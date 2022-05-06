#importonce

#define FASTMATH

.namespace Global {
    time: .byte 0   
    startAngle: .word 0
}

// notes
.namespace Sound {
    .const REST = 0
    .const E0 = $06
    .const F0 = $07
    .const Gb0 = $08
    .const G0 = $09
    .const A1 = $10
    .const Bb1 = $1a
    .const B1 = $1b
    .const C1 = $1c
    .const Db1 = $1d
    .const D1 = $1e
    .const Eb1 = $1f
    .const E1 = $20
    .const F1 = $21
    .const Gb1 = $22
    .const G1 = $23
    .const Ab2 = $24
    .const A2 = $25
    .const Bb2 = $26
    .const B2 = $27
    .const C2 = $28   
    .const Db2 = $29
    .const D2 = $2a
    .const Eb2 = $2b
    .const E2 = $2c
    .const F2 = $2d
    .const Gb2 = $2e
    .const G2 = $2f
    .const Ab3 = $30
    .const A3 = $31
    .const Bb3 = $32
    .const B3 = $33
    .const C3 = $34    
    .const Db3 = $35
    .const D3 = $36
    .const Eb3 = $37
    .const E3 = $38
    .const F3 = $39
    .const Gb3 = $3a
    .const G3 = $3b
    .const Ab4 = $3c
    .const A4 = $3d
    .const Bb4 = $3e
    .const B4 = $3f
    .const C4 = $40
    .const Db4 = $41
    .const D4 = $42
    .const Eb4 = $43
    .const E4 = $44
    .const F4 = $45
    .const Gb4 = $46
    .const G4 = $47
    .const Ab5 = $48
    .const A5 = $49
    .const Bb5 = $4a
    .const B5 = $4b
    .const C5 = $4c
    .const Db5 = $4d
    .const D5 = $4e
    .const Eb5 = $4f
    .const E5 = $50
    .const F5 = $51
    .const Gb5 = $52
    .const G5 = $53
    .const Ab6 = $54
    .const A6 = $55
    .const Bb6 = $56
    .const B6 = $57
    .const C6 = $58
    .const Db6 = $59
    .const D6 = $5a
    .const Eb6 = $5b
    .const E6 = $5c
}

