BasicUpstart2(Start)

// let's try
// - lissajou,
// i had some issues, i should MODEL it
// 
// x = sin(fx+phasex)
// y = sin(fy+phasey)

// TODO:
// - irq on raster to get rid of flicker
// - joystick to twiddle the phase and xf


#import "_charscreen.lib"
#import "_joystick.lib"


.const TRAILS = 25

t: .byte 0

xf: .byte 1
yf: .byte 2

xFreq: .byte $00
yFreq: .byte $0

xPhase: .byte 0
yPhase: .byte 128

xtime: .byte 0
ytime: .byte 0

playerAction: .byte 0
latchedUp: .byte 0
latchedDown: .byte 0
latchedLeft: .byte 0
latchedRight: .byte 0

Start:{
    // let's try1
    Set $d020:#0
    Set $d021:#0
    jsr $E544


    // TODO: set IRQ to use a raster and see 
    // if we can get rid of the flicker
    // start main loop
    // sei
    //     lda #<Draw            
    //     sta $0314
    //     lda #>Draw
    //     sta $0315
    // cli
loop:
    jsr Draw
    // infinite loop
    jmp loop
}


Draw:{
    loop:
    inc t
    inc xFreq
    inc yFreq;inc yFreq
    // inc xtime
    // inc ytime

    // jsr ReadInput

    // // now run slower than the clock
    // lda xtime
    // cmp xf
    // bcc !+
    //     Set xtime:#0
    //     inc xFreq
    // !:

    // lda ytime
    // cmp yf
    // bcc !+
    //     Set ytime:#0
    //     inc yFreq
    // !:

     Lissajou xFreq:yFreq

    // // end irq
    // pla;tay;pla;tax;pla
    rts 
}

ReadInput: {

    Call Joystick.Read:playerAction
    Set playerAction:__val0

    .const V = 200
    .const H = 50

    // Call Joystick.IsAction:playerAction:#Joystick.DOWN

    // lda __val0
    // cmp #0
    // beq !+
    //     inc yf
    // !:

    lda #Joystick.UP
    and playerAction
    cmp #Joystick.UP
    bne !skip+
        // true
        inc latchedUp
        Set latchedDown:#0
    !skip:

    lda #Joystick.DOWN
    and playerAction
    cmp #Joystick.DOWN
    bne !skip+
        // true
        inc latchedDown
        Set latchedUp:#0
    !skip:

    lda #Joystick.LEFT
    and playerAction
    cmp #Joystick.LEFT
    bne !skip+
        // true
        inc latchedLeft
        Set latchedRight:#0
    !skip:

    lda #Joystick.RIGHT
    and playerAction
    cmp #Joystick.RIGHT
    bne !skip+
        // true
        inc latchedRight
        Set latchedLeft:#0
    !skip:

    lda latchedUp
    cmp #V
    bne !+
        inc yf
        Set latchedUp:#0
    !:

    lda latchedDown
    cmp #V
    bne !+
        dec yf
        Set latchedDown:#0
    !:

    lda latchedLeft
    cmp #H
    bne !+
        inc yPhase
        Set latchedLeft:#0
    !:

    lda latchedRight
    cmp #H
    bne !+
        dec yPhase
        Set latchedRight:#0
    !:

    rts
}

.pseudocommand Lissajou xf:yf {
    // .var xf = __arg0
    // .var yf = __arg1
    
    inc i
    inc j

    ldx j
    cpx #TRAILS
    bcc !+
        Set j:#0
    !:

    lda xTrails,X
    sta x    
    lda yTrails,X
    sta y
    // clear previous
    Set CharScreen.PenColor:#BLACK
    Call CharScreen.PlotH:x:y
   
    lda xf
    clc
    adc xPhase
    tax
    lda sine,X
    lsr;lsr;
    clc
    adc xOffset
    sta x
    ldx i
    sta xTrails, X

    lda yf
    clc
    adc yPhase
    tax
    lda sine,X
    lsr;lsr;lsr;
    clc
    adc yOffset
    sta y
    ldx i
    sta yTrails, X

    Set CharScreen.PenColor:t
    Call CharScreen.PlotH:x:y

    lda i
    cmp #TRAILS
    bcc !+
        Set i:#0
    !:

    rts

    xOffset: .byte 8
    yOffset: .byte 8
    x: .byte 0
    y: .byte 0
    i: .byte 0
    j: .byte 1
}


* = $1300 "unsigned trig tables"
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))
* = $1500 "trails"
xTrails: .fill TRAILS,0
yTrails: .fill TRAILS,0



