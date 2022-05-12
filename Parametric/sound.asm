#importonce

.namespace Sound {
    #import "_prelude.lib"
    #import "_math.lib"
    #import "globals.asm"

    // point to chip
    .const SID_ACTUAL = $D400
    // point to framebuffer
    .const SID        = $4000
    // reserve space for "frame buffer"
    .pseudopc SID { .fill 27,0 }

    .const VOICE1 = 0
    .const VOICE2 = 1
    .const VOICE3 = 2
    .const MIX = 3

    // voice
    .const FREQ_LO = 0
    .const FREQ_HI = 1
    .const PW_LO = 2
    .const PW_HI = 3
    
    /* MSB Noise, Square, Saw, Triangle, Disable/Reset, Ring, Sync, Trigger LSB  */
    .const CONTROL = 4
    
    .const ATTACK_DECAY = 5
    .const SUSTAIN_RELEASE = 6

    // mix
    /* Low bits 0-2 only */
    .const FILTER_CUT_OFF_LO = 0
    .const FILTER_CUT_OFF_HI = 1
    /* MSB Resonance3, Resonance2, Resonance1, Resonance0, Ext voice filtered, v3 filter, v2 filter, v1 filter LSB */
    .const FILTER_CONTROL = 2
    /* MSB v3 disable, High pass filter, band pass filter, low pass filter, volume3, volume2, volume1, volume0 LSB */
    .const VOLUME = 3

    // extras for the voice
    .const SUSTAIN_DURATION = 25

    Init: {
        SetInstrument(VOICE1, instrument0)
        SetInstrument(VOICE2, instrument1)
        SetInstrument(VOICE3, bassInstrument)                

        // filters and whatnot
        Set SID+MIX*7+FILTER_CUT_OFF_LO:#%00000111
        Set SID+MIX*7+FILTER_CUT_OFF_HI:#%00001111
        Set SID+MIX*7+FILTER_CONTROL:#%11110101
        Set SID+MIX*7+VOLUME:#%00011111

        rts
    }

    .const BARS = 256

    beat: .byte 3

    v1NoteIndex: .byte 0
    v2NoteIndex: .byte 0
    v3NoteIndex: .byte 0

    // set some skew
    v1Clock:    .byte 2
    v2Clock:    .byte 1
    v3Clock:    .byte 0

    Play: {

        jsr Render

        inc     Global.time

        PlayVoice(VOICE1, v1Clock, v1NoteIndex, arp)
        PlayVoice(VOICE2, v2Clock, v2NoteIndex, arp1)
        PlayVoice(VOICE3, v3Clock, v3NoteIndex, arp2)

        PlayFilter(v1Clock, v1NoteIndex, filter)
        
        jmp     $ea31                  
    }

    Render: {
        // memcpy SID 0..24
        ldx #24
        loop:
            lda SID,x
            sta SID_ACTUAL,x
            dex
            bne loop

        // unroll the last iteration, saves some cmp/bra
        lda SID,x
        sta SID_ACTUAL,x

        rts
    }

    .macro SetInstrument (voiceNumber, instrument) {
        ldx #0
        loop:
            lda instrument,X
            sta SID+voiceNumber*7+PW_LO, X
            inx
            cpx #5
            bne loop

        lda instrument,X
        // sustain duration
        sta SID+SUSTAIN_DURATION+voiceNumber
    }

    .macro PlayVoice(voiceNumber, clock, noteIndex, pattern) {
        inc     clock
        lda     clock
        cmp     Global.tempo
        bne     !skipBeat+
            // reset clock
            Set clock:#0

            // read note
            ldx     noteIndex
            lda     pattern,x  
            // if REST then skip it
            beq     !nextNote+
            tax
            lda     freq_msb,x
            sta     SID+voiceNumber*7+FREQ_HI         
            lda     freq_lsb,x
            sta     SID+voiceNumber*7+FREQ_LO    

            // add detune here                
            
            // trigger on
            lda SID+voiceNumber*7+CONTROL
            ora #%00000001
            sta SID+voiceNumber*7+CONTROL

        !nextNote:
            inc     noteIndex
            lda     noteIndex
            cmp     #BARS
            bne     !+
                Set     noteIndex:#0
            !:

        !skipBeat:
            lda     clock
            cmp     SID+SUSTAIN_DURATION+voiceNumber
            bne !+
                // trigger off
                lda SID+voiceNumber*7+CONTROL
                and #%11111110
                sta SID+voiceNumber*7+CONTROL
        !:

        //sweet detune, nice on an lfo, mix with clock skew so fat
        lda #voiceNumber
        cmp #2
        bne !+
            inc    SID+voiceNumber*7+FREQ_LO
            inc    SID+voiceNumber*7+FREQ_LO

        !:    
    }

    .macro PlayFilter(clock, noteIndex, pattern) {
        lda     clock
        bne     !skipBeat+
           
            // read note
            ldx     noteIndex
            lda     pattern,x  
            // if REST then skip it
            beq     !nextNote+
            
            sta     SID+3*7+FILTER_CUT_OFF_HI    
            sta     Global.time

        !nextNote:
        !skipBeat:
    }

    // pw_low, pw_hi, control, AD, SR, sustain duration
    instrument0: .byte  $00, $40, %00110000, $40, $AA, $09
    instrument1: .byte  $00, $00, %00010010, $20, $88, $0A
    bassInstrument: .byte  $00, $20, %01110000, $00, $6A, $06


    freq_msb:
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
    .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
    .byte $02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05,$06,$06
    .byte $06,$07,$07,$08,$08,$09,$09,$0a,$0a,$0b,$0c,$0d,$0d,$0e,$0f,$10
    .byte $11,$12,$13,$14,$15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$27,$29
    .byte $2b,$2e,$31,$34,$37,$3a,$3e,$41,$45,$49,$4e,$52,$57,$5c,$62,$68

    freq_lsb:
    .byte $6e,$75,$7c,$83,$8b,$93,$9c,$a5,$af,$b9,$c4,$d0,$dd,$ea,$f8,$07
    .byte $16,$27,$39,$4b,$5f,$74,$8a,$a1,$ba,$d4,$f0,$0e,$2d,$4e,$71,$96
    .byte $be,$e7,$14,$42,$74,$a9,$e0,$1b,$5a,$9c,$e2,$2d,$7b,$cf,$27,$85
    .byte $e8,$51,$c1,$37,$b4,$38,$c4,$59,$f7,$9d,$4e,$0a,$d0,$a2,$81,$6d
    .byte $67,$70,$89,$b2,$ed,$3b,$9c,$13,$a0,$45,$02,$da,$ce,$e0,$11,$64
    .byte $da,$76,$39,$26,$40,$89,$04,$b4,$9c,$c0,$23,$c8,$b4,$eb,$72,$4c
    .byte $80,$12,$08,$68,$39,$80,$45,$90,$68,$d6,$e3,$99,$00,$24,$10

    arp: 
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3 
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3   

    arp1: 
    .byte REST,REST,REST,REST, REST,REST,REST,REST, REST,REST,REST,REST, REST,REST,REST,REST
    .byte REST,REST,REST,REST, REST,REST,REST,REST, REST,REST,REST,REST, REST,REST,REST,REST
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3   
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3               

    arp2: 
    // copied from arp
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    // end
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2    
    .byte E1,E1,E1,E1, E1,E1,E1,E1, E1,E1,E1,E1, E1,E1,E1,E1
    .byte C1,C1,C1,C1, C1,C1,C1,C1, C1,C1,C1,C1, C1,C1,C1,C1 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 

    filter: 
    // round(resolution + dcOffset + resolution * sin(toradians(i * 360 * f / resolution )))
    // e.g. fill sine wave offset 16 with 4 bit resolution
    .var speed = 1; .var low = 3; .var high = 7

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
}