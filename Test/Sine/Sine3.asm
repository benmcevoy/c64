BasicUpstart2(Start)

#import "_charscreen.lib"

offset: .byte 0

Start:{
    // let's try
    // - draw a circle
    // unit circle
    // x = cos(t)
    // y = sin(t)

    Set t:#$ff
loop:

    lda t
    tax
    lda cosine,X
    lsr;lsr;lsr;lsr;
    clc
    adc xOffset
    sta x


    lda sine,X
    lsr;lsr;lsr;lsr;
    clc 
    adc yOffset
    sta y

    
      Call CharScreen.Plot:x:y
    // ha, so many bugs here
//    Call CharScreen.PlotLine:#20:#12:x:y

    dec t

    !:
     lda t
     cmp #0
    jmp loop

    
    rts
    // screen coords
    x: .byte 0
    y: .byte 0

    xOffset: .byte 12
    yOffset: .byte 4

    t: .byte 0
}

// unsigned trig tables
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))
