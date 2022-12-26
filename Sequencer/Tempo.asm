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
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#$80
        Set SID_MIX_FILTER_CONTROL:#%11110111
        Set SID_MIX_VOLUME:#%00011111

        InitInstrument()

        LoadInstrument(0, boring_square1)
        LoadInstrument(1, boring_square2)
        LoadInstrument(2, boring_square3)

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019

        dec _frameCounter
        beq !+
            jmp nextFrame
        !:

    nextStep:
        MCopy _frameInterval:_frameCounter

        ldx _stepIndex
        lda _sequence, X

        sta voices_ReferenceNoteNumber
        sta voices_ReferenceNoteNumber+1
        sta voices_ReferenceNoteNumber+2

        // skip REST
        beq !+

        // set tone
        tax
        lda     freq_msb,x
        sta     SID_V1_FREQ_HI
        lda     freq_lsb,x
        sta     SID_V1_FREQ_LO
        
        
        txa;sec;sbc #12;tax
        lda     freq_msb,x
        sta     SID_V2_FREQ_HI
        sta     SID_V3_FREQ_HI
        
        lda     freq_lsb,x
        sbc #2
        sta     SID_V2_FREQ_LO
        sbc #3
        sta     SID_V3_FREQ_LO
        
        inc _stepIndex
        lda _stepIndex
        cmp _steps
        bne !+
            Set _stepIndex:#0
        !:

    nextFrame:
        UpdateInstrument(0, boring_square1)
        UpdateInstrument(1, boring_square2)
        UpdateInstrument(2, boring_square3)
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 1
    _frameInterval: .byte 10

    _steps: .byte 8
    _stepIndex: .byte 0
    
    _sequence: .byte C2, C3, Eb2, Eb3, F3, F2, G3, G2
}
    