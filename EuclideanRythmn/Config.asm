#importonce
#import "Sid.asm"

.const scale_length = 7
.const STEPS = 8
.const readInputDelay = 6

.const CHANNEL_VOICE1 = 0
.const CHANNEL_VOICE2 = 1
.const CHANNEL_VOICE3 = 2
.const CHANNEL_OCTAVE1 = 3
.const CHANNEL_OCTAVE2 = 4
.const CHANNEL_OCTAVE3 = 5
.const CHANNEL_FILTER = 6
.const CHANNEL_METER = 7

.const CHANNEL_PATTERN = 8
.const CHANNEL_TEMPO = 9
.const CHANNEL_ECHO = 10
.const CHANNEL_COPY = 11
.const CHANNEL_PASTE = 12
.const CHANNEL_AUTO = 13
.const CHANNEL_RANDOM = 14

_frameCounter: .byte 0
_stepIndex: .byte 0
_selectedVoice: .byte 0
_transpose: .byte 4

_chord: .byte 0
// currently active chord index
_chordCurrentIndex: .byte 0
// which beat are we on on the chord "wheel"
_chordIndex: .byte 0

_measureCounter: .byte 0
_beatsPerMeasure_Index: .byte 4
_beatsPerMeasure_LUT: .byte 128,64,32,16,8,4,2,1

_echoOn: .byte $0
// proceed is ON when AUTO is ON
_proceedOn: .byte $0
_proceedInterval: .byte 12
_proceedIntervalDelay: .byte 12
_patternIndex: .byte 0
_readInputInterval: .byte readInputDelay

_delay0_on: .byte 12,13,14
_delay0_off: .byte 14,15,16
_delay1_on: .byte 24,25,26
_delay1_off: .byte 26,27,28
_delay2_on: .byte 36,37,38
_delay2_off: .byte 38,39,40
_delay3_on: .byte 48,49,50
_delay3_off: .byte 50,51,52
// clipboard reserves space for 6 voices each with two values - number of beats and rotation, + filter beats and rotation  = 14 bytes
_clipBoard: .fill 16,0

// tempo in units of "frame count"
_tempo: .byte 14
_tempo_Index: .byte 4
// in BPM 47,93,125,188,250,500,750!  i'm feeling that every second beat is a "beat"
_tempo_LUT: .byte 64,32,24,16,12,08,06,04


.align $100
chords: Attempt6()
.label selectedScale = scale_harmonic_minor

.macro Attempt2(){
.byte C2, Eb2, C3
.byte C2, Eb2, G3 
.byte C2, Eb2, Eb3
.byte Bb2, Eb2, F3
.byte Bb2, Eb2, Bb3
.byte C2, Eb2, C3
.byte C2, Eb2, Ab3
.byte C2, Eb2, G2 
}

.macro Attempt1(){
.byte C2, E2, F2
.byte G2, C2, A3 
.byte E2, C3, G3
.byte E2, G2, B3
.byte F1, E2, G2
.byte B2, G2, A3
.byte C2, F2, A3
.byte C2, C3, A3 
}

.macro Attempt3(){
.byte F3, Db2, C4
.byte F3, Db2, F4
.byte C4, Ab3, F4
.byte C4, Ab3, C4
.byte Ab4, Eb2, F4
.byte Ab4, Eb2, F4
.byte G3, F2, C4
.byte G3, F2, F4
}

// pentatonic and a drone
.macro Attempt4(){
.byte C3, D4, C2
.byte C3, D4, C2
.byte G3, E4, C2
.byte G3, E4, C2
.byte A4, G4, C2
.byte A4, G4, C2
.byte C4, A5, C2
.byte C4, A5, C2
}

// blues
.macro Attempt5(){
.byte C2, F4, C4
.byte C2, F4, G4
.byte Eb2, G4, C4
.byte Eb2, G4, G4
.byte F2, Bb5, C4
.byte F2, Bb5, G4
.byte G2, C5, C4
.byte G2, C5, G4
}

// shepard tone?
.macro Attempt6(){
    .byte C2, G2, E3
    .byte A3, E3, C2
    .byte F3, C2, A3
    .byte D2, A3, F3
    .byte B3, F3, D2
    .byte G3, D2, B3
    .byte E2, B3, G3
    .byte C3, G3, E2
 }

 .macro Attempt7(){
    .byte C2, D3, E4
    .byte D3, E4, F2
    .byte E4, F2, G3
    .byte F2, G3, A5
    .byte G3, A5, B3
    .byte A5, B3, C4
    .byte B3, C4, C2
    .byte C4, D2, E3
 }

// drone with a fifth every four beast
 .macro Attempt8(){
    .byte G2, B3, E2
    .byte G3, B3, E2
    .byte G4, B2, E2
    .byte G3, B3, E3
    .byte G3, B3, E2
    .byte G3, B3, E2
    .byte G4, B4, E2
    .byte G3, B3, E3
 }

 .macro Attempt9(){
    .byte G2, Eb2, D3
    .byte G2, Eb2, D3
    .byte Bb3, Eb2, D3
    .byte C3, Eb2, D3
    .byte G2, Eb2, Eb3
    .byte G2, Eb2, Eb3
    .byte G2, Eb2, Eb3
    .byte G2, Eb2, Eb3
 }


.macro HouseProgression() { 
    // house progression
    chord_Dbm: .byte Db2, E2, Ab3
    chord_A: .byte A2, Db2, E2
    chord_E: .byte E2, Ab3, B3
    chord_B: .byte B2, Eb2, Gb2
    chord_Dbm1: .byte Db2, E2, Ab3
    chord_A1: .byte A2, Db2, E2
    chord_E1: .byte E2, Ab3, B3
    chord_B1: .byte B2, Eb2, Gb2
}

