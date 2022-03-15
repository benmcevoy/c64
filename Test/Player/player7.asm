BasicUpstart2(Start)

// let's try 
// - 16 bit game space - high byte is screen space, noice, so range is 0:40 => 0:10240, and 0:25 => 0:6400
//      wow, that works great :)
// - decay dx back to zero (+ve/-ve)
// - check collision in NSEW directions

#import "_prelude.lib"
#import "_charscreen.lib"

.const GRAVITY = 2
.const IMPULSE = -64
.const SPEED = 48

.const GROUNDCHAR = 102
.const BLANKCHAR = 32
.const PLAYERCHAR = 81

.label debug = $c000
.label PORT2 = $dc00

// statePLAYERCHAR
x: .word 0
y: .word 0

dx: .byte 0
dy: .byte 0

// screen space variables
y0: .byte 0
x0: .byte 0

// joystick state 
isJumping: .byte 0

Start: {
    Set $d020:#BLACK
    Set $d021:#BLACK
    // x,y are in "game space" x2/x8 of "screen space" or 0:78 (1 bits x2), 0:192 (3 bits x8)
    // screen space being 0:39,0:24
    Set x:#20
    Set x+1:#0

    Set y:#0
    Set y+1:#0

    Set dx:#0

    // draw the bounds once
    Set CharScreen.Character:#GROUNDCHAR
    Set CharScreen.PenColor:#GREEN
    Call CharScreen.PlotLine:#0:#24:#39:#24
    Call CharScreen.PlotLine:#0:#0:#0:#24
    Call CharScreen.PlotLine:#39:#0:#39:#24

    Loop: 
        // StoreInitialPos
        lda y; sta y0
        lda x; sta x0
        
        jsr ReadJoystick
        jsr UpdatePos
        jsr CheckCollisions
        jsr Render
        
    jmp Loop
}

// TODO: inline or .macro
Plot:{
    .var xHi = __arg0
    .var yHi = __arg1
    .var color = __arg2

    Set CharScreen.PenColor:color
    Call CharScreen.Plot:xHi:yHi

    rts
}

ReadJoystick: {
    // read joystick and mess with dx
    // let dx tend back to zero
    // TODO: now this is 16bit this is a bit slippy
    // thought about /2 or x2 instead (ror/rol)

    // This is a simple kind of momentum, 
    // you could have in y too for a race car game or something, sliding
    lda dx
    // signed CMP, dx > 0
    cmp #0
    beq readJoystick
    bmi !+
        dec dx
        jmp readJoystick
    !:
    inc dx

    // no momentum
    //Set dx:#0

    readJoystick:
    // left
    lda #%00000100
    bit PORT2
    bne !+
        Set dx:#-SPEED
    !: 
        
    // right
    lda #%00001000
    bit PORT2
    bne !+
        Set dx:#SPEED
    !: 
    
    // up
    lda isJumping
    cmp #0
    bne !+
        lda #%00000001
        bit PORT2
        bne !+
            Set dy:#IMPULSE
            Set isJumping:#1
    !:

    rts
}

UpdatePos: {
    // update dy
    // add GRAVITY instead of subtract due to screen co-ords being 0,0<>top,left
    // TODO: could just be `inc dy` if gravity is always 1 
    // if no gravity then the read joystick could test for up/down and set dy according, like it does for dx
    lda dy
    clc
    adc #GRAVITY
    sta dy

    // get high bytes of dy for 16bit add
    Set dHi:#0
    lda dy 
    // test the MSB by rotating into .C flag
    rol
    bcc !+
        // add high bytes
        Set dHi:#$ff
    !:

    // y + dy
    // add low bytes
    lda y+1
    clc
    adc dy
    sta y+1
    lda y
    adc dHi
    sta y

    Set dHi:#0
    lda dx 
    // test the MSB by rotating into .C flag
    rol
    bcc !+
        // add high bytes
        Set dHi:#$ff
    !:

    // x + dx
    lda x+1
    clc
    adc dx
    sta x+1
    lda x
    adc dHi
    sta x

    rts
    dHi: .byte 0
}

