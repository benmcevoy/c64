BasicUpstart2(Start)

#import "_prelude.lib"

Start: {

    Wrap #0: #10:  #40
    DebugPrint __val0

    Wrap #39: #42:  #40
    DebugPrint __val0


    Wrap #78: #90:  #40
    DebugPrint __val0

    Modulus #0:  #40
    DebugPrint __val0

    Modulus #39:   #40
    DebugPrint __val0


    Modulus #78:  #40
    DebugPrint __val0

    rts
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
.pseudocommand Wrap oldValue: newValue :maxValue {

    // if new value >=0 and <=max then return it
    lda newValue
    cmp #0
    bmi !+
        lda newValue
        cmp maxValue
        beq cont
        bcs !+
            cont:
            Set __val0:newValue
            jmp exit
    !:

    // find delta/direction
    lda newValue
    sec
    sbc oldValue
    bmi decreasing
        lda newValue
        sec
        sbc maxValue
        sta __val0
        jmp exit
    !: 
    
    decreasing:
        lda newValue
        clc
        adc maxValue
        sta __val0
        
    exit:
}