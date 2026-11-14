#!/usr/bin/env bash
# Build and run the calculator using the reference solution's eval.
#   ./ocaml-hw/tools/calc.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
W="$(mktemp -d)"
cp "$HERE/calc.ml" "$HERE/../solution/hw1.ml" "$HERE/../autograder/lexer.mll" "$HERE/../autograder/parser.mly" "$W/"
cd "$W"
ocamllex -q lexer.mll
ocamlyacc parser.mly
ocamlopt hw1.ml parser.mli parser.ml lexer.ml calc.ml -o calc
./calc
