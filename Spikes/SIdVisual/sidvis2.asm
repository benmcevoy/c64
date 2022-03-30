BasicUpstart2(Start)

#import "_prelude.lib"
#import "_charscreen.lib"

Start: {

    .var y = __tmp1
    .var x = __tmp2
    .var delay = __tmp0

    Set $d020:#0
    Set $d021:#0

    // this just sets voice3 osciallting a triangle wave at $0110 freq whatever that is
    // there might be interesting behaviour in here
    // you can also read the voice 3 ADSR register
    // and i think you can feed the other voices in? I can't recall...
    // could be a very efficient way to do some effects, like screen wipes
    // or generally as a function to generate sine waves (shit ones)

    // init sid noise for random
    lda #$10 // maximum frequency value
    sta $D40E // voice 3 frequency low byte
    lda #$01
    sta $D40F // voice 3 frequency high byte
    lda #16  // triangle
    sta $D412 // voice 3 control register

    loop:

    // this is a very crappy sine triangle wave
    // read sid wave out
    lda $d41b
    // cut it down to 0..32 for screen high
    lsr;lsr;lsr
    sta x
    
    // delay and read again for a phase offset, e.g. cosine
    !: dec delay
    bne !-
    !: dec delay
    bne !-
    !: dec delay
    bne !-
    !: dec delay
    bne !-
    !: dec delay
    bne !-    
    
    lda $d41b
    lsr;lsr;lsr;
    sta y
    
    // and we get a very crappy circle
    Call CharScreen.Plot:x:y
    inc CharScreen.PenColor

    jmp loop

    rts
}