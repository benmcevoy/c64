BasicUpstart2(Start)

// continue from player1.asm, now to add horizontal motion
// and addditional walls


#import "../_prelude.lib"
#import "../_charscreen.lib"

.const GRAVITY = 1
.const GROUND = 192 // 8*24 in game space
.const NO_DECAY = 1

.const WALL0 = 0
.const WALL1 = 78 // 2*39

Start:

    Set $d020:#BLACK
    Set $d021:#BLACK
    // x,y are in "game space" x2/x8 of "screen space" or 0:78 (1 bits x2), 0:192 (3 bits x8)
    // screen space being 0:39,0:24
    // i believe this is called "fixed point". yes it is.
    Set x:#80
    Set y:#8
    Set dx:#255
 
    // draw ground
    Set CharScreen.Character:#102
    Set CharScreen.PenColor:#GREEN
    Call CharScreen.PlotLine:#0:#24:#39:#24

    Set CharScreen.Character:#81

    .label debug = $c000

    // setup CIA timer
    sei
    lda #<OnTimer
    sta $0314
    lda #>OnTimer
    sta $0315
    cli
    rts

OnTimer:
    // clear previous
    Call Render:x:y:#BLACK

    // update dy
    // add GRAVITY instead of subtract due to screen co-ords being 0,0 top,left
    lda dy
    clc
    adc #GRAVITY
    sta dy

    // y + dy
    lda y
    clc
    adc dy
    sta y

    // x + dx
    lda x
    clc
    adc dx
    sta x

    // check bounds y
    lda y
    cmp #GROUND
    // unsigned CMP as #GROUND is > 128
    // check for > ground
    bcc !+
        // hit the ground, make dy -ve
        lda dy
        //  invert
        NegateA()
        sec
        sbc #NO_DECAY
        sta dy
       
        // bounce y1 = ground - (y-ground)
        lda y
        sec
        sbc #GROUND
        sta y1
        lda #GROUND
        sec
        sbc y1
        sta y
    !:

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
    // 	plot player.X, player.Y
    Call Render:x:y:#YELLOW
    jmp $ea31

    x: .byte 0
    y: .byte 0
    dx: .byte 1
    dy: .byte 0
    y1: .byte 0

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

    // 	plot player.X, player.Y
    Set CharScreen.PenColor:color
    Call CharScreen.Plot:x:y
    rts
}