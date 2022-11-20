#importonce 

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


.const REST = 0;
.const E0 = $14;    .const F0 = $15;    .const Gb0 = $16;    .const G0 = $17;    .const A1 = $18;     .const Ab1 = $19;     .const Bb1 = $1a;   .const B1 = $1b;     .const C1 = $1c;    .const Db1 = $1d;   .const D1 = $1e;     .const Eb1 = $1f
.const E1 = $20;    .const F1 = $21;    .const Gb1 = $22;    .const G1 = $23;    .const Ab2 = $24;    .const A2 = $25;    .const Bb2 = $26;    .const B2 = $27;    .const C2 = $28;    .const Db2 = $29;    .const D2 = $2a;    .const Eb2 = $2b;
.const E2 = $2c;    .const F2 = $2d;    .const Gb2 = $2e;    .const G2 = $2f;    .const Ab3 = $30;    .const A3 = $31;    .const Bb3 = $32;    .const B3 = $33;    .const C3 = $34;    .const Db3 = $35;    .const D3 = $36;    .const Eb3 = $37
.const E3 = $38;    .const F3 = $39;    .const Gb3 = $3a;    .const G3 = $3b;    .const Ab4 = $3c;    .const A4 = $3d;    .const Bb4 = $3e;    .const B4 = $3f;    .const C4 = $40;    .const Db4 = $41;    .const D4 = $42;;    .const Eb4 = $43
.const E4 = $44;    .const F4 = $45;    .const Gb4 = $46;    .const G4 = $47;    .const Ab5 = $48;    .const A5 = $49;    .const Bb5 = $4a;    .const B5 = $4b;    .const C5 = $4c;    .const Db5 = $4d;    .const D5 = $4e;    .const Eb5 = $4f
.const E5 = $50;    .const F5 = $51;    .const Gb5 = $52;    .const G5 = $53;    .const Ab6 = $54;    .const A6 = $55;    .const Bb6 = $56;    .const B6 = $57;    .const C6 = $58;    .const Db6 = $59;    .const D6 = $5a;    .const Eb6 = $5b
.const E6 = $5c;


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
