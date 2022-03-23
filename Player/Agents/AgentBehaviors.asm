#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "../globals.asm"
#import "Agent.asm"

.namespace Agent{
    .namespace AgentBehaviors {
        DefaultRender: {
            GetW(Agent.x, x)
            GetW(Agent.y, y)
            GetW(Agent.x0, x0)
            GetW(Agent.y0, y0)
            Get(Agent.bgGlyph, bgGlyph)
            Get(Agent.bgColor, bgColor)
            Get(Agent.glyph, glyph)
            Get(Agent.color, color)
            
            lda x0
            cmp x
            bne swap
            lda y0
            cmp y
            bne swap
            jmp draw
            
        swap:    
            Set CharScreen.PenColor:bgColor
            Set CharScreen.Character:bgGlyph
            Call CharScreen.Plot:x0:y0

            Call CharScreen.Read:x:y
            Set(Agent.bgGlyph, __val0)
            Set(Agent.bgColor, __val1)
        draw:
            Set CharScreen.Character:glyph
            Set CharScreen.PenColor:color
            Call CharScreen.Plot:x:y
        end:
            
            rts

            bgColor: .byte 0
            bgGlyph: .byte 0
            x0: .word 0
            y0: .word 0
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