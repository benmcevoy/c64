BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

#import "_prelude.lib"
#import "sound.asm"
#import "vision.asm"

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    // clear screen
    jsr $E544
    jsr Sound.Init

    sei
        lda #<Sound.Play
        sta $0314    
        lda #>Sound.Play
        sta $0315
    cli

    loop:
        jsr Vision.Update
        jmp loop
}