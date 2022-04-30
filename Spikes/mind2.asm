.cpu _6502
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

#import "_prelude.lib"

BasicUpstart2(Start)

.const sid        = 54272


.const Eb3 = $2e
.const E3 = $2f
.const F3 = $30
.const Gb3 = $3a
.const G3 = $3b
.const Ab4 = $3c
.const A4 = $3d
.const B4 = $3e
.const C4 = $3f
.const Db4 = $40
.const D4 = $41
.const Eb4 = $42
.const E4 = $43
.const F4 = $44
.const Gb4 = $45
.const G4 = $46
.const Ab5 = $47
.const A5 = $48

basstbl:    .byte E3,Gb3,B4,Db4,D4,F3,E3,Db4,B4,Gb3,D4,Db4

Start: {
    // voice 1
    Set sid+0*7+FREQ_LO:#$00
    Set sid+0*7+FREQ_HI:#$00
    Set sid+0*7+PW_LO:#$00
    Set sid+0*7+PW_HI:#$29
    Set sid+0*7+CONTROL:#%01000001
    Set sid+0*7+ATTACK_DECAY:#$1c
    Set sid+0*7+SUSTAIN_RELEASE:#$d0

    // voice 2
    Set sid+1*7+FREQ_LO:#$00
    Set sid+1*7+FREQ_HI:#$00
    Set sid+1*7+PW_LO:#$00
    Set sid+1*7+PW_HI:#$19
    Set sid+1*7+CONTROL:#%01000001
    Set sid+1*7+ATTACK_DECAY:#$1c
    Set sid+1*7+SUSTAIN_RELEASE:#$d0    

    // filters and whatnot
    Set sid+3*7+FILTER_CUT_OFF_LO:#%00000111
    Set sid+3*7+FILTER_CUT_OFF_HI:#%00000111
    Set sid+3*7+FILTER_CONTROL:#%11110011
    Set sid+3*7+VOLUME:#%00011111

    sei
        lda #<onTick
        sta $0314    
        lda #>onTick
        sta $0315
    cli

    rts
}

onTick: {
    
    inc     clock1
    lda     clock1
    cmp     #16
    bne !+
        Set     clock1:#0
        inc     clock1+1
        lda clock1+1
        cmp #12
        bne !+
            Set     clock1+1:#0

    !:

    inc     clock2
    lda     clock2
    cmp     #15
    bne !+
        Set     clock2:#0
        inc     clock2+1
        lda clock2+1
        cmp #12
        bne !+
            Set     clock2+1:#0
    !:

    lda     clock1+1                // x contains current bar count
    and     #%00000111              // mask off last 3 bits of bar
    tax
    lda     basstbl,x               // use as index into bass note table
    tax
    lda     freq_msb,x
    sta     sid+0*7+FREQ_HI         
    lda     freq_lsb,x
    sta     sid+0*7+FREQ_LO         

    lda     clock2+1                
    and     #%00000111              
    tax
    lda     basstbl,x       
    tax
    lda     freq_msb,x
    sta     sid+1*7+FREQ_HI         
    lda     freq_lsb,x
    sta     sid+1*7+FREQ_LO               

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


