#importonce
#import "_prelude.lib"
#import "Sid.asm"

.macro TriggerOn(oscillator) {
    ldy #oscillator
    lda oscillator_control, Y
    sta SID_V1_CONTROL + (oscillator * 7)
    sta SID_V1_CONTROL + $20 + (oscillator * 7)
}

.macro TriggerOff(oscillator) {
    ldy #oscillator
    lda oscillator_control, Y
    and #%11111110
    sta SID_V1_CONTROL + (oscillator * 7)
    sta SID_V1_CONTROL + $20 + (oscillator * 7)
}

.macro LoadPatch(oscillator, patch) {
    lda patch
    sta SID_V1_PW_LO + (oscillator * 7)
    sta SID_V1_PW_LO + $20 + (oscillator * 7)
    
    lda patch+1
    sta SID_V1_PW_HI + (oscillator * 7)
    sta SID_V1_PW_HI + $20 + (oscillator * 7)
    
    lda patch+2
    sta SID_V1_ATTACK_DECAY + (oscillator * 7)
    sta SID_V1_ATTACK_DECAY + $20 + (oscillator * 7)
    
    lda patch+3
    sta SID_V1_SUSTAIN_RELEASE + (oscillator * 7)
    sta SID_V1_SUSTAIN_RELEASE + $20 + (oscillator * 7)

    lda patch+4
    sta SID_V1_CONTROL + (oscillator * 7)
    sta SID_V1_CONTROL + $20 + (oscillator * 7)
    ldy #oscillator
    sta oscillator_control, Y
}

.macro SetNote() {
    // expect note number in .X

    ldy #0
    txa; clc; adc oscillator_tune_coarse, Y; tax
    lda     freq_msb,x
    sta     SID_V1_FREQ_HI
    sta     SID_V1_FREQ_HI + $20
    lda     freq_lsb,x
    clc; adc oscillator_tune_fine, Y
    sta     SID_V1_FREQ_LO
    sta     SID_V1_FREQ_LO + $20

    ldy #1
    txa; clc; adc oscillator_tune_coarse, Y; tax
    lda     freq_msb,x
    sta     SID_V2_FREQ_HI
    sta     SID_V2_FREQ_HI + $20
    lda     freq_lsb,x
    clc; adc oscillator_tune_fine, Y
    sta     SID_V2_FREQ_LO
    sta     SID_V2_FREQ_LO + $20

    ldy #2
    txa; clc; adc oscillator_tune_coarse, Y; tax
    lda     freq_msb,x
    sta     SID_V3_FREQ_HI
    sta     SID_V3_FREQ_HI + $20
    lda     freq_lsb,x
    clc; adc oscillator_tune_fine, Y
    sta     SID_V3_FREQ_LO
    sta     SID_V3_FREQ_LO + $20
}

.macro UpdateModulation() { 
    // filter cutoff
    lda SID_ENV
    // depth
    lsr;lsr;lsr;lsr
    clc;adc #4
    sta SID_MIX_FILTER_CUT_OFF_HI

    // resonance 
    lda SID_ENV
    eor #$ff
    and #%11110000
    ora #%00000111
    sta SID_MIX_FILTER_CONTROL
    sta SID_MIX_FILTER_CONTROL + $20
}

silence:        .byte $00, $00, $00, $00, %00000000
boring_square:  .byte $00, $04, $2A, $A2, %01000001
triangle:       .byte $00, $00, $2A, $A2, %00010001    
saw:            .byte $00, $00, $00, $F9, %00100001        
lfo:            .byte $00, $00, $14, $00, %00100001
noise:          .byte $00, $00, $00, $F0, %10000001

square1: .byte $08, $04, $09 , 0, %01000001
square2: .byte $09, $06, $09 , 0, %01000001
square3: .byte $00, $06, $09 , 0, %01000001

// coarse in semitones
oscillator_tune_coarse: .byte 0,0,-12
// fine in cents or you know, some number.
oscillator_tune_fine: .byte 0,6,0
oscillator_control: .byte 0,0,0