BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

// allow joystick control to control a couple of parameters
// tune up the parameters so we can get nice variety when we twiddle the knobs
// move away from Call and _prelude.lib
// consider
// - more than one label can be applied to a zero page address, as long as the labels are orthognal or not used at the same time then you should be ok (non simulataneous? )
// - the carry flag can be used as a status flag by your own code, e.g.
// - start and end labels can be applied to a struct (or table) so you can have dynamically sized "objects", i think

// MyFunction: {
//     ... do stuff ...
//
//     exit_false:
//         clc
//         rts
//     exit_true:
//         sec
//         rts
// }

// beginning to learn the "idioms" of this language
// and how to better use it

// the .A should mostly contain the result of a macro/jsr
// the three registers should be used AS MUCH AS POSSIBLE, remember tay/tax and txa etc for holding a state temporarily
// there is a design:

// .macro expose the public API, it handles setting up any registers, state etc, calls a JSR, handles the results if required
// jsr is a routine in a MODULE or FEATURE. I have heard it called a SYSTEM, which I kinda like better than feature, as one system may have several features
// sub routines should expect to be passed things in the registers
// and should return things in the registers
// avoid temporary state where possible

// i need to review this pattern and try and document it somewhere. in code. Spike!


#define FASTMATH

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_math.lib"

.label ClearScreen = $E544

.const AXIS = 8
.const TRAILS = 6
.const PALETTE_LENGTH = 16
.const WIDTH = 51
.const HEIGHT = 51
.const OFFSET = 16
.const CENTERX = (WIDTH/2)
.const CENTERY = (HEIGHT/2)
.const ROTATION_ANGLE_INCREMENT = (256/AXIS)  

.const FREQ_LO = 0
.const FREQ_HI = 1
.const PW_LO = 2
.const PW_HI = 3
.const CONTROL = 4
.const ATTACK_DECAY = 5
.const SUSTAIN_RELEASE = 6

.const FILTER_CUT_OFF_LO = 0
.const FILTER_CUT_OFF_HI = 1
.const FILTER_CONTROL = 2
.const VOLUME = 3

.const sid        = 54272
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
.const G5 = $47
.const Ab5 = $48

.const Clock1Speed = 10
.const Clock2Speed = 11

basstbl:    .byte E3, Gb3, B4, Db4, D4, Gb3, E3, Db4, B4, Gb3, D4, Db4
Start: {
    // initialise
    jsr ClearScreen
    Set $d020:#BLACK
    Set $d021:#BLACK

    // voice 1
    Set sid+0*7+FREQ_LO:#$00
    Set sid+0*7+FREQ_HI:#$00
    Set sid+0*7+PW_LO:#$00
    Set sid+0*7+PW_HI:#$80
    Set sid+0*7+CONTROL:#%01010001
    Set sid+0*7+ATTACK_DECAY:#$12
    Set sid+0*7+SUSTAIN_RELEASE:#$60

    // voice 2
    Set sid+1*7+FREQ_LO:#$00
    Set sid+1*7+FREQ_HI:#$00
    Set sid+1*7+PW_LO:#$00
    Set sid+1*7+PW_HI:#$80
    Set sid+1*7+CONTROL:#%00110001
    Set sid+1*7+ATTACK_DECAY:#$13
    Set sid+1*7+SUSTAIN_RELEASE:#$60    

    // filters and whatnot
    Set sid+3*7+FILTER_CUT_OFF_LO:#%00000111
    Set sid+3*7+FILTER_CUT_OFF_HI:#%00001111
    Set sid+3*7+FILTER_CONTROL:#%11110011
    Set sid+3*7+VOLUME:#%00111111

    sei
        lda #<onTick
        sta $0314    
        lda #>onTick
        sta $0315
    cli

    loop:
        inc time
        jsr Update
    jmp loop
}

// TODO: clena up this madness
// derive clocks from time - i had a crazy idea that lfsr could derive any clock
// currently i am trying to manage multiple clocks
// so this is a place where we can apply some transformation of the problem
// and have a signal clock generating events
// sequencer, or duration that elapses
// also give the render function a clock as well,
// can get some synced variety by restarting the filter sweep below and syncing that with the evolution of the parameteric system
// tempo
// basically want arps that can retrigger with different starting pitch
// and what happens if you run a clock backwards
onTick: {
    inc     clock1
    lda     clock1
    cmp     #Clock1Speed
    bne !+
        Set     clock1:#0
        inc     clock1+1
        lda clock1+1
        cmp #12
        bne !+
            Set     clock1+1:#0
       
    !:

    inc     clock2
    lda     clock2
    cmp     #Clock2Speed
    bne !+
        Set     clock2:#0
        inc     clock2+1
        lda clock2+1
        cmp #12
        bne !+
            Set     clock2+1:#0
       
    !:       

    lda     clock1+1                // x contains current bar count
  //  and     #%00001111              // mask off last 3 bits of bar
    tax
    lda     basstbl,x               // use as index into bass note table
    tax
    lda     freq_msb,x
    sta     sid+0*7+FREQ_HI         
    lda     freq_lsb,x
    sta     sid+0*7+FREQ_LO         

    lda     clock2+1                
    // and     #%00001111              
    tax
    lda     basstbl,x   

        
    tax
    lda     freq_msb,x
    sta     sid+1*7+FREQ_HI         
    lda     freq_lsb,x
    sta     sid+1*7+FREQ_LO               

    lda time
    sta sid+3*7+FILTER_CUT_OFF_HI
    jmp     $ea31                  
}

