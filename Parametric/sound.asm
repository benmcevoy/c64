#importonce

.namespace Sound {
    #import "_prelude.lib"
    #import "globals.asm"

    .const sid        = 54272

    .const FREQ_LO = 0
    .const FREQ_HI = 1
    .const PW_LO = 2
    .const PW_HI = 3
    .const CONTROL = 4
    .const ATTACK_DECAY = 5
    .const SUSTAIN_RELEASE = 6

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
    .const G5 = $47
    .const Ab5 = $48

    .const Clock1Speed = 10
    .const Clock2Speed = 11
    .const Bars = 12

    Init: {
        // voice 1
        Set sid+0*7+FREQ_LO:#$00
        Set sid+0*7+FREQ_HI:#$00
        Set sid+0*7+PW_LO:#$00
        Set sid+0*7+PW_HI:#$80
        Set sid+0*7+CONTROL:#%01010001
        Set sid+0*7+ATTACK_DECAY:#$12
        Set sid+0*7+SUSTAIN_RELEASE:#$60

        // voice 2
        Set sid+1*7+FREQ_LO:#$00
        Set sid+1*7+FREQ_HI:#$00
        Set sid+1*7+PW_LO:#$00
        Set sid+1*7+PW_HI:#$80
        Set sid+1*7+CONTROL:#%00110001
        Set sid+1*7+ATTACK_DECAY:#$13
        Set sid+1*7+SUSTAIN_RELEASE:#$60    

        // filters and whatnot
        Set sid+3*7+FILTER_CUT_OFF_LO:#%00000111
        Set sid+3*7+FILTER_CUT_OFF_HI:#%00001111
        Set sid+3*7+FILTER_CONTROL:#%11110011
        Set sid+3*7+VOLUME:#%00111111

        rts
    }

    // TODO: clean up this madness
    // derive clocks from time - i had a crazy idea that lfsr could derive any clock
    // currently i am trying to manage multiple clocks
    // so this is a place where we can apply some transformation of the problem
    // and have a signal clock generating events
    // sequencer, or duration that elapses
    // also give the render function a clock as well,
    // can get some synced variety by restarting the filter sweep below and syncing that with the evolution of the parameteric system
    // tempo
    // basically want arps that can retrigger with different starting pitch
    // and what happens if you run a clock backwards
    Play: {
        inc     clock1
        lda     clock1
        cmp     #Clock1Speed
        bne !+
            Set     clock1:#0
            inc     clock1+1
            lda clock1+1
            cmp #Bars
            bne !+
                Set     clock1+1:#0
        
        !:

        inc     clock2
        lda     clock2
        cmp     #Clock2Speed
        bne !+
            Set     clock2:#0
            inc     clock2+1
            lda clock2+1
            cmp #Bars
            bne !+
                Set     clock2+1:#0
        
        !:       

        lda     clock1+1                // x contains current bar count
    //  and     #%00001111              // mask off last 3 bits of bar
        tax
        lda     basstbl,x               // use as index into bass note table
        tax
        lda     freq_msb,x
        sta     sid+0*7+FREQ_HI         
        lda     freq_lsb,x
        sta     sid+0*7+FREQ_LO         

        lda     clock2+1                
        // and     #%00001111              
        tax
        lda     basstbl,x   
            
        tax
        lda     freq_msb,x
        sta     sid+1*7+FREQ_HI         
        lda     freq_lsb,x
        sta     sid+1*7+FREQ_LO               

        lda     Global.time
        sta     sid+3*7+FILTER_CUT_OFF_HI
        jmp     $ea31                  
    }

    clock1:      .word $0000
    clock2:      .word $0000

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

    basstbl:    .byte E3, Gb3, B4, Db4, D4, Gb3, E3, Db4, B4, Gb3, D4, Db4
}