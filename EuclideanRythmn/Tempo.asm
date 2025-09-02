#importonce
#import "_prelude.lib"
#import "Sid.asm"
#import "Render.asm"
#import "Input.asm"
#import "Config.asm"
#import "Midi.asm"

.namespace Tempo {

    .const FILTER_MIN = 10
    .const FILTER_MAX = 40
    .const FILTER_RESONANCE_MIN = 6
    .const WAVEFORM = Saw

    // one for each voice
    _intraBeatCounter: .byte 0,0,0
    _filterCutOffHi: .byte 16
    _filterResonance: .byte 8

    Init: {
        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#%00000010
        Set SID_MIX_FILTER_CONTROL:#%11110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_ATTACK_DECAY:#$00
        Set SID_V2_ATTACK_DECAY:#$00
        Set SID_V3_ATTACK_DECAY:#$00

        Set SID_V1_SUSTAIN_RELEASE:#$00
        Set SID_V2_SUSTAIN_RELEASE:#$00
        Set SID_V3_SUSTAIN_RELEASE:#$00

        SetWaveForm(CHANNEL_VOICE1, WAVEFORM)
        SetWaveForm(CHANNEL_VOICE2, WAVEFORM)
        SetWaveForm(CHANNEL_VOICE3, WAVEFORM)

        // SetPulseWidth(CHANNEL_VOICE1, $FF, $7F)
        // SetPulseWidth(CHANNEL_VOICE2, $8F, $7F)
        // SetPulseWidth(CHANNEL_VOICE3, $0F, $7F)

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda $d019
        sta $d019
        // set next irq line number
        lda    #1
        sta    $d012

        dec _readInputInterval
        bne !+
            jsr ReadInput
            Set _readInputInterval:#readInputDelay
        !:

        dec _frameCounter
      
        jsr Render

        lda _frameCounter        
        beq !+
            jmp nextFrame
        !: 
    stepStart:
        ldy _tempo_Index
        Set _frameCounter:_tempo_LUT,Y

        inc _stepIndex
        lda _stepIndex
        cmp #STEPS
        bne !+
            // the measure is complete
            Set _stepIndex:#0
        !:

        inc _measureCounter
        lda _measureCounter
        ldx _beatsPerMeasure_Index
        cmp _beatsPerMeasure_LUT, X
        bcc !+
            Set _measureCounter:#0
            // trigger the next chord
            TriggerChord(CHANNEL_METER)   
        !:
        
    // set the note numbers to currently active chord
    SetChord(chords, _chordCurrentIndex)

    #if MIDI
        TriggerMidiOff(CHANNEL_VOICE1)
        TriggerMidiOff(CHANNEL_VOICE2)
        TriggerMidiOff(CHANNEL_VOICE3)
        TriggerMidiOff(CHANNEL_OCTAVE1)
        TriggerMidiOff(CHANNEL_OCTAVE2)
        TriggerMidiOff(CHANNEL_OCTAVE3)
        // filter is not sent to midi
    #endif    
        TriggerOctave(CHANNEL_OCTAVE1)
        TriggerOctave(CHANNEL_OCTAVE2)
        TriggerOctave(CHANNEL_OCTAVE3)

        TriggerBeat(CHANNEL_VOICE1)
        TriggerBeat(CHANNEL_VOICE2)
        TriggerBeat(CHANNEL_VOICE3)

        TriggerFilter(CHANNEL_FILTER)

    nextFrame:
        inc _intraBeatCounter
        inc _intraBeatCounter+1
        inc _intraBeatCounter+2

        lda _echoOn
        bne !+
            jmp proceed
        !:

        Echo(CHANNEL_VOICE1)
        Echo(CHANNEL_VOICE2)
        Echo(CHANNEL_VOICE3)

    proceed:
        lda _proceedOn
        beq exit
        dec _proceedInterval
        Proceed()

    exit:
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    .macro Proceed(){
        lda _proceedInterval
        bne !+
            dec _patternIndex

            Modulo _patternIndex:#8

            Set _proceedInterval:_proceedIntervalDelay
        !:
    }

    .macro Echo(voiceNumber){
        ldy #voiceNumber
        lda _intraBeatCounter,Y
        cmp _delay0_on,Y
        bne !+
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$89
            Set SID_V1_SUSTAIN_RELEASE+voiceNumber*7:#$F9
            Set SID_V1_CONTROL+voiceNumber*7:#1
        !:

        lda _intraBeatCounter,Y
        cmp _delay0_off,Y
        bne !+
            Set SID_V1_CONTROL+voiceNumber*7:#(WAVEFORM-1)
        !:

        lda _intraBeatCounter,Y
        cmp _delay1_on,Y
        bne !+
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$A0
            Set SID_V1_SUSTAIN_RELEASE+voiceNumber*7:#$89
            Set SID_V1_CONTROL+voiceNumber*7:#1
        !:

        lda _intraBeatCounter,Y
        cmp _delay2_off,Y
        bne !+
            Set SID_V1_CONTROL+voiceNumber*7:#(WAVEFORM-1)
        !:

        lda _intraBeatCounter,Y
        cmp _delay2_on,Y
        bne !+
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$C0
            Set SID_V1_SUSTAIN_RELEASE+voiceNumber*7:#$49
            Set SID_V1_CONTROL+voiceNumber*7:#1
        !:

        lda _intraBeatCounter,Y
        cmp _delay2_off,Y
        bne !+
            Set SID_V1_CONTROL+voiceNumber*7:#(WAVEFORM-1)
        !:

        lda _intraBeatCounter,Y
        cmp _delay3_on,Y
        bne !+
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$E0
            Set SID_V1_SUSTAIN_RELEASE+voiceNumber*7:#$29
            Set SID_V1_CONTROL+voiceNumber*7:#1
        !:

        lda _intraBeatCounter,Y
        cmp _delay3_off,Y
        bne !+
            Set SID_V1_CONTROL+voiceNumber*7:#(WAVEFORM-1)
        !:
    }

    .macro TriggerFilter(voiceNumber) {
        .var voiceNumberOfBeats = _beatPatterns + (voiceNumber*8)
        .var voiceRotation = _rotationPatterns + (voiceNumber*8)

        ldy #voiceNumber
        lda #0
        sta _voiceOn,Y
        ldy _patternIndex
        lda voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc voiceRotation, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        beq !+++
            // trigger on
            // filter
            lda _filterCutOffHi
            clc; adc #2
            cmp #FILTER_MAX
            sta SID_MIX_FILTER_CUT_OFF_HI
            bcs !+
                sta _filterCutOffHi
            !:

            lda _filterResonance
            clc; adc #3
            cmp #16
            bcs !+
                sta _filterResonance
                asl;asl;asl;asl;
                ora #%00000111
                sta SID_MIX_FILTER_CONTROL
            !:            
        
            lda #1
            ldy #voiceNumber
            sta _voiceOn, Y
            jmp exit
        !:

        lda _filterCutOffHi
        sec; sbc #4
        sta SID_MIX_FILTER_CUT_OFF_HI
        cmp #FILTER_MIN
        bcc exit
        sta _filterCutOffHi

        lda _filterResonance
        sec; sbc #4
        cmp #FILTER_RESONANCE_MIN
        bcc exit
        sta _filterResonance
        asl;asl;asl;asl
        ora #%00000111
        sta SID_MIX_FILTER_CONTROL

    exit:
    }
    
    .macro TriggerChord(voiceNumber) {
        .var voiceNumberOfBeats = _beatPatterns + (voiceNumber*8)
        .var voiceRotation = _rotationPatterns + (voiceNumber*8)

        // nothing to do if number of beats is zero
        lda voiceNumberOfBeats
        cmp #0
        bne !+
            jmp exit
        !:

        // we are on the an active beat
        // find the next active chord index
        // naively
        // loop from _chordCurrentIndex to 8
    loop:
        inc _chordIndex
        lda _chordIndex
        cmp #8
        bne !+
            Set _chordIndex:#0
        !:

        // ignore pattern - would be in .Y like it is TriggerBeat
        lda voiceNumberOfBeats
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _chordIndex
        adc voiceRotation
        tax
        lda _rhythm, X
        // if 0 then REST
        beq !+
            lda _chordIndex
            sta _chordCurrentIndex
        !:
    exit:
    }

    .macro TriggerNextChord(voiceNumber) {
        .var voiceNumberOfBeats = _beatPatterns + (voiceNumber*8)
        .var voiceRotation = _rotationPatterns + (voiceNumber*8)

        // nothing to do if number of beats is zero
        lda voiceNumberOfBeats
        cmp #0
        bne !+
            jmp exit
        !:

        // find the next active chord index
        // naively
        // loop from _chordCurrentIndex to 8
    loop:
        inc _chordCurrentIndex
        lda _chordCurrentIndex
        cmp #8
        bne !+
            Set _chordCurrentIndex:#0
        !:

        // ignore pattern - would be in .Y like it is TriggerBeat
        lda voiceNumberOfBeats
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _chordCurrentIndex
        adc voiceRotation
        tax
        lda _rhythm, X
        // if 0 then REST
        bne !+
            jmp loop
        !:
    exit:
    }

    .macro TriggerBeat(voiceNumber) {
        .var voiceNumberOfBeats = _beatPatterns + (voiceNumber*8)
        .var voiceRotation = _rotationPatterns + (voiceNumber*8)

        ldy #voiceNumber
        lda #0
        sta _voiceOn,Y
        ldy _patternIndex
        lda voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc voiceRotation, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        bne !+
            jmp exit
        !:
            // trigger on
            TriggerOff(voiceNumber)

            ldx _voiceNoteNumber,Y
            lda freq_msb, X
            sta SID_V1_FREQ_HI+voiceNumber*7
            lda freq_lsb, X
            sta SID_V1_FREQ_LO+voiceNumber*7

            lda #$00
            sta SID_V1_SUSTAIN_RELEASE+voiceNumber*7
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$19
            TriggerOn(voiceNumber)
        #if MIDI
            TriggerMidiOn(voiceNumber)
        #endif

            lda #1
            ldy #voiceNumber
            sta _voiceOn, Y

            Set _intraBeatCounter,Y:#0
        exit:
    }

    .macro TriggerOctave(voiceNumber) {
        .var voiceNumberOfBeats = _beatPatterns + (voiceNumber*8)
        .var voiceRotation = _rotationPatterns + (voiceNumber*8)

        ldy #voiceNumber
        lda #0
        sta _voiceOn,Y
        ldy _patternIndex
        lda voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc voiceRotation, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        beq !+
            // trigger on
            lda #1
            ldy #voiceNumber
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

    /* @Command Return remainder in value */
    .pseudocommand Modulo value:modulus {
        sec
        lda value
    subtract:
        sbc modulus
        bcs subtract
        adc modulus
        sta value 
    }
}
