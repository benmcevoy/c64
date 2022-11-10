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
