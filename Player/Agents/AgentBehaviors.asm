#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "../globals.asm"
#import "Agent.asm"

.namespace AgentBehaviors {

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

    NoOperation: {
        rts
    }
}
