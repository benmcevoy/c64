BasicUpstart2(Start)

// let's try 
// - control the timing of the render and the game speed 
// - do i need a dt delta time? there is a clock.
// - will IRQ suffice?
// render at a stable fps via an IRQ
// update at a much slower one? ideally use dt

// a delay does the trick
// i notice collision detection is not quite right..., should move player back to the previous position
// not just dec x or dec y or whatever...
// that is now fixed and the code got much DRYer, winner winner

#import "../_prelude.lib"
#import "../_charscreen.lib"

.const GRAVITY = 2
.const IMPULSE = -72
.const SPEED = 48
.const GROUND_CHAR = 204
.const BLANK_CHAR = 32
.const PLAYER_CHAR = 81

// state
x: .word 0
y: .word 0
dx: .byte 0
dy: .byte 0
y0: .byte 0
x0: .byte 0

delayCounter: .byte 0
.const DELAY = 80

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
.const ACTION_IS_JUMPING        = %00100000

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

    Set CharScreen.PenColor:#BROWN
    Call CharScreen.PlotLine:#30:#20:#38:#20
    Call CharScreen.PlotLine:#20:#16:#30:#16
    Call CharScreen.PlotLine:#15:#12:#22:#12
    Call CharScreen.PlotLine:#24:#8:#26:#8
    Call CharScreen.PlotLine:#15:#12:#22:#12
    Call CharScreen.PlotLine:#32:#16:#38:#12
    Call CharScreen.PlotLine:#20:#23:#14:#18
    Call CharScreen.PlotLine:#22:#8:#22:#16
    Call CharScreen.PlotLine:#1:#20:#10:#20
    Call CharScreen.PlotLine:#1:#16:#10:#16

    rts
}

ReadJoystick: {
    // let dx tend back to zero
    // if jumping then no friction
    lda #ACTION_IS_JUMPING
    bit playerAction
    bne !skip+
        lda dx
        cmp #0
        beq read_joystick
        bmi !+
            dec dx
            jmp read_joystick
        !:
        inc dx
    !skip:

    read_joystick:
        // left
        lda #JOYSTICK_LEFT
        bit PORT2
        bne !skip+
            lda #ACTION_IS_JUMPING
            bit playerAction
            beq !+
                Set dx:#-SPEED/2
                jmp !skip+
            !:
                Set dx:#-SPEED
        !skip: 
            
        // right
        lda #JOYSTICK_RIGHT
        bit PORT2
        bne !skip+
            lda #ACTION_IS_JUMPING
            bit playerAction
            beq !+
                Set dx:#SPEED/2
                jmp !skip+
            !:
                Set dx:#SPEED
        !skip: 

        // up
        // down

        // fire
        lda #ACTION_IS_JUMPING
        bit playerAction
        // no double jumping
        bne !skip+
            lda #JOYSTICK_FIRE
            bit PORT2
            bne !skip+
                Set dy:#IMPULSE
                SetBit playerAction:#ACTION_IS_JUMPING
        !skip:
    rts
}

UpdatePos: {
    // dy is signed and must be clamped to prevent overflow, or suddenly switching from +ve to -ve
    lda dy
    clc
    adc #GRAVITY
    bvs !+
        sta dy
    !:
    
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
        bne !skip+
            // set player back to position before collision
            Set x:xPrev
            Set y:yPrev

            // what direction was collision?
            lda dx
            cmp #0
            bmi setLeft
            bpl setRight

            setLeft: 
                Set dx:#0
                jmp end_h
            setRight: 
                Set dx:#0
            end_h:

            lda dy
            cmp #0
            bmi setUp
            bpl setDown

            setUp: 
                Set dy:#0
                jmp end_v
            setDown: 
                Set dy:#0
                // allow jump
                lda playerAction
                and #~ACTION_IS_JUMPING
                sta playerAction
            end_v:

            Set __val0:#ACTION_HANDLED
            rts
        !skip:
        
        Set __val0:#0
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
