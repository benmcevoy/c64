BasicUpstart2(Start)

// let's try 
// - ray casting for collision detection -= RAY Marching =-
//      refactor charlib to have the line calc just return the set of points to test?
//      need a stack or a queue or list or something...
//      for speed i think replacing the Call Plot with Call Read allows exit early
// - a game field, i should not have to redraw the every render
//      ye-ikes - now it is screaming fast

#import "_prelude.lib"
#import "_charscreen.lib"

.const GRAVITY = 2
.const IMPULSE = -64
.const SPEED = 48

.const GROUND_CHAR = 102
.const BLANK_CHAR = 32
.const PLAYER_CHAR = 224
.const COLLISION_INDICATOR_CHAR = 81

.label debug = $c000
.label PORT2 = $dc00

// state
x: .word 0
y: .word 0
dx: .byte 0
dy: .byte 0
y0: .byte 0
x0: .byte 0


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
    jsr $E544
    Set $d020:#BLACK
    Set $d021:#BLACK
    // x,y are in 16 bit "game space", the high byte is "screen space", nice.
    // screen space being 0:39,0:24
    Set x:#20
    Set x+1:#0

    Set y:#2
    Set y+1:#0

    Set dx:#0
    Set dy:#0

    jsr DrawGameField

    Loop: 
        // StoreInitialPos
        lda y; sta y0
        lda x; sta x0
        
        jsr ReadJoystick
        jsr UpdatePos
        jsr CheckCollisions

        // maybe try move render to a raster irq line? it's very stable now and seems unneeded
        jsr Render
        
    jmp Loop
}

DrawGameField: {
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
    rts
}

ReadJoystick: {
    // read joystick and mess with dx

    // let dx tend back to zero
    // This is a simple kind of momentum, 
    // you could have in y too for a race car game or something, sliding, 
    // or use rol or something to dampen instead of inc/dec
    // lda dx
    // // signed CMP, dx > 0
    // cmp #0
    // beq readJoystick
    // bmi !+
    //     dec dx
    //     jmp readJoystick
    // !:
    // inc dx

    // no momentum
    Set dx:#0

    readJoystick:
        // left
        lda #ACTION_COLLIDED_LEFT
        bit playerAction
        bne !+
            lda #JOYSTICK_LEFT
            bit PORT2
            bne !+
                Set dx:#-SPEED
        !: 
            
        // right
        lda #ACTION_COLLIDED_RIGHT
        bit playerAction
        bne !+
            lda #JOYSTICK_RIGHT
            bit PORT2
            bne !+
                Set dx:#SPEED
        !: 
        
        // up
        lda #ACTION_IS_JUMPING
        bit playerAction
        // no double jumping
        bne !+
            lda #JOYSTICK_UP
            bit PORT2
            bne !+
                Set dy:#IMPULSE
                SetBit playerAction:#ACTION_IS_JUMPING
        !:

        // fire
        lda #JOYSTICK_FIRE
        bit PORT2
        bne !+
            SetBit playerAction:#ACTION_IS_FIRING
        !:
    rts
}

