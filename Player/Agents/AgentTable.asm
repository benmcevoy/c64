#importonce
#import "Agent.asm"
#import "AgentBehaviors.asm"
#import "PlayerBehaviors.asm"

.const MAXAGENTS = 2

.namespace Agent {

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
        Update: .word PlayerBehaviors.Update 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 81 // ball
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte 0
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
        bgGlyph: .byte 32
        bgColor: .byte 0
    }
}
