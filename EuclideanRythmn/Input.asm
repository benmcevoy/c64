#importonce
#import "_prelude.lib"
#import "Config.asm"
#import "Sid.asm"

.const PORT2   = $dc00
.const UP      = %00000001
.const DOWN    = %00000010
.const LEFT    = %00000100
.const RIGHT   = %00001000
.const FIRE    = %00010000

.const LEFT_AND_FIRE  = %00010100
.const RIGHT_AND_FIRE = %00011000
.const UP_AND_FIRE    = %00010001
.const DOWN_AND_FIRE  = %00010010

_previousTempo: .byte 0
_previousPattern: .byte 0
_debounceOn: .byte 0
.const Top = 5

ReadInput: {
    // hold down fire for actions
    lda #FIRE
    bit PORT2
    beq !+
        Set _debounceOn:#0
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
        lda _proceedOn
        beq !+
            CyclePattern(_patternIndex, 0, 7, LEFT_AND_FIRE, RIGHT_AND_FIRE)
            CyclePattern(_patternIndex, 0, 7, UP_AND_FIRE, DOWN_AND_FIRE)    
            jmp end
        !:
        CyclePatternLR(_patternIndex)
        CyclePatternUD(_patternIndex)    
        jmp end

    check_tempo:
        lda _selectedVoice
        cmp #CHANNEL_TEMPO
        beq !+
            jmp check_echo
        !:
        ConstrainTempoLR(_tempoIndicator)
        ConstrainTempoUD(_tempoIndicator)
        jmp end

    check_echo:
        lda _selectedVoice
        cmp #CHANNEL_ECHO
        bne check_copy
        Toggle(_echoOn, FIRE)        
        jmp end

    check_copy:
        lda _selectedVoice
        cmp #CHANNEL_COPY
        bne check_paste
        ldy _patternIndex
        ldx #0
        nextCopy:
            lda _beatPatterns, Y
            sta _clipBoard, X
            inx
            cpx #14
            beq !+
                tya
                clc; adc #8
                tay
                jmp nextCopy
        !:
        jmp end    

    check_paste:
        lda _selectedVoice
        cmp #CHANNEL_PASTE
        bne check_auto
        ldy _patternIndex
        ldx #0
        nextPaste:
            lda _clipBoard, X
            sta _beatPatterns, Y
            inx
            cpx #14
            beq !+
                tya
                clc; adc #8
                tay
                jmp nextPaste
        !:
        jmp end    

    check_auto:
        lda _selectedVoice
        cmp #CHANNEL_AUTO
        bne check_random
        Toggle(_proceedOn, FIRE)        
        jmp end  

    check_random:
        lda _selectedVoice
        cmp #CHANNEL_RANDOM
        bne select_voice
        RandomizeCurrentPattern()        
        jmp end                             

    // selection
    select_voice:
        /*all-voices*/
        SelectVoice()
    end:
}
_exit:rts

.macro RandomizeCurrentPattern(){
    ldx _patternIndex
next:
    NextRandom()
    tay
    lda _randomDistribution, Y
    sta _beatPatterns,X
    
    // increase x by 8 to advance to the next CHANNEL
    clc
    txa; adc #8
    tax

    cpx #112
    bcc next
}

