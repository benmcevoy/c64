#importonce
#import "Agent.asm"
#import "AgentBehaviors.asm"
#import "PlayerBehaviors.asm"

.const MAXAGENTS = 9

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
        data: .byte 0
    }

    Bg1:{
        destroyed: .byte 0
        x: .word $0a00
        y: .word $0700
        z: .byte 12
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 73 // .
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation
        data: .byte 0
    }
    Bg2:{
        destroyed: .byte 0
        x: .word $0900
        y: .word $0800
        z: .byte 3
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 85 // .
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation
        data: .byte 1
    }
    Bg3:{
        destroyed: .byte 0
        x: .word $0b00
        y: .word $0800
        z: .byte 9
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 75 // .
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation
        data: .byte 2
    }
    Bg4:{
        destroyed: .byte 0
        x: .word $0a00
        y: .word $0900
        z: .byte 6
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 74 // .
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation
        data: .byte 3
    }

     Bg5:{
        destroyed: .byte 0
        x: .word $0e00
        y: .word $0700
        z: .byte 6
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 73 // .
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation
        data: .byte 0
    }
    Bg6:{
        destroyed: .byte 0
        x: .word $0d00
        y: .word $0800
        z: .byte 9
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 85 // .
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation
        data: .byte 1
    }
    Bg7:{
        destroyed: .byte 0
        x: .word $0f00
        y: .word $0800
        z: .byte 3
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 75 // .
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation
        data: .byte 2
    }
    Bg8:{
        destroyed: .byte 0
        x: .word $0e00
        y: .word $0900
        z: .byte 12
        dx: .byte 0
        dy: .byte 0
        Update: .word AgentBehaviors.Animate 
        Render: .word AgentBehaviors.DefaultRender 
        glyph: .byte 74 // .
        color: .byte WHITE
        x0: .word 0
        y0: .word 0
        bgGlyph: .byte 32
        bgColor: .byte GRAY
        bgX: .byte 0
        bgY: .byte 0        
        CurrentState: .word AgentBehaviors.NoOperation
        data: .byte 3
    }
  
}
