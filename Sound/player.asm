BasicUpstart2(Start)

#import "_prelude.lib"
#import "sound.asm"

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    // clear screen
    jsr $E544
    jsr Sound.Init

    // TODO: try move to a raster irq see if that sounds better
    sei
        lda #<Sound.Play
        sta $0314    
        lda #>Sound.Play
        sta $0315
    cli

    rts
}