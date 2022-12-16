#importonce
#import "_prelude.lib"

BasicUpstart2(Start)
    _frameCounter: .byte 1
    _tempo: .byte 64


Start: {

    Set $d020:#BLACK
    Set $d021:#BLACK
    // set to 25 line text mode and turn on the screen
	Set $d011:#$1B
	// disable SHIFT-Commodore
	Set $0291:#$80
   	// set screen memory ($0400) and charset bitmap offset ($2000)
    Set $d018:#$18

    // clear screen
    jsr $E544

 // Raster IRQ
    sei
        // disable cia timers
        lda    #$7f
        sta    $dc0d

        // clear high bit of raster flag
        // lda    #$1b
        // sta    $d011
        // enable raster irq
        lda $d01a                     //; enable raster irq
        ora #$01
        sta $d01a
        lda $d011                    // ; clear high bit of raster line
        and #$7f
        sta $d011

        // set next irq line number
        lda    #10
        sta    $d012
        
        lda #<OnRasterInterrupt            
        sta $0314
        lda #>OnRasterInterrupt
        sta $0315
        // sta    $dc0c
        // lda    $dc0d
        // lda    $dc0c
    cli

    jmp *
}

OnRasterInterrupt: {

        // ack irq
        lda $d019
        sta $d019
            // set next irq line number
    lda    #1
    sta    $d012
        // inc $d020
        // dec _readInputInterval
        // bne !+
        //     jsr ReadInput
        //     Set _readInputInterval:#readInputDelay
        // !:
        
        // inc $d020
        // jsr Render
        
        inc $d020
        dec _frameCounter
        beq !+
            jmp nextFrame
        !: 

    stepStart:
        inc $d020
        Set _frameCounter:_tempo

        // inc _stepIndex
        // lda _stepIndex
        // cmp #steps
        // bne !+
        //     Set _stepIndex:#0
        // !:

        // // TriggerMidiOff(0)
        // // TriggerMidiOff(1)
        // // TriggerMidiOff(2)
        
        // TriggerChord()

        // TriggerBeat(0, Square)
        // TriggerBeat(1, Square)
        // TriggerBeat(2, Square)

        // // filter
        // ldx _filterIndex
        // lda _filter, X
        // sta SID_MIX_FILTER_CUT_OFF_HI
        // inc _filterIndex

    nextFrame:
        dec $d020
        // end irq

        pla;tay;pla;tax;pla
        rti          
    }