.macro SelectVoice() {
    check_down:
        lda #DOWN
        bit PORT2
        beq !+
            jmp check_up
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
            Set _selectedVoice:#CHANNEL_RANDOM
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

        lda _selectedVoice
        cmp #CHANNEL_PATTERN
        bne !+
            Set _selectedVoice:#CHANNEL_COPY
            jmp _exit
        !:   

        lda _selectedVoice
        cmp #CHANNEL_TEMPO
        bne !+
            Set _selectedVoice:#CHANNEL_COPY
            jmp _exit
        !:                      

    check_up:
        lda #UP
        bit PORT2
        beq !+
            jmp check_left
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

        lda _selectedVoice
        cmp #CHANNEL_ECHO
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:         

        lda _selectedVoice
        cmp #CHANNEL_AUTO
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:  

        lda _selectedVoice
        cmp #CHANNEL_RANDOM
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:                  

        lda _selectedVoice
        cmp #CHANNEL_COPY
        bne !+
            Set _selectedVoice:#CHANNEL_PATTERN
            jmp _exit
        !:    

        lda _selectedVoice
        cmp #CHANNEL_PASTE
        bne !+
            Set _selectedVoice:#CHANNEL_PATTERN
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

        lda _selectedVoice
        cmp #CHANNEL_ECHO
        bne !+
            Set _selectedVoice:#CHANNEL_AUTO
            jmp _exit
        !: 

        lda _selectedVoice
        cmp #CHANNEL_AUTO
        bne !+
            Set _selectedVoice:#CHANNEL_RANDOM
            jmp _exit
        !:         

        lda _selectedVoice
        cmp #CHANNEL_PASTE
        bne !+
            Set _selectedVoice:#CHANNEL_COPY
            jmp _exit
        !:   

        lda _selectedVoice
        cmp #CHANNEL_COPY
        bne !+
            Set _selectedVoice:#CHANNEL_ECHO
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
        cmp #CHANNEL_OCTAVE3
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

        lda _selectedVoice
        cmp #CHANNEL_TEMPO
        bne !+
            Set _selectedVoice:#CHANNEL_VOICE3
            jmp _exit
        !:

        lda _selectedVoice
        cmp #CHANNEL_COPY
        bne !+
            Set _selectedVoice:#CHANNEL_PASTE
            jmp _exit
        !: 

        lda _selectedVoice
        cmp #CHANNEL_ECHO
        bne !+
            Set _selectedVoice:#CHANNEL_COPY
            jmp _exit
        !:              

        lda _selectedVoice
        cmp #CHANNEL_AUTO
        bne !+
            Set _selectedVoice:#CHANNEL_ECHO
            jmp _exit
        !:  

        lda _selectedVoice
        cmp #CHANNEL_RANDOM
        bne !+
            Set _selectedVoice:#CHANNEL_AUTO
            jmp _exit
        !:  
}

.macro ConstrainTempoLR(operand) {
    lda #LEFT_AND_FIRE
    bit PORT2
    bne !++
        lda operand
        cmp #Top
        bne skip
            sta _previousTempo
        skip:
        cmp #0
        beq !+
            dec operand
        !:
        jmp _exit
    !:

    lda #RIGHT_AND_FIRE
    bit PORT2
    bne !++
        inc _previousTempo
        lda operand
        cmp #7
        beq !+
            inc operand
        !:
        jmp _exit
    !:
}

.macro ConstrainTempoUD(operand) {
    lda #DOWN_AND_FIRE
    bit PORT2
    beq !+
        jmp checkUp
    !:
    lda operand
    cmp #1
    bne !+
        dec operand
        jmp _exit
    !:
    cmp #2
    bne !+
        dec operand
        jmp _exit
    !:
    cmp #3
    bne !+
        dec operand
        jmp _exit
    !:
    cmp #4
    bne !+
        lda _previousTempo
        cmp #Top
        bne skip
            inc operand
            inc _previousTempo
            jmp _exit    
        skip:
        dec operand
        jmp _exit
    !:
    cmp #5
    bne !+
        inc operand
        jmp _exit
    !:
    cmp #6
    bne !+
        inc operand
        jmp _exit
    !:

checkUp:
    lda #UP_AND_FIRE
    bit PORT2
    bne exit
        lda operand
        cmp #3
        beq threeOrless
        bcs !+
            threeOrless:
            inc operand
            jmp _exit
        !:
        cmp #5
        bne !+
            sta _previousTempo
            dec operand
            jmp _exit
        !:
        cmp #6 // or 7
        bcc !+
            dec operand
            jmp _exit
        !:
    exit:
}

