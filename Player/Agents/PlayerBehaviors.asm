#importonce
#import "_prelude.lib"
#import "_joystick.lib"
#import "_math.lib"
#import "Agent.asm"
#import "../globals.asm"

.namespace Agent{
    .namespace PlayerBehaviors {
        .const JERK = -72
        .const ACCELERATION = 60
        .const MAX_DX = 60
        // similar to joystick flags, updated each time to reflect joystick
        .const ACTION_COLLIDED_UP       = %00000001
        .const ACTION_COLLIDED_DOWN     = %00000010
        .const ACTION_COLLIDED_LEFT     = %00000100
        .const ACTION_COLLIDED_RIGHT    = %00001000
        .const ACTION_PRESSED_BUTTON    = %00010000

        // the high three bits are preserved during update
        .const ACTION_IS_JUMPING        = %00100000
        .const ACTION_IS_SHOOTING       = %01000000
        // default state for the above flags
        playerAction: .byte %00100000        
        // friction is a signed word, fixed point, so low byte only, $00..$7f
        // the higher friction is the less effect it has
        friction: .word $0060

        .const LEFTGLYPH = 79
        .const RIGHTGLYPH = 80
        .const STILLGLYPH = 93

        Update: {
            jsr ReadJoystick

            GetW(Agent.x, x)
            GetW(Agent.y, y)
            Get(Agent.dx, dx)
            Get(Agent.dy, dy)
            Get(Agent.glyph, glyph)

            // StoreInitialPos
            lda y+1; sta y0+1
            lda x+1; sta x0+1

            // dy is signed and must be clamped to prevent overflow,
            // dy+=gravity
            lda dy
            clc
            adc #GRAVITY
            bvs !+
                sta dy
            !:

            // // dx*=friction, no friction when jumping
            // lda #ACTION_IS_JUMPING
            // bit playerAction
            // beq !+
            //     jmp cont
            // !: 
            //     Sat16 dx: dHi
            //     SMulW32 dx:dHi:friction:friction+1
            //     Set dx:__val1
                
            //     // snap dx to zero when close to zero
            //     lda dx
            //     bpl !+
            //         NegateA
            //     !:
            //     cmp #5
            //     bcs !+
            //         Set dx:#0
            //     !:
            // cont:

            lda dx
            cmp #0
            bne !+
                Set glyph:#STILLGLYPH
            !:

            // update position
            // y + dy
            Sat16 dy: dHi
            Add16 y:y+1:dy:dHi
            Set y:__val0
            Set y+1:__val1

            // x + dx
            Sat16 dx: dHi
            Add16 x:x+1:dx:dHi
            Set x:__val0
            Set x+1:__val1

            Set(Agent.dx, dx)
            Set(Agent.dy, dy)
            SetW(Agent.x, x)
            SetW(Agent.y, y)
            SetW(Agent.x0, x0)
            SetW(Agent.y0, y0)
            Set(Agent.glyph, glyph) 

            jsr Collision

            rts
            dHi: .byte 0
            dy: .byte 0
            dx: .byte 0
            y: .word 0
            x: .word 0
            y0: .word 0
            x0: .word 0    
            glyph: .byte 0    
        }

        ReadJoystick: {
            Get(Agent.dx, dx)
            Get(Agent.dy, dy)
            Get(Agent.glyph, glyph)

            Call Joystick.Read
            // merge flags, top 3 bits preserved, lower 5 cleared
            lda playerAction
            and #%11100000
            eor __val0
            sta playerAction

            lda #Joystick.LEFT
            bit playerAction 
            beq !+
                lda dx
                sec
                sbc #ACCELERATION
                cmp #-MAX_DX
                bpl !skip+
                    lda #-MAX_DX                
                !skip:
                    sta dx

                Set glyph:#LEFTGLYPH
            !:

            lda #Joystick.RIGHT
            bit playerAction 
            beq !+
                lda dx
                clc
                adc #ACCELERATION
                cmp #MAX_DX
                bmi !skip+
                    lda #MAX_DX                
                !skip:
                    sta dx
                Set glyph:#RIGHTGLYPH
            !:

            lda #Joystick.FIRE
            bit playerAction 
            beq !+
                SetBit playerAction:#ACTION_PRESSED_BUTTON
            !:

            lda #ACTION_IS_JUMPING
            bit playerAction
            bne !skip+
                lda #Joystick.UP
                bit playerAction 
                beq !+
                    Set dy:#JERK
                    SetBit playerAction:#ACTION_IS_JUMPING
                !:
            !skip:

            Set(Agent.dx, dx)
            Set(Agent.dy, dy)
            Set(Agent.glyph, glyph)

            rts

            dx: .byte 0
            dy: .byte 0
            glyph: .byte 0
        }

        Collision: {
            // very cheap and fast
            // falls off the ceiling, but sticks to the walls
            GetW(Agent.x, x)
            GetW(Agent.y, y)
            GetW(Agent.x0, x0)
            GetW(Agent.y0, y0)
            Get(Agent.dx, dx)
            Get(Agent.dy, dy)

            // what direction?
            Call CharScreen.Read:x+1:y+1
            lda __val0
            cmp #GROUND_CHAR
            bne !skip+
                // set player back to position before collision
                SetW(Agent.x, x0)
                SetW(Agent.y, y0)
               
                // kill horizontal
                // TODO: interplay with friciton, which is currently disabled
                Set dx:#0

                // only allow jump if we collided DOWN
                lda dy
                cmp #0
                bmi end_v
                    setDown: 
                        // allow jump
                        lda playerAction
                        // notice ~ negate
                        and #~ACTION_IS_JUMPING
                        sta playerAction
                end_v:

                // kill vertical
                Set dy:#0
                Set(Agent.dx, dx)   
                Set(Agent.dy, dy)   

                Set __val0:#ACTION_HANDLED
                rts
            !skip:
                Set __val0:#0

            rts

            dy: .byte 0
            dx: .byte 0
            x0: .word 0
            y0: .word 0
            x: .word 0
            y: .word 0
         }
    }
}