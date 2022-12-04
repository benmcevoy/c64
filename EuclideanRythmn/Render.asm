#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Config.asm"

voiceCounter: .byte 0
stepCounter: .byte 0

.const SPACE = 32
.const REST_TOP_LEFT = 6
.const REST_TOP_RIGHT = 7
.const REST_BOTTOM_LEFT = 22
.const REST_BOTTOM_RIGHT = 23

.const TOP_LEFT = 2
.const TOP_RIGHT = 3
.const BOTTOM_LEFT = 18
.const BOTTOM_RIGHT = 19

.const ALT_TOP_LEFT = 0
.const ALT_TOP_RIGHT = 1
.const ALT_BOTTOM_LEFT = 16
.const ALT_BOTTOM_RIGHT = 17

.const VOICE0_COLOR = RED
.const VOICE0_ALT_COLOR = LIGHT_RED
.const VOICE1_COLOR = GREEN
.const VOICE1_ALT_COLOR = LIGHT_GREEN
.const VOICE2_COLOR = BLUE
.const VOICE2_ALT_COLOR = CYAN

Render: {
        // render the pattern in faded color, dark gray
        // render the selected voice in alt color
        // starting at the voice offset index
        // loop 8 (steps) times
        
        ldx #0
        Set stepCounter:#0
    renderPattern0:
        
        // voice0
        {
            Set CharScreen.PenColor:#DARK_GREY

            lda _selectedVoice
            cmp #0
            bne !+
                Set CharScreen.PenColor:#VOICE0_ALT_COLOR
            !:

            // is this step a beat?
            ldy #0
            lda _voiceNumberOfBeats, Y
            // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
            asl;asl;asl;asl
            clc 
            adc stepCounter
            adc _voiceOffset, Y
            tay

            lda voice0_x,X
            sta x
            lda voice0_y,X
            sta y

            lda _rhythm, Y
            bne !+
                jmp voice0_beat_off
            !:
                
        voice0_beat_on:
            Set CharScreen.Character:#ALT_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#ALT_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#ALT_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#ALT_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            jmp voice0_next_step

        voice0_beat_off:
            Set CharScreen.Character:#REST_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#REST_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y

        voice0_next_step:
            inx
            inc stepCounter
            lda stepCounter
            cmp _steps
            beq !+
                jmp renderPattern0
            !:
        }

        ldx #0
        Set stepCounter:#0
    renderPattern1:
        
        // voice1
        {
            Set CharScreen.PenColor:#DARK_GREY

            lda _selectedVoice
            cmp #1
            bne !+
                Set CharScreen.PenColor:#VOICE1_ALT_COLOR
            !:

            // is this step a beat?
            ldy #1
            lda _voiceNumberOfBeats, Y
            // *16 so shift 4 times, each rhytmn pattern is sixteeen long 
            asl;asl;asl;asl
            clc 
            adc stepCounter
            adc _voiceOffset, Y
            tay

            lda voice1_x,X
            sta x
            lda voice1_y,X
            sta y

            lda _rhythm, Y
            bne !+
                jmp voice1_beat_off
            !:
                
        voice1_beat_on:
            Set CharScreen.Character:#ALT_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#ALT_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#ALT_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#ALT_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            jmp voice1_next_step

        voice1_beat_off:
            Set CharScreen.Character:#REST_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#REST_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y

        voice1_next_step:
            inx
            inc stepCounter
            lda stepCounter
            cmp _steps
            beq !+
                jmp renderPattern1
            !:
        }

        ldx #0
        Set stepCounter:#0
    renderPattern2:
        
        // voice0
        {
            Set CharScreen.PenColor:#DARK_GREY

            lda _selectedVoice
            cmp #2
            bne !+
                Set CharScreen.PenColor:#VOICE2_ALT_COLOR
            !:

            // is this step a beat?
            ldy #2
            lda _voiceNumberOfBeats, Y
            // *16 so shift 4 times
            asl;asl;asl;asl
            clc 
            adc stepCounter
            adc _voiceOffset, Y
            tay

            lda voice2_x,X
            sta x
            lda voice2_y,X
            sta y

            lda _rhythm, Y
            bne !+
                jmp voice2_beat_off
            !:
                
        voice1_beat_on:
            Set CharScreen.Character:#ALT_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#ALT_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#ALT_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#ALT_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            jmp voice2_next_step

        voice2_beat_off:
            Set CharScreen.Character:#REST_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#REST_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y

        voice2_next_step:
            inx
            inc stepCounter
            lda stepCounter
            cmp _steps
            beq !+
                jmp renderPattern2
            !:
        }

        // render the sweep and the beat
        // for the given stepIndex use a brighter color
        // if this is a beat use brightest and the beat character

        
        ldy #0
        ldx _stepIndex
        
        // voice0
        renderBeat0:
        {
            // get plot position
            lda voice0_x,X
            sta x
            lda voice0_y,X
            sta y

            Set CharScreen.PenColor:#VOICE0_COLOR

            lda _selectedVoice
            cmp #0
            beq !+
                Set CharScreen.PenColor:#LIGHT_GRAY
            !:

            // render fullstops, wasteful
            // render color
            Set CharScreen.Character:#REST_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#REST_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            dec y
            dec x
            
            lda _voiceOn, Y
            bne !+
                jmp !++
            !:
            Set CharScreen.PenColor:#VOICE0_ALT_COLOR

            Set CharScreen.Character:#TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            !:
        }

        ldy #1
        ldx _stepIndex
        
        // voice1
        renderBeat1:
        {
            // get plot position
            lda voice1_x,X
            sta x
            lda voice1_y,X
            sta y

            Set CharScreen.PenColor:#VOICE1_COLOR

            lda _selectedVoice
            cmp #1
            beq !+
                Set CharScreen.PenColor:#LIGHT_GRAY
            !:

            // render fullstops, wasteful
            // render color
            Set CharScreen.Character:#REST_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#REST_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            dec y
            dec x
            
            lda _voiceOn, Y
            bne !+
                jmp !++
            !:
            Set CharScreen.PenColor:#VOICE1_ALT_COLOR

            Set CharScreen.Character:#TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            !:
        }

        ldy #2
        ldx _stepIndex
        
        // voice1
        renderBeat2:
        {
            // get plot position
            lda voice2_x,X
            sta x
            lda voice2_y,X
            sta y

            Set CharScreen.PenColor:#VOICE2_COLOR

            lda _selectedVoice
            cmp #2
            beq !+
                Set CharScreen.PenColor:#LIGHT_GRAY
            !:

            // render fullstops, wasteful
            // render color
            Set CharScreen.Character:#REST_TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#REST_TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#REST_BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            dec y
            dec x
            
            lda _voiceOn, Y
            bne !+
                jmp !++
            !:
            Set CharScreen.PenColor:#VOICE2_ALT_COLOR

            Set CharScreen.Character:#TOP_LEFT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#BOTTOM_LEFT
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Set CharScreen.Character:#TOP_RIGHT
            Call CharScreen.Plot:x:y
            inc y
            Set CharScreen.Character:#BOTTOM_RIGHT
            Call CharScreen.Plot:x:y
            !:
        }
      

        rts
        x: .byte 0
        y: .byte 0
    }

voice0_x: .byte 18,24,27,24,18,12,9,12,18,24,27,24,18,12,9,12
voice0_y: .byte 2,5,11,17,20,17,11,5,2,5,11,17,20,17,11,5

voice1_x: .byte 18,22,24,22,18,14,12,14,18,22,24,22,18,14,12,14
voice1_y: .byte 5,7,11,15,17,15,11,7,5,7,11,15,17,15,11,7

voice2_x: .byte 18,20,21,20,18,16,15,16,18,20,21,20,18,16,15,16
voice2_y: .byte 8,9,11,13,14,13,11,9,8,9,11,13,14,13,11,9

