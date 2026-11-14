#!/usr/bin/env bash
# Runs once when Gradescope builds the autograder Docker image (Ubuntu base).
# ocamllex and ocamlyacc ship with the OCaml compiler.
set -e
apt-get update
apt-get install -y ocaml-nox python3
