.section .data
.align 4
.globl FrameBufferInfo 
FrameBufferInfo:
  .int 1024 /* #0 Physical Width */
  .int 768 /* #4 Physical Height */
  .int 1024 /* #8 Virtual Width */
  .int 768 /* #12 Virtual Height */
  .int 0 /* #16 GPU - Pitch */
  .int 16 /* #20 Bit Depth */
  .int 0 /* #24 X */
  .int 0 /* #28 Y */
  .int 0 /* #32 GPU - Pointer */
  .int 0 /* #36 GPU - Size */

.section .text
@ Negotiate communication with the frame buffer
@ r0 - width
@ r1 - height
@ r2 - bit depth
.globl InitialiseFrameBuffer
InitialiseFrameBuffer:
  @ Validate inputs
  width .req r0
  height .req r1
  bitDepth .req r2
  cmp width,#4096
  cmpls height,#4096
  cmpls bitDepth,#32
  result .req r0
  movhi result,#0
  movhi pc,lr

  @ Load frame buffer info into address given in r3
  push {r4, lr}
  fbInfoAddr .req r4
  ldr fbInfoAddr,=FrameBufferInfo
  str width,[fbInfoAddr,#0]
  str height,[fbInfoAddr,#4]
  str width,[fbInfoAddr,#8]
  str height,[fbInfoAddr,#12]
  str bitDepth,[fbInfoAddr,#20]
  .unreq width
  .unreq height
  .unreq bitDepth

  @ Add 0x4000000 to frame buffer address to indicate to send message directly back
  mov r0,fbInfoAddr
  add r0,#0x40000000
  @ Use channel 1
  mov r1,#1
  @ Write the message
  bl MailboxWrite
  @ Read the response
  mov r0,#1
  bl MailboxRead

  @ Check if result is 0 and return 0 if not
  teq result,#0
  movne result,#0
  popne {fbInfoAddr,pc}

  @ Return frame buffer info address
  mov result,fbInfoAddr
  pop {fbInfoAddr,pc}
  .unreq result
  .unreq fbInfoAddr
