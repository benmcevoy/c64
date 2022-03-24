BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

// so this is more pain than expected
// to start I am going to plot some points
// and implement the one useful thing, rotational transform

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_joystick.lib"
#import "_math.lib"
#import "_debug.lib"

.label ClearScreen = $E544

.const TWOPI = 256 // 256 is two PI in BRAD's
.const DELAY = 200
.const AXIS = 8
.const TRAILS = 12
.const WIDTH = 80
.const HEIGHT = 50
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
    loop:
    
    Call CharScreen.PlotH:#4:#4
    Call Rotate:angle:#4:#4
    Call CharScreen.PlotH:__val0:__val1

    Call CharScreen.PlotH:#4:#5
    Call Rotate:angle:#4:#5
    Call CharScreen.PlotH:__val0:__val1
    
    Call CharScreen.PlotH:#4:#6
    Call Rotate:angle:#4:#6
    Call CharScreen.PlotH:__val0:__val1

    Call CharScreen.PlotH:#4:#7
    Call Rotate:angle:#4:#7
    Call CharScreen.PlotH:__val0:__val1

    Call CharScreen.PlotH:#4:#8
    Call Rotate:angle:#4:#8
    Call CharScreen.PlotH:__val0:__val1
    
    Call CharScreen.PlotH:#4:#9
    Call Rotate:angle:#4:#9
    Call CharScreen.PlotH:__val0:__val1

    Call CharScreen.PlotH:#4:#10
    Call Rotate:angle:#4:#10
    Call CharScreen.PlotH:__val0:__val1

    Call CharScreen.PlotH:#4:#11
    Call Rotate:angle:#4:#11
    Call CharScreen.PlotH:__val0:__val1
    
    Call CharScreen.PlotH:#4:#12
    Call Rotate:angle:#4:#12
    Call CharScreen.PlotH:__val0:__val1

    Call CharScreen.PlotH:#4:#13
    Call Rotate:angle:#4:#13
    Call CharScreen.PlotH:__val0:__val1

    Call CharScreen.PlotH:#4:#14
    Call Rotate:angle:#4:#14
    Call CharScreen.PlotH:__val0:__val1
    
    Call CharScreen.PlotH:#4:#15
    Call Rotate:angle:#4:#15
    Call CharScreen.PlotH:__val0:__val1    

    lda angle
    clc
    adc #30
    sta angle

    cmp #250
    beq !+
        inc CharScreen.PenColor
        jmp loop
    !:

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

    // correct so far
    // var x2 = xRel * Math.Cos(angle) - yRel * Math.Sin(angle);
    ldx angle
    lda cosine,X
    sta __tmp0
    
    // sign extension required on value of cosine
    Sat16 __tmp0:__tmp1
    SMulW32 xRelative:xRelative+1:__tmp0:__tmp1
    Set __tmp0:__val1
    Set __tmp1:__val2

    lda sine,X
    sta __tmp2
    Sat16 __tmp2:__tmp3

    SMulW32 yRelative:yRelative+1:__tmp2:__tmp3
    Set __tmp2:__val1
    Set __tmp3:__val2

    Sub16 __tmp0:__tmp1:__tmp2:__tmp3
    Set x1:__val0
    Set x1+1:__val1

    // var y2 = x * Math.Sin(angle) + y * Math.Cos(angle);
    lda sine,X
    sta __tmp0

    Sat16 __tmp0:__tmp1
    SMulW32 xRelative:xRelative+1:__tmp0:__tmp1
    Set __tmp0:__val1
    Set __tmp1:__val2

    lda cosine,X
    sta __tmp2
    Sat16 __tmp2:__tmp3
    SMulW32 yRelative:yRelative+1:__tmp2:__tmp3
    Set __tmp2:__val1
    Set __tmp3:__val2

    Add16 __tmp0:__tmp1:__tmp2:__tmp3
    Set y1:__val0
    Set y1+1:__val1

    // convert back to "screen space"
    // use HI bytes
    // x1 + CENTERX
    lda x1+1
    clc
    adc #CENTERX
    sta __val0
    // CENTERY - y1
    lda #CENTERY
    sec
    sbc y1+1
    sta __val1

    rts
    // relative to origin at centerx,y
    xRelative: .word 0
    yRelative: .word 0
    x1: .word 0
    y1: .word 0
}

// state
delayCounter: .byte 0

time: .byte 0

*=$2000 "Signed trig tables"
// values range -127..127  
sine: .fill 256,round(127*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
