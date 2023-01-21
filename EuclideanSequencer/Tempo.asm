#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Sid.asm"
#import "Song.asm"
#import "Config.asm"
#import "Instruments.asm"

.namespace Tempo {

    .const FILTER_LOW = 6
    .const FILTER_HIGH = 18

    _frameCounter: .byte 1
    _index: .byte 0
    _filter: .byte 10

    Init: {
        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#10
        Set SID_MIX_FILTER_CONTROL:#%11110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_MIX_FILTER_CUT_OFF_LO+$20:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI+$20:#10
        Set SID_MIX_FILTER_CONTROL+$20:#%11110111
        Set SID_MIX_VOLUME+$20:#%00011111

        LoadPatch(OSCILLATOR1, square1)
        LoadPatch(OSCILLATOR2, square2)
        LoadPatch(OSCILLATOR3, square3)

        // lfo cycle
        lda #00
        sta SID_V3_FREQ_HI
        sta SID_V3_FREQ_HI + $20
        lda #$04
        sta SID_V3_FREQ_LO
        sta SID_V3_FREQ_LO + $20

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda $d019
        sta $d019
        // set next irq line number
        lda    #100
        sta    $d012

        dec _frameCounter
        beq !+
            jmp nextFrame
        !: 

    stepStart:
        ReadSong()

        ldy #TEMPO
        lda _voiceNumberOfBeats, Y
        tax
        Set _frameCounter:_tempo_fill,X

        inc _stepIndex
        lda _stepIndex
        cmp #steps
        bne !+
            Set _stepIndex:#0
        !:
   
        TriggerChord()

        TriggerOctave(ACCENT1)
        TriggerOctave(ACCENT2)
        TriggerOctave(ACCENT3)

        TriggerBeat(OSCILLATOR1)
        TriggerBeat(OSCILLATOR2)
        TriggerBeat(OSCILLATOR3)

        TriggerFilter(FILTER)
    nextFrame:
        UpdateModulation()
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    .macro TriggerFilter(voiceNumber) {
            ldy #voiceNumber
            lda _voiceNumberOfBeats, Y
            // *16 so shift 4 times
            asl;asl;asl;asl
            clc 
            adc _stepIndex
            adc _voiceRotation, Y
            tax

            lda _rhythm, X
            // if 0 then REST
            beq !++
                // trigger on
                // filter
                lda _filter
                clc; adc #2
                cmp #FILTER_HIGH
                sta SID_MIX_FILTER_CUT_OFF_HI
                sta SID_MIX_FILTER_CUT_OFF_HI + $20
                bcs !+
                    sta _filter
                !:

                jmp exit
            !:

            lda _filter
            sec; sbc #4
            sta SID_MIX_FILTER_CUT_OFF_HI 
            sta SID_MIX_FILTER_CUT_OFF_HI + $20
            cmp #FILTER_LOW
            bcc exit
            sta _filter

        exit:
    }
    
    .macro TriggerChord() {

        .var scale = scale_circle_harmonic_major
        .const transpose = 0

        ldy #CHORD
        // multiply by 3 to get the chord start index
        lda _voiceNumberOfBeats, Y
        asl
        clc
        adc _voiceNumberOfBeats, Y
        tay

        lda chords, Y
        Scale(transpose, scale)
        ldx #OSCILLATOR1
        sta _voiceNoteNumber, X

        iny
        lda chords, Y
        Scale(transpose, scale)
        ldx #OSCILLATOR2
        sta _voiceNoteNumber, X

        iny
        lda chords, Y
        Scale(transpose, scale)
        ldx #OSCILLATOR3
        sta _voiceNoteNumber, X
    }

    .macro TriggerBeat(voiceNumber) {
        ldy #voiceNumber
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc _voiceRotation, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        bne !+
            jmp exit
        !:
            // trigger off
            TriggerOff(voiceNumber)

            ldx _voiceNoteNumber,Y
            SetNote()

            // trigger on
            TriggerOn(voiceNumber)
        exit:
    }

    .macro TriggerOctave(voiceNumber) {
        ldy #voiceNumber
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc _voiceRotation, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        beq !++
            ldy #voiceNumber
            lda _voiceNoteNumber, Y
            
            cpy #OSCILLATOR1
            bne !+
                clc; adc #4
            !:

            cpy #OSCILLATOR2
            bne !+
                clc; adc #7
            !:

            cpy #OSCILLATOR3
            bne !+
                clc; adc #12
            !:


            sta _voiceNoteNumber, Y
        !:
    }

    .macro Scale(transpose, scale) {
        ldx transpose
        clc; adc scale,X; tax
    }
}

