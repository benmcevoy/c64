#importonce

// _voiceControl: .byte %010100001, %010100001, %010100001

_stepIndex: .byte 0
_selectedVoice: .byte 0
_steps: .byte 8
_transpose: .byte 4

// between 0-8 (_steps=8)
_voiceNumberOfBeats: .byte 1,0,0
// offset 0-8
_voiceOffset: .byte 3,4,2
// flags
_voiceOn: .byte 0,0,0

// double up the sequence so we can offset into it
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