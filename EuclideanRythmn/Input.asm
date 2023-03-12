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
        // checking for less than or equal to CHANNEL_FILTER
        // which is voices and octaves and the filter as they are all manipulated the same
        cmp #CHANNEL_FILTER
        beq !+
            bcc !+
            jmp check_pattern
        !:
        ConstrainBeatsForVoice(_selectedVoice, 0, steps, RIGHT_AND_FIRE, LEFT_AND_FIRE)
        CycleRotationForVoice(_selectedVoice, 0, steps, UP_AND_FIRE, DOWN_AND_FIRE)
        jmp end

    check_pattern:
        lda _selectedVoice
        cmp #CHANNEL_PATTERN
        beq !+
            jmp check_tempo
        !:
        Cycle(_patternIndex, 0, 7, LEFT_AND_FIRE, RIGHT_AND_FIRE)
        Cycle(_patternIndex, 0, 7, UP_AND_FIRE, DOWN_AND_FIRE)    
        jmp end

    check_tempo:
        lda _selectedVoice
        cmp #CHANNEL_TEMPO
        bne select_voice
        Constrain(_tempoIndicator, 0, 7, RIGHT_AND_FIRE, LEFT_AND_FIRE)
        Constrain(_tempoIndicator, 0, 7, UP_AND_FIRE, DOWN_AND_FIRE)
        Toggle(_echoOn, FIRE)        
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
        cmp #CHANNEL_VOICE1
        bne !+
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE2
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE1
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE3
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_OCTAVE1
        bne !+
            Set _selectedVoice:#CHANNEL_OCTAVE3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_OCTAVE2
        bne !+
            Set _selectedVoice:#CHANNEL_OCTAVE3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_OCTAVE3
        bne !+
            Set _selectedVoice:#CHANNEL_PATTERN
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_FILTER
        bne !+
            Set _selectedVoice:#CHANNEL_TEMPO
            jmp _exit
        !:

    check_up:
        lda #UP
        bit PORT2
        beq !+
            jmp check_left
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE1
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE2
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE3
        bne !+
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_OCTAVE3
        bne !+
            Set _selectedVoice:#CHANNEL_OCTAVE2
            jmp _exit
        !:  

        lda _selectedVoice
        cmp #CHANNEL_PATTERN
        bne !+
            Set _selectedVoice:#CHANNEL_OCTAVE3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_TEMPO
        bne !+
            Set _selectedVoice:#CHANNEL_FILTER
            jmp _exit
        !:

    check_left:
        lda #LEFT
        bit PORT2
        beq !+
            jmp check_right
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE1
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE2
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE3
        bne !+
            // not sure
            //Set _selectedVoice:#CHANNEL_VOICE2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_OCTAVE1
        bne !+
            Set _selectedVoice:#CHANNEL_FILTER
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_OCTAVE2
        bne !+
            Set _selectedVoice:#CHANNEL_OCTAVE1
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_OCTAVE3
        bne !+
            Set _selectedVoice:#CHANNEL_OCTAVE1
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_FILTER
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_PATTERN
        bne !+
            Set _selectedVoice:#CHANNEL_TEMPO
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_TEMPO
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:

    check_right:
        lda #RIGHT
        bit PORT2
        beq !+
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE1
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE2
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_VOICE3
        bne !+
            Set _selectedVoice:#CHANNEL_FILTER
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_FILTER
        bne !+
            Set _selectedVoice:#CHANNEL_OCTAVE1
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_OCTAVE1
        bne !+
            Set _selectedVoice:#CHANNEL_OCTAVE2
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_TEMPO
        bne !+
            Set _selectedVoice:#CHANNEL_PATTERN
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

.macro CycleRotationForVoice(voice, lowerlimit, upperlimit, increaseAction, decreaseAction){
    // setup pointer
    lda #>_rotationPatterns
    sta op1+2
    sta op2+2
    sta op3+2
    sta op4+2
    sta op5+2
    sta op6+2    

    lda voice
    // multiply by 8
    asl;asl;asl
    clc; adc #<_rotationPatterns
    sta op1+1
    sta op2+1
    sta op3+1
    sta op4+1
    sta op5+1
    sta op6+1    

    lda #decreaseAction
    bit PORT2
    bne !++
        ldx _patternIndex
op1:    lda $BEEF, X
        cmp #lowerlimit
        beq !+
op2:        dec $BEEF, X
            jmp _exit
        !:
        lda #upperlimit
op3:    sta $BEEF, X
        jmp _exit
    !:

    lda #increaseAction
    bit PORT2
    bne !++
        ldx _patternIndex
op4:    lda $BEEF, X
        cmp #upperlimit
        beq !+
op5:        inc $BEEF, X
            jmp _exit
        !:
        lda #lowerlimit
op6:    sta $BEEF, X
        jmp _exit
    !:
}


.macro ConstrainBeatsForVoice(voice, lowerlimit, upperlimit, increaseAction, decreaseAction){
    // setup pointer
    lda #>_beatPatterns
    sta op1+2
    sta op2+2
    sta op3+2
    sta op4+2

    lda voice
    // multiply by 8
    asl;asl;asl
    clc; adc #<_beatPatterns
    sta op1+1
    sta op2+1
    sta op3+1
    sta op4+1

    lda #decreaseAction
    bit PORT2
    bne !++
        ldx _patternIndex
op1:    lda $BEEF, X
        cmp #lowerlimit
        beq !+
op2:    dec $BEEF, X
        !:
        jmp _exit
    !:

    lda #increaseAction
    bit PORT2
    bne !++
        ldx _patternIndex
op3:    lda $BEEF, X
        cmp #upperlimit
        beq !+
op4:        inc $BEEF, X
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

