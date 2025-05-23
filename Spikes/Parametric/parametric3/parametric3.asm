BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

// - wrap
// - point
// - "phase"

#define FASTMATH
#define HIRES

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_joystick.lib"
#import "_math.lib"

.label ClearScreen = $E544

.const TWOPI = 256 // 256 is two PI in BRAD's
.const AXIS = 8
.const TRAILS = 24

#if HIRES
    .const WIDTH = 79
    .const HEIGHT = 49
#else
    .const WIDTH = 39
    .const HEIGHT = 24
#endif

.const CENTERX = (WIDTH/2)
.const CENTERY = (HEIGHT/2)
.const ROTATION_ANGLE_INCREMENT = (TWOPI/AXIS)  
.const GLYPH = 204 // a little square

Start: {
    // initialise
    Set CharScreen.Character:#GLYPH
    jsr ClearScreen
    Set $d020:#BLACK
    Set $d021:#BLACK

    Set phase:#0
    Set phase+1:#0

    loop:
        inc time
        inc phase;  
        bcc !+
            inc phase+1
        !:
        jsr UpdateState
    jmp loop
}

UpdateState: {
    // clear the sprite data, can i do this in the loop below?
    jsr ClearScreen

    Set i:#0

    trails:
        jsr Point
        Set x:__val0
        Set y:#CENTERY

        Wrap x0:x:#CENTERX
        Set x:__val0
        Wrap y0:y:#CENTERY
        Set y:__val0

        Set x0:x
        Set y0:y
        
        // var a = Math.Cos(t) * ctx.Phase;
        ldx time
        lda cosine,X
        sta angle

        Sat16 angle:angle+1
        SMulW32 angle:angle+1:phase:phase+1
        Set angle:__val2

        Set j:#0

        axis:
            Rotate angle:x:y
            Set x1:__val0
            Set y1:__val1

            ldx i
            lda palette,x
            sta CharScreen.PenColor
                        
            #if HIRES
                Call CharScreen.PlotH:x1:y1
            #else
                Call CharScreen.Plot:x1:y1
            #endif

            lda angle
            clc
            adc #ROTATION_ANGLE_INCREMENT 
            sta angle
        inc j
        lda j
        cmp #AXIS
        bcs !+
            jmp axis
        !:
        dec time
    inc i
    lda i
    cmp #TRAILS
    bcs exit
    jmp trails

exit:

    rts
    // indexes
    i: .byte 0
    j: .byte 0
    x0: .byte 0
    y0: .byte 0
    x: .byte 0
    y: .byte 0
    x1: .byte 0
    y1: .byte 0
    angle: .word 0
}

Point: {
    lda #CENTERX
    sec
    sbc time
    sta __val0
    
    rts
}

.pseudocommand Rotate angle:x:y{
    // xRelative is signed and relative to the origin at (CENTERX, CENTERY)
    lda x
    sec
    sbc #CENTERX
    sta xRelative+1
    Set xRelative:#0

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
    //asl     
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
    //asl     
    sta y1

    // convert back to "screen space"
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
    // relative to origin at centerx,y
    xRelative: .word 0
    yRelative: .word 0

    sineAngle: .word 0
    cosineAngle: .word 0

    x2a: .word 0
    y2a: .word 0

    x1: .byte 0
    y1: .byte 0

/* @Command */
.pseudocommand Wrap oldValue: newValue :maxValue {

    // if new value >=0 and <=max then return it
    lda newValue
    cmp #0
    bmi !+
        lda newValue
        cmp maxValue
        beq cont
        bcs !+
            cont:
            Set __val0:newValue
            jmp exit
    !:

    // find delta/direction
    lda newValue
    sec
    sbc oldValue
    bmi decreasing
        lda newValue
        sec
        sbc maxValue
        sta __val0
        jmp exit
    !: 
    
    decreasing:
        lda newValue
        clc
        adc maxValue
        sta __val0
        
    exit:
}

// state
time: .byte 0
phase: .word 0

// WIP, ok for the now
palette: .byte 6,11,4,14,5,3,13,7,1,1,7,13,15,5,12,8,2,9,2,9,$06,$06,$06,$0e,$06,$0e,$0e,$06,$0e,$0e,$0e,$03,$0e,$03,$03,$0e,$03,$03,6,11,4,14,5,3,13,7,1,1,7,13,15,5,12,8,2,9,2,9,$06,$06,$06,$0e,$06,$0e,$0e,$06,$0e,$0e,$0e,$03,$0e,$03,$03,$0e,$03,$03
//palette: .byte $06,$06,$06,$0e,$06,$0e,$0e,$06,$0e,$0e,$0e,$03,$0e,$03,$03,$0e,$03,$03
 

*=$0900 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))
* = $0b00 "trails"
xTrails: .fill TRAILS,0
yTrails: .fill TRAILS,0