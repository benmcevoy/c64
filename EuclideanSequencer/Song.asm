#importonce
#import "Config.asm"


/* SONG DATA */
// number of beats, rotation, transpose, instrument, ttl
osc1_pattern:       .byte 6,5,0,0,8, 3,2,0,0,8, $FF
osc2_pattern:       .byte 4,5,0,0,1, $FF
osc3_pattern:       .byte 3,5,0,0,1, $FF
filter_pattern:     .byte 2,2,0,0,32, 3,2,0,0,32, 4,2,0,0,16, 6,2,0,0,8, 3,2,0,0,16, $FF    
accent1_pattern:    .byte 2,2,0,0,1, $FF
accent2_pattern:    .byte 3,2,0,0,1, $FF
accent3_pattern:    .byte 1,2,0,0,1, $FF
chord_pattern:      .byte 0,0,0,0,32, 1,0,0,0,16, 2,0,0,0,16, $FF
tempo_pattern:      .byte 5,0,0,0,1, $FF




/* **************** Macros *************** */
.macro ReadSong() {
    Next(OSCILLATOR1, osc1_pattern)
    Next(OSCILLATOR2, osc2_pattern)
    Next(OSCILLATOR3, osc3_pattern)
    Next(FILTER, filter_pattern)
    Next(ACCENT1, accent1_pattern)
    Next(ACCENT2, accent2_pattern)
    Next(ACCENT3, accent3_pattern)
    Next(CHORD, chord_pattern)
    Next(TEMPO, tempo_pattern)    

    dec _voicePatternTTL + OSCILLATOR1
    dec _voicePatternTTL + OSCILLATOR2
    dec _voicePatternTTL + OSCILLATOR3
    dec _voicePatternTTL + FILTER
    dec _voicePatternTTL + ACCENT1
    dec _voicePatternTTL + ACCENT2    
    dec _voicePatternTTL + ACCENT3
    dec _voicePatternTTL + CHORD
    dec _voicePatternTTL + TEMPO
}

.macro Next(voiceNumber, pattern) {
    ldy #voiceNumber
    lda _voicePatternIndex, Y
    tax
    lda pattern, X
    cmp #$FF
    bne !+
        lda #0
        sta _voicePatternIndex, Y
    !:

    ldx _voicePatternTTL, Y
    bne !+
        SetState(pattern)
    !:
}

.macro SetIndex(parameter) {
    lda _voicePatternIndex, Y
    clc; adc #parameter
    tax
}

.macro SetState(pattern) { 
    SetIndex(VOICE_NUMBER_OF_BEATS)
    lda pattern, X
    sta _voiceNumberOfBeats,Y

    SetIndex(VOICE_ROTATION)
    lda pattern, X
    sta _voiceRotation,Y
    
    SetIndex(VOICE_TTL)
    lda pattern, X
    sta _voicePatternTTL,Y

    lda _voicePatternIndex, Y
    clc; adc #STRIDE
    sta _voicePatternIndex, Y
}
