@ Load the GPIO address in r0
.globl GetGpioAddress
GetGpioAddress:
  ldr r0,=0x20200000
  mov pc,lr

@ Control any GPIO pin
@ r0 - GPIO pin number
@ r1 - GPIO function
.globl SetGpioFunction
SetGpioFunction:

  @ Error checking
  cmp r0,#53
  cmpls r1,#7
  movhi pc,lr

  @ Get GPIO address
  push {lr}
  mov r2,r0
  bl GetGpioAddress

  @ Get block pin number is in
  functionLoop$:
    cmp r2,#9
    subhi r2,#10
    addhi r0,#4
    bhi functionLoop$

  @ Multiply by 3 because there are three bits for each pin
  add r2, r2,lsl #1
  @ Set the bits corresponding to the GPIO pin number (3 bits per pin)
  lsl r1,r2
  @ Store the function value at that pin address
  str r1,[r0]
  pop {pc}

@ Turn on or off
@ r0 - pin number
@ r1 - on or off (0 = off, 1 = on)
.globl SetGpio
SetGpio:
  pinNum .req r0
  pinVal .req r1
  @ Error checking
  cmp pinNum,#53
  movhi pc,lr

  @ Get GPIO address
  push {lr}
  mov r2,pinNum
  .unreq pinNum
  pinNum .req r2
  bl GetGpioAddress
  gpioAddr .req r0

  @ Get address for pin number
  @ 0x20200000 for pin 0-31
  @ 0x20200004 for pin 32-53
  pinBank .req r3
  lsr pinBank,pinNum,#5
  lsl pinBank,#2
  add gpioAddr,pinBank
  .unreq pinBank

  @ Set bit representing pin
  @ e.g. for pin 16 set 16th bit
  @ for pin 45 set 45 % 32 = 13th bit
  and pinNum,#31
  setBit .req r3
  mov setBit,#1
  lsl setBit,pinNum
  .unreq pinNum

  @ If r1 is 0, turn pin off (#40) (turns light on)
  @ If r1 is not 0, turn pin on (#28) (turns light off)
  teq pinVal,#0
  .unreq pinVal
  streq setBit,[gpioAddr,#40]
  strne setBit,[gpioAddr,#28]
  .unreq setBit
  .unreq gpioAddr
  pop {pc}
