#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"

using namespace llvm;

namespace {
bool isPositivePowerOfTwo(Value *V) {
  auto *C = dyn_cast<ConstantInt>(V);
  return C && !C->getValue().isNegative() && C->getValue().isPowerOf2();
}

class PowerOfTwoPass : public PassInfoMixin<PowerOfTwoPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
    bool Changed = false;
    for (BasicBlock &BB : F) {
      for (Instruction &I : make_early_inc_range(BB)) {
        if (I.getOpcode() != Instruction::Mul ||
            !(I.getType()->isIntegerTy(32) || I.getType()->isIntegerTy(64)) ||
            I.hasNoSignedWrap() || I.hasNoUnsignedWrap())
          continue;

        unsigned Side = isPositivePowerOfTwo(I.getOperand(1)) ? 1 : 0;
        if (!isPositivePowerOfTwo(I.getOperand(Side)))
          continue;

        auto *Factor = cast<ConstantInt>(I.getOperand(Side));
        auto *Count = ConstantInt::get(I.getType(), Factor->getValue().logBase2());
        auto *Shift = BinaryOperator::CreateShl(I.getOperand(1 - Side), Count,
                                                "", I.getIterator());
        Shift->takeName(&I);
        Shift->setDebugLoc(I.getDebugLoc());
        I.replaceAllUsesWith(Shift);
        I.eraseFromParent();
        Changed = true;
      }
    }
    return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
  }
};
} // namespace

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "PowerOfTwo", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &PM,
                   ArrayRef<PassBuilder::PipelineElement> Inner) {
                  if (Name != "power-of-two" || !Inner.empty())
                    return false;
                  PM.addPass(PowerOfTwoPass());
                  return true;
                });
          }};
}

