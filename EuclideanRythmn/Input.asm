#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Config.asm"


 ReadInput: {
        .const PORT2   = $dc00
        .const UP      = %00000001
        .const DOWN    = %00000010
        .const LEFT    = %00000100
        .const RIGHT   = %00001000
        .const FIRE    = %00010000

        .const LEFT_AND_FIRE    = %00010100
        .const RIGHT_AND_FIRE    = %00011000
        .const UP_AND_FIRE    = %00010001
        .const DOWN_AND_FIRE    = %00010010

        // hold down fire to change overall tempo
        lda #RIGHT_AND_FIRE
        bit PORT2
        bne !++
            lda _frameInterval
            cmp #1
            beq !+
                dec _frameInterval
            !:
            jmp exit
        !:

        lda #LEFT_AND_FIRE
        bit PORT2
        bne !++
            lda _frameInterval
            cmp #$ff
            beq !+
                inc _frameInterval
            !:
            jmp exit
        !:

        // transpose
        lda #DOWN_AND_FIRE
        bit PORT2
        bne !++
            lda _transpose
            beq !+
                dec _transpose
            !:
            jmp exit
        !:

        lda #UP_AND_FIRE
        bit PORT2
        bne !++
            lda _transpose
            cmp #scale_length
            beq !+
                inc _transpose
            !:
            jmp exit
        !:

        //offset or rotation
        // lda #UP_AND_FIRE
        // bit PORT2
        // bne !++
        //     lda _selectedVoice
        //     tax
        //     lda _voiceOffset, X
        //     beq !+
        //         dec _voiceOffset, X
        //         jmp exit
        //     !:
        //     lda #7
        //     sta _voiceOffset, X
        //     jmp exit
        // !:

        // lda #DOWN_AND_FIRE
        // bit PORT2
        // bne !++
        //     lda _selectedVoice
        //     tax
        //     lda _voiceOffset, X
        //     cmp _steps
        //     beq !+
        //         inc _voiceOffset, X
        //         jmp exit
        //     !:
        //     lda #0
        //     sta _voiceOffset, X
        //     jmp exit
        // !:

        lda #DOWN
        bit PORT2
        bne !++
            lda _selectedVoice
            cmp #0
            beq !+
                dec _selectedVoice
                jmp exit
            !:
            Set _selectedVoice:#2
            jmp exit
        !:

        lda #UP
        bit PORT2
        bne !++
            lda _selectedVoice
            cmp #2
            beq !+
                inc _selectedVoice
                jmp exit
            !:
            Set _selectedVoice:#0
            jmp exit
        !:

        lda #LEFT
        bit PORT2
        bne !++
            lda _selectedVoice
            tax
            lda _voiceNumberOfBeats, X
            beq !+
                dec _voiceNumberOfBeats, X
            !:
            jmp exit
        !:

        lda #RIGHT
        bit PORT2
        bne !++
            lda _selectedVoice
            tax
            lda _voiceNumberOfBeats, X
            cmp _steps
            beq !+
                inc _voiceNumberOfBeats, X
            !:
        !:

    exit:
        rts
    }