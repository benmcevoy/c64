BasicUpstart2(Start)

#import "_prelude.lib"
#import "_debug.lib"

// declare the layout in bytes
.namespace Agent {
    .label x = 0
    .label y = 1 
    .label z = 2
    .label dx = 3 
    .label dy = 4 
    .label destroyed = 5 
    .label Update = 6  
    .label Render = 8
    .label Glyph = 9
    .label Color = 10

    .label Length = 11

    __getObjectPtr: {
        .var index = __arg0

        Set __val0:#<Agents
        Set __val1:#>Agents

        // calculate object pointer
        lda index
        asl // *2
        clc
        adc __val0
        sta __val0
        lda __val1
        // add the carry for page boundary
        adc #0
        sta __val1

        rts
    }

    _getFieldPtr: {
        .var field = __arg0

        .var objectPtr = __ptr0
        .var fieldPtr = __ptr1

        // calculate field pointer - objectPtr + field offset
        ldy #0
        lda (objectPtr),y
        clc
        adc field
        sta __val0
        iny
        lda (objectPtr),y
        // add the carry for page boundary
        adc #0
        sta __val1
       
        rts
    }

    _getMethodPtr: {
        .var method = __arg0

        .var objectPtr = __ptr0
        .var fieldPtr = __ptr1

        Call _getFieldPtr:method
        Set fieldPtr:__val0
        Set fieldPtr+1:__val1

        // extract method pointer actual address
        ldy #0
        lda (fieldPtr),y
        sta __val0
        iny
        lda (fieldPtr),y
        sta __val1

        rts
    }

    GetField: {
        .var index = __arg0
        .var field = __arg1

        .var objectPtr = __ptr0
        .var fieldPtr = __ptr1
        
        Call __getObjectPtr:index
        Set objectPtr:__val0
        Set objectPtr+1:__val1

        Call _getFieldPtr:field
        Set fieldPtr:__val0
        Set fieldPtr+1:__val1

        // extract field actual value
        ldy #0
        lda (fieldPtr),y
        sta __val0

        DebugPrint #<Agents
        DebugPrint #>Agents
        DebugPrint objectPtr
        DebugPrint objectPtr+1

        TODO: fieldPtr is 0000
        can the agenttable be zp?
        dispatch table and double dispatch
        how does an "object" do it?

        DebugPrint fieldPtr
        DebugPrint fieldPtr+1

        rts
    }

    SetField: {
        .var index = __arg0
        .var field = __arg1
        .var value = __arg2

        .var objectPtr = __ptr0
        .var fieldPtr = __ptr1
        
        Call __getObjectPtr:index
        Set objectPtr:__val0
        Set objectPtr+1:__val1

        Call _getFieldPtr:field
        Set fieldPtr:__val0
        Set fieldPtr+1:__val1

        ldy #0
        lda value
        sta (fieldPtr),y

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
    .var index = 1
    
    Call Agent.Invoke:#index:#Agent.Update
    Call Agent.Invoke:#index:#Agent.Render

    rts
}

UpdateImpl: {
    .var index = __arg0

    Call Agent.SetField:#index:#Agent.x:#80
    
    rts
}

UpdateImpl2: {
    .var index = __arg0

    Call Agent.SetField:#index:#Agent.x:#81

    rts
}

RenderImpl: {
    .var index = __arg0
    
    Call Agent.GetField:#index:#Agent.x

    sta $0400
    rts
}



// pool of pointers to agents
.label AgentTable = $c0fa
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
    x: .byte 0
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