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
.const WIDTH = 40
.const HEIGHT = 24
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
    Call CharScreen.Plot:#4:#4
    
    // angle 32 BRAD's is pi/4=0.785 in radians or 45 degrees
    .var angle = 32

    Call Rotate:#32:#4:#4
    // Call Rotate:#64:#4:#4
    // Call Rotate:#96:#4:#4
    // Call Rotate:#128:#4:#4

    // expect (3,17 or 18)  ($03,$12)
    DebugPrint __val0
    DebugPrint __val1

    Call CharScreen.Plot:__val0:__val1

    rts
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

    I need to do this on paper first.
    I do not understand what I do with a BRAD (or a BAM).  It's a fraction of a turn. OK
    So what?

    16 bit words

    x.0
    y.0
    0.sin
    0.cos

    ding ding.  sine yields a value between -1 and 1, or -0.9999..0.99999
    convert values to 16 bit fixed point
    need a SWMul16 or something?  or convert to 8 bit fixed point, e.g. 0000.0000
    just lsr;lsr;lsr;lsr ??

    i think this may be working but 8 bit is too small

    i had actually worked this out a while ago and forgot...
    obvious now, assuming it is correct.
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
    
DebugPrint __tmp0

    Call Math.SMul16:xRelative:__tmp0
    Set __tmp0:__val0
    Set __tmp1:__val1

DebugPrint __tmp1
DebugPrint __tmp0


    lda sine,X
    sta __tmp2

DebugPrint __tmp2

    Call Math.SMul16:yRelative:__tmp2
    Set __tmp2:__val0
    Set __tmp3:__val1

    Sub16(__tmp0,__tmp1,__tmp2,__tmp3)
    Set x1:__val0
    Set x1+1:__val1

    DebugPrint x1+1
    DebugPrint x1
    

    // var y2 = x * Math.Sin(angle) + y * Math.Cos(angle);
    lda sine,X
    sta __tmp0
    
    Call Math.SMulW16:xRelative:xRelative+1:#0:__tmp0
    Set __tmp0:__val0
    Set __tmp1:__val1

    lda cosine,X
    sta __tmp1
    Call Math.SMulW16:yRelative:yRelative+1:#0:__tmp1
    Set __tmp2:__val0
    Set __tmp3:__val1

    Call Math.Add16:__tmp0:__tmp1:__tmp2:__tmp3
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
    xRelative: .byte 0
    yRelative: .byte 0
    x1: .word 0
    y1: .word 0
}

// state
delayCounter: .byte 0

time: .byte 0

*=$1600 "Signed trig tables"
// values range -127..127  
sine: .fill 256,round(127*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
