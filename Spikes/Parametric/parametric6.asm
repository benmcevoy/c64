BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

// after lying on the couch one evening, i realise
// my handling of time is very whack
// phase is really "wobble the starting angle of the rotation"
// and i think this can all be a lot simpler, linear and faster

#define FASTMATH
#define HIRES

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_joystick.lib"
#import "_math.lib"

.label ClearScreen = $E544
.const AXIS = 8
.const TRAILS = $8F
.const PALETTE_LENGTH = 16

_offset: .byte 16

#if HIRES
    .const WIDTH = 51
    .const HEIGHT = 51
    .label OFFSET = _offset
#else
    .const WIDTH = 25
    .const HEIGHT = 25
    .const OFFSET = 8
#endif

.const CENTERX = (WIDTH/2)
.const CENTERY = (HEIGHT/2)
.const ROTATION_ANGLE_INCREMENT = (256/AXIS)  
.const GLYPH = 204 // a little square

Start: {
    // initialise
    Set CharScreen.Character:#GLYPH
    jsr ClearScreen
    Set $d020:#BLACK
    Set $d021:#BLACK

 sei
        lda #<UpdateState
        sta $0314    
        lda #>UpdateState
        sta $0315

        //  // clear high bit of raster flag
        // lda    #$1b
        // sta    $d011
        // // enable raster irq
        // lda    #$01
        // sta    $d01a
        // // disable cia timers
        // lda    #$7f
        // sta    $dc0d
        // sta    $dc0c
        // lda    $dc0d
        // lda    $dc0c
    cli

    loop:
        jsr UpdateState
        jmp loop
}

UpdateState: {
    inc time
    // set point, just moving along a line
    Set x:time
    Set y:#CENTERY
    Set j:#0
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
        Plot x1:y1
        Rotate startAngle:x:y
        Set x1:__val0
        Set y1:__val1

        Modulo x1:#WIDTH
        Set x1:__val0
        Modulo y1:#HEIGHT
        Set y1:__val0

        lda x1
        clc 
        adc OFFSET
        sta x1

        lda #%00000001
        bit x1
        bne !+
            lda x1
            eor #1
            sta x1
        !:

        lda #%00000001
        bit y1
        bne !+
            lda y1
            eor #1
            sta y1
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
        // too slow for this  -
        //sta 53280;sta 53281
        Plot x1:y1

        lda startAngle
        clc
        adc #ROTATION_ANGLE_INCREMENT 
        sta startAngle

        lda writePointer
        cmp #(TRAILS*AXIS)
        bcc !+
            Set writePointer:#0
        !:

       // inc _offset
        // lda _offset
        // clc 
        // adc #1
        // sta _offset
        inc j
        lda j
        cmp #AXIS
        beq !+
            jmp axis
        !:
    exit:
    // end irq
    pla;tay;pla;tax;pla
    rti 

    // indexes
    j: .byte 0
    x: .byte 0
    y: .byte CENTERY
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
    Set x2a:__val1
    Set x2a+1:__val2

    Set __tmp0:yRelative
    Set __tmp1:yRelative+1
    Set __tmp2:sineAngle
    Set __tmp3:sineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3

    Set y2a:__val1
    Set y2a+1:__val2

    Set __tmp0:x2a
    Set __tmp1:x2a+1
    Set __tmp2:y2a
    Set __tmp3:y2a+1
    
    Sub16 __tmp0:__tmp1:__tmp2:__tmp3

    // only care about high byte
    lda __val1
    // i do not know why i have to double it, only that it works :(
    asl
    sta x1

    // var y2 = x * Math.Sin(angle) + y * Math.Cos(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:sineAngle
    Set __tmp3:sineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    Set x2a:__val1
    Set x2a+1:__val2

    Set __tmp0:yRelative
    Set __tmp1:yRelative+1
    Set __tmp2:cosineAngle
    Set __tmp3:cosineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    Set y2a:__val1
    Set y2a+1:__val2

    Set __tmp0:x2a
    Set __tmp1:x2a+1
    Set __tmp2:y2a
    Set __tmp3:y2a+1

    Add16 __tmp0:__tmp1:__tmp2:__tmp3
    // only care about high byte
    lda __val1
    asl
    sta y1

    // convert back to "screen space"
    lda x1
    clc
    adc #CENTERX
    sta __val0

    // CENTERY - y1
    lda y1
    clc
    adc #CENTERY
    sta __val1
}

.pseudocommand Plot x:y {
    #if HIRES
        Call CharScreen.PlotH:x:y
    #else
        Call CharScreen.Plot:x:y
    #endif
}

// relative to origin at centerx,y
xRelative: .word 0
yRelative: .word 0

sineAngle: .word 0
cosineAngle: .word 0

x2a: .word 0
y2a: .word 0

x1: .byte 0
y1: .byte 0

// state
time: .byte 0
palette: 
.byte CYAN,LIGHT_BLUE,PURPLE,LIGHT_RED
.byte ORANGE,YELLOW,LIGHT_GREEN,GREEN
.byte LIGHT_BLUE,BLUE,BLUE,BLUE
.byte RED,WHITE,WHITE,WHITE
.byte ORANGE,YELLOW,LIGHT_GREEN,GREEN

*=$4000 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))
* = $4200 "trails"
xTrails: .fill (TRAILS*AXIS),0
yTrails: .fill (TRAILS*AXIS),0

