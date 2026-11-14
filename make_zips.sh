#!/usr/bin/env bash
# Build the zip files you upload to Gradescope ("Configure Autograder" ->
# "Zip file upload"). Gradescope needs setup.sh and run_autograder at the
# top level of the zip, so we zip the *contents* of each autograder folder.

set -euo pipefail
cd "$(dirname "$0")"
mkdir -p dist
for hw in ocaml-hw java-hw extras/haskell-hw; do
  name="$(basename "$hw")"; rm -f "dist/$name-autograder.zip"
  (cd "$hw/autograder" && zip -q -r "$OLDPWD/dist/$name-autograder.zip" .)
  echo "built dist/$name-autograder.zip"
done
