#importonce
#import "Agent.asm"
#import "AgentBehaviors.asm"
#import "PlayerBehaviors.asm"

.const MAXAGENTS = 5

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
        y: .word $0600
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word PlayerBehaviors.Update 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 5 
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 81
        bgColor: .byte BLACK
        bgX: .byte 0
        bgY: .byte 0
        CurrentState: .word PlayerBehaviors.Idle
        data: .byte 0
    }

   Agent1:{
        destroyed: .byte 0
        x: .word $0400
        y: .word $0500
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 54 
        color: .byte YELLOW
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 81
        bgColor: .byte BLACK
        bgX: .byte 0
        bgY: .byte 0
        CurrentState: .word PlayerBehaviors.Idle
        data: .byte 0
    }

   Agent2:{
        destroyed: .byte 0
        x: .word $0a00
        y: .word $0d00
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 54 
        color: .byte YELLOW
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 81
        bgColor: .byte BLACK
        bgX: .byte 0
        bgY: .byte 0
        CurrentState: .word PlayerBehaviors.Idle
        data: .byte 0
    }

   Agent3:{
        destroyed: .byte 0
        x: .word $1900
        y: .word $0700
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 54 
        color: .byte YELLOW
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 81
        bgColor: .byte BLACK
        bgX: .byte 0
        bgY: .byte 0
        CurrentState: .word PlayerBehaviors.Idle
        data: .byte 0
    }  

    Agent4:{
        destroyed: .byte 0
        x: .word $1400
        y: .word $0800
        z: .byte 0
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 54 
        color: .byte YELLOW
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 81
        bgColor: .byte BLACK
        bgX: .byte 0
        bgY: .byte 0
        CurrentState: .word PlayerBehaviors.Idle
        data: .byte 0
    }        
  
}
