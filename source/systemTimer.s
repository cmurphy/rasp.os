@ Load the Counter address in r0
.globl GetCounterAddress
GetCounterAddress:
  ldr r0,=0x20003000
  mov pc,lr

@ Wait for # microseconds
@ r0 - number of microseconds to wait
.globl Wait
Wait:
  @ Get counter address
  push {lr}
  targetTime .req r3
  mov targetTime,r0
  bl GetCounterAddress
  ctrAddr .req r2
  mov ctrAddr,r0


  @ Get starting counter value
  @ Ignore r1 (high bytes)
  ldrd r0,r1,[r2,#4]

  @ Add desired wait time to current time
  @ to get target time
  add targetTime,r0

  @ Loop until current time >= target time
  waitLoop$:
  ldrd r0,r1,[ctrAddr,#4]
  cmp targetTime,r0
  bge waitLoop$

  @ Exit when loop ends
  .unreq targetTime
  .unreq ctrAddr
  pop {pc}

