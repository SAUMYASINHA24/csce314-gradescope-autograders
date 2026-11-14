(* Compiles on its own, but my_rev has the wrong type (list of lists). *)

let rec my_rev l = match l with [] -> [] | x :: xs -> my_rev xs @ x

let compress l = l
let sum_squares_of_odds _ = 0
let safe_div _ _ = None

type expr =
  | Num of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let eval _ = None
