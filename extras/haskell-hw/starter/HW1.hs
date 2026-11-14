-- CSCE 314 style practice homework: recursion, higher-order functions,
-- Maybe, and a tiny expression evaluator.
--
-- Rules:
--   * Keep the module name and every type signature exactly as given.
--   * Replace each `undefined` with your implementation.
--   * Do NOT use the library function that a problem asks you to write
--     (e.g. don't call `reverse` inside myReverse).
--   * Submit only this file (HW1.hs) to Gradescope.

module HW1
  ( myReverse
  , compress
  , sumSquaresOfOdds
  , safeDiv
  , Expr (..)
  , eval
  ) where

-- | Problem 1 (recursion). Reverse a list without using `reverse`.
--
-- >>> myReverse [1,2,3]
-- [3,2,1]
myReverse :: [a] -> [a]
myReverse = undefined

-- | Problem 2 (recursion + Eq). Remove consecutive duplicates.
--
-- >>> compress "aaabccaadeeee"
-- "abcade"
compress :: Eq a => [a] -> [a]
compress = undefined

-- | Problem 3 (higher-order functions). Sum of the squares of the odd
-- numbers in a list. Use map / filter / foldr (no explicit recursion).
--
-- >>> sumSquaresOfOdds [1,2,3,4,5]
-- 35
sumSquaresOfOdds :: [Int] -> Int
sumSquaresOfOdds = undefined

-- | Problem 4 (Maybe). Integer division that fails safely on zero.
--
-- >>> safeDiv 7 2
-- Just 3
-- >>> safeDiv 7 0
-- Nothing
safeDiv :: Int -> Int -> Maybe Int
safeDiv = undefined

-- | Problem 5 (language implementation). A tiny arithmetic language.
data Expr
  = Num Int
  | Add Expr Expr
  | Sub Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  deriving (Show, Eq)

-- | Evaluate an expression. Division by zero anywhere makes the whole
-- result Nothing. Division uses `div` (rounds toward negative infinity).
--
-- >>> eval (Add (Num 2) (Mul (Num 3) (Num 4)))
-- Just 14
-- >>> eval (Div (Num 1) (Sub (Num 2) (Num 2)))
-- Nothing
eval :: Expr -> Maybe Int
eval = undefined
