BasicUpstart2(Start)

Start:

//; some equates

.var COLOUR1 = 0
.var COLOUR2 = 1
.var LINE1 = 20
.var LINE2 = 150

//; code starts

setup:

sei                          // ; disable interrupts

lda #$7f                      //; turn off the cia interrupts
sta $dc0d

lda $d01a                     //; enable raster irq
ora #$01
sta $d01a

lda $d011                    // ; clear high bit of raster line
and #$7f
sta $d011

lda #LINE1                   // ; line number to go off at
sta $d012                    // ; low byte of raster line

lda #<intcode                // ; get low byte of target routine
sta 788                      // ; put into interrupt vector
lda #>intcode                // ; do the same with the high byte
sta 789

cli                          // ; re-enable interrupts
rts                          // ; return to caller

intcode:

lda modeflag                 // ; determine whether to do top or
                             // ; bottom of screen
beq mode1
jmp mode2

mode1:

lda #$01                     // ; invert modeflag
sta modeflag

lda #COLOUR1                 // ; set our colour
sta $d021

lda #LINE1                   // ; setup line for NEXT interrupt
sta $d012                    // ; (which will activate MODE2)

lda $d019
sta $d019

jmp $ea31                    // ; MODE1 exits to Rom

mode2:

lda #$00                      //; invert modeflag
sta modeflag

lda #COLOUR2                  // set our colour
sta $d021

lda #LINE2                    //; setup line for NEXT interrupt
sta $d012                     //; (which will activate MODE1)

lda $d019
sta $d019

pla                           //; we exit interrupt entirely.
tay                           //; since happening 120 times per
pla                           //; second, only 60 need to go to
tax                           //; hardware Rom. The other 60 simply
pla                          // ; end
rti

modeflag: .byte 1