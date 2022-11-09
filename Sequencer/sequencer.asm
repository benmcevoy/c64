BasicUpstart2(Start)

#import "_prelude.lib"
#import "Tempo.asm"

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    // clear screen
    jsr $E544
    jsr Tempo.Init

    // Raster IRQ
    sei
        lda #<Tempo.OnRasterInterrupt            
        sta $0314
        lda #>Tempo.OnRasterInterrupt
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