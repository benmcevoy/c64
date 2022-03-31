BasicUpstart2(Start)

#import "_prelude.lib"
#import "_math.lib"


Start: {


    loop:

        Wrap counter:#40
        DebugPrint __val0

        dec counter
        cmp #0
        bne !+
            rts
        !:
        jmp loop

    rts

    counter: .byte 42
}

.pseudocommand Modulus value:modulus {
    sec
    lda value
    m:
    sbc modulus
    bcs m
    adc modulus
    sta __val0 
}


/* @Command */
.pseudocommand Wrap value :maxValue {
    lda value
    bmi negative
        bpl !+
            Modulo value:maxValue
            jmp exit
        !:
            sta __val0
            jmp exit

    negative:
        Modulo value:maxValue
        lda __val0
        cmp #0
        bne !+
            jmp exit
        !:
        clc
        adc maxValue
        sta __val0
   
   exit:
}