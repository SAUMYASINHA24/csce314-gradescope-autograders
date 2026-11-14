(* Reference solution (instructor only, not distributed to students). *)

let my_rev (l : 'a list) : 'a list =
  let rec go acc = function
    | [] -> acc
    | x :: xs -> go (x :: acc) xs
  in
  go [] l

let rec compress (l : 'a list) : 'a list =
  match l with
  | x :: (y :: _ as rest) -> if x = y then compress rest else x :: compress rest
  | short -> short

let sum_squares_of_odds (l : int list) : int =
  l |> List.filter (fun x -> x mod 2 <> 0)
    |> List.map (fun x -> x * x)
    |> List.fold_left ( + ) 0

let safe_div (a : int) (b : int) : int option =
  if b = 0 then None else Some (a / b)

type expr =
  | Num of int
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec eval (e : expr) : int option =
  let both f a b =
    match eval a, eval b with
    | Some x, Some y -> f x y
    | _ -> None
  in
  match e with
  | Num n -> Some n
  | Add (a, b) -> both (fun x y -> Some (x + y)) a b
  | Sub (a, b) -> both (fun x y -> Some (x - y)) a b
  | Mul (a, b) -> both (fun x y -> Some (x * y)) a b
  | Div (a, b) -> both safe_div a b
