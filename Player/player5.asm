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
// 


#import "../_prelude.lib"
#import "../_charscreen.lib"

.const GRAVITY = 1
.const GROUND = 192 // 8*24 in game space
.const NO_DECAY = 1
.const WALL0 = 0
.const WALL1 = 78 // 2*39

.label debug = $c000

Start:
    Set $d020:#BLACK
    Set $d021:#BLACK
    // x,y are in "game space" x2/x8 of "screen space" or 0:78 (1 bits x2), 0:192 (3 bits x8)
    // screen space being 0:39,0:24
    // i believe this is called "fixed point". yes it is.
    Set x:#20
    Set y:#16
    Set dx:#1
 
    // setup CIA timer as game loop
    sei
    lda #<OnTimer
    sta $0314
    lda #>OnTimer
    sta $0315
    cli
    rts

OnTimer:
    // store initial screen space position
    lda y
    sta ylast
    lsr;lsr;lsr;
    sta y0

    lda x
    sta xlast
    lsr
    sta x0
    
    // update dy
    // add GRAVITY instead of subtract due to screen co-ords being 0,0 top,left
    lda dy
    clc;adc #GRAVITY
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

    // if we are going up, y1 < y0 then jump to check_collision_x
    // only collisions when going down
    lda y0
    cmp y1
    bcs check_collision_x

    check_collision_y:
    // loop from y0 to y1, i do not care about interpolation
    Call CharScreen.Read:x0:y0
    // now __val0 has the Read result
    lda __val0
    cmp #102
    bne !+
        lda y0
        clc;rol;rol;rol
        sec
        sbc #1
        sta y
        
        lda dy
        NegateA()
        sec
        sbc #NO_DECAY
        sta dy

        // TODO: do an actual bounce
        jmp check_collision_x
    !:
    inc y0
    lda y0
    cmp y1
    bne check_collision_y

    check_collision_x:
    // check bounds x
    // two walls at 0 and 39*4
    // bounce off them
    // i wonder if Bounce in the y can be generalized to a macro or something
    lda x
    cmp #WALL0
    // signed CMP, if x > 0 then branch
    bpl !+
        Set dx:#$01
        Set x:#WALL0
        jmp render // else
    !:

    lda x
    // check wall 39*4
    cmp #WALL1
    // signed CMP, if x < 39*2 then branch
    bcc !+
        Set dx:#-1
        Set x:#WALL1
    !:

    render:
    // clear previous
    Set CharScreen.Character:#32
    Call Render:xlast:ylast:#BLACK

    // prepare for player
    Set CharScreen.Character:#81
    Call Render:x:y:#YELLOW

    // draw ground
    Set CharScreen.Character:#102
    Set CharScreen.PenColor:#GREEN
    Call CharScreen.PlotLine:#0:#24:#40:#24
    Call CharScreen.PlotLine:#30:#20:#40:#20
    Call CharScreen.PlotLine:#20:#16:#30:#16
    Call CharScreen.PlotLine:#15:#12:#22:#12
    Call CharScreen.PlotLine:#24:#8:#26:#8

    jmp OnTimer//$ea31

    x: .byte 0
    y: .byte 0
    dx: .byte 0
    dy: .byte 0
    xlast: .byte 0
    ylast: .byte 0
    y0: .byte 0
    y1: .byte 0
    x0: .byte 0
    x1: .byte 0

Render:{
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
