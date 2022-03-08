BasicUpstart2(Start)

// TODO: how to loop over the sprite? the Charscreen.Read should be a start?
// - multiply
// - 

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_joystick.lib"
#import "_debug.lib"

.label ClearScreen = $E544

.const TWOPI = 256 // 256 is two PI in BRAD's
.const DELAY = 200
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
    Set size:#1
    Set phase:#1
    Set speed:#1

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
        // TODO: multiply by phase
        sta angle

        Set j:#0
axis:
            Call Rotate:angle:x:y
            Set x1:__val0
            Set y1:__val1

            Call Wrap:x1:#WIDTH
            Set x1:__val0
            Call Wrap:y1:#HEIGHT
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
    lda #CENTERX
    sec
    sbc time // TODO: * size
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

    ldx angle
    lda cosine,x


    // var x2 = x1 * Math.Cos(angle) - y1 * Math.Sin(angle);
    // var y2 = x1 * Math.Sin(angle) + y1 * Math.Cos(angle);

    Set __val0:x1 
    Set __val1:y1 

    rts
    x1: .byte 0
    y1: .byte 0
}

Wrap: {
    .var value = __arg0
    .var maxValue = __arg1

    // if (value < 0)
    // {
    //     if (value % maxValue == 0) return 0;

    //     return (int)(value % maxValue + maxValue);
    // }

    // return value >= maxValue
    //     ? (int)(value % maxValue)
    //     : (int)(value);

    Set __val0:value // TODO:
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
        inc size
        Set latchedUp:#0
    !:

    lda latchedDown
    cmp #V
    bne !+
        dec size
        Set latchedDown:#0
    !:

    lda latchedLeft
    cmp #H
    bne !+
        inc phase
        Set latchedLeft:#0
    !:

    lda latchedRight
    cmp #H
    bne !+
        dec phase
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
size: .byte 0
phase: .word 0
speed: .byte 0

// unsigned trig tables
*=$1000 "Data"
sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))

// WIP, ok for the now
palette: .byte 4,6,14,3,5,13,7,10,2,8,9

