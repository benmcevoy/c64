#importonce
#import "sid.asm"

.namespace Sound {
    // PW is 12 bits, so only low nibble of PW_HI is used
    // pw_low, pw_hi, control, AD, SR, tune
    instrument0: .byte  $00, $00, %00100000, $4B, $04, 0
    instrument1: .byte  $00, $00, %00110000, $4b, $04, 3 
    bassInstrument: .byte  $80, $09, %01000000, $06, $0F, 6

    //instrument0: .byte  $80, $09, %00100000, $00, $81, 0
    //instrument1: .byte  $80, $09, %00110000, $00, $81, 3
}