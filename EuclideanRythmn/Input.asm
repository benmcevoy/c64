#importonce
#import "_prelude.lib"
#import "Config.asm"

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

ReadInput: {
    // hold down fire for actions
    lda #FIRE
    bit PORT2
    beq !+
        jmp select_voice
    !:

    // actions
    check_voice:
        lda _selectedVoice
        // cheking for less than or equal to 5
        // which is voices and octaves
        cmp #5
        beq !+
            bcs check_pattern
        !:
        ConstrainForVoice(_selectedVoice, _voiceNumberOfBeats, 0, steps, RIGHT_AND_FIRE, LEFT_AND_FIRE)
        CycleForVoice(_selectedVoice, _voiceRotation, 0, steps, UP_AND_FIRE, DOWN_AND_FIRE)
        jmp end

    check_pattern:
        lda _selectedVoice
        cmp #6
        beq !+
            jmp check_tempo
        !:
        CycleForVoice(_selectedVoice, _voiceRotation, 0, 7, LEFT_AND_FIRE, RIGHT_AND_FIRE)
        CycleForVoice(_selectedVoice, _voiceRotation, 0, 7, UP_AND_FIRE, DOWN_AND_FIRE)    
        jmp end

    check_tempo:
        lda _selectedVoice
        cmp #7
        bne check_filter
        Constrain(_tempoIndicator, 0, 7, RIGHT_AND_FIRE, LEFT_AND_FIRE)
        Constrain(_tempoIndicator, 0, 7, UP_AND_FIRE, DOWN_AND_FIRE)
        Toggle(_echoOn, FIRE)        
        jmp end

    check_filter:
        lda _selectedVoice
        cmp #8
        bne select_voice
        ConstrainForVoice(_selectedVoice, _voiceNumberOfBeats, 0, steps, RIGHT_AND_FIRE, LEFT_AND_FIRE)
        CycleForVoice(_selectedVoice, _voiceRotation, 0, steps, UP_AND_FIRE, DOWN_AND_FIRE)
        jmp end


    // selection
    select_voice:
        /*all-voices*/
        SelectVoiceUpDown()
    end:
}
_exit:rts

.macro SelectVoiceUpDown() {
    check_down:
        lda #DOWN
        bit PORT2
        beq !+
            jmp check_up
        !:

        lda _selectedVoice
        cmp #0
        bne !+
            jmp _exit
        !:

        lda _selectedVoice
        cmp #1
        bne !+
            Set _selectedVoice:#0
            jmp _exit
        !:

        lda _selectedVoice
        cmp #2
        bne !+
            Set _selectedVoice:#1
            jmp _exit
        !:

        lda _selectedVoice
        cmp #3
        bne !+
            Set _selectedVoice:#5
            jmp _exit
        !:

        lda _selectedVoice
        cmp #4
        bne !+
            Set _selectedVoice:#5
            jmp _exit
        !:

        lda _selectedVoice
        cmp #5
        bne !+
            Set _selectedVoice:#6
            jmp _exit
        !:

        lda _selectedVoice
        cmp #8
        bne !+
            Set _selectedVoice:#7
            jmp _exit
        !:

    check_up:
        lda #UP
        bit PORT2
        beq !+
            jmp check_left
        !:

        lda _selectedVoice
        cmp #0
        bne !+
            Set _selectedVoice:#1
            jmp _exit
        !:

        lda _selectedVoice
        cmp #1
        bne !+
            Set _selectedVoice:#2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #2
        bne !+
            jmp _exit
        !:

        lda _selectedVoice
        cmp #5
        bne !+
            Set _selectedVoice:#4
            jmp _exit
        !:  

        lda _selectedVoice
        cmp #6
        bne !+
            Set _selectedVoice:#5
            jmp _exit
        !:

        lda _selectedVoice
        cmp #7
        bne !+
            Set _selectedVoice:#8
            jmp _exit
        !:

    check_left:
        lda #LEFT
        bit PORT2
        beq !+
            jmp check_right
        !:

        lda _selectedVoice
        cmp #0
        bne !+
            Set _selectedVoice:#1
            jmp _exit
        !:

        lda _selectedVoice
        cmp #1
        bne !+
            Set _selectedVoice:#2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #2
        bne !+
            jmp _exit
        !:

        lda _selectedVoice
        cmp #3
        bne !+
            Set _selectedVoice:#8
            jmp _exit
        !:

        lda _selectedVoice
        cmp #4
        bne !+
            Set _selectedVoice:#3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #5
        bne !+
            Set _selectedVoice:#3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #8
        bne !+
            Set _selectedVoice:#2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #6
        bne !+
            Set _selectedVoice:#7
            jmp _exit
        !:

        lda _selectedVoice
        cmp #7
        bne !+
            Set _selectedVoice:#2
            jmp _exit
        !:

    check_right:
        lda #RIGHT
        bit PORT2
        beq !+
            jmp _exit
        !:

        lda _selectedVoice
        cmp #0
        bne !+
            Set _selectedVoice:#1
            jmp _exit
        !:

        lda _selectedVoice
        cmp #1
        bne !+
            Set _selectedVoice:#2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #2
        bne !+
            Set _selectedVoice:#8
            jmp _exit
        !:

        lda _selectedVoice
        cmp #8
        bne !+
            Set _selectedVoice:#3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #3
        bne !+
            Set _selectedVoice:#4
            jmp _exit
        !:

        lda _selectedVoice
        cmp #7
        bne !+
            Set _selectedVoice:#6
            jmp _exit
        !:        

}

