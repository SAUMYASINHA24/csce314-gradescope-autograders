#!/usr/bin/env bash
# Runs once when Gradescope builds the autograder Docker image (Ubuntu base).
set -e
apt-get update
apt-get install -y ghc libghc-quickcheck2-dev alex happy python3
