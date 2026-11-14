#!/usr/bin/env bash
# Build and run the calculator using the reference solution's eval.
#   ./extras/haskell-hw/tools/calc.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
W="$(mktemp -d)"
cp "$HERE/Calc.hs" "$HERE/../solution/HW1.hs" "$HERE/../autograder/ExprLexer.x" "$HERE/../autograder/ExprParser.y" "$W/"
cd "$W"
alex ExprLexer.x -o ExprLexer.hs
happy ExprParser.y -o ExprParser.hs
ghc -O0 -v0 -package array -o calc Calc.hs
./calc
