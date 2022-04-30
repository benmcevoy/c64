BasicUpstart2(Start)

// consider the idea of a z-index, i'd like to see little thing moving in the background.
// a little dot in the background, bouncing along, reverse direction on collide
// or a bird flying past in the fore ground.  The "swap" logic in render would allow things to go over/under other things
// multi character "sprites"
// animation - (new state, duration), new state of the value being animated, maybe state is the pointer to the four characters that make up a "sprite"
// handle screen edges so we do not need the box around the screen for collisions, give us back 2 cols and 2 rows of screen
#import "globals.asm"
#import "_prelude.lib"
#import "_charscreen.lib"
#import "./Agents/Agent.asm"
#import "./Backgrounds/weave.asm"
//#import "./Backgrounds/honeycomb.asm"
//#import "./Backgrounds/colours.asm"
//#import "./Backgrounds/jungle.asm"
//#import "./Backgrounds/clouds.asm"

.var music = LoadSid("A_Mind_Is_Born.sid")	

.const DELAY = 20;
_delay: .byte DELAY
_delay1: .byte 0
_semaphore: .byte 0

Start: {
    jsr Kernal.ClearScreen
    jsr music.init	

    Call Background.Draw
    Call DrawGameField
  
    // Raster IRQ
    sei
        lda #<Render            
        sta $0314
        lda #>Render
        sta $0315

        // clear high bit of raster flag
        lda    #$1b
        sta    $d011
        // enable raster irq
        lda    #$01
        sta    $d01a
        // disable cia timers
        lda    #$7f
        sta    $dc0d
        sta    $dc0c
        lda    $dc0d
        lda    $dc0c
    cli

    loop:
        lda _semaphore
        bne RenderRequested
            dec _delay
            bne !++
                Set _delay:#DELAY
                dec _delay1
                bne !+
                    Set _delay1:#DELAY
                    jsr UpdateAgents
                !:
            !:
            jmp loop

        RenderRequested:
            //inc $d020
            jsr music.play
            jsr RenderAgents
            Set _semaphore:#0
            //dec $d020

    jmp loop
}

Render: {
    // ack irq
    lda    #$01
    sta    $d019
    // set next irq line number
    lda    #100
    sta    $d012

    lda _semaphore
    bne !skip+
        // request render
        Set _semaphore:#1
    !skip:

    // end irq
    pla;tay;pla;tax;pla
    rti 
}

DrawGameField: {
    Set CharScreen.Character:#GROUND_CHAR
    Set CharScreen.PenColor:#GROUND_COLOR    
    Call CharScreen.PlotRect:#0:#0:#39:#24

    Call CharScreen.PlotLine:#30:#20:#38:#20
    Call CharScreen.PlotLine:#20:#16:#30:#16
    Call CharScreen.PlotLine:#15:#12:#22:#12
    Call CharScreen.PlotLine:#24:#8:#26:#8
    Call CharScreen.PlotLine:#15:#12:#22:#12
    Call CharScreen.PlotLine:#32:#16:#38:#12
    Call CharScreen.PlotLine:#20:#23:#14:#18
    Call CharScreen.PlotLine:#22:#8:#22:#16
    Call CharScreen.PlotLine:#1:#20:#10:#20
    Call CharScreen.PlotLine:#1:#16:#10:#16

    rts
}

UpdateAgents: {
    lda #MAXAGENTS
    sta index

    loop:
        dec index
        bpl !+
            jmp exit
        !:
    
        AgentSetCurrent(index)
        AgentIsDestroyed()
        bcs loop

        AgentInvoke(Agent.Update)
        jmp loop

    exit:    
    rts

    index: .byte 0
}

RenderAgents: {
    lda #MAXAGENTS
    sta index

    loop:
        dec index
        bpl !+
            jmp exit
        !:

        AgentSetCurrent(index)
        AgentIsDestroyed()
        bcs loop
        
        AgentInvoke(Agent.Render)
        jmp loop

    exit:    
    rts

    index: .byte 0
}


//---------------------------------------------------------
			*=music.location "Music"
			.fill music.size, music.getData(i)	