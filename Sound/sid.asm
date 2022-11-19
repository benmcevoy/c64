#importonce

.namespace Sound {

    .const TEMPO = 6

    // point to chip
    .const SID_ACTUAL = $D400
    // point to framebuffer
    .const SID        = $4000
    // reserve space for "frame buffer"
    .pseudopc SID { .fill 37,0 }

    .const VOICE1 = 0
    .const VOICE2 = 1
    .const VOICE3 = 2
    .const MIX = 3

    // voice
    .const FREQ_LO = 0
    .const FREQ_HI = 1
    .const PW_LO = 2
    .const PW_HI = 3
    
    /* MSB Noise, Square, Saw, Triangle, Disable/Reset, Ring, Sync, Trigger LSB  */
    .const CONTROL = 4
    
    .const ATTACK_DECAY = 5
    .const SUSTAIN_RELEASE = 6

    // mix
    /* Low bits 0-2 only */
    .const FILTER_CUT_OFF_LO = 0
    .const FILTER_CUT_OFF_HI = 1
    /* MSB Resonance3, Resonance2, Resonance1, Resonance0, Ext voice filtered, v3 filter, v2 filter, v1 filter LSB */
    .const FILTER_CONTROL = 2
    /* MSB v3 disable, High pass filter, band pass filter, low pass filter, volume3, volume2, volume1, volume0 LSB */
    .const VOLUME = 3

    // extras for the voice
    // laid out like v1Tune, v2Tune, v3Tune, v1Duration, v2Duration, v3Duration, etc
    // 
    .const TUNE = 25  
    .const DURATION = 28 
    // pointer to instrument
    .const INSTRUMENT_LO = 31
    .const INSTRUMENT_HI = 34

    freq_msb:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
    .byte $02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05,$06,$06
    .byte $06,$07,$07,$08,$08,$09,$09,$0a,$0a,$0b,$0c,$0d,$0d,$0e,$0f,$10
    .byte $11,$12,$13,$14,$15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$27,$29
    .byte $2b,$2e,$31,$34,$37,$3a,$3e,$41,$45,$49,$4e,$52,$57,$5c,$62,$68

    freq_lsb:
    .byte $6e,$75,$7c,$83,$8b,$93,$9c,$a5,$af,$b9,$c4,$d0,$dd,$ea,$f8,$07
    .byte $16,$27,$39,$4b,$5f,$74,$8a,$a1,$ba,$d4,$f0,$0e,$2d,$4e,$71,$96
    .byte $be,$e7,$14,$42,$74,$a9,$e0,$1b,$5a,$9c,$e2,$2d,$7b,$cf,$27,$85
    .byte $e8,$51,$c1,$37,$b4,$38,$c4,$59,$f7,$9d,$4e,$0a,$d0,$a2,$81,$6d
    .byte $67,$70,$89,$b2,$ed,$3b,$9c,$13,$a0,$45,$02,$da,$ce,$e0,$11,$64
    .byte $da,$76,$39,$26,$40,$89,$04,$b4,$9c,$c0,$23,$c8,$b4,$eb,$72,$4c
    .byte $80,$12,$08,$68,$39,$80,$45,$90,$68,$d6,$e3,$99,$00,$24,$10

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