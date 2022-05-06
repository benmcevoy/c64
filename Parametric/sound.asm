#importonce

.namespace Sound {
    #import "_prelude.lib"
    #import "_math.lib"
    #import "globals.asm"

    .const SID        = 54272

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
    
    .const REST = 0
    .const G1 = $23
    .const Ab2 = $24
    .const A2 = $25
    .const Bb2 = $26
    .const B2 = $27
    .const C2 = $28   
    .const Db2 = $29
    .const D2 = $2a
    .const Eb2 = $2b
    .const E2 = $2c
    .const F2 = $2d
    .const Gb2 = $2e
    .const G2 = $2f
    .const Ab3 = $30
    .const A3 = $31
    .const Bb3 = $32
    .const B3 = $33
    .const C3 = $34    
    .const Db3 = $35
    .const D3 = $36
    .const Eb3 = $37
    .const E3 = $38
    .const F3 = $39
    .const Gb3 = $3a
    .const G3 = $3b
    .const Ab4 = $3c
    .const A4 = $3d
    .const Bb4 = $3e
    .const B4 = $3f
    .const C4 = $40
    .const Db4 = $41
    .const D4 = $42
    .const Eb4 = $43
    .const E4 = $44
    .const F4 = $45
    .const Gb4 = $46
    .const G4 = $47
    .const Ab5 = $48
    .const A5 = $49
    .const Bb5 = $4a
    .const B5 = $4b
    .const C5 = $4c
    .const Db5 = $4d
    .const D5 = $4e
    .const Eb5 = $4f
    .const E5 = $50
    .const F5 = $51
    .const Gb5 = $52
    .const G5 = $53
    .const Ab6 = $54
    .const A6 = $55
    .const Bb6 = $56
    .const B6 = $57
    .const C6 = $58
    .const Db6 = $59
    .const D6 = $5a
    .const Eb6 = $5b
    .const E6 = $5c

    .const Bars = 64
    .const TEMPO = 8
    .const SUSTAIN_DURATION = 4

    Init: {
        // voice 1 instrument
        Set SID+0*7+PW_LO:#$00
        Set SID+0*7+PW_HI:#$F0
        Set SID+0*7+CONTROL:#%01100000
        Set voiceControl+0:#%01100000
        Set SID+0*7+ATTACK_DECAY:#$40
        Set SID+0*7+SUSTAIN_RELEASE:#$A3

        // voice 2 instrument
        Set SID+1*7+PW_LO:#$00
        Set SID+1*7+PW_HI:#$F0
        Set SID+1*7+CONTROL:#%01100000
        Set voiceControl+1:#%01100000
        Set SID+1*7+ATTACK_DECAY:#$40
        Set SID+1*7+SUSTAIN_RELEASE:#$A3

        // voice 3 instrument
        Set SID+2*7+PW_LO:#$00
        Set SID+2*7+PW_HI:#$F0
        Set SID+2*7+CONTROL:#%01010000
        Set voiceControl+2:#%01010000
        Set SID+2*7+ATTACK_DECAY:#$40
        Set SID+2*7+SUSTAIN_RELEASE:#$A3        
    
        // filters and whatnot
        Set SID+3*7+FILTER_CUT_OFF_LO:#%00000111
        Set SID+3*7+FILTER_CUT_OFF_HI:#%00001111
        Set SID+3*7+FILTER_CONTROL:#%11110100
        Set SID+3*7+VOLUME:#%00011111

        rts
    }

    voiceControl: .byte 0,0,0
    beat: .byte 0
    bar: .byte 0

    v1NoteIndex: .byte 0
    v2NoteIndex: .byte 0
    v3NoteIndex: .byte 0

    v1Clock:    .byte 0
    v2Clock:    .byte SUSTAIN_DURATION/2
    v3Clock:    .byte 2

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
        
        jmp     $ea31                  
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
            lda voiceControl+voiceNumber
            clc
            adc #1
            sta SID+voiceNumber*7+CONTROL

        !nextNote:
            inc     noteIndex
            lda     noteIndex
            cmp     #Bars
            bne     !+
                Set     noteIndex:#0
            !:

        !skipBeat:
            lda     clock
            cmp     #SUSTAIN_DURATION
            bne !+
                // trigger off
                lda voiceControl+voiceNumber
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
    .byte A3,A4,C5,A3, A4,C5,A3,C5, A3,B4,A3,C5, B4,A3,G3,C5
    .byte A3,A4,A3,C5, A3,A4,C5,A3, B4,C5,A3,B4, A3,C5,B4,G3
    .byte A3,A4,C5,A3, A4,C5,A3,C5, A3,B4,A3,C5, B4,A3,G3,C5
    .byte A3,A4,A3,C5, A3,A4,C5,A3, B4,C5,A3,B4, A3,C5,B4,G3

    arp1: 
    .byte A3,A4,C5,A3, A4,C5,A3,C5, A3,B4,A3,C5, B4,A3,G3,C5
    .byte A3,A4,A3,C5, A3,A4,C5,A3, B4,C5,A3,B4, A3,C5,B4,G3
    .byte A3,A4,C5,A3, A4,C5,A3,C5, A3,B4,A3,C5, B4,A3,G3,C5
    .byte A3,A4,A3,C5, A3,A4,C5,A3, B4,C5,A3,B4, A3,C5,B4,G3

    arp2: 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 

    filter: 
    .fill 64,round(127+127*sin(toRadians(i*360/64)))
}