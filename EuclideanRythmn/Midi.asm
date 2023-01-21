#importonce 
#import "_prelude.lib"
#import "Config.asm"

// turn on
#define MIDI

// SEQUENTIAL CIRCUITS INC.
// Mode 	1 MHZ IRQ 	
// Control Register 	$DE00 	Write only
// Status Register 	$DE02 	Read only
// Transmit Data (Tx)	$DE01 	Write only
// Receive Data (Rx) 	$DE03 	Read only
// Midi Reset 	$03 	Master Reset
// Midi Enable 	$15 	Word Select & Counter Divide
// Midi IRQ Enable 	$95 	IRQ ON, Word Select & Counter Divide 

// https://www.codebase64.org/doku.php?id=base:c64_midi_interfaces

#if MIDI
// Sequential Circuits
.label MidiControl = $DE00
.label MidiTransmit = $DE01
.label MidiStatus = $DE02
.label MidiReceive = $DE03
.const Velocity = 100
.const MidiEnable = $15
.const MidiIRQEnable = $95
.const MidiReset = $03

_index: .byte 0

InitMidi: {
    Set MidiControl:#MidiReset
    Set MidiControl: #MidiEnable

    rts
}

.macro TriggerMidiOn(voiceNumber) {
    // $9n is note on, channel n
    lda #$90
    ora #voiceNumber
    tax
    jsr _transmitMidi 
    
    ldy #voiceNumber
    lda _voiceNoteNumber, Y
    tax
    jsr _transmitMidi

    inc _index
    ldx _index
    lda _random20,X
    clc; adc #Velocity
    tax
    jsr _transmitMidi
}

.macro TriggerMidiOff(voiceNumber) {
    // $8n is note off, channel n
    lda #$80
    ora #voiceNumber
    tax
    jsr _transmitMidi 
    
    ldy #voiceNumber
    lda _voiceNoteNumber, Y
    tax
    jsr _transmitMidi
    
    ldx #0
    jsr _transmitMidi
}

.macro PollForMidiMessage() {
        lda MidiStatus
        lsr
        bcc exit

        lda MidiReceive
        // ignore the chaneel (lower nybble)
        and #$F0
        // Bx are control change messages
        cmp #$B0
        bne flush

    // bit 0 on MidiStatus is strobed for every byte
    rx: lda MidiStatus
        lsr
        bcc rx

        lda MidiReceive
        cmp #74
        bne !+
            jsr _cc1
        !:

        cmp #71
        bne !+
            jsr _cc2
        !:

        cmp #73
        bne !+
            jsr _cc3
        !:


    flush:
        lda MidiReceive
        lda MidiStatus
        lsr
        bcs flush
    exit:    
}

_cc1: {
    rx: lda MidiStatus
        lsr
        bcc rx

        lda MidiReceive
        lsr;lsr;lsr;lsr;
        sta _selectedVoice     
    rts
}

_cc2: {
    rx: lda MidiStatus
        lsr
        bcc rx

        lda MidiReceive
        lsr;lsr;lsr;lsr;
        ldy _selectedVoice
        sta _voiceNumberOfBeats, Y
    rts
}

_cc3: {
    rx: lda MidiStatus
        lsr
        bcc rx

        lda MidiReceive
        lsr;lsr;lsr;lsr;
        ldy _selectedVoice
        sta _voiceRotation, Y
    rts
}

_transmitMidi: {
    lda MidiStatus
    lsr
    lsr
    // testing for the Tx to be high
    bcc _transmitMidi
    stx MidiTransmit 
    rts
}

#endif