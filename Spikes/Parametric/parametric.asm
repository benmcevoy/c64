BasicUpstart2(Start)

// refer: https://github.com/benmcevoy/ParametricToy

// ahhhh... so many issues
// 16 bit math, i am not doing it
// an angle is expressed as BRAD's e.g. 0..2PI => 0..255
// but size, time, phase? what the hell units are they in? not BRAD's, not "normalized" to 0..255 ...

// from reading my own code (in C#)
// time - is a value that increases.  I think it is OK if it just loops around from 0 to 255.
//  it mostly just passed to a trig function, so it would be fine. I also seem to add/subtract from time
//  which acts like phase
// 

// phase - I do this - var a = Math.Cos(t) * ctx.Phase;
//  which is not phase at all :) Phase also ranges from 0 .. 0.01  (1/100)
//  it greatly reduces the angle.  at a phase of zero angle is zero.
//  I don't know what this is, it's not phase, that's for sure
//  but it looks cool.  leave at zero for now

// size - ranges from 0..2. Seems I only use it in calulating the next point
//  it seems to act like some kind of horizontal offset
//  yeah it does.  in conjuntion with the trails it looks cool
//  I can simply remove phase and size form my c# code and it still looks neat
//  so for now - set size=1 so it does nothing...

// speed - not even using it.  it was used to control the speed that time increases at.

// so lets commit the work right now.  and then rip out speed, phase and size and see what happens

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_joystick.lib"
#import "_math.lib"

.label ClearScreen = $E544

.const TWOPI = 256 // 256 is two PI in BRAD's
.const DELAY = 1
.const AXIS = 8
.const TRAILS = 12
.const WIDTH = 40
.const HEIGHT = 24
.const CENTERX = (WIDTH/2)
.const CENTERY = (HEIGHT/2)
.const ROTATION_ANGLE_INCREMENT = (TWOPI/AXIS)  
.const GLYPH = 204 // a little square

.print CENTERX

Start: {
    // initialise
    Set CharScreen.Character:#GLYPH
    jsr ClearScreen
    Set $d020:#BLACK
    Set $d021:#BLACK

    // TODO: no idea what values to put yet
    // // Set size:#1
    // // Set phase:#0
    // // Set speed:#1

    // start main loop
    sei
        lda #<Update            
        sta $0314
        lda #>Update
        sta $0315
    cli

    // infinite loop
    jmp *
}

Update: {
    inc delayCounter
    lda delayCounter
    cmp #DELAY
    bne !+
        Set delayCounter:#0

        // TODO: update time? can i use TOD clock? seems not on vice...
        inc time
        
        jsr ReadInput
        Call UpdateState:time
    !:

    // end irq
    pla;tay;pla;tax;pla
    rti 
}

UpdateState: {
    .var time = __arg0

    // clear the sprite data, can i do this in the loop below?
    /*
    lda #0
    Set __ptr0:#>sprite
    Set __ptr0+1:#<sprite
    !:
        sta (__ptr0),Y
            
        dey
        bne !-
    */
    Set i:#0
trails:
        Call Point:time
        Set x:__val0
        Set y:__val1
        
        // var a = Math.Cos(t) * ctx.Phase;
        ldx time
        lda cosine,X
        sta angle

        //Call Mult_U8_U16:angle:phase
        // TODO: yeah not really... result is 16 bit
        Set angle:__val0

        Set j:#0
axis:
            Call Rotate:angle:x:y
            Set x1:__val0
            Set y1:__val1

            Call Wrap:x:x1:#WIDTH
            Set x1:__val0
            Call Wrap:y:y1:#HEIGHT
            Set y1:__val0

            // sprite[Wrap(x1,Sprite.Width), Wrap(y2, Sprite.Height)] = i % Sprite.PaletteLength;
            // TODO: set the sprite x,y with i % palette
            // should just Call Plot, but set colour first
            Set CharScreen.PenColor:i
            Call CharScreen.Plot:x1:y1
                            
            lda angle
            clc
            adc #ROTATION_ANGLE_INCREMENT 
            sta angle
        inc j
        lda j
        cmp #AXIS
        bcs !+
            jmp axis
        !:
        dec time
    inc i
    lda i
    cmp #TRAILS
    bcs exit
    jmp trails

exit:
    rts

    // indexes
    i: .byte 0
    j: .byte 0
    x: .byte 0
    y: .byte 0
    x1: .byte 0
    y1: .byte 0
    angle: .byte 0
}

