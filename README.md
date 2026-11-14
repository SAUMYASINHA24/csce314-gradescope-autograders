# CSCE 314 Gradescope Autograders

I built these to learn how Gradescope autograders work for a programming
languages course. There are two sample homeworks, one in OCaml and one in
Java, each with a starter file, a solution, a few sample submissions and an
autograder.

- `ocaml-hw`: lists, tail recursion, options, a small expression evaluator
- `java-hw`: generics, reflection, threads, dynamic dispatch

There's also a Haskell version in `extras/` that I wrote first.

## Running it

```bash
./run_local.sh ocaml-hw ocaml-hw/sample_submissions/correct   # 28.5/28.5
./run_local.sh ocaml-hw ocaml-hw/sample_submissions/buggy     # 13/28.5
./run_local.sh java-hw  java-hw/sample_submissions/correct    # 27/27
./run_local.sh java-hw  java-hw/sample_submissions/buggy      # 12/27
./make_zips.sh                                                # zips for Gradescope
```

`run_local.sh` sets up the same folders Gradescope uses (`source`,
`submission`, `results`) and prints the scores from `results.json`.

You need OCaml, a JDK (17+), ANTLR 4, python3 and GNU `timeout`. On a Mac:
`brew install ocaml antlr openjdk coreutils`, and add coreutils' `gnubin`
folder to your PATH so `timeout` works.

## How the grading works

Every test has its own time limit, so an infinite loop or a crash only
loses the points for that one test instead of the whole submission.

Besides normal unit tests there are:
- random tests that compare the student's answer with the solution (some of
  these stay hidden until grades are published)
- a check that `my_rev` doesn't use `List.rev` and can reverse a list of a
  million elements, so it has to be tail recursive
- a check that `ParallelSum` actually starts threads
- a check that the Java `Exprs.java` doesn't use `instanceof`, `getClass` or
  `switch`, so `eval()` has to work through dynamic dispatch

The student's code is compiled by itself first. If it doesn't compile, or the
function names/types don't match the starter, they get a message saying that
instead of a pile of test errors.

## Lexer and parser

Writing expression tests as nested constructors like
`Add (Num 2, Mul (Num 3, Num 4))` gets hard to read, so the evaluator test
cases are plain text in `eval_cases.txt`:

```
2 + 3 * 4 => 14
1 / (2 - 2) => error
```

For OCaml, `lexer.mll` (ocamllex) and `parser.mly` (ocamlyacc) turn each line
into the student's `expr` type. `%left` sets precedence and associativity and
`%prec UMINUS` handles unary minus. For Java, `Arith.g4` (ANTLR 4) does the
same thing, with a visitor (`ExprBuilder.java`) that builds the student's
`Expr` objects. Each line becomes a separate test. If a line in the file is
malformed, it's reported as a problem with the test file, not the student's
code.

`ocaml-hw/tools/calc.sh` is a small calculator that uses the same parser, if
you want to try it.

## Uploading to Gradescope

Make a Programming Assignment with the Ubuntu image, run `./make_zips.sh`,
and upload the zip from `dist/` under Configure Autograder. Then use Test
Autograder with one of the sample submissions.
