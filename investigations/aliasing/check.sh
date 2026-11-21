#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
out=$(mktemp -d)
trap 'rm -rf -- "$out"' EXIT
bin=$(llvm-config-21 --bindir)
flags=(-std=c++20 -O3 -march=znver3)
"$bin/clang++" "${flags[@]}" -S -emit-llvm copy_add.cpp -o "$out/optimized.ll"
"$bin/clang++" "${flags[@]}" -Rpass=loop-vectorize -Rpass-missed=loop-vectorize \
  -Rpass-analysis=loop-vectorize -fsave-optimization-record \
  -foptimization-record-passes=loop-vectorize -foptimization-record-file="$out/remarks.yaml" \
  -fdebug-compilation-dir=. -S -masm=intel copy_add.cpp -o "$out/kernels.s" 2>"$out/remarks.txt"
"$bin/opt" -passes=verify -disable-output "$out/optimized.ll"
"$bin/FileCheck" checks.txt --check-prefix=IR < "$out/optimized.ll"
"$bin/FileCheck" checks.txt --check-prefix=RECORD < "$out/remarks.yaml"
"$bin/FileCheck" checks.txt --check-prefix=ASM < "$out/kernels.s"

# Isolate the parameter attribute in otherwise identical, already canonical IR.
sed 's/define void @ordinary(ptr %dst, ptr %src/define void @ordinary(ptr noalias %dst, ptr noalias %src/' \
  minimal.ll > "$out/noalias.ll"
for variant in minimal noalias; do
  input=minimal.ll
  if [[ $variant == noalias ]]; then input="$out/noalias.ll"; fi
  "$bin/opt" '-passes=print<access-info>' -disable-output "$input" >"$out/$variant.access" 2>&1
  "$bin/opt" -mcpu=znver3 '-passes=default<O3>' -verify-each -S "$input" -o "$out/$variant.opt.ll"
  grep -Fq 'load <8 x i32>' "$out/$variant.opt.ll"
done
grep -Fq 'Check 0:' "$out/minimal.access"
grep -Fq 'icmp ult i64 %0, 128' "$out/minimal.opt.ll"
if grep -Fq 'Check 0:' "$out/noalias.access" || grep -Fq 'ptrtoint' "$out/noalias.opt.ll"; then
  echo "Unexpected noalias memory guard" >&2; exit 1
fi

# Build the sequential oracle independently so its loop stays scalar.
"$bin/clang++" -std=c++20 -O0 -c check.cpp -o "$out/check.o"
"$bin/clang++" "${flags[@]}" copy_add.cpp "$out/check.o" -o "$out/check"
"$out/check"
if [[ $# == 1 ]]; then
  mkdir -p "$1"
  cp "$out"/{optimized.ll,kernels.s,remarks.yaml,remarks.txt,minimal.access,noalias.access} "$1/"
fi
echo 'Passed code-generation, loop-access analysis and legal-input correctness checks.'
