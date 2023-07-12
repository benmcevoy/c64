#importonce 
#import "_prelude.lib"
#import "Config.asm"

// turn on
//#define MIDI

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

_noteNumber: .byte 0
_index: .byte 0

InitMidi: {
    Set MidiControl:#MidiReset
    Set MidiControl:#MidiEnable

    rts
}

.macro TriggerMidiOn(voiceNumber) {
    // $9n is note on, channel n
    lda #$90
    ora #voiceNumber
    tax
    _transmitMidi()
    
    ldy #voiceNumber
    lda _voiceNoteNumber, Y
    tax
    _transmitMidi()

    inc _index
    ldx _index
    lda _random20,X
    clc; adc #Velocity
    tax
    _transmitMidi()
}

.macro TriggerMidiOff(voiceNumber) {
    // $8n is note off, channel n
    lda #$80
    ora #voiceNumber
    tax
    _transmitMidi()
    
    ldy #voiceNumber
    lda _voiceNoteNumber, Y
    tax
    _transmitMidi()
    
    ldx #0
    _transmitMidi()
}

.macro PollForMidiMessage() {
        lda MidiStatus
        lsr
        bcc exit

        lda MidiReceive
        // ignore the channel (lower nybble)
        and #$F0
        // Bx are control change messages
        // 90 is note on
        cmp #$90
        bne flush

    // bit 0 on MidiStatus is strobed for every byte
    rx: lda MidiStatus
        lsr
        bcc rx
                
        lda MidiReceive
        sta _noteNumber
        clc

        // here .Y is the index into chords and accent_chords
        // .X is the chord shape, currently 0,2,4
        ldy #0
        ldx #0 // chord scale index 0
        adc scale,X
        sta chords,Y
        adc #24
        ldy #3
        sta chords,Y

        lda _noteNumber
        ldx #2  // chord scale index 1
        ldy #1
        adc scale,X
        sta chords,Y
        adc #24
        ldy #4
        sta chords,Y

        lda _noteNumber
        ldx #4 // chord scale index 2
        ldy #2
        adc scale,X
        sta chords,Y
        adc #24
        ldy #5
        sta chords,Y

    flush:
        lda MidiReceive
        lda MidiStatus
        lsr
        bcs flush
    exit:    
}

.macro _transmitMidi() {
    _txMidi:
    lda MidiStatus
    lsr
    lsr
    // testing for the Tx to be high
    bcc _txMidi
    stx MidiTransmit 
}

#endif