#importonce
#import "_prelude.lib"
#import "../globals.asm"
#import "Agent.asm"
#import "_joystick.lib"

.namespace Agent{
    .namespace PlayerBehaviors {
        Update: {
            Call ReadJoystick

            GetW(Agent.x, x)
            GetW(Agent.y, y)
            Get(Agent.dx, dx)
            Get(Agent.dy, dy)

            // StoreInitialPos
            lda y; sta y0
            lda x; sta x0

            // dy is signed and must be clamped to prevent overflow, or suddenly switching from +ve to -ve
            lda dy
            clc
            adc #GRAVITY
            bvs !+
                sta dy
            !:

            Sat16(dy, dHi)

            // y + dy
            // add low .bytes
            // TODO: looks abit wrong? big-endian?
            lda y+1
            clc
            adc dy
            sta y+1
            lda y
            adc dHi
            sta y

            Sat16(dx, dHi)

            // x + dx
            lda x+1
            clc
            adc dx
            sta x+1
            lda x
            adc dHi
            sta x

            Set(Agent.dx, dx)
            Set(Agent.dy, dy)
            SetW(Agent.x, x)
            SetW(Agent.y, y)
            SetW(Agent.x0, x0)
            SetW(Agent.y0, y0)

            Call CollisionImmediate

            rts
            dHi: .byte 0
            dy: .byte 0
            dx: .byte 0
            y: .word 0
            x: .word 0
            y0: .word 0
            x0: .word 0        
        }

        ReadJoystick: {
            Get(Agent.dx, dx)
            Get(Agent.dy, dy)

            Call Joystick.Read
            // merge flags, top 3 bits preserved, lower 5 replaced
            lda playerAction
            and #%11100000
            eor __val0
            sta playerAction

            lda #Joystick.LEFT
            bit playerAction 
            beq !+
                Set dx:#-SPEED
            !:

            lda #Joystick.RIGHT
            bit playerAction 
            beq !+
                Set dx:#SPEED
            !:

            lda #ACTION_IS_JUMPING
            bit playerAction
            bne !skip+
                lda #Joystick.FIRE
                bit playerAction 
                beq !+
                    Set dy:#IMPULSE
                    SetBit playerAction:#ACTION_IS_JUMPING
                !:
            !skip:

            Set(Agent.dx, dx)
            Set(Agent.dy, dy)

            rts

            dx: .byte 0
            dy: .byte 0
        }

        CollisionCastRay: {
            GetW(Agent.x, x)
            GetW(Agent.y, y)
            GetW(Agent.x0, x0)
            GetW(Agent.y0, y0)
            Get(Agent.dx, dx)
            Get(Agent.dy, dy)
            
            Set __ptr0:#<(checkCollision)
            Set __ptr0+1:#>(checkCollision)
            
            // this is the most expensive collision check
            Call CharScreen.CastRay:x0:y0:x:y

            Set(Agent.dx, dx)
            Set(Agent.dy, dy)
            SetW(Agent.x, x)
            SetW(Agent.y, y)

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

            dy: .byte 0
            dx: .byte 0
            x0: .word 0
            y0: .word 0
            x: .word 0
            y: .word 0
        }

        CollisionImmediate: {
            // very cheap and fast
            // falls off the ceiling, but sticks to the walls
            GetW(Agent.x, x)
            GetW(Agent.y, y)
            GetW(Agent.x0, x0)
            GetW(Agent.y0, y0)
            Get(Agent.dx, dx)
            Get(Agent.dy, dy)

            // what direction?
            Call CharScreen.Read:x:y
            lda __val0
            cmp #GROUND_CHAR
            bne !skip+
                // set player back to position before collision
                SetW(Agent.x, x0)
                SetW(Agent.y, y0)

                // kill horizontal movement
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