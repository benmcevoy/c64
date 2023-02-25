#importonce
#import "_prelude.lib"
#import "_joystick.lib"
#import "_math.lib"
#import "Agent.asm"
#import "../globals.asm"

.namespace Agent{
    .namespace PlayerBehaviors {
        .const JERK = -100
        .const SPEED = 50
        .const LEFTGLYPH = 79
        .const RIGHTGLYPH = 80
        .const IDLEGLYPH = 3
        .const ACTION_PRESSED_BUTTON    = %00010000
        .const ACTION_IS_JUMPING        = %00100000

        .const SPIKEL = 40
        .const SPIKER = 38
        .const SPIKEU = 39
        .const SPIKED = 37


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
            dec duration
            bne exit

            ldx frame
            lda animation,X
            cmp #$ff
            beq !+
                sta _glyph
                inx 
                lda animation,X
                sta duration
                inx
                stx frame
                rts
            !:

        reset:   
            lda #0
            sta frame
            inc duration
        
        exit: rts
            animation: .byte 5,40,4,40, $ff  // and 3 for the foot tap
            frame: .byte 0
            duration: .byte 1
        }

        Running: {
            dec duration
            bne exit

            lda _dx
            bpl right

        left:
            ldx frame
            lda runningLeft,X
            cmp #$ff
            beq !+
                sta _glyph
                inx 
                lda runningLeft,X
                sta duration
                inx
                stx frame
                rts
            !:
            jmp reset
            
        right:    
            ldx frame
            lda runningRight,X
            cmp #$ff
            beq !+
                sta _glyph
                inx 
                lda runningRight,X
                sta duration
                inx
                stx frame
                rts
            !:

        reset:
            lda #0
            sta frame
            inc duration
        
        exit: rts
            runningLeft: .byte 15,10, 14,10, 13,10, $ff  
            runningRight: .byte 1,10, 2,10, 3,10, $ff  
            frame: .byte 0
            duration: .byte 1
        }

        Jumping: {
            lda _dx
            bmi left
                Set _glyph:#8
                rts
            left:
            Set _glyph:#7
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
                    jmp end_h
                !skip:
                // cmp #SPIKEL
                // bne end_h
                //     Set _dx:#-JERK
                    
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