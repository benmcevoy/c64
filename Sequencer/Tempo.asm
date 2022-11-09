#importonce
#import "_prelude.lib"

.namespace Tempo {
    Init: {
        rts
    }

    OnBeat: {
        inc $d021
        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019
        // set next irq line number
        // this could run at 100Hz or whatever you can fit in.
        // could be clc;adc #n lines to $d012
        // lda    #100
        // sta    $d012

        jsr DoWork

        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    DoWork:{

        // executes every frame or 1/50th of a second
        // start with a 60bpm
        // change screen colour

        // 60bpm is how many frames? 50 frames, duh

        dec _frameCounter
        bne !+
            lda _frameInterval
            sta _frameCounter

            jsr OnBeat
        !: 

        rts
        _frameCounter: .byte 20
        _frameInterval: .byte 20
    }

}

