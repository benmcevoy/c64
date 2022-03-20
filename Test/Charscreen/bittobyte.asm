BasicUpstart2(Start)

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_math.lib"

.label CHAR_ROM = $d000

Start:{
    
    Call CharScreen.WriteString:#10:#9:#<message:#>message

    .var x = __arg0
    .var y = __arg1
    .var byteLine = __arg3
    .var charPtr = __tmp0
    .var xStart = __tmp1

    Set x:#0
    Set y:#10
    Set charPtr:#0
    Set xStart:x
    lda xStart
    sec
    sbc #8
    sta xStart
    
    sei  
        lda 1
        and #251
        sta 1

        
    nextChar:

        ldy charPtr
        lda message,y
        cmp #ACTION_HANDLED
        bne !+
            jmp exit
        !:

        // at this point you have a screen code in the accumulator, between 0..255
        // you need to multiply by 8 and add to $d000
        sta __tmp2
        Call Math.Mul16:#8:__tmp2
        Call Math.Add16:__val0:__val1:#$00:#$d0
        
        // bit of meta programming
        lda __val0
        sta inject+1
        lda __val1
        sta inject+2

        ldy #0
            
        lda xStart
        clc
        adc #8
        sta xStart

        nextByteInChar:
            Set x:xStart
            inject:
            lda CHAR_ROM,Y
            sta byteLine

            ldx #0
            
            plot:
                lda byteLine
                // shift msb into carry
                asl
                sta byteLine
                // test carry
                bcc !+
                    Call CharScreen.PlotH:x:y
                !:

                inc x
                inx 
                cpx #8
                bne plot

            inc y
            iny
            cpy #8
            bne nextByteInChar
        
        inc charPtr
        Set y:#0
        jmp nextChar

    exit:
        // restore char rom
        lda 1
        ora #4
        sta 1
    cli
    rts

    message: .text @"\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$ff"

}

Start1:{
    Set char:#%10101011

    ldx #0
    
plot:
    lda char
    // shift msb into carry
    asl
    sta char
    // test carry
    bcc !+
        Call CharScreen.Plot:x:y
    !:

    inc x
    inx 
    cpx #8
    bne plot

    rts
    x: .byte 0
    y: .byte 0
    char: .byte 0
    debug: .byte 0
    DEBUG: .word $c000
}