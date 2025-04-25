BasicUpstart2(Start)
#import "_prelude.lib"

.const OFFSET = 15
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
.label sixel0 = $2c
.label sixel1 = $2d
.label frame = $2e

.label index_to_sixel = $2e

screenRow: .lohifill 25, 40*i

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    ClearScreen()

    Set _rnd:#1
    Set a:#160

    // byte 32,126,124,226,123,97,255,236,108,127,225,251,98,252,254,160
    ldx #0
    lda #32
    sta index_to_sixel,X
    inx
    lda #126
    sta index_to_sixel,X
    inx
    lda #124
    sta index_to_sixel,X
    inx
    lda #226
    sta index_to_sixel,X
    inx
    lda #123
    sta index_to_sixel,X
    inx
    lda #97
    sta index_to_sixel,X
    inx
    lda #255
    sta index_to_sixel,X
    inx
    lda #236
    sta index_to_sixel,X
    inx
    lda #108
    sta index_to_sixel,X
    inx
    lda #127
    sta index_to_sixel,X
    inx
    lda #225
    sta index_to_sixel,X
    inx
    lda #251
    sta index_to_sixel,X
    inx
    lda #98
    sta index_to_sixel,X
    inx
    lda #252
    sta index_to_sixel,X
    inx
    lda #254
    sta index_to_sixel,X
    inx
    lda #160
    sta index_to_sixel,X
    

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

}

UpdateState: {
    // ack irq
    lda $d019
    sta $d019
    // set next irq line number
    lda    #250
    sta    $d012

//inc $d020

    // TODO: unset a pixel
    ClearScreen()

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
    lsr;lsr;
    sta d
next:
    NextRandom()
    sta PenColor

    NextRandom()
    // TODO: surely an AND is faster?
    lsr;lsr;lsr;lsr;lsr
    //and #%00000111
    clc; adc b
    sta b

    NextRandom()
    lsr;lsr;lsr;lsr;lsr
    //and #%00000011
    clc; adc c
    sta c

    // check bounds b <= a
    lda b
    cmp a
    bcc !+
    beq !+
        // out of bounds bail
        jmp early
    !:

    // check bounds c <= a
    lda c
    cmp a
    bcc !+
    beq !+
        jmp early
    !:
    
    // plot a+b, a+c
    lda a
    clc;adc b;adc #OFFSET;
    sta _x

    lda a
    clc;adc c
    sta _y

    // TODO: too many, can i use some kind of buffer instead and draw the lot in one go?
    // maintain a bit map/frame buffer of 80x50 pixels (or 80x48) or 10x6 bytes
    // 60 bytes can fit in zero page
    // then i can calculate new frame with many raster lines then just render within the blank

    // start:
    //  zero out the buffer
    //  OR in the pixels
    // render:
    //  draws the "whole" screen everytime
    //  from pixel to sixel?  more  LUTs? map 1 byte to one draw operation
    //  one byte is 8x8 pixels, which is 4 sixels?

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

early:
    dec d
    beq cont
    jmp next
cont:
exit:
//dec $d020
        pla;tay;pla;tax;pla
        rti  
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

    /* Plot a hires sixel point, __arg0 is x 0..79, __arg1 is y 0..49 
       Currently there is no way to "unset" a pixel? Other than setting the whole "cell" to the bg color. */
    .macro PlotH(x,y) {
        // set sixel1 as default even
        Set sixel1:#1
        Set sixel0:#0

        // convert screen space
        lda x
        lsr 
        sta xScreen

        lda y
        lsr 
        sta yScreen

        // get current sixel
        ReadInner(xScreen,yScreen)

        // convert the character to the sixel index
        ldx __val0
        lda sixel_to_index,x
        sta sixel0

        // calulate new bit to set from odd/even of x,y
        lda x
        and #%00000001
        cmp #0
        beq !+ // was even, that's the default, do nothing
            // was odd, 
            Set sixel1:#2
        !:
        
        lda y
        and #%00000001
        cmp #0
        beq !+ // was odd, do nothing
            // was even, shift << 2
            lda sixel1
            asl;asl
            sta sixel1
        !:

        // sixel1 and sixel0 now have equivalent basis, 0..15
        // combine the two with OR so as to preserve any ON bits
        lda sixel0
        ora sixel1
        tax
        stx sixel1

        // lookup new char
        lda index_to_sixel,X
        sta sixel1

        // and plot
        Set Character:sixel1
        PlotInner(xScreen,yScreen)
    }

    sixel_to_index: .fill 0, 96
    .byte 5,12,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,2,0,1,9
    .fill 31,0
    .byte 15
    .fill 64,0
    .byte 10,3,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,13,0,14,6
            

    .macro ReadInner(x,y){
        .var screenLO = __tmp0 
        .var screenHI = __tmp1

        ldy x
        ldx y

        clc
        lda screenRow.lo,x  
        sta screenLO

        lda screenRow.hi,x
        ora #$04 
        sta screenHI

        lda (screenLO),y  
        sta __val0

        // color
        lda screenRow.hi,x
        ora #$D8 
        sta screenHI

        lda (screenLO),y  
        sta __val1
    }

.macro ClearScreen(){
    //$0400-$07E7
    lda #32
    ldx #0
    !:
        sta $0400,X
        sta $0500,X
        sta $0600,X
        sta $0700,X
        inx
    bne !-
}
