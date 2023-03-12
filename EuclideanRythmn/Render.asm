#importonce
#import "_prelude.lib"
#import "Config.asm"

.const BLANK = 2
.const BLANK_SMALL = 144
.const PATTERN = 3
.const BEAT = 4

Character: .byte 204
PenColor: .byte GREEN

_voiceColor: .byte RED, GREEN, ORANGE, RED, GREEN, ORANGE, YELLOW
_voiceAltColor: .byte LIGHT_RED, LIGHT_GREEN, YELLOW, LIGHT_RED, LIGHT_GREEN, YELLOW, WHITE
_stepCounter: .byte 0

Render: {
    RenderPattern(CHANNEL_VOICE1, voice0_x, voice0_y, BLANK)
    RenderPattern(CHANNEL_VOICE2, voice1_x, voice1_y, BLANK)
    RenderPattern(CHANNEL_VOICE3, voice2_x, voice2_y, BLANK)

    RenderPatternSmall(CHANNEL_OCTAVE1, octave0_x, octave0_y)
    RenderPatternSmall(CHANNEL_OCTAVE2, octave1_x, octave1_y)
    RenderPatternSmall(CHANNEL_OCTAVE3, octave2_x, octave2_y)
    
    RenderPattern(CHANNEL_FILTER, filter_x, filter_y, BLANK_SMALL)

    RenderSelectedPattern(pattern_x, pattern_y, BLANK_SMALL)
    RenderTempo(tempo_x, tempo_y)

    RenderEcho()
    rts
}

.macro RenderEcho() {
    
    Set Character: #150
    Set PenColor: #DARK_GRAY

    lda _echoOn
    beq !+
        Set Character: #151
        Set PenColor: #GREEN
    !:

    Plot #25: #19
}

.macro RenderSelectedPattern(voice_x, voice_y, blank) {
    lda #0
    sta _stepCounter
    tax
    
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #CHANNEL_PATTERN
    bne !+
        ldy #CHANNEL_PATTERN
        Set PenColor:_voiceColor, Y
    !:

    render_pattern:
        ldy #CHANNEL_PATTERN
        // is this step a beat?
        lda #1
        // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
        asl;asl;asl;asl
        clc 
        adc _stepCounter
        adc _patternIndex
        tay

        lda _rhythm, Y
        beq rest

    pattern:
        Set Character:#PATTERN
        jmp next_step

    rest:
        Set Character:#blank

    next_step:
        Plot voice_x,X:voice_y,X
        inx
        inc _stepCounter
        lda _stepCounter
        cmp #steps
        bne render_pattern
}


.macro RenderPattern(voiceNumber, voice_x, voice_y, blank) {
    lda #0
    sta _stepCounter
    tax
    
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #voiceNumber
    bne !+
        ldy #voiceNumber
        Set PenColor:_voiceColor, Y
    !:

    render_pattern:
        ldy #voiceNumber
        // is this step a beat?
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
        asl;asl;asl;asl
        clc 
        adc _stepCounter
        adc _voiceRotation, Y
        tay

        lda _rhythm, Y
        beq rest

    pattern:
        Set Character:#PATTERN
        jmp next_step

    rest:
        Set Character:#blank

    next_step:
        Plot voice_x,X:voice_y,X
        inx
        inc _stepCounter
        lda _stepCounter
        cmp #steps
        bne render_pattern

    beat:
        ldx _stepIndex
        ldy #voiceNumber
        lda _voiceOn, Y
        beq !+
            Set PenColor:_voiceAltColor, Y
            Set Character:#BEAT
            Plot voice_x,X:voice_y,X
        !:
}

.macro RenderTempo(voice_x, voice_y) {
    // set pen color to unselected 
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #CHANNEL_TEMPO
    bne !+
        ldy #CHANNEL_TEMPO
        // or selected
        Set PenColor:_voiceColor, Y
    !:

    ldx #0
    Set _stepCounter:#0
    Set Character:#145

    render_pattern:
        // _tempo is 0 to $ff, where 0 is FULL ON and $ff is FULL OFF
        lda _tempoIndicator
        cmp _stepCounter
        bcs next_step

    pattern:
        Set Character:#BLANK_SMALL
        jmp next_step

    next_step:
        ldy _stepCounter
        Plot voice_x,X:voice_y,X
        inx
        inc _stepCounter
        lda _stepCounter
        cmp #steps
        bne render_pattern
}

