#importonce
#import "_prelude.lib"
#import "Sid.asm"
#import "_debug.lib"

.namespace Tempo {

    ReadJoystick: {
        .const PORT2 = $dc00
        .const UP      = %00000001
        .const DOWN    = %00000010
        .const LEFT    = %00000100
        .const RIGHT   = %00001000
        .const FIRE    = %00010000        

        // left
        lda #LEFT
        bit PORT2
        bne !++
            lda _frameInterval
            cmp #1
            beq !+
                dec _frameInterval
            !:
        !:

        lda #RIGHT
        bit PORT2
        bne !++
            lda _frameInterval
            cmp #$ff
            beq !+
                inc _frameInterval
            !:
        !:

        lda #UP
        bit PORT2
        bne !++
            lda _scaleIndex
            cmp #7
            beq !+
                inc _scaleIndex
            !:
        !:

        lda #DOWN
        bit PORT2
        bne !++
            lda _scaleIndex
            cmp #0
            beq !+
                dec _scaleIndex
            !:
        !:

        //Set SID_MIX_FILTER_CUT_OFF_HI:_filter

        rts
    }

    Init: {
        // set raster irq line number
        lda    #0
        sta    $d012

        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:_filter
        Set SID_MIX_FILTER_CONTROL:#%11110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_FREQ_LO:#$E8 
        Set SID_V1_FREQ_HI:#$0
        Set SID_V1_PW_LO:#$00
        Set SID_V1_PW_HI:#$00
        Set SID_V1_ATTACK_DECAY:#$4b
        Set SID_V1_SUSTAIN_RELEASE:#$04

        Set SID_V2_FREQ_LO:#$E8 
        Set SID_V2_FREQ_HI:#$06
        Set SID_V2_PW_LO:#$00
        Set SID_V2_PW_HI:#$00
        Set SID_V2_ATTACK_DECAY:#$4b
        Set SID_V2_SUSTAIN_RELEASE:#$04

        Set SID_V3_FREQ_LO:#$E8 
        Set SID_V3_FREQ_HI:#$06
        Set SID_V3_PW_LO:#$00
        Set SID_V3_PW_HI:#$00
        Set SID_V3_ATTACK_DECAY:#$4b
        Set SID_V3_SUSTAIN_RELEASE:#$04

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019

        dec _frameCounter
        beq  !+
            jmp nextFrame
        !:

        MCopy _frameInterval:_frameCounter

        inc $d020
        inc $d021

        lda _voice
        cmp #2
        bne !+
            ldx _stepIndex
            lda _sequence, X

            // skip REST
            beq !+

            sta __tmp0

            ldx _scaleIndex
            lda _scale, X

            clc
            adc __tmp0

            // set tone
            tax
            lda     freq_msb,x
            sta     SID_V1_FREQ_HI  
            lda     freq_lsb,x
            sta     SID_V1_FREQ_LO

            // trigger on
            Set SID_V1_CONTROL:#%00100000
            Set SID_V1_CONTROL:#%00100001

            jmp nextStep
        !:

        lda _voice
        cmp #1
        bne !+
            ldx _stepIndex
            lda _sequence, X

            beq !+

            sta __tmp0

            ldx _scaleIndex
            lda _scale, X

            clc
            adc __tmp0

            // set tone
            tax
            lda     freq_msb,x
            sta     SID_V2_FREQ_HI  
            lda     freq_lsb,x
            sta     SID_V2_FREQ_LO

            // trigger on
            Set SID_V2_CONTROL:#%00100000
            Set SID_V2_CONTROL:#%00100001
            jmp nextStep
        !:

        ldx _stepIndex
        lda _sequence, X
        
        beq nextStep

        sta __tmp0

        ldx _scaleIndex
        lda _scale, X

        clc
        adc __tmp0

        // set tone
        tax
        lda     freq_msb,x
        sta     SID_V3_FREQ_HI  
        lda     freq_lsb,x
        sta     SID_V3_FREQ_LO

        // trigger on
        Set SID_V3_CONTROL:#%00100000
        Set SID_V3_CONTROL:#%00100001

    nextStep:    
        inc _voice
        cmp #3
        bne !+
            Set _voice:#0
        !:

        inc _stepIndex
        lda _stepIndex
        cmp _steps
        bne !+
            Set _stepIndex:#0
        !:

    nextFrame:

        dec _readInputInterval
        bne !+
            jsr ReadJoystick
            Set _readInputInterval:#15
        !:
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 1
    _frameInterval: .byte 10
    _readInputInterval: .byte 15

    _steps: .byte 8
    _stepIndex: .byte 0

    //_sequence: .byte C2, C3, Eb2, Eb3, F3, F2, G3, G2,     C2, C3, E2, E3, F3, F2, G3, G2
    //_sequence: .byte E2, G2, A3, G2, D3, C3, D3, E3
    
    _sequence: .byte E2,E3,E2,REST,D3,E2,REST,G3

    _filter: .byte 8

    _scaleIndex: .byte 0
    _scale: .byte 12,5,10,11,12,5,10,11

    _voice: .byte 0
}
