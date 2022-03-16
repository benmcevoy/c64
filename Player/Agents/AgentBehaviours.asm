#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "../globals.asm"
#import "Agent.asm"

.namespace AgentBehaviours {

    DefaultCollision: {
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

    DefaultRender: {
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
        Call Agent.GetField:#Agent.glyph0
        Set swapChar:__val0
        Call Agent.GetField:#Agent.color0
        Set swapColor:__val0
        Call Agent.GetField:#Agent.glyph
        Set glyph:__val0
        Call Agent.GetField:#Agent.color
        Set color:__val0        

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
        Set CharScreen.Character:glyph
        Set CharScreen.PenColor:color
        Call CharScreen.Plot:x:y

    end:
        Call Agent.SetField:#Agent.glyph0:swapChar
        Call Agent.SetField:#Agent.color0:swapColor

        rts

        swapColor: .byte 0
        swapChar: .byte 0
        x0: .word 0
        y0: .word 0
        x: .word 0
        y: .word 0
        color: .byte 0
        glyph: .byte 0
    }

    DefaultUpdate: {

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
        Call Agent.SetField:#Agent.x:x:x+1
        Call Agent.SetFieldW:#Agent.y:y:y+1
        Call Agent.SetFieldW:#Agent.x0:x0:x0+1
        Call Agent.SetFieldW:#Agent.y0:y0:y0+1

        rts
        dHi: .byte 0
        dy: .byte 0
        dx: .byte 0
        y: .word 0
        x: .word 0
        y0: .word 0
        x0: .word 0        
    }

    SimpleRender: {
        Call Agent.GetField:#Agent.x
        Set x:__val0
        Set x+1:__val1
        Call Agent.GetField:#Agent.y
        Set y:__val0
        Set y+1:__val1
        
        Call Agent.GetField:#Agent.color
        Set color:__val0        
        Call Agent.GetField:#Agent.glyph
        Set glyph:__val0  

    draw:
        Set CharScreen.Character:glyph
        Set CharScreen.PenColor:color
        Call CharScreen.Plot:x:y

        rts

        x: .word 0
        y: .word 0
        color: .byte 0
        glyph: .byte 0
    }

    SimpleUpdate: {
        // just spin color
        Call Agent.GetField:#Agent.color
        inc __val0

        Call Agent.SetField:#Agent.color:__val0
        
        rts
        
    }

    NoOperation: {
        rts
    }
}
