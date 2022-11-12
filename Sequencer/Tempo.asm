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
            lda _filter
            cmp #$A0
            beq !+
                inc _filter
            !:
        !:

        lda #DOWN
        bit PORT2
        bne !++
            lda _filter
            cmp #1
            beq !+
                dec _filter
            !:
        !:

        Set SID_MIX_FILTER_CUT_OFF_HI:_filter

        rts
    }

    Init: {
        // set raster irq line number
        lda    #0
        sta    $d012

        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:_filter
        Set SID_MIX_FILTER_CONTROL:#%11110001
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_FREQ_LO:#$E8 
        Set SID_V1_FREQ_HI:#$06
        Set SID_V1_PW_LO:#$00
        Set SID_V1_PW_HI:#$00
        Set SID_V1_ATTACK_DECAY:#$0A
        Set SID_V1_SUSTAIN_RELEASE:#$00

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019

        dec _frameCounter
        bne !++
            MCopy _frameInterval:_frameCounter

            inc $d020
            inc $d021

            ldx _stepIndex
            lda _sequence, X

            // set tone
            tax
            lda     freq_msb,x
            sta     SID_V1_FREQ_HI  
            lda     freq_lsb,x
            sta     SID_V1_FREQ_LO

            // trigger on
            Set SID_V1_CONTROL:#%00100000
            Set SID_V1_CONTROL:#%00100001

            inc _stepIndex
            lda _stepIndex
            cmp _steps
            bne !+
                Set _stepIndex:#0
            !:
        !: 

        jsr ReadJoystick

        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 1
    _frameInterval: .byte 50

    _steps: .byte 8
    _stepIndex: .byte 0

    _sequence: .byte C2, C3, Eb2, Eb3, F3, F2, G3, G2
    _filter: .byte 17
}
