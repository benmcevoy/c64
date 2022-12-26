#importonce
#import "_prelude.lib"
#import "Sid.asm"

// voice state
voices_Phase: .byte 0,0,0
voices_ReferenceNoteNumber: .byte 0,0,0
voices_WaveTableIndex: .byte 0,0,0
voices_F_lo: .byte 0,0,0
voices_F_hi: .byte 0,0,0


.label waveTablePtr = __ptr0
.align $100
wavetables:
_ssine: .fill 256,round(127*sin(toRadians(i*360/256)))
// unsigned Sine table
_usine: .fill 256,round(127.5 + 127*sin(toRadians(i*360/256)))
_saw: .fill 256,i
_triangle: .fill 128,i; .fill 128, 128-i
_noise: .fill 256, round(256*random())

.const SignedSine = $00
.const UnsignedSine = $01
.const Saw = $02
.const Triangle = $03
.const Noise = $04

// voice lfo commands, params: wave, cycle, depth
.const PulseWidthMod = $01
.const FreqMod = $02

// voice note commands
// params: numberOfNotes1, numberOfNotes2 ... numberOfNotesN, END_COMMAND
.const Arpeggio = $11
// params: numberOfNotes
.const Transpose = $12


// mix lfo commands, params: wave, cycle, depth
.const FilterCutoffMod = $21
.const FilterResonanceMod = $22
.const VolumeMod = $23

.const END_INSTRUMENT = $FF
.const END_COMMAND = $FE
.const commandStart = 4

// boring square
boring_square1: 
    .byte $00, $08, $2A, $A2, %01110001
    .byte PulseWidthMod, SignedSine, $01, $01
    //.byte Arpeggio, $00, $12, $24, END_COMMAND
    .byte END_INSTRUMENT

boring_square2: 
    .byte $00, $08, $2A, $A2, %01110001
    .byte PulseWidthMod, SignedSine, $02, $02
    .byte END_INSTRUMENT  

boring_square3: 
    .byte $00, $08, $2A, $A2, %01100001
    .byte PulseWidthMod, SignedSine, $03, $03
    .byte END_INSTRUMENT      

.macro InitInstrument() {
    // setup zero page pointer
    lda <wavetables
    sta waveTablePtr
    lda >wavetables
    sta waveTablePtr + 1
}

.macro LoadInstrument(voiceNumber, instrument) {
    lda instrument
    sta SID_V1_PW_LO + (voiceNumber * 7)
    
    lda instrument+1
    sta SID_V1_PW_HI + (voiceNumber * 7)
    
    lda instrument+2
    sta SID_V1_ATTACK_DECAY + (voiceNumber * 7)
    
    lda instrument+3
    sta SID_V1_SUSTAIN_RELEASE + (voiceNumber * 7)

    lda instrument+4
    sta SID_V1_CONTROL + (voiceNumber * 7)
}

.macro UpdateInstrument(voiceNumber, instrument) {
        ldx #commandStart

    readCommand:
        inx
        lda instrument, X
        cmp #END_INSTRUMENT
        bne !+
            jmp exit
        !:
        
        cmp #PulseWidthMod
        bne !+
            ApplyLFO(voiceNumber, instrument, SID_V1_PW_LO)
        !:

        lda instrument, X
        cmp #FreqMod
        bne !+
            ApplyLFO(voiceNumber, instrument, SID_V1_FREQ_LO)
        !:

        lda instrument, X
        cmp #Arpeggio
        bne !+
            ApplyArpeggio(voiceNumber, instrument)
        !:

        // next command
        jmp readCommand

    exit:
}

.macro ApplyLFO(voiceNumber, instrument, register) {
        // set up wave table pointer
        inx
        lda instrument, X
        clc; adc <wavetables
        sta waveTablePtr

        // apply cycle to phase
        ldy #voiceNumber
        lda voices_Phase, Y
        inx
        clc; adc instrument, X
        sta voices_Phase, Y
        
        // read the LFO
        tay
        lda (waveTablePtr), Y

        // apply depth
        inx 
        ldy instrument, X
    halve:
        cpy #0
        beq modulate
        // keep halving the LFO
        lsr
        dey
        jmp halve

    modulate:
        sta register + (voiceNumber * 7)
        inx
}

// TODO: not right, next to advance the wavetable/arp table PER FRAME not all at once.
// which is the purpose of the voices_WaveTableIndex
// much confusion, i think i need to draw it out on paper...
.macro ApplyArpeggio(voiceNumber, instrument) {
        txa; pha
        
        // check for REST i.e. $00
        ldy #voiceNumber
        lda voices_ReferenceNoteNumber, Y
        beq exit

    readNext:
        inx 
        lda instrument, x

        cmp #END_COMMAND
        bne !+
            ldy #voiceNumber
            lda #0
            sta voices_WaveTableIndex, Y
            jmp exit
        !:

        ldy #voiceNumber
        clc;adc voices_ReferenceNoteNumber, Y

        tay
        lda     freq_msb,Y
        sta     SID_V1_FREQ_HI + (voiceNumber * 7)
        lda     freq_lsb,Y
        sta     SID_V1_FREQ_LO + (voiceNumber * 7)

        jmp readNext

    exit:    


        pla; tax
}
