#importonce

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

    arp: 
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3 
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3   

    arp1: 
    .byte REST,REST,REST,REST, REST,REST,REST,REST, REST,REST,REST,REST, REST,REST,REST,REST
    .byte REST,REST,REST,REST, REST,REST,REST,REST, REST,REST,REST,REST, REST,REST,REST,REST
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3   
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3               

    arp2: 
    // copied from arp
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    .byte A3,A4,C4,A3, A4,C4,A3,C4, A3,B4,A3,C4, B4,A3,G3,C4
    .byte A3,A4,A3,C4, A3,A4,C4,A3, B4,C4,A3,B4, A3,C4,B4,G3
    // end
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2    
    .byte E1,E1,E1,E1, E1,E1,E1,E1, E1,E1,E1,E1, E1,E1,E1,E1
    .byte C1,C1,C1,C1, C1,C1,C1,C1, C1,C1,C1,C1, C1,C1,C1,C1 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2
    .byte A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2, A2,A2,A2,A2 

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
}