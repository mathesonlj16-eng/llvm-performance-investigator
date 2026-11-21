# The same dot-product loop at two optimization levels

On the Ryzen 7 5800HS, Ubuntu Clang 21.1.8 emitted byte-identical dot-product assembly at O2 and O3. The small elapsed-time differences have no observed kernel instruction change to explain them.

## Foundation check

Before editing the starter, its default run completed two warm-up pairs and seven measured pairs. The transform medians were 20.562 ms and 18.376 ms. Both builds produced IR, Intel-syntax assembly and a source-line vectorization remark reporting width eight and interleave count four. The starter recorded only the architecture as its CPU identifier and gave no numeric variability summary. Its element tolerance could accept a NaN because the ordered comparison with a NaN is false. v0.2 checks finite errors and parsed values, records the CPU model, and reports median absolute deviation. The [baseline JSON](starter-baseline.json) preserves the first run.

## Follow the reduction

In `src/dot_product.cpp`, each product fits in 32 bits because the inputs are bounded by 65,535 and 250. Accumulation uses unsigned 64-bit arithmetic. LLVM can regroup unsigned additions while preserving the result, including modular wraparound. This choice avoids changing floating-point semantics to enable vectorization.

At both levels the diagnostic at line 5 reads `vectorized loop (vectorization width: 4, interleaved count: 4)`. In the optimized kernel IR, four `mul <4 x i32>` operations produce groups of products. Each group is zero-extended to `<4 x i64>`. Independent vector accumulators carry partial sums. The IR combines them and uses `llvm.vector.reduce.add.v4i64` to collapse lanes to a scalar.

The x86 loop uses four XMM `vpmulld` instructions, widens their results with `vpmovzxdq`, and adds them into four YMM accumulators with `vpaddq`. Together they process 16 elements per main-loop iteration. Independent accumulators allow additions from different groups to overlap. This describes the available instruction-level parallelism. We did not measure execution-port utilization.

To inspect the same evidence after running the experiment, set `run` to its output directory.

```sh
sha256sum "$run"/dot_product/{O2,O3}.s
diff -u "$run"/dot_product/{O2,O3}.remarks.txt
less "$run/dot_product/O2.ll"
less "$run/dot_product/O2.s"
```

Session A produced SHA-256 `462fa6b0b934029b4da341e95aeb6becf549982032acbb5c27871d40a2653fdc` for both complete assembly files. Inspect the first function, `_Z6kernelPKjS0_m`. The second function implements the reference calculation.

## Two independent launches

Each entry gives O2 → O3 median kernel-region time in milliseconds and the change relative to O2. Each process ran 100 rounds over one million elements. The runner used two warm-up pairs and seven measured pairs per workload in each session.

| Kernel | Session A | Session B |
|---|---:|---:|
| Array transform | 17.103 → 17.052 (−0.30%) | 17.351 → 17.585 (+1.35%) |
| Dot product | 11.096 → 10.888 (−1.88%) | 9.587 → 9.482 (−1.10%) |
| Branch hash | 320.316 → 319.608 (−0.22%) | 328.740 → 335.921 (+2.18%) |

The direction of the dot-product difference repeated. In session A the gap was 0.208 ms, against MADs of 0.956 and 0.470 ms. In session B the gap was 0.105 ms, against MADs of 0.153 and 0.344 ms. Movement between sessions exceeded either within-session gap. Driver code, process placement, CPU frequency and host scheduling are possible contributors. These runs do not isolate their effects. [Session A](session-a.json) · [Session B](session-b.json)

For the branch hash, the O3 diagnostic at line 6 says LLVM could not identify the carried value as a reduction. The assembly retains conditional jumps after comparisons with 32768 and unrolls the main loop by eight. The hash depends on the preceding accepted value. A count of branch misses would be needed to quantify the prediction cost. The elapsed-time difference changed sign across sessions.

## Next investigation

Install two packaged Clang releases side by side. Keep the optimization level, explicit CPU target, C++ runtime and inputs fixed. Alternate the versions across paired trials. If a slowdown repeats, isolate the affected function, compare its remarks, IR and machine code, and minimize the input while retaining correctness and the timing effect.

