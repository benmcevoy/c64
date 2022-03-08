BasicUpstart2(Start)

// let's try 
// - get rid of the trails
// - draw a playfield (after clearing previous position)
// - if dy is +ve (going down) check char BELOW for ground (currently char 102)
// - turn on decay, or kill dy when we collide
// - get some joystick input
// - push up and get an impulse dy =-5 or something - we can JUMP

// should be able to jump and land on platforms...
// walk left right
#import "../_prelude.lib"
#import "../_charscreen.lib"

.const IMPULSE = -8
.const WALL0 = 0
.const WALL1 = 78 // 2*39
.const GROUND = 102
.const BLANK = 32
.const PLAYER = 81

.label debug = $c000
.label PORT = $dc00

// state
// game space variables
GRAVITY: .byte 1
x: .byte 0
y: .byte 0
dx: .byte 0
dy: .byte 0
xlast: .byte 0
ylast: .byte 0

// screen space variables
y0: .byte 0
y1: .byte 0
x0: .byte 0
x1: .byte 0

// joystick state 
isJumping: .byte 0

Start: {
    Set $d020:#BLACK
    Set $d021:#BLACK
    // x,y are in "game space" x2/x8 of "screen space" or 0:78 (1 bits x2), 0:192 (3 bits x8)
    // screen space being 0:39,0:24
    Set x:#20
    Set y:#1
    Set dx:#0

    // draw the floor once
    Set CharScreen.Character:#GROUND
    Set CharScreen.PenColor:#GREEN
    Call CharScreen.PlotLine:#0:#24:#40:#24

    Loop: 
        jsr StoreInitialPos
        jsr ReadJoystick
        jsr UpdatePos
        jsr CheckCollisions
        jsr Render
        
    jmp Loop
}

Plot:{
    .var x = __arg0
    .var y = __arg1
    .var color = __arg2

    // convert x,y to screen space
    lda x
    lsr
    sta x

    lda y
    lsr;lsr;lsr;
    sta y

    Set CharScreen.PenColor:color
    Call CharScreen.Plot:x:y

    rts
}

StoreInitialPos: {
    lda y
    sta ylast
    lsr;lsr;lsr;
    sta y0

    lda x
    sta xlast
    lsr
    sta x0

    rts
}

ReadJoystick: {
    // read joystick and mess with dx
    Set dx:#0

    // left
    lda #%00000100
    bit PORT
    bne !+
        Set dx:#-1
    !:
        
    // right
    lda #%00001000
    bit PORT
    bne !+
        Set dx:#1
    !: 
    
    // up
    lda isJumping
    cmp #0
    bne !+
        lda #%00000001
        bit PORT
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
    lda dy
    clc;adc GRAVITY
    sta dy

    // y + dy
    lda y
    clc;adc dy
    sta y
  
    // x + dx
    lda x
    clc;adc dx
    sta x

    // convert updated x,y to x1,y1 in screen space for collision detection
    // store new screen space position
    lda y
    lsr;lsr;lsr;
    sta y1

    lda x
    lsr
    sta x1

    rts
}

CheckCollisions: {
    // if we are going up, y1 < y0 then jump to check_collision_x
    // only collisions when going down
    lda y0
    cmp y1
    bcs check_collision_x

    check_collision_y:
    inc y0
    // loop from y0 to y1, i do not care about interpolation
    Call CharScreen.Read:x0:y0
    // now __val0 has the Read result
    lda __val0
    cmp #GROUND
    bne !+
        // set new y to one above where collision was found
        dec y0
        lda y0
        asl;asl;asl  //x8
        sta y
        
        Set dy:#0
        Set isJumping:#0

        jmp check_collision_x
    !:
    
    lda y0
    cmp y1
    bne check_collision_y

    check_collision_x:
    // check bounds x
    lda x
    cmp #WALL0
    // signed CMP, if x > 0 then branch
    bpl !+
        Set x:#WALL0
        jmp _exit // else
    !:

    lda x
    // check wall 39*4
    cmp #WALL1
    // signed CMP, if x < 39*2 then branch
    bcc !+
        Set x:#WALL1
    !:

    _exit:
    rts
}

Render:{
    // clear previous
    Set CharScreen.Character:#BLANK
    Call Plot:xlast:ylast:#BLACK

    // prepare for player
    // have to draw immediately or there is flicker
    Set CharScreen.Character:#PLAYER
    Call Plot:x:y:#WHITE

    // draw ground
    Set CharScreen.Character:#GROUND
    Set CharScreen.PenColor:#GREEN

    Call CharScreen.PlotLine:#30:#20:#40:#20
    Call CharScreen.PlotLine:#20:#16:#30:#16
    Call CharScreen.PlotLine:#15:#12:#22:#12
    Call CharScreen.PlotLine:#24:#8:#26:#8
    Call CharScreen.PlotLine:#15:#12:#22:#12

    Call CharScreen.PlotLine:#32:#16:#40:#12

    rts
}
    