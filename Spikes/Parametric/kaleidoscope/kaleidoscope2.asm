BasicUpstart2(Start)
#import "_prelude.lib"
#import "../dynamic/solid.asm"

.label ClearScreen = $E544
.const OFFSET = 7
// ZP
.label _rnd = $20
.label a = $21
.label b = $22
.label c = $23
.label d = $24

.label dir = $25
.label _x = $26
.label _y = $27

.label PenColor = $28

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    Set _rnd:#1
    Set a:#12



// Raster IRQ
    sei
        // disable cia timers
        lda    #$7f
        sta    $dc0d
        
        // enable raster irq
        lda $d01a                     
        ora #$01
        sta $d01a
        lda $d011                    
        and #$7f
        sta $d011

        // set next irq line number
        lda    #1
        sta    $d012
        
        lda #<UpdateState            
        sta $0314
        lda #>UpdateState
        sta $0315
    cli

    jmp *

loop:
   
    jsr UpdateState
    jmp loop
}

UpdateState: {
     jsr Background.Draw
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

    lda b
    cmp a
    bcc !+
    beq !+
        Set b:#0
    !:

    lda c
    cmp a
    bcc !+
    beq !+
        Set c:#0
    !:
    // plot a+b, a+c
    lda a
    clc;adc b
    adc #OFFSET;
    sta _x

    lda a
    clc;adc c
    sta _y

    PlotColor _x:_y

    // plot a+b, a-c
    lda a
    sec;sbc c
    sta _y

    PlotColor _x:_y

    // plot a-b, a+c
    lda a
    sec;sbc b
    clc;adc #OFFSET;
    sta _x

    lda a
    clc;adc c
    sta _y

    PlotColor _x:_y

    // plot a-b, a-c
    lda a
    sec;sbc c
    sta _y

    PlotColor _x:_y

    // plot a+c, a+b
    lda a
    clc;adc c
    adc #OFFSET;
    sta _x

    lda a
    clc;adc b
    sta _y

    PlotColor _x:_y

    // plot a+c, a-b
    lda a
    sec;sbc b
    sta _y

    PlotColor _x:_y

    // plot a-c, a+b
    lda a
    sec;sbc c
    clc; adc #OFFSET; 
    sta _x

    lda a
    clc;adc b
    sta _y

    PlotColor _x:_y

    // plot a-c, a-b
    lda a
    sec;sbc b
    sta _y

    PlotColor _x:_y

    dec d
    beq cont
    jmp next
cont:
        pla;tay;pla;tax;pla
        rti  
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

.pseudocommand PlotColor x:y {
    .var screenLO = __tmp0 
    .var screenHI = __tmp1

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
}

screenRow: .lohifill 25, 40*i


