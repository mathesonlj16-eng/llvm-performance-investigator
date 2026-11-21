# LLVM Performance Investigator

A compiler-engineering portfolio project for x86-64 Linux. It follows a C++ loop from aliasing rules through LLVM legality analysis to Zen 3 machine code, measures the resulting short-call behavior, and implements a small verified LLVM optimization pass.

| Investigation | Result |
|---|---|
| [Loop vectorization and pointer aliasing](docs/vectorization-investigation.md) | Clang 21 vectorized both loops. Ordinary pointers required a 128-byte runtime distance check. Adding only noalias to the minimal IR removed it. |
| [Short-call experiment](docs/short-call-analysis.md) | At 32 elements, ordinary calls took 0.23–0.32 ns longer across four launches. A different scalar cleanup path complicates attribution at 31 elements. Includes raw paired timings and linked disassembly. |
| [LLVM new-pass-manager plugin](docs/llvm-pass-analysis.md) | An out-of-tree function pass rewrites eligible power-of-two integer multiplies. FileCheck, LLVM verification and an execution oracle test legality, SSA replacement and idempotence. |
| [Release comparison](docs/version-analysis.md) | Under fixed flags and inputs, the largest apparent Clang 20→21 slowdown reversed on repetition. All three measured kernels had matching instruction and label text. |

## Reproduce

The recorded environment was Ubuntu under WSL2 on an AMD Ryzen 7 5800HS with packaged LLVM 21.1.8. Use an x86-64 system supporting the Zen 3 instructions for native execution. These commands assume Ubuntu repositories containing the named packages. The plugin build uses the matching LLVM 21 headers, libraries and tools; Clang 20 is for the earlier release comparison.

```sh
sudo apt update
sudo apt install --no-install-recommends clang clang-20 clang-21 llvm-21-dev llvm-21-tools g++ binutils util-linux python3 git
python3 -m unittest discover -s tests -v
bash passes/test.sh
bash investigations/aliasing/check.sh
```

Run from the repository root. The pass test builds the plugin. To see the rewrite directly:

```sh
opt-21 -load-pass-plugin=.build/passes/PowerOfTwo.so -passes=power-of-two -verify-each -S passes/tests/cases.ll -o -
```

To repeat the short-call experiment, choose a permitted guest CPU (the recorded runs used CPU 2) and a new results directory. To inspect the recorded data on another machine, only Python is required.

```sh
taskset -c 2 bash investigations/aliasing/time_calls.sh results/short-calls
python3 investigations/aliasing/summarize_calls.py docs/short-calls
```

## Architecture

- **passes/** contains the LLVM 21 plugin, its build script, IR fixtures and executable boundary-value oracle.
- **investigations/aliasing/** contains the two C++ kernels, single-loop IR reproducer, code-generation checks and short-call driver. Both correctness and timing use the same kernel source.
- **src/** and **tools/** contain the original three workloads and Python standard-library runner. It records compiler metadata, interleaves paired trials, validates outputs and captures assembly, IR and optimization remarks. [Original kernel analysis](docs/compiler-analysis.md)
- **docs/** contains the investigations and selected evidence. **results/** and **.build/** are ignored local output directories. The repository retains compact evidence needed to audit the findings.

For a functional check of the earlier runner:

```sh
python3 tools/run.py --compiler clang++-21 --size 37 --rounds 3 --samples 3 --warmups 1
```

For the earlier release experiment, use the following command on the documented target. The resulting medians are sensitive to host conditions.

```sh
taskset -c 2 python3 tools/run.py --compiler clang++-20 --candidate clang++-21 --march znver3 --level O3 --samples 10 --output results/reproduction
python3 tools/compare_asm.py results/reproduction
```

## License status

Project license selection is pending owner approval. The recommended option is Apache-2.0 WITH LLVM-exception to align with upstream LLVM. [LLVM license text](https://llvm.org/LICENSE.txt)
