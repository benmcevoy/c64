#importonce
#import "_prelude.lib"
#import "Sid.asm"
#import "_debug.lib"

.namespace Tempo {
    .const NOTEDURATION = 20
    .const BEATINTERVAL = 40

    OnBeat: {
        inc $d021

        // 1. Metronome, call Trigger() and play sound with release only
        // 2. change BPM via input
        // 3. step sequencer - c2, c3, D#2/Eb2, D#3/Eb3, f3, f2, g3, g2



        // trigger on
        lda SID_V1_CONTROL
        ora #%00000001
        sta SID_V1_CONTROL

        MCopy _noteHold:_noteHoldCounter

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
        Set SID_V1_ATTACK_DECAY:#$00
        Set SID_V1_SUSTAIN_RELEASE:#$A1

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

            jsr OnBeat
        !: 

        dec _noteHoldCounter
        
        bne !+
            // trigger off
            lda SID_V1_CONTROL
            and #%11111110
            sta SID_V1_CONTROL
        !:

        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 50
    _frameInterval: .byte 30
    
    _noteHoldCounter: .byte 20
    _noteHold: .byte 10
}

