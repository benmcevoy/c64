BasicUpstart2(Start)

// let's try a circular buffer and see if we can have trails...

#import "_prelude.lib"
#import "_charscreen.lib"

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
    Set y:#16
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
    // Call Render:x:y:#BLACK

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

    // $06,$04,$0e,$05,$03,$0d,$01,$0d,$03,$05,$0e,$04,$06,$00
    //$09,$02,$08,$0a,$0f,$07,$01,$07,$0f,$0a,$08,$02,$09,$00
    // 	plot player.X, player.Y
    Set CharScreen.PenColor:#$01
    Call CharScreen.Plot:x:y

    Set CharScreen.PenColor:#$07
    Call CharScreen.Plot:x1:y1

    Set CharScreen.PenColor:#$07
    Call CharScreen.Plot:x2:y2

    Set CharScreen.PenColor:#$0f
    Call CharScreen.Plot:x3:y3

    Set CharScreen.PenColor:#$0f
    Call CharScreen.Plot:x4:y4

    Set CharScreen.PenColor:#$0a
    Call CharScreen.Plot:x5:y5

    Set CharScreen.PenColor:#$08
    Call CharScreen.Plot:x6:y6

    Set CharScreen.PenColor:#$02
    Call CharScreen.Plot:x7:y7

    Set CharScreen.PenColor:#BLACK
    Call CharScreen.Plot:x8:y8

    lda x7
    sta x8
    lda x6
    sta x7
    lda x5
    sta x6
    lda x4
    sta x5
    lda x3
    sta x4
    lda x2
    sta x3
    lda x1
    sta x2
    lda x
    sta x1

    lda y7
    sta y8
    lda y6
    sta y7
    lda y5
    sta y6
    lda y4
    sta y5
    lda y3
    sta y4
    lda y2
    sta y3
    lda y1
    sta y2
    lda y
    sta y1

    rts
    x1: .byte 0
    x2: .byte 0
    x3: .byte 0
    x4: .byte 0
    x5: .byte 0
    x6: .byte 0
    x7: .byte 0
    x8: .byte 0

    y1: .byte 0
    y2: .byte 0
    y3: .byte 0
    y4: .byte 0
    y5: .byte 0
    y6: .byte 0
    y7: .byte 0
    y8: .byte 0
}
