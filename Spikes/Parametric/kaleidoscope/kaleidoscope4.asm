BasicUpstart2(Start)
#import "_prelude.lib"
#import "../dynamic/solid.asm"

.const OFFSET = 15
.const ITERATIONS = 40
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
.label iterations = $2f
.label index_to_sixel = $30

.label aplusb = $c000
.label aplusc = $c100
.label aminusc = $c200
.label aminusb = $c300

screenRow: .lohifill 25, 40*i

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    Set _rnd:#1
    Set a:#160
   
 // init sid noise for random
    lda #$ff // maximum frequency value
    sta $D40E // voice 3 frequency low byte
    lda #$ff
    sta $D40F // voice 3 frequency high byte
    lda #32 // saw
    sta $D412 // voice 3 control register
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
    lda    #1
    sta    $d012

    inc frame
    lda frame
    ror
    bcc !+
        jsr Background.Draw    
        jsr Render  
        pla;tay;pla;tax;pla
        rti  
    !:
    
    jsr UpdateStateInner
    
    pla;tay;pla;tax;pla
    rti  
}

UpdateStateInner: {
    lda #0
    sta b
    sta c
    sta iterations
    tax

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
    and #%00000111
    clc; adc b
    sta b

    NextRandom()
    and #%00000111
    clc; adc c
    sta c

    // check bounds b <= a
    lda b
    cmp a
    bcc !+
    beq !+
        // out of bounds bail
        Set b:#0
    !:

    // check bounds c <= a
    lda c
    cmp a
    bcc !+
    beq !+
        Set c:#0
    !:

    lda a
    clc;adc b
    sta aplusb,X

    lda a
    clc;adc c
    sta aplusc,X

    lda a
    sec;sbc b
    sta aminusb,X

    lda a
    sec;sbc c
    sta aminusc,X

    inc iterations
    inx 
    cpx d
    bne next

exit:
    rts
}

Render: {

loop:    
    NextRandom()
    sta PenColor

    ldx iterations
    // plot a+b, a+c
    lda aplusb,X
    cmp a
    bne !+
     jmp next
    !:
    clc;adc #OFFSET;
    sta _x

    lda aplusc,X
    cmp a
    bne !+
     jmp next
    !:
    sta _y

    PlotH(_x,_y)

    ldx iterations
    // plot a+b, a-c
    lda aminusc,X
    cmp a
    bne !+
     jmp next
    !:
    sta _y

    PlotH(_x,_y)

    ldx iterations
    // plot a-b, a+c
    lda aminusb,X
    cmp a
    bne !+
     jmp next
    !:
    clc; adc #OFFSET
    sta _x

    lda aplusc,X
    cmp a
    bne !+
     jmp next
    !:
    sta _y

    PlotH(_x,_y)

    ldx iterations
    // plot a-b, a-c
    lda aminusb,X
    cmp a
    bne !+
     jmp next
    !:
    sta _y

    PlotH(_x,_y)

    ldx iterations
    // plot a+c, a+b
    lda aplusc, X; clc; adc #OFFSET
    cmp a
    bne !+
     jmp next
    !:
    sta _x

    lda aplusb,X
    cmp a
    bne !+
     jmp next
    !:
    sta _y

    PlotH(_x,_y)

    ldx iterations
    // plot a+c, a-b
    lda aminusb,X
    cmp a
    bne !+
     jmp next
    !:
    sta _y

    PlotH(_x,_y)

    // plot a-c, a+b
    ldx iterations
    lda aminusc,X;clc; adc #OFFSET
    cmp a
    bne !+
     jmp next
    !:
    sta _x

    lda aplusb,X
    cmp a
    bne !+
     jmp next
    !:
    sta _y

    PlotH(_x,_y)

    // plot a-c, a-b
    ldx iterations
    lda aminusb,X
    cmp a
    bne !+
     jmp next
    !:
    sta _y

    PlotH(_x,_y)
next:
    dec iterations
    beq !+
        jmp loop
    !:
    rts
}

/* 
    Return a random byte in .A
*/
.macro NextRandom() {
        lda $d41b
    // lda _rnd
    // asl;
    // eor _rnd
    // sta _rnd
    // lsr;
    // eor _rnd
    // sta _rnd
    // asl;asl
    // eor _rnd
    // sta _rnd
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
        

        