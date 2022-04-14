#importonce
#import "../globals.asm"
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Agent.asm"

.namespace Agent{
    .namespace AgentBehaviors {
        DefaultRender: {
            // Render operates on player x, y, glyph, color, and bgX, bgY, bgGlyph, bgColor

            GetW(Agent.x, x)
            GetW(Agent.y, y)
            Get(Agent.bgGlyph, bgGlyph)
            Get(Agent.bgColor, bgColor)
            Get(Agent.glyph, glyph)
            Get(Agent.color, color)
            Get(Agent.bgX, bgX)
            Get(Agent.bgY, bgY)
            
            // check if the last render position has changed
            lda bgX
            cmp x+1
            bne swap
            lda bgY
            cmp y+1
            bne swap
            // neither x or y changed, no work to do
            // redraw anyway as character may be animated 
            jmp draw

        swap:    
            // restore the background 
            Set CharScreen.PenColor:bgColor
            Set CharScreen.Character:bgGlyph
            Call CharScreen.Plot:bgX:bgY

            // store new background data
            Call CharScreen.Read:x+1:y+1
            Set(Agent.bgGlyph, __val0)
            Set(Agent.bgColor, __val1)
            Set(Agent.bgX, x+1)
            Set(Agent.bgY, y+1)
        draw:
            // draw the current position
            Set CharScreen.Character:glyph
            Set CharScreen.PenColor:color
            Call CharScreen.Plot:x+1:y+1
        end:
            
            rts

            bgColor: .byte 0
            bgGlyph: .byte 0
            bgX: .byte 0
            bgY: .byte 0
            x: .word 0
            y: .word 0
            color: .byte 0
            glyph: .byte 0
        }

        NoOperation: {
            rts
        }
    }
}