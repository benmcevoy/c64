#importonce
#import "_prelude.lib"

BasicUpstart2(Start)

.const SID_BASE = $D400
.const SID_V1_FREQ_LO = (SID_BASE + 0)
.const SID_V1_FREQ_HI = (SID_BASE + 1)
.const SID_V1_PW_LO = SID_BASE + 2
.const SID_V1_PW_HI = SID_BASE + 3
.const SID_V1_ATTACK_DECAY = SID_BASE + 5
.const SID_V1_SUSTAIN_RELEASE = SID_BASE + 6
/* MSB Noise, Square, Saw, Triangle, Disable/Reset, Ring, Sync, Trigger LSB  */
.const SID_V1_CONTROL = SID_BASE + 4

/* Low bits 0-2 only */
.const SID_MIX_FILTER_CUT_OFF_LO = SID_BASE + 21 + 0
.const SID_MIX_FILTER_CUT_OFF_HI = SID_BASE + 21 + 1
/* MSB Resonance3, Resonance2, Resonance1, Resonance0, Ext voice filtered, v3 filter, v2 filter, v1 filter LSB */
.const SID_MIX_FILTER_CONTROL = SID_BASE + 21 + 2
/* MSB v3 disable, High pass filter, band pass filter, low pass filter, volume3, volume2, volume1, volume0 LSB */
.const SID_MIX_VOLUME = SID_BASE + 21 + 3

Start: {

    // init SID
    Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
    Set SID_MIX_FILTER_CUT_OFF_HI:#10
    Set SID_MIX_FILTER_CONTROL:#%11110111
    Set SID_MIX_VOLUME:#%00011111

    Set SID_V1_ATTACK_DECAY:#$00

    Set SID_V1_FREQ_HI:#$03
    Set SID_V1_FREQ_LO:#$E0

// Raster IRQ
    sei
        // disable cia timers
        lda    #$7f
        sta    $dc0d
        
        // enable raster irq
        lda $d01a                     
        ora #$01
        sta $d01a
        lda $d011                    
        and #$7f
        sta $d011

        // set next irq line number
        lda    #1
        sta    $d012
        
        lda #<OnRasterInterrupt            
        sta $0314
        lda #>OnRasterInterrupt
        sta $0315
    cli


    jmp *
}

frameCounter: .byte 32

OnRasterInterrupt: {
    // ack irq
    lda $d019
    sta $d019
    // set next irq line number
    lda    #1
    sta    $d012

    dec frameCounter
    ldx frameCounter
    cpx #$ff
    bne!+
        Set frameCounter:#32
    !:

    Echo(14, $9)

    // end irq
    pla;tay;pla;tax;pla
    rti  
}

.macro Echo(period, release){
    .var repeat = 4
    .var volume = $f

        cpx #32
        bne !+
            Set SID_V1_SUSTAIN_RELEASE:#(volume<<4)+release
            Set SID_V1_CONTROL:#%01101001
        !:

        cpx #30
        bne !+
            Set SID_V1_CONTROL:#%01100000
        !:
.eval volume = volume>>1

        cpx #22
        bne !+
            Set SID_V1_SUSTAIN_RELEASE:#(volume<<4)+release
            Set SID_V1_CONTROL:#%01101001
        !:

        cpx #20
        bne !+
            Set SID_V1_CONTROL:#%01100000
        !:
.eval volume = volume>>1
         cpx #12
        bne !+
            Set SID_V1_SUSTAIN_RELEASE:#(volume<<4)+release
            Set SID_V1_CONTROL:#%01101001
        !:

        cpx #10
        bne !+
            Set SID_V1_CONTROL:#%01100000
        !:

        cpx #2
    bne !+
        Set SID_V1_CONTROL:#%00100000
    !:

}

.macro EchoUsingInc(period, release){
    .var repeat = 4
    .var volume = $f

    .for(var i=0; i<repeat; i++) {
        cpx #period*(i+1)
        bne !+
            Set SID_V1_SUSTAIN_RELEASE:#(volume<<4)+release
            Set SID_V1_CONTROL:#%01101001
        !:

        cpx #period*(i+1)+2
        bne !+
            Set SID_V1_CONTROL:#%01100000
        !:

        .eval volume = volume>>1
    }

    cpx #period*(repeat+1)
    bne !+
        Set SID_V1_CONTROL:#%00100000
    !:
}

