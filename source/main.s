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

    render$:
      @ Load the frame buffer address
      fbAddr .req r3
      ldr fbAddr,[fbInfoAddr,#32]

      @ while y=768 > 0
      colour .req r0
      y .req r1
      mov y,#768
      drawRow$:
        @ while x=1024 > 0
        x .req r2
        mov x,#1024
        drawPixel$:
          strh colour,[fbAddr] /* Store the low half of fbAddr in colour */
          @ Increment address
          add fbAddr,#2
          @ Decrement counter
          sub x,#1
          @ Exit loop if done
          teq x,#0
          bne drawPixel$

        @ Decrement counter
        sub y,#1
        @ Increment color value
        add colour,#1
        teq y,#0
        bne drawRow$

      b render$

      .unreq fbAddr
      .unreq fbInfoAddr

