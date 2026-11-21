# Why Clang guards one vector loop

Clang 21.1.8 compiled two versions of `dst[i] = src[i] + 1u` for Zen 3. Both main loops process 32 unsigned 32-bit elements per iteration. With ordinary pointers, LLVM emitted a runtime choice between vector and scalar execution. With `__restrict`, the pointer-distance check disappeared. The change concerns which inputs LLVM can prove safe for grouped loads and stores.

## Reproduce on WSL2 Ubuntu

The measured machine configuration for code generation was a Ryzen 7 5800HS, x86-64 Linux under WSL2, Ubuntu Clang 21.1.8 (6ubuntu1). The investigation uses the LLVM 21 tools already installed for v0.4. From the repository root:

```sh
bash investigations/aliasing/check.sh
```

The script compiles with C++20, `-O3 -march=znver3`, all three requested loop-vectorize remark flags and `-fsave-optimization-record`. It filters the saved record to the loop-vectorize pass and independently emits optimized IR. Optional output paths are relative to the investigation directory; pass `.` to regenerate the six checked-in evidence files. The test uses the repository's LLVM 21 and FileCheck workflow. [C++ reproducer](../investigations/aliasing/copy_add.cpp) · [Commands and checks](../investigations/aliasing/check.sh)

## Verified observations

| Evidence | Ordinary pointers | Restricted pointers |
|---|---|---|
| Clang success remark | Width 8, interleave count 4 at line 5 | Same choice at line 11 |
| Optimized IR signature | Source readonly, destination writeonly | Same access attributes plus noalias on each pointer |
| Loop-access analysis on minimal IR | One runtime check comparing the read and write groups | No runtime memory checks |
| Main loop entry | Checks trip count and unsigned destination-minus-source distance | Checks trip count |
| Main vector body | Four YMM packed additions and four unaligned vector stores | Same operation and grouping |

The filtered YAML contains two passed `Vectorized` records. The remarks identify the chosen vector plan. The additional memory condition is visible in the analysis and generated code. A readonly source can still refer to storage modified through an ordinary destination. [Diagnostics](../investigations/aliasing/remarks.txt) · [Optimization record](../investigations/aliasing/remarks.yaml)

### Trace one branch

The ordinary function begins its nonempty path with these instructions in the captured IR. Here %0 is dst, %1 is src and %2 is n.

```llvm
%6 = ptrtoint ptr %0 to i64
%7 = ptrtoint ptr %1 to i64
%8 = icmp ult i64 %2, 4
%9 = sub i64 %6, %7
%10 = icmp ult i64 %9, 128
%11 = or i1 %8, %10
br i1 %11, label %12, label %31
```

Block 12 enters the scalar path. Block 31 decides whether there are at least 32 elements for the main vector body. A smaller vector epilogue can handle groups of four. The restricted function still has trip-count and remainder handling. It does not compute a difference between the addresses. [Optimized IR](../investigations/aliasing/optimized.ll)

In the ordinary x86-64 entry sequence, `sub rcx, rsi` computes dst−src after copying dst from rdi. `cmp rcx, 127` and unsigned `seta cl` test whether the distance is at least 128 bytes. That byte result is combined with the trip-count predicate before branching. In the main body, four `vpaddd` instructions read groups of eight elements before four `vmovdqu` stores. The vector loop advances by 32 elements. **8 lanes × 4 groups × 4 bytes = 128 bytes.** [Side-by-side kernels in generated assembly](../investigations/aliasing/kernels.s)

Consider ordinary pointers with dst = src + 1 element. Scalar iteration zero writes the value that iteration one must read. Loading 32 old values before writing would break that recurrence. The four-byte distance selects the scalar path. At dst = src + 32 elements, the first batch's stores can feed the *next* batch's loads, and the guard permits vectorization. For dst below src, unsigned subtraction can give a large distance even when ranges overlap; those forward stores do not clobber future input. The guard tests dependence distance and direction. It can accept overlap and conservatively routes identical addresses to scalar execution.

### Isolate the legality decision

The standalone IR reproducer has a single canonical loop and no C++ headers. The test derives a second input by adding only `noalias` to its two parameters. For each input it runs `opt-21 -passes='print<access-info>'` and then the verified `default<O3>` pipeline with `-mcpu=znver3`. The first analysis prints a comparison between destination and source access groups. Its optimized IR contains the unsigned distance check. The second analysis leaves the check list empty and its optimized loop still has eight-lane loads. [IR reproducer](../investigations/aliasing/minimal.ll) · [Ordinary analysis](../investigations/aliasing/minimal.access) · [Noalias analysis](../investigations/aliasing/noalias.access)

## LLVM implementation

1. The Loop Vectorizer's legality stage asks Loop Access Analysis whether the loop's memory accesses can be vectorized. Runtime-checkable dependences allow the vectorizer to proceed conditionally. [LoopVectorizationLegality::canVectorizeMemory, LLVM 21.1.8](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Transforms/Vectorize/LoopVectorizationLegality.cpp#L1200)
2. Loop Access Analysis groups memory accesses and can describe suitable pairs using a pointer-difference check. The scalar-evolution expressions in this case show two forward streams advancing four bytes per iteration. [RuntimePointerChecking::tryToCreateDiffCheck](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Analysis/LoopAccessAnalysis.cpp#L369)
3. When runtime pointer checking is needed and difference checks are available, the vectorizer passes the selected vector width and interleave count to the check builder. The helper emits an unsigned comparison against the product of vector width, interleave count and element size. Later simplification and x86 lowering account for the form visible above. [LoopVectorize.cpp](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Transforms/Vectorize/LoopVectorize.cpp#L1835) · [addDiffRuntimeChecks](https://github.com/llvm/llvm-project/blob/llvmorg-21.1.8/llvm/lib/Transforms/Utils/LoopUtils.cpp#L2019)

## Correctness and interpretation

The test compares the entire backing array against a separately compiled, unoptimized forward scalar oracle. It runs 99 ordinary cases spanning zero length, vector and tail boundaries, exact aliasing, and overlap in both directions. It runs 59 restricted cases with disjoint accessed ranges or zero iterations. Inputs include UINT32_MAX to exercise defined unsigned wraparound. These checks cover the chosen examples and the 31/32/33-element distance boundary. [Correctness driver](../investigations/aliasing/check.cpp)

**Assessment.** This is expected runtime loop versioning under incomplete alias information. The target-specific width and interleave choice set the numerical threshold. The underlying need to preserve a possible forward recurrence follows from the ordinary function's contract. These results warrant no upstream report or patch.

**Hypothesis.** Removing entry work could matter for a caller issuing many short, disjoint calls. Establishing that would require a representative call-size and address distribution and measurements that resolve the entry cost.

**Unresolved.** We did not measure runtime or establish whether an extra equality fast path would pay for itself in a real caller. The experiment establishes a legality and code-generation difference on this compiler and target.
