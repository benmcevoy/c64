#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Config.asm"

.const BLANK = 35
.const PATTERN = 34
.const BEAT = 33

_voiceColor: .byte RED, GREEN, BLUE, YELLOW
_voiceAltColor: .byte LIGHT_RED, LIGHT_GREEN, CYAN, YELLOW
_stepCounter: .byte 0

Render: {
    RenderPattern(0, voice0_x, voice0_y)
    RenderPattern(1, voice1_x, voice1_y)
    RenderPattern(2, voice2_x, voice2_y)
    RenderPattern(3, voice3_x, voice3_y)

    rts
}

.macro RenderPattern(voiceNumber, voice_x, voice_y) {
    ldx #0
    Set _stepCounter:#0
    Set CharScreen.PenColor:#DARK_GRAY

    lda _selectedVoice
    cmp #voiceNumber
    bne !+
        ldy #voiceNumber
        Set CharScreen.PenColor:_voiceColor, Y
    !:

    render_pattern:
        ldy #voiceNumber
        // is this step a beat?
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
        asl;asl;asl;asl
        clc 
        adc _stepCounter
        adc _voiceOffset, Y
        tay

        lda _rhythm, Y
        bne !+
            jmp rest
        !:

    pattern:
        Set CharScreen.Character:#PATTERN
        jmp next_step

    rest:
        Set CharScreen.Character:#BLANK

    next_step:
        Call CharScreen.Plot:voice_x,X:voice_y,X
        inx
        inc _stepCounter
        lda _stepCounter
        cmp #steps
        beq !+
            jmp render_pattern
        !:

    beat:
        ldx _stepIndex
        ldy #voiceNumber
        lda _voiceOn, Y
        beq !+
            Set CharScreen.PenColor:_voiceAltColor, Y
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