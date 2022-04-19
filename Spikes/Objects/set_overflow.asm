BasicUpstart2(Start)

#import "_prelude.lib"

Start: {

    // Set __tmp0:#$AB

    // lda #%00100000
    // bit __tmp0

    Set __overflowSet:#$60

    sev // or clv
    bvs overflowSet
    bvc overflowClear
    rts

    overflowSet:
        DebugPrint #01
        rts

    overflowClear:
        DebugPrint #00
        rts

}