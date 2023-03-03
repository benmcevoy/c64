BasicUpstart2(Start)
#define FASTMATH

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_joystick.lib"
#import "_math.lib"
#import "Input.asm"


.const AXIS = 8
.const TRAILS = 8
.const PALETTE_LENGTH = 16

.const WIDTH = 51
.const HEIGHT = 51
.const OFFSET = 16

.const CENTERX = (WIDTH/2)
.const CENTERY = (HEIGHT/2)
.label ROTATION_ANGLE_INCREMENT = _rotation_angle_increment
.label ClearScreen = $E544
.const readInputDelay = 4
_readInputInterval: .byte readInputDelay

Start: {
    // initialise
    jsr ClearScreen
    Set $d020:#BLACK
    Set $d021:#BLACK

    sei
        lda #<UpdateState
        sta $0314    
        lda #>UpdateState
        sta $0315
    cli

    loop: jmp loop
}

UpdateState: {
    inc time
    // set point, just moving along a line
    Set x:time
    Set j:#0
    //Set startAngle:time
    inc startAngle 
    inc startAngle 

    dec _readInputInterval
    bne !+
        jsr ReadInput
        Set _readInputInterval:#readInputDelay
    !:

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
        Plot x1:y1
        Rotate startAngle:x:y
        Set x1:__val0
        Set y1:__val1

        Modulo x1:#WIDTH
        Set x1:__val0
        Modulo y1:#HEIGHT
        Set y1:__val0

        lda x1
        clc 
        adc #OFFSET
        sta x1

        lda #%00000001
        bit x1
        bne !+
            lda x1
            eor #1
            sta x1
        !:

        lda #%00000001
        bit y1
        bne !+
            lda y1
            eor #1
            sta y1
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
        Plot x1:y1
                
        lda startAngle
        clc
        adc ROTATION_ANGLE_INCREMENT 
        sta startAngle

        lda writePointer
        cmp #(TRAILS*AXIS)
        bcc !+
            Set writePointer:#0
        !:

        inc j
        lda j
        cmp #AXIS
        beq !+
            jmp axis
        !:
    exit:

    // end irq
    pla;tay;pla;tax;pla
    rti 

    // indexes
    j: .byte 0
    x: .byte 0
    y: .byte CENTERY
    x1: .byte 0
    y1: .byte 0
    startAngle: .word 0
    writePointer: .byte 0
    erasePointer: .byte 0
}

.pseudocommand Rotate angle:x:y{
    // xRelative is signed and relative to the origin at (CENTERX, CENTERY)
    lda x
    sec
    sbc #CENTERX
    sta xRelative+1
    Set xRelative:#0

    lda y
    sec
    sbc #CENTERY
    sta yRelative+1
    Set yRelative:#0

    ldx angle
    lda cosine,X
    sta cosineAngle
    Sat16 cosineAngle:cosineAngle+1

    ldx angle
    lda sine,X
    sta sineAngle
    Sat16 sineAngle:sineAngle+1

    // var x2 = xRel * Math.Cos(angle) - yRel * Math.Sin(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:cosineAngle
    Set __tmp3:cosineAngle+1
    
    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    Set x2a:__val1
    Set x2a+1:__val2

    Set __tmp0:yRelative
    Set __tmp1:yRelative+1
    Set __tmp2:sineAngle
    Set __tmp3:sineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3

    Set y2a:__val1
    Set y2a+1:__val2

    Set __tmp0:x2a
    Set __tmp1:x2a+1
    Set __tmp2:y2a
    Set __tmp3:y2a+1
    
    Sub16 __tmp0:__tmp1:__tmp2:__tmp3

    // only care about high byte
    lda __val1
    // i do not know why i have to double it, only that it works :(
    asl
    sta x1

    // var y2 = x * Math.Sin(angle) + y * Math.Cos(angle);
    Set __tmp0:xRelative
    Set __tmp1:xRelative+1
    Set __tmp2:sineAngle
    Set __tmp3:sineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    Set x2a:__val1
    Set x2a+1:__val2

    Set __tmp0:yRelative
    Set __tmp1:yRelative+1
    Set __tmp2:cosineAngle
    Set __tmp3:cosineAngle+1

    SMulW32 __tmp0:__tmp1:__tmp2:__tmp3
    Set y2a:__val1
    Set y2a+1:__val2

    Set __tmp0:x2a
    Set __tmp1:x2a+1
    Set __tmp2:y2a
    Set __tmp3:y2a+1

    Add16 __tmp0:__tmp1:__tmp2:__tmp3
    // only care about high byte
    lda __val1
    asl
    sta y1

    // convert back to "screen space"
    lda x1
    clc
    adc #CENTERX
    sta __val0

    // CENTERY - y1
    lda y1
    clc
    adc #CENTERY
    sta __val1
}

.pseudocommand Plot x:y {
    Call CharScreen.PlotH:x:y
}

// relative to origin at centerx,y
xRelative: .word 0
yRelative: .word 0

sineAngle: .word 0
cosineAngle: .word 0

x2a: .word 0
y2a: .word 0

x1: .byte 0
y1: .byte 0

// state
time: .byte 0
palette: 
//.byte 1,7,15,5,4,2,6,9,11,8,12,3,13,1,7,15

.byte CYAN,LIGHT_BLUE,PURPLE,LIGHT_RED
.byte ORANGE,YELLOW,LIGHT_GREEN,GREEN
.byte LIGHT_BLUE,BLUE,BLUE,BLUE
.byte RED,WHITE,WHITE,WHITE
.byte ORANGE,YELLOW,LIGHT_GREEN,GREEN

*=$4000 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))
* = $4200 "trails"
xTrails: .fill (TRAILS*AXIS),0
yTrails: .fill (TRAILS*AXIS),0

