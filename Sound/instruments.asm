#importonce
#import "sid.asm"

.namespace Sound {
    // PW is 12 bits, so only low nibble of PW_HI is used
    // pw_low, pw_hi, control, AD, SR, tune
instrument0: .byte  $00, $40, %00100000, $40, $AA, $0
    instrument1: .byte  $00, $00, %00010010, $20, $88, $8
    bassInstrument: .byte  $00, $20, %01110000, $00, $6A, $14
}