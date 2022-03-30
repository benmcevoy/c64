BasicUpstart2(Start)

// let's try
// - lissajou, but as trails
// ANIMATE PHASE

#import "_charscreen.lib"


xSpeed: .byte $00
ySpeed: .byte $2
xPhase: .byte 128
yPhase: .byte 128

Start:{
    // let's try
    // - draw a circle
    // unit circle
    // x = cos(t)
    // y = sin(t)
    Set CharScreen.Character:#204
    Set $d020:#0
    Set $d021:#0
    jsr $E544
    Set time:#0

loop:
    lda time
    adc #1
    sta time

    lda yPhase
    adc ySpeed
    sta yPhase

    lda xPhase
    adc xSpeed
    sta xPhase
    
    // lissajou curve
    Call Lissajou:time:x:y
    jmp loop

    // screen coords
    x: .byte 0
    y: .byte 0
    time: .byte 0
}

Lissajou: {
    .var t = __arg0
    .var x0 =__arg1
    .var y0 = __arg2

    
    lda t
    
    adc xPhase
    tax
    lda sine,X
    lsr;lsr;
    clc
    adc xOffset
    sta x

    lda t
    
    adc yPhase
    tax
    lda sine,X
    lsr;lsr;
    clc
    adc yOffset
    sta y

    Set CharScreen.PenColor:yPhase
    Call CharScreen.PlotH:x:y
        
    rts

    xOffset: .byte 6
    yOffset: .byte 4
    x: .byte 0
    y: .byte 0
    i: .byte 0
}
/* =========================================================================================================*/


.label PORT2 = $dc00
.const JOYSTICK_UP      = %00000001
.const JOYSTICK_DOWN    = %00000010
.const JOYSTICK_LEFT    = %00000100
.const JOYSTICK_RIGHT   = %00001000
.const JOYSTICK_FIRE    = %00010000
// similar to joystick flags
.const ACTION_COLLIDED_UP       = %00000001
.const ACTION_COLLIDED_DOWN     = %00000010
.const ACTION_COLLIDED_LEFT     = %00000100
.const ACTION_COLLIDED_RIGHT    = %00001000
.const ACTION_IS_FIRING         = %00010000
.const ACTION_IS_JUMPING        = %00100000


// default state for the above flags
playerAction: .byte %00100000

ReadJoystick: {


    // let dx tend back to zero
    // if jumping then no friction
    lda #ACTION_IS_JUMPING
    bit playerAction
    bne !skip+
        // lda dx
        // cmp #0
        // beq read_joystick
        // bmi !+
        //     dec dx
        //     jmp read_joystick
        // !:
        // inc dx
    !skip:

    read_joystick:
        // left
        lda #JOYSTICK_LEFT
        bit PORT2
        bne !skip+
            // lda #ACTION_IS_JUMPING
            // bit playerAction
            // beq !+
            //     Set dx:#-SPEED/2
            //     jmp !skip+
            // !:
            //     Set dx:#-SPEED
        !skip:

        // right
        lda #JOYSTICK_RIGHT
        bit PORT2
        bne !skip+
            // lda #ACTION_IS_JUMPING
            // bit playerAction
            // beq !+
            //     Set dx:#SPEED/2
            //     jmp !skip+
            // !:
            //     Set dx:#SPEED
        !skip:

        // up
        // down

        // fire
        lda #ACTION_IS_JUMPING
        bit playerAction
        // no double jumping
        bne !skip+
            lda #JOYSTICK_FIRE
            bit PORT2
            bne !skip+
                // Set dy:#IMPULSE
                SetBit playerAction:#ACTION_IS_JUMPING
        !skip:
    rts
}

* = $1200
// unsigned trig tables
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))

