BasicUpstart2(Start)

.label debug = $c000

Start: {

    // signed 16 bit add and subtract

    // 512 + -376
    // 512 is 0000 0010 0000 0000
    // -376 is 1111 1110 1000 1000
    // and 
    // eor $ffff
    // adc #1
    // works 

    lda #%00000010
    sta aHi

    lda #%00000000
    sta aLo

    // does #< this work? yep
    lda #<-376
    sta bLo
    sta debug

    lda #>-376
    sta bHi

    sta debug+1

    // to add

    clc
    lda aLo
    adc bLo
    // lo byte of result
    sta debug + 2
    // DO NOT clear carry
    lda aHi
    adc bHi
    sta debug + 3

    // expect 136

    lda #127
    sta aLo
    lda #0
    sta aHi

    // sign extension, test MSB
    lda aLo
    rol
    //bit aLo
    bcc !+
        lda #$ff
        sta aHi
    !:

    lda aHi
    sta debug + 4

    rts

    aLo: .byte 0
    aHi: .byte 0

    bLo: .byte 0
    bHi: .byte 0

    c: .word $0000

}