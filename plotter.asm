BasicUpstart2(Start)

#import "_prelude.lib"
#import "_charscreen.lib"

Start:{
    Set $d020:#GREEN
    Set $d021:#BLACK

    Set CharScreen.Character:#204
    Set CharScreen.PenColor:#GREEN
    
    // test cases
    jsr DrawHexagon
    jsr DrawSquare
    jsr DrawLines
    jsr DrawDisc

    jsr DrawAngle
    jsr DrawEdges

    //Call CharScreen.Plot:#39:#0
    
    rts

    x: .byte 10
    y: .byte 6
}

DrawEdges: {
    Call CharScreen.PlotLine: #0:#0:#39:#0
     Call CharScreen.PlotLine: #0:#0:#0:#24
     Call CharScreen.PlotLine: #39:#0:#39:#24
     Call CharScreen.PlotLine: #0:#24:#39:#24

    rts
}

DrawHexagon: {
    // a hexagon
    Call CharScreen.PlotLine: #2:#12:#12:#2
    Call CharScreen.PlotLine: #12:#2:#22:#2
    Call CharScreen.PlotLine: #22:#2:#32:#12
    Call CharScreen.PlotLine: #32:#12:#22:#22
    Call CharScreen.PlotLine: #22:#22:#12:#22
    Call CharScreen.PlotLine: #12:#22:#2:#12 

    rts
}

DrawSquare: {
    // draw a square
    Set CharScreen.PenColor:#WHITE
    Call CharScreen.PlotRect:#6:#6:#32:#20

    rts
}

DrawLines:{
    // horizontal positive, x inc, y is constant
    Call CharScreen.PlotLine: #20:#12:#30:#12

    // horizontal negative
    inc CharScreen.PenColor
    Call CharScreen.PlotLine: #20:#12:#10:#12

    // another case to exercise _plotLineLow
    inc CharScreen.PenColor
    Call CharScreen.PlotLine: #20:#12:#10:#6

    // vertical postive
    inc CharScreen.PenColor
    Call CharScreen.PlotLine: #20:#12:#20:#22

    // vertical -ve
    inc CharScreen.PenColor
    Call CharScreen.PlotLine: #20:#12:#20:#2

    // down right
    inc CharScreen.PenColor
    Call CharScreen.PlotLine: #20:#12:#30:#22

    // down left
    inc CharScreen.PenColor
    Call CharScreen.PlotLine: #20:#12:#10:#22

    // up right
    inc CharScreen.PenColor
    Call CharScreen.PlotLine: #20:#12:#30:#2

    // up left
    inc CharScreen.PenColor
    Call CharScreen.PlotLine: #20:#12:#10:#2

    rts
}

DrawAngle: {
    Set t:#75
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

    Set CharScreen.PenColor:#WHITE
    // ha, so many bugs here
    Call CharScreen.PlotLine:#20:#12:x:y

    Set CharScreen.PenColor:#GREEN
    Call CharScreen.Plot:x:y

    rts
    // screen coords
    x: .byte 0
    y: .byte 0

    xOffset: .byte 12
    yOffset: .byte 4
}

DrawDisc: {
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

    Set CharScreen.PenColor:#WHITE
    // ha, so many bugs here
    Call CharScreen.PlotLine:#20:#12:x:y

    Set CharScreen.PenColor:#GREEN
    Call CharScreen.Plot:x:y

    dec t
    dec t
    lda t
    cmp #3
    bcc !+
        jmp loop
    !:

    rts
    // screen coords
    x: .byte 0
    y: .byte 0

    xOffset: .byte 12
    yOffset: .byte 4
}

t: .byte 0
// unsigned trig tables
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))