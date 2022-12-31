#importonce

.const STRIDE = 5

.const VOICE_NUMBER_OF_BEATS = 0
.const VOICE_ROTATION = 1
.const VOICE_TRANSPOSE = 2
.const VOICE_INSTRUMENT = 3
.const VOICE_TTL = 4

.const OSCILLATOR1 = 0
.const OSCILLATOR2 = 1
.const OSCILLATOR3 = 2
.const ACCENT1 = 3
.const ACCENT2 = 4
.const ACCENT3 = 5
.const CHORD = 6
.const TEMPO = 7
.const FILTER = 8

_voicePatternIndex: .byte 0,0,0,0,0,0,0,0,0
_voicePatternTTL: .byte 0,0,0,0,0,0,0,0,0
// index 6 is CHORD must be 1
_voiceNumberOfBeats: .byte 0,0,0,0,0,0,1,5,0
_voiceRotation: .byte 0,0,0,0,0,0,0,0,0
_voiceNoteNumber: .byte 0,0,0,0,0,0,0,0,0

.const steps = 8
_stepIndex: .byte 0

// double up the sequence so we can offset into it
.align $100
_rhythm: 
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
    .byte 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0
    .byte 1,0,0,1,0,0,1,0,1,0,0,1,0,0,1,0
    .byte 1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
    .byte 1,0,1,1,0,1,1,0,1,0,1,1,0,1,1,0
    .byte 1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1
    .byte 1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

// tempo in units of "frame count"
_tempo_fill:
    .byte 64,32,24,16,12,08,06,04

