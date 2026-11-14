(* CSCE 314 style practice homework (OCaml): lists, tail recursion,
   options, algebraic data types and higher-order functions.

   Rules:
   - Keep every name and type exactly as given.
   - Replace each [failwith "TODO"] with your implementation.
   - Do NOT use List.rev in [my_rev].
   - Submit only this file (hw1.ml) to Gradescope. *)

(* Problem 1 (lists, tail recursion). Reverse a list without List.rev.
   Must be tail recursive and run in linear time: the autograder reverses
   a list of 1,000,000 elements.
     my_rev [1; 2; 3] = [3; 2; 1] *)
let my_rev (_l : 'a list) : 'a list = failwith "TODO"

(* Problem 2 (lists, patterns). Remove consecutive duplicates.
     compress ['a';'a';'b';'c';'c';'a'] = ['a';'b';'c';'a'] *)
let compress (_l : 'a list) : 'a list = failwith "TODO"

(* Problem 3 (higher-order functions). Sum of the squares of the odd
   numbers. Use List.filter / List.map / List.fold_left, no explicit
   recursion.
     sum_squares_of_odds [1; 2; 3; 4; 5] = 35 *)
let sum_squares_of_odds (_l : int list) : int = failwith "TODO"

(* Problem 4 (options). Integer division that fails safely on zero.
   Uses OCaml's ( / ), which rounds toward zero.
     safe_div 7 2 = Some 3     safe_div 7 0 = None     safe_div (-7) 2 = Some (-3) *)
let safe_div (_a : int) (_b : int) : int option = failwith "TODO"

(* Problem 5 (algebraic data types). A tiny arithmetic language. *)
type expr =
  | Num of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

(* Evaluate an expression. Division by zero anywhere makes the whole
   result None.
     eval (Add (Num 2, Mul (Num 3, Num 4))) = Some 14
     eval (Div (Num 1, Sub (Num 2, Num 2))) = None *)
let eval (_e : expr) : int option = failwith "TODO"
