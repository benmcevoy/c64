#importonce
#import "_prelude.lib"

.namespace Tempo {
    OnBeat: {
        inc $d021

        rts
    }

    Init: {
        // set raster irq line number
        lda    #0
        sta    $d012
        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019
        
        dec _frameCounter
        bne !+
            lda _frameInterval
            sta _frameCounter

            jsr OnBeat
        !: 

        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 50
    _frameInterval: .byte 50
}

