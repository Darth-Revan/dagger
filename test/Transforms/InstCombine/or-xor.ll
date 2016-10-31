; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s

define i32 @test1(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[Y_NOT:%.*]] = xor i32 %y, -1
; CHECK-NEXT:    [[Z:%.*]] = or i32 [[Y_NOT]], %x
; CHECK-NEXT:    ret i32 [[Z]]
;
  %or = or i32 %x, %y
  %not = xor i32 %or, -1
  %z = or i32 %x, %not
  ret i32 %z
}

define i32 @test2(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[X_NOT:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[Z:%.*]] = or i32 [[X_NOT]], %y
; CHECK-NEXT:    ret i32 [[Z]]
;
  %or = or i32 %x, %y
  %not = xor i32 %or, -1
  %z = or i32 %y, %not
  ret i32 %z
}

define i32 @test3(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[Y_NOT:%.*]] = xor i32 %y, -1
; CHECK-NEXT:    [[Z:%.*]] = or i32 [[Y_NOT]], %x
; CHECK-NEXT:    ret i32 [[Z]]
;
  %xor = xor i32 %x, %y
  %not = xor i32 %xor, -1
  %z = or i32 %x, %not
  ret i32 %z
}

define i32 @test4(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[X_NOT:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[Z:%.*]] = or i32 [[X_NOT]], %y
; CHECK-NEXT:    ret i32 [[Z]]
;
  %xor = xor i32 %x, %y
  %not = xor i32 %xor, -1
  %z = or i32 %y, %not
  ret i32 %z
}

define i32 @test5(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    ret i32 -1
;
  %and = and i32 %x, %y
  %not = xor i32 %and, -1
  %z = or i32 %x, %not
  ret i32 %z
}

define i32 @test6(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    ret i32 -1
;
  %and = and i32 %x, %y
  %not = xor i32 %and, -1
  %z = or i32 %y, %not
  ret i32 %z
}

define i32 @test7(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[Z:%.*]] = or i32 %x, %y
; CHECK-NEXT:    ret i32 [[Z]]
;
  %xor = xor i32 %x, %y
  %z = or i32 %y, %xor
  ret i32 %z
}

define i32 @test8(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[X_NOT:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[Z:%.*]] = or i32 [[X_NOT]], %y
; CHECK-NEXT:    ret i32 [[Z]]
;
  %not = xor i32 %y, -1
  %xor = xor i32 %x, %not
  %z = or i32 %y, %xor
  ret i32 %z
}

define i32 @test9(i32 %x, i32 %y) nounwind {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[Y_NOT:%.*]] = xor i32 %y, -1
; CHECK-NEXT:    [[Z:%.*]] = or i32 [[Y_NOT]], %x
; CHECK-NEXT:    ret i32 [[Z]]
;
  %not = xor i32 %x, -1
  %xor = xor i32 %not, %y
  %z = or i32 %x, %xor
  ret i32 %z
}

define i32 @test10(i32 %A, i32 %B) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    ret i32 -1
;
  %xor1 = xor i32 %B, %A
  %not = xor i32 %A, -1
  %xor2 = xor i32 %not, %B
  %or = or i32 %xor1, %xor2
  ret i32 %or
}

; (x | y) & ((~x) ^ y) -> (x & y)
define i32 @test11(i32 %x, i32 %y) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[AND:%.*]] = and i32 %x, %y
; CHECK-NEXT:    ret i32 [[AND]]
;
  %or = or i32 %x, %y
  %neg = xor i32 %x, -1
  %xor = xor i32 %neg, %y
  %and = and i32 %or, %xor
  ret i32 %and
}

; ((~x) ^ y) & (x | y) -> (x & y)
define i32 @test12(i32 %x, i32 %y) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    [[AND:%.*]] = and i32 %x, %y
; CHECK-NEXT:    ret i32 [[AND]]
;
  %neg = xor i32 %x, -1
  %xor = xor i32 %neg, %y
  %or = or i32 %x, %y
  %and = and i32 %xor, %or
  ret i32 %and
}

