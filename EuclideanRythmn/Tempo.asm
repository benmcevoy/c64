#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Sid.asm"
#import "Render.asm"
#import "Input.asm"
#import "Config.asm"
#import "Midi.asm"

.namespace Tempo {

    .const readInputDelay = 8
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
        SetPulseWidth(1, $06, $06)
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
        Set _frameCounter:_tempo

        inc _stepIndex
        lda _stepIndex
        cmp #steps
        bne !+
            Set _stepIndex:#0
        !:

        TriggerMidiOff(0)
        TriggerMidiOff(1)
        TriggerMidiOff(2)
        
        TriggerChord()

        TriggerOctave(3)
        TriggerOctave(4)
        TriggerOctave(5)

        TriggerBeat(0, Square)
        TriggerBeat(1, Square)
        TriggerBeat(2, Square)

        // filter
        ldx _filterIndex
        lda _filter, X
        sta SID_MIX_FILTER_CUT_OFF_HI
        inc _filterIndex
    nextFrame:
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }
    
    .macro TriggerChord() {
        ldy #6
        lda _chord
        sta _voiceRotation, Y

        SetChord(chords, _chord, _transpose, scale_phrygian_dominant)
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
            TriggerMidiOn(voiceNumber)
            
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
        !:
    }

    _filterIndex: .byte 0
    _filter: 
        // round(resolution + dcOffset + resolution * sin(toradians(i * 360 * f / resolution )))
        // e.g. fill sine wave offset 16 with 4 bit resolution
        .var speed = 1; .var low = 1; .var high = 8

        .fill 16,round(high+low+high*sin(toRadians(i*360*(speed+0)/high)))
        .fill 16,round(high+low+high*sin(toRadians(i*360*(speed+0)/high)))

        .eval high = 12
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
        
        .eval high = 8
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
        
        .eval high = 12
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))

        .eval high = 8
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+4)/high)))
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
        .byte $ff
}

