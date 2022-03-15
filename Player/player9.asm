BasicUpstart2(Start)

// extract player out to an "Agent" struct, with OnUpdate, OnRender, then allow multiple for "enemies" and other things.
// consider the idea of a z-index, i'd like to see little thing moving in the background.
// a little dot in the background, bouncing along, reverse direction on collide
// or a bird flying past in the fore ground.  The "swap" logic in render would allow things to go over/under other things
// push render to a raster irq?
// push update to some other raster line irq?
// multi character "sprites"
// animation - (new state, duration), new state of the value being animated, maybe state is the pointer to the four characters that make up a "sprite"
// handle screen edges so we do not need the box around the screen for collisions, give us back 2 cols and 2 rows of screen

#import "_prelude.lib"
#import "_charscreen.lib"

#import "./Backgrounds/weave.asm"
//#import "./Backgrounds/honeycomb.asm"
//#import "./Backgrounds/city.asm"
//#import "./Backgrounds/jungle.asm"
//#import "./Backgrounds/clouds.asm"

.const GRAVITY = 2
.const IMPULSE = -72
.const SPEED = 48
.const GROUND_CHAR = 224
.const BLANK_CHAR = 32
.const PLAYER_CHAR = 81

.const PLAYER_COLOR = WHITE
.const GROUND_COLOR = BLACK

// state
x: .word 0
y: .word 0
dx: .byte 0
dy: .byte 0
y0: .byte 0
x0: .byte 0

swapColor: .byte 0
swapChar: .byte 0

delayCounter: .byte 0
.const DELAY = 100

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

    // init some things
    // x,y are in 16 bit "game space", the high .byte is "screen space", nice.
    // screen space being 0:39,0:24
    Set x:#20
    Set x+1:#0
    Set y:#2
    Set y+1:#0
    Set dx:#0
    Set dy:#0

    jsr DrawGameField

    Call CharScreen.Read:x:y
    Set swapChar:__val0
    Set swapColor:__val1
    
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

    jsr DrawBackground
    
    Set CharScreen.Character:#GROUND_CHAR
    Set CharScreen.PenColor:#GROUND_COLOR    
    Call CharScreen.PlotRect:#0:#0:#39:#24
    //Call CharScreen.PlotLine:#0:#24:#39:#24

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
    
    // get high .bytes of dy for 16bit add
    Set dHi:#0
    lda dy 
    // test the MSB by rotating into .C flag
    rol
    bcc !+
        // add high .byte, sign extension
        Set dHi:#$ff
    !:

    // y + dy
    // add low .bytes
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

    lda x0
    cmp x
    bne swap
    lda y0
    cmp y
    bne swap
    jmp draw
    
swap:    
    Set CharScreen.PenColor:swapColor
    Set CharScreen.Character:swapChar
    Call CharScreen.Plot:x0:y0

    Call CharScreen.Read:x:y
    Set swapChar:__val0
    Set swapColor:__val1

draw:
    Set CharScreen.Character:#PLAYER_CHAR
    Set CharScreen.PenColor:#PLAYER_COLOR
    Call CharScreen.Plot:x:y

end:
    rts

}

