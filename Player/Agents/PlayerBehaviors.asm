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
        // friction is a signed word, fixed point, so low byte only, $00..$7f
        // the higher friction is the less effect it has
        .const FRICTION = $0060
        .const LEFTGLYPH = 79
        .const RIGHTGLYPH = 80
        .const IDLEGLYPH = 93

        .const ACTION_PRESSED_BUTTON    = %00010000
        .const ACTION_IS_JUMPING        = %00100000

        Update: {
            GetW(Agent.x, _x)
            GetW(Agent.y, _y)
            GetW(Agent.x0, _x0)
            GetW(Agent.y0, _y0)
            Get(Agent.dx, _dx)
            Get(Agent.dy, _dy)
            Get(Agent.glyph, _glyph)

            jsr UpdatePhysics
            jsr ReadJoystick

            Call Agent.Invoke:#Agent.CurrentState

            jsr UpdatePosition
            jsr Collision

            SetW(Agent.x, _x)
            SetW(Agent.y, _y)
            SetW(Agent.x0, _x0)
            SetW(Agent.y0, _y0)
            Set(Agent.dx, _dx)
            Set(Agent.dy, _dy)
            Set(Agent.glyph, _glyph)

            rts
        }

        Idle: {
            Set _glyph:#IDLEGLYPH
            rts
        }

        MoveLeft: {
            Set _glyph:#LEFTGLYPH
            rts
        }

        MoveRight: {
            Set _glyph:#RIGHTGLYPH
            rts
        }

        Jump: {
            rts
        }

        UpdatePhysics: {
            // dy is signed and must be clamped to prevent overflow,
            // dy+=gravity
            lda _dy
            clc
            adc #GRAVITY
            bvs !+
                sta _dy
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

            rts
        }

        UpdatePosition: {
            // StoreInitialPos
            Set _x0+1:_x+1
            Set _y0+1:_y+1

            // update position
            // y + dy
            Sat16 _dy: dHi
            Add16 _y:_y+1:_dy:dHi
            Set _y:__val0
            Set _y+1:__val1

            // x + dx
            Sat16 _dx: dHi
            Add16 _x:_x+1:_dx:dHi
            Set _x:__val0
            Set _x+1:__val1

            rts
            dHi: .byte 0
        }

        // read joystick and update dx,dy and current state
        ReadJoystick: {
            Call Joystick.Read
            // merge flags, top 3 bits preserved, lower 5 cleared
            lda _playerAction
            and #%11100000
            eor __val0
            sta _playerAction

            SetPtr(Agent.CurrentState, Idle)

            lda #Joystick.LEFT
            bit _playerAction 
            beq !+
                lda _dx
                sec
                sbc #ACCELERATION
                cmp #-MAX_DX
                bpl !skip+
                    lda #-MAX_DX                
                !skip:
                    sta _dx

                SetPtr(Agent.CurrentState, MoveLeft)
            !:

            lda #Joystick.RIGHT
            bit _playerAction 
            beq !+
                lda _dx
                clc
                adc #ACCELERATION
                cmp #MAX_DX
                bmi !skip+
                    lda #MAX_DX                
                !skip:
                    sta _dx

                SetPtr(Agent.CurrentState, MoveRight)
            !:

            lda #Joystick.FIRE
            bit _playerAction 
            beq !+
                SetBit _playerAction:#ACTION_PRESSED_BUTTON
            !:

            lda #ACTION_IS_JUMPING
            bit _playerAction
            bne !skip+
                lda #Joystick.UP
                bit _playerAction 
                beq !+
                    Set _dy:#JERK
                    SetBit _playerAction:#ACTION_IS_JUMPING
                    SetPtr(Agent.CurrentState, Jump)
                !:
            !skip:

            rts
        }

        Collision: {
            // very cheap and fast
            // falls off the ceiling, but sticks to the walls
            // what direction?
            Call CharScreen.Read:_x+1:_y+1
            lda __val0
            cmp #GROUND_CHAR
            bne !skip+
                // set player back to position before collision
                Set _x:_x0
                Set _x+1:_x0+1
                Set _y:_y0
                Set _y+1:_y0+1
               
                // kill horizontal
                // TODO: interplay with friciton, which is currently disabled
                Set _dx:#0

                // only allow jump if we collided DOWN
                lda _dy
                cmp #0
                bmi end_v
                    setDown: 
                        // allow jump
                        lda _playerAction
                        // notice ~ negate
                        and #~ACTION_IS_JUMPING
                        sta _playerAction
                end_v:

                // kill vertical
                Set _dy:#0

                Set __val0:#ACTION_HANDLED
                rts
            !skip:
                Set __val0:#0
            rts
         }

         // current player state.  
         // TODO: pity i have to do memcpy, still trying to have an epiphany to get rid of it
         // the state looks like it is going to migrate from the Agent to here, at least for player.
        _dy: .byte 0
        _dx: .byte 0
        _x0: .word 0
        _y0: .word 0
        _x: .word 0
        _y: .word 0
        _glyph: .byte 0
        // default state for the action flags
        _playerAction: .byte %00100000        
    }
}