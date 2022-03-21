#importonce
#import "_prelude.lib"
#import "../globals.asm"
#import "Agent.asm"
#import "_joystick.lib"

.namespace PlayerBehaviors {


    PlayerUpdate: {
        Call ReadJoystick

        Call Agent.GetField:#Agent.dx
        Set dx:__val0
        Call Agent.GetField:#Agent.dy
        Set dy:__val0
        Call Agent.GetField:#Agent.x
        Set x:__val0
        Set x+1:__val1
        Call Agent.GetField:#Agent.y
        Set y:__val0
        Set y+1:__val1

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

        Call Agent.SetField:#Agent.dx:dx
        Call Agent.SetField:#Agent.dy:dy
        Call Agent.SetFieldW:#Agent.x:x:x+1
        Call Agent.SetFieldW:#Agent.y:y:y+1
        Call Agent.SetFieldW:#Agent.x0:x0:x0+1
        Call Agent.SetFieldW:#Agent.y0:y0:y0+1

    
        Call Collision

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
        Call Agent.GetField:#Agent.dx
        Set dx:__val0
        Call Agent.GetField:#Agent.dy
        Set dy:__val0

        Call Joystick.Read
        Set playerAction:__val0

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

        // read_joystick:
        //     // left
        //     lda #JOYSTICK_LEFT
        //     bit PORT2
        //     bne !skip+
        //         lda #ACTION_IS_JUMPING
        //         bit playerAction
        //         beq !+
        //             Set dx:#-SPEED/2
        //             jmp !skip+
        //         !:
        //             Set dx:#-SPEED
        //     !skip: 
                
        //     // right
        //     lda #JOYSTICK_RIGHT
        //     bit PORT2
        //     bne !skip+
        //         lda #ACTION_IS_JUMPING
        //         bit playerAction
        //         beq !+
        //             Set dx:#SPEED/2
        //             jmp !skip+
        //         !:
        //             Set dx:#SPEED
        //     !skip: 

        //     // up
        //     // down

        //     // fire
        //     lda #ACTION_IS_JUMPING
        //     bit playerAction
        //     // no double jumping
        //     bne !skip+
        //         lda #JOYSTICK_FIRE
        //         bit PORT2
        //         bne !skip+
        //             Set dy:#IMPULSE
        //             SetBit playerAction:#ACTION_IS_JUMPING
        //     !skip:

            Call Agent.SetField:#Agent.dx:dx
            Call Agent.SetField:#Agent.dy:dy
        rts

        dx: .byte 0
        dy: .byte 0
    }

    Collision: {
        // TODO: it would be great to get a better pattern here so 
        // we can avoid the copying of memory

        Call Agent.GetField:#Agent.x
        Set x:__val0
        Set x+1:__val1
        Call Agent.GetField:#Agent.y
        Set y:__val0
        Set y+1:__val1
        Call Agent.GetField:#Agent.x0
        Set x0:__val0
        Set x0+1:__val1
        Call Agent.GetField:#Agent.y0
        Set y0:__val0
        Set y0+1:__val1 
        Call Agent.GetField:#Agent.dx
        Set dx:__val0
        Call Agent.GetField:#Agent.dy
        Set dy:__val0     

        Set __ptr0:#<(checkCollision)
        Set __ptr0+1:#>(checkCollision)

        Call CharScreen.CastRay:x0:y0:x:y

        Call Agent.SetFieldW:#Agent.x:x:x+1
        Call Agent.SetFieldW:#Agent.y:y:y+1

        Call Agent.SetField:#Agent.dx:dx
        Call Agent.SetField:#Agent.dy:dy

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
}