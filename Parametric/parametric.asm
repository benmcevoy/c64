BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

#define FASTMATH

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_math.lib"
#import "globals.asm"

#import "sound.asm"


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
    Set $d020:#BLACK
    Set $d021:#BLACK

    jsr ClearScreen
    jsr Sound.Init

    sei
        lda #<Sound.Play
        sta $0314    
        lda #>Sound.Play
        sta $0315
    cli

    loop:
        inc Global.time
        jsr Update
    jmp loop
}

Update: {
    Set i:#0
    inc startAngle
    // xRelative is signed and relative to the origin at (CENTERX, CENTERY)
    lda  Global.time
    sec
    sbc #CENTERX
    sta xRelative+1
    Set xRelative:#0

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

        Rotate startAngle
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

        Modulo Global.time:#PALETTE_LENGTH
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

.pseudocommand Rotate angle {
    ldx angle
    lda cosine,X
    sta cosineAngle
    Sat16 cosineAngle:cosineAngle+1

    ldx angle
    lda sine,X
    sta sineAngle
    Sat16 sineAngle:sineAngle+1

    // var x2 = xRel * Math.Cos(angle)  ///  yRel is always 0 so ignore this - yRel * Math.Sin(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:cosineAngle
    Set __tmp3:cosineAngle+1
    
    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    
    // only care about high byte
    lda __val2
    asl
    sta x1

    // var y2 = x * Math.Sin(angle) /// -- ignore Y term -- + y * Math.Cos(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:sineAngle
    Set __tmp3:sineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    lda __val2
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
x1: .byte 0
y1: .byte 0

// state
palette: .byte 6,11,4,14,5,3,13,7,1,1,7,13,15,5,12,8,2,9,2,9

*=$3700 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))
* = $3900 "trails"
xTrails: .fill (TRAILS*AXIS),0
yTrails: .fill (TRAILS*AXIS),0