/* Calulate new point x,y are signed */
Point: {
    .var time = __arg0

    // var x = centerX - time * ctx.Size;
    // Mul16 time:size
    // __val0 is already set by call to 
    lda #CENTERX
    sec
    sbc time 
    sta __val0
    
    Set __val1:#CENTERY

    rts
}

Rotate: {
    .var angle = __arg0
    .var x = __arg1
    .var y = __arg2

    // var x1 = x - centerX;
    lda x
    sec
    sbc CENTERX
    sta x1

    // var y1 = y - centerY;
    lda y
    sec
    sbc CENTERY
    sta y1

    // var x2 = x1 * Math.Cos(angle) - y1 * Math.Sin(angle);
    ldx angle
    lda cosine,x
    sta __tmp0
    
    Mul16 x:__tmp0
    Set __tmp0:__val0

    lda sine,x
    sta __tmp1
    Mul16 y:__tmp1
    Set __tmp1:__val0

    lda __tmp0
    sec
    sbc __tmp1
    sta x1

    // var y2 = x1 * Math.Sin(angle) + y1 * Math.Cos(angle);
    lda sine,x
    sta __tmp0
    
    Mul16 x:__tmp0
    Set __tmp0:__val0

    lda cosine,x
    sta __tmp1
    Mul16 y:__tmp1
    Set __tmp1:__val0

    lda __tmp0
    clc
    adc __tmp1
    sta y1

    Set __val0:x1 
    Set __val1:y1 

    rts
    x1: .byte 0
    y1: .byte 0
}

Wrap: {
    .var oldValue = __arg0
    .var newValue = __arg1
    .var maxValue = __arg2
    
    Set __val0:newValue

    // if new value >0 and <max then return it
    lda newValue
    cmp #0
    bmi !+
        cmp maxValue
        beq !+
        bmi !+
        rts
    !:

    // find delta/direction
    lda newValue
    sec
    sbc oldValue
    bmi decreasing
        lda newValue
        cmp maxValue
        beq wrap1
        bpl !+
        wrap1:
            sec
            sbc maxValue
            sta __val0
            rts
    !: 
    decreasing:
        lda newValue
        clc
        adc maxValue
        sta __val0

    rts
}

ReadInput: {
    Call Joystick.Read:playerAction
    Set playerAction:__val0

    .const V = 100
    .const H = 100

    lda #Joystick.UP
    and playerAction
    cmp #Joystick.UP
    bne !skip+
        inc latchedUp
        Set latchedDown:#0
    !skip:

    lda #Joystick.DOWN
    and playerAction
    cmp #Joystick.DOWN
    bne !skip+
        inc latchedDown
        Set latchedUp:#0
    !skip:

    lda #Joystick.LEFT
    and playerAction
    cmp #Joystick.LEFT
    bne !skip+
        inc latchedLeft
        Set latchedRight:#0
    !skip:

    lda #Joystick.RIGHT
    and playerAction
    cmp #Joystick.RIGHT
    bne !skip+
        inc latchedRight
        Set latchedLeft:#0
    !skip:

    lda latchedUp
    cmp #V
    bne !+
        //inc size
        Set latchedUp:#0
    !:

    lda latchedDown
    cmp #V
    bne !+
       // dec size
        Set latchedDown:#0
    !:

    lda latchedLeft
    cmp #H
    bne !+
       // inc phase
        Set latchedLeft:#0
    !:

    lda latchedRight
    cmp #H
    bne !+
        //dec phase
        Set latchedRight:#0
    !:

    rts

    playerAction: .byte 0
    latchedUp: .byte 0
    latchedDown: .byte 0
    latchedLeft: .byte 0
    latchedRight: .byte 0
}

// state
delayCounter: .byte 0

time: .byte 0
// size: .byte 0
// phase: .word 0
// speed: .byte 0

// unsigned trig tables
*=$1300 "Data"
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))

// WIP, ok for the now
palette: .byte 0,6,11,4,14,5,3,13,7,1,1,7,13,15,5,12,8,2,9


