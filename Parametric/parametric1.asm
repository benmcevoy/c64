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

    Call Rotate:#angle:#4:#4

    // expect (3,17 or 18)  ($03,$12)
    DebugPrint __val0
    DebugPrint __val1

    Call CharScreen.Plot:__val0:__val1

    rts
}

Rotate: {
    .var angle = __arg0
    .var x = __arg1
    .var y = __arg2

    // convert to "origin" space
    // var x1 = x - centerX;
    lda x
    sec
    sbc #CENTERX
    sta xRelative

    // xRelative is signed and relative to the origin at (CENTERX, CENTERY)
    // as is yRelative

    // var y1 = centerY - y 
    // reverse that due to Y being upside down on a screen
    lda #CENTERY
    sec
    sbc y
    sta yRelative

    // var x2 = x * Math.Cos(angle) - y * Math.Sin(angle);
    ldx angle
    lda cosine,X
    sta __tmp0
    
    Call Math.SMul16:xRelative:__tmp0
    // TODO: need to handle this 16 bit value now.
    Set __tmp0:__val0
    Set __tmp1:__val1

    lda sine,X
    sta __tmp1
    Call Math.SMul16:yRelative:__tmp1
    Set __tmp2:__val0
    Set __tmp3:__val1

    Sub16(__tmp0,__tmp1,__tmp2,__tmp3)
    Set x1:__val0

    // var y2 = x * Math.Sin(angle) + y * Math.Cos(angle);
    lda sine,X
    sta __tmp0
    
    Call Math.SMul16:xRelative:__tmp0
    Set __tmp0:__val0
    Set __tmp1:__val1

    lda cosine,X
    sta __tmp1
    Call Math.SMul16:yRelative:__tmp1
    Set __tmp2:__val0
    Set __tmp3:__val1

    Call Math.Add16(__tmp0,__tmp1,__tmp2,__tmp3)
    Set y1:__val0
    
    DebugPrint x1
    DebugPrint y1

    // convert back to "screen space"
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
    xRelative: .byte 0
    yRelative: .byte 0
    x1: .byte 0
    y1: .byte 0
}

// state
delayCounter: .byte 0

time: .byte 0

// unsigned trig tables
//*=$1300 "Data"
// I had an idea, that instead of two tables, just one extended another 90 degrees.  
// although that crosses a page boundary so maybe not
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))
