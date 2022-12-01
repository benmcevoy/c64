BasicUpstart2(Start)

#import "_prelude.lib"
#import "_charscreen.lib"


Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    // clear screen
    jsr $E544

    Set CharScreen.Character:#81
    jsr OnRasterInterrupt
    rts
}

OnRasterInterrupt: {
        
    Set t:#$ff
    loop:

    lda t
    tax
    lda cosine1,X
    clc
    adc #10
    sta x

    lda sine1,X
    clc 
    adc #4
    sta y

    Set CharScreen.PenColor:#BLUE
    Call CharScreen.Plot:x:y

    lda t
    tax
    lda cosine2,X
    clc
    adc #11
    sta x

    lda sine2,X
    clc 
    adc #5
    sta y

    Set CharScreen.PenColor:#GREEN
    Call CharScreen.Plot:x:y

    lda t
    tax
    lda cosine3,X
    clc
    adc #12
    sta x

    lda sine3,X
    clc 
    adc #6
    sta y

    Set CharScreen.PenColor:#YELLOW
    Call CharScreen.Plot:x:y

    dec t
    dec t
    dec t
    dec t
    dec t
    lda t
    cmp #4
    bcc !+
        jmp loop
    !:

rts
    // screen coords
    x: .byte 0
    y: .byte 0

    xOffset: .byte 10
    yOffset: .byte 5
}
t: .byte 0
// unsigned trig tables
sine1: .fill 256,round(8.5+8.5*sin(toRadians(i*360/256)))
cosine1: .fill 256,round(8.5+8.5*cos(toRadians(i*360/256)))
sine2: .fill 256,round(7.5+7.5*sin(toRadians(i*360/256)))
cosine2: .fill 256,round(7.5+7.5*cos(toRadians(i*360/256)))
sine3: .fill 256,round(6.5+6.5*sin(toRadians(i*360/256)))
cosine3: .fill 256,round(6.5+6.5*cos(toRadians(i*360/256)))