clock1:      .word $0000
clock2:      .word $0000


freq_msb:
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02
.byte $02,$02,$03,$03,$03,$03,$03,$04,$04,$04,$04,$05,$05,$05,$06,$06
.byte $06,$07,$07,$08,$08,$09,$09,$0a,$0a,$0b,$0c,$0d,$0d,$0e,$0f,$10
.byte $11,$12,$13,$14,$15,$17,$18,$1a,$1b,$1d,$1f,$20,$22,$24,$27,$29
.byte $2b,$2e,$31,$34,$37,$3a,$3e,$41,$45,$49,$4e,$52,$57,$5c,$62,$68

freq_lsb:
.byte $6e,$75,$7c,$83,$8b,$93,$9c,$a5,$af,$b9,$c4,$d0,$dd,$ea,$f8,$07
.byte $16,$27,$39,$4b,$5f,$74,$8a,$a1,$ba,$d4,$f0,$0e,$2d,$4e,$71,$96
.byte $be,$e7,$14,$42,$74,$a9,$e0,$1b,$5a,$9c,$e2,$2d,$7b,$cf,$27,$85
.byte $e8,$51,$c1,$37,$b4,$38,$c4,$59,$f7,$9d,$4e,$0a,$d0,$a2,$81,$6d
.byte $67,$70,$89,$b2,$ed,$3b,$9c,$13,$a0,$45,$02,$da,$ce,$e0,$11,$64
.byte $da,$76,$39,$26,$40,$89,$04,$b4,$9c,$c0,$23,$c8,$b4,$eb,$72,$4c
.byte $80,$12,$08,$68,$39,$80,$45,$90,$68,$d6,$e3,$99,$00,$24,$10

Update: {
    Set i:#0
    inc startAngle
    // xRelative is signed and relative to the origin at (CENTERX, CENTERY)
    lda time
    sec
    sbc #CENTERX
    sta xRelative+1
    Set xRelative:#0

    axis:
        inc writePointer
        inc erasePointer

        ldx erasePointer
        cpx #(TRAILS*AXIS)
        bcc !+
            Set erasePointer:#0
        !:

        lda xTrails,X
        sta x1    
        lda yTrails,X
        sta y1
        // clear previous
        Set CharScreen.PenColor:#BLACK
        Call CharScreen.PlotH:x1:y1

        Rotate startAngle
        Modulo __val0:#WIDTH
        Set x1:__val0
        Modulo __val1:#HEIGHT
        Set y1:__val0

        lda x1
        clc 
        adc #OFFSET
        sta x1

        // make even
        lda #%00000001
        bit x1
        bne !+
            dec x1
        !:

        lda #%00000001
        bit y1
        bne !+
            dec y1
        !:

        ldx writePointer
        lda x1
        sta xTrails, X
        lda y1
        sta yTrails, X

        Modulo time:#PALETTE_LENGTH
        ldx __val0
        lda palette,X
        sta CharScreen.PenColor
        Call CharScreen.PlotH:x1:y1

        lda startAngle
        clc
        adc #ROTATION_ANGLE_INCREMENT 
        sta startAngle

        lda writePointer
        cmp #(TRAILS*AXIS)
        bcc !+
            Set writePointer:#0
        !:

        inc i
        lda i
        cmp #AXIS
        beq !+
            jmp axis
        !:
    exit:
    rts
    
    i: .byte 0
    x1: .byte 0
    y1: .byte 0
    startAngle: .word 0
    writePointer: .byte 0
    erasePointer: .byte 0
}

.pseudocommand Rotate angle {
    ldx angle
    lda cosine,X
    sta cosineAngle
    Sat16 cosineAngle:cosineAngle+1

    ldx angle
    lda sine,X
    sta sineAngle
    Sat16 sineAngle:sineAngle+1

    // var x2 = xRel * Math.Cos(angle)  ///  yRel is always 0 so ignore this - yRel * Math.Sin(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:cosineAngle
    Set __tmp3:cosineAngle+1
    
    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    
    // only care about high byte
    lda __val2
    asl
    sta x1

    // var y2 = x * Math.Sin(angle) /// -- ignore Y term -- + y * Math.Cos(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:sineAngle
    Set __tmp3:sineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    lda __val2
    asl
    sta y1

    // convert back to "screen space"
    lda x1
    clc
    adc #CENTERX
    sta __val0

    lda y1
    clc
    adc #CENTERY
    sta __val1
}

// relative to origin at centerx,y
xRelative: .word 0
yRelative: .word 0
sineAngle: .word 0
cosineAngle: .word 0
x1: .byte 0
y1: .byte 0

// state
time: .byte 0
palette: .byte 6,11,4,14,5,3,13,7,1,1,7,13,15,5,12,8,2,9,2,9

*=$3700 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))
* = $3900 "trails"
xTrails: .fill (TRAILS*AXIS),0
yTrails: .fill (TRAILS*AXIS),0
