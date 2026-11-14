# extras/haskell-hw

The same homework and autograder design in Haskell: unit tests, QuickCheck
properties against a hidden reference solution, a static check, and an
**Alex** lexer + **Happy** parser for the plain-arithmetic test cases.

```bash
./run_local.sh extras/haskell-hw extras/haskell-hw/sample_submissions/correct   # 27.5 / 27.5
./extras/haskell-hw/tools/calc.sh
```

Needs `ghc` with QuickCheck, `alex` and `happy`.
