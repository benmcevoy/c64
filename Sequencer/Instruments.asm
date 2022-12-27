#importonce
#import "_prelude.lib"
#import "Sid.asm"


// boring square
boring_square: 
    .byte $00, $04, $2A, $A2, %01000001

lfo: 
    .byte $00, $04, $16, $20, %00010001

.macro LoadPatch(oscillator, patch) {
    lda patch
    sta SID_V1_PW_LO + (oscillator * 7)
    
    lda patch+1
    sta SID_V1_PW_HI + (oscillator * 7)
    
    lda patch+2
    sta SID_V1_ATTACK_DECAY + (oscillator * 7)
    
    lda patch+3
    sta SID_V1_SUSTAIN_RELEASE + (oscillator * 7)

    lda patch+4
    sta SID_V1_CONTROL + (oscillator * 7)
}

.macro UpdateModulation() { 
    // filter cutoff
    lda SID_LFO
    // depth
    lsr;lsr;lsr;lsr;
    clc;adc #10
    sta SID_MIX_FILTER_CUT_OFF_HI

    // resonace 
    lda SID_ENV
    and #%11110000
    ora #%00000111
    sta SID_MIX_FILTER_CONTROL

    lda SID_LFO
    lsr;lsr;
    sta SID_V1_PW_LO
    sta SID_V2_PW_LO
}