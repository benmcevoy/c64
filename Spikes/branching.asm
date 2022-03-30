BasicUpstart2(Start)

#import "_prelude.lib"

Start: {

    // FLAGS:

    // C - Carry
    // - BCC - branch carry clear, no borrow happened, or no carry happened
    // - BCS - branch carry set - borrow or carry did occour

    // N - Negative
    // - same as carry but for 2's complement, 
    // - BMI - branch if minus - result was >= 128
    // - BPL - branch if plus - result was less than 128

    // Z - Zero
    // - BEQ - zero flag is set
    // - BNE - zer flag is not set

    // V - Overflow
    // - BVC - branch overflow clear
    // - BVS - branch overflow set

    // CMP - simulates a subtraction, setting the flags accordingly, but not the .A 

    // setup debug
    Set __ptr1+1:#$c0
    Set __ptr1:#$00
    Set __offset:#0


    // unsigned
    // unsigned branch equal
    lda #1
    cmp #2
    bne !+
        // true
        print #0
        jmp !++
    !:
        // false
        print #1
    !:

    // signed
    
    print_results:
    ldy #0
    chrout:
        // top 4 bits
        lda (__ptr1),y
        lsr;lsr;lsr;lsr
        toHex()
        jsr $FFD2

        lda (__ptr1),y
        and #$0f
      //  sta (__ptr1),y
        toHex()
        jsr $FFD2

        lda #32
        jsr $FFD2
        iny
        cpy __offset
        bne chrout
    rts

    addressA: .byte 0
    addressB: .byte 0
}

.macro toHex(){
    
    cmp #$A
        beq !+
        bcs !+
            clc
            // 48 = 0 in petscii
            adc #48
            jmp exit
        !:
        clc
        // 65 is A  
        adc #55
        exit:
}

 __offset: .byte $0
    .pseudocommand print value {
        php
        ldy __offset; lda value; sta (__ptr1),y; inc __offset
        cpy #$ff
        bne !+
            brk
        !:
        plp
    }    

    .macro ShowAllFlags(){
        print #$ff

        // C was set
        bcs !+
            print #%0
            jmp !++
        !:
            print #1
        !:

        // Z was set
        beq !+
            print #%0
            jmp !++
        !:
            print #1
        !:

        // N was set
        bmi !+
            print #0
            jmp !++
        !:
            print #1
        !:

        // V was set
        bvs !+
            print #%0
            jmp !++
        !:
            print #1
        !:

        print #$ff
    }