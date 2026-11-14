(* Autograder test suite for hw1.ml.

   Four kinds of checks a real course autograder needs:
   1. Unit tests with fixed inputs (visible, clear feedback).
   2. Randomized tests against a hidden reference solution, reporting the
      first counterexample (catches edge cases students did not think of).
   3. Rule checks: my_rev must not call List.rev and must be linear-time /
      tail recursive (it has to reverse 1,000,000 elements quickly).
   4. Readable evaluator tests written as plain arithmetic in
      eval_cases.txt, turned into Hw1.expr values by a lexer and parser
      generated with ocamllex and ocamlyacc (lexer.mll, parser.mly).

   Every test runs under a time limit and catches exceptions, so one
   infinite loop or failwith costs only that test's points. Results are
   written in Gradescope's results.json format. *)

open Hw1

(* ------------------------------------------------------------------ *)
(* Hidden reference solution                                            *)

let ref_rev l = List.fold_left (fun acc x -> x :: acc) [] l

let rec ref_compress = function
  | x :: (y :: _ as r) -> if x = y then ref_compress r else x :: ref_compress r
  | l -> l

let ref_sum l = List.fold_left (fun acc x -> if x mod 2 <> 0 then acc + x * x else acc) 0 l

let rec ref_eval = function
  | Num n -> Some n
  | Add (a, b) -> ref_bin ( + ) a b
  | Sub (a, b) -> ref_bin ( - ) a b
  | Mul (a, b) -> ref_bin ( * ) a b
  | Div (a, b) ->
    (match ref_eval a, ref_eval b with
     | Some _, Some 0 -> None
     | Some x, Some y -> Some (x / y)
     | _ -> None)
and ref_bin f a b =
  match ref_eval a, ref_eval b with
  | Some x, Some y -> Some (f x y)
  | _ -> None

(* ------------------------------------------------------------------ *)
(* Printers for feedback messages                                       *)

let show_list f l = "[" ^ String.concat "; " (List.map f l) ^ "]"
let show_ints = show_list string_of_int
let show_chars = show_list (Printf.sprintf "'%c'")
let show_opt = function None -> "None" | Some n -> Printf.sprintf "Some (%d)" n

let rec show_expr = function
  | Num n -> Printf.sprintf "Num (%d)" n
  | Add (a, b) -> Printf.sprintf "Add (%s, %s)" (show_expr a) (show_expr b)
  | Sub (a, b) -> Printf.sprintf "Sub (%s, %s)" (show_expr a) (show_expr b)
  | Mul (a, b) -> Printf.sprintf "Mul (%s, %s)" (show_expr a) (show_expr b)
  | Div (a, b) -> Printf.sprintf "Div (%s, %s)" (show_expr a) (show_expr b)

(* ------------------------------------------------------------------ *)
(* Test framework                                                       *)

exception Timeout

type test = {
  name : string;
  points : float;
  visible : bool;            (* false = "after_published" (hidden until grades are out) *)
  run : unit -> bool * string;
}

let expect show expected actual =
  if actual = expected then (true, "Passed.")
  else (false, Printf.sprintf "Expected %s but got %s" (show expected) (show actual))

(* Run [f] under a time limit; any exception becomes a failure message. *)
let with_limit seconds f =
  Sys.set_signal Sys.sigalrm (Sys.Signal_handle (fun _ -> raise Timeout));
  ignore (Unix.alarm seconds);
  let result =
    try f () with
    | Timeout -> (false, Printf.sprintf "Timed out after %d seconds (infinite loop or too slow?)." seconds)
    | Stack_overflow -> (false, "Stack overflow (is your function tail recursive?).")
    | Failure msg -> (false, "Raised Failure \"" ^ msg ^ "\" (did you leave a TODO?).")
    | Division_by_zero -> (false, "Raised Division_by_zero.")
    | e -> (false, "Raised exception " ^ Printexc.to_string e)
  in
  ignore (Unix.alarm 0);
  result

(* Randomized test: compare with the reference on [n] generated inputs. *)
let random_test ~n ~gen ~show ~ok =
  Random.init 314;
  let rec loop i =
    if i = n then (true, Printf.sprintf "Passed %d random tests." n)
    else
      let x = gen () in
      match ok x with
      | Ok () -> loop (i + 1)
      | Error msg -> (false, Printf.sprintf "Failed on a random input:\n  input: %s\n  %s" (show x) msg)
  in
  loop 0

let gen_list ?(lo = -50) ?(hi = 50) () =
  List.init (Random.int 30) (fun _ -> lo + Random.int (hi - lo + 1))

let rec gen_expr depth =
  if depth = 0 || Random.int 4 = 0 then Num (Random.int 11 - 5)
  else
    let a = gen_expr (depth - 1) and b = gen_expr (depth - 1) in
    match Random.int 4 with
    | 0 -> Add (a, b)
    | 1 -> Sub (a, b)
    | 2 -> Mul (a, b)
    | _ -> Div (a, b)

(* Static check: the source of [fn]'s definition must not mention [banned]. *)
let contains s sub =
  let n = String.length s and m = String.length sub in
  let rec go i = i + m <= n && (String.sub s i m = sub || go (i + 1)) in
  go 0

let definition_of fn src =
  let lines = String.split_on_char '\n' src in
  let starts l = contains l ("let " ^ fn ^ " ") || contains l ("let rec " ^ fn ^ " ") in
  let rec skip = function [] -> [] | l :: r -> if starts l then l :: take r else skip r
  and take = function
    | [] -> []
    | l :: r ->
      let top = String.length l >= 4 && (String.sub l 0 4 = "let " || String.sub l 0 4 = "type") in
      if top then [] else l :: take r
  in
  String.concat "\n" (skip lines)

(* ------------------------------------------------------------------ *)
(* eval_cases.txt -> tests, using the ocamllex/ocamlyacc parser          *)

let trim = String.trim

let split_arrow line =
  let n = String.length line in
  let rec find i =
    if i + 1 >= n then None
    else if line.[i] = '=' && line.[i + 1] = '>' then Some i
    else find (i + 1)
  in
  match find 0 with
  | None -> (line, "")
  | Some i -> (String.sub line 0 i, String.sub line (i + 2) (n - i - 2))

let parse_expr s =
  let lexbuf = Lexing.from_string s in
  try Ok (Parser.main Lexer.token lexbuf) with
  | Lexer.Lex_error msg -> Error msg
  | Parsing.Parse_error ->
    let p = Lexing.lexeme_start_p lexbuf in
    Error (Printf.sprintf "parse error at column %d near '%s'"
             (p.Lexing.pos_cnum - p.Lexing.pos_bol + 1) (Lexing.lexeme lexbuf))

let case_tests text =
  String.split_on_char '\n' text
  |> List.mapi (fun i l -> (i + 1, trim l))
  |> List.filter (fun (_, l) -> l <> "" && l.[0] <> '#')
  |> List.map (fun (lineno, l) ->
      let lhs, rhs = split_arrow l in
      let lhs = trim lhs and rhs = trim rhs in
      let config_error msg =
        Printf.printf "AUTOGRADER CONFIG ERROR in eval_cases.txt line %d: %s\n" lineno msg;
        (false, Printf.sprintf "This test is misconfigured; please tell the instructor (eval_cases.txt line %d)." lineno)
      in
      { name = Printf.sprintf "P5 eval (eval_cases.txt line %d): %s" lineno lhs;
        points = 0.5; visible = true;
        run = (fun () ->
          let expected =
            if rhs = "error" then Some None
            else Option.map (fun n -> Some n) (int_of_string_opt rhs)
          in
          match parse_expr lhs, expected with
          | Error msg, _ -> config_error ("cannot parse the expression: " ^ msg)
          | _, None -> config_error (Printf.sprintf "bad expected value %S (use an integer or 'error')" rhs)
          | Ok e, Some want ->
            let ok, msg = expect show_opt want (eval e) in
            (ok, if ok then msg else msg ^ "\n  parsed as: " ^ show_expr e)) })

(* ------------------------------------------------------------------ *)
(* Test cases                                                           *)

let base_tests src = [
  { name = "P1 my_rev: basic example"; points = 1.; visible = true;
    run = (fun () -> expect show_ints [3; 2; 1] (my_rev [1; 2; 3])) };
  { name = "P1 my_rev: empty list"; points = 1.; visible = true;
    run = (fun () -> expect show_ints [] (my_rev [])) };
  { name = "P1 my_rev: matches reference on random lists"; points = 2.; visible = false;
    run = (fun () -> random_test ~n:300 ~gen:gen_list ~show:show_ints
              ~ok:(fun l -> let got = my_rev l in
                    if got = ref_rev l then Ok () else Error ("got " ^ show_ints got))) };
  { name = "P1 my_rev: tail recursive and linear time (1,000,000 elements)"; points = 1.; visible = true;
    run = (fun () ->
      let big = List.init 1_000_000 Fun.id in
      match my_rev big with
      | x :: _ as r when x = 999_999 && List.length r = 1_000_000 -> (true, "Passed.")
      | _ -> (false, "Wrong result on a 1,000,000-element list.")) };
  { name = "P1 my_rev: does not call List.rev"; points = 1.; visible = true;
    run = (fun () ->
      let body = definition_of "my_rev" src in
      if contains body "List.rev" || contains body "rev_append"
      then (false, "my_rev uses the banned function List.rev.")
      else (true, "Passed.")) };

  { name = "P2 compress: example from the handout"; points = 1.; visible = true;
    run = (fun () -> expect show_chars ['a'; 'b'; 'c'; 'a'] (compress ['a'; 'a'; 'b'; 'c'; 'c'; 'a'])) };
  { name = "P2 compress: matches reference on random lists"; points = 2.; visible = false;
    run = (fun () -> random_test ~n:300 ~gen:(gen_list ~lo:0 ~hi:2) ~show:show_ints
              ~ok:(fun l -> let got = compress l in
                    if got = ref_compress l then Ok () else Error ("got " ^ show_ints got))) };

  { name = "P3 sum_squares_of_odds: example"; points = 1.; visible = true;
    run = (fun () -> expect string_of_int 35 (sum_squares_of_odds [1; 2; 3; 4; 5])) };
  { name = "P3 sum_squares_of_odds: negatives and empty list"; points = 1.; visible = true;
    run = (fun () ->
      let ok1, m1 = expect string_of_int 10 (sum_squares_of_odds [-3; -2; 1; 0]) in
      if not ok1 then (ok1, m1) else expect string_of_int 0 (sum_squares_of_odds [])) };
  { name = "P3 sum_squares_of_odds: matches reference on random lists"; points = 2.; visible = false;
    run = (fun () -> random_test ~n:300 ~gen:gen_list ~show:show_ints
              ~ok:(fun l -> let got = sum_squares_of_odds l in
                    if got = ref_sum l then Ok () else Error ("got " ^ string_of_int got))) };

  { name = "P4 safe_div: normal division"; points = 1.; visible = true;
    run = (fun () -> expect show_opt (Some 3) (safe_div 7 2)) };
  { name = "P4 safe_div: divide by zero"; points = 1.; visible = true;
    run = (fun () -> expect show_opt None (safe_div 7 0)) };
  { name = "P4 safe_div: negative numbers round toward zero"; points = 1.; visible = true;
    run = (fun () -> expect show_opt (Some (-3)) (safe_div (-7) 2)) };

  { name = "P5 eval: nested expression"; points = 1.; visible = true;
    run = (fun () -> expect show_opt (Some 14) (eval (Add (Num 2, Mul (Num 3, Num 4))))) };
  { name = "P5 eval: division by zero propagates"; points = 2.; visible = true;
    run = (fun () -> expect show_opt None (eval (Add (Num 1, Div (Num 1, Sub (Num 2, Num 2)))))) };
  { name = "P5 eval: matches reference on random expressions"; points = 3.; visible = false;
    run = (fun () -> random_test ~n:300 ~gen:(fun () -> gen_expr 5) ~show:show_expr
              ~ok:(fun e -> let got = eval e and want = ref_eval e in
                    if got = want then Ok ()
                    else Error (Printf.sprintf "expected %s but got %s" (show_opt want) (show_opt got)))) };
]

(* ------------------------------------------------------------------ *)
(* results.json                                                         *)

let json_string s =
  let b = Buffer.create (String.length s + 2) in
  Buffer.add_char b '"';
  String.iter (function
      | '"' -> Buffer.add_string b "\\\""
      | '\\' -> Buffer.add_string b "\\\\"
      | '\n' -> Buffer.add_string b "\\n"
      | '\t' -> Buffer.add_string b "\\t"
      | c when Char.code c < 32 -> Buffer.add_char b ' '
      | c -> Buffer.add_char b c) s;
  Buffer.add_char b '"';
  Buffer.contents b

let num f = if Float.is_integer f then string_of_int (int_of_float f) else Printf.sprintf "%g" f

let read_file path =
  let ic = open_in_bin path in
  let s = really_input_string ic (in_channel_length ic) in
  close_in ic; s

let () =
  let env k d = Option.value (Sys.getenv_opt k) ~default:d in
  let src = read_file (env "HW1_SOURCE" "hw1.ml") in
  let cases = read_file (env "EVAL_CASES" "eval_cases.txt") in
  let out = env "RESULTS_JSON" "results.json" in
  let tests = base_tests src @ case_tests cases in
  let results = List.map (fun t ->
      let ok, msg = with_limit 3 t.run in
      Printf.printf "%s %s\n%!" (if ok then "[PASS]" else "[FAIL]") t.name;
      (t, ok, msg)) tests in
  let earned = List.fold_left (fun a (t, ok, _) -> if ok then a +. t.points else a) 0. results in
  let total = List.fold_left (fun a (t, _, _) -> a +. t.points) 0. results in
  let one (t, ok, msg) =
    Printf.sprintf "{\"name\":%s,\"score\":%s,\"max_score\":%s,\"output\":%s,\"visibility\":%s}"
      (json_string t.name) (num (if ok then t.points else 0.)) (num t.points)
      (json_string msg) (json_string (if t.visible then "visible" else "after_published"))
  in
  let summary = Printf.sprintf "Autograder score: %s / %s. Tests marked hidden are revealed after grades are published."
      (num earned) (num total) in
  let oc = open_out_bin out in
  Printf.fprintf oc "{\"score\":%s,\"output\":%s,\"visibility\":\"visible\",\"stdout_visibility\":\"hidden\",\"tests\":[%s]}\n"
    (num earned) (json_string summary) (String.concat "," (List.map one results));
  close_out oc;
  Printf.printf "Score: %s / %s\n" (num earned) (num total)
