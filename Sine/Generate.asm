BasicUpstart2(Start)

Start:{

    // TODO: draw a Sine wave
    // can mess with frequency
    // and Cosine too
initSineTable:
 
 ldy #$3f
 ldx #$00
 
// Accumulate the delta (normal 16-bit addition)
!: lda value
  clc
  adc delta
  sta value
  lda value+1
  adc delta+1
  sta value+1
 
// Reflect the value around for a sine wave
  sta sine+$c0,x
  sta sine+$80,y
  eor #$ff
  sta sine+$40,x
  sta sine+$00,y
 
// Increase the delta, which creates the "acceleration" for a parabola
  lda delta
  adc #$10   // this value adds up to the proper amplitude
  sta delta
  bcc !+
   inc delta+1
!:
 
// Loop
  inx
  dey
 bpl !--
 
 rts
 
value: .word 0
delta: .word 0
 
sine: .fill 256,0
    
}