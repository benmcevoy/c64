#importonce

.const vControl = %00100001

_stepIndex: .byte 0
_selectedVoice: .byte 0
_steps: .byte 8
_transpose: .byte 4

// between 0-8 (_steps=8)
_voiceNumberOfBeats: .byte 1,0,0
// offset 0-8
_voiceOffset: .byte 2,3,1
// flags
_voiceOn: .byte 0,0,0
