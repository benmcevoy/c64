#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Agent.asm"

.namespace AgentBehaviours {

    Initialise: {
        Call Agent.SetFieldW:#0:#Agent.Update:#<DefaultUpdate:#>DefaultUpdate
        Call Agent.SetFieldW:#0:#Agent.Render:#<DefaultRender:#>DefaultRender
        

        rts
    }

    DefaultRender: {
        .var index = __arg0

        Call Agent.GetField:index:#Agent.x
        Set x:__val0
        Set x+1:__val1
        Call Agent.GetField:index:#Agent.y
        Set y:__val0
        Set y+1:__val1
        Call Agent.GetField:index:#Agent.x0
        Set x0:__val0
        Set x0+1:__val1
        Call Agent.GetField:index:#Agent.y0
        Set y0:__val0
        Set y0+1:__val1        
        Call Agent.GetField:index:#Agent.glyph0
        Set swapChar:__val0
        Call Agent.GetField:index:#Agent.color0
        Set swapColor:__val0
        Call Agent.GetField:index:#Agent.glyph
        Set color:__val0
        Call Agent.GetField:index:#Agent.color
        Set glyph:__val0        


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
        Set CharScreen.Character:#glyph
        Set CharScreen.PenColor:#color
        Call CharScreen.Plot:x:y

    end:
        Call Agent.SetField:index:#Agent.glyph0:swapChar
        Call Agent.SetField:index:#Agent.color0:swapColor

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
        .var index = __arg0

        Call Agent.GetField:index:#Agent.dx
        Set dx:__val0
        Call Agent.GetField:index:#Agent.dy
        Set dy:__val0
        Call Agent.GetField:index:#Agent.x
        Set x:__val0
        Set x+1:__val1
        Call Agent.GetField:index:#Agent.y
        Set y:__val0
        Set y+1:__val1

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

        Call Agent.SetField:index:#Agent.dx:dx
        Call Agent.SetField:index:#Agent.dy:dy
        Call Agent.SetField:index:#Agent.x:x:x+1
        Call Agent.SetFieldW:index:#Agent.y:y:y+1

        rts
        dHi: .byte 0
        dy: .byte 0
        dx: .byte 0
        y: .word 0
        x: .word 0
    }
}
