#importonce
#import "_prelude.lib"
#import "_debug.lib"
#import "AgentBehaviors.asm"
#import "PlayerBehaviors.asm"

.const MAXAGENTS = 2

// declare the layout in bytes
.namespace Agent {
    /* this is like a header file */
    /* offset in bytes, order is important */
    .label destroyed = 0
    .label x = 1 // word
    .label y = 3 // word
    .label z = 5
    .label dx = 6 
    .label dy = 7 
    .label Update = 8 // word  
    .label Render = 10 // word
    .label glyph = 12
    .label color = 13
    .label x0 = 14 // word
    .label y0 = 16 // word
    .label glyph0 = 18
    .label color0 = 19
    
    .label Length = 20

    // PICO-8 uses "flags" to associate behaviours, e.g. a tile or char with flag0 set is "collidable", a tile with flag1 set is a health buff, etc.
    // consider if we could use the top nibble of colour ram to store flags per character tile?  Thought about WALL, ANIM0, ANIM1, ANIM2 or WALL, BOUNCY, SLOW, ???
    // ideally flags should be additive so you can combine flags to get rich behaviour, like a bouncy wall or floor

    .var __objectPtr = __ptr3

    Invoke: {
        .var field = __arg0
        
        .var __methodPtr = __ptr1
 
        Call GetField:field
        
        Set __methodPtr:__val0
        Set __methodPtr+1:__val1

        Call (__methodPtr)

        rts
    }

    /* MUST call GetObjectPtr first */
    GetField: {
        .var field = __arg0

        ldy field
        lda (__objectPtr),Y
        sta __val0
        iny
        lda (__objectPtr),Y
        sta __val1

        rts
    }
    
    /* MUST call GetObjectPtr first */
    SetField: {
        .var field = __arg0
        .var value = __arg1
        
        ldy field
        lda value
        sta (__objectPtr),Y

        rts
    }

    /* MUST call GetObjectPtr first */
    SetFieldW: {
        .var field = __arg0
        .var valueLo = __arg1
        .var valueHi = __arg2
       
        ldy field
        lda valueLo
        sta (__objectPtr),Y
        iny
        lda valueHi
        sta (__objectPtr),Y

        rts
    }

    SetCurrentObject: {
        .var index = __arg0

        // calculate object pointer, offset by index*2 (2 bytes)
        lda index
        asl // *2
        tax
        
        lda __agents,x
        sta __objectPtr
        inx
        lda __agents,x
        sta __objectPtr+1

        rts
    }

    // pool of pointers to agents
    .label __agentTable = $c000
    // list of pointers to the agent table
    __agents: .for(var i = 0; i < MAXAGENTS; i++) .word __agentTable + (Agent.Length * i)
    // reserve memory
    *=__agentTable "Agent data"
    Player:{
        destroyed: .byte 0
        x: .word 20
        y: .word 2
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word PlayerBehaviors.PlayerUpdate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 81 // ball
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        glyph0: .byte 32
        color0: .byte 0
        
    }
    NPC1:{
        destroyed: .byte 0
        x: .word 10
        y: .word 2
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.NoOperation 
        Render: .word AgentBehaviors.SimpleRender 
        glyph: .byte 81 // ball
        color: .byte GREEN
        x0: .word 0
        y0: .word 0
        glyph0: .byte 32
        color0: .byte 0
        
    }
}
