#importonce

// _voiceControl: .byte %010100001, %010100001, %010100001

.const scale_length = 7
.const chord_length = 7
.const steps = 8

// tempo in units of "frame count"
_tempo: .byte 20
_stepIndex: .byte 0
_selectedVoice: .byte 0
_transpose: .byte 4
_chord: .byte 0

// v6 (chord) must be 1.  voices are a bad name :) v0, v1, v2,  octave0, octave1, octave2, chord, tempo, filter
_voiceNumberOfBeats: .byte 1,0,0,0,0,0,1,0,0
// offset 0-8
_voiceRotation: .byte 3,4,5,0,0,0,0,0,0
// flags
_voiceOn: .byte 0,0,0,0,0,0,0,0,0
_voiceNoteNumber: .byte 0,0,0,0,0,0,0,0,0

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

// offset yet as addressing is a pain > 256 bytes
_rhythm16:
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 // 1
    .byte 1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
    .byte 1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0
    .byte 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0
    .byte 1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0
    .byte 1,0,0,1,0,1,0,0,1,0,0,1,0,1,0,0
    .byte 1,0,0,1,0,1,0,1,0,0,1,0,1,0,1,0
    .byte 1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0 // 8
    .byte 1,0,1,1,0,1,0,1,0,1,1,0,1,0,1,0 
    .byte 1,0,1,1,0,1,0,1,1,0,1,1,0,1,0,1
    .byte 1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1
    .byte 1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1 // 12
    .byte 1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1
    .byte 1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

