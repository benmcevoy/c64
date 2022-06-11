BasicUpstart2(Start)

#import "_prelude.lib"

  // point to chip
    .const SID_ACTUAL = $D400
    // point to framebuffer
    .const SID        = $D400
    // reserve space for "frame buffer"
    .pseudopc SID { .fill 30,0 }

    .const VOICE1 = 0
    .const VOICE2 = 1*7
    .const VOICE3 = 2*7
    .const MIX = 3*7

    // voice
    .const FREQ_LO = 0
    .const FREQ_HI = 1
    .const PW_LO = 2
    .const PW_HI = 3
    
    /* MSB Noise, Square, Saw, Triangle, Disable/Reset, Ring, Sync, Trigger LSB  */
    .const CONTROL = 4
    
    .const ATTACK_DECAY = 5
    .const SUSTAIN_RELEASE = 6

    // mix
    /* Low bits 0-2 only */
    .const FILTER_CUT_OFF_LO = 0
    .const FILTER_CUT_OFF_HI = 1
    /* MSB Resonance3, Resonance2, Resonance1, Resonance0, Ext voice filtered, v3 filter, v2 filter, v1 filter LSB */
    .const FILTER_CONTROL = 2
    /* MSB v3 disable, High pass filter, band pass filter, low pass filter, volume3, volume2, volume1, volume0 LSB */
    .const VOLUME = 3

    // extras for the voice
    .const TUNE = 25
    .const DURATION = 28

Start: {

    Set $d020:#0
    Set $d021:#0

    // voice one plays a saw, continuously
    Set SID+FREQ_LO:#100
    Set SID+FREQ_HI:#10
    Set SID+ATTACK_DECAY:#11
    Set SID+SUSTAIN_RELEASE:#$A2

    // v3 plays a low freq
    Set SID+VOICE3+FREQ_LO:#10
    Set SID+VOICE3+FREQ_HI:#0
    Set SID+VOICE3+ATTACK_DECAY:#11
    Set SID+VOICE3+SUSTAIN_RELEASE:#$00

    Set SID+VOICE3+PW_LO:#0
    Set SID+VOICE3+PW_HI:#0

    // saw, gate on
    Set SID+CONTROL:#%00100001
    Set SID+VOICE3+CONTROL:#%00010000


    Set SID+MIX+FILTER_CUT_OFF_LO:#%00000111
    Set SID+MIX+FILTER_CUT_OFF_HI:#%00001111
    // try and get some interest with the filter
    Set SID+MIX+FILTER_CONTROL:#%11110100
    // v3 off, max volume, lpf on
    Set SID+MIX+VOLUME:#%10011111

    Ratchet()

    rts
}

// things tried and abandoned
// VCA - you cannot manipulate the sustain level without retriggering and it sounds crap
// Ring - nothing special, it's just ring mod.
// Accent - see VCA.  Instead, set an ADSR, then for each note set a sustain level
//  it will at least sustain at different levels, and maybe rest the sustain to the
//  the instrument default afterwards
// test bit - strobe test bit continously with noise, yeah nah

.macro Ratchet(){
    // and ratcheting
    // https://github.com/RohanM/clock-with-shift/blob/master/clockwithshift.ino

    // i read that code, it's a bit of a fricking mess to be honest
    // ratcheting is beat generation off a master clock (or in that case an external clock)

    // if we have a beat we can easily DIVIDE by counting beats
    // and updating our derived clock every n beats

    // to get more beats per beat, e.g. multiplier then we need a WALL CLOCK (they use the arduino millis())
    // we ain't got no real time clock, but we do have a CIA clock telling us elapsed time since power on
    // in i think 10th of a second increments

    // BUT we run on either a raster clock at 50Hz or a CIA clock at whatever Hz we want....
    // so our external clock or master clock is already smoking fast

    // if we DIVIDE that 50Hz clock down to 120bpm or 2Hz we can now use this new clock as the
    // reference clock and multiply/divide as we like

    // OR... we use the voice 3 amplitude as the external clock and just set the frequency we want
    // and use a square wave with 50% duty


    // v3 freq
    // if you set the frequency too high this skitz out and misses the beat
    // noticeable about f_lo=80 (which is who knows what Hz)
    // a value of f_lo=34 is supposed to be 2Hz on a PAL machine
    // sounds like it when I compare to a metronome
    Set SID+VOICE3+FREQ_LO:#134
    Set SID+VOICE3+FREQ_HI:#0
    // set square wave 50% duty
    Set SID+VOICE3+CONTROL:#%01000000
    // pw is 12 bit, 0-100% or 0-4096
    // so 50% = 2048
    Set SID+VOICE3+PW_HI:#%00001000
    Set SID+VOICE3+PW_LO:#%00000000

    // loop:
    //     // v3 amplitude/waveform output
    //     lda $D41B
    //     // as it square it's either 0 or 1
    //     beq !+ 
    //         // passed the trigger voltage/value
    //         // set v1 on
    //         Set SID+CONTROL:#%00100001
    //         jmp loop
    //     !:
    //     // set v1 off
    //     Set SID+CONTROL:#%00100000

    // jmp loop

    // the above is fine
    // but how to DIVIDE?  let's get some book-keeping, use slow_clock to track the slower beat

    // loop:
    //     // v3 amplitude/waveform output
    //     lda $D41B
    //     // as it square it's either 0 or 1
    //     beq !+ 
    //         // passed the trigger voltage/value
    //         // set v1 on
    //         inc slow_clock
    //     !:
        
    //     // now mask bit 0 as the slow clock beat
    //     lda slow_clock
    //     and #%00000001
    //     beq !+ 
    //         Set slow_clock:#0
    //         Set SID+CONTROL:#%00100001
    //         jmp loop
    //     !:
        
    //     Set SID+CONTROL:#%00100000
    // jmp loop

    // the above does NOT work as we are inc slow_clock A LOT, lol
    // want to track the "edge" or if it's high or low
    // more bookkeeping - clock_hi
    // and more bookkeeping for the edge transitions

    loop:
        Set clock_hi:#0
        // v3 amplitude/waveform output
        lda $D41B
        // as it square it's either 0 or 1
        beq !+ 
            Set clock_hi:#1
        !:
        
        lda clock_hi
        cmp clock_prev
        beq !+
            Set clock_prev:clock_hi
            // i guess i could gate v2 here and have two beats, @120 bpm and at e.g. 60 bpm
            // or speed up the master clock/v3 Hz 
            inc slow_clock
        !:
        
        lda slow_clock
        // by moving the high bit we get 120,60,30, etc bpm
        // so this is 60 bpm
        //and #%00000010  // <-- beat mask
        // this is kind of dit-dit (rest) dit-dit (rest)
        and #%00001010  
        bne !+ 
            Set SID+CONTROL:#%00100001
            jmp loop
        !:
        
        Set SID+CONTROL:#%00100000
    jmp loop

    // well that is sorta kinda what I was thinking of
    // there is another implementation in the spike/sine5.asm
    // in a musical sense this should step a sequence
    // i imagine an arp pattern as the sequence, looping, and the beat moves fast or slow
    // this implementation is also pretty convoluted...
    // can I just use a counter? if I used a timer yes.  This has extra malarky as we are in a tight loop
    // watching for a "pin" (v3 osc) to go high/low
    // inefficient too

    // if i speed up the v3 osc to say f_lo=136
    // and set the "beat mask" to #%00001010  
    // it's kinda neat.  we get that pattern repeatedly as we count up to 255, it's like xx--xx-- dit-dit  dit-dit

    // i abandon this now.

    clock_prev: .byte 0
    clock_hi: .byte 0
    slow_clock: .byte 0
}

