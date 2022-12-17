BasicUpstart2(Start)

#import "_prelude.lib"
#import "char/chars.asm"
#import "char/screen.asm"
#import "Tempo.asm"

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    // clear screen
    jsr $E544

    jsr Screen.Draw

    jsr Tempo.Init

    // turning on midi seems to screw up IRQ
    // TODO: read the documentation :)
    // jsr InitMidi

    // Raster IRQ
    sei
        // disable cia timers
        lda    #$7f
        sta    $dc0d
        
        // enable raster irq
        lda $d01a                     
        ora #$01
        sta $d01a
        lda $d011                    
        and #$7f
        sta $d011

        // set next irq line number
        lda    #1
        sta    $d012
        
        lda #<Tempo.OnRasterInterrupt            
        sta $0314
        lda #>Tempo.OnRasterInterrupt
        sta $0315
    cli

    jmp *
}