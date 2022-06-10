#importonce
#import "sid.asm"

.namespace Sound {

    // PW is 12 bits, so only low nibble of PW_HI is used
    // pw_low, pw_hi, control, AD, SR, tune
    piano: .byte  $00, $00, %00010000, $4B, $04, 0
    piano2: .byte  $00, $00, %00100000, $4b, $04, 0 
    bass: .byte  $80, $09, %01000000, $06, $0F, 0

    saw: .byte  $80, $09, %00100000, $00, $81, 0
    sawDetune: .byte  $80, $09, %00110000, $00, $F1, 3

    .macro SetInstrument (voiceNumber, instrument) {
        ldx #0
        loop:
            lda instrument,X
            sta SID+voiceNumber*7+PW_LO, X
            inx
            cpx #5
            bne loop

        lda instrument,X
        sta SID+TUNE+voiceNumber
        
        lda #TEMPO
        sta SID+DURATION+voiceNumber

        lda #<instrument
        sta SID+INSTRUMENT_LO+voiceNumber
        lda #>instrument
        sta SID+INSTRUMENT_HI+voiceNumber
    }
}