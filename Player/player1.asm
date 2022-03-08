BasicUpstart2(Start)

    // let's just bounce
    // ignore dx for now.

#import "../_prelude.lib"
#import "../_charscreen.lib"

.const GRAVITY = 1
.const GROUND = 192 // 4*24 in game space
.const NO_DECAY = 1

Start:

    Set $d020:#BLACK
    Set $d021:#BLACK
    // x,y are in "game space" x4 of "screen space" or 0:156 (2 bits x4), 0:192 (3 bits x8)
    // screen space being 0:39,0:24
    Set x:#04
    Set y:#8
 
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

    // let's just bounce
    // ignore dx for now.

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
    // lda x
    // clc
    // adc dx
    // sta x

    // check bounds
    lda y
    cmp #GROUND
    // signed CMP
    // check for > ground
    bmi !+
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

    // 	plot player.X, player.Y
    Call Render:x:y:#GREEN
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
    lsr;clc;lsr;
    sta x

    lda y
    lsr;clc;lsr;clc;lsr;
    sta y

    // 	plot player.X, player.Y
    Set CharScreen.PenColor:color
    Call CharScreen.Plot:x:y
    rts
}