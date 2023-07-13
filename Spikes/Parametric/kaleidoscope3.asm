BasicUpstart2(Start)
#import "_prelude.lib"
#import "dynamic/solid.asm"

.const OFFSET = 5
.label ClearScreen = $E544

// ZP
.label _rnd = $20
.label a = $21
.label b = $22
.label c = $23
.label d = $24

.label dir = $25
.label _x = $26
.label _y = $27
.label Character = $28
.label PenColor = $29
.label xScreen = $2a
.label yScreen = $2b

screenRow: .lohifill 25, 40*i

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    Set _rnd:#1
    Set a:#160

loop:
    // TODO: trails
    jsr Background.Draw
    jsr UpdateState
    jmp loop
}

UpdateState: {
    lda #0
    sta b
    sta c
    
    lda a
    cmp #200
    bne !+
        Set dir:#1
    !:

    lda a
    cmp #140
    bne !+
        Set dir:#0
    !:

    lda dir
    cmp #1
    bne !+
        dec a
        jmp __
    !:
    inc a
__:

    NextRandom()
    lsr;lsr
    sta d
next:
    NextRandom()
    sta PenColor

    NextRandom()
    lsr;lsr;lsr;lsr;lsr
    clc; adc b
    sta b

    NextRandom()
    lsr;lsr;lsr;lsr;lsr
    clc; adc c
    sta c

    // check bounds b <= a
    lda b
    cmp a
    bcc !+
    beq !+
        Set b:#0
    !:

    // check bounds c <= a
    lda c
    cmp a
    bcc !+
    beq !+
        Set c:#0
    !:
    
    // plot a+b, a+c
    lda a
    clc;adc b;adc #OFFSET;
    sta _x

    lda a
    clc;adc c
    sta _y

    PlotH(_x,_y)

    // plot a+b, a-c
    lda a
    sec;sbc c
    sta _y

    PlotH(_x,_y)

    // plot a-b, a+c
    lda a
    sec;sbc b;clc; adc #OFFSET
    sta _x

    lda a
    clc;adc c
    sta _y

    PlotH(_x,_y)

    // plot a-b, a-c
    lda a
    sec;sbc c
    sta _y

    PlotH(_x,_y)

    // plot a+c, a+b
    lda a
    clc;adc c; adc #OFFSET
    sta _x

    lda a
    clc;adc b
    sta _y

    PlotH(_x,_y)

    // plot a+c, a-b
    lda a
    sec;sbc b
    sta _y

    PlotH(_x,_y)

    // plot a-c, a+b
    lda a
    sec;sbc c;clc; adc #OFFSET
    sta _x

    lda a
    clc;adc b
    sta _y

    PlotH(_x,_y)

    // plot a-c, a-b
    lda a
    sec;sbc b
    sta _y

    PlotH(_x,_y)

    dec d
    beq cont
    jmp next
cont:

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

    /* @jsr x:__arg0, y:__arg1 */
    .macro PlotInner(x,y) {
        .var screenLO = __tmp0 
        .var screenHI = __tmp1

        lda x
        cmp #39
        bcc !+
        beq !+
            jmp exit
        !:

        lda y
        cmp #24
        bcc !+
        beq !+
            jmp exit
        !:

         // annoyingly backwards "x is Y" due to indirect indexing below
        ldy x
        ldx y

        clc
        lda screenRow.lo,x  
        sta screenLO

        lda screenRow.hi,x
        ora #$04 
        sta screenHI

        lda Character
        sta (screenLO),y  

        // set color ram
        lda screenRow.hi,x
        // ora is nice then to set the memory page
        ora #$D8 
        sta screenHI

        lda PenColor
        sta (screenLO),Y  
        exit:
    }

    .macro PlotH(x,y) {
        
        // convert screen space
        lda x
        lsr 
        sta xScreen

        lda y
        lsr 
        sta yScreen

        PlotColor xScreen:yScreen
    }


.pseudocommand PlotColor x:y {
    .var screenLO = __tmp0 
    .var screenHI = __tmp1

lda x
        cmp #39
        bcc !+
        beq !+
            jmp exit
        !:

        lda y
        cmp #24
        bcc !+
        beq !+
            jmp exit
        !:

    // annoyingly backwards "x is Y" due to indirect indexing below
    ldy x
    ldx y

    lda screenRow.lo,X  
    sta screenLO

    // set color ram
    lda screenRow.hi,X
    // ora is nice then to set the memory page
    ora #$D8 
    sta screenHI

    lda PenColor
    sta (screenLO),Y  
    exit:
}
        

