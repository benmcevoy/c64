#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Config.asm"

stepCounter: .byte 0

.const SPACE = 32
.const BLANK = 35
.const PATTERN = 34
.const BEAT = 33

.const VOICE0_COLOR = RED
.const VOICE0_ALT_COLOR = LIGHT_RED
.const VOICE1_COLOR = GREEN
.const VOICE1_ALT_COLOR = LIGHT_GREEN
.const VOICE2_COLOR = BLUE
.const VOICE2_ALT_COLOR = CYAN
.const VOICE3_COLOR = YELLOW
.const VOICE3_ALT_COLOR = YELLOW

Render: {
    // render the pattern in faded color, dark gray
    // render the selected voice in alt color
    // starting at the voice offset index
    // loop 8 (steps) times
    RenderPattern(0, VOICE0_COLOR, voice0_x, voice0_y)
    RenderPattern(1, VOICE1_COLOR, voice1_x, voice1_y)
    RenderPattern(2, VOICE2_COLOR, voice2_x, voice2_y)
    RenderPattern(3, VOICE3_COLOR, voice3_x, voice3_y)
    
    // render the sweep and the beat
    // for the given stepIndex use a brighter color
    // if this is a beat use brightest and the beat character
    RenderBeat(0, VOICE0_COLOR, VOICE0_ALT_COLOR, voice0_x, voice0_y)
    RenderBeat(1, VOICE1_COLOR, VOICE1_ALT_COLOR, voice1_x, voice1_y)
    RenderBeat(2, VOICE2_COLOR, VOICE2_ALT_COLOR, voice2_x, voice2_y)
    RenderBeat(3, VOICE3_COLOR, VOICE3_ALT_COLOR, voice3_x, voice3_y)

    rts
}

.macro RenderPattern(voiceNumber, voiceColor, voice_x, voice_y) {
    ldx #0
    Set stepCounter:#0

    Set CharScreen.PenColor:#DARK_GREY

    lda _selectedVoice
    cmp #voiceNumber
    bne !+
        Set CharScreen.PenColor:#voiceColor
    !:

    render_pattern:
        ldy #voiceNumber
        // is this step a beat?
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
        asl;asl;asl;asl
        clc 
        adc stepCounter
        adc _voiceOffset, Y
        tay

        lda _rhythm, Y
        bne !+
            jmp beat_off
        !:

    beat_on:
        Set CharScreen.Character:#PATTERN
        jmp next_step

    beat_off:
        Set CharScreen.Character:#BLANK

    next_step:
        Call CharScreen.Plot:voice_x,X:voice_y,X
        inx
        inc stepCounter
        lda stepCounter
        cmp #steps
        beq !+
            jmp render_pattern
        !:
}

.macro RenderBeat(voiceNumber, voiceColor, voiceAltColor, voice_x, voice_y) {
    ldy #voiceNumber
    lda _voiceOn, Y
    beq !+
        ldx _stepIndex
        Set CharScreen.PenColor:#voiceAltColor
        Set CharScreen.Character:#BEAT
        Call CharScreen.Plot:voice_x,X:voice_y,X
    !:
}

voice0_x: .byte 18,20,21,20,18,16,15,16,18,20,21,20,18,16,15,16
voice0_y: .byte 09,10,12,14,15,14,12,10,09,10,12,14,15,14,12,10

voice1_x: .byte 18,22,23,22,18,14,13,14,18,22,23,22,18,14,13,14
voice1_y: .byte 07,08,12,16,17,16,12,08,07,08,12,16,17,16,12,08

voice2_x: .byte 18,24,25,24,18,12,11,12,18,24,25,24,18,12,11,12
voice2_y: .byte 05,06,12,18,19,18,12,06,05,06,12,18,19,18,12,06

voice3_x: .byte 18,26,27,26,18,10,09,10,18,26,27,26,18,10,09,10
voice3_y: .byte 03,04,12,20,21,20,12,04,03,04,12,20,21,20,12,04