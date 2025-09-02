#importonce
#import "_prelude.lib"
#import "Config.asm"
#import "Sid.asm"

.const BLANK = 2
.const BLANK_SMALL = 144
.const PATTERN = 3
.const BEAT = 4
.const SelectedColor = GREEN
.const BeatColor = LIGHT_GREEN
.const ChordColor = LIGHT_RED

// TODO: this was the old colour scheme and I think it was cooler
_voiceColor: .byte RED, GREEN, BLUE, YELLOW
_voiceAltColor: .byte LIGHT_RED, LIGHT_GREEN, CYAN, YELLOW

Character: .byte 204
PenColor: .byte GREEN
// the "dot" we are rendering
_stepCounter: .byte 0

Render: {
    // TODO: there is a bug here, flickering
    // can't work it out.
    
    RenderPattern(CHANNEL_FILTER, filter_x, filter_y, BLANK_SMALL)

    RenderPattern(CHANNEL_VOICE1, voice0_x, voice0_y, BLANK)
    RenderPattern(CHANNEL_VOICE2, voice1_x, voice1_y, BLANK)
    RenderPattern(CHANNEL_VOICE3, voice2_x, voice2_y, BLANK)
    
    RenderPatternSmall(CHANNEL_OCTAVE1, octave0_x, octave0_y)
    RenderPatternSmall(CHANNEL_OCTAVE2, octave1_x, octave1_y)
    RenderPatternSmall(CHANNEL_OCTAVE3, octave2_x, octave2_y)
    
    // TODO: RenderChord should render like tempo - like a volume knob
    RenderChord(meter_x, meter_y)
    RenderSelectedPattern(pattern_x, pattern_y, BLANK_SMALL)
    RenderTempo(tempo_x, tempo_y)
    RenderEchoButton(_echoOn)
    RenderCopyButton()
    RenderPasteButton()
    RenderAutoButton(_proceedOn)
    RenderRandomButton()
    RenderJoy()
    RenderMetronome()
    rts
}

.macro RenderMetronome() {
    // TODO: flash the beat and flash the measure
    // somewhere top of the screen, part of the "joy" probably
}

.macro RenderJoy(){

    .var paletteIndex = __tmp2
    .var color = __tmp3

    ldy _tempo_Index
    lda _tempo_LUT,Y
    tay; dey; 
    cpy _frameCounter
    beq !+
        jmp exit
    !:

    PlotColor #0:#0:#BLACK
    PlotColor #1:#0:#BLACK
    PlotColor #2:#0:#BLACK
    PlotColor #0:#1:#BLACK
    PlotColor #1:#1:#BLACK
    PlotColor #2:#1:#BLACK
    PlotColor #0:#2:#BLACK
    PlotColor #1:#2:#BLACK
    PlotColor #2:#2:#BLACK

    ldy #CHANNEL_VOICE1
    lda _voiceOn,y
    beq !++
        Set paletteIndex:#2
        ldy paletteIndex
        Set color:joy_palette,Y
        PlotColor #0:paletteIndex:color
        dec paletteIndex

        ldy #CHANNEL_OCTAVE1
        lda _voiceOn,y
        beq !+
            ldy paletteIndex
            Set color:joy_palette,Y
            PlotColor #0:paletteIndex:color
            dec paletteIndex
        !:
        ldy #CHANNEL_FILTER
        lda _voiceOn,y
        beq !+
        ldy paletteIndex
        Set color:joy_palette,Y
        PlotColor #0:paletteIndex:color
    !:
    
    ldy #CHANNEL_VOICE2
    lda _voiceOn,y
    beq !++
        Set paletteIndex:#2
        ldy paletteIndex
        Set color:joy_palette,Y
        PlotColor #1:paletteIndex:color
        dec paletteIndex

        ldy #CHANNEL_OCTAVE2
        lda _voiceOn,y
        beq !+
            ldy paletteIndex
            Set color:joy_palette,Y
            PlotColor #1:paletteIndex:color
            dec paletteIndex
        !:

        ldy #CHANNEL_FILTER
        lda _voiceOn,y
        beq !+
        ldy paletteIndex
        Set color:joy_palette,Y
        PlotColor #1:paletteIndex:color
    !:
    
    ldy #CHANNEL_VOICE3
    lda _voiceOn,y
    beq !++
        Set paletteIndex:#2
        ldy paletteIndex
        Set color:joy_palette,Y
        PlotColor #2:paletteIndex:color
        dec paletteIndex

        ldy #CHANNEL_OCTAVE3
        lda _voiceOn,y
        beq !+
            ldy paletteIndex
            Set color:joy_palette,Y
            PlotColor #2:paletteIndex:color
            dec paletteIndex
        !:

        ldy #CHANNEL_FILTER
        lda _voiceOn,y
        beq !+
        ldy paletteIndex
        Set color:joy_palette,Y
        PlotColor #2:paletteIndex:color
    !:
exit:
}

