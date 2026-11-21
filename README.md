# LLVM Performance Regression Investigator - v0.4

Build the LLVM 21 new-pass-manager plugin with `bash passes/build.sh` and validate it with `bash passes/test.sh`. The [pass investigation](docs/llvm-pass-analysis.md) covers setup, actual IR, the semantic argument and the stock LLVM comparison.

## Earlier release investigation

Compare two packaged Clang releases at one optimization level on three validated C++20 kernels. Start with the [Clang 20 versus 21 investigation](docs/version-analysis.md).

## Reproduce the release comparison

On x86-64 Ubuntu with the versioned packages available, install the two drivers alongside one another. The recorded experiment ran on a Ryzen 7 5800HS with WSL2 logical CPU 2 available.

```sh
sudo apt install --no-install-recommends clang-20 clang-21 g++ python3
taskset -c 2 python3 tools/run.py --compiler clang++-20 --candidate clang++-21 --march znver3 --level O3 --samples 10 --output results/reproduction
python3 tools/compare_asm.py results/reproduction
```

Choose a supported explicit CPU target and an available logical CPU on other hardware. Repeat with a fresh output directory. Ten alternating pairs balance which compiler starts first. The report identifies both compiler versions, target triples, C++ runtime link paths, CPU affinity and flags. The assembly comparison extracts the measured function and compares instructions and labels. It discards comments and assembler directives, including alignment.

## Optimization-level experiments

A local C++20 experiment comparing Clang optimization levels on three kernels. Start with [the measured findings](docs/compiler-analysis.md). The two captured sessions include raw trial times, correctness results and machine metadata in [session A](docs/session-a.json) and [session B](docs/session-b.json).

## Reproduce on x86-64 Ubuntu or WSL2

Install the distribution packages if needed. Run from the project root.

```sh
sudo apt update
sudo apt install --no-install-recommends clang g++ python3 git
python3 -m unittest discover -s tests -v
python3 tools/run.py
python3 tools/run.py --workload dot_product --size 1000000 --rounds 100 --samples 7 --warmups 2
```

Each invocation writes a new directory under `results/`. Use `--output PATH` to choose an unused directory and `--compiler clang++-21` to select a driver. Each workload gets Intel-syntax assembly, optimized LLVM IR and loop-vectorizer remarks at both levels. For a quick functional check use `--size 37 --rounds 3 --samples 3 --warmups 1`. Temporary binaries and generated evidence trees are excluded from Git. The compact reports under `docs/` are tracked.

## What runs inside the timer

| Workload | Timed work | Correctness check outside timer |
|---|---|---|
| Array transform | Mutate one input, then compute a scaled sum for every float | Compare every final element against double-precision arithmetic with a relative-plus-absolute tolerance |
| Dot product | Multiply bounded unsigned inputs, accumulate in 64 bits | Reverse traversal with widened operands |
| Branch hash | For input values above the cutoff, update an order-sensitive rolling hash | Reconstruct the polynomial in reverse with successive powers of 33 |

The two integer workloads share a driver. It alternates between two overlapping input slices and checks the aggregate across all rounds using defined unsigned modular arithmetic. A separate translation unit and compilation without LTO keep repeated kernel calls visible to the timer. Deterministic inputs give each executable the same decisions and operands. The branch benchmark tests one roughly balanced input distribution. Other distributions can produce different code performance.

## Reading the report

Each trial launches a fresh process, prepares data and exercises the kernel before timing repeated calls with a monotonic clock. Warm-up trial pairs are discarded. Measured pairs alternate which executable runs first. Seven samples leave one extra first position for O2. The JSON retains order, timings, checksum and maximum errors. Equal checksums across levels supplement the per-executable reference checks.

The reported change is 100 Ã— (O3 median / O2 median âˆ’ 1). MAD measures within-session spread. It is the median distance from the sample median, in milliseconds. It provides no confidence interval. Compare independently repeated sessions before interpreting a difference. The default repeats the same arrays, so cache reuse matters. Input generation, allocation, reference computation and process startup are outside the timer.

Native targeting specializes code for the CPU features exposed by the guest. WSL2 scheduling, migration, host activity, frequency changes and thermal conditions remain uncontrolled. These experiments collect elapsed time only. Branch misses, bandwidth and execution-port bottlenecks would require additional evidence. Keep the host and workload fixed for comparisons.

## Learning path

Follow one dot-product call from the driver to the C++ loop, then locate the source line in the vectorization remarks. Match vector width and interleave count to LLVM vector types, widening operations and the independent accumulators in assembly. Compare the scalar tail with the vector loop. Finally, use the raw trials to recalculate each median and MAD. For a version investigation, hold optimization level, target, input and harness constant and vary only the Clang release.

