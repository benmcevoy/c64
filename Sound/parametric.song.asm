#importonce
#import "sid.asm"
#import "notes.asm"

.namespace Sound {
    /// pw_low, pw_hi, control, AD, SR, tune
    instrument0: .byte  $00, $40, %00100000, $40, $AA, $0
    instrument1: .byte  $00, $00, %00010010, $20, $88, $8
    bassInstrument: .byte  $00, $20, %01110000, $00, $6A, $14

    arp: 
    .byte A3, beat1, $00, A4, beat1, $00,C4, beat1, $00,A3, beat1, $00, A4, beat1, $00,C4, beat1, $00,A3, beat1, $00,C4, beat1, $00, A3, beat1, $00,B4, beat1, $00,A3, beat1, $00,C4, beat1, $00, B4, beat1, $00,A3, beat1, $00,G3, beat1, $00,C4, beat1, $00
    .byte A3, beat1, $00,A4, beat1, $00,A3, beat1, $00,C4, beat1, $00, A3, beat1, $00,A4, beat1, $00,C4, beat1, $00,A3, beat1, $00, B4, beat1, $00,C4, beat1, $00,A3, beat1, $00,B4, beat1, $00, A3, beat1, $00,C4, beat1, $00,B4, beat1, $00,G3, beat1, $00
    .byte $ff

    rest: .byte REST, beat4, $00, REST, beat4, $00, REST, beat4, $00, REST, beat4, $00
    .byte $ff

    bass1: 
    .byte A2, beat1, $00,A2, beat1, $00,A2, beat2, $1f, A2, beat1, $00,A2, beat1, $00,A2, beat1, $00,A2, beat1, $00, A2, beat1, $00,A2, beat1, $00,A2, beat2, $1f, A2, beat1, $00,A2, beat1, $00,A2, beat1, $00,A2, beat1, $00
    .byte $ff

    bass2: 
    .byte E1, beat1, $00,E1, beat1, $00,E1, beat2, $1f, E1, beat1, $00,E1, beat1, $00,E1, beat1, $00,E1, beat1, $00, E1, beat1, $00,E1, beat1, $00,E1, beat2, $1f, E1, beat1, $00,E1, beat1, $00,E1, beat1, $00,E1, beat1, $00
    .byte $ff
    
    bass3: 
    .byte C1, beat1, $00,C1, beat1, $00,C1, beat2, $1f, C1, beat1, $00,C1, beat1, $00,C1, beat1, $00,C1, beat1, $00, C1, beat1, $00,C1, beat1, $00,C1, beat2, $1f, C1, beat1, $00,C1, beat1, $00,C1, beat1, $00,C1, beat1, $00 
    .byte $ff
    
    filter: 
    // round(resolution + dcOffset + resolution * sin(toradians(i * 360 * f / resolution )))
    // e.g. fill sine wave offset 16 with 4 bit resolution
    .var speed = 1; .var low = 3; .var high = 7

    .fill 16,round(high+low+high*sin(toRadians(i*360*(speed+0)/high)))
    .fill 16,round(high+low+high*sin(toRadians(i*360*(speed+0)/high)))

    .eval high = 12
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
    
    .eval high = 8
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
    
    .eval high = 12
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))

    .eval high = 8
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+4)/high)))
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
    .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
    .byte $ff

    voice1: .word arp,arp,arp,arp,arp,arp,arp,arp, $ffff 
    voice2: .word rest, rest, arp,arp,arp,arp,arp,arp,arp, $ffff
    voice3: .word arp, arp, bass1,bass1,bass1,bass1,bass2,bass3,bass1,bass1,bass1,bass1,bass1,bass1, $ffff

    controlChannel: .word filter, $ffff
}