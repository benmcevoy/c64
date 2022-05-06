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

    .const v1ClockSpeed = 10
    .const v2ClockSpeed = 11
    .const v3ClockSpeed = 2*v1ClockSpeed*v2ClockSpeed
    .const Bars = 12
    .const MelodyBars = 8

    Init: {
        // voice 1
        Set SID+0*7+FREQ_HI:#$00
        Set SID+0*7+PW_LO:#$00
        Set SID+0*7+PW_HI:#$80
        Set SID+0*7+CONTROL:#%01010001
        Set SID+0*7+ATTACK_DECAY:#$12
        Set SID+0*7+SUSTAIN_RELEASE:#$60

        // voice 2
        Set SID+1*7+PW_LO:#$00
        Set SID+1*7+PW_HI:#$80
        Set SID+1*7+CONTROL:#%00110001
        Set SID+1*7+ATTACK_DECAY:#$13
        Set SID+1*7+SUSTAIN_RELEASE:#$60   

        // voice 3
        Set SID+2*7+PW_LO:#$00
        Set SID+2*7+PW_HI:#$A0
        Set SID+2*7+CONTROL:#%01010001
        Set SID+2*7+ATTACK_DECAY:#$90
        Set SID+2*7+SUSTAIN_RELEASE:#$30            

        // filters and whatnot
        Set SID+3*7+FILTER_CUT_OFF_LO:#%00000111
        Set SID+3*7+FILTER_CUT_OFF_HI:#%00001111
        Set SID+3*7+FILTER_CONTROL:#%11110111
        Set SID+3*7+VOLUME:#%00111111

        rts
    }

    Play: {
        inc     Global.time

        dec     v1Clock
        bne !+
            Set     v1Clock:#v1ClockSpeed
            
            ldx     v1NoteIndex
            lda     bass,x  
            tax
            lda     freq_msb,x
            sta     SID+0*7+FREQ_HI         
            lda     freq_lsb,x
            sta     SID+0*7+FREQ_LO               

            inc     v1NoteIndex
            lda     v1NoteIndex
            cmp     #Bars
            bne     !+
                Set     v1NoteIndex:#0
        !:

        dec v2Clock
        bne !+
            Set     v2Clock:#v2ClockSpeed

            ldx     v2NoteIndex               
            lda     bass,x   
            tax
            lda     freq_msb,x
            sta     SID+1*7+FREQ_HI         
            lda     freq_lsb,x
            sta     SID+1*7+FREQ_LO 

            inc     v2NoteIndex
            lda     v2NoteIndex
            cmp     #Bars
            bne     !+
                Set     v2NoteIndex:#0
        !:   

        dec     v3Clock
        bne !+
            Set     v3Clock:#v3ClockSpeed

            ldx     v3NoteIndex               
            lda     melody,x   
            tax
            lda     freq_msb,x
            sta     SID+2*7+FREQ_HI         
            lda     freq_lsb,x
            sta     SID+2*7+FREQ_LO 

            inc     v3NoteIndex
            lda     v3NoteIndex
            cmp     #MelodyBars
            bne     !+
                Set     v3NoteIndex:#0
        !:   

        lda upDown
        bne down
            inc clock3
            bne updateFilter
                inc upDown
                jmp updateFilter
        
        down:
            dec clock3
            // don't let the filter bottom out
            lda clock3
            cmp #16
            bne updateFilter
                dec upDown

        updateFilter:
            Set SID+3*7+FILTER_CUT_OFF_HI:clock3
            Set SID+2*7+PW_HI:clock3

        jmp     $ea31                  
    }

    v1NoteIndex: .byte 0
    v2NoteIndex: .byte 0
    v3NoteIndex: .byte 0

    v1Clock:    .byte v1ClockSpeed
    v2Clock:    .byte v2ClockSpeed
    v3Clock:    .byte v3ClockSpeed
    clock3:     .byte 0
    upDown:     .byte 0

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

    bass:       .byte E3, Gb3, B4, Db4, D4, Gb3, E3, Db4, B4, Gb3, D4, Db4
    melody:     .byte B5, A5, D5, E5, B5, A5, D5, Db5
}