BasicUpstart2(Init)

// i want to fill the screen with that  chr$(205.5 +rnd(1))
// rnd could be from the timer, or sid
// on the irq, loop 1000 times (40*25)
// poke the value into screen memory  1024 + y*40 + x
// in fact not using irq at all. all good, just fill the screen.

*=$080d

Init:
// setup the ZP vector at $02 with $0400 (start of screen ram)
lda #00;sta $02
lda #04;sta $03

// init sid noise for random
lda #$FF  // maximum frequency value
sta $D40E // voice 3 frequency low byte
sta $D40F // voice 3 frequency high byte
lda #$80  // noise waveform, gate bit off
sta $D412 // voice 3 control register

// .. loop 4*255 = 1024 times
ldx #4; ldy #0

loop:
// read sid noise
 lda $d41b
 // mask to only look at bit 0
 and #1
 adc #205
 // result is 205 or 206
 sta ($02),y
 iny; bne loop
 // y is now back to zero, which is handy
 // mess with that zp vector for the next 255 characters
 inc $03
 dex; bne loop

done:
 rts
