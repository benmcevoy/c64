BasicUpstart2(Start)
#define FASTMATH
// refer: https://github.com/benmcevoy/ParametricToy

// so this is more pain than expected
// to start I am going to plot some points
// and implement the one useful thing, rotational transform

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_math.lib"

.label ClearScreen = $E544

.const PALETTE_LENGTH = 8
.const TWOPI = 256 // 256 is two PI in BRAD's
.const AXIS = 8
.const CENTERX = 20
.const CENTERY = 13
.const ROTATION_ANGLE_INCREMENT = (TWOPI/AXIS)  
.const GLYPH = 126 // a little square

Start: {
    // initialise
    Set CharScreen.Character:#GLYPH
    jsr ClearScreen
    Set $d020:#BLACK
    Set $d021:#BLACK

    sei
        // disable cia timers
        lda    #$7f
        sta    $dc0d
        
        // enable raster irq
        lda $d01a                     
        ora #$01
        sta $d01a
        lda $d011                    
        and #$7f
        sta $d011

        // set next irq line number
        lda    #1
        sta    $d012

        lda #<Update            
        sta $0314
        lda #>Update
        sta $0315
    cli

    // infinite loop
    jmp *
}

Update: {
    // ack irq
    lda $d019
    sta $d019
    // set next irq line number
    lda    #1
    sta    $d012

    inc time;inc time;inc time;inc time;inc time

//inc $d020    
    jsr UpdateState
//dec $d020
    // end irq
    pla;tay;pla;tax;pla
    rti 
}

UpdateState: {
        lda #CENTERX
        sec
        sbc time 
        sta x
        sta angle

        Set y:#CENTERY

        Set axisIndex:#0
        
axis:
        Rotate angle:x:y
        Set x1:__val0
        Set y1:__val1

        Modulo time:#PALETTE_LENGTH
        ldx __val0
        lda palette,X
        sta CharScreen.PenColor
        Call CharScreen.Plot:x1:y1
                        
        lda angle
        clc
        adc #ROTATION_ANGLE_INCREMENT 
        sta angle

        inc axisIndex
        lda axisIndex
        cmp #AXIS
        bcs !+
            jmp axis
        !:
exit:
    rts

    // indexes
    axisIndex: .byte 0
    x: .byte 0
    y: .byte 0
    x1: .byte 0
    y1: .byte 0
    angle: .byte 0
}

.pseudocommand Rotate angle:x:y {
    // .var angle = __arg0
    // .var x = __arg1
    // .var y = __arg2

    // xRelative is signed and relative to the origin at (CENTERX, CENTERY)
    // as is yRelative
    // convert to "origin" space
    // var x1 = x - centerX;
    lda x
    sec
    sbc #CENTERX
    sta xRelative+1
    Set xRelative:#0

    // xRelative is now 16 bit fixedpoint hi.lo, e.g. x.00000000
    // var y1 = centerY - y 
    // reverse that due to Y being upside down on a screen
    lda #CENTERY
    sec
    sbc y
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
    sta y1

    // convert back to "screen space"
    // use HI bytes
    // x1 + CENTERX
    lda x1
    clc
    adc #CENTERX
    sta __val0

    // CENTERY - y1
    lda #CENTERY
    sec
    sbc y1
    sta __val1
}

// state
    // relative to origin at centerx,y
    xRelative: .word 0
    yRelative: .word 0

    sineAngle: .word 0
    cosineAngle: .word 0

    x2a: .word 0
    y2a: .word 0

    x1: .byte 0
    y1: .byte 0

time: .byte 0
palette: 
.byte 0,0,15,5,4,2,6,9,11,8,12,3,13,1,7,15

*=$2000 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))

