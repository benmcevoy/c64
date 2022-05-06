#importonce

.namespace Sound {
    #import "_prelude.lib"
    #import "_math.lib"
    #import "globals.asm"

    // point to chip
    .const SID_ACTUAL = 54272
    // point to framebuffer
    .const SID        = $4000
    // reserve space for "frame buffer"
    .pseudopc SID { .fill 24,0 }

    // voice
    .const FREQ_LO = 0
    .const FREQ_HI = 1
    .const PW_LO = 2
    .const PW_HI = 3
    .const CONTROL = 4
    .const ATTACK_DECAY = 5
    .const SUSTAIN_RELEASE = 6

    // mix
    .const FILTER_CUT_OFF_LO = 0
    .const FILTER_CUT_OFF_HI = 1
    .const FILTER_CONTROL = 2
    .const VOLUME = 3

    Init: {
        // voice 1 instrument
        Set SID+0*7+PW_LO:#$00
        Set SID+0*7+PW_HI:#$40
        Set SID+0*7+CONTROL:#%00110000
        Set SID+0*7+ATTACK_DECAY:#$40
        Set SID+0*7+SUSTAIN_RELEASE:#$AA

        // voice 2 instrument
        Set SID+1*7+PW_LO:#$00
        Set SID+1*7+PW_HI:#$00
        Set SID+1*7+CONTROL:#%00010010
        Set SID+1*7+ATTACK_DECAY:#$20
        Set SID+1*7+SUSTAIN_RELEASE:#$88

        // voice 3 instrument
        Set SID+2*7+PW_LO:#$00
        Set SID+2*7+PW_HI:#$20
        Set SID+2*7+CONTROL:#%01110000
        Set SID+2*7+ATTACK_DECAY:#$10
        Set SID+2*7+SUSTAIN_RELEASE:#$63       
    
        // filters and whatnot
        Set SID+3*7+FILTER_CUT_OFF_LO:#%00000111
        Set SID+3*7+FILTER_CUT_OFF_HI:#%00001111
        Set SID+3*7+FILTER_CONTROL:#%11110101
        Set SID+3*7+VOLUME:#%00011111

        rts
    }


    .const BARS = 256
    .const TEMPO = 8
    .const SUSTAIN_DURATION = 4

    beat: .byte 3

    v1NoteIndex: .byte 0
    v2NoteIndex: .byte 0
    v3NoteIndex: .byte 0

    // set some skew
    v1Clock:    .byte 2
    v2Clock:    .byte 0
    v3Clock:    .byte 1

    Play: {
        inc     Global.time

        // The tempo
        // 4 beats to a bar
        // The Play routine is called on the CIA clock at 60Hz
        // for a given BPM we have n "ticks"  
        // the below is wrong...
        // BPM = 14400/n
        // e.g for 96 BPM is  n = 14400/96 or 150 ticks

        PlayVoice(0, v1Clock, v1NoteIndex, arp)
        PlayVoice(1, v2Clock, v2NoteIndex, arp1)
        PlayVoice(2, v3Clock, v3NoteIndex, arp2)

        PlayFilter(v1Clock, v1NoteIndex, filter)
        
        jsr Render

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

        // lda     SID+3*7+FILTER_CUT_OFF_HI
        // sta     Global.startAngle

        rts
    }

    .macro PlayVoice(voiceNumber, clock, noteIndex, pattern) {
        inc     clock
        lda     clock
        cmp     #TEMPO
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
            cmp     #SUSTAIN_DURATION
            bne !+
                // trigger off
                lda SID+voiceNumber*7+CONTROL
                and #%11111110
                sta SID+voiceNumber*7+CONTROL
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

        !nextNote:
        !skipBeat:
    }

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
    .var speed = 1; .var low = 1; .var high = 8

    .fill 16,round(high+low+high*sin(toRadians(i*360*(speed+3)/high)))
    .fill 16,round(high+low+high*sin(toRadians(i*360*(speed+3)/high)))

    .eval high = 12
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+3)/high)))
    
    .eval high = 8
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+3)/high)))
    
    .eval high = 12
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))

    .eval high = 8
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+4)/high)))
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
}