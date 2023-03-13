#importonce

.const scale_length = 7
.const chord_length = 7
.const steps = 8

// tempo in units of "frame count"
_tempo: .byte 12
_tempoIndicator: .byte 3
_stepIndex: .byte 0
_selectedVoice: .byte 0
_transpose: .byte 0
_chord: .byte 0
_echoOn: .byte 0

.const CHANNEL_VOICE1 = 0
.const CHANNEL_VOICE2 = 1
.const CHANNEL_VOICE3 = 2
.const CHANNEL_OCTAVE1 = 3
.const CHANNEL_OCTAVE2 = 4
.const CHANNEL_OCTAVE3 = 5
.const CHANNEL_FILTER = 6
.const CHANNEL_TEMPO = 7
.const CHANNEL_PATTERN = 8

_patternIndex: .byte 2

.align $100
_beatPatterns:
// going across are the patterns
    _voice1NumberOfBeats: .byte 5,5,4,0,0,0,0,0
    _voice2NumberOfBeats: .byte 4,2,3,0,0,0,0,0
    _voice3NumberOfBeats: .byte 4,5,5,0,0,0,0,0
    _octave1NumberOfBeats: .byte 4,3,4,0,0,0,0,0
    _octave2NumberOfBeats: .byte 2,1,5,0,0,0,0,0
    _octave3NumberOfBeats: .byte 3,3,8,0,0,0,0,0,0
    _filterNumberOfBeats: .byte 1,5,6,0,0,0,0,0

_rotationPatterns:
    _voice1Rotation: .byte 3,1,0,0,0,0,0,0
    _voice2Rotation: .byte 1,0,0,0,0,0,0,0
    _voice3Rotation: .byte 0,7,0,0,0,0,0,0
    _octave1Rotation: .byte 0,4,0,0,0,0,0,0
    _octave2Rotation: .byte 7,0,0,0,0,0,0,0
    _octave3Rotation: .byte 6,4,0,0,0,0,0,0
    _filterRotation: .byte 0,5,0,0,0,0,0,0

_voiceOn: .byte 0,0,0,0,0,0,0
_voiceNoteNumber: .byte 0,0,0,0,0,0,0
_voiceControl: .byte 0,0,0

_delay0_on: .byte 12,13,14
_delay0_off: .byte 14,15,16
_delay1_on: .byte 24,25,26
_delay1_off: .byte 26,27,28
_delay2_on: .byte 36,37,38
_delay2_off: .byte 38,39,40
_delay3_on: .byte 48,49,50
_delay3_off: .byte 50,51,52

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

_tempo_fill:
    .byte 64,32,24,16,12,08,06,04

.align $100
_random20: .fill 256,round(5*random())

