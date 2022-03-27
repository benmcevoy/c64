BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

// so this is more pain than expected
// to start I am going to plot some points
// and implement the one useful thing, rotational transform

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_joystick.lib"
#import "_math.lib"

.label ClearScreen = $E544

.const TWOPI = 256 // 256 is two PI in BRAD's
.const DELAY = 200
.const AXIS = 8
.const TRAILS = 12
.const WIDTH = 40
.const HEIGHT = 25
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

    jsr UpdateState
    rts

    // // start main loop
    // sei
    //     lda #<Update            
    //     sta $0314
    //     lda #>Update
    //     sta $0315
    // cli

    // // infinite loop
    // jmp *
}

Update: {
    inc delayCounter
    lda delayCounter
    cmp #DELAY
    bne !+
        Set delayCounter:#0

        inc time
        
        jsr UpdateState
    !:

    // end irq
    pla;tay;pla;tax;pla
    rti 
}

UpdateState: {

    Set angle:#0
!loop:
    Call Rotate:angle:#4:#4

    Call CharScreen.Plot:__val0:__val1

    inc angle
    bne !loop-

    rts
    angle: .byte 0
}

/*
    private static Tuple<double, double> Rotate(double angle, double x, double y, double centerX, double centerY)
    {
        var x1 = x - centerX;
        var y1 = y - centerY;

        var x2 = x1 * Math.Cos(angle) - y1 * Math.Sin(angle);
        var y2 = x1 * Math.Sin(angle) + y1 * Math.Cos(angle);

        return new Tuple<double, double>(x2 + centerX, y2 + centerY);
    }

    refer:
    https://github.com/mgolombeck/3D-Demo/blob/master/PLOT3D.S#L635
*/

Rotate: {
    .var angle = __arg0
    .var x = __arg1
    .var y = __arg2

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

    rts
    // relative to origin at centerx,y
    xRelative: .word 0
    yRelative: .word 0

    sineAngle: .word 0
    cosineAngle: .word 0

    x2a: .word 0
    y2a: .word 0

    x1: .byte 0
    y1: .byte 0
}

// state
delayCounter: .byte 0

time: .byte 0

*=$2000 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))

