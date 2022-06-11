#importonce
#import "sid.asm"

.namespace Sound {
    // notes
    .const REST = 0;
    .const E0 = $14;    .const F0 = $15;    .const Gb0 = $16;    .const G0 = $17;    .const A1 = $18;     .const Ab1 = $19;     .const Bb1 = $1a;   .const B1 = $1b;     .const C1 = $1c;    .const Db1 = $1d;   .const D1 = $1e;     .const Eb1 = $1f
    .const E1 = $20;    .const F1 = $21;    .const Gb1 = $22;    .const G1 = $23;    .const Ab2 = $24;    .const A2 = $25;    .const Bb2 = $26;    .const B2 = $27;    .const C2 = $28;    .const Db2 = $29;    .const D2 = $2a;    .const Eb2 = $2b;
    .const E2 = $2c;    .const F2 = $2d;    .const Gb2 = $2e;    .const G2 = $2f;    .const Ab3 = $30;    .const A3 = $31;    .const Bb3 = $32;    .const B3 = $33;    .const C3 = $34;    .const Db3 = $35;    .const D3 = $36;    .const Eb3 = $37
    .const E3 = $38;    .const F3 = $39;    .const Gb3 = $3a;    .const G3 = $3b;    .const Ab4 = $3c;    .const A4 = $3d;    .const Bb4 = $3e;    .const B4 = $3f;    .const C4 = $40;    .const Db4 = $41;    .const D4 = $42;;    .const Eb4 = $43
    .const E4 = $44;    .const F4 = $45;    .const Gb4 = $46;    .const G4 = $47;    .const Ab5 = $48;    .const A5 = $49;    .const Bb5 = $4a;    .const B5 = $4b;    .const C5 = $4c;    .const Db5 = $4d;    .const D5 = $4e;    .const Eb5 = $4f
    .const E5 = $50;    .const F5 = $51;    .const Gb5 = $52;    .const G5 = $53;    .const Ab6 = $54;    .const A6 = $55;    .const Bb6 = $56;    .const B6 = $57;    .const C6 = $58;    .const Db6 = $59;    .const D6 = $5a;    .const Eb6 = $5b
    .const E6 = $5c;

    // beats
    .const beatQuarter=TEMPO/4
    .const beatHalf=TEMPO/2
    .const beat1=TEMPO
    .const beat2=TEMPO*2
    .const beat3=TEMPO*3
    .const beat4=TEMPO*4

    psytrance1: 
        .byte E2, TEMPO*1, E3, TEMPO*1, E2, TEMPO*1, REST, TEMPO*1, D3, TEMPO*1, E2, TEMPO*1,REST, TEMPO*1,G3, TEMPO*1
        .byte $ff
    psytrance2: 
        .byte A2, TEMPO*1, A3, TEMPO*1, A2, TEMPO*1, REST, TEMPO*1, C3, TEMPO*1, A2, TEMPO*1,REST, TEMPO*1,E3, TEMPO*1
        .byte $ff   
    psytrance3: 
        .byte D2, TEMPO*1, D3, TEMPO*1, D2, TEMPO*1, REST, TEMPO*1, F3, TEMPO*1, D2, TEMPO*1,REST, TEMPO*1,A4, TEMPO*1
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

    voice1: 
    voice2:
    voice3:
    .word ifeellove1,ifeellove1,ifeellove1,ifeellove1
    .word ifeellove2,ifeellove2,ifeellove2,ifeellove2
    .word ifeellove3,ifeellove3,ifeellove3,ifeellove3
    .word $ffff

    
   // voice3:        .word silence, $ffff

    // voice1:         
    //      .word psytrance1, psytrance1, psytrance1, psytrance1, psytrance2, psytrance2, psytrance2, psytrance2, psytrance3,psytrance3,psytrance3,psytrance3, psytrance1, psytrance1, psytrance1, psytrance1,$ffff
    // voice2: 
    //     .word psytrance1, psytrance1, psytrance1, psytrance1, psytrance2, psytrance2, psytrance2, psytrance2, psytrance3,psytrance3,psytrance3,psytrance3, psytrance1, psytrance1, psytrance1, psytrance1,$ffff
    // voice3: 
    //     .word psytrance1, psytrance1, psytrance1, psytrance1, psytrance2, psytrance2, psytrance2, psytrance2, psytrance3,psytrance3,psytrance3,psytrance3, psytrance1, psytrance1, psytrance1, psytrance1,$ffff        
    controlChannel:
        .word filter, $ffff
}