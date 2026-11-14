#!/usr/bin/env bash
# Runs once when Gradescope builds the autograder Docker image (Ubuntu base).
set -e
apt-get update
apt-get install -y openjdk-21-jdk-headless antlr4 python3
