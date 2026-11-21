; FileCheck pins every instruction in these short functions.

; CHECK-LABEL: define i32 @scale32(
; CHECK-NEXT: %r = shl i32 %x, 3
; CHECK-NEXT: ret i32 %r
define i32 @scale32(i32 %x) {
  %r = mul i32 %x, 8
  ret i32 %r
}

; CHECK-LABEL: define i64 @scale64(
; CHECK-NEXT: %r = shl i64 %x, 62
; CHECK-NEXT: ret i64 %r
define i64 @scale64(i64 %x) {
  %r = mul i64 4611686018427387904, %x
  ret i64 %r
}

; CHECK-LABEL: define i64 @identity(
; CHECK-NEXT: %r = shl i64 %x, 0
; CHECK-NEXT: ret i64 %r
define i64 @identity(i64 %x) {
  %r = mul i64 %x, 1
  ret i64 %r
}

; CHECK-LABEL: define i32 @signed(
; CHECK-NEXT: %r = mul nsw i32 %x, 4
; CHECK-NEXT: ret i32 %r
define i32 @signed(i32 %x) {
  %r = mul nsw i32 %x, 4
  ret i32 %r
}

; CHECK-LABEL: define i64 @unsigned(
; CHECK-NEXT: %r = mul nuw i64 8, %x
; CHECK-NEXT: ret i64 %r
define i64 @unsigned(i64 %x) {
  %r = mul nuw i64 8, %x
  ret i64 %r
}

; CHECK-LABEL: define i32 @zero(
; CHECK-NEXT: %r = mul i32 %x, 0
; CHECK-NEXT: ret i32 %r
define i32 @zero(i32 %x) {
  %r = mul i32 %x, 0
  ret i32 %r
}

; CHECK-LABEL: define i32 @negative(
; CHECK-NEXT: %r = mul i32 %x, -8
; CHECK-NEXT: ret i32 %r
define i32 @negative(i32 %x) {
  %r = mul i32 %x, -8
  ret i32 %r
}

; CHECK-LABEL: define i64 @signbit(
; CHECK-NEXT: %r = mul i64 %x, -9223372036854775808
; CHECK-NEXT: ret i64 %r
define i64 @signbit(i64 %x) {
  %r = mul i64 %x, -9223372036854775808
  ret i64 %r
}

; CHECK-LABEL: define i32 @three(
; CHECK-NEXT: %r = mul i32 3, %x
; CHECK-NEXT: ret i32 %r
define i32 @three(i32 %x) {
  %r = mul i32 3, %x
  ret i32 %r
}

; CHECK-LABEL: define i32 @variable(
; CHECK-NEXT: %r = mul i32 %x, %y
; CHECK-NEXT: ret i32 %r
define i32 @variable(i32 %x, i32 %y) {
  %r = mul i32 %x, %y
  ret i32 %r
}

; CHECK-LABEL: define i16 @narrow(
; CHECK-NEXT: %r = mul i16 %x, 8
; CHECK-NEXT: ret i16 %r
define i16 @narrow(i16 %x) {
  %r = mul i16 %x, 8
  ret i16 %r
}

; CHECK-LABEL: define <2 x i32> @lanes(
; CHECK-NEXT: %r = mul <2 x i32> %x, splat (i32 8)
; CHECK-NEXT: ret <2 x i32> %r
define <2 x i32> @lanes(<2 x i32> %x) {
  %r = mul <2 x i32> %x, splat (i32 8)
  ret <2 x i32> %r
}

; CHECK-LABEL: define float @floating(
; CHECK-NEXT: %r = fmul float %x, 8.000000e+00
; CHECK-NEXT: ret float %r
define float @floating(float %x) {
  %r = fmul float %x, 8.000000e+00
  ret float %r
}

; CHECK-LABEL: define i32 @chain(
; CHECK-NEXT: %a = shl i32 %x, 2
; CHECK-NEXT: %b = shl i32 %a, 1
; CHECK-NEXT: %sum = add i32 %a, %b
; CHECK-NEXT: ret i32 %sum
define i32 @chain(i32 %x) {
  %a = mul i32 %x, 4
  %b = mul i32 2, %a
  %sum = add i32 %a, %b
  ret i32 %sum
}
