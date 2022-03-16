#importonce
#import "_prelude.lib"
#import "_debug.lib"
#import "AgentBehaviours.asm"

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
    .label Collision = 20 // word

    .label Length = 22

    .var __objectPtr = __ptr0
    .var __fieldPtr = __ptr1

// TODO:
// - consider indexing into struct, e.g. (ffff),x or what addressing mode is appropriate  absolute indexed, e.g. $ffff,X
// - consider meta programming - can i alter the code as it is running and avoid a few lda/sta's, perhaps to set 16 bit values for lda/sta, 
// might rework this api, to operate on object pointers and not fetch them every time
// but first make it work (again)




    IsDestroyed: {
        .var index = __arg0

        Call GetObjectPtr:index
        Set __objectPtr:__val0
        Set __objectPtr+1:__val1

        // rely on the fact that destroyed is the 0th field
        // the object pointer points straight at it
        ldy #0
        lda (__objectPtr),y
        sta __val0

        rts
    }

    GetField: {
        .var index = __arg0
        .var field = __arg1

        Call GetFieldPtr:index:field
  
        // extract field actual value
        ldy #0
        lda (__fieldPtr),Y
        sta __val0
        // __val1 might be rubbish
        iny
        lda (__fieldPtr),Y
        sta __val1

        rts
    }

    SetField: {
        .var index = __arg0
        .var field = __arg1
        .var value = __arg2
       
        Call GetFieldPtr:index:field

        ldy #0
        lda value
        sta (__fieldPtr),y

        rts
    }

    SetFieldW: {
        .var index = __arg0
        .var field = __arg1
        .var valueLo = __arg2
        .var valueHi = __arg3
       
        Call GetFieldPtr:index:field

        ldy #0
        lda valueLo
        sta (__fieldPtr),y
        iny 
        lda valueHi
        sta (__fieldPtr),y

        rts
    }

    Invoke: {
        .var index = __arg0
        .var field = __arg1
        
        Call GetField:index:field
        
        Set __fieldPtr:__val0
        Set __fieldPtr+1:__val1

        Call (__fieldPtr):index

        rts
    }

    GetObjectPtr: {
        .var index = __arg0

        Set __objectPtr:#<__agents
        Set __objectPtr+1:#>__agents

        // calculate object pointer, offset by index*2 (2 bytes)
        lda index
        asl // *2
        clc
        adc __objectPtr
        sta __objectPtr
        bcc !+
            inc __objectPtr+1
        !:
        // objectPtr now has the pointer (word from Agents table) to the pointer to the object
        // extract object pointer actual address
        ldy #0
        lda (__objectPtr),y
        sta __val0
        iny
        lda (__objectPtr),y
        sta __val1
        
        Set __objectPtr:__val0
        Set __objectPtr+1:__val1

        rts
    }

    GetFieldPtr: {
        .var index = __arg0
        .var field = __arg1

        Call GetObjectPtr:index

        // calculate field pointer - objectPtr + field offset
        lda __objectPtr
        clc
        adc field
        sta __val0
        sta __fieldPtr
        lda __objectPtr+1
        // add the carry for page boundary
        adc #0
        sta __val1
        sta __fieldPtr+1

        rts
    }

    // pool of pointers to agents
    
    .label __agentTable = $c000
    
    // list of pointers to the agent table
    __agents: .for(var i = 0; i < MAXAGENTS; i++) .word __agentTable + (Agent.Length * i)

    // reserve memory
    *=__agentTable "Agent data"
    Agent0:{
        destroyed: .byte 0
        x: .word 20
        y: .word 2
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviours.DefaultUpdate 
        Render: .word AgentBehaviours.DefaultRender 
        glyph: .byte 81 // ball
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        glyph0: .byte 0
        color0: .byte 0
        Collision: .word AgentBehaviours.DefaultCollision 
    }
    Agent1:{
        destroyed: .byte 1
        x: .word 0
        y: .word 0
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word 0 
        Render: .word 0
        glyph: .byte 0
        color: .byte 0
        x0: .word 0
        y0: .word 0
        glyph0: .byte 0
        color0: .byte 0
        Collision: .word 0
    }
}


