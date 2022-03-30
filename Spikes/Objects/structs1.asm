BasicUpstart2(Start)

#import "_prelude.lib"

// declare the layout in bytes
.namespace AgentFields {
    .label x = 0
    .label y = 1 
    .label z = 2
    .label dx = 3 
    .label dy = 4 
    .label destroyed = 5 
    .label Update = 6  
    .label Render = 8

    .label Length = 10
}


// pool of pointers to agents
.label AgentTable = $c0fa
Agents: .word  AgentTable+(AgentFields.Length*0),AgentTable+(AgentFields.Length*1),AgentTable+(AgentFields.Length*2)  // 3ptrs?

*=AgentTable+(AgentFields.Length*0) 
Agent0:{
    x: .byte 0
    y: .byte 0
    z: .byte 0
    dx: .byte 0
    dy: .byte 0
    destroyed: .byte 1
    Update: .word UpdateImpl // should be to resuable methods and not in this struct
    // e.g. Update: .word Game.Player.Update , or NPC.Worm.Update, Enemy.Bot.Update
    // must be a template
    Render: .word RenderImpl
}

*=AgentTable+(AgentFields.Length*1) 
Agent1:{
 x: .byte 0
    y: .byte 0
    z: .byte 0
    dx: .byte 0
    dy: .byte 0
    destroyed: .byte 1
    Update: .word UpdateImpl2 // should be to resuable methods and not in this struct
    // e.g. Update: .word Game.Player.Update , or NPC.Worm.Update, Enemy.Bot.Update
    // must be a template
    Render: .word RenderImpl
}

*=AgentTable+(AgentFields.Length*2) 
Agent2:{
     x: .byte 0
    y: .byte 0
    z: .byte 0
    dx: .byte 0
    dy: .byte 0
    destroyed: .byte 1
    Update: .word UpdateImpl // should be to resuable methods and not in this struct
    // e.g. Update: .word Game.Player.Update , or NPC.Worm.Update, Enemy.Bot.Update
    // must be a template
    Render: .word RenderImpl
}

InvokeMethod: {
    .var index = __arg0
    .var method = __arg1

    .var temp = __ptr0
    .var action = __ptr1
    .var object = Agents+index *2


    rts
}

Start: {

    .var temp = __ptr0
    .var action = __ptr1

    // get agent pointer by index
    .var index =0
    .var object = Agents+index *2
    

    // lda agent ptr low byte
    lda object
    // offset for update method
    clc
    adc #AgentFields.Update
    sta temp

    // lda agent ptr high byte
    lda object+1
    // add the carry for page boundary
    adc #0 
    sta temp+1

    ldy #0
    lda (temp),y
    sta action
    iny
    lda (temp),y
    sta action+1

    Call (action)

    // lda agent ptr low byte
    lda object
    // offset for method
    clc
    adc #AgentFields.Render
    sta __ptr0

    // lda agent ptr high byte
    lda object+1
    adc #0 // add the carry for page boundary
    sta __ptr0+1

    ldy #0
    lda (__ptr0),y
    sta action
    iny
    lda (__ptr0),y
    sta action+1

    Call (action)

    rts
}


    UpdateImpl: {

        lda #81
        sta Agent0.x
        rts
    }

    UpdateImpl2: {

        lda #80
        sta Agent0.x
        rts
    }

    RenderImpl: {

        lda Agent0.x
        sta $0400
        rts
    }