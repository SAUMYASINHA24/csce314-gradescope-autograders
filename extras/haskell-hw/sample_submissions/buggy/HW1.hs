-- A deliberately buggy submission, used to check that the autograder gives
-- partial credit and useful feedback.

module HW1
  ( myReverse
  , compress
  , sumSquaresOfOdds
  , safeDiv
  , Expr (..)
  , eval
  ) where

import Data.List (nub)

-- Bug: calls the banned library function.
myReverse :: [a] -> [a]
myReverse xs = reverse xs

-- Bug: removes ALL duplicates, not just consecutive ones.
compress :: Eq a => [a] -> [a]
compress = nub

-- Bug: infinite loop on any non-empty list.
sumSquaresOfOdds :: [Int] -> Int
sumSquaresOfOdds [] = 0
sumSquaresOfOdds xs = sumSquaresOfOdds (xs ++ [])

-- Bug: quot instead of div (wrong for negatives).
safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv a b = Just (a `quot` b)

data Expr
  = Num Int
  | Add Expr Expr
  | Sub Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  deriving (Show, Eq)

-- Bug: crashes on division by zero instead of returning Nothing.
eval :: Expr -> Maybe Int
eval (Num n)   = Just n
eval (Add a b) = (+) <$> eval a <*> eval b
eval (Sub a b) = (-) <$> eval a <*> eval b
eval (Mul a b) = (*) <$> eval a <*> eval b
eval (Div a b) = div <$> eval a <*> eval b
