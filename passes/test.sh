#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
bash passes/build.sh
bin=$(llvm-config-21 --bindir)
plugin=.build/passes/PowerOfTwo.so
cases=passes/tests/cases.ll
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
run_pass() {
  "$bin/opt" -load-pass-plugin="$plugin" -passes="$1" -verify-each -S "$2" -o "$3"
}
run_pass power-of-two "$cases" "$tmp/once.ll"
run_pass 'power-of-two,power-of-two' "$cases" "$tmp/twice.ll"
cmp "$tmp/once.ll" "$tmp/twice.ll"
"$bin/FileCheck" "$cases" < "$tmp/once.ll"
for ir in "$cases" "$tmp/once.ll"; do
  "$bin/clang" -O0 -Wno-override-module "$ir" passes/tests/oracle.c -o "$tmp/check"
  "$tmp/check"
done
# Suppress frontend optimization passes so the source multiply reaches our plugin.
echo 'unsigned times8(unsigned x) { return x * 8u; }' |
  "$bin/clang" -x c - -O1 -Xclang -disable-llvm-passes -emit-llvm -S -o "$tmp/source.ll"
grep -Eq 'mul i32 %[^,]+, 8' "$tmp/source.ll"
run_pass power-of-two "$tmp/source.ll" "$tmp/result.ll"
grep -Eq 'shl i32 %[^,]+, 3' "$tmp/result.ll"
for pipeline in instcombine 'default<O2>'; do
  "$bin/opt" -passes="$pipeline" -verify-each -S "$cases" -o "$tmp/standard.ll"
  sed -n '/^define .*@scale32(/,/^}/p' "$tmp/standard.ll" | grep -F 'shl i32 %x, 3'
done
echo 'Passed IR shape, verification, idempotence, boundary values, Clang input and standard pipeline checks.'
