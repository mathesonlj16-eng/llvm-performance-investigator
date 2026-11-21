# Measuring short calls across the 32-element vector boundary

On a Ryzen 7 5800HS, Clang 21.1.8's restricted kernel completed the 32-element call 0.23–0.32 ns sooner across four launches. At 31 elements the paired difference grew to 1.99–2.32 ns. This measures the complete generated functions on disjoint, repeatedly reused buffers. The gap depends strongly on which loop and tail the call executes.

## Measured results

Each entry is the session median of 12 paired differences in ns/call (ordinary minus restricted). Positive values favor restricted. Column order is execution order. A and D share one binary; B and C share the other.

| Elements | A, 16-byte alignment | B, 64-byte | C, 64-byte | D, 16-byte |
|---:|---:|---:|---:|---:|
| 0 | +0.042 | +0.007 | −0.013 | +0.170 |
| 1 | +0.515 | +0.442 | +0.692 | +0.753 |
| 4 | +0.057 | +0.243 | +0.204 | +0.055 |
| 16 | +0.720 | +1.009 | +1.011 | +0.738 |
| 31 | +1.988 | +2.317 | +2.231 | +2.044 |
| 32 | +0.231 | +0.250 | +0.318 | +0.286 |
| 33 | +0.672 | +0.756 | +0.540 | +1.019 |
| 64 | +0.275 | +0.513 | +0.507 | +0.229 |

In session A at 32 elements, the ordinary and restricted medians were 2.454 and 2.234 ns/call. The paired difference had a MAD (median absolute deviation) of 0.027 ns/call. At 31 elements the medians were 6.421 and 4.420, with a paired MAD of 0.046. Pairing before taking the median accounts for why the table differs slightly from subtracting the two marginal medians. At four elements both 16-byte-layout differences were smaller than their respective paired MADs. The zero-length control changed sign across launches. Neither result supports a precise fixed entry-cost estimate. [All per-kernel medians, MADs and paired summaries](short-calls/summary.csv) · [Raw A](short-calls/a16.csv) · [Raw B](short-calls/b64.csv) · [Raw C](short-calls/c64.csv) · [Raw D](short-calls/d16.csv)

## From legality to measured machine code

Clang turns the restricted parameters into LLVM noalias arguments. For ordinary pointers, Loop Access Analysis identifies a potentially loop-carried read-after-write dependence. The Loop Vectorizer can still select the same eight-lane, four-way interleaved plan by guarding vector execution. Its difference check uses 8 lanes × 4 groups × 4 bytes/element = 128 bytes. For example, writing one element ahead of the source changes the next scalar iteration's input. Loading a whole group before writing would violate that ordering. [IR, remarks and version-matched LLVM implementation trace](vectorization-investigation.md)

In the linked 16-byte build, ordinary first branches on zero length, then forms dst−src at 0x401913. It compares the unsigned distance to 127, combines the result with the minimum trip count and branches at 0x40191f. Restricted proceeds from the zero-length check to trip-count dispatch. At 32 elements both execute one group of four YMM additions and stores. At 31 both use the four-element XMM loop for 28 elements. Ordinary then enters a scalar remainder path shared with the alias fallback, including remainder-count setup; restricted has a shorter scalar cleanup loop. The observed 31-element gap therefore includes a second concrete code difference. The relative contribution of each instruction remains unresolved. [16-byte linked disassembly](short-calls/layout-16.asm) · [64-byte linked disassembly](short-calls/layout-64.asm)

## Measurement controls

- Ubuntu Clang 21.1.8 (6ubuntu1), x86_64-pc-linux-gnu, C++20, -O3 -march=znver3 -fno-lto -fno-pie, linked with -no-pie. WSL2 Linux 6.18.58.1-microsoft-standard-WSL2. The process inherited affinity to guest logical CPU 2.
- The two unchanged v0.5 kernels live in a separate translation unit from the caller. One noinline timing function calls either kernel indirectly. The linked loop contains a call through r15 and a counter initialized to 500,000. The timer is read twice per batch. Input generation, output resets and checks are outside the timer.
- Every timed call uses the same source and destination addresses, both 64-byte aligned and 512 bytes apart. The longest accessed range is 256 bytes. Both kernels see identical deterministic values, including UINT32_MAX. After every batch the driver checks every destination element and the untouched margin. Separate v0.5 tests cover overlapping layouts for ordinary pointers.
- Two warm-up pairs per length precede 12 measured pairs. Each pair measures both kernels, alternates which goes first, and rotates the starting length across sweeps. Four fresh processes ran in layout order 16, 64, 64, 16. Entry addresses in the first layout were 0x401900 and 0x401a70; in the second they were 0x401940 and 0x401ac0. The non-PIE link kept addresses fixed within each layout. The zero-length call includes loop, call, early return and timing overhead. Its measurements are reported directly without baseline subtraction.

## Limits and reproduction

Confidence is highest in the direction of the whole-call difference at 31 and 32 for these binaries and this layout of hot data. Repeated calls make branch outcomes predictable. Real callers may inline the function, vary lengths and addresses, or miss in cache. Two instruction layouts sample only a small part of alignment sensitivity. WSL guest affinity cannot fix host scheduling, CPU frequency or thermal state. MAD describes observed spread and supplies no confidence interval. There is no isolated cycle count for the check and no measured application speedup.

From the repository root on the documented target, run the following. Choose an available guest CPU and a fresh output directory.

```sh
taskset -c 2 bash investigations/aliasing/time_calls.sh results/short-calls
python3 investigations/aliasing/summarize_calls.py docs/short-calls
```

The first command saves binaries, full disassembly, environment, raw CSVs and summaries locally. The second reconstructs the published summary from the four compact raw files. [Timing driver](../investigations/aliasing/short_calls.cpp) · [Build and run commands](../investigations/aliasing/time_calls.sh)
