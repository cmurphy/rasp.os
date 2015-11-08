.section .init
.globl _start
_start:

b main
.section .text
main:
mov sp,#0x8000

pinNum .req r0
pinFunc .req r1
mov pinNum,#16
mov pinFunc,#1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

@ Load the pattern sequence
@ Initialize sequence index to 0
ptrn .req r4
ldr ptrn,=pattern
ldr ptrn,[ptrn]
seq .req r5
mov seq,#0

loop$:
pinNum .req r0
pinVal .req r1
mov pinNum,#16
mov pinVal,#0
bl SetGpio
.unreq pinNum
.unreq pinVal

mov r0,#0x40000
bl Wait

pinNum .req r0
pinVal .req r1
mov pinNum,#16
@ Set value to 1 if current is 1
mov pinVal,#1
lsl pinVal,seq
and pinVal,ptrn
bl SetGpio
.unreq pinNum
.unreq pinVal

mov r0,#0x40000
bl Wait

add seq,#1
cmp seq,#32
moveq seq,#0

b loop$

.section .data
.align 2
pattern:
.int 0b11111111101010100010001000101010
