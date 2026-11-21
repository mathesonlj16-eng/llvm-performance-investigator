# From integer multiplication to a left shift

The v0.4 plugin registers the function pipeline name `power-of-two` with LLVM 21.1.8. It performs one local rewrite. The examples below come from `passes/tests/cases.ll` and the verified output of `opt-21`.

## Reproduce on WSL2 Ubuntu

Run from the repository root in Bash. The distribution's Clang 21 driver was already installed. The matching development and tooling packages supplied the headers, shared LLVM library, llvm-config, opt and FileCheck.

```sh
sudo apt install --no-install-recommends clang-21 llvm-21-dev llvm-21-tools
llvm-config-21 --version --includedir --libdir
bash passes/build.sh
opt-21 -load-pass-plugin=.build/passes/PowerOfTwo.so \
  -passes=power-of-two -verify-each -S passes/tests/cases.ll -o -
bash passes/test.sh
python3 -m unittest discover -s tests -v
```

The build uses the compiler in the binary directory reported by llvm-config-21, the release's C++ flags, and shared-library link flags. On this machine the plugin resolved libLLVM.so.21.1. Using matching headers and runtime matters because the plugin passes C++ objects across that boundary.

## Read the IR

Before, with the constant on the left:

```llvm
define i64 @scale64(i64 %x) {
  %r = mul i64 4611686018427387904, %x
  ret i64 %r
}
```

After one plugin invocation:

```llvm
define i64 @scale64(i64 %x) {
  %r = shl i64 %x, 62
  ret i64 %r
}
```

LLVM represents the multiplication as a binary instruction with two same-width operands. The constant is a ConstantInt backed by a fixed-width APInt. The result is an SSA value used by the return. In the 32-bit fixture the constant is on the right. The input `%r = mul i32 %x, 8` became `%r = shl i32 %x, 3`.

## Decide whether the rewrite is legal

For width w, an unflagged multiply by 2^k computes the low w bits of x × 2^k. A left shift by k computes those same low bits. Bits discarded at the top are discarded by both operations. This holds for every input bit pattern, including values interpreted as negative. A poison input propagates through both instructions. Both use the variable operand once.

LLVM integer types are signless. For the requested *positive constant* restriction, the pass interprets the constant's bit pattern as signed, requires its sign bit to be clear, and checks for exactly one set bit. Its binary logarithm gives k. Consequently k is at most w−2, safely below the width at which a shift would produce poison. One qualifies and becomes a shift by zero. Zero has no set bit. A sign-bit-only constant is deliberately excluded even though modular arithmetic would permit a separate rule for it.

The matcher accepts scalar i32 and i64 only. It skips every multiplication with nsw or nuw. Those flags turn certain overflows into poison and require a separate argument about preserving that contract. Vectors would require reasoning about lanes and constant forms. Floating-point multiplication has different rounding and exceptional-value semantics. Variable factors and other constant factors fall outside the one-shift rule.

## Change the instruction safely

The pass inserts a same-typed shift at the multiplication's position, transfers its SSA name and debug location, redirects every use, and erases the old instruction. Insertion at that position preserves dominance for its users. Early-increment traversal keeps the iterator valid after erasure. A changed function conservatively invalidates cached analyses. An untouched function preserves them all. A second invocation finds only shifts at the rewritten sites. The plugin registers an explicitly selectable pipeline element. [LLVM new-pass-manager guide](https://llvm.org/docs/WritingAnLLVMNewPMPass.html)

## What the tests establish

FileCheck checks both operand orders, both widths, multiplication by one, and exact retained operations for excluded types, factors and flags. The test runner uses the LLVM verifier after each pass and compares one invocation with two on the same input. A C oracle executes the original and rewritten IR separately for eleven input patterns, including signed limits, the sign-bit boundary, all ones and a mixed-bit value. Unsigned C arithmetic supplies the expected modular result. A separate smoke test compiles an unsigned C function with Clang frontend optimization passes disabled, confirms that a multiply reached the plugin, and checks the resulting shift. Boundary tests exercise examples; the modular argument covers the full supported input domain.

## Compare LLVM's own pipeline

```sh
opt-21 -passes=instcombine -verify-each -S passes/tests/cases.ll -o -
opt-21 -passes='default<O2>' -verify-each -S passes/tests/cases.ll -o -
```

On LLVM 21.1.8, both commands emitted `%r = shl i32 %x, 3` in scale32 with the plugin absent. InstCombine alone therefore suffices for this example. This exercise demonstrates matching, legality, SSA replacement, analysis invalidation and verification. The experiment measures IR behavior. It supplies no execution-time comparison or claim about machine instruction cost.