.macro RenderCopyButton() {
    lda _selectedVoice
    cmp #CHANNEL_COPY
    beq on        
    jmp off

    on:
        PlotColor #30: #23: #GREEN
        PlotColor #31: #23: #GREEN
        PlotColor #32: #23: #GREEN
        jmp end  
    !:

    off:
        PlotColor #30: #23: #GREY
        PlotColor #31: #23: #GREY
        PlotColor #32: #23: #GREY
    end:
}

.macro RenderPasteButton() {
    lda _selectedVoice
    cmp #CHANNEL_PASTE
    beq on        
    jmp off

    on:
        PlotColor #34: #23: #GREEN
        PlotColor #35: #23: #GREEN
        PlotColor #36: #23: #GREEN
        PlotColor #37: #23: #GREEN
        jmp end  
    !:

    off:
        PlotColor #34: #23: #GREY
        PlotColor #35: #23: #GREY
        PlotColor #36: #23: #GREY
        PlotColor #37: #23: #GREY
    end:
}

.macro RenderEchoButton(operand) {
    lda _selectedVoice
    cmp #CHANNEL_ECHO
    beq on        
    jmp off

on:
    PlotColor #14: #23: #GREEN
    PlotColor #15: #23: #GREEN
    jmp endSelected  

off:
    PlotColor #14: #23: #GREY
    PlotColor #15: #23: #GREY

endSelected:

    lda operand
    beq !+
        PlotColor #12: #23: #GREEN
        PlotColor #13: #23: #GREEN
        jmp endEchoOn
    !:

    PlotColor #12: #23: #GREY
    PlotColor #13: #23: #GREY
endEchoOn:
}

.macro RenderAutoButton(operand) {
    lda _selectedVoice
    cmp #CHANNEL_AUTO
    beq on        
    jmp off

on:
        PlotColor #9: #23: #GREEN
        PlotColor #10: #23: #GREEN
        jmp endSelected  

off:
        PlotColor #9: #23: #GREY
        PlotColor #10: #23: #GREY

endSelected:

    lda operand
    beq !+
        PlotColor #8: #23: #GREEN
        jmp end
    !:

    PlotColor #8: #23: #GREY
end:
}

.macro RenderRandomButton() {
    lda _selectedVoice
    cmp #CHANNEL_RANDOM
    beq on        
    jmp off

on:
    PlotColor #4: #23: #GREEN
    PlotColor #5: #23: #GREEN
    PlotColor #6: #23: #GREEN
    jmp end  

off:
    PlotColor #4: #23: #DARK_GREY
    PlotColor #5: #23: #GREY
    PlotColor #6: #23: #GREY
end:
}

.macro RenderSelectedPattern(voice_x, voice_y, blank) {
    ldx #0
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #CHANNEL_PATTERN
    bne !+
        Set PenColor:#SelectedColor
    !:

    render_pattern:
        Set Character:#blank

        // is this step a beat?
        txa
        clc 
        adc #16
        adc _patternIndex
        tay

        lda _rhythm, Y
        beq next_step

        Set Character:#PATTERN

    next_step:
        Plot voice_x,X:voice_y,X
        inx
        cpx #STEPS
        bne render_pattern

    lda _proceedOn
    beq !+

    beat:
        ldx _stepIndex        
        Set PenColor:#GREY
        Set Character:#BEAT
        Plot voice_x,X:voice_y,X
    !:        
}

.macro RenderChord(voice_x, voice_y) {
    // set pen color to unselected 
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #CHANNEL_METER
    bne !+
        // or selected
        Set PenColor:#SelectedColor
    !:

    ldx #0
    render_pattern:
        Set Character:#PATTERN
        cpx _beatsPerMeasure_Index
        bcc next_step
        beq next_step
        Set Character:#BLANK_SMALL
    next_step:
        Plot voice_x,X:voice_y,X
        inx
        cpx #STEPS
        bne render_pattern
}

