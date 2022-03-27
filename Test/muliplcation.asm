BasicUpstart2(start)

#import "_prelude.lib"
#import "_math.lib"

start: {
    //  jsr Test_multiply_8bit_unsigned
    //  jsr Test_multiply_8bit_signed
    // jsr Test_multiply_16bit_unsigned
    //jsr Test_multiply_16bit_signed

     // $f000 * $005a
    Set __tmp0:#$00
    Set __tmp1:#$f0
    Set __tmp2:#$5a
    Set __tmp3:#$00
    sec
    jsr multiply_16bit_signed

    DebugPrint __val3
    DebugPrint __val2
    DebugPrint __val1
    DebugPrint __val0
    rts
}

Test_multiply_8bit_signed:{
    Set __tmp0:#23
    Set __tmp1:#7
    sec
    jsr multiply_8bit_signed

    // expect $00a1
    DebugPrint __val1
    DebugPrint __val0

    SMul16 __tmp0:__tmp1

    DebugPrint __val1
    DebugPrint __val0

    Set __tmp0:#$17
    Set __tmp1:#-7
    sec
    jsr multiply_8bit_signed

    // expect $ff5f, didn't get it
    DebugPrint __val1
    DebugPrint __val0

    Set __tmp0:#$17
    Set __tmp1:#$F9

    SMul16 __tmp0:__tmp1

    DebugPrint __val1
    DebugPrint __val0

    rts
}

Test_multiply_16bit_unsigned: {
    
    // 312 * -78 is -24336 or $a0f0
    Set __tmp0:#$38
    Set __tmp1:#$01
    Set __tmp2:#$4e
    Set __tmp3:#$00
    sec
    jsr multiply_16bit_unsigned

    // expect $5f10 - nope :(
    DebugPrint __val3
    DebugPrint __val2
    DebugPrint __val1
    DebugPrint __val0

    MulW32 __tmp0:__tmp1:__tmp2:__tmp3

    // expect $5f10
    DebugPrint __val3
    DebugPrint __val2
    DebugPrint __val1
    DebugPrint __val0

    rts
}

Test_multiply_16bit_signed: {

    // 312 * -78 is $0138 * 004e
    Set __tmp0:#$38
    Set __tmp1:#$01
    Set __tmp2:#$b2
    Set __tmp3:#$ff
    sec
    jsr multiply_16bit_signed

    // expect $ffffa0f0 
    DebugPrint __val3
    DebugPrint __val2
    DebugPrint __val1
    DebugPrint __val0

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3

    // expect $ffffa0f0 
    DebugPrint __val3
    DebugPrint __val2
    DebugPrint __val1
    DebugPrint __val0

    rts
}

Test_multiply_8bit_unsigned: {
    Set __tmp0:#23
    Set __tmp1:#7
    sec
    jsr multiply_8bit_unsigned

    // expect $00a1
    DebugPrint __val1
    DebugPrint __val0

     Mul16 __tmp0:__tmp1

     DebugPrint __val1
     DebugPrint __val0

    Set __tmp0:#23
    Set __tmp1:#12
    sec
    jsr multiply_8bit_unsigned
    // expect $0114
    DebugPrint __val1
    DebugPrint __val0

    rts
}

// https://codebase64.org/doku.php?id=base:seriously_fast_multiplication
// my routines... i am not sure they are giving the right answers
// so lets compare
// well, it almost gives the right number...
// bugs in that tablegen code, possibly my transciption, but i regen it and it's good
// it's working now, so far
// both versions give the same answer

