#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Sid.asm"
#import "Render.asm"
#import "Input.asm"
#import "Config.asm"
#import "Midi.asm"

.namespace Tempo {

    .const readInputDelay = 6
    _frameCounter: .byte 1
    _readInputInterval: .byte readInputDelay

    Init: {
        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#10
        Set SID_MIX_FILTER_CONTROL:#%11110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_ATTACK_DECAY:#$09
        Set SID_V2_ATTACK_DECAY:#$09
        Set SID_V3_ATTACK_DECAY:#$09

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

        TriggerBeat(0, Saw)
        TriggerBeat(1, Saw)
        TriggerBeat(2, Saw)

        TriggerFilter(8)
    nextFrame:
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    .macro TriggerFilter(voiceNumber) {
        .const FILTER_LOW = 8
        .const FILTER_HIGH = 16

        ldy #voiceNumber
        lda #0
        sta _voiceOn,Y
        
        lda #FILTER_LOW
        sta SID_MIX_FILTER_CUT_OFF_HI

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
            // filter
            lda #FILTER_HIGH
            sta SID_MIX_FILTER_CUT_OFF_HI
           
            lda #1
            ldy #voiceNumber
            sta _voiceOn, Y
        !:
    }
    
    .macro TriggerChord() {
        ldy #6
        lda _chord
        sta _voiceRotation, Y

        SetChord(chords, _chord, _transpose, scale_aeolian)
    }

    .macro TriggerBeat(voiceNumber, waveform) {
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
            SetWaveForm(voiceNumber, Silence)

            ldx _voiceNoteNumber,Y
            lda freq_msb, X
            sta SID_V1_FREQ_HI+voiceNumber*7
            lda freq_lsb, X
            sta SID_V1_FREQ_LO+voiceNumber*7

            SetWaveForm(voiceNumber, waveform)
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
   
        #if MIDI
            ldy #voiceNumber
            sta _voiceNoteNumber, Y
            TriggerMidiOn(voiceNumber)
        #else
            sta _voiceNoteNumber, Y
        #endif
        
        !:
    }
}

