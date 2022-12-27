#importonce
#import "_prelude.lib"
#import "Sid.asm"
#import "Instruments.asm"


.namespace Tempo {

    Init: {
        // set raster irq line number
        lda    #0
        sta    $d012

        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#$00  
        Set SID_MIX_FILTER_CUT_OFF_HI:#$80
        Set SID_MIX_FILTER_CONTROL:#%11110011
        Set SID_MIX_VOLUME:#%10011111

        LoadPatch(0, boring_square)
        LoadPatch(1, boring_square)
        LoadPatch(2, lfo)

        // lfo cycle
        lda #0
        sta SID_V3_FREQ_HI
        lda #$04
        sta SID_V3_FREQ_LO

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019

        
inc $d020
        dec _frameCounter
        beq !+
            jmp nextFrame
        !:

    nextStep:
        MCopy _frameInterval:_frameCounter

        ldx _stepIndex
        lda _sequence, X

        // skip REST
        beq !+

        // set tone
        tax
        lda     freq_msb,x
        sta     SID_V1_FREQ_HI
        lda     freq_lsb,x
        sta     SID_V1_FREQ_LO
        
        // octave lower
        txa;sec;sbc #12;tax
        lda     freq_msb,x
        sta     SID_V2_FREQ_HI
        lda     freq_lsb,x
        clc;adc#3
        sta     SID_V2_FREQ_LO
        
        // retrigger oscillator 3
        lda #%00010000
        sta SID_V3_CONTROL
        lda #%00010001
        sta SID_V3_CONTROL
    !:    
        inc _stepIndex
        lda _stepIndex
        cmp _steps
        bne !+
            Set _stepIndex:#0
        !:

    nextFrame:
        UpdateModulation()
        dec $d020
        // end irq
        // pla;tay;pla;tax;pla
        // rti          
         jmp $EA31   
    }

    _frameCounter: .byte 1
    _frameInterval: .byte 6

    _steps: .byte 8
    _stepIndex: .byte 0
    
    _sequence: 
    //.byte C2, C3, Eb2, Eb3, F3, F2, G3, G2
    .byte E2, E3, E2, REST, D3, E2, REST, G3
    .byte F2, F2, F2,F2,C2, REST,Eb2,REST
    //.byte A3,A4,C4,A3, A4,C4,A3,C4
    //.byte A3,A4,A3,A3, A5,A3,A5,A3
}
    
