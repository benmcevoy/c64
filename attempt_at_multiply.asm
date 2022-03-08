BasicUpstart2(Init)

// i want to fill the screen with that  chr$(205.5 +rnd(1))
// rnd could be from the timer, or sid
// on the irq, loop 1000 times (40*25)
// poke the value into screen memory  1024 + y*40 + x

Init:

// use two registers as op1 and op2

.var op1 = $02
.var op2 = $03
.var result = $04
.var shift = $05
.var places = $06

lda #13
sta op1

lda #4
sta op2

// okay, so 13x4, which is 52
jsr Multiply
rts


Multiply:

  // result result and temp variables
  lda #0
  sta result
  sta shift
  lda #1
  sta places

_loop:
  // if place is high in op1
  lda op1
  and places
  cmp places
  bne _next // no it wasn't
  // yes it was, add shift and add  result
  lda op2 
  ldx shift
  cpx #0
  beq _add
_loop1:
  asl
  dex
  cpx #0
  bne _loop1
_add:
  clc
  adc result
  sta result

_next:
  inc shift
  lda places; asl; sta places

  cmp #0
  bne _loop
  rts
