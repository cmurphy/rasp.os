@ Get the address of the mailbox region
@ returns address in r0
.globl GetMailboxBase
GetMailboxBase:
  ldr r0,=0x2000B880
  mov pc,lr

@ Send a message to a particular mailbox
@ r0 - message body
@ r1 - mailbox index
.globl MailboxWrite
MailboxWrite:
  @ Validate that the low 4 bits of message body are 0
  @ so that the message body and mailbox index can be combined later
  tst r0,#0b1111
  movne pc,lr

  @ Validate that the mailbox index is less than 15
  cmp r1,#15
  movhi pc,lr

  @ Get mailbox base address
  channel .req r1
  value .req r2
  mov value,r0
  push {lr}
  bl GetMailboxBase
  mailbox .req r0

  @ Load current status and wait until it is 0
  @ (mailbox + 0x18 is the status address)
  wait1$:
    status .req r3
    ldr status,[mailbox,#0x18]
    tst status,#0x80000000
    .unreq status
    bne wait1$

  @ Combine message body and mailbox index
  add value,channel
  .unreq channel

  @ Write the value to the mailbox
  @ (mailbox + 0x20 is the write address)
  str value,[mailbox,#0x20]
  .unreq value
  .unreq mailbox
  pop {pc}

@ Read a message from a particular mailbox
@ r0 - mailbox to read from
.globl MailboxRead
MailboxRead:
  @ Validate that channel is less than 15
  cmp r0,#15
  movhi pc,lr

  @ Get mailbox base address
  channel .req r1
  mov channel,r0
  push {lr}
  bl GetMailboxBase
  mailbox .req r0

  rightmail$:
    @ Load current status and wait until it is 0
    wait2$:
      status .req r2
      ldr status,[mailbox,#0x18]
      tst status,#0x40000000
      .unreq status
      bne wait2$

    @ Read next item from the mailbox
    mail .req r2
    ldr mail,[mailbox,#0]

    @ Check if the channel is right, otherwise try again
    inchan .req r3
    and inchan,mail,#0b1111
    teq inchan,channel
    .unreq inchan
    bne rightmail$
    .unreq mailbox
    .unreq channel

    @ Return the message
    and r0,mail,#0xfffffff0
    .unreq mail
    pop {pc}


