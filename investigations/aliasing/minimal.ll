target triple = "x86_64-pc-linux-gnu"

define void @ordinary(ptr %dst, ptr %src, i64 %n) {
entry:
  %empty = icmp eq i64 %n, 0
  br i1 %empty, label %exit, label %loop

loop:
  %i = phi i64 [ 0, %entry ], [ %next, %loop ]
  %s = getelementptr inbounds i32, ptr %src, i64 %i
  %v = load i32, ptr %s, align 4
  %sum = add i32 %v, 1
  %d = getelementptr inbounds i32, ptr %dst, i64 %i
  store i32 %sum, ptr %d, align 4
  %next = add nuw i64 %i, 1
  %done = icmp eq i64 %next, %n
  br i1 %done, label %exit, label %loop

exit:
  ret void
}
