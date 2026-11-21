; ModuleID = 'copy_add.cpp'
source_filename = "copy_add.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local void @ordinary(ptr noundef writeonly captures(none) %0, ptr noundef readonly captures(none) %1, i64 noundef %2) local_unnamed_addr #0 {
  %4 = icmp eq i64 %2, 0
  br i1 %4, label %73, label %5

5:                                                ; preds = %3
  %6 = ptrtoint ptr %0 to i64
  %7 = ptrtoint ptr %1 to i64
  %8 = icmp ult i64 %2, 4
  %9 = sub i64 %6, %7
  %10 = icmp ult i64 %9, 128
  %11 = or i1 %8, %10
  br i1 %11, label %12, label %31

12:                                               ; preds = %57, %71, %5
  %13 = phi i64 [ 0, %5 ], [ %34, %57 ], [ %62, %71 ]
  %14 = sub i64 %2, %13
  %15 = and i64 %14, 7
  %16 = icmp eq i64 %15, 0
  br i1 %16, label %27, label %17

17:                                               ; preds = %12, %17
  %18 = phi i64 [ %24, %17 ], [ %13, %12 ]
  %19 = phi i64 [ %25, %17 ], [ 0, %12 ]
  %20 = getelementptr inbounds nuw i32, ptr %1, i64 %18
  %21 = load i32, ptr %20, align 4, !tbaa !5
  %22 = add i32 %21, 1
  %23 = getelementptr inbounds nuw i32, ptr %0, i64 %18
  store i32 %22, ptr %23, align 4, !tbaa !5
  %24 = add nuw i64 %18, 1
  %25 = add i64 %19, 1
  %26 = icmp eq i64 %25, %15
  br i1 %26, label %27, label %17, !llvm.loop !9

27:                                               ; preds = %17, %12
  %28 = phi i64 [ %13, %12 ], [ %24, %17 ]
  %29 = sub i64 %13, %2
  %30 = icmp ugt i64 %29, -8
  br i1 %30, label %73, label %74

31:                                               ; preds = %5
  %32 = icmp ult i64 %2, 32
  br i1 %32, label %60, label %33

33:                                               ; preds = %31
  %34 = and i64 %2, -32
  br label %35

35:                                               ; preds = %35, %33
  %36 = phi i64 [ 0, %33 ], [ %53, %35 ]
  %37 = getelementptr inbounds nuw i32, ptr %1, i64 %36
  %38 = getelementptr inbounds nuw i8, ptr %37, i64 32
  %39 = getelementptr inbounds nuw i8, ptr %37, i64 64
  %40 = getelementptr inbounds nuw i8, ptr %37, i64 96
  %41 = load <8 x i32>, ptr %37, align 4, !tbaa !5
  %42 = load <8 x i32>, ptr %38, align 4, !tbaa !5
  %43 = load <8 x i32>, ptr %39, align 4, !tbaa !5
  %44 = load <8 x i32>, ptr %40, align 4, !tbaa !5
  %45 = add <8 x i32> %41, splat (i32 1)
  %46 = add <8 x i32> %42, splat (i32 1)
  %47 = add <8 x i32> %43, splat (i32 1)
  %48 = add <8 x i32> %44, splat (i32 1)
  %49 = getelementptr inbounds nuw i32, ptr %0, i64 %36
  %50 = getelementptr inbounds nuw i8, ptr %49, i64 32
  %51 = getelementptr inbounds nuw i8, ptr %49, i64 64
  %52 = getelementptr inbounds nuw i8, ptr %49, i64 96
  store <8 x i32> %45, ptr %49, align 4, !tbaa !5
  store <8 x i32> %46, ptr %50, align 4, !tbaa !5
  store <8 x i32> %47, ptr %51, align 4, !tbaa !5
  store <8 x i32> %48, ptr %52, align 4, !tbaa !5
  %53 = add nuw i64 %36, 32
  %54 = icmp eq i64 %53, %34
  br i1 %54, label %55, label %35, !llvm.loop !11

55:                                               ; preds = %35
  %56 = icmp eq i64 %2, %34
  br i1 %56, label %73, label %57

57:                                               ; preds = %55
  %58 = and i64 %2, 28
  %59 = icmp eq i64 %58, 0
  br i1 %59, label %12, label %60

60:                                               ; preds = %57, %31
  %61 = phi i64 [ %34, %57 ], [ 0, %31 ]
  %62 = and i64 %2, -4
  br label %63