.macro RenderPatternSmall(voiceNumber, voice_x, voice_y) {
    lda #0
    sta _stepCounter
    tax
    
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #voiceNumber
    bne !+
        ldy #voiceNumber
        Set PenColor:_voiceColor, Y
    !:

    render_pattern:
        ldy #voiceNumber
        // is this step a beat?
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
        asl;asl;asl;asl
        clc 
        adc _stepCounter
        adc _voiceRotation, Y
        tay

        lda _rhythm, Y
        beq rest

    pattern:
        ldy _stepCounter
        Set Character:pattern_small_char,Y
        jmp next_step

    rest:
        ldy _stepCounter
        Set Character:blank_small_char,Y

    next_step:
        Plot voice_x,X:voice_y,X
        inx
        inc _stepCounter
        lda _stepCounter
        cmp #steps
        bne render_pattern

    beat:
        ldx _stepIndex
        ldy #voiceNumber
        lda _voiceOn, Y
        beq !+
            Set PenColor:_voiceAltColor, Y
            ldy _stepCounter
            Set Character:beat_small_char,X
            Plot voice_x,X:voice_y,X
        !:
}

.pseudocommand Plot x:y {
    .var screenLO = __tmp0 
    .var screenHI = __tmp1

    txa;pha;
   
    Set __tmp3:y
    // annoyingly backwards "x is Y" due to indirect indexing below
    ldy x
    ldx __tmp3

    clc
    lda screenRow.lo,X  
    sta screenLO

    lda screenRow.hi,X
    ora #$04 
    sta screenHI

    lda Character
    sta (screenLO),Y  

    // set color ram
    lda screenRow.hi,X
    // ora is nice then to set the memory page
    ora #$D8 
    sta screenHI

    lda PenColor
    sta (screenLO),Y  

    pla;tax
}

screenRow: .lohifill 25, 40*i

blank_small_char:   .byte 142,143,159,175,174,173,157,141
pattern_small_char: .byte 187,188,204,220,219,218,202,186
beat_small_char:    .byte 190,191,207,223,222,221,205,189

voice0_x:   .byte 09,11,12,11,09,07,06,07,09,11,12,11,09,07,06,07
voice0_y:   .byte 12,13,15,17,18,17,15,13,12,13,15,17,18,17,15,13

voice1_x:   .byte 09,13,14,13,09,05,04,05,09,13,14,13,09,05,04,05
voice1_y:   .byte 10,11,15,19,20,19,15,11,10,11,15,19,20,19,15,11

voice2_x:   .byte 09,15,16,15,09,03,02,03,09,15,16,15,09,03,02,03
voice2_y:   .byte 08,09,15,21,22,21,15,09,08,09,15,21,22,21,15,09

pattern_x:    .byte 33,35,36,35,33,31,30,31,33,35,36,35,33,31,30,31
pattern_y:    .byte 16,17,19,21,22,21,19,17,16,17,19,21,22,21,19,17

tempo_x:    .byte 25,23,22,23,25,27,28,27
tempo_y:    .byte 22,21,19,17,16,17,19,21

filter_x:   .byte 25,27,28,27,25,23,22,23,25,27,28,27,25,23,22,23
filter_y:   .byte 06,07,09,11,12,11,09,07,06,07,09,11,12,11,09,07

octave0_x:  .byte 31,32,32,32,31,30,30,30,31,32,32,32,31,30,30,30
octave0_y:  .byte 07,07,08,09,09,09,08,07,07,07,08,09,09,09,08,07

octave1_x:  .byte 35,36,36,36,35,34,34,34,35,36,36,36,35,34,34,34
octave1_y:  .byte 07,07,08,09,09,09,08,07,07,07,08,09,09,09,08,07

octave2_x:  .byte 33,34,34,34,33,32,32,32,33,34,34,34,33,32,32,32
octave2_y:  .byte 10,10,11,12,12,12,11,10,10,10,11,12,12,12,11,10