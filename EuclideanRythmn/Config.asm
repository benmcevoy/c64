#importonce

// _voiceControl: .byte %010100001, %010100001, %010100001

.const scale_length = 7
.const chord_length = 7
.const steps = 16

// tempo in units of "frame count"
_tempo: .byte 18
_stepIndex: .byte 0
_selectedVoice: .byte 0
_transpose: .byte 4
_chord: .byte 0

// between 0-8 (_steps=8)
// v3 must be 1
_voiceNumberOfBeats: .byte 1,0,0,1
// offset 0-8
_voiceOffset: .byte 0,0,0,0
// flags
_voiceOn: .byte 0,0,0,0
_voiceNoteNumber: .byte 0,0,0,0

// double up the sequence so we can offset into it
.align $100
_rhythm8: 
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
.align $100
_rhythm:
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
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
    .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

