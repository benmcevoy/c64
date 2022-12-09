#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
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
        // more specifc inputs first, eg.g LEFT_AND_FIRE before just LEFT
        /*all-voices*/
        Constrain(_tempo, 1, $ff, LEFT_AND_FIRE, RIGHT_AND_FIRE)
        
        /*all-voices*/
        //Cycle(_chord, 0, chord_length, LEFT_AND_FIRE, RIGHT_AND_FIRE)    
        // fiter could be part of a chord, e.g. cMaj with a band-pass filter to emphasise a note
        // Filter(/*filter*/)
        
        /*all-voices*//*scale*/
        //Cycle(_transpose, 0, scale_length, UP_AND_FIRE, DOWN_AND_FIRE)

        /*voice*//*phase*/  
        CycleForVoice(_selectedVoice, _voiceOffset, 0, steps, UP_AND_FIRE, DOWN_AND_FIRE)
        
        /*voice*//*number of beats*/
        ConstrainForVoice(_selectedVoice, _voiceNumberOfBeats, 0, steps, RIGHT, LEFT)
        
        /*all-voices*/
        Cycle(_selectedVoice, 0, 3, UP, DOWN)
    }
exit:rts

    .macro Constrain(operand, lowerlimit, upperlimit, increaseAction, decreaseAction){
        lda #decreaseAction
        bit PORT2
        bne !++
            lda operand
            cmp #lowerlimit
            beq !+
                dec operand
            !:
            jmp exit
        !:

        lda #increaseAction
        bit PORT2
        bne !++
            lda operand
            cmp #upperlimit
            beq !+
                inc operand
            !:
            jmp exit
        !:
    }

    .macro Cycle(operand, lowerlimit, upperlimit, increaseAction, decreaseAction){
        // change chord shape
        lda #decreaseAction
        bit PORT2
        bne !++
            lda operand
            cmp #lowerlimit
            beq !+
                dec operand
                jmp exit
            !:
            Set operand:#upperlimit
            jmp exit
        !:

        lda #increaseAction
        bit PORT2
        bne !++
            lda operand
            cmp #upperlimit
            beq !+
                inc operand
                jmp exit
            !:
            Set operand:#lowerlimit
            jmp exit
        !:
    }

    .macro CycleForVoice(voice, operand, lowerlimit, upperlimit, increaseAction, decreaseAction){
        //offset or rotation
        lda #decreaseAction
        bit PORT2
        bne !++
            lda voice
            tax
            lda operand, X
            cmp #lowerlimit
            beq !+
                dec operand, X
                jmp exit
            !:
            lda #upperlimit
            sta operand, X
            jmp exit
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
                jmp exit
            !:
            lda #lowerlimit
            sta operand, X
            jmp exit
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
            jmp exit
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
            jmp exit
        !:        
    }