.macro CyclePatternLR(operand){
check_left:
    lda #LEFT_AND_FIRE
    bit PORT2
    beq !+
        jmp check_right
    !:
    
    // if operand is 0,1,7 then inc
    // if 2 do nothing
    // if 3,4,5 then dec
    // if 6 then test previous to see if 
    
    lda operand
    cmp #0
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit
    !:
    cmp #1
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit
    !:
    cmp #2
    bne !+
        jmp _exit
    !:    
    cmp #3
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
    cmp #4
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
    cmp #5
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
    cmp #6
    bne !+
        lda _previousPattern
        cmp #5
        bne skip
            dec operand
            dec _previousPattern
            jmp _exit    
        skip:
        inc operand
        inc _previousPattern
        jmp _exit        
    !:
    cmp #7
    bne !+
        sta _previousPattern
        Set operand:#0
         
        jmp _exit
    !:

check_right:
    lda #RIGHT_AND_FIRE
    bit PORT2
    beq !+
        jmp exit
    !:

    // if operand is 1,0,7,6 then dec
    // if 6 do nothing
    // if 3,4,5 then inc
    // if 2 then test previous to see if 
    lda operand
    cmp #0
    bne !+
        sta _previousPattern
        Set operand:#7
        jmp _exit
    !:
    cmp #1
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
    cmp #2
    bne !+
        lda _previousPattern
        cmp #1
        bne skip1
            dec operand
            dec _previousPattern
            jmp _exit    
        skip1:
        inc operand
        inc _previousPattern
        jmp _exit 
    !:
    cmp #3
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit
    !:
    cmp #4
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit
    !:
    cmp #5
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit
    !:
    cmp #6
    bne !+
        jmp _exit
    !:    
    cmp #7
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
exit:
}

.macro CyclePatternUD(operand){
check_up:
    lda #UP_AND_FIRE
    bit PORT2
    beq !+
        jmp check_down
    !:
    // if operand is 1,2,3 then dec
    // if 7,6,5 then inc
    // if 0 do nothing
    // if 4 then test previous to see if 
    lda operand
    cmp #0
    bne !+
        jmp _exit
    !:
    cmp #1
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
    cmp #2
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:    
    cmp #3
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
    cmp #4
    bne !+
        lda _previousPattern
        cmp #3
        bne skip
            dec operand
            dec _previousPattern
            jmp _exit    
        skip:
        inc operand
        inc _previousPattern
        jmp _exit 
    !:
    cmp #5
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit
    !:
    cmp #6
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit        
    !:
    cmp #7
    bne !+
        sta _previousPattern
        Set operand:#0
        jmp _exit
    !:

check_down:
    lda #DOWN_AND_FIRE
    bit PORT2
    beq !+
        jmp exit
    !:

    // if operand is 1,2,3 then inc
    // if 7,6,5 then dec
    // if 4 do nothing
    // if 0 then test previous to see if 
    lda operand
    cmp #0
    bne !+
        lda _previousPattern
        cmp #1
        bne skip1
            inc operand
            inc _previousPattern
            jmp _exit    
        skip1:
        Set _previousPattern:#0
        Set operand:#7
        jmp _exit
    !:
    lda operand
    cmp #1
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit
    !:
    cmp #2
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit 
    !:
    cmp #3
    bne !+
        sta _previousPattern
        inc operand
        jmp _exit
    !:
    cmp #4
    bne !+
        jmp _exit
    !:    
    cmp #5
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
    cmp #6
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:    
    cmp #7
    bne !+
        sta _previousPattern
        dec operand
        jmp _exit
    !:
exit:    
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
    // debounce
    lda _debounceOn
    beq !+
        jmp _exit
    !:

    Set _debounceOn:#1

    lda #action
    bit PORT2
    bne !+
        lda operand
        eor #$FF
        sta operand
        jmp _exit
    !:
}

.macro CyclePattern(operand, lowerlimit, upperlimit, increaseAction, decreaseAction){
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
