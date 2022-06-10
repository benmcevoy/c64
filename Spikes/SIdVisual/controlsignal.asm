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

    VCO()

    rts
}

// things tried and abandoned
// VCA - you cannot manipulate the sustain level without retriggering and it sounds crap
// Ring - nothing special, it's just ring mod.
// Accent - see VCA.  Instead, set an ADSR, then for each note set a sustain level
//  it will at least sustain at different levels, and maybe rest the sustain to the
//  the instrument default afterwards
// test bit - strobe test bit continously with noise, yeah nah

.macro Jiffy(){
    // investigate the JIFFY clock
    
    
}

.macro Ratchet(){
    // and ratcheting
    // https://github.com/RohanM/clock-with-shift/blob/master/clockwithshift.ino
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