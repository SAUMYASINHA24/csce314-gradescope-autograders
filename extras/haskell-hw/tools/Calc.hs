-- Interactive calculator: type an expression, see the Expr the Happy parser
-- builds and what eval returns. Handy for playing with the grammar.
module Main (main) where

import ExprParser (parseExpr)
import HW1 (eval)
import System.IO

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  putStrLn "Type an expression (e.g. 2 + 3 * -4), or an empty line to quit."
  loop
  where
    loop = do
      putStr "> "
      eof <- isEOF
      if eof then pure () else do
        line <- getLine
        if null line then pure () else do
          case parseExpr line of
            Left err -> putStrLn err
            Right e  -> do
              putStrLn ("  AST:   " ++ show e)
              putStrLn ("  value: " ++ maybe "error (division by zero)" show (eval e))
          loop
