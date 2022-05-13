#importonce
#import "_prelude.lib"
#import "sid.asm"
#import "instruments.asm"
#import "patterns.asm"

.namespace Sound {
    .const BARS = 256

    time: .byte 0   
    tempo: .byte 11
    beat: .byte 3

    v1NoteIndex: .byte 0
    v2NoteIndex: .byte 0
    v3NoteIndex: .byte 0

    // set some skew
    v1Clock:    .byte 2
    v2Clock:    .byte 1
    v3Clock:    .byte 0

    Init: {
        SetInstrument(VOICE1, instrument0)
        SetInstrument(VOICE2, instrument1)
        SetInstrument(VOICE3, bassInstrument)                

        // filters and whatnot
        Set SID+MIX*7+FILTER_CUT_OFF_LO:#%00000111
        Set SID+MIX*7+FILTER_CUT_OFF_HI:#%00001111
        Set SID+MIX*7+FILTER_CONTROL:#%11110101
        Set SID+MIX*7+VOLUME:#%00011111

        rts
    }

    Play: {
        jsr Render

        inc     time

        PlayVoice(VOICE1, v1Clock, v1NoteIndex, arp)
        PlayVoice(VOICE2, v2Clock, v2NoteIndex, arp1)
        PlayVoice(VOICE3, v3Clock, v3NoteIndex, arp2)

        PlayFilter(v1Clock, v1NoteIndex, filter)
        
        jmp     $ea31                  
    }

    Render: {
        // memcpy SID 0..24
        ldx #24
        loop:
            lda SID,x
            sta SID_ACTUAL,x
            dex
            bne loop

        // unroll the last iteration, saves some cmp/bra
        lda SID,x
        sta SID_ACTUAL,x

        rts
    }

    .macro PlayVoice(voiceNumber, clock, noteIndex, pattern) {
        inc     clock
        lda     clock
        cmp     tempo
        bne     !skipBeat+
            // reset clock
            Set clock:#0

            // read note
            ldx     noteIndex
            lda     pattern,x  
            // if REST then skip it
            beq     !nextNote+
            tax
            lda     freq_msb,x
            sta     SID+voiceNumber*7+FREQ_HI         
            lda     freq_lsb,x
            sta     SID+voiceNumber*7+FREQ_LO    

            // trigger on
            lda SID+voiceNumber*7+CONTROL
            ora #%00000001
            sta SID+voiceNumber*7+CONTROL

        !nextNote:
            inc     noteIndex
            lda     noteIndex
            cmp     #BARS
            bne     !+
                Set     noteIndex:#0
            !:

        !skipBeat:
            lda     clock
            cmp     SID+SUSTAIN_DURATION+voiceNumber
            bne !+
                // trigger off
                lda SID+voiceNumber*7+CONTROL
                and #%11111110
                sta SID+voiceNumber*7+CONTROL
        !:
    }

    .macro PlayFilter(clock, noteIndex, pattern) {
        lda     clock
        bne     !skipBeat+
           
            // read note
            ldx     noteIndex
            lda     pattern,x  
            // if REST then skip it
            beq     !nextNote+
            
            sta     SID+3*7+FILTER_CUT_OFF_HI    

        !nextNote:
        !skipBeat:
    }
}