BasicUpstart2(Start)
#import "_prelude.lib"
#import "_charscreen.lib"

.label ClearScreen = $E544
_offset: .byte 15
_rnd: .byte 1
a: .byte 25
b: .byte 0
c: .byte 0
d: .byte 0
e: .byte 0

index: .byte 0
index1: .byte 0

_x: .byte 0
_y: .byte 0

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK
loop:
    jsr ClearScreen
    jsr UpdateState
    
    Set index:#255
delay:
    dec index
    beq !+
        Set index1:#255
        inner:
        dec index1
        bne inner

        jmp delay
    !: 

    jmp loop
}

UpdateState: {
    // for d = c to a+a*pi*rnd
    // TODO: fixed point mulitply
    // why pi? this is just a + a * (some number betweeen 0 and 3.14)

    Set a:#25
    Set b:#0
    Set c:#0
    Set d:#0
    Set e:#0
    Set _x:#0
    Set _y:#0


    NextRandom()
    lsr;lsr
    sta d
next:
    NextRandom()
    sta CharScreen.PenColor
    // let e = pi*pi*rnd
    // about 0..10
    
    NextRandom()
    lsr;lsr;lsr;lsr;lsr
    sta e

    // let b = b + e*rnd
    NextRandom()
    lsr;lsr;lsr;lsr;lsr
    clc; adc b
    sta b

    // let c = c+e*rnd
    NextRandom()
    lsr;lsr;lsr;lsr;lsr
    clc; adc c
    sta c
    // let b = b && b <= a
    lda b
    cmp a
    bcc !+
    beq !+
        Set b:#0
    !:

    // let c = c && c <= a
    lda c
    cmp a
    bcc !+
    beq !+
        Set c:#0
    !:
    // plot a+b, a+c
    lda a
    clc;adc b
    sta _x

    lda a
    clc;adc c
    sta _y

    lda _x; clc; adc _offset; sta _x
    Call CharScreen.PlotH:_x:_y

    // plot a+b, a-c
    lda a
    sec;sbc c
    sta _y

    Call CharScreen.PlotH:_x:_y

    // plot a-b, a+c
    lda a
    sec;sbc b
    sta _x

    lda a
    clc;adc c
    sta _y

    lda _x; clc; adc _offset; sta _x
    Call CharScreen.PlotH:_x:_y

    // plot a-b, a-c
    lda a
    sec;sbc c
    sta _y

    Call CharScreen.PlotH:_x:_y

    // plot a+c, a+b
    lda a
    clc;adc c
    sta _x

    lda a
    clc;adc b
    sta _y

    lda _x; clc; adc _offset; sta _x
    Call CharScreen.PlotH:_x:_y

    // plot a+c, a-b
    lda a
    sec;sbc b
    sta _y

    Call CharScreen.PlotH:_x:_y

    // plot a-c, a+b
    lda a
    sec;sbc c
    sta _x

    lda a
    clc;adc b
    sta _y

    lda _x; clc; adc _offset; sta _x
    Call CharScreen.PlotH:_x:_y

    // plot a-c, a-b
    lda a
    sec;sbc b
    sta _y

    Call CharScreen.PlotH:_x:_y

    dec d
    beq cont
    jmp next
cont:

    // end irq
    // pla;tay;pla;tax;pla
    // rti 
    rts
}

/* 
    Return a random byte in .A
*/
.macro NextRandom() {
    lda _rnd
    asl;
    eor _rnd
    sta _rnd
    lsr;
    eor _rnd
    sta _rnd
    asl;asl
    eor _rnd
    sta _rnd
}


