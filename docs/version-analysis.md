# Clang 20.1.8 to 21.1.8 on Zen 3

The largest apparent slowdown reversed on repetition. The array transform took 18.35% longer with Clang 21 in the first launch and 14.05% less time in the second. None of the three workloads produced a repeatable slowdown by ratio of medians.

## Experiment

Ubuntu packages supplied baseline Clang 20.1.8 (2ubuntu8) and candidate Clang 21.1.8 (6ubuntu1). Both drivers reported the same x86_64-pc-linux-gnu target and libstdc++ link path. The installed libstdc++6 package was 16-20260322-1ubuntu1. Both compiled the same sources with C++20, -O3, -march=znver3 and -DNDEBUG. Each session rebuilt the executables. All benchmark processes inherited affinity to WSL2 logical CPU 2 on the Ryzen 7 5800HS.

For each workload, two warm-up pairs preceded ten timed pairs. Each process exercised one million elements for 100 timed rounds. Trial order alternated across pairs. All per-executable reference checks and cross-release checksum comparisons passed.

| Kernel | A: 20 → 21 median (ms) | A change | B: 20 → 21 median (ms) | B change |
|---|---:|---:|---:|---:|
| Array transform | 26.778 → 31.692 | +18.35% | 24.658 → 21.195 | −14.05% |
| Dot product | 10.219 → 10.612 | +3.84% | 9.657 → 9.553 | −1.08% |
| Branch hash | 331.229 → 326.648 | −1.38% | 326.031 → 337.350 | +3.47% |

The candidate transform's session A MAD was 9.306 ms around a 31.692 ms median. Examining matched pairs also weakens the slowdown hypothesis. Clang 21 took longer in seven of ten transform pairs in A and five of ten in B. Median within-pair changes were +11.69% and −0.92%, respectively. These summarize individual paired ratios, while the table compares two marginal medians. [Session A raw trials](v03-a.json) · [Session B raw trials](v03-b.json)

## What the compilers emitted

Running `python3 tools/compare_asm.py results/v03-a` and repeating for session B found matching instruction and label text in every measured kernel across the two releases. The comparison included scalar tails and loop-entry checks. It excludes assembler directives, final binary placement and code outside the kernel.

| Kernel | Kernel instructions and labels, each release | Evidence from the loop |
|---|---:|---|
| Array transform | 112 | Both vectorizers report width 8 and interleave count 4 at the transform loop. |
| Dot product | 86 | Both report width 4 and interleave count 4. Both optimized IR files contain the four-lane 64-bit reduction intrinsic. |
| Branch hash | 129 | Both miss vectorization of the conditional hash recurrence. Compare the threshold tests and jumps in the assembly. |

The transform's first-session result alone would have made a misleading regression report. The code comparison rules out a changed instruction sequence in the measured function as the explanation. The timing data cannot distinguish host scheduling, frequency, data placement, alignment or surrounding driver effects. Guest affinity controls the logical CPU visible to the process. Host scheduling and thermal behavior remain uncontrolled.

## Next evidence worth collecting

Use this runner on a minimized workload from an existing LLVM performance report with identified good and bad releases. Preserve its input distribution and correctness oracle, check whether the effect survives repeated paired sessions, and compare the changed loop before attributing a slowdown to a pass. This run supplies a negative control for that investigation.
