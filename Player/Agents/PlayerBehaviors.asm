#importonce
#import "_prelude.lib"
#import "_joystick.lib"
#import "_math.lib"
#import "Agent.asm"
#import "../globals.asm"

.namespace Agent{
    .namespace PlayerBehaviors {
        .const JERK = -120
        .const SPEED = 80
        .const LEFTGLYPH = 79
        .const RIGHTGLYPH = 80
        .const IDLEGLYPH = 3
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

            AgentInvoke(Agent.CurrentState)

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

        UpdatePhysics: {
            // dy is signed and must be clamped to prevent overflow,
            // dy+=gravity
            lda _dy
            clc
            adc #GRAVITY
            bvs !+
                sta _dy
            !:

            rts
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
                Set _dx:#-SPEED/2
                lda #ACTION_IS_JUMPING
                bit _playerAction
                bne !skip+
                    Set _dx:#-SPEED
                !skip:
                SetPtr(Agent.CurrentState, Running)
            !:

            lda #Joystick.RIGHT
            bit _playerAction 
            beq !+
                Set _dx:#SPEED/2
                lda #ACTION_IS_JUMPING
                bit _playerAction
                bne !skip+
                    Set _dx:#SPEED
                !skip:
                SetPtr(Agent.CurrentState, Running)
            !:

            lda #ACTION_IS_JUMPING
            bit _playerAction
            bne !skip+
                // lda #Joystick.FIRE
                // bit _playerAction 
                // beq !+
                lda #Joystick.UP
                bit _playerAction 
                beq !+                
                    Set _dy:#JERK
                    SetBit _playerAction:#ACTION_IS_JUMPING
                    SetPtr(Agent.CurrentState, Jumping)
                !:
            !skip:

            rts
        }        

        Idle: {
            dec anim
            lda anim
            cmp #$A0
            bcc !+
                Set _glyph:#3
                rts
            !:

            cmp #$80
            bcc !+
                Set _glyph:#5
                rts
            !:

            cmp #$40
            bcc !+
                Set _glyph:#4
                rts
            !:
            
            cmp #$20
            bcc !+
                Set _glyph:#3
                rts
            !:

            Set _glyph:#4
            rts
            anim: .byte 0
        }

        Running: {
            dec anim
            dec anim
            dec anim
            dec anim
            dec anim
            dec anim
            dec anim
            dec anim
            lda #128
            bit _dx
            beq left
                lda anim
                cmp #$aa
                bcc !+
                    Set _glyph:#6   
                    rts
                !:
                cmp #$55
                bcc !+
                    Set _glyph:#7   
                    rts
                !:
                cmp #$00
                bcc !+
                    Set _glyph:#8  
                    rts
                !:
                rts
            left:
                lda anim
                cmp #$aa
                bcc !+
                    Set _glyph:#0   
                    rts
                !:
                cmp #$55
                bcc !+
                    Set _glyph:#1
                    rts
                !:
                cmp #$00
                bcc !+
                    Set _glyph:#2
                    rts
                !:
                rts
            rts
            anim: .byte 0
        }

        Jumping: {
            lda #128
            bit _dx
            beq left
                Set _glyph:#7
                rts
            left:
            Set _glyph:#2
            rts
        }

        UpdatePosition: {
            // StoreInitialPos
            Set _x0+1:_x+1
            Set _y0+1:_y+1

            // update position
            // y + dy
            Sat16 _dy: _dHi
            Add16 _y:_y+1:_dy:_dHi
            Set _y:__val0
            Set _y+1:__val1

            // x + dx
            Sat16 _dx: _dHi
            Add16 _x:_x+1:_dx:_dHi
            Set _x:__val0
            Set _x+1:__val1

            rts
        }

        Collision: {
            lda _dx
            bmi checkLeft
            bpl checkRight

            checkLeft: 
                Call CharScreen.Read:_x+1:_y+1
                lda __val0
                cmp #GROUND_CHAR
                bne !skip+
                    Set _x:_x0
                    Set _x+1:_x0+1
                    Set _dx:#0
                !skip:
                    jmp end_h

            checkRight: 
                Call CharScreen.Read:_x+1:_y+1
                lda __val0
                cmp #GROUND_CHAR
                bne !skip+
                    Set _x:_x0
                    Set _x+1:_x0+1
                    Set _dx:#0
                !skip:
            end_h:

            lda _dy
            bmi checkUp
            bpl checkDown

            checkUp: 
                Call CharScreen.Read:_x+1:_y+1
                lda __val0
                cmp #GROUND_CHAR
                bne !skip+
                    Set _y:_y0
                    Set _y+1:_y0+1
                    Set _dy:#0
                !skip:   
                    jmp end_v

            checkDown: 
                Call CharScreen.Read:_x+1:_y+1
                lda __val0
                cmp #GROUND_CHAR
                bne end_v
                    Set _y:_y0
                    Set _y+1:_y0+1
                    Set _dy:#0
                    Set _dx:#0
                    // allow jump
                    lda _playerAction
                    and #~ACTION_IS_JUMPING
                    sta _playerAction
            end_v:

            rts
         }

         // current player state.  
        _dy: .byte 0
        _dx: .byte 0
        _x0: .word 0
        _y0: .word 0
        _x: .word 0
        _y: .word 0
        _glyph: .byte 0
        // default state for the action flags
        _playerAction: .byte %00100000        
        _dHi: .byte 0
    }
}