; FIXME: We miss the fold because the pattern matching is inadequate.

define i32 @test12_commuted(i32 %x, i32 %y) {
; CHECK-LABEL: @test12_commuted(
; CHECK-NEXT:    [[NEG:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[NEG]], %y
; CHECK-NEXT:    [[OR:%.*]] = or i32 %y, %x
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[XOR]], [[OR]]
; CHECK-NEXT:    ret i32 [[AND]]
;
  %neg = xor i32 %x, -1
  %xor = xor i32 %neg, %y
  %or = or i32 %y, %x
  %and = and i32 %xor, %or
  ret i32 %and
}

; ((x | y) ^ (x ^ y)) -> (x & y)
define i32 @test13(i32 %x, i32 %y) {
; CHECK-LABEL: @test13(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %y, %x
; CHECK-NEXT:    ret i32 [[TMP1]]
;
  %1 = xor i32 %y, %x
  %2 = or i32 %y, %x
  %3 = xor i32 %2, %1
  ret i32 %3
}

; ((x | ~y) ^ (~x | y)) -> x ^ y
define i32 @test14(i32 %x, i32 %y) {
; CHECK-LABEL: @test14(
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 %x, %y
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %noty = xor i32 %y, -1
  %notx = xor i32 %x, -1
  %or1 = or i32 %x, %noty
  %or2 = or i32 %notx, %y
  %xor = xor i32 %or1, %or2
  ret i32 %xor
}

; FIXME: We miss the fold because the pattern matching is inadequate.

define i32 @test14_commuted(i32 %x, i32 %y) {
; CHECK-LABEL: @test14_commuted(
; CHECK-NEXT:    [[NOTY:%.*]] = xor i32 %y, -1
; CHECK-NEXT:    [[NOTX:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[OR1:%.*]] = or i32 [[NOTY]], %x
; CHECK-NEXT:    [[OR2:%.*]] = or i32 [[NOTX]], %y
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[OR1]], [[OR2]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %noty = xor i32 %y, -1
  %notx = xor i32 %x, -1
  %or1 = or i32 %noty, %x
  %or2 = or i32 %notx, %y
  %xor = xor i32 %or1, %or2
  ret i32 %xor
}

; ((x & ~y) ^ (~x & y)) -> x ^ y
define i32 @test15(i32 %x, i32 %y) {
; CHECK-LABEL: @test15(
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 %x, %y
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %noty = xor i32 %y, -1
  %notx = xor i32 %x, -1
  %and1 = and i32 %x, %noty
  %and2 = and i32 %notx, %y
  %xor = xor i32 %and1, %and2
  ret i32 %xor
}

; FIXME: We miss the fold because the pattern matching is inadequate.

define i32 @test15_commuted(i32 %x, i32 %y) {
; CHECK-LABEL: @test15_commuted(
; CHECK-NEXT:    [[NOTY:%.*]] = xor i32 %y, -1
; CHECK-NEXT:    [[NOTX:%.*]] = xor i32 %x, -1
; CHECK-NEXT:    [[AND1:%.*]] = and i32 [[NOTY]], %x
; CHECK-NEXT:    [[AND2:%.*]] = and i32 [[NOTX]], %y
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[AND1]], [[AND2]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %noty = xor i32 %y, -1
  %notx = xor i32 %x, -1
  %and1 = and i32 %noty, %x
  %and2 = and i32 %notx, %y
  %xor = xor i32 %and1, %and2
  ret i32 %xor
}

define i32 @test16(i32 %a, i32 %b) {
; CHECK-LABEL: @test16(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %a, 1
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[TMP1]], %b
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %or = xor i32 %a, %b
  %and1 = and i32 %or, 1
  %and2 = and i32 %b, -2
  %xor = or i32 %and1, %and2
  ret i32 %xor
}