.macro RenderPattern(voiceNumber, voice_x, voice_y, blank) {
    .var voiceNumberOfBeats = _beatPatterns + (voiceNumber*8)
    .var voiceRotation = _rotationPatterns + (voiceNumber*8)

    lda #0
    sta _stepCounter
    tax
    Set PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #voiceNumber
    bne !+
        Set PenColor:#SelectedColor
    !:

    render_pattern:
        stx _stepCounter
        ldy _patternIndex
        // is this step a beat?
        lda voiceNumberOfBeats, Y
        // *16 so shift 4 times, each rhythm pattern is sixteeen long 
        asl;asl;asl;asl
        clc 
        adc _stepCounter
        adc voiceRotation, Y
        tay

        Set Character:#blank

        lda _rhythm, Y
        beq next_step

        Set Character:#PATTERN

    next_step:
        Plot voice_x,X:voice_y,X
        inx
        cpx #STEPS
        bne render_pattern

    beat:
        ldy #voiceNumber
        lda _voiceOn, Y
        beq !+
            ldx _stepIndex        
            Set PenColor:#BeatColor
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
        Set PenColor:#SelectedColor
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
        cmp #STEPS
        bne render_pattern

    beat:
        ldy #voiceNumber
        lda _voiceOn, Y
        beq !+
            ldx _stepIndex
            Set PenColor:#BeatColor
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
        // or selected
        Set PenColor:#SelectedColor
    !:

    ldx #0
    render_pattern:
        Set Character:tempo_char,X
        cpx _tempo_Index
        bcc next_step
        beq next_step
        Set Character:tempo_blank_char,X
    next_step:
        Plot voice_x,X:voice_y,X
        inx
        cpx #STEPS
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

.pseudocommand ReadChar x:y {
        .var screenLO = __tmp0 
        .var screenHI = __tmp1

        Set __tmp3:y
        ldy x
        ldx __tmp3

        clc
        lda screenRow.lo,x  
        sta screenLO

        lda screenRow.hi,x
        ora #$04 
        sta screenHI

        lda (screenLO),y  
        sta Character
  
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

// reversed
joy_palette: .byte GREEN,LIGHT_GREEN,LIGHT_RED

voice0_x:   .byte 09,11,12,11,09,07,06,07,09,11,12,11,09,07,06,07
voice0_y:   .byte 10,11,13,15,16,15,13,11,10,11,13,15,16,15,13,11

voice1_x:   .byte 09,13,14,13,09,05,04,05,09,13,14,13,09,05,04,05
voice1_y:   .byte 08,09,13,17,18,17,13,09,08,09,13,17,18,17,13,09

voice2_x:   .byte 09,15,16,15,09,03,02,03,09,15,16,15,09,03,02,03
voice2_y:   .byte 06,07,13,19,20,19,13,07,06,07,13,19,20,19,13,07

pattern_x:  .byte 33,35,36,35,33,31,30,31,33,35,36,35,33,31,30,31
pattern_y:  .byte 14,15,17,19,20,19,17,15,14,15,17,19,20,19,17,15

// this is in a different order, first entry is the bottom of the circle, goes clockwise
tempo_x:    .byte 38,37,37,37,38,39,39,39
tempo_y:    .byte 02,02,01,00,00,00,01,02
tempo_blank_char:   .byte 174,173,157,141,142,143,159,175
tempo_char: .byte 219,218,202,186,187,188,204,220

// like tempo, first entry is the bottom of the circle, goes clockwise
// chord_x:    .byte 25,27,28,27,25,23,22,23,25,27,28,27,25,23,22,23
// chord_y:    .byte 14,15,17,19,20,19,17,15,14,15,17,19,20,19,17,15

meter_x:    .byte 25,23,22,23,25,27,28,27,25,23,22,23,25,27,28,27
meter_y:    .byte 20,19,17,15,14,15,17,19,20,19,17,15,14,15,17,19


filter_x:   .byte 25,27,28,27,25,23,22,23,25,27,28,27,25,23,22,23
filter_y:   .byte 04,05,07,09,10,09,07,05,04,05,07,09,10,09,07,05

octave0_x:  .byte 31,32,32,32,31,30,30,30,31,32,32,32,31,30,30,30
octave0_y:  .byte 05,05,06,07,07,07,06,05,05,05,06,07,07,07,06,05

octave1_x:  .byte 35,36,36,36,35,34,34,34,35,36,36,36,35,34,34,34
octave1_y:  .byte 05,05,06,07,07,07,06,05,05,05,06,07,07,07,06,05

octave2_x:  .byte 33,34,34,34,33,32,32,32,33,34,34,34,33,32,32,32
octave2_y:  .byte 08,08,09,10,10,10,09,08,08,08,09,10,10,10,09,08