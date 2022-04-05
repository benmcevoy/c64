BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

// allow joystick control to control a couple of parameters
// tune up the parameters so we can get nice variety when we twiddle the knobs
// move away from Call and _prelude.lib
// consider
// - more than one label can be applied to a zero page address, as long as the labels are orthognal or not used at the same time then you should be ok (non simulataneous? )
// - the carry flag can be used as a status flag by your own code, e.g.
// - start and end labels can be applied to a struct (or table) so you can have dynamically sized "objects", i think

// MyFunction: {
//     ... do stuff ...
//
//     exit_false:
//         clc
//         rts
//     exit_true:
//         sec
//         rts
// }

// beginning to learn the "idioms" of this language
// and how to better use it

// the .A should mostly contain the result of a macro/jsr
// the three registers should be used AS MUCH AS POSSIBLE, remember tay/tax and txa etc for holding a state temporarily
// there is a design:

// .macro expose the public API, it handles setting up any registers, state etc, calls a JSR, handles the results if required
// jsr is a routine in a MODULE or FEATURE. I have heard it called a SYSTEM, which I kinda like better than feature, as one system may have several features
// sub routines should expect to be passed things in the registers
// and should return things in the registers
// avoid temporary state where possible

// i need to review this pattern and try and document it somewhere. in code. Spike!


#define FASTMATH

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_joystick.lib"
#import "_math.lib"

.label ClearScreen = $E544

.const AXIS = 8
.const TRAILS = 6
.const PALETTE_LENGTH = 16
.const WIDTH = 51
.const HEIGHT = 51
.const OFFSET = 16
.const CENTERX = (WIDTH/2)
.const CENTERY = (HEIGHT/2)
.const ROTATION_ANGLE_INCREMENT = (256/AXIS)  

Start: {
    // initialise
    jsr ClearScreen
    Set $d020:#BLACK
    Set $d021:#BLACK

    loop:
        inc time
        jsr Update
    jmp loop
}

Update: {
    // set point, just moving along a line
    .var y = CENTERY
    .var x = time

    Set i:#0
    inc startAngle

    axis:
        inc writePointer
        inc erasePointer

        ldx erasePointer
        cpx #(TRAILS*AXIS)
        bcc !+
            Set erasePointer:#0
        !:

        lda xTrails,X
        sta x1    
        lda yTrails,X
        sta y1
        // clear previous
        Set CharScreen.PenColor:#BLACK
        Call CharScreen.PlotH:x1:y1

        Rotate startAngle:x:#y
        Modulo __val0:#WIDTH
        Set x1:__val0
        Modulo __val1:#HEIGHT
        Set y1:__val0

        lda x1
        clc 
        adc #OFFSET
        sta x1

        // make even
        lda #%00000001
        bit x1
        bne !+
            dec x1
        !:

        lda #%00000001
        bit y1
        bne !+
            dec y1
        !:

        ldx writePointer
        lda x1
        sta xTrails, X
        lda y1
        sta yTrails, X

        Modulo time:#PALETTE_LENGTH
        ldx __val0
        lda palette,X
        sta CharScreen.PenColor
        Call CharScreen.PlotH:x1:y1

        lda startAngle
        clc
        adc #ROTATION_ANGLE_INCREMENT 
        sta startAngle

        lda writePointer
        cmp #(TRAILS*AXIS)
        bcc !+
            Set writePointer:#0
        !:

        inc i
        lda i
        cmp #AXIS
        beq !+
            jmp axis
        !:
    exit:
    rts
    
    i: .byte 0
    x1: .byte 0
    y1: .byte 0
    startAngle: .word 0
    writePointer: .byte 0
    erasePointer: .byte 0
}

.pseudocommand Rotate angle:x:y{
    // xRelative is signed and relative to the origin at (CENTERX, CENTERY)
    lda x
    sec
    sbc #CENTERX
    sta xRelative+1
    Set xRelative:#0

    lda y
    sec
    sbc #CENTERY
    sta yRelative+1
    Set yRelative:#0

    ldx angle
    lda cosine,X
    sta cosineAngle
    Sat16 cosineAngle:cosineAngle+1

    ldx angle
    lda sine,X
    sta sineAngle
    Sat16 sineAngle:sineAngle+1

    // var x2 = xRel * Math.Cos(angle) - yRel * Math.Sin(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:cosineAngle
    Set __tmp3:cosineAngle+1
    
    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    Set x2:__val1
    Set x2+1:__val2

    Set __tmp0:yRelative
    Set __tmp1:yRelative+1
    Set __tmp2:sineAngle
    Set __tmp3:sineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3

    Set y2:__val1
    Set y2+1:__val2

    Set __tmp0:x2
    Set __tmp1:x2+1
    Set __tmp2:y2
    Set __tmp3:y2+1
    
    Sub16 __tmp0:__tmp1:__tmp2:__tmp3
    // only care about high byte
    lda __val1
    asl
    sta x1

    // var y2 = x * Math.Sin(angle) + y * Math.Cos(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:sineAngle
    Set __tmp3:sineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    Set x2:__val1
    Set x2+1:__val2

    Set __tmp0:yRelative
    Set __tmp1:yRelative+1
    Set __tmp2:cosineAngle
    Set __tmp3:cosineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    Set y2:__val1
    Set y2+1:__val2

    Set __tmp0:x2
    Set __tmp1:x2+1
    Set __tmp2:y2
    Set __tmp3:y2+1

    Add16 __tmp0:__tmp1:__tmp2:__tmp3
    lda __val1
    asl
    sta y1

    // convert back to "screen space"
    lda x1
    clc
    adc #CENTERX
    sta __val0

    lda y1
    clc
    adc #CENTERY
    sta __val1
}

// relative to origin at centerx,y
xRelative: .word 0
yRelative: .word 0

sineAngle: .word 0
cosineAngle: .word 0

x2: .word 0
y2: .word 0

x1: .byte 0
y1: .byte 0

// state
time: .byte 0
palette: .byte 6,11,4,14,5,3,13,7,1,1,7,13,15,5,12,8,2,9,2,9

*=$4000 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))
* = $4200 "trails"
xTrails: .fill (TRAILS*AXIS),0
yTrails: .fill (TRAILS*AXIS),0

