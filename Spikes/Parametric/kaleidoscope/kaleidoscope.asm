BasicUpstart2(Start)

// ZP state
// I am not using BASIC or KERNAL so $02-$ff is available to me
.label __tmp0 = $02
.label __tmp1 = $03
.label __tmp2 = $04
.label __tmp3 = $05

.label _rnd = $20

// "game" is not a great name - it's kaleidoscope space (as opposed to screen space)
.label _gameCenter = $21
.label _gameB = $22
.label _gameC = $23
// kaleidoscope co-ords 
.label _gameX = $24
.label _gameY = $25

.label _iterations = $26

.label _character = $27
.label _penColor = $28

// screen space co-ord 0..80 and 0..48
.label _screenX = $29
.label _screenY = $2a

// temp working variables
.label _sixel0 = $2b
.label _sixel1 = $2c

.label _indexToSixel = $2d // len 16

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    SetZeroPageState();

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
        lda    #0
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

    ClearScreen()

    // clear b,c
    lda #0
    sta _gameB
    sta _gameC
        
    // number of times to loop
    lda #16
    sta _iterations

next:
    // set a "random" pen color
    inc _penColor

    // you *could* just grab a random value about 0..32 and use that as a and b
    // but by accumulating the random number it looks better
    // looks sparser 
    // messing with the bitmask also has effects

    // get a random value 0..7
    NextRandom()
    //lsr;lsr;lsr;lsr;lsr
    and #%00111111
    // add it to b
    //clc; adc _gameB
    sta _gameB

    // // check bounds b <= a
    // lda _gameB
    // cmp _gameCenter
    // // is b <= a?
    // bcc !+
    // beq !+
    //     // out of bounds bail
    //     jmp early
    // !:

    // get a random value 0..7
    NextRandom()
    //lsr;lsr;lsr;lsr;lsr
    and #%00011111
    // add it to c
  //  clc; adc _gameC
    sta _gameC

    // check bounds c <= a
    // lda _gameC
    // cmp _gameCenter
    // // is c <= a?
    // bcc !+
    // beq !+
    //     jmp early
    // !:
    
    // plot a+b, a+c
    lda _gameCenter
    clc;adc _gameB
    sta _gameX

    lda _gameCenter
    clc;adc _gameC
    sta _gameY

    PlotH(_gameX, _gameY)

    // plot a+b, a-c
    lda _gameCenter
    sec;sbc _gameC
    sta _gameY

    PlotH(_gameX,_gameY)

    // plot a-b, a+c
    lda _gameCenter
    sec;sbc _gameB
    sta _gameX

    lda _gameCenter
    clc;adc _gameC

    sta _gameY

    PlotH(_gameX,_gameY)

    // plot a-b, a-c
    lda _gameCenter
    sec;sbc _gameC
    sta _gameY

    PlotH(_gameX,_gameY)

    // plot a+c, a+b
    lda _gameCenter
    clc;adc _gameC
    sta _gameX

    lda _gameCenter
    clc;adc _gameB
    sta _gameY

    PlotH(_gameX,_gameY)

    // plot a+c, a-b
    lda _gameCenter
    sec;sbc _gameB
    sta _gameY

    PlotH(_gameX,_gameY)

    // plot a-c, a+b
    lda _gameCenter
    sec;sbc _gameC
    sta _gameX

    lda _gameCenter
    clc;adc _gameB
    sta _gameY

    PlotH(_gameX,_gameY)

    // plot a-c, a-b
    lda _gameCenter
    sec;sbc _gameB
    sta _gameY

    PlotH(_gameX,_gameY)

early:
    dec _iterations
    beq exit
    jmp next
exit:
    pla;tay;pla;tax;pla
    rti  
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

    lda _character
    sta (screenLO),y  

    // set color ram
    lda screenRow.hi,x
    // ora is nice then to set the memory page
    ora #$D8 
    sta screenHI

    lda _penColor
    sta (screenLO),Y  
    exit:
}

/* Plot a hires sixel point, __arg0 is x 0..79, __arg1 is y 0..49 
    Currently there is no way to "unset" a pixel? Other than setting the whole "cell" to the bg color. */
.macro PlotH(gameX, gameY) {
    // set sixel1 as default even
    Set _sixel1:#1
    Set _sixel0:#0

    // convert to char screen space 0..40, 0..25
    lda gameX
    lsr 
    sta _screenX

    lda gameY
    lsr 
    sta _screenY

    // get current sixel, result in .X
    ReadInner(_screenX, _screenY)

    // convert the character to the sixel index
    lda sixel_to_index,x
    sta _sixel0

    // calulate new bit to set from odd/even of x,y
    lda gameX
    and #%00000001
    cmp #0
    beq !+ // was even, that's the default, do nothing
        // was odd, 
        Set _sixel1:#2
    !:
    
    lda gameY
    and #%00000001
    cmp #0
    beq !+ // was odd, do nothing
        // was even, shift << 2
        lda _sixel1
        asl;asl
        sta _sixel1
    !:

    // sixel1 and sixel0 now have equivalent basis, 0..15
    // combine the two with OR so as to preserve any ON bits
    lda _sixel0
    ora _sixel1
    tax
    stx _sixel1

    // lookup new char
    lda _indexToSixel,X
    sta _character

    // and plot
    PlotInner(_screenX, _screenY)
}
// from a screen code back to an index
.align $100  // this is a full page
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
    tax
}

// TODO: often called mov
/* @Command Set memory address to value. */
.pseudocommand Set destination:value {
    .errorif destination.getType() == AT_IMMEDIATE, "destination must not be IMMEDIATE."
    
    lda value
    sta destination
}


.align $100
screenRow: .lohifill 25, 40*i

.macro SetZeroPageState() {
    // set the random seed
    Set _rnd:#1

    // set game space match screen space = 40
    Set _gameCenter:#40
    Set _penColor:#WHITE

    // Setup "sixel" LUT
    // byte 32,126,124,226,123,97,255,236,108,127,225,251,98,252,254,160
    ldx #0
    lda #32
    sta _indexToSixel,X
    inx
    lda #126
    sta _indexToSixel,X
    inx
    lda #124
    sta _indexToSixel,X
    inx
    lda #226
    sta _indexToSixel,X
    inx
    lda #123
    sta _indexToSixel,X
    inx
    lda #97
    sta _indexToSixel,X
    inx
    lda #255
    sta _indexToSixel,X
    inx
    lda #236
    sta _indexToSixel,X
    inx
    lda #108
    sta _indexToSixel,X
    inx
    lda #127
    sta _indexToSixel,X
    inx
    lda #225
    sta _indexToSixel,X
    inx
    lda #251
    sta _indexToSixel,X
    inx
    lda #98
    sta _indexToSixel,X
    inx
    lda #252
    sta _indexToSixel,X
    inx
    lda #254
    sta _indexToSixel,X
    inx
    lda #160
    sta _indexToSixel,X
}