// Description: Unsigned 8-bit multiplication with unsigned 16-bit result.
//                                                                       
// Input: 8-bit unsigned value in T1                                      
//        8-bit unsigned value in T2                                      
//        Carry=0: Re-use T1 from previous multiplication (faster)        
//        Carry=1: Set T1 (slower)                                        
//                                                                        
// Output: 16-bit unsigned value in PRODUCT                               
//                                                                        
// Clobbered: PRODUCT, X, A, C                                            
//                                                                        
// Allocation setup: T1,T2 and PRODUCT preferably on Zero-page.           
//                   square1_lo, square1_hi, square2_lo, square2_hi must be
//                   page aligned. Each table are 512 bytes. Total 2kb.    
//                                                                         
// Table generation: I:0..511                                              
//                   square1_lo = <((I*I)/4)                               
//                   square1_hi = >((I*I)/4)                               
//                   square2_lo = <(((I-255)*(I-255))/4)                   
//                   square2_hi = >(((I-255)*(I-255))/4)                   
multiply_8bit_unsigned:{      
        .var T1 = __tmp0                                        
        .var T2 = __tmp1
        .var PRODUCT = __val0
        .var PRODUCTHI = __val1

        bcc !+                                                    
            lda T1                                                
            sta sm1+1                                             
            sta sm3+1                                             
            eor #$ff                                              
            sta sm2+1                                             
            sta sm4+1                                             
        !:  

        ldx T2 
        sec   
sm1:    lda square1.lo,x
sm2:    sbc square2.lo,x
        sta PRODUCT   
sm3:    lda square1.hi,x
sm4:    sbc square2.hi,x
        sta PRODUCTHI   

        rts
}

// Description: Signed 8-bit multiplication with signed 16-bit result.
//                                                                    
// Input: 8-bit signed value in T1                                    
//       8-bit signed value in T2                                    
//        Carry=0: Re-use T1 from previous multiplication (faster)    
//        Carry=1: Set T1 (slower)                                    
//                                                                    
// Output: 16-bit signed value in PRODUCT                             
//                                                                    
// Clobbered: PRODUCT, X, A, C                                        
multiply_8bit_signed:{       
    .var T1 = __tmp0                                        
    .var T2 = __tmp1
    .var PRODUCT = __val0
    .var PRODUCTHI = __val1

    lda T1                                     
    bpl !+                                     
        sec                                    
        lda PRODUCT+1                          
        sbc T2                                 
        sta PRODUCT+1                          
    !:                                          
    lda T2                                     
    bpl !+                                     
        sec                                    
        lda PRODUCT+1                          
        sbc T1                                 
        sta PRODUCT+1                          
    !:                                          

    rts
}     

