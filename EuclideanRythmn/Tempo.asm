#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Sid.asm"
#import "Render.asm"
#import "Input.asm"
#import "Config.asm"
#import "Midi.asm"

.namespace Tempo {

    .const FILTER_LOW = 10
    .const FILTER_HIGH = 40
    .const readInputDelay = 6
    _frameCounter: .byte 0
    _intraBeatCounter: .byte 0,0,0
    _readInputInterval: .byte readInputDelay
    _index: .byte 0
    _filter: .byte 16

    Init: {
        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#10
        Set SID_MIX_FILTER_CONTROL:#%01110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_ATTACK_DECAY:#$09
        Set SID_V2_ATTACK_DECAY:#$09
        Set SID_V3_ATTACK_DECAY:#$09

        Set SID_V1_SUSTAIN_RELEASE:#$00

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
    
        dec _readInputInterval
        bne !+
            jsr ReadInput
            Set _readInputInterval:#readInputDelay
        !:
        
        jsr Render
        
        
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
        TriggerPattern()
        TriggerChord()

        TriggerOctave(3)
        TriggerOctave(4)
        TriggerOctave(5)

        TriggerBeat(0)
        TriggerBeat(1)
        TriggerBeat(2)

        TriggerFilter(8)

    nextFrame:
        inc _intraBeatCounter
        inc _intraBeatCounter+1
        inc _intraBeatCounter+2

        lda _echoOn
        bne !+
            jmp exit
        !:

        Echo(0)
        Echo(1)
        Echo(2)

    exit:
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    .macro Echo(voiceNumber){
        ldy #voiceNumber
        lda _intraBeatCounter,Y
        cmp _delay0_on,Y
        bne !+
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$89
            Set SID_V1_SUSTAIN_RELEASE+voiceNumber*7:#$F9
            Set SID_V1_CONTROL+voiceNumber*7:#%00000001
        !:

        lda _intraBeatCounter,Y
        cmp _delay0_off,Y
        bne !+
            Set SID_V1_CONTROL+voiceNumber*7:#%00110000
        !:

        lda _intraBeatCounter,Y
        cmp _delay1_on,Y
        bne !+
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$A0
            Set SID_V1_SUSTAIN_RELEASE+voiceNumber*7:#$89
            Set SID_V1_CONTROL+voiceNumber*7:#%00000001
        !:

        lda _intraBeatCounter,Y
        cmp _delay1_off,Y
        bne !+
            Set SID_V1_CONTROL+voiceNumber*7:#%00110000
        !:

        lda _intraBeatCounter,Y
        cmp _delay2_on,Y
        bne !+
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$C0
            Set SID_V1_SUSTAIN_RELEASE+voiceNumber*7:#$49
            Set SID_V1_CONTROL+voiceNumber*7:#%00000001
        !:

        lda _intraBeatCounter,Y
        cmp _delay2_off,Y
        bne !+
            Set SID_V1_CONTROL+voiceNumber*7:#%00110000
        !:

        lda _intraBeatCounter,Y
        cmp _delay3_on,Y
        bne !+
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#$E0
            Set SID_V1_SUSTAIN_RELEASE+voiceNumber*7:#$29
            Set SID_V1_CONTROL+voiceNumber*7:#%00000001
        !:

        lda _intraBeatCounter,Y
        cmp _delay3_off,Y
        bne !+
            Set SID_V1_CONTROL+voiceNumber*7:#%00110000
        !:
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
    
    .macro TriggerPattern() {
        // TODO: _voiceRotation, Y contains the currently selected pattern
        ldy #6
        lda _voiceRotation, Y
        sta _pattern
    }

    .macro TriggerChord() {
        SetChord(chords, _chord, _transpose, scale_phrygian)
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
            Set SID_V1_ATTACK_DECAY+voiceNumber*7:#09
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

            ldx _voiceNoteNumber,Y
            lda freq_msb, X
            sta SID_V1_FREQ_HI+(voiceNumber-3)*7
            lda freq_lsb, X
            sta SID_V1_FREQ_LO+(voiceNumber-3)*7
   
        #if MIDI
            ldy #voiceNumber
            sta _voiceNoteNumber, Y
            TriggerMidiOn(voiceNumber)
        #endif
        
        !:
    }
}
