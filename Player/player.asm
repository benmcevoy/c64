BasicUpstart2(Start)

// extract player out to an "Agent" struct, with OnUpdate, OnRender, then allow multiple for "enemies" and other things.
// consider the idea of a z-index, i'd like to see little thing moving in the background.
// a little dot in the background, bouncing along, reverse direction on collide
// or a bird flying past in the fore ground.  The "swap" logic in render would allow things to go over/under other things
// push render to a raster irq?
// push update to some other raster line irq?
// multi character "sprites"
// animation - (new state, duration), new state of the value being animated, maybe state is the pointer to the four characters that make up a "sprite"
// handle screen edges so we do not need the box around the screen for collisions, give us back 2 cols and 2 rows of screen

#import "_prelude.lib"
#import "_charscreen.lib"
#import "_debug.lib"
#import "globals.asm"
#import "./Agents/Agent.asm"

#import "./Backgrounds/weave.asm"
//#import "./Backgrounds/honeycomb.asm"
//#import "./Backgrounds/city.asm"
//#import "./Backgrounds/jungle.asm"
//#import "./Backgrounds/clouds.asm"


Start: {
    // KERNAL clear screen
    jsr $E544

    Call Background.Draw
    Call DrawGameField
  
    // set IRQ for GameUpdate, CIA timer
    sei
        lda #<GameUpdate            
        sta $0314
        lda #>GameUpdate
        sta $0315
    cli

    // infinite loop
    jmp *
}

GameUpdate: {
    inc delayCounter
    lda delayCounter
    cmp #DELAY
    bne !+
        Set delayCounter:#0

        //Call ReadJoystick
        Set $d020:#WHITE
        Call UpdateAgents
        Set $d020:#WHITE
        Call CollisionAgents
        Set $d020:#GREEN
        Call RenderAgents
    !:

    // - set border color change for some perf indicator, needs IRQ to be raster one
    Set $d020:#BLACK

    // end irq
    pla;tay;pla;tax;pla
    rti 
}

DrawGameField: {
    Set CharScreen.Character:#GROUND_CHAR
    Set CharScreen.PenColor:#GROUND_COLOR    
    Call CharScreen.PlotRect:#0:#0:#39:#24
    //Call CharScreen.PlotLine:#0:#24:#39:#24

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

// ReadJoystick: {

//     read_joystick:
//         // left
//         lda #JOYSTICK_LEFT
//         bit PORT2
//         bne !skip+
//             lda #ACTION_IS_JUMPING
//             bit playerAction
//             beq !+
//                 Set dx:#-SPEED/2
//                 jmp !skip+
//             !:
//                 Set dx:#-SPEED
//         !skip: 
            
//         // right
//         lda #JOYSTICK_RIGHT
//         bit PORT2
//         bne !skip+
//             lda #ACTION_IS_JUMPING
//             bit playerAction
//             beq !+
//                 Set dx:#SPEED/2
//                 jmp !skip+
//             !:
//                 Set dx:#SPEED
//         !skip: 

//         // up
//         // down

//         // fire
//         lda #ACTION_IS_JUMPING
//         bit playerAction
//         // no double jumping
//         bne !skip+
//             lda #JOYSTICK_FIRE
//             bit PORT2
//             bne !skip+
//                 Set dy:#IMPULSE
//                 SetBit playerAction:#ACTION_IS_JUMPING
//         !skip:
//     rts
// }

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
 
    Call Agent.IsDestroyed:index
    lda __val0
    cmp #0
    bne loop

    Call Agent.Invoke:index:#Agent.Update

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

    Call Agent.IsDestroyed:index
    lda __val0
    cmp #0 
    bne loop
    
    Call Agent.Invoke:index:#Agent.Render
    jmp loop

    exit:    
    rts

    index: .byte 0
}

CollisionAgents: {
    lda #MAXAGENTS
    sta index

    loop:
    dec index
    
    lda index
    cmp #0
    bpl !+
        jmp exit
    !:

    Call Agent.IsDestroyed:index
    lda __val0
    cmp #0 
    bne loop
    
    Call Agent.Invoke:index:#Agent.Collision
    jmp loop

    exit:    
    rts

    index: .byte 0
}