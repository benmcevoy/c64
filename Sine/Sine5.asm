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



.const TRAILS = 128

xf: .byte 1
yf: .byte 3

xFreq: .byte $00
yFreq: .byte $0

xPhase: .byte 0
yPhase: .byte 128

xtime: .byte 0
ytime: .byte 0



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


    // TODO: set IRQ to use a raster and see 
    // if we can get rid of the flicker
    // start main loop
    sei
        lda #<Draw            
        sta $0314
        lda #>Draw
        sta $0315
    cli

    // infinite loop
    jmp *
}


Draw:{
    loop:
    inc xtime
    inc ytime

    // both are at a frequency of whatever irq clock is
    // lda xFreq
    // clc
    // adc #xf
    // sta xFreq

    // lda yFreq
    // clc
    // adc #yf
    // sta yFreq
    

    // now run slower than the clock
    lda xtime
    cmp xf
    bcc !+
        Set xtime:#0
        inc xFreq
    !:

    lda ytime
    cmp yf
    bcc !+
        Set ytime:#0
        inc yFreq
    !:

    Call Lissajou:xFreq:yFreq

    // end irq
    pla;tay;pla;tax;pla
    rti 
}

Lissajou: {
    .var xf = __arg0
    .var yf = __arg1
    
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
    Call CharScreen.Plot:x:y
   
    lda xf
    clc
    adc xPhase
    tax
    lda sine,X
    lsr;lsr;lsr;lsr;
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
    lsr;lsr;lsr;lsr;
    clc
    adc yOffset
    sta y
    ldx i
    sta yTrails, X

    Set CharScreen.PenColor:#YELLOW
    Call CharScreen.Plot:x:y

    lda i
    cmp #TRAILS
    bcc !+
        Set i:#0
    !:

    rts

    xOffset: .byte 6
    yOffset: .byte 4
    x: .byte 0
    y: .byte 0
    i: .byte 0
    j: .byte 1
}


* = $0d00 "unsigned trig tables"
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))
* = $0f00 "trails"
xTrails: .fill TRAILS,0
yTrails: .fill TRAILS,0


