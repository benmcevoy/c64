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
        bne !+
            dec _frameInterval
        !:

        lda #RIGHT
        bit PORT2
        bne !+
            inc _frameInterval
        !:

        rts
    }

    Init: {
        // set raster irq line number
        lda    #0
        sta    $d012

        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111
        Set SID_MIX_FILTER_CUT_OFF_HI:#%00001111
        Set SID_MIX_FILTER_CONTROL:#%00000000
        Set SID_MIX_VOLUME:#%00001111

        Set SID_V1_FREQ_LO:#$E8 
        Set SID_V1_FREQ_HI:#$06
        Set SID_V1_PW_LO:#$00
        Set SID_V1_PW_HI:#$00
        Set SID_V1_ATTACK_DECAY:#$07
        Set SID_V1_SUSTAIN_RELEASE:#$00

        Set SID_V1_CONTROL:#%00010000

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019

        dec _frameCounter
        bne !+
            MCopy _frameInterval:_frameCounter

            inc $d020
            inc $d021

            // trigger on
            Set SID_V1_CONTROL:#%00010000
            Set SID_V1_CONTROL:#%00010001
        !: 

        jsr ReadJoystick

        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 1
    _frameInterval: .byte 50
}
