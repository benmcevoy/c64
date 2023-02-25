#importonce
#import "sid.asm"

.namespace Sound {
    // PW is 12 bits, so only low nibble of PW_HI is used
    // pw_low, pw_hi, control, AD, SR, tune
    instrument0: .byte  $00, $00, %00100000, $0F, $00, 0
    
}