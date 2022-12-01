#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Config.asm"

Render: {
        lda prevIndex
        tax

        Set CharScreen.Character:#32
        Set CharScreen.PenColor:#DARK_GREY
        lda _selectedVoice
        cmp #0
        bne !+
            Set CharScreen.Character:#046
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

        Set CharScreen.Character:#32
        lda _selectedVoice
        cmp #1
        bne !+
            Set CharScreen.Character:#046
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

        Set CharScreen.Character:#32
        lda _selectedVoice
        cmp #2
        bne !+
            Set CharScreen.Character:#046
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


        lda _stepIndex
        tax
        sta prevIndex

        ldy #0
        Set CharScreen.Character:#046
        Set CharScreen.PenColor:#GRAY
        lda _voiceOn, Y
        beq !+
            Set CharScreen.PenColor:#GREEN
        !:

        lda voice0_x,X
        sta x
        lda voice0_y,X
        sta y

        Set CharScreen.Character:#85
        Call CharScreen.Plot:x:y
        inc y
        Set CharScreen.Character:#74
        Call CharScreen.Plot:x:y
        dec y
        inc x
        Set CharScreen.Character:#73
        Call CharScreen.Plot:x:y
        inc y
        Set CharScreen.Character:#75
        Call CharScreen.Plot:x:y

        iny
        Set CharScreen.Character:#046
        Set CharScreen.PenColor:#GRAY
        lda _voiceOn, Y
        cmp #1
        bne !+
            Set CharScreen.PenColor:#YELLOW
        !:

        lda voice1_x,X
        sta x
        lda voice1_y,X
        sta y

        Set CharScreen.Character:#85
        Call CharScreen.Plot:x:y
        inc y
        Set CharScreen.Character:#74
        Call CharScreen.Plot:x:y
        dec y
        inc x
        Set CharScreen.Character:#73
        Call CharScreen.Plot:x:y
        inc y
        Set CharScreen.Character:#75
        Call CharScreen.Plot:x:y

        iny
        Set CharScreen.Character:#046
        Set CharScreen.PenColor:#GRAY
        lda _voiceOn, Y
        cmp #1
        bne !+
            Set CharScreen.PenColor:#BLUE
        !:

        lda voice2_x,X
        sta x
        lda voice2_y,X
        sta y

        Set CharScreen.Character:#85
        Call CharScreen.Plot:x:y
        inc y
        Set CharScreen.Character:#74
        Call CharScreen.Plot:x:y
        dec y
        inc x
        Set CharScreen.Character:#73
        Call CharScreen.Plot:x:y
        inc y
        Set CharScreen.Character:#75
        Call CharScreen.Plot:x:y

        lda _selectedVoice
        clc; adc #8
        sta y

        Set CharScreen.Character:#046
        Set CharScreen.PenColor:#RED
        Call CharScreen.Plot:#6:y

        rts
        prevIndex: .byte 0
        x: .byte 0
        y: .byte 0
    }

voice0_x: .byte 18,24,27,24,18,12,9,12,18,24,27,24,18,12,9,12
voice0_y: .byte 2,5,11,17,20,17,11,5,2,5,11,17,20,17,11,5

voice1_x: .byte 18,22,24,22,18,14,12,14,18,22,24,22,18,14,12,14
voice1_y: .byte 5,7,11,15,17,15,11,7,5,7,11,15,17,15,11,7

voice2_x: .byte 18,20,21,20,18,16,15,16,18,20,21,20,18,16,15,16
voice2_y: .byte 8,9,11,13,14,13,11,9,8,9,11,13,14,13,11,9