.macro Constrain(operand, lowerlimit, upperlimit, increaseAction, decreaseAction){
    lda #decreaseAction
    bit PORT2
    bne !++
        lda operand
        cmp #lowerlimit
        beq !+
            dec operand
        !:
        jmp _exit
    !:

    lda #increaseAction
    bit PORT2
    bne !++
        lda operand
        cmp #upperlimit
        beq !+
            inc operand
        !:
        jmp _exit
    !:
}

.macro Cycle(operand, lowerlimit, upperlimit, increaseAction, decreaseAction){
    lda #decreaseAction
    bit PORT2
    bne !++
        lda operand
        cmp #lowerlimit
        beq !+
            dec operand
            jmp _exit
        !:
        Set operand:#upperlimit
        jmp _exit
    !:

    lda #increaseAction
    bit PORT2
    bne !++
        lda operand
        cmp #upperlimit
        beq !+
            inc operand
            jmp _exit
        !:
        Set operand:#lowerlimit
        jmp _exit
    !:
}

.macro CycleForVoice(voice, operand, lowerlimit, upperlimit, increaseAction, decreaseAction){
    lda #decreaseAction
    bit PORT2
    bne !++
        lda voice
        tax
        lda operand, X
        cmp #lowerlimit
        beq !+
            dec operand, X
            jmp _exit
        !:
        lda #upperlimit
        sta operand, X
        jmp _exit
    !:

    lda #increaseAction
    bit PORT2
    bne !++
        lda voice
        tax
        lda operand, X
        cmp #upperlimit
        beq !+
            inc operand, X
            jmp _exit
        !:
        lda #lowerlimit
        sta operand, X
        jmp _exit
    !:
}

.macro ConstrainForVoice(voice, operand, lowerlimit, upperlimit, increaseAction, decreaseAction){
    lda #decreaseAction
    bit PORT2
    bne !++
        lda voice
        tax
        lda operand, X
        cmp #lowerlimit
        beq !+
            dec operand, X
        !:
        jmp _exit
    !:

    lda #increaseAction
    bit PORT2
    bne !++
        lda voice
        tax
        lda operand, X
        cmp #upperlimit
        beq !+
            inc operand, X
        !:
        jmp _exit
    !:        
}

.macro Toggle(operand, action){
    lda #action
    bit PORT2
    bne !+
        lda operand
        eor #$FF
        sta operand
        jmp _exit
    !:
}