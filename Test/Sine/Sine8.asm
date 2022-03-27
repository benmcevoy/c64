BasicUpstart2(Start)


#import "_charscreen.lib"
#import "_joystick.lib"

.label ClearScreen = $E544

.const TRAILS = 256

t: .byte 0

xf: .byte 2
yf: .byte 1

xFreq: .byte $0
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
    Set CharScreen.Character:#204
    Set $d020:#0
    Set $d021:#0
    jsr ClearScreen

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
    inc t
    inc xtime
    inc ytime

    jsr ReadInput

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

ReadInput: {

    Call Joystick.Read:playerAction
    Set playerAction:__val0

    .const V = 200
    .const H = 50

    lda #Joystick.UP
    bit playerAction
    beq !skip+
        // true
        inc latchedUp
        Set latchedDown:#0
    !skip:

    lda #Joystick.DOWN
    bit playerAction
    beq !skip+
        // true
        inc latchedDown
        Set latchedUp:#0
    !skip:

    lda #Joystick.LEFT
    bit playerAction
    beq !skip+
        // true
        inc latchedLeft
        Set latchedRight:#0
    !skip:

    lda #Joystick.RIGHT
    bit playerAction
    beq !skip+
        // true
        inc latchedRight
        Set latchedLeft:#0
    !skip:


    lda latchedUp
    cmp #V
    bne !+
        inc xf
        jsr ClearScreen
        Set latchedUp:#0
    !:

    lda latchedDown
    cmp #V
    bne !+
        dec xf
        jsr ClearScreen
        Set latchedDown:#0
    !:

    lda latchedLeft
    cmp #H
    bne !+
        inc xPhase
        jsr ClearScreen
        Set latchedLeft:#0
    !:

    lda latchedRight
    cmp #H
    bne !+
        dec xPhase
        jsr ClearScreen
        Set latchedRight:#0
    !:

    rts
}

Lissajou: {
    .var xf = __arg0
    .var yf = __arg1
    
    lda #Joystick.FIRE
    and playerAction
    cmp #Joystick.FIRE
    bne !skip+
        jsr ClearTrail
    !skip:

   


    inc writePointer
    lda xf
    clc
    adc xPhase
    tax
    lda sine,X
    lsr;lsr;
    clc
    adc xOffset
    sta x
    ldx writePointer
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
    ldx writePointer
    sta yTrails, X

    Set CharScreen.PenColor:t
    Call CharScreen.PlotH:x:y

    lda writePointer
    cmp #TRAILS
    bcc !+
        Set writePointer:#0
    !:

    rts

    xOffset: .byte 10
    yOffset: .byte 10
    x: .byte 0
    y: .byte 0
    writePointer: .byte 0
}

ClearTrail: {
    // clear the trail 1 ahead of the write pointer
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

    rts
        x: .byte 0
    y: .byte 0
        j: .byte 1
}


* = $1300 "unsigned trig tables"
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))
* = $1500 "trails"
xTrails: .fill TRAILS,0
yTrails: .fill TRAILS,0