UpdatePos: {
    // update dy
    // add GRAVITY instead of subtract due to screen co-ords being 0,0<>top,left
    // TODO: could just be `inc dy` if gravity is always 1 
    // if no gravity then the read joystick could test for up/down and set dy according, like it does for dx

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
    // TODO: the cast ray evaluates points right to left or in the wrong order in some cases
    // this means we are testing for collisions in the wrong places
    // need to test in the direction of movement
    // in the CastRay we have to remove or account for where we swap x0<>x1 etc

    // clear previous collisions
    lda playerAction
    and #~%00001111
    sta playerAction
    
    horizontal:
        // are we going right?
        lda dx
        cmp #0
        beq !+
        bpl right
        jmp left

        !: jmp vertical

        right: {
            Set __ptr0:#<(checkCollisionRight)
            Set __ptr0+1:#>(checkCollisionRight)

            Call CharScreen.CastRay:x0:y0:x:y

            jmp vertical

            checkCollisionRight:{
                .var xRay = __arg0
                .var yRay = __arg1
                
                inc xRay

                Call CharScreen.Read:xRay:yRay

                lda __val0
                cmp #GROUND_CHAR
                bne !+
                    // Set CharScreen.Character:#COLLISION_INDICATOR_CHAR
                    // Call CharScreen.Plot:xRay:yRay

                    dec xRay
                    lda xRay
                    sta x
                    Set x+1:#0
                    Set dx:#0

                    SetBit playerAction:#ACTION_COLLIDED_RIGHT

                    Set __val0:#$ff
                    rts
                !:
                
                Set __val0:#0
                rts
            }
        }

        left:{
            Set __ptr0:#<(checkCollisionLeft)
            Set __ptr0+1:#>(checkCollisionLeft)

            Call CharScreen.CastRay:x0:y0:x:y

            jmp vertical

            checkCollisionLeft: {
                .var xRay = __arg0
                .var yRay = __arg1
                
                dec xRay

                Call CharScreen.Read:xRay:yRay

                lda __val0
                cmp #GROUND_CHAR
                bne !+
                    // Set CharScreen.Character:#COLLISION_INDICATOR_CHAR
                    // Call CharScreen.Plot:xRay:yRay

                    inc xRay
                    lda xRay
                    sta x
                    Set x+1:#0
                    Set dx:#0

                    SetBit playerAction:#ACTION_COLLIDED_LEFT

                    Set __val0:#$ff
                    rts
                !:
                
                Set __val0:#0
                rts
            }
        }

    vertical:
        // are we going up?
        lda dy
        cmp #0
        beq !+
        bpl down
        jmp up

        !: rts
        
        down: {
            Set __ptr0:#<(checkCollisionDown)
            Set __ptr0+1:#>(checkCollisionDown)

            Call CharScreen.CastRay:x0:y0:x:y

            rts

            checkCollisionDown:{
                .var xRay = __arg0
                .var yRay = __arg1

                // look down
                inc yRay

                Call CharScreen.Read:xRay:yRay
                lda __val0
                cmp #GROUND_CHAR
                bne !+
                    // Set CharScreen.Character:#COLLISION_INDICATOR_CHAR
                    // Call CharScreen.Plot:xRay:yRay

                    dec yRay
                    lda yRay
                    sta y

                    Set y+1:#0
                    Set dy:#0

                    lda playerAction
                    and #~ACTION_IS_JUMPING
                    sta playerAction

                    SetBit playerAction:#ACTION_COLLIDED_DOWN

                    Set __val0:#$ff

                    rts
                !:

                Set __val0:#0
                rts
            }
        }

        up: {
            Set __ptr0:#<(checkCollisionUp)
            Set __ptr0+1:#>(checkCollisionUp)

            Call CharScreen.CastRay:x0:y0:x:y

            rts

            checkCollisionUp:{
                .var xRay = __arg0
                .var yRay = __arg1
                
                dec yRay

                Call CharScreen.Read:xRay:yRay

                lda __val0
                cmp #GROUND_CHAR
                bne !+
                    // Set CharScreen.Character:#COLLISION_INDICATOR_CHAR
                    // Call CharScreen.Plot:xRay:yRay

                    inc yRay
                    lda yRay
                    sta y
                    Set y+1:#0
                    Set dy:#0

                    SetBit playerAction:#ACTION_COLLIDED_UP

                    Set __val0:#$ff
                    rts
                !:
                
                Set __val0:#0
                rts
            }
        }

    exit: rts
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

    Set CharScreen.Character:#PLAYER_CHAR
    Set CharScreen.PenColor:#WHITE
    Call CharScreen.Plot:x:y

    // slow everything down, comment out for speed
    //jsr DrawGameField    

    rts
}

    