#importonce
#import "sid.asm"
#import "notes.asm"

.namespace Sound {

    psytrance1: 
        .byte E2, beat1, $00, E3, beat1,$00, E2, beat1, $00,REST, beat1,$00, D3, beat1,$00, E2, beat1,$00,REST, beat1,$00,G3, beat1,$00
        .byte $ff
    psytrance2: 
        .byte A2, beat1, $00,A3, beat1,$00, A2, beat1,$00, REST, beat1,$00, C3, beat1,$00, A2, beat1,$00,REST, beat1,$00,E3, beat1,$00
        .byte $ff   
    psytrance3: 
        .byte D2, beat1, $00, D3, beat1, $00, D2, beat1, $00, REST, beat1, $00, F3, beat1, $00, D2, beat1, $00,REST, beat1, $00,A4, beat1, $00
        .byte $ff   

    silence: .byte REST,TEMPO,$00,$ff  

    ifeellove1:
        .byte F2,beat1, $00
        .byte F2,beat1, $1f
        .byte F2,beat1, $00
        .byte F2,beat1, $1f
        .byte C2, TEMPO*2, $00
        .byte Eb2, TEMPO*2, $1f
        .byte $ff
    ifeellove2:
        .byte Ab3,beat1, $00
        .byte Ab3,beat1, $1f
        .byte Ab3,beat1, $00
        .byte Ab3,beat1, $1f
        .byte Eb2, TEMPO*2, $00
        .byte Gb2, TEMPO*2, $00
        .byte $ff
    ifeellove3:
        .byte Bb3,beat1, $00
        .byte Bb3,beat1, $1f
        .byte Bb3,beat1, $00
        .byte Bb3,beat1, $1f
        .byte F2, TEMPO*2, $00
        .byte Ab3, TEMPO*2, $00
        .byte $ff

    arpUpDown1: 
        .byte C3, beat2, $00 
        .byte E3, beat2, $1f
        .byte G3, beat2, $00
        .byte C4, beat2, $00
        .byte G3, beat2, $00
        .byte E3, beat2, $1f
        .byte $ff
    arpUpDown2: 
        .byte C3, beat2, $00 
        .byte E3, beat2, $00
        .byte G3, beat2, $1f
        .byte C4, beat2, $00
        .byte G3, beat2, $1f
        .byte E3, beat2, $00
        .byte $ff
    arpUpDown3: 
        .byte C3, beat2, $1f
        .byte E3, beat2, $00
        .byte G3, beat2, $00
        .byte C4, beat2, $1f
        .byte G3, beat2, $00
        .byte E3, beat2, $00
        .byte $ff 

    pulse: 
        .byte C3, beat1, $00
        .byte C3, beat1, $00
        .byte C3, beat2, $1f
        .byte C3, beat1, $00
        .byte C3, beat1, $00
        .byte C3, beat1, $00
        .byte C3, beat1, $00
        .byte $ff    

    pulseAlt: 
        .byte E3, beat1, $1f
        .byte E3, beat1, $18
        .byte E3, beat1, $1f
        .byte E3, beat1, $18
        .byte E3, beat1, $1f
        .byte E3, beat1, $1f
        .byte E3, beat1, $18
        .byte E3, beat1, $1f
        .byte $ff                                   

    filter: 
    // round(resolution + dcOffset + resolution * sin(toradians(i * 360 * f / resolution )))
    // =3+(1+SIN(A1*PI()/180*10))*2
    // e.g. fill sine wave offset 16 with 4 bit resolution
    .var speed = 1; .var low = 3; .var high = 7

    .fill 16, 2+i
    .fill 16, 18-i
    
    .byte $ff

    /* ***************************** SONG ***************************** */
    // voice1: 
    //     .word ifeellove1,ifeellove1,ifeellove1,ifeellove1
    //     .word ifeellove2,ifeellove2,ifeellove2,ifeellove2
    //     .word ifeellove3,ifeellove3,ifeellove3,ifeellove3
    //     .word $ffff

    // voice1: 
    // voice2:
    // voice3:
    // .word ifeellove1,ifeellove1,ifeellove1,ifeellove1
    // .word ifeellove2,ifeellove2,ifeellove2,ifeellove2
    // .word ifeellove3,ifeellove3,ifeellove3,ifeellove3
    // .word $ffff

    
   // voice3:        .word silence, $ffff

    voice1:         
         .word psytrance1, psytrance1, psytrance1, psytrance1, psytrance2, psytrance2, psytrance2, psytrance2, psytrance3,psytrance3,psytrance3,psytrance3, psytrance1, psytrance1, psytrance1, psytrance1,$ffff
    voice2: 
        .word psytrance1, psytrance1, psytrance1, psytrance1, psytrance2, psytrance2, psytrance2, psytrance2, psytrance3,psytrance3,psytrance3,psytrance3, psytrance1, psytrance1, psytrance1, psytrance1,$ffff
    voice3: 
        .word psytrance1, psytrance1, psytrance1, psytrance1, psytrance2, psytrance2, psytrance2, psytrance2, psytrance3,psytrance3,psytrance3,psytrance3, psytrance1, psytrance1, psytrance1, psytrance1,$ffff        
    controlChannel:
        .word filter, $ffff
}