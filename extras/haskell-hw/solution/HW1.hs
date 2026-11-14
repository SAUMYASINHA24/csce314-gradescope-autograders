-- Reference solution (instructor only, not distributed to students).

module HW1
  ( myReverse
  , compress
  , sumSquaresOfOdds
  , safeDiv
  , Expr (..)
  , eval
  ) where

myReverse :: [a] -> [a]
myReverse = go []
  where
    go acc []       = acc
    go acc (x : xs) = go (x : acc) xs

compress :: Eq a => [a] -> [a]
compress (x : y : rest)
  | x == y    = compress (y : rest)
  | otherwise = x : compress (y : rest)
compress xs = xs

sumSquaresOfOdds :: [Int] -> Int
sumSquaresOfOdds = foldr (+) 0 . map (^ (2 :: Int)) . filter odd

safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv a b = Just (a `div` b)

data Expr
  = Num Int
  | Add Expr Expr
  | Sub Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
  deriving (Show, Eq)

eval :: Expr -> Maybe Int
eval (Num n)   = Just n
eval (Add a b) = (+) <$> eval a <*> eval b
eval (Sub a b) = (-) <$> eval a <*> eval b
eval (Mul a b) = (*) <$> eval a <*> eval b
eval (Div a b) = do
  x <- eval a
  y <- eval b
  safeDiv x y
