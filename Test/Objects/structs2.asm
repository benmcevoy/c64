BasicUpstart2(Start)

#import "_prelude.lib"

// declare the layout in bytes
.namespace Agent {
    /* this is ;ile a header file */
    /* offset in bytes, order is important */
    .label x = 0
    .label y = 1 
    .label z = 2
    .label dx = 3 
    .label dy = 4 
    // TODO: might pay to make this the first field as we would check it alot, i dunno
    .label destroyed = 5 
    .label Update = 6  
    .label Render = 8
    .label Glyph = 10
    .label Color = 11

    .label Length = 12

    .var __objectPtr = __ptr0
    .var __fieldPtr = __ptr1

    // TODO: be nice to make these funciton generic or agnostic to the struct layout, would need to know the
    // table pointer, preferably as zp 
    __getObjectPtr: {
        .var index = __arg0

        Set __objectPtr:#<Agents
        Set __objectPtr+1:#>Agents

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
        
        rts
    }

    _getFieldPtr: {
        .var field = __arg0

        // calculate field pointer - objectPtr + field offset
        lda __objectPtr
        clc
        adc field
        sta __val0
        lda __objectPtr+1
        // add the carry for page boundary
        adc #0
        sta __val1
       
        rts
    }

    _getMethodPtr: {
        .var method = __arg0

        Call _getFieldPtr:method
        Set __fieldPtr:__val0
        Set __fieldPtr+1:__val1

        // extract method pointer actual address
        ldy #0
        lda (__fieldPtr),y
        sta __val0
        iny
        lda (__fieldPtr),y
        sta __val1

        rts
    }

    GetField: {
        .var index = __arg0
        .var field = __arg1

        Call __getObjectPtr:index
        Set __objectPtr:__val0
        Set __objectPtr+1:__val1

        Call _getFieldPtr:field
        Set __fieldPtr:__val0
        Set __fieldPtr+1:__val1

        // extract field actual value
        ldy #0
        lda (__fieldPtr),y
        sta __val0

        rts
    }

    SetField: {
        .var index = __arg0
        .var field = __arg1
        .var value = __arg2
       
        Call __getObjectPtr:index
        Set __objectPtr:__val0
        Set __objectPtr+1:__val1

        Call _getFieldPtr:field
        Set __fieldPtr:__val0
        Set __fieldPtr+1:__val1

        ldy #0
        lda value
        sta (__fieldPtr),y

        rts
    }

    Invoke: {
        .var index = __arg0
        .var method = __arg1

        .var objectPtr = __ptr0
        .var methodPtr = __ptr1
        
        Call __getObjectPtr:index
        Set objectPtr:__val0
        Set objectPtr+1:__val1

        Call _getMethodPtr:method
        Set methodPtr:__val0
        Set methodPtr+1:__val1

        Call (methodPtr):index

        rts
    }
}

Start: {
    .var id = 2
    
    Call Agent.Invoke:#id:#Agent.Update
    Call Agent.Invoke:#id:#Agent.Render

    rts
}

UpdateImpl: {
    .var index = __arg0

    Call Agent.SetField:index:#Agent.x:#80

    rts
}

UpdateImpl2: {
    .var index = __arg0

    Call Agent.SetField:index:#Agent.x:#81

    rts
}

RenderImpl: {
    .var index = __arg0
    
    Call Agent.GetField:index:#Agent.x
    lda __val0

    sta $0400
    rts
}



// pool of pointers to agents
.label AgentTable = $c0fa
// Agents should be in ZP to make things faster/easier
// TODO: i need some memory mangement, to free up ZP and kill BASIC, tape drive, and unused stuff.
Agents: .word  AgentTable+(Agent.Length*0),AgentTable+(Agent.Length*1),AgentTable+(Agent.Length*2)  // 3ptrs?

*=AgentTable+(Agent.Length*0) "Agent data"
Agent0:{
    x: .byte 0
    y: .byte 0
    z: .byte 0
    dx: .byte 0
    dy: .byte 0
    destroyed: .byte 1
    Update: .word UpdateImpl 
    Render: .word RenderImpl
    glyph: .byte 0
    color: .byte 0
}

Agent1:{
    x: .byte $42
    y: .byte 0
    z: .byte 0
    dx: .byte 0
    dy: .byte 0
    destroyed: .byte 1
    Update: .word UpdateImpl2
    Render: .word RenderImpl
    glyph: .byte 0
    color: .byte 0
}

Agent2:{
    x: .byte 0
    y: .byte 0
    z: .byte 0
    dx: .byte 0
    dy: .byte 0
    destroyed: .byte 1
    Update: .word UpdateImpl 
    Render: .word RenderImpl
    glyph: .byte 0
    color: .byte 0
}

// could also just add  .fill Agent.Length*number_of_agents_i_want_in_the_pool 0