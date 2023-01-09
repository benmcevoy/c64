#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Sid.asm"
#import "Render.asm"
#import "Input.asm"
#import "Config.asm"
#import "Midi.asm"

.namespace Tempo {

    .const FILTER_LOW = 6
    .const FILTER_HIGH = 18
    .const readInputDelay = 6
    _frameCounter: .byte 1
    _readInputInterval: .byte readInputDelay
    _index: .byte 0
    _filter: .byte 10

    Init: {
        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#10
        Set SID_MIX_FILTER_CONTROL:#%11110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_ATTACK_DECAY:#$09
        Set SID_V2_ATTACK_DECAY:#$09
        Set SID_V3_ATTACK_DECAY:#$09

        SetWaveForm(0, Saw)
        SetWaveForm(1, Saw)
        SetWaveForm(2, Saw)

        SetPulseWidth(0, $08, $04)
        SetPulseWidth(1, $09, $06)
        SetPulseWidth(2, $8A, $06)

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda $d019
        sta $d019
        // set next irq line number
        lda    #1
        sta    $d012
    
    #if MIDI
        WasThatAMidiInterrupt()
    #endif    

        dec _readInputInterval
        bne !+
            jsr ReadInput
            Set _readInputInterval:#readInputDelay
        !:
        
        //inc $d020
        jsr Render
        //dec $d020
        
        dec _frameCounter
        beq !+
            jmp nextFrame
        !: 

    stepStart:
        ldy _tempoIndicator
        Set _frameCounter:_tempo_fill,Y

        inc _stepIndex
        lda _stepIndex
        cmp #steps
        bne !+
            Set _stepIndex:#0
        !:
    #if MIDI
        TriggerMidiOff(0)
        TriggerMidiOff(1)
        TriggerMidiOff(2)
        TriggerMidiOff(3)
        TriggerMidiOff(4)
        TriggerMidiOff(5)
    #endif    
        TriggerChord()

        TriggerOctave(3)
        TriggerOctave(4)
        TriggerOctave(5)

        TriggerBeat(0)
        TriggerBeat(1)
        TriggerBeat(2)

        TriggerFilter(8)
    nextFrame:
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    .macro TriggerFilter(voiceNumber) {
            ldy #voiceNumber
            lda #0
            sta _voiceOn,Y
            
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
                bcs !+
                    sta _filter
                !:
            
                lda #1
                ldy #voiceNumber
                sta _voiceOn, Y
                jmp exit
            !:

            lda _filter
            sec; sbc #4
            sta SID_MIX_FILTER_CUT_OFF_HI
            cmp #FILTER_LOW
            bcc exit
            sta _filter

        exit:
    }
    
    .macro TriggerChord() {
        ldy #6
        lda _chord
        sta _voiceRotation, Y

        // i was thinking about reading the chord then setting some v0-2 reference notes
        // then calculating octave from the reference
        // also - scale, use the step index to index into the scale and add that as the transpose
        // so rather than transposing, that action cycles throgh scales?
        // the chord sets the reference

        // or use the scale to add variety to the octave, not an 12 step transpose but
        // a scale transpose , e.g. the step with the beat provides the index into the scale.
        // scale could be constrained to a triad or e.g. 0,7,12 
        // more arp like
        SetChord(chords, _chord, _transpose, scale_circle_harmonic_major)
    }

    .macro TriggerBeat(voiceNumber) {
        ldy #voiceNumber
        lda #0
        sta _voiceOn,Y
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc _voiceRotation, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        beq !+
            // trigger on
            TriggerOff(voiceNumber)

            ldx _voiceNoteNumber,Y
            lda freq_msb, X
            sta SID_V1_FREQ_HI+voiceNumber*7
            lda freq_lsb, X
            sta SID_V1_FREQ_LO+voiceNumber*7

            TriggerOn(voiceNumber)
        #if MIDI
            TriggerMidiOn(voiceNumber)
        #endif
            
            lda #1
            ldy #voiceNumber
            sta _voiceOn, Y
        !:
    }

    .macro TriggerOctave(voiceNumber) {
        ldy #voiceNumber
        lda #0
        sta _voiceOn,Y
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc _voiceRotation, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        beq !+
            // trigger on
            lda #1
            sta _voiceOn, Y

            lda #voiceNumber
            sec; sbc #3
            tay
            
            lda _voiceNoteNumber, Y
            clc; adc #12
            sta _voiceNoteNumber, Y
   
        #if MIDI
            ldy #voiceNumber
            sta _voiceNoteNumber, Y
            TriggerMidiOn(voiceNumber)
        #endif
        
        !:
    }

    .macro UpdateModulation() { 
        // filter cutoff
        lda SID_ENV
        // depth
        lsr;lsr;lsr;lsr
        clc;adc #2
        sta SID_MIX_FILTER_CUT_OFF_HI

        // resonance 
        lda SID_ENV
        and #%11110000
        ora #%00000011
        sta SID_MIX_FILTER_CONTROL

        lda SID_LFO
        lsr;lsr;
        sta SID_V2_PW_LO
    }
}