// Description: Unsigned 16-bit multiplication with unsigned 32-bit result.
//                                                                         
// Input: 16-bit unsigned value in T1                                      
//        16-bit unsigned value in T2                                      
//       Carry=0: Re-use T1 from previous multiplication (faster)         
//       Carry=1: Set T1 (slower)                                         
//                                                                         
// Output: 32-bit unsigned value in PRODUCT                                
//                                                                         
// Clobbered: PRODUCT, X, A, C                                             
//                                                                         
// Allocation setup: T1,T2 and PRODUCT preferably on Zero-page.            
//                   square1_lo, square1_hi, square2_lo, square2_hi must be
//                   page aligned. Each table are 512 bytes. Total 2kb.    
//                                                                         
// Table generation: I:0..511                                              
//                   square1_lo = <((I*I)/4)                               
//                  square1_hi = >((I*I)/4)                               
//                   square2_lo = <(((I-255)*(I-255))/4)                   
//                  square2_hi = >(((I-255)*(I-255))/4)                   
multiply_16bit_unsigned:{                                             
                // <T1 * <T2 = AAaa                                        
                // <T1 * >T2 = BBbb                                        
                // >T1 * <T2 = CCcc                                        
                // >T1 * >T2 = DDdd                                        
                //                                                         
                //       AAaa                                              
                //     BBbb                                                
                //     CCcc                                                
                // + DDdd                                                  
                // ----------                                              
                //   PRODUCT!                                              

                .var T1LO = __tmp0                                        
                .var T1HI = __tmp1
                .var T2LO = __tmp2
                .var T2HI = __tmp3
                .var PRODUCTLO1 = __val0
                .var PRODUCTLO2 = __val1
                .var PRODUCTHI1 = __val2
                .var PRODUCTHI2 = __val3

                // Setup T1 if changed
                bcc !+               
                    lda T1LO        
                    sta sm1a+1       
                    sta sm3a+1       
                    sta sm5a+1       
                    sta sm7a+1       
                    eor #$ff         
                    sta sm2a+1       
                    sta sm4a+1       
                    sta sm6a+1       
                    sta sm8a+1       
                    lda T1HI       
                    sta sm1b+1       
                    sta sm3b+1       
                    sta sm5b+1       
                    sta sm7b+1       
                    eor #$ff         
                    sta sm2b+1       
                    sta sm4b+1       
                    sta sm6b+1       
                    sta sm8b+1       
                !:                    

                // Perform <T1 * <T2 = AAaa
                ldx T2LO                  
                sec                       
sm1a:           lda square1.lo,x          
sm2a:           sbc square2.lo,x          
                sta PRODUCTLO1             
sm3a:           lda square1.hi,x          
sm4a:           sbc square2.hi,x          
                sta _AA+1                 

                // Perform >T1_hi * <T2 = CCcc
                sec                          
sm1b:           lda square1.lo,x             
sm2b:           sbc square2.lo,x             
                sta _cc+1                    
sm3b:           lda square1.hi,x             
sm4b:           sbc square2.hi,x             
                sta _CC+1                    

                // Perform <T1 * >T2 = BBbb
                ldx T2HI                 
                sec                       
sm5a:           lda square1.lo,x          
sm6a:           sbc square2.lo,x          
                sta _bb+1                 
sm7a:           lda square1.hi,x          
sm8a:           sbc square2.hi,x          
                sta _BB+1                 

                // Perform >T1 * >T2 = DDdd
                sec                       
sm5b:           lda square1.lo,x          
sm6b:           sbc square2.lo,x          
                sta _dd+1                 
sm7b:           lda square1.hi,x          
sm8b:           sbc square2.hi,x          
                sta PRODUCTHI2             

                // Add the separate multiplications together
                clc                                        
_AA:            lda #0                                     
_bb:            adc #0                                     
                sta PRODUCTLO2                              
_BB:            lda #0                                     
_CC:            adc #0                                     
                sta PRODUCTHI1                             
                bcc !+                                     
                    inc PRODUCTHI2                          
                    clc                                    
                !:                                          
_cc:            lda #0                                     
                adc PRODUCTLO2                            
                sta PRODUCTLO2                        
_dd:            lda #0                                     
                adc PRODUCTHI1                              
                sta PRODUCTHI1                      
                bcc !+                                     
                    inc PRODUCTHI2                          
                !:                                          

                rts
}


// Description: Signed 16-bit multiplication with signed 32-bit result.
//                                                                     
// Input: 16-bit signed value in T1                                    
//        16-bit signed value in T2                                    
//        Carry=0: Re-use T1 from previous multiplication (faster)     
//        Carry=1: Set T1 (slower)                                     
//                                                                     
// Output: 32-bit signed value in PRODUCT                              
//
// Clobbered: PRODUCT, X, A, C
multiply_16bit_signed:{

        .var T1LO = __tmp0                                        
        .var T1HI = __tmp1
        .var T2LO = __tmp2
        .var T2HI = __tmp3
        .var PRODUCTLO1 = __val0
        .var PRODUCTLO2 = __val1
        .var PRODUCTHI1 = __val2
        .var PRODUCTHI2 = __val3

        jsr multiply_16bit_unsigned

        // Apply sign (See C=Hacking16 for details).
        lda T1HI
        bpl !+
            sec
            lda PRODUCTHI1
            sbc T2LO
            sta PRODUCTHI1
            lda PRODUCTHI2
            sbc T2HI
            sta PRODUCTHI2
        !:
        lda T2HI
        bpl !+
            sec
            lda PRODUCTHI1
            sbc T1LO
            sta PRODUCTHI1
            lda PRODUCTHI2
            sbc T1HI
            sta PRODUCTHI2
        !:

        rts
}

*=$c000 "square1"
square1: .lohifill 512, ((i*i)/4)
*=* "square2"
square2: .lohifill 512, ((i-255)*(i-255)/4)

