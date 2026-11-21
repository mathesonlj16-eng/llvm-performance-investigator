# LLVM Performance Regression Investigator — starter v0.1

A small, testable starting point for a compiler-engineering portfolio project.
The **first milestone** compares two Clang optimization configurations. It does
**not** claim to detect actual LLVM regressions yet.

## Prerequisites

On Ubuntu / WSL2:

```bash
sudo apt update
sudo apt install -y build-essential clang llvm python3 git
```

## Run the first experiment

From the root directory:

```bash
python3 tools/run.py
```

It compiles `src/array_transform.cpp` with `-O2` and `-O3`, performs 2 warm-up
and 7 measured trials of each configuration, checks outputs, and creates:

- `results/report.md` and `results/report.json` (timings and metadata)
- `results/O2.s` and `results/O3.s` (assembly)
- `results/O2.ll` and `results/O3.ll` (LLVM IR)
- `results/O2_vectorization.txt` and `results/O3_vectorization.txt` (remarks)

The runner requires only Python's standard library and a C++20-capable Clang.
To smoke-test with small inputs:

```bash
python3 tools/run.py --size 10000 --rounds 3 --samples 3 --warmups 1
```

Small-input timings are *not* performance evidence. Use defaults or larger workloads
for useful measurements, and repeat on a quiet laptop plugged into power.

## What to investigate

1. Does Clang emit different instructions at `-O2` and `-O3`?
2. Does either build use packed vector instructions?
3. Did output checksums agree across configurations?
4. Are differences large and repeatable enough to warrant deeper investigation?
5. What does the vectorization report say? See [LLVM vectorizers](https://llvm.org/docs/Vectorizers.html).

## Roadmap (strictly sequential)

- **v0.1:** First reproducible experiment (this repo).
- **v0.2:** Add two different real workloads, CPU metadata, robust timing analysis,
  explicit minimum effect-size thresholds, and automated *correctness* checks.
- **v0.3:** Compare two actual Clang/LLVM versions on identical inputs;
  demonstrate a confirmed regression investigation.
- **v0.4:** Investigate a missed optimization or contribute a minimal fix/upstream test.

Don't expand into a UI, database, AI agent, or dashboard at this stage.

## Methodology limitations

- The runner measures only the kernel region, not input initialization.
- Output values are validated against a separate double-precision calculation.
- Results vary with thermals, laptop power settings, and the WSL2 scheduler.
- There is no formal statistical significance test in this first version.
- Compiler settings are not compiler versions; `-O3` being slower doesn't itself
  mean that LLVM has regressed.

## Git hygiene

Build outputs are ignored. You may intentionally commit a small, representative
report for your portfolio; avoid committing all compiled binaries and large IR dumps.
