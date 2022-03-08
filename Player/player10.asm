BasicUpstart2(Start)

// let's try
// - a little "car" game
// yeah, kinda meh.

#import "../_prelude.lib"
#import "../_charscreen.lib"

.const MAXSPEED = 80
.const SPEED_INC = 3
.const GROUND_CHAR = 219
.const BLANK_CHAR = 32
.const PLAYER_CHAR = 81
.const DELAY = 200

// state
x: .word 0
y: .word 0
dx: .byte 0
dy: .byte 0
y0: .byte 0
x0: .byte 0
delayCounter: .byte 0

.label PORT2 = $dc00
.const JOYSTICK_UP      = %00000001
.const JOYSTICK_DOWN    = %00000010
.const JOYSTICK_LEFT    = %00000100
.const JOYSTICK_RIGHT   = %00001000
.const JOYSTICK_FIRE    = %00010000
// similar to joystick flags
.const ACTION_COLLIDED_UP       = %00000001
.const ACTION_COLLIDED_DOWN     = %00000010
.const ACTION_COLLIDED_LEFT     = %00000100
.const ACTION_COLLIDED_RIGHT    = %00001000
.const ACTION_IS_FIRING         = %00010000
// default state for the above flags
playerAction: .byte %00100000

Start: {
    // KERNAL clear screen
    jsr $E544
    // set border and screen colors
    Set $d020:#BLACK
    Set $d021:#BLACK

    // init some things
    // x,y are in 16 bit "game space", the high byte is "screen space", nice.
    // screen space being 0:39,0:24
    Set x:#20
    Set x+1:#0
    Set y:#2
    Set y+1:#0
    Set dx:#0
    Set dy:#0

    jsr DrawGameField

    // set IRQ for GameUpdate, CIA timer
    sei
    lda #<GameUpdate
    sta $0314
    lda #>GameUpdate
    sta $0315
    cli

    // infinite loop
    jmp *
}

GameUpdate: {
    inc delayCounter
    lda delayCounter
    cmp #DELAY
    bne !+
        Set delayCounter:#0

        // StoreInitialPos
        lda y; sta y0
        lda x; sta x0

        jsr ReadJoystick
        jsr UpdatePos
        jsr CheckCollisions
        jsr Render
    !:

    // end irq
    pla;tay;pla;tax;pla
    rti
}

DrawGameField: {
    // for ground, consider we have a custom char set
    // then ground should be a range, e.g. characters 40-60
    // so we can have some variety, and our collision test can still be reasonable
    // e.g. I could draw with some nice PETSCII chars instead
    Set CharScreen.Character:#GROUND_CHAR

    Set CharScreen.PenColor:#GREEN
    Call CharScreen.PlotRect:#0:#0:#39:#24
    Call CharScreen.Plot:#1:#1
    Call CharScreen.Plot:#38:#1
    Call CharScreen.Plot:#1:#23
    Call CharScreen.Plot:#38:#23

    Set CharScreen.PenColor:#BROWN
    Call CharScreen.PlotRect:#7:#8:#32:#16
    Call CharScreen.PlotRect:#8:#7:#31:#17

    rts
}

ReadJoystick: {
    // let dx tend back to zero
    // This is a simple kind of momentum,
    // you could have in y too for a race car game or something, sliding,
    // or use rol or something to dampen instead of inc/dec

    lda dx
    cmp #0
    beq update_dy_momentum
    bmi !+
        dec dx
        jmp update_dy_momentum
    !:
    inc dx

    update_dy_momentum:
    lda dy
    cmp #0
    beq read_joystick
    bmi !+
        dec dy
        jmp read_joystick
    !:
    inc dy

    read_joystick:
        // left
        lda #JOYSTICK_LEFT
        bit PORT2
        bne !+
            lda dx;sec;sbc #SPEED_INC;sta dx
            cmp #-MAXSPEED
            bpl !+
                Set dx:#-MAXSPEED
            !:

        lda #JOYSTICK_RIGHT
        bit PORT2
        bne !+
            lda dx;clc;adc #SPEED_INC;sta dx
            cmp #MAXSPEED
            bmi !+
                Set dx:#MAXSPEED
            !:

        // up
        lda #JOYSTICK_UP
        bit PORT2
        bne !+
            lda dy;sec;sbc #SPEED_INC;sta dy
            cmp #-MAXSPEED
            bpl !+
                Set dy:#-MAXSPEED
            !:

        // down
        lda #JOYSTICK_DOWN
        bit PORT2
        bne !+
            lda dy;clc;adc #SPEED_INC;sta dy
            cmp #MAXSPEED
            bmi !+
                Set dy:#MAXSPEED
            !:

        // fire, not used but hey :)
        lda #JOYSTICK_FIRE
        bit PORT2
        bne !+
            SetBit playerAction:#ACTION_IS_FIRING
        !:
    rts
}

UpdatePos: {
    // get high bytes of dy for 16bit add
    Set dHi:#0
    lda dy
    // test the MSB by rotating into .C flag
    rol
    bcc !+
        // add high byte, sign extension
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
    rol
    bcc !+
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
    // clear previous collision states
    lda playerAction
    and #~%00001111
    sta playerAction

    Set __ptr0:#<(checkCollision)
    Set __ptr0+1:#>(checkCollision)

    Call CharScreen.CastRay:x0:y0:x:y

    rts

    checkCollision:{
        .var xRay = __arg0
        .var yRay = __arg1
        .var xPrev = __arg2
        .var yPrev = __arg3

        Call CharScreen.Read:xRay:yRay

        lda __val0
        cmp #GROUND_CHAR
        beq !+
            Set __val0:#0
            rts
        !: 

        // what direction was collision?
        lda dx
        cmp #0
        bmi setLeft
        bpl setRight

        setLeft:
            SetBit playerAction:#ACTION_COLLIDED_LEFT
            jmp end_h
        setRight:
            SetBit playerAction:#ACTION_COLLIDED_RIGHT
        end_h:

        lda dy
        cmp #0
        bmi setUp
        bpl setDown

        setUp:
            SetBit playerAction:#ACTION_COLLIDED_UP
            jmp end_v
        setDown:
            SetBit playerAction:#ACTION_COLLIDED_DOWN
        end_v:

        // set player back to position before collision
        Set x:xPrev
        Set y:yPrev

        Set __val0:#ACTION_HANDLED
        rts
    }
}

Render:{
    // changed?
    lda x0
    cmp x
    bne clearPlayer
    lda y0
    cmp y
    beq !+
        clearPlayer:
            Set CharScreen.PenColor:#BLACK
            Set CharScreen.Character:#BLANK_CHAR
            Call CharScreen.Plot:x0:y0
    !:

    // draw player
    Set CharScreen.Character:#PLAYER_CHAR
    Set CharScreen.PenColor:#WHITE
    Call CharScreen.Plot:x:y

    rts
}
