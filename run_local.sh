#!/usr/bin/env bash
# Run an autograder locally, exactly the way Gradescope would.
#
#   ./run_local.sh haskell-hw haskell-hw/sample_submissions/buggy
#   ./run_local.sh java-hw    java-hw/sample_submissions/correct
#
# It builds a throwaway /autograder-style folder, runs run_autograder,
# and pretty-prints results.json.

set -euo pipefail
HW="${1:?usage: run_local.sh <hw-folder> <submission-folder>}"
SUBMISSION="${2:?usage: run_local.sh <hw-folder> <submission-folder>}"

ROOT="$(mktemp -d)"
mkdir -p "$ROOT/source" "$ROOT/submission" "$ROOT/results"
cp -r "$HW/autograder/." "$ROOT/source/"
cp -r "$SUBMISSION/." "$ROOT/submission/"

AG_ROOT="$ROOT" bash "$ROOT/source/run_autograder"

echo
echo "===== results.json ====="
python3 -m json.tool "$ROOT/results/results.json"
