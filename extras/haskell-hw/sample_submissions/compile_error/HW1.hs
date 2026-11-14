-- A submission with a type error, used to check the compile-error path.

module HW1
  ( myReverse
  , compress
  , sumSquaresOfOdds
  , safeDiv
  , Expr (..)
  , eval
  ) where

myReverse :: [a] -> [a]
myReverse [] = []
myReverse (x : xs) = myReverse xs ++ x   -- type error: x is not a list

compress :: Eq a => [a] -> [a]
compress = id

sumSquaresOfOdds :: [Int] -> Int
sumSquaresOfOdds = const 0

safeDiv :: Int -> Int -> Maybe Int
safeDiv _ _ = Nothing

data Expr
  = Num Int
  | Add Expr Expr
  | Sub Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  deriving (Show, Eq)

eval :: Expr -> Maybe Int
eval _ = Nothing
