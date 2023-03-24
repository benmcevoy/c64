#importonce

.const scale_length = 7
.const chord_length = 7
.const steps = 8

// tempo in units of "frame count"
_frameCounter: .byte 0
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
.const CHANNEL_ECHO = 9
.const CHANNEL_COPY = 10
.const CHANNEL_PASTE = 11

_patternIndex: .byte 0

.align $100
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
_randomJoy: 
    .byte 10,04,07,03,02,10,03,02,06
    .byte 13,03,04,02,05,02,07,14,03
    .byte 03,05,06,05,04,05,02,05,13
    .byte 05,05,05,05,10,05,05,05,05
    .byte 05,02,05,13,04,07,05,06,05
    .byte 04,13,10,13,13,03,10,14,04

    .byte 13,10,04,14,10,10,04,04,03
    .byte 14,07,03,06,05,06,14,04,13
    .byte 03,05,06,05,13,05,14,05,07
    .byte 05,05,05,05,13,05,05,05,05
    .byte 05,07,05,13,07,13,05,03,05
    .byte 06,10,13,13,03,07,14,14,14

    .byte 03,10,06,10,03,04,10,04,02
    .byte 04,02,06,14,05,07,07,02,07
    .byte 03,05,07,05,14,05,07,05,14
    .byte 05,05,05,05,07,05,05,05,05
    .byte 05,03,05,06,03,07,05,06,05
    .byte 04,14,03,14,06,04,04,03,02

    .byte 03,13,07,03,07,13,02,02,10
    .byte 13,13,06,14,05,02,07,13,03
    .byte 02,05,03,05,10,05,04,05,04
    .byte 05,05,05,05,07,05,05,05,05
    .byte 05,06,05,10,10,14,05,06,05
    .byte 02,04,10,10,02,07,07,14,10

    .byte 03,07,02,10,03,04,13,03,02
    .byte 14,03,13,14,05,14,02,02,03
    .byte 04,05,06,05,04,05,03,05,04
    .byte 05,05,05,05,13,05,05,05,05
    .byte 05,03,05,03,13,14,05,10,05
    .byte 10,13,14,07,04,06,13,02,04
    

    

