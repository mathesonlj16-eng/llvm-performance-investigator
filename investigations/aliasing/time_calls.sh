#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
out=${1:?supply a new output directory relative to the project root or an absolute path}
mkdir -p "$(dirname "$out")"
mkdir "$out"
src=investigations/aliasing
flags=(-std=c++20 -O3 -march=znver3 -fno-lto)
{
  clang++-21 --version
  uname -srmo
  grep -m1 'model name' /proc/cpuinfo
  taskset -pc $$
  printf 'flags: %s\n' "${flags[*]} -falign-functions={16,64}; non-PIE link"
} > "$out/environment.txt"
clang++-21 "${flags[@]}" -fno-pie -c "$src/short_calls.cpp" -o "$out/driver.o"
for align in 16 64; do
  clang++-21 "${flags[@]}" -fno-pie -falign-functions="$align" -c "$src/copy_add.cpp" -o "$out/kernels.o"
  clang++-21 -no-pie "$out/driver.o" "$out/kernels.o" -o "$out/calls-$align"
  objdump -d -M intel -C "$out/calls-$align" > "$out/layout-$align.asm"
done
for run in a16 b64 c64 d16; do
  "$out/calls-${run:1}" > "$out/$run.csv"
done
python3 "$src/summarize_calls.py" "$out" > "$out/summary.csv"
