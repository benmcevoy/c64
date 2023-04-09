#importonce

.const scale_length = 7
.const chord_length = 7
.const steps = 8

.const CHANNEL_VOICE1 = 0
.const CHANNEL_VOICE2 = 1
.const CHANNEL_VOICE3 = 2
.const CHANNEL_OCTAVE1 = 3
.const CHANNEL_OCTAVE2 = 4
.const CHANNEL_OCTAVE3 = 5
.const CHANNEL_FILTER = 6
.const CHANNEL_TEMPO = 7
.const CHANNEL_PATTERN = 8
.const CHANNEL_ECHO = 9
.const CHANNEL_COPY = 10
.const CHANNEL_PASTE = 11
.const CHANNEL_AUTO = 12
.const CHANNEL_RANDOM = 13

// tempo in units of "frame count"
_time: .byte 0
_frameCounter: .byte 0
_tempo: .byte 16
_tempoIndicator: .byte 4
_stepIndex: .byte 0
_selectedVoice: .byte 0
_transpose: .byte 0
_chord: .byte 0
_echoOn: .byte $0
_proceedOn: .byte $0
_patternIndex: .byte 0
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
_clipBoard: .fill 14,0
_tempo_fill: .byte 64,32,24,16,12,08,06,04

//------------------------------------------------------------------------
// aligned data

// random distribution, skew towards 0-5, chance of a 6 or 7 is low, like 1 in 20
// high numbers can be too chaotic
.align $100  // this is a full page
_randomDistribution: 
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  //1 ~6% chance of a REST
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1  
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1  
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1  
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    .byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    .byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    .byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    .byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
    .byte 2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3
    .byte 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
    .byte 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
    .byte 3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4
    .byte 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
    .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
    .byte 6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7  // 16, ~3% chance of 6 or 7



.align $100  // 112 bytes
 _beatPatterns:
// going across are the patterns
    _voice1NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _voice2NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _voice3NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _octave1NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _octave2NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _octave3NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _filterNumberOfBeats: .byte 0,0,0,0,0,0,0,0

_rotationPatterns:
    _voice1Rotation: .byte 0,0,0,0,0,0,0,0
    _voice2Rotation: .byte 0,0,0,0,0,0,0,0
    _voice3Rotation: .byte 0,0,0,0,0,0,0,0
    _octave1Rotation: .byte 0,0,0,0,0,0,0,0
    _octave2Rotation: .byte 0,0,0,0,0,0,0,0
    _octave3Rotation: .byte 0,0,0,0,0,0,0,0
    _filterRotation: .byte 0,0,0,0,0,0,0,0

// chill patterns that are built around 3 beat
// _beatPatterns:  // 8*7 bytes  = 56
// // going across are the patterns
//     _voice1NumberOfBeats: .byte 3,3,3,3,0,3,3,3
//     _voice2NumberOfBeats: .byte 0,1,2,2,0,2,2,1
//     _voice3NumberOfBeats: .byte 0,1,3,3,0,3,3,1
//     _octave1NumberOfBeats: .byte 5,5,4,4,0,4,4,5
//     _octave2NumberOfBeats: .byte 1,1,2,2,0,2,2,1
//     _octave3NumberOfBeats: .byte 1,1,3,3,0,3,3,1
//     _filterNumberOfBeats: .byte 3,3,3,6,0,3,3,3

// _rotationPatterns: // 8*7 bytes  = 56
//     _voice1Rotation: .byte 0,0,0,0,0,0,0,0
//     _voice2Rotation: .byte 0,0,0,0,0,0,0,0
//     _voice3Rotation: .byte 0,2,2,2,0,2,2,2
//     _octave1Rotation: .byte 0,0,0,0,0,0,0,0
//     _octave2Rotation: .byte 0,0,0,0,0,0,0,0
//     _octave3Rotation: .byte 2,2,2,2,0,2,2,2
//     _filterRotation: .byte 7,7,7,7,0,7,7,7

// double up the sequence so we can offset into it
.align $100  // 144 bytes
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