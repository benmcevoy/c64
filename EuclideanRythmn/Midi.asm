#importonce 
#import "_prelude.lib"
#import "Config.asm"

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

.label MidiControl = $DE00
.label MidiStatus = $DE02
.label MidiTransmit = $DE01
.const Velocity = 100

.macro TriggerMidiOff(voiceNumber) {
    // $8n is note off, channel n
    lda #$80
    ora #voiceNumber
    tax
    jsr TransmitMidi 
    
    ldy #voiceNumber
    lda _voiceNoteNumber, Y
    // my note numbers are not midi note number, add 8 to line them up
    clc; adc #8
    tax
    jsr TransmitMidi
    
    ldx #Velocity
    jsr TransmitMidi
}

.macro TriggerMidiOn(voiceNumber) {
    // $9n is note on, channel n
    lda #$90
    ora #voiceNumber
    tax
    jsr TransmitMidi 
    
    ldy #voiceNumber
    lda _voiceNoteNumber, Y
    // my note numbers are not midi note number, add 8 to line them up
    clc; adc #8
    tax
    jsr TransmitMidi

    ldx #Velocity
    jsr TransmitMidi
}

TransmitMidi: {
    lda MidiStatus
    lsr
    lsr
    // testing for the Tx to be high
    bcc TransmitMidi
    stx MidiTransmit 
    rts
}

InitMidi: {
    // reset
    Set MidiControl:#$03
    // not too sure but it makes noise :)
    // bit 7 - Rx disable, bit 6,5 tx enable?, bit 4,3,2 - 8 bit no parity, bit 1,0 counter divide by 1
    Set MidiControl:#%00110000
    
    rts
}