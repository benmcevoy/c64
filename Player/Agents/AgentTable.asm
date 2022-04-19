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
        x: .word $1400
        y: .word $0200
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word PlayerBehaviors.Update 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 93 // vertical bar
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 81
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0
        CurrentState: .word PlayerBehaviors.Idle
    }

    Agent2:{
        destroyed: .byte 0
        x: .word $0a00
        y: .word $0200
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.ColorCycle 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 81 // .
        color: .byte GREEN
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation

    }
  
}
