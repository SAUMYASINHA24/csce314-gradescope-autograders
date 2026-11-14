(* A deliberately buggy submission, used to check that the autograder gives
   partial credit and useful feedback. *)

(* Bug: uses the banned List.rev. *)
let my_rev l = List.rev l

(* Bug: removes ALL duplicates, not just consecutive ones. *)
let compress l =
  List.fold_left (fun acc x -> if List.mem x acc then acc else acc @ [x]) [] l

(* Bug: infinite loop on any non-empty list. *)
let rec sum_squares_of_odds l = if l = [] then 0 else sum_squares_of_odds (l @ [])

(* Bug: Some 0 instead of None on division by zero. *)
let safe_div a b = if b = 0 then Some 0 else Some (a / b)

type expr =
  | Num of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

(* Bug: crashes with Division_by_zero instead of returning None. *)
let rec eval e =
  match e with
  | Num n -> Some n
  | Add (a, b) -> Option.bind (eval a) (fun x -> Option.map (fun y -> x + y) (eval b))
  | Sub (a, b) -> Option.bind (eval a) (fun x -> Option.map (fun y -> x - y) (eval b))
  | Mul (a, b) -> Option.bind (eval a) (fun x -> Option.map (fun y -> x * y) (eval b))
  | Div (a, b) -> Option.bind (eval a) (fun x -> Option.map (fun y -> x / y) (eval b))
