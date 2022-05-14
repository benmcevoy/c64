BasicUpstart2(Start)

#import "_prelude.lib"
#import "sound.asm"

// # Commands:
// control commands, e.g. filter, tempo
// instrument commands, e.g. detune, change waveform, change envelope, clock skew, etc 
//  - these mess with the instrument state and are persistant
//  - indicates some cohesion, e.g. move clock skew, detune to be part of an instrument
// voice commands - e,g, set current instrument
// pattern commands, e.g. set next pattern
//  - thinking these are declared instead as a "song" defn.
//  - come up with some data structure

// basic command structure was name:data
// expect #note_number, #sustain/velocity, #command, #data
// trying to be influenced by MIDI

// i don't want to build commands up front, just get some design pattern
// actual commands are dictated by the song

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    // clear screen
    jsr $E544
    jsr Sound.Init

    // Raster IRQ
    sei
        lda #<Sound.Play            
        sta $0314
        lda #>Sound.Play
        sta $0315

        // clear high bit of raster flag
        lda    #$1b
        sta    $d011
        // enable raster irq
        lda    #$01
        sta    $d01a
        // disable cia timers
        lda    #$7f
        sta    $dc0d
        sta    $dc0c
        lda    $dc0d
        lda    $dc0c
    cli

    jmp *
}