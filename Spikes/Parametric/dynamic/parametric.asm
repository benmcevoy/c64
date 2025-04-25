BasicUpstart2(Start)
#define FASTMATH

#import "_prelude.lib"
#import "_math.lib"
#import "Input.asm"
#import "state.asm"
#import "pattern2.asm"

.label ClearScreen = $E544

Start: {
    // initialise
    Set $d020:#BLACK
    Set $d021:#BLACK

    jsr ClearScreen
    jsr Background.Draw

    InitializeState()

    // Raster IRQ
    sei
        // disable cia timers
        lda    #$7f
        sta    $dc0d
        
        // enable raster irq
        lda $d01a                     
        ora #$01
        sta $d01a
        lda $d011                    
        and #$7f
        sta $d011

        // set next irq line number
        lda    #1
        sta    $d012
        
        lda #<UpdateState            
        sta $0314
        lda #>UpdateState
        sta $0315
    cli

    jmp *
}

UpdateState: {
    // ack irq
    lda $d019
    sta $d019
    // set next irq line number
    lda    #1
    sta    $d012
inc $d020    
    inc time
    lda time
    and _slowMo
    bne !+
        inc clock
    !:

    // set point, just moving along a line
    Set x:clock
    Set j:#0
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
        Set PenColor:#BLACK
        Plot x1:y1

        // TODO: this call is very slow
       // Rotate startAngle:x:y
        Set x1:__val0
        Set y1:__val1
        
        _mod51(x1)
        _mod51(y1)

        lda x1
        clc 
        adc #OFFSET
        sta x1

        ldx writePointer
        lda x1
        sta xTrails, X
        lda y1
        sta yTrails, X

        _mod16(clock)
        lda palette,X
        sta PenColor
        Plot x1:y1
                
        lda startAngle
        clc
        adc _rotation_angle_increment 
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
     dec $d020
    // end irq
    pla;tay;pla;tax;pla
    rti 
}

.pseudocommand Rotate angle:x:y{
    // xRelative is signed and relative to the origin at (CENTERX, CENTERY)
    lda x
    sec
    sbc CENTERX
    sta xRelative+1
    Set xRelative:#0

    lda y
    sec
    sbc CENTERY
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
    // // only care about high byte
    lda __val1
    asl
    sta y1

    // convert back to "screen space"
    lda x1
    clc
    adc CENTERX
    sta __val0

    // CENTERY - y1
    lda y1
    clc
    adc CENTERY
    sta __val1
}

.pseudocommand Plot x:y {
    // we never take advantage of PlotH/Sixels
    // so can just halve the x/y and do a char based plot instead
    lda x;lsr;sta x
    lda y;lsr;sta y
    
    .var screenLO = __tmp0 
    .var screenHI = __tmp1

    Set __tmp3:y
    // annoyingly backwards "x is Y" due to indirect indexing below
    ldy x
    ldx __tmp3

    clc
    lda screenRow.lo,X  
    sta screenLO

    // lda screenRow.hi,X
    // ora #$04 
    // sta screenHI

    // lda #126
    // sta (screenLO),Y  

    // set color ram
    lda screenRow.hi,X
    // ora is nice then to set the memory page
    ora #$D8 
    sta screenHI

    lda PenColor
    sta (screenLO),Y  
}

screenRow: .lohifill 25, 40*i

// lookup mod51 and put result in value
.macro _mod51(value){
    ldx value
    lda mod51,x
    sta value
}

// lookup mod16 and put result in .X
.macro _mod16(value){
    ldx value
    lda mod16,x
    tax
}

*=$8000 "Modulo LUT"
mod51: .byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,0
mod16: .byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
mod26: .byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
mod23: .byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21

*=$9000 "Signed trig tables"
// values range -127..127  
cosine: .fill 256,round(127*cos(toRadians(i*360/256)))
sine: .fill 256,round(127*sin(toRadians(i*360/256)))

