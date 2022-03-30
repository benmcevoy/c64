BasicUpstart2(Start)

#import "_prelude.lib"
#import "_charscreen.lib"

Start: {
    .var time = __tmp0
    .var y = __tmp1
    .var delayCount = __tmp2
    .const DELAY = $40

    Set $d020:#0
    Set $d021:#0
    Set time:#0
    Set delayCount:#0

    // init sid noise for random
    lda #$10 // maximum frequency value
    sta $D40E // voice 3 frequency low byte
    lda #$01
    sta $D40F // voice 3 frequency high byte
    lda #16  // triangle
    sta $D412 // voice 3 control register

    loop:

    lda delayCount
    cmp #DELAY
    bne !+
        Set delayCount:#0
        inc time
    !:

    // read sid wave out
    lda $d41b
    // cut it down to 0..32 for screen high
    lsr;lsr
    sta y
   
    lda time
    cmp #25
    bne !+
        Set time:#0
        inc CharScreen.PenColor
    !:
    
    Call CharScreen.Plot:y:time
    
    inc delayCount

    jmp loop

    rts
}