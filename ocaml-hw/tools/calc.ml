(* Interactive calculator: type an expression, see the AST that the
   ocamlyacc parser builds and what eval returns. *)

open Hw1

let rec show = function
  | Num n -> Printf.sprintf "Num (%d)" n
  | Add (a, b) -> Printf.sprintf "Add (%s, %s)" (show a) (show b)
  | Sub (a, b) -> Printf.sprintf "Sub (%s, %s)" (show a) (show b)
  | Mul (a, b) -> Printf.sprintf "Mul (%s, %s)" (show a) (show b)
  | Div (a, b) -> Printf.sprintf "Div (%s, %s)" (show a) (show b)

let () =
  print_endline "Type an expression (e.g. 2 + 3 * -4), or an empty line to quit.";
  let rec loop () =
    print_string "> ";
    match read_line () with
    | exception End_of_file -> ()
    | "" -> ()
    | line ->
      let lexbuf = Lexing.from_string line in
      (match Parser.main Lexer.token lexbuf with
       | e ->
         Printf.printf "  AST:   %s\n  value: %s\n" (show e)
           (match eval e with Some n -> string_of_int n | None -> "None (division by zero)")
       | exception Lexer.Lex_error msg -> print_endline msg
       | exception Parsing.Parse_error ->
         Printf.printf "parse error near '%s'\n" (Lexing.lexeme lexbuf));
      loop ()
  in
  loop ()
