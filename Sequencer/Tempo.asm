#importonce
#import "_prelude.lib"
#import "Sid.asm"
#import "_debug.lib"

.namespace Tempo {

    Init: {
        // set raster irq line number
        lda    #0
        sta    $d012

        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#$FF
        Set SID_MIX_FILTER_CONTROL:#%11110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_FREQ_LO:#$E8 
        Set SID_V1_FREQ_HI:#$06
        Set SID_V1_PW_LO:#$00
        Set SID_V1_PW_HI:#$00
        Set SID_V1_ATTACK_DECAY:#$0A
        Set SID_V1_SUSTAIN_RELEASE:#$00

        Set SID_V2_FREQ_LO:#$E8 
        Set SID_V2_FREQ_HI:#$06
        Set SID_V2_PW_LO:#$00
        Set SID_V2_PW_HI:#$00
        Set SID_V2_ATTACK_DECAY:#$0A
        Set SID_V2_SUSTAIN_RELEASE:#$00

        Set SID_V3_FREQ_LO:#$E8 
        Set SID_V3_FREQ_HI:#$06
        Set SID_V3_PW_LO:#$00
        Set SID_V3_PW_HI:#$00
        Set SID_V3_ATTACK_DECAY:#$0A
        Set SID_V3_SUSTAIN_RELEASE:#$00

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019

        dec _frameCounter
        bne nextFrame

        MCopy _frameInterval:_frameCounter

        lda _voiceIndex
        tay

        ldx _stepIndex
        lda _sequence, X

        // skip REST
        beq !+

        // set tone
        tax
        lda     freq_msb,x
        sta     SID_V1_FREQ_HI, Y  
        lda     freq_lsb,x
        sta     SID_V1_FREQ_LO, Y

        // trigger on
        lda  #%00010000
        sta SID_V1_CONTROL, Y
        lda  #%00010001
        sta SID_V1_CONTROL, Y
        
        // round robin voice
        lda _voiceIndex
        clc; adc #7
        sta _voiceIndex
        cmp #21
        bne !+
            Set _voiceIndex:#0
        !:

        inc _stepIndex
        lda _stepIndex
        cmp _steps
        bne !+
            Set _stepIndex:#0
        !:

    nextFrame:
        
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 1
    _frameInterval: .byte 10

    _voiceIndex: .byte 0
    _steps: .byte 8
    _stepIndex: .byte 0
    
    _sequence: .byte C2, C3, Eb2, Eb3, F3, F2, G3, G2,     C2, C3, E2, E3, F3, F2, G3, G2
    //_sequence: .byte E2, G2, A3, G2, D3, C3, D3, E3
    //_sequence: .byte E2,E3,E2,REST,D3,E2,REST,G3
    //_sequence: .byte C2,E2,G2,E2,F2,G2,E2,G2
    //_sequence: .byte        B2,E2,G2,E2,F2,G2,E2,G2,A2,E2,G2,E2,F2,G2,E2,G2
}

    