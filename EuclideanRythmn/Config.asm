#importonce

// _voiceControl: .byte %010100001, %010100001, %010100001

.const scale_length = 7

 _frameInterval: .byte 32

_stepIndex: .byte 0
_selectedVoice: .byte 0
_steps: .byte 8
_transpose: .byte 4

// between 0-8 (_steps=8)
_voiceNumberOfBeats: .byte 1,0,0
// offset 0-8
_voiceOffset: .byte 4,4,4
// flags
_voiceOn: .byte 0,0,0

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