63:                                               ; preds = %63, %60
  %64 = phi i64 [ %61, %60 ], [ %69, %63 ]
  %65 = getelementptr inbounds nuw i32, ptr %1, i64 %64
  %66 = load <4 x i32>, ptr %65, align 4, !tbaa !5
  %67 = add <4 x i32> %66, splat (i32 1)
  %68 = getelementptr inbounds nuw i32, ptr %0, i64 %64
  store <4 x i32> %67, ptr %68, align 4, !tbaa !5
  %69 = add nuw i64 %64, 4
  %70 = icmp eq i64 %69, %62
  br i1 %70, label %71, label %63, !llvm.loop !15

71:                                               ; preds = %63
  %72 = icmp eq i64 %2, %62
  br i1 %72, label %73, label %12

73:                                               ; preds = %27, %74, %55, %71, %3
  ret void

74:                                               ; preds = %27, %74
  %75 = phi i64 [ %115, %74 ], [ %28, %27 ]
  %76 = getelementptr inbounds nuw i32, ptr %1, i64 %75
  %77 = load i32, ptr %76, align 4, !tbaa !5
  %78 = add i32 %77, 1
  %79 = getelementptr inbounds nuw i32, ptr %0, i64 %75
  store i32 %78, ptr %79, align 4, !tbaa !5
  %80 = add nuw i64 %75, 1
  %81 = getelementptr inbounds nuw i32, ptr %1, i64 %80
  %82 = load i32, ptr %81, align 4, !tbaa !5
  %83 = add i32 %82, 1
  %84 = getelementptr inbounds nuw i32, ptr %0, i64 %80
  store i32 %83, ptr %84, align 4, !tbaa !5
  %85 = add nuw i64 %75, 2
  %86 = getelementptr inbounds nuw i32, ptr %1, i64 %85
  %87 = load i32, ptr %86, align 4, !tbaa !5
  %88 = add i32 %87, 1
  %89 = getelementptr inbounds nuw i32, ptr %0, i64 %85
  store i32 %88, ptr %89, align 4, !tbaa !5
  %90 = add nuw i64 %75, 3
  %91 = getelementptr inbounds nuw i32, ptr %1, i64 %90
  %92 = load i32, ptr %91, align 4, !tbaa !5
  %93 = add i32 %92, 1
  %94 = getelementptr inbounds nuw i32, ptr %0, i64 %90
  store i32 %93, ptr %94, align 4, !tbaa !5
  %95 = add nuw i64 %75, 4
  %96 = getelementptr inbounds nuw i32, ptr %1, i64 %95
  %97 = load i32, ptr %96, align 4, !tbaa !5
  %98 = add i32 %97, 1
  %99 = getelementptr inbounds nuw i32, ptr %0, i64 %95
  store i32 %98, ptr %99, align 4, !tbaa !5
  %100 = add nuw i64 %75, 5
  %101 = getelementptr inbounds nuw i32, ptr %1, i64 %100
  %102 = load i32, ptr %101, align 4, !tbaa !5
  %103 = add i32 %102, 1
  %104 = getelementptr inbounds nuw i32, ptr %0, i64 %100
  store i32 %103, ptr %104, align 4, !tbaa !5
  %105 = add nuw i64 %75, 6
  %106 = getelementptr inbounds nuw i32, ptr %1, i64 %105
  %107 = load i32, ptr %106, align 4, !tbaa !5
  %108 = add i32 %107, 1
  %109 = getelementptr inbounds nuw i32, ptr %0, i64 %105
  store i32 %108, ptr %109, align 4, !tbaa !5
  %110 = add nuw i64 %75, 7
  %111 = getelementptr inbounds nuw i32, ptr %1, i64 %110
  %112 = load i32, ptr %111, align 4, !tbaa !5
  %113 = add i32 %112, 1
  %114 = getelementptr inbounds nuw i32, ptr %0, i64 %110
  store i32 %113, ptr %114, align 4, !tbaa !5
  %115 = add nuw i64 %75, 8
  %116 = icmp eq i64 %115, %2
  br i1 %116, label %73, label %74, !llvm.loop !16
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable
define dso_local void @restricted(ptr noalias noundef writeonly captures(none) %0, ptr noalias noundef readonly captures(none) %1, i64 noundef %2) local_unnamed_addr #0 {
  %4 = icmp eq i64 %2, 0
  br i1 %4, label %51, label %5

5:                                                ; preds = %3
  %6 = icmp ult i64 %2, 4
  br i1 %6, label %7, label %9

7:                                                ; preds = %35, %49, %5
  %8 = phi i64 [ 0, %5 ], [ %12, %35 ], [ %40, %49 ]
  br label %52

9:                                                ; preds = %5
  %10 = icmp ult i64 %2, 32
  br i1 %10, label %38, label %11

11:                                               ; preds = %9
  %12 = and i64 %2, -32
  br label %13

