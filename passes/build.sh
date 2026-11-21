#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
bin=$(llvm-config-21 --bindir)
mkdir -p .build/passes
# llvm-config emits separate command-line arguments for the packaged installation.
"$bin/clang++" $(llvm-config-21 --cxxflags) -fPIC -shared passes/PowerOfTwo.cpp \
  $(llvm-config-21 --ldflags --link-shared --libs core passes --system-libs) \
  -o .build/passes/PowerOfTwo.so

