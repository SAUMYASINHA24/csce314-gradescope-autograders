{-# LANGUAGE ScopedTypeVariables #-}
-- Autograder test suite for HW1.
--
-- Combines three kinds of checks that a real course autograder needs:
--   1. Unit tests with fixed inputs (visible to students, good feedback).
--   2. QuickCheck property tests against a hidden reference solution
--      (catch edge cases students did not think of).
--   3. A static check that the student did not call a banned function.
--
--   4. Readable test cases for the evaluator, written as plain arithmetic in
--      eval_cases.txt and turned into Expr values by a lexer and parser
--      generated with Alex and Happy (ExprLexer.x, ExprParser.y).
--
-- Every test runs under a timeout and catches exceptions, so one infinite
-- loop or `undefined` costs only that test's points.
-- Results are written in Gradescope's results.json format.

module Main (main) where

import qualified HW1 as S
import ExprParser (parseExpr)
import Data.Char (isSpace)
import Text.Read (readMaybe)
import Control.Exception (SomeException, evaluate, try)
import Data.Char (isAlphaNum)
import Data.List (isPrefixOf)
import System.Environment (lookupEnv)
import GHC.IO.Encoding (setLocaleEncoding, utf8)
import System.IO (hFlush, stdout)
import System.Timeout (timeout)
import Test.QuickCheck

------------------------------------------------------------------------
-- Hidden reference solution (students never see the autograder source)

refReverse :: [a] -> [a]
refReverse = foldl (flip (:)) []

refCompress :: Eq a => [a] -> [a]
refCompress (x : y : r) | x == y = refCompress (y : r)
                        | otherwise = x : refCompress (y : r)
refCompress xs = xs

refSumSq :: [Int] -> Int
refSumSq xs = sum [x * x | x <- xs, odd x]

refEval :: S.Expr -> Maybe Int
refEval (S.Num n)   = Just n
refEval (S.Add a b) = (+) <$> refEval a <*> refEval b
refEval (S.Sub a b) = (-) <$> refEval a <*> refEval b
refEval (S.Mul a b) = (*) <$> refEval a <*> refEval b
refEval (S.Div a b) = do
  x <- refEval a
  y <- refEval b
  if y == 0 then Nothing else Just (x `div` y)

-- Random expression generator for property tests (small numbers so
-- division by zero actually shows up).
instance Arbitrary S.Expr where
  arbitrary = sized gen
    where
      gen 0 = S.Num <$> choose (-5, 5)
      gen n = oneof
        [ S.Num <$> choose (-5, 5)
        , S.Add <$> sub <*> sub
        , S.Sub <$> sub <*> sub
        , S.Mul <$> sub <*> sub
        , S.Div <$> sub <*> sub
        ]
        where sub = gen (n `div` 2)

------------------------------------------------------------------------
-- Test framework

data Visibility = Visible | AfterPublished

data TestCase = TestCase
  { tName       :: String
  , tPoints     :: Double
  , tVisibility :: Visibility
  , tRun        :: IO (Bool, String)
  }

-- | Compare a value with the expected one, forcing it fully via `show`.
expect :: (Eq a, Show a) => a -> a -> IO (Bool, String)
expect expected actual = do
  r <- try (evaluate (length (show actual) `seq` actual == expected))
  pure $ case r of
    Left (e :: SomeException)
      | show e == "<<timeout>>" -> (False, "Timed out after 3 seconds (infinite loop?).")
      | otherwise -> (False, "Raised an exception: " ++ firstLine (show e))
    Right True  -> (True, "Passed.")
    Right False -> (False, "Expected " ++ show expected ++ " but got " ++ show actual)

-- | Run a QuickCheck property quietly and report the counterexample.
property' :: Testable p => p -> IO (Bool, String)
property' p = do
  -- `within` gives each random case its own time limit, so an infinite
  -- loop fails fast instead of being swallowed by QuickCheck's shrinking.
  r <- quickCheckWithResult stdArgs { chatty = False, maxSuccess = 300, maxShrinks = 20 }
         (within 200000 p)
  pure $ if isSuccess r
    then (True, "Passed 300 random tests.")
    else (False, "Failed on a random test:\n" ++ output r)

-- | Static check: the given function's definition must not call `banned`.
notUsing :: String -> String -> String -> IO (Bool, String)
notUsing src fn banned =
  let body = definitionOf fn src
      used = banned `elem` wordsOf body
  in pure $ if used
       then (False, fn ++ " uses the banned function `" ++ banned ++ "`.")
       else (True, "Passed.")

definitionOf :: String -> String -> [String]
definitionOf fn src =
  let ls = lines src
      starts l = (fn ++ " ") `isPrefixOf` l || (fn ++ "=") `isPrefixOf` l
      rest = dropWhile (not . starts) ls
      isCont l = null l || take 1 l == " " || starts l
  in takeWhile isCont rest

wordsOf :: [String] -> [String]
wordsOf = concatMap (words . map (\c -> if isAlphaNum c || c == '_' || c == '\'' then c else ' '))

firstLine :: String -> String
firstLine = takeWhile (/= '\n')

-- | Run one test with a time limit; exceptions and timeouts become failures.
runTest :: TestCase -> IO (TestCase, Bool, String)
runTest t = do
  r <- timeout 3000000 (try (tRun t))
  let (ok, msg) = case r of
        Nothing -> (False, "Timed out after 3 seconds (infinite loop?).")
        Just (Left (e :: SomeException)) -> (False, "Raised an exception: " ++ firstLine (show e))
        Just (Right res) -> res
  putStrLn ((if ok then "[PASS] " else "[FAIL] ") ++ tName t) >> hFlush stdout
  pure (t, ok, msg)

------------------------------------------------------------------------
-- Test cases

tests :: String -> String -> [TestCase]
tests src cases = baseTests src ++ caseTests cases

-- | One test per non-comment line of eval_cases.txt:  expression => expected
caseTests :: String -> [TestCase]
caseTests txt =
  [ TestCase ("P5 eval (eval_cases.txt line " ++ show n ++ "): " ++ trim lhs) 0.5 Visible (runCase n lhs rhs)
  | (n, l) <- zip [1 :: Int ..] (lines txt)
  , let t = trim l
  , not (null t), take 1 t /= "#"
  , let (lhs, rhs) = splitArrow t
  ]

runCase :: Int -> String -> String -> IO (Bool, String)
runCase n lhs rhs =
  case (parseExpr lhs, expected (trim rhs)) of
    (Left err, _) -> configError ("cannot parse the expression: " ++ err)
    (_, Nothing)  -> configError ("bad expected value " ++ show (trim rhs) ++ " (use an integer or 'error')")
    (Right e, Just want) -> do
      (ok, msg) <- expect want (S.eval e)
      pure (ok, if ok then msg else msg ++ "\n  parsed as: " ++ show e)
  where
    expected "error" = Just Nothing
    expected v       = Just <$> readMaybe v
    configError m = do
      putStrLn ("AUTOGRADER CONFIG ERROR in eval_cases.txt line " ++ show n ++ ": " ++ m)
      pure (False, "This test is misconfigured; please tell the instructor (eval_cases.txt line " ++ show n ++ ").")

splitArrow :: String -> (String, String)
splitArrow = go ""
  where
    go acc ('=' : '>' : rest) = (reverse acc, rest)
    go acc (c : rest)         = go (c : acc) rest
    go acc []                 = (reverse acc, "")

trim :: String -> String
trim = f . f where f = reverse . dropWhile isSpace

baseTests :: String -> [TestCase]
baseTests src =
  [ TestCase "P1 myReverse: basic examples" 1 Visible $
      expect [3, 2, 1 :: Int] (S.myReverse [1, 2, 3])
  , TestCase "P1 myReverse: empty list" 1 Visible $
      expect ([] :: [Int]) (S.myReverse [])
  , TestCase "P1 myReverse: matches reference on random lists" 2 AfterPublished $
      property' (\(xs :: [Int]) -> S.myReverse xs == refReverse xs)
  , TestCase "P1 myReverse: does not call reverse" 1 Visible $
      notUsing src "myReverse" "reverse"

  , TestCase "P2 compress: example from the handout" 1 Visible $
      expect "abcade" (S.compress "aaabccaadeeee")
  , TestCase "P2 compress: matches reference on random lists" 2 AfterPublished $
      -- small values (0..2) so consecutive duplicates are common
      property' (forAll (listOf (choose (0, 2 :: Int))) (\xs -> S.compress xs == refCompress xs))

  , TestCase "P3 sumSquaresOfOdds: example" 1 Visible $
      expect 35 (S.sumSquaresOfOdds [1, 2, 3, 4, 5])
  , TestCase "P3 sumSquaresOfOdds: negatives and empty list" 1 Visible $
      expect (9 + 1) (S.sumSquaresOfOdds [-3, -2, 1, 0])
  , TestCase "P3 sumSquaresOfOdds: matches reference on random lists" 2 AfterPublished $
      property' (\xs -> S.sumSquaresOfOdds xs == refSumSq xs)

  , TestCase "P4 safeDiv: normal division" 1 Visible $
      expect (Just 3) (S.safeDiv 7 2)
  , TestCase "P4 safeDiv: divide by zero" 1 Visible $
      expect Nothing (S.safeDiv 7 0)
  , TestCase "P4 safeDiv: negative numbers use div" 1 Visible $
      expect (Just (-4)) (S.safeDiv (-7) 2)

  , TestCase "P5 eval: nested expression" 1 Visible $
      expect (Just 14) (S.eval (S.Add (S.Num 2) (S.Mul (S.Num 3) (S.Num 4))))
  , TestCase "P5 eval: division by zero propagates" 2 Visible $
      expect Nothing (S.eval (S.Add (S.Num 1) (S.Div (S.Num 1) (S.Sub (S.Num 2) (S.Num 2)))))
  , TestCase "P5 eval: matches reference on random expressions" 3 AfterPublished $
      property' (\e -> S.eval e == refEval e)
  ]

------------------------------------------------------------------------
-- results.json

jsonString :: String -> String
jsonString s = "\"" ++ concatMap esc s ++ "\""
  where
    esc '"'  = "\\\""
    esc '\\' = "\\\\"
    esc '\n' = "\\n"
    esc '\t' = "\\t"
    esc c | c < ' '   = ' ' : []
          | otherwise = [c]

showNum :: Double -> String
showNum d = if d == fromIntegral (round d :: Int) then show (round d :: Int) else show d

toJson :: [(TestCase, Bool, String)] -> String
toJson rs =
  let total  = sum [tPoints t | (t, ok, _) <- rs, ok]
      maxPts = sum [tPoints t | (t, _, _) <- rs]
      one (t, ok, msg) = concat
        [ "{\"name\":", jsonString (tName t)
        , ",\"score\":", showNum (if ok then tPoints t else 0)
        , ",\"max_score\":", showNum (tPoints t)
        , ",\"output\":", jsonString msg
        , ",\"visibility\":", jsonString (vis (tVisibility t))
        , "}" ]
      vis Visible = "visible"
      vis AfterPublished = "after_published"
      summary = "Autograder score: " ++ showNum total ++ " / " ++ showNum maxPts
        ++ ". Tests marked hidden are revealed after grades are published."
  in concat
       [ "{\"score\":", showNum total
       , ",\"output\":", jsonString summary
       , ",\"visibility\":\"visible\""
       , ",\"stdout_visibility\":\"hidden\""
       , ",\"tests\":[", joinWith "," (map one rs), "]}\n" ]
  where
    joinWith _ [] = ""
    joinWith sep (x : xs) = x ++ concatMap (sep ++) xs

main :: IO ()
main = do
  setLocaleEncoding utf8
  srcPath <- maybe "HW1.hs" id <$> lookupEnv "HW1_SOURCE"
  outPath <- maybe "results.json" id <$> lookupEnv "RESULTS_JSON"
  casesPath <- maybe "eval_cases.txt" id <$> lookupEnv "EVAL_CASES"
  src <- readFile srcPath
  cases <- readFile casesPath
  length src `seq` length cases `seq` pure ()
  results <- mapM runTest (tests src cases)
  writeFile outPath (toJson results)
  let got = sum [tPoints t | (t, ok, _) <- results, ok]
      tot = sum [tPoints t | (t, _, _) <- results]
  putStrLn ("Score: " ++ showNum got ++ " / " ++ showNum tot)