.macro CircleOfFifths() {
    // circle of fifths
    // C F B0 Em Am Dm G C
    chord_C: .byte C2, E2, G2
    chord_F: .byte F2, A2, C3
    chord_B0: .byte B3, D2, F2
    chord_Em: .byte E2, G2, B3
    chord_Am: .byte A2, C3, E3
    chord_Dm: .byte D2, F2, A3
    chord_G: .byte G2, B3, D2
    chord_C2: .byte C3, E2, G2
}

.macro CRoot() {
chord0: .byte C2, E2, G2
chord1: .byte A2, C3, E3
chord2: .byte F2, A2, C3
chord3: .byte D2, F2, A3
chord4: .byte G2, B3, D2
chord5: .byte E2, G2, B3
chord6: .byte B3, D2, F2
chord7: .byte C3, E2, G2
}

.macro GalaticCore() {
    // "galatic core"
    // C, Am, F, Dm, G, Em, Bdim, C
    // Bdim is B D F#
    // https://www.youtube.com/watch?v=wtkYFQi8GpM 
    chord_C2: .byte C2, E2, G2
    chord_Am: .byte A2, C3, E3
    chord_F: .byte F1, A3, C3
    chord_Dm: .byte D2, F2, A3
    chord_B0: .byte B2, D2, F2
    chord_G: .byte G1, B2, D2
    chord_Em: .byte E2, G2, B3
    chord_B01: .byte B2, D2, F2
    chord_F1: .byte F1, A3, C3
}

.macro DropDGuitar() {
    .byte D3,Gb3,A4
    .byte E3,G3,B3
    .byte Gb3,A4,Db4
    .byte D3,G3,A4
    .byte D3,A4,A4
    .byte D3,B4,A4
    .byte D3,Gb3,B3
    .byte D3,Gb3,B3    
}

.macro Hallelujah() {
    chord_C2: .byte C2, E2, G2
    chord_Am: .byte A2, C3, E3
    chord_F: .byte F2, A2, C3
    chord_G: .byte G2, B3, D2
    chord_C21: .byte C2, E2, G2
    chord_F2: .byte F2, A2, C3
    chord_E7: .byte B2, D3, Ab4
    chord_Am2: .byte A2, C3, E3
}

.macro BornSlippy() {
    chord_CG2: .byte E2, G2, C3
    chord_EfSus4: .byte D2, A3, B3
    chord_Em: .byte E2, B3, E3
    chord_C2: .byte C2, E2, G2
    // repeat
    .byte E2, G2, C3
    .byte D2, A3, B3
    .byte E2, B3, E3
    .byte C2, E2, G2
}

.macro MinorChords() {
   chord_Cm: .byte C2, Eb2, G2 
   chord_Gm: .byte G2, Bb2, D2 
   chord_Fm: .byte F2, Ab2, C2 
   chord_Gm1: .byte G2, Bb2, D2 
   chord_Cm1: .byte C2, Eb2, G2 
   chord_Gm2: .byte G2, Bb2, D2 
   chord_Fm2: .byte F2, Ab2, C2 
   chord_Gm3: .byte G2, Bb2, D2 
}



// https://en.wikipedia.org/wiki/List_of_musical_scales_and_modes
scale_acoustic: .byte 0,2,4,6,7,9,10,12 // W-W-W-H-W-H-W 
scale_aeolian: .byte  0,2,3,5,7,8,10,12
scale_super_locrian: .byte 0,1,3,4,6,8,10,12
scale_enigmatic: .byte 0,1,4,6,8,10,11,12
scale_double_harmonic: .byte 0,1,4,5,7,8,11,12
scale_flamenco: .byte 0,1,4,5,7,8,11,12
scale_gypsy: .byte 0,2,3,6,7,8,10,12
scale_half_diminshed: .byte 0,2,3,5,6,8,10,12
scale_harmonic_major: .byte 0,2,4,5,7,8,11,12
scale_harmonic_minor: .byte 0,2,3,5,7,8,11,12
scale_phrygian: .byte 0,1,3,5,7,8,10,12
scale_phrygian_dominant: .byte 0,1,4,5,7,8,10,12
scale_circle_harmonic_major: .byte 0,5,11,2,7,12,4,8

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


.align $100  // 128 bytes
 _beatPatterns:
// going across are the patterns
    _voice1NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _voice2NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _voice3NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _octave1NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _octave2NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _octave3NumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _filterNumberOfBeats: .byte 0,0,0,0,0,0,0,0
    _chordNumberOfBeats: .byte 8,8,8,8,8,8,8,8

_rotationPatterns:
    _voice1Rotation: .byte 0,0,0,0,0,0,0,0
    _voice2Rotation: .byte 0,0,0,0,0,0,0,0
    _voice3Rotation: .byte 0,0,0,0,0,0,0,0
    _octave1Rotation: .byte 0,0,0,0,0,0,0,0
    _octave2Rotation: .byte 0,0,0,0,0,0,0,0
    _octave3Rotation: .byte 0,0,0,0,0,0,0,0
    _filterRotation: .byte 0,0,0,0,0,0,0,0
    _chordRotation: .byte 0,0,0,0,0,0,0,0
    
_patternNumberOfBeats: .byte 1,1,1,1,1,1,1,1    
_patternRotation: .byte 0,0,0,0,0,0,0,0
_voiceOn: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.print _beatPatterns
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

.align $100
_random20: .fill 256,round(5*random())    