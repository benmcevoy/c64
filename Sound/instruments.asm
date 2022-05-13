#importonce
#import "sid.asm"

.namespace Sound {


    // pw_low, pw_hi, control, AD, SR, sustain duration
    instrument0: .byte  $00, $40, %00110000, $40, $AA, $09
    instrument1: .byte  $00, $00, %00010010, $20, $88, $0A
    bassInstrument: .byte  $00, $20, %01110000, $00, $6A, $06

    .macro SetInstrument (voiceNumber, instrument) {
        ldx #0
        loop:
            lda instrument,X
            sta SID+voiceNumber*7+PW_LO, X
            inx
            cpx #5
            bne loop

        lda instrument,X
        // sustain duration
        sta SID+SUSTAIN_DURATION+voiceNumber
    }

}