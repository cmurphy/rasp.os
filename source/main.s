.section .init
.globl _start
_start:

b main
.section .text
main:
  mov sp,#0x8000

  @ Initialize frame buffer with width 1024, height 768, bit depth 16
  mov r0,#1024
  mov r1,#768
  mov r2,#16
  bl InitialiseFrameBuffer

  @ Check if returned value was 0 - if it was, there was no error
  teq r0,#0
  bne noError$

  @ If there was an error, turn on the OK LED and wait forever
  mov r0,#16
  mov r1,#1
  bl SetGpioFunction
  mov r0,#16
  mov r1,#0
  bl SetGpio

  error$:
    b error$

  @ Move the frame buffer address into r4
  noError$:
    fbInfoAddr .req r4
    mov fbInfoAddr,r0

    bl SetGraphicsAddress

    @ Initialize variables
    lastRand .req r7
    lastX .req r8
    lastY .req r9
    color .req r10
    nextX .req r5
    nextY .req r6
    mov lastRand, #0
    mov color,#0
    mov lastX, #0
    mov lastY, #0

    draw$:
      @ Generate random number, with the last random number as a seed
      mov r0, lastRand
      bl Random
      mov lastRand, r0
      @ Set it as the next X coordinate
      mov nextX, lastRand
      @ Generate another random number
      bl Random
      mov lastRand, r0
      @ Set it as the next Y coordinate
      mov nextY, lastRand
      @ Set the last random number to be the last Y coordinate generated
      mov lastRand, nextY

      @ Set the color
      mov r0, color
      @ Increment the color
      add color, #1
      @ Reset to zero if reached max
      lsl color, #16
      lsr color, #16
      bl SetForeColour

      @ Set x0,y0
      mov r0,lastX
      mov r1,lastY
      @ Set x1,y1 converted to a number between 0 and 1023
      lsr r2,nextX, #22
      lsr r3,nextY, #22
      @ If Y is too high, restart
      cmp r3, #768
      bhs draw$

      @ Set last x/y coordinates for next time
      mov lastX, r2
      mov lastY, r3

      @ Draw the line
      bl DrawLine

      b draw$

      .unreq lastX
      .unreq lastY
      .unreq nextX
      .unreq nextY
      .unreq color
      .unreq lastRand
