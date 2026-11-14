(* A submission with a type error, used to check the compile-error path. *)

let my_rev l = List.fold_left (fun acc x -> x :: acc) [] l

let compress l = l
let sum_squares_of_odds l = List.fold_left ( + ) 0 l + "1"   (* int + string *)
let safe_div _ _ = None

type expr =
  | Num of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let eval _ = None
