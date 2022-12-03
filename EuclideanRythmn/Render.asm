#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Config.asm"

voiceCounter: .byte 0
stepCounter: .byte 0

.const SPACE = 32
.const FULL_STOP = 46
.const TOP_LEFT = 207
.const TOP_RIGHT = 208
.const BOTTOM_LEFT = 204
.const BOTTOM_RIGHT = 250
.const PATTERN_ON = 108

.const VOICE0_COLOR = BLUE
.const VOICE0_ALTCOLOR = LIGHT_BLUE
.const VOICE1_COLOR = GREEN
.const VOICE1_ALTCOLOR = LIGHT_GREEN
.const VOICE2_COLOR = RED
.const VOICE2_ALTCOLOR = LIGHT_RED

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
            Set CharScreen.Character:#FULL_STOP

            lda _selectedVoice
            cmp #0
            bne !+
                Set CharScreen.PenColor:#VOICE0_ALTCOLOR
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

            lda _rhythm, Y
            // if 0 then REST
            beq !+
                // trigger on
                Set CharScreen.Character:#PATTERN_ON
            !:
            
            lda voice0_x,X
            sta x
            lda voice0_y,X
            sta y

            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y

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
        
        // voice0
        {
            Set CharScreen.PenColor:#DARK_GREY
            Set CharScreen.Character:#FULL_STOP

            lda _selectedVoice
            cmp #1
            bne !+
                Set CharScreen.PenColor:#VOICE1_ALTCOLOR
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

            lda _rhythm, Y
            // if 0 then REST
            beq !+
                // trigger on
                Set CharScreen.Character:#PATTERN_ON
            !:
            
            lda voice1_x,X
            sta x
            lda voice1_y,X
            sta y

            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y

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
            Set CharScreen.Character:#FULL_STOP

            lda _selectedVoice
            cmp #2
            bne !+
                Set CharScreen.PenColor:#VOICE2_ALTCOLOR
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

            lda _rhythm, Y
            // if 0 then REST
            beq !+
                // trigger on
                Set CharScreen.Character:#PATTERN_ON
            !:
            
            lda voice2_x,X
            sta x
            lda voice2_y,X
            sta y

            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y

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

            Set CharScreen.Character:#FULL_STOP
            Set CharScreen.PenColor:#LIGHT_GRAY

            lda _selectedVoice
            cmp #0
            beq !+
                Set CharScreen.PenColor:#WHITE
            !:

            // render fullstops, wasteful
            // render color
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            dec x
            
            lda _voiceOn, Y
            bne !+
                jmp !++
            !:
            Set CharScreen.PenColor:#VOICE0_COLOR

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

            Set CharScreen.Character:#FULL_STOP
            Set CharScreen.PenColor:#LIGHT_GRAY

            lda _selectedVoice
            cmp #1
            beq !+
                Set CharScreen.PenColor:#WHITE
            !:

            // render fullstops, wasteful
            // render color
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            dec x
            
            lda _voiceOn, Y
            bne !+
                jmp !++
            !:
            Set CharScreen.PenColor:#VOICE1_COLOR

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

            Set CharScreen.Character:#FULL_STOP
            Set CharScreen.PenColor:#LIGHT_GRAY

            lda _selectedVoice
            cmp #2
            beq !+
                Set CharScreen.PenColor:#WHITE
            !:

            // render fullstops, wasteful
            // render color
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            inc x
            Call CharScreen.Plot:x:y
            inc y
            Call CharScreen.Plot:x:y
            dec y
            dec x
            
            lda _voiceOn, Y
            bne !+
                jmp !++
            !:
            Set CharScreen.PenColor:#VOICE2_COLOR

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

