BasicUpstart2(Start)

#import "_prelude.lib"
#import "_charscreen.lib"

Start: {
    Set $d020:#0
    Set $d021:#0

    // this just sets voice3 osciallting a triangle wave at $0110 freq whatever that is
    // there might be interesting behaviour in here
    // you can also read the voice 3 ADSR register
    // and i think you can feed the other voices in? I can't recall...
    // could be a very efficient way to do some effects, like screen wipes
    // or generally as a function to generate sine waves (shit ones)

    // synchronization means that as one voice passes through "0" this resets the synchronized voice to also start from zero
    // ringmod is more intersesting.  The triangle  waveform substitues as a "carrier" wave and is then modulated by another voice
    // voice 3 can ringmod with voice 2, not sure which has to be a triangle...
    // voice 3 must be triangle

    // init sid noise for random

    // voice 3 frequency low byte
    Set $D40E:#$60 
    // voice 3 frequency high byte
    Set $D40F:#$0
    // v3 waveform
    Set $D412:#%00010101
    // set v3 sustain
    Set $d414:#%11110000

    // setup v2 for ring mod with v3
    // f lo
    Set $D407:#$00
    // f hi
    Set $D408:#$20
    // v2 voice
    Set $d40b:#%00010000
    // set v2 sustain
    Set $d40d:#%11110000

    // master volume
    Set $d418:#%00001000

    // Raster IRQ
    sei
        lda #<Update            
        sta $0314
        lda #>Update
        sta $0315

        // clear high bit of raster flag
        lda    #$20
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
    
  rts
}

// very clever, i learnt something from the bit manipulation when drawing lo-res text
// low bit's skip a frame
rotor: .byte %00000000

Update:{
    // ack irq
    lda    #$01
    sta    $d019
    // set next irq line number
    lda    #10
    sta    $d012

    // this is a very crappy sine triangle wave
    // read sid wave out
    lda $d41b
    // cut it down to 0..16 for colour
    lsr;lsr;lsr;lsr

    tax
    lda palette,X

    sta $d020
    sta $d021
    // messes with the fps, on off on off etc
    lda rotor
    rol 
    sta rotor
    bcc !+
        inc $D408
    !:

    exit:
    // end irq
    pla;tay;pla;tax;pla
    rti 
    //palette: .byte 2,6,2,6,2,6,2,6,2,6,2,6,2,6,2,6
    palette: .byte 6,11,4,14,5,3,13,7,1,1,7,13,15,5,12,8,2,9,2,9

}