CheckCollisions: {
    vertical:
        // are we going up?
        lda y0
        cmp y
        bcs up

        down:
            lda y0
            sta yCurrent

            loopDown:
                inc yCurrent
                // loop from y0 to y, i do not care about interpolation
                Call CharScreen.Read:x0:yCurrent
                // now __val0 has the Read result
                lda __val0
                cmp #GROUNDCHAR
                bne !+
                    // set new y to one above where collision was found
                    dec yCurrent
                    lda yCurrent
                    sta y
                    Set y+1:#0

                    // if dy is > some threshold then bounce instead?

                    Set dy:#0
                    Set isJumping:#0

                    jmp horizontal
                !:
                
                lda yCurrent
                cmp y
                bne loopDown
                jmp horizontal
        up:
            lda y0
            sta yCurrent

            loopUp:
                Call CharScreen.Read:x0:yCurrent
                // now __val0 has the Read result
                lda __val0
                cmp #GROUNDCHAR
                bne !+
                    // set new y to one above where collision was found
                    // messing with the y, e.g. do not inc, can make you "stick" to the "ceiling" :)
                    inc yCurrent
                    lda yCurrent
                    sta y
                    Set y+1:#0
                    Set dy:#0

                    jmp horizontal
                !:
                // cf to down: the inc is first, then check, here it's check then dec
                dec yCurrent
                lda yCurrent
                cmp y
                bpl loopUp
                //jmp horizontal
                
    horizontal:
        // are we going right?
        lda dx
        cmp #0
        beq !+
        bpl right
        bmi left

        !: rts

        left:
            lda x0
            sta xCurrent

            loopLeft:
                dec xCurrent
                // for xCurrent to x
                Call CharScreen.Read:xCurrent:y
                lda __val0
                cmp #GROUNDCHAR
                bne !+
                    inc xCurrent
                    lda xCurrent
                    sta x
                    Set x+1:#0
                    Set dx:#0
                    
                    // allow "wall jump"!
                    // TODO: pretty rough, you can jump into a wall, then keep on jumping...
                    // this might need to be in the read joystick bit
                    // we might need some state so when we read input we can allow wall jump then
                    // e.g. just set a flag - allowWallJump.  I assume using bits would be better than a byte per flag...
                    lda isJumping
                    cmp #1
                    bne !+
                        Set isJumping:#0
                    !:
                    rts
                !:
                
                lda xCurrent
                cmp x
                bcs loopLeft
                rts

        right:
            lda x0
            sta xCurrent

            loopRight:
                inc xCurrent
                Call CharScreen.Read:xCurrent:y
                lda __val0
                cmp #GROUNDCHAR
                bne !+
                    dec xCurrent
                    lda xCurrent
                    sta x
                    Set x+1:#0
                    Set dx:#0

                    // allow "wall jump"!
                    lda isJumping
                    cmp #1
                    bne !+
                        Set isJumping:#0
                    !:
                    rts
                !:
                
                lda xCurrent
                cmp x
                bcc loopRight

    exit: rts

    xCurrent: .byte 0
    yCurrent: .byte 0
}

Render:{
    // clear previous
    Set CharScreen.Character:#BLANKCHAR
    Call Plot:x0:y0:#BLACK

    Set CharScreen.Character:#PLAYERCHAR
    Call Plot:x:y:#WHITE

    // draw ground
    Set CharScreen.Character:#GROUNDCHAR
    Set CharScreen.PenColor:#GREEN

    Call CharScreen.PlotLine:#30:#20:#40:#20
    Call CharScreen.PlotLine:#20:#16:#30:#16
    Call CharScreen.PlotLine:#15:#12:#22:#12
    Call CharScreen.PlotLine:#24:#8:#26:#8
    Call CharScreen.PlotLine:#15:#12:#22:#12

    Call CharScreen.PlotLine:#32:#16:#40:#12
    Call CharScreen.PlotLine:#20:#24:#14:#18

    Call CharScreen.PlotLine:#22:#12:#22:#16

    rts
}
    