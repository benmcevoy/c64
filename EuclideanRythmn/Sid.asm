#importonce 
#import "Config.asm"

.const SID_BASE = $D400

.const SID_V1_FREQ_LO = (SID_BASE + 0)
.const SID_V1_FREQ_HI = (SID_BASE + 1)
.const SID_V1_PW_LO = SID_BASE + 2
.const SID_V1_PW_HI = SID_BASE + 3
.const SID_V1_ATTACK_DECAY = SID_BASE + 5
.const SID_V1_SUSTAIN_RELEASE = SID_BASE + 6
/* MSB Noise, Square, Saw, Triangle, Disable/Reset, Ring, Sync, Trigger LSB  */
.const SID_V1_CONTROL = SID_BASE + 4

.const SID_V2_FREQ_LO = SID_BASE + 7 + 0
.const SID_V2_FREQ_HI = SID_BASE + 7 + 1
.const SID_V2_PW_LO = SID_BASE + 7 + 2
.const SID_V2_PW_HI = SID_BASE + 7 + 3
/* MSB Noise, Square, Saw, Triangle, Disable/Reset, Ring, Sync, Trigger LSB  */
.const SID_V2_CONTROL = SID_BASE + 7 + 4
.const SID_V2_ATTACK_DECAY = SID_BASE + 7 + 5
.const SID_V2_SUSTAIN_RELEASE = SID_BASE + 7 + 6

.const SID_V3_FREQ_LO = SID_BASE + 14 + 0
.const SID_V3_FREQ_HI = SID_BASE + 14 + 1
.const SID_V3_PW_LO = SID_BASE + 14 + 2
.const SID_V3_PW_HI = SID_BASE + 14 + 3
/* MSB Noise, Square, Saw, Triangle, Disable/Reset, Ring, Sync, Trigger LSB  */
.const SID_V3_CONTROL = SID_BASE + 14 + 4
.const SID_V3_ATTACK_DECAY = SID_BASE + 14 + 5
.const SID_V3_SUSTAIN_RELEASE = SID_BASE + 14 + 6

/* Low bits 0-2 only */
.const SID_MIX_FILTER_CUT_OFF_LO = SID_BASE + 21 + 0
.const SID_MIX_FILTER_CUT_OFF_HI = SID_BASE + 21 + 1
/* MSB Resonance3, Resonance2, Resonance1, Resonance0, Ext voice filtered, v3 filter, v2 filter, v1 filter LSB */
.const SID_MIX_FILTER_CONTROL = SID_BASE + 21 + 2
/* MSB v3 disable, High pass filter, band pass filter, low pass filter, volume3, volume2, volume1, volume0 LSB */
.const SID_MIX_VOLUME = SID_BASE + 21 + 3

/* Voice #3 waveform output */
.const SID_LFO = SID_BASE + 21 + 6
/* Voice #3 ADSR output */
.const SID_ENV = SID_BASE + 21 + 7

.const REST = 0;
// note number match MIDI note numbers
.const E0 = $1c;    .const F0 = $1d;    .const Gb0 = $1e;    .const G0 = $1f;    .const Ab1 = $20;    .const A1 = $21;    .const Bb1 = $22;    .const B1 = $23;    .const C1 = $24;    .const Db1 = $25;    .const D1 = $26;    .const Eb1 = $27
.const E1 = $28;    .const F1 = $29;    .const Gb1 = $2a;    .const G1 = $2b;    .const Ab2 = $2c;    .const A2 = $2d;    .const Bb2 = $2e;    .const B2 = $2f;    .const C2 = $30;    .const Db2 = $31;    .const D2 = $32;    .const Eb2 = $33
.const E2 = $34;    .const F2 = $35;    .const Gb2 = $36;    .const G2 = $37;    .const Ab3 = $38;    .const A3 = $39;    .const Bb3 = $3a;    .const B3 = $3b;    .const C3 = $3c;    .const Db3 = $3d;    .const D3 = $3e;    .const Eb3 = $3f
.const E3 = $40;    .const F3 = $41;    .const Gb3 = $42;    .const G3 = $43;    .const Ab4 = $44;    .const A4 = $45;    .const Bb4 = $46;    .const B4 = $47;    .const C4 = $48;    .const Db4 = $49;    .const D4 = $4a;    .const Eb4 = $4b
.const E4 = $4c;    .const F4 = $4d;    .const Gb4 = $4e;    .const G4 = $4f;    .const Ab5 = $50;    .const A5 = $51;    .const Bb5 = $52;    .const B5 = $53;    .const C5 = $54;    .const Db5 = $55;    .const D5 = $56;    .const Eb5 = $57
.const E5 = $58;    .const F5 = $59;    .const Gb5 = $5a;    .const G5 = $5b;    .const Ab6 = $5c;    .const A6 = $5d;    .const Bb6 = $5e;    .const B6 = $5f;    .const C6 = $60;    .const Db6 = $61;    .const D6 = $62;    .const Eb6 = $63
.const E6 = $64;