13:                                               ; preds = %13, %11
  %14 = phi i64 [ 0, %11 ], [ %31, %13 ]
  %15 = getelementptr inbounds nuw i32, ptr %1, i64 %14
  %16 = getelementptr inbounds nuw i8, ptr %15, i64 32
  %17 = getelementptr inbounds nuw i8, ptr %15, i64 64
  %18 = getelementptr inbounds nuw i8, ptr %15, i64 96
  %19 = load <8 x i32>, ptr %15, align 4, !tbaa !5
  %20 = load <8 x i32>, ptr %16, align 4, !tbaa !5
  %21 = load <8 x i32>, ptr %17, align 4, !tbaa !5
  %22 = load <8 x i32>, ptr %18, align 4, !tbaa !5
  %23 = add <8 x i32> %19, splat (i32 1)
  %24 = add <8 x i32> %20, splat (i32 1)
  %25 = add <8 x i32> %21, splat (i32 1)
  %26 = add <8 x i32> %22, splat (i32 1)
  %27 = getelementptr inbounds nuw i32, ptr %0, i64 %14
  %28 = getelementptr inbounds nuw i8, ptr %27, i64 32
  %29 = getelementptr inbounds nuw i8, ptr %27, i64 64
  %30 = getelementptr inbounds nuw i8, ptr %27, i64 96
  store <8 x i32> %23, ptr %27, align 4, !tbaa !5
  store <8 x i32> %24, ptr %28, align 4, !tbaa !5
  store <8 x i32> %25, ptr %29, align 4, !tbaa !5
  store <8 x i32> %26, ptr %30, align 4, !tbaa !5
  %31 = add nuw i64 %14, 32
  %32 = icmp eq i64 %31, %12
  br i1 %32, label %33, label %13, !llvm.loop !17

33:                                               ; preds = %13
  %34 = icmp eq i64 %2, %12
  br i1 %34, label %51, label %35

35:                                               ; preds = %33
  %36 = and i64 %2, 28
  %37 = icmp eq i64 %36, 0
  br i1 %37, label %7, label %38

38:                                               ; preds = %35, %9
  %39 = phi i64 [ %12, %35 ], [ 0, %9 ]
  %40 = and i64 %2, -4
  br label %41

41:                                               ; preds = %41, %38
  %42 = phi i64 [ %39, %38 ], [ %47, %41 ]
  %43 = getelementptr inbounds nuw i32, ptr %1, i64 %42
  %44 = load <4 x i32>, ptr %43, align 4, !tbaa !5
  %45 = add <4 x i32> %44, splat (i32 1)
  %46 = getelementptr inbounds nuw i32, ptr %0, i64 %42
  store <4 x i32> %45, ptr %46, align 4, !tbaa !5
  %47 = add nuw i64 %42, 4
  %48 = icmp eq i64 %47, %40
  br i1 %48, label %49, label %41, !llvm.loop !18

49:                                               ; preds = %41
  %50 = icmp eq i64 %2, %40
  br i1 %50, label %51, label %7

51:                                               ; preds = %52, %33, %49, %3
  ret void

52:                                               ; preds = %7, %52
  %53 = phi i64 [ %58, %52 ], [ %8, %7 ]
  %54 = getelementptr inbounds nuw i32, ptr %1, i64 %53
  %55 = load i32, ptr %54, align 4, !tbaa !5
  %56 = add i32 %55, 1
  %57 = getelementptr inbounds nuw i32, ptr %0, i64 %53
  store i32 %56, ptr %57, align 4, !tbaa !5
  %58 = add nuw i64 %53, 1
  %59 = icmp eq i64 %58, %2
  br i1 %59, label %51, label %52, !llvm.loop !19
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind memory(argmem: readwrite) uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="znver3" "target-features"="+adx,+aes,+avx,+avx2,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+invpcid,+lzcnt,+mmx,+movbe,+mwaitx,+pclmul,+pku,+popcnt,+prfchw,+rdpid,+rdpru,+rdrnd,+rdseed,+sahf,+sha,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+wbnoinvd,+x87,+xsave,+xsavec,+xsaveopt,+xsaves" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Ubuntu clang version 21.1.8 (6ubuntu1)"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C++ TBAA"}
!9 = distinct !{!9, !10}
!10 = !{!"llvm.loop.unroll.disable"}
!11 = distinct !{!11, !12, !13, !14}
!12 = !{!"llvm.loop.mustprogress"}
!13 = !{!"llvm.loop.isvectorized", i32 1}
!14 = !{!"llvm.loop.unroll.runtime.disable"}
!15 = distinct !{!15, !12, !13, !14}
!16 = distinct !{!16, !12, !13}
!17 = distinct !{!17, !12, !13, !14}
!18 = distinct !{!18, !12, !13, !14}
!19 = distinct !{!19, !12, !14, !13}
