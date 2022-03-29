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

Start: {
    jsr Kernal.ClearScreen

    Call Background.Draw
    Call DrawGameField
  
    // Raster IRQ
    sei
        lda #<GameUpdate            
        sta $0314
        lda #>GameUpdate
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
        // TODO: I should be able to move the Update and Collision
        // code here and just render on the IRQ
        // when I try that it looks like my pointers get clobbered, which is expected
        // need more ZP space and setup a pointer per method, hello globals :)

        // a lot of the work could be scheduled, e.g. readjoystick only needs to happen like every 2ms or less
        // you can create a budget over the raster lines, e.g. allocate 20% to render, 1% for inputs, etc
        // or maybe a scheduler runs first, tracking timeout till next piece of work
        // and allocates the scan lines accordingly.  sounds complicated.

        // for scheduling, the "simple" approach i just thought of
        // is to have a flag that toggles the next piece of work between Update/Render
        // so each subroutine gets a full frame each
        // raster IRQ is 50Hz for PAL, so you are getting 25fps which is OK
        // this coould be extended to interleave things, e.g. Render every 2nd frame, but the odd frames can be distributed amongst other things?
        // might do a little reading on scheduling in an OS.
        // consider
        //  - priority
        //  - frequency
        //  - rentrancy or concurrency - CLOBBERING, lol. each worker needs it's own state
        //      is there reentrancy?  on an IRQ the current PC is pushed to the stack, then RTI lets it resume

        // schedule
        // update
        // render
        // cleanup

        // the version player9 has a nice feel, i think because it updates on the cia timer instead, seems like it is updating more than 50 fps
        // also the jump speed is half

    // infinite loop
    jmp loop
}

GameUpdate: {
    
    // ack irq
    lda    #$01
    sta    $d019
    // set next irq line number
    lda    #00
    sta    $d012

    // - set border color change for some perf indicator
    Set $d020:#WHITE
    Call UpdateAgents
         
    Set $d020:#GREEN
    Call RenderAgents
    
    // - set border color change for some perf indicator
    Set $d020:#BLACK

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
    
        lda index
        cmp #0
        bpl !+
            jmp exit
        !:
    
        Call Agent.SetCurrentObject:index
        Call Agent.IsDestroyed
        lda __val0
        cmp #0
        bne loop

        Call Agent.Invoke:#Agent.Update

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
        
        lda index
        cmp #0
        bpl !+
            jmp exit
        !:

        Call Agent.SetCurrentObject:index
        Call Agent.IsDestroyed
        lda __val0
        cmp #0 
        bne loop
        
        Call Agent.Invoke:#Agent.Render
        jmp loop

    exit:    
    rts

    index: .byte 0
}