freq_msb:
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
.byte $02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05,$06,$06
.byte $06,$07,$07,$08,$08,$09,$09,$0a,$0a,$0b,$0c,$0d,$0d,$0e,$0f,$10
.byte $11,$12,$13,$14,$15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$27,$29
.byte $2b,$2e,$31,$34,$37,$3a,$3e,$41,$45,$49,$4e,$52,$57,$5c,$62,$68

freq_lsb:
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $6e,$75,$7c,$83,$8b,$93,$9c,$a5,$af,$b9,$c4,$d0,$dd,$ea,$f8,$07
.byte $16,$27,$39,$4b,$5f,$74,$8a,$a1,$ba,$d4,$f0,$0e,$2d,$4e,$71,$96
.byte $be,$e7,$14,$42,$74,$a9,$e0,$1b,$5a,$9c,$e2,$2d,$7b,$cf,$27,$85
.byte $e8,$51,$c1,$37,$b4,$38,$c4,$59,$f7,$9d,$4e,$0a,$d0,$a2,$81,$6d
.byte $67,$70,$89,$b2,$ed,$3b,$9c,$13,$a0,$45,$02,$da,$ce,$e0,$11,$64
.byte $da,$76,$39,$26,$40,$89,$04,$b4,$9c,$c0,$23,$c8,$b4,$eb,$72,$4c
.byte $80,$12,$08,$68,$39,$80,$45,$90,$68,$d6,$e3,$99,$00,$24,$10

chords: HouseProgression()

.macro HouseProgression() { 
    // house progression
    chord_Dbm: .byte Db2, E2, Ab3
    chord_A: .byte A2, Db2, E2
    chord_E: .byte E2, Ab3, B3
    chord_B: .byte B2, Eb2, Gb2
    chord_Dbm1: .byte Db2, E2, Ab3
    chord_A1: .byte A2, Db2, E2
    chord_E1: .byte E2, Ab3, B3
    chord_B1: .byte B2, Eb2, Gb2
}

.macro CircleOfFifths() {
    // circle of fifths
    // C F B0 Em Am Dm G C
    chord_C: .byte C2, E2, G2
    chord_F: .byte F2, A2, C3
    chord_B0: .byte B3, D2, F2
    chord_Em: .byte E2, G2, B3
    chord_Am: .byte A2, C3, E3
    chord_Dm: .byte D2, F2, A3
    chord_G: .byte G2, B3, D2
    chord_C2: .byte C3, E2, G2
}

.macro GalaticCore() {
    // "galatic core"
    // C, Am, F, Dm, G, Em, Bdim, C
    // Bdim is B D F#
    // https://www.youtube.com/watch?v=wtkYFQi8GpM 
    chord_C2: .byte C2, E2, G2
    chord_Am: .byte A2, C3, E3
    chord_F: .byte F1, A3, C3
    chord_Dm: .byte D2, F2, A3
    chord_B0: .byte B2, D2, F2
    chord_G: .byte G1, B2, D2
    chord_Em: .byte E2, G2, B3
    chord_B01: .byte B2, D2, F2
    chord_F1: .byte F1, A3, C3
}

.macro DropDGuitar() {
    .byte D3,Gb3,A4
    .byte E3,G3,B3
    .byte Gb3,A4,Db4
    .byte D3,G3,A4
    .byte D3,A4,A4
    .byte D3,B4,A4
    .byte D3,Gb3,B3
    .byte D3,Gb3,B3    
}

