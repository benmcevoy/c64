#importonce
#import "_prelude.lib"
#import "Config.asm"
#import "Sid.asm"

.const BLANK = 2
.const BLANK_SMALL = 144
.const PATTERN = 3
.const BEAT = 4

Character: .byte 204
PenColor: .byte GREEN

_selectedColor: .byte GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN, GREEN
_beatColor: .byte LIGHT_GREEN, LIGHT_GREEN, LIGHT_GREEN, LIGHT_GREEN, LIGHT_GREEN, LIGHT_GREEN, LIGHT_GREEN, LIGHT_GREEN
_stepCounter: .byte 0

Render: {
    RenderPattern(CHANNEL_VOICE1, voice0_x, voice0_y, BLANK)
    RenderPattern(CHANNEL_VOICE2, voice1_x, voice1_y, BLANK)
    RenderPattern(CHANNEL_VOICE3, voice2_x, voice2_y, BLANK)
    RenderPatternSmall(CHANNEL_OCTAVE1, octave0_x, octave0_y)
    RenderPatternSmall(CHANNEL_OCTAVE2, octave1_x, octave1_y)
    RenderPatternSmall(CHANNEL_OCTAVE3, octave2_x, octave2_y)
    RenderSelectedPattern(pattern_x, pattern_y, BLANK_SMALL)

    RenderTempo(tempo_x, tempo_y)
    RenderEcho()
    RenderCopy()
    RenderPaste()
    RenderPattern(CHANNEL_FILTER, filter_x, filter_y, BLANK_SMALL)

    RenderJoy()
    rts
}

.macro RenderJoy(){

    lda _frameCounter
    beq !+
        jmp exit
    !:

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #0:#0:__tmp2
    inc joy_palette_index

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #0:#1:__tmp2
    inc joy_palette_index

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #0:#2:__tmp2
    inc joy_palette_index

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #1:#0:__tmp2
    inc joy_palette_index

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #1:#1:__tmp2
    inc joy_palette_index

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #1:#2:__tmp2
    inc joy_palette_index

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #2:#0:__tmp2
    inc joy_palette_index

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #2:#1:__tmp2
    inc joy_palette_index

    ldy joy_palette_index
    Set __tmp2:_randomJoy,Y
    PlotColor #2:#2:__tmp2
    inc joy_palette_index
    
exit:
}

.macro RenderCopy() {
    lda _selectedVoice
    cmp #CHANNEL_COPY
    beq on        
    jmp off

    on:
        PlotColor #31: #23: #GREEN
        PlotColor #32: #23: #GREEN
        jmp end  
    !:

    off:
        PlotColor #31: #23: #GREY
        PlotColor #32: #23: #GREY
    end:
}

.macro RenderPaste() {
    lda _selectedVoice
    cmp #CHANNEL_PASTE
    beq on        
    jmp off

    on:
        PlotColor #34: #23: #GREEN
        PlotColor #35: #23: #GREEN
        PlotColor #36: #23: #GREEN
        jmp end  
    !:

    off:
        PlotColor #34: #23: #GREY
        PlotColor #35: #23: #GREY
        PlotColor #36: #23: #GREY
    end:
}

.macro RenderEcho() {
    lda _selectedVoice
    cmp #CHANNEL_ECHO
    beq on        
    jmp off

on:
        PlotColor #26: #23: #GREEN
        PlotColor #27: #23: #GREEN
        jmp endSelected  

off:
        PlotColor #26: #23: #GREY
        PlotColor #27: #23: #GREY

endSelected:

    lda _echoOn
    beq !+
        PlotColor #24: #23: #GREEN
        PlotColor #25: #23: #GREEN
        jmp endEchoOn
    !:

    PlotColor #24: #23: #GREY
    PlotColor #25: #23: #GREY
endEchoOn:
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
        Set PenColor:_selectedColor, Y
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
    .var voiceNumberOfBeats = _beatPatterns + (voiceNumber*8)
    .var voiceRotation = _rotationPatterns + (voiceNumber*8)

    lda #0
    tax
    sta _stepCounter
    
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #voiceNumber
    bne !+
        // this is the currently selected voice
        ldy #voiceNumber
        Set PenColor:_selectedColor, Y
    !:

    render_pattern:
        ldy _patternIndex
        // is this step a beat?
        lda voiceNumberOfBeats, Y
        // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
        asl;asl;asl;asl
        clc 
        adc _stepCounter
        adc voiceRotation, Y
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
        ldy #voiceNumber
        lda _voiceOn, Y
        beq !+
            ldx _stepIndex        
            Set PenColor:_beatColor, Y
            Set Character:#BEAT
            Plot voice_x,X:voice_y,X
        !:
}

.macro RenderPatternSmall(voiceNumber, voice_x, voice_y) {
    .var voiceNumberOfBeats = _beatPatterns + (voiceNumber*8)
    .var voiceRotation = _rotationPatterns + (voiceNumber*8)

    lda #0
    sta _stepCounter
    tax
    
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #voiceNumber
    bne !+
        ldy #voiceNumber
        Set PenColor:_selectedColor, Y
    !:

    render_pattern:
        ldy _patternIndex
        // is this step a beat?
        lda voiceNumberOfBeats, Y
        // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
        asl;asl;asl;asl
        clc 
        adc _stepCounter
        adc voiceRotation, Y
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
        ldy #voiceNumber
        lda _voiceOn, Y
        beq !+
            ldx _stepIndex
            Set PenColor:_beatColor, Y
            Set Character:beat_small_char,X
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
        Set PenColor:_selectedColor, Y
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

.pseudocommand PlotColor x:y:color {
    .var screenLO = __tmp0 
    .var screenHI = __tmp1

    // annoyingly backwards "x is Y" due to indirect indexing below
    ldy x
    ldx y

    clc
    lda screenRow.lo,X  
    sta screenLO

    lda screenRow.hi,X
    ora #$04 
    sta screenHI
    
    // set color ram
    lda screenRow.hi,X
    // ora is nice then to set the memory page
    ora #$D8 
    sta screenHI

    lda color
    sta (screenLO),Y  
}

screenRow: .lohifill 25, 40*i

blank_small_char:   .byte 142,143,159,175,174,173,157,141
pattern_small_char: .byte 187,188,204,220,219,218,202,186
beat_small_char:    .byte 190,191,207,223,222,221,205,189

joy_palette_index: .byte 0

voice0_x:   .byte 09,11,12,11,09,07,06,07,09,11,12,11,09,07,06,07
voice0_y:   .byte 10,11,13,15,16,15,13,11,10,11,13,15,16,15,13,11

voice1_x:   .byte 09,13,14,13,09,05,04,05,09,13,14,13,09,05,04,05
voice1_y:   .byte 08,09,13,17,18,17,13,09,08,09,13,17,18,17,13,09

voice2_x:   .byte 09,15,16,15,09,03,02,03,09,15,16,15,09,03,02,03
voice2_y:   .byte 06,07,13,19,20,19,13,07,06,07,13,19,20,19,13,07

pattern_x:  .byte 33,35,36,35,33,31,30,31,33,35,36,35,33,31,30,31
pattern_y:  .byte 14,15,17,19,20,19,17,15,14,15,17,19,20,19,17,15

// this is in a different order, first entry is the bottom of the circle, goes clockwise
tempo_x:    .byte 25,23,22,23,25,27,28,27
tempo_y:    .byte 20,19,17,15,14,15,17,19

filter_x:   .byte 25,27,28,27,25,23,22,23,25,27,28,27,25,23,22,23
filter_y:   .byte 04,05,07,09,10,09,07,05,04,05,07,09,10,09,07,05

octave0_x:  .byte 31,32,32,32,31,30,30,30,31,32,32,32,31,30,30,30
octave0_y:  .byte 05,05,06,07,07,07,06,05,05,05,06,07,07,07,06,05

octave1_x:  .byte 35,36,36,36,35,34,34,34,35,36,36,36,35,34,34,34
octave1_y:  .byte 05,05,06,07,07,07,06,05,05,05,06,07,07,07,06,05

octave2_x:  .byte 33,34,34,34,33,32,32,32,33,34,34,34,33,32,32,32
octave2_y:  .byte 08,08,09,10,10,10,09,08,08,08,09,10,10,10,09,08