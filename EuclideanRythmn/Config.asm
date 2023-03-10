#importonce

.const scale_length = 7
.const chord_length = 7
.const steps = 8
.const echo = 24
.const tails = 8

// tempo in units of "frame count"
_tempo: .byte $10
_tempoIndicator: .byte 3
_stepIndex: .byte 0
_selectedVoice: .byte 0
_transpose: .byte 0
_chord: .byte 0


// TODO: voices are a bad name :) yes. how about "channel"
// and naming the channels would help a lot
// v6 (chord) must be 1.  voices are a bad name :) v0, v1, v2,  octave0, octave1, octave2, chord, tempo, filter
_voiceNumberOfBeats: .byte 1,0,0,0,0,0,1,0,0
// offset 0-8
_voiceRotation: .byte 3,4,5,0,0,0,0,0,0
// flags
_voiceOn: .byte 0,0,0,0,0,0,0,0,0
_voiceNoteNumber: .byte 0,0,0,0,0,0,0,0,0
_voiceVolume: .byte 0,0,0
_voiceControl: .byte 0,0,0

_delay0_on: .byte 112
_delay0_off: .byte 110
_delay1_on: .byte 96
_delay1_off: .byte 94
_delay2_on: .byte 80
_delay2_off: .byte 78
_delay3_on: .byte 64
_delay3_off: .byte 62


.print _tempo

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