.macro Hallelujah() {
    chord_C2: .byte C2, E2, G2
    chord_Am: .byte A2, C3, E3
    chord_F: .byte F2, A2, C3
    chord_G: .byte G2, B3, D2
    chord_C21: .byte C2, E2, G2
    chord_F2: .byte F2, A2, C3
    chord_E7: .byte B2, D3, Ab4
    chord_Am2: .byte A2, C3, E3
}

.macro BornSlippy() {
    chord_CG2: .byte E2, G2, C3
    chord_EfSus4: .byte D2, A3, B3
    chord_Em: .byte E2, B3, E3
    chord_C2: .byte C2, E2, G2
    // repeat
    .byte E2, G2, C3
    .byte D2, A3, B3
    .byte E2, B3, E3
    .byte C2, E2, G2
}

.macro MinorChords() {
   chord_Cm: .byte C2, Eb2, G2 
   chord_Gm: .byte G2, Bb2, D2 
   chord_Fm: .byte F2, Ab2, C2 
   chord_Gm1: .byte G2, Bb2, D2 
   chord_Cm1: .byte C2, Eb2, G2 
   chord_Gm2: .byte G2, Bb2, D2 
   chord_Fm2: .byte F2, Ab2, C2 
   chord_Gm3: .byte G2, Bb2, D2 
}

// chord_Maj: .byte C2, E2, G2
// chord_Min: .byte C2, Eb2, G2
// chord_M_7: .byte C2, G2, Bb3
// chord_Mn7: .byte C2, Eb2, Bb3
// chord_Mj7: .byte C2, G2, B3
// chord_Su4: .byte C2, F2, G2
// chord_Su2: .byte C2, D2, G2
// chord_Dim: .byte C2, Eb2, Gb2

// https://en.wikipedia.org/wiki/List_of_musical_scales_and_modes
// W-W-W-H-W-H-W 	
scale_acoustic: .byte 0,2,4,6,7,9,10,12
scale_aeolian: .byte  0,2,3,5,7,8,10,12
scale_super_locrian: .byte 0,1,3,4,6,8,10,12
scale_enigmatic: .byte 0,1,4,6,8,10,11,12
scale_double_harmonic: .byte 0,1,4,5,7,8,11,12
scale_flamenco: .byte 0,1,4,5,7,8,11,12
scale_gypsy: .byte 0,2,3,6,7,8,10,12
scale_half_diminshed: .byte 0,2,3,5,6,8,10,12
scale_harmonic_major: .byte 0,2,4,5,7,8,11,12
scale_harmonic_minor: .byte 0,2,3,5,7,8,11,12
scale_phrygian: .byte 0,1,3,5,7,8,10,12
scale_phrygian_dominant: .byte 0,1,4,5,7,8,10,12

scale_circle_harmonic_major: .byte 0,5,11,2,7,12,4,8

.const Noise = %10000001
.const Square = %01000001
.const Saw = %00100001
.const Triangle = %00010001
.const Silence = 0

.macro SetPulseWidth(voiceNumber, lo, hi) {
    lda     lo
    sta     SID_V1_PW_LO+voiceNumber*7
    lda     hi
    sta     SID_V1_PW_HI+voiceNumber*7 
}

.macro SetWaveForm(voiceNumber, waveform) {
    lda #waveform
    sta SID_V1_CONTROL+voiceNumber*7
    ldy #voiceNumber
    sta _voiceControl, Y
}

.macro Scale(transpose, scale) {
    ldx transpose
    clc; adc scale,X; tax
}

.macro SetChord(chord, chordIndex, transpose, scale) {
    // multiply by 3
    lda chordIndex
    asl
    clc
    adc chordIndex
    tay

    lda chord, Y
    Scale(transpose, scale)
    ldx #0
    sta _voiceNoteNumber, X
    
    iny
    lda chord, Y
    Scale(transpose, scale)
    ldx #1
    sta _voiceNoteNumber, X

    iny
    lda chord, Y
    Scale(transpose, scale)
    ldx #2
    sta _voiceNoteNumber, X
}

.macro TriggerOn(voiceNumber) {
    ldy #voiceNumber
    lda _voiceControl, Y
    sta SID_V1_CONTROL + (voiceNumber * 7)
}

.macro TriggerOff(voiceNumber) {
    ldy #voiceNumber
    lda _voiceControl, Y
    and #%11111110
    sta SID_V1_CONTROL + (voiceNumber * 7)
}