.macro Reverb(){
    // is it possible? ping pong to 2 two voices, retrigger with just attack and release
    // each attack retrigger is quieter
}

.macro Delay() {
    // try a circular buffer
    // or just clock slew?
}

.macro VCR(){
    // resonance
    // v3 freq
    Set SID+VOICE3+FREQ_LO:#20
    Set SID+VOICE3+FREQ_HI:#0
    
    loop:
        // v3 amplitude/waveform output
        lda $D41B
        and #%11110000
        ora #%00000001
        sta SID+MIX+FILTER_CONTROL

    jmp loop    
}

.macro PWM(){
    // v3 freq
    Set SID+VOICE3+FREQ_LO:#04
    Set SID+VOICE3+FREQ_HI:#0
    // ensure square wave on v1
    Set SID+CONTROL:#%01000001

    loop:
        // v3 amplitude/waveform output
        // could also use envelope
        lda $D41B
        sta SID+PW_LO

    jmp loop
}

.macro VCO(){
    // v3 freq
    Set SID+VOICE3+FREQ_LO:#20
    Set SID+VOICE3+FREQ_HI:#0

    // different waveforms, saw, triangle. pulse sounds no good
    Set SID+VOICE3+CONTROL:#%00100000
    
    loop:
        // v3 amplitude/waveform output
        lda $D41B
        sta SID+FREQ_HI

    jmp loop
}

.macro VCF(){
    // v3 freq acts speed
    Set SID+VOICE3+FREQ_LO:#12
    // keep this zero, or it's too fast
    Set SID+VOICE3+FREQ_HI:#0

    // some noise, or triangle to go up-down
    Set SID+VOICE3+CONTROL:#%10000000

    // filter controls
    Set SID+MIX+FILTER_CUT_OFF_LO:#%00000111
    Set SID+MIX+FILTER_CUT_OFF_HI:#%00000001
    // ensure filter on V1 so we can hear it
    Set SID+MIX+FILTER_CONTROL:#%01110001
    // v3 off, max volume, lpf on
    Set SID+MIX+VOLUME:#%10011111
    
    loop:
        // v3 amplitude/waveform output
        lda $D41B
        sta SID+MIX+FILTER_CUT_OFF_HI

    jmp loop
}

.macro Follower(){
 
    // v3 envelope
    // the large the values the longer the period
    Set SID+VOICE3+ATTACK_DECAY:#$CF
    // as we never trigger the release might as well be zero
    // if you set sustain to some value then decay will stop there
    Set SID+VOICE3+SUSTAIN_RELEASE:#$00
    
    loop:
        // v3 envelope output
        lda $D41C
        sta SID+FREQ_HI
    jmp loop
}

.macro GateControl(){
    .const threshold = 180

     loop:
        // v3 amplitude/waveform output
        lda $D41B
        // cmompare the v3 output to a threshold
        cmp #threshold
        // less than then branch
        bcc !+ 
            // passed the trigger voltage/value
            // set v1 on
            Set SID+CONTROL:#%00100001

            jmp loop
        !:
            // set v1 off
            Set SID+CONTROL:#%00100000

    jmp loop
}