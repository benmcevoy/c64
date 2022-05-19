#importonce
#import "_prelude.lib"
#import "sid.asm"
#import "instruments.asm"
#import "patterns.asm"

.namespace Sound {

    .const NOTEINDEX = 0
    .const CLOCK = 1
    .const PATTERN = 2

    Song: {
        v1NoteIndex: .byte 0
        v1Clock:    .byte 0
        v1CurrentPattern: .word $0000

        v2NoteIndex: .byte 0
        v2Clock:    .byte 0
        v2CurrentPattern: .word $0000

        v3NoteIndex: .byte 0
        v3Clock:    .byte 0
        v3CurrentPattern: .word $0000

        controlChannelIndex: .byte 0
        controlChannelClock:    .byte 0
        controlChannelCurrentPattern: .word $0000
    }

    Init: {
        SetInstrument(VOICE1, saw)
        SetInstrument(VOICE2, sawDetune)
        SetInstrument(VOICE3, bass)      

        // TODO: not working
        lda #<psytrance
        sta Song+0*4+PATTERN
        lda #>psytrance
        sta Song+0*4+PATTERN+1

        // filters and whatnot
        Set SID+MIX*7+FILTER_CUT_OFF_LO:#%00000111
        Set SID+MIX*7+FILTER_CUT_OFF_HI:#%00001111
        Set SID+MIX*7+FILTER_CONTROL:#%11110011
        Set SID+MIX*7+VOLUME:#%00011111

        rts
    }

    Play: {
        // ack irq
        lda    #$01
        sta    $d019
        // set next irq line number
        lda    #100
        sta    $d012

        dec $d020
        Render()

        dec $d020
        UpdateChannel(VOICE1)
        UpdateChannel(VOICE2)
        UpdateChannel(VOICE3)

        PlayFilter(MIX, filter)

        inc $d020
        inc $d020
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }
    
    .macro UpdateChannel(channelNo) {

        // TODO: the current pattern .word - need to check addressing modes as this may need to be ZP?
        // the voice needs to point at the patternList and jump a couple of bytes
        // or use hi-lo lookups
        .var pattern = psytrance//Song+voiceNumber*4+PATTERN

        inc     Song+channelNo*4+CLOCK
        lda     Song+channelNo*4+CLOCK
        cmp     SID+channelNo+DURATION
        bne     !skipBeat+
            // reset clock
            Set Song+channelNo*4+CLOCK:#0

            !readNote:
                ldx     Song+channelNo*4+NOTEINDEX
                lda     pattern,x  
                // if REST then skip setting the tone
                beq     !noteExtras+
                // if end of pattern reset note index
                cmp     #$ff
                bne     !+
                    Set     Song+channelNo*4+NOTEINDEX:#0
                    jmp     !readNote-
                !:

                // set tone
                tax
                lda     freq_msb,x
                sta     SID+channelNo*7+FREQ_HI         
                lda     freq_lsb,x
                // detune is property of instrument
                clc
                adc     SID+channelNo+TUNE
                sta     SID+channelNo*7+FREQ_LO
                
                // trigger on
                lda SID+channelNo*7+CONTROL
                ora #%00000001
                sta SID+channelNo*7+CONTROL

            !noteExtras:
                inc     Song+channelNo*4+NOTEINDEX
                ldx     Song+channelNo*4+NOTEINDEX
                lda     pattern,x  
                // expect duration in the high-low nibbles
                sta     SID+channelNo+DURATION         
            
                // next note, command or data
                inc     Song+channelNo*4+NOTEINDEX

                // MORE COMMANDS HERE I THINK

                jmp !end+

        !skipBeat:
            lda     SID+channelNo+DURATION
            sec
            sbc     #2
            cmp     Song+channelNo*4+CLOCK
            bne !end+
                // trigger off
                lda SID+channelNo*7+CONTROL
                and #%11111110
                sta SID+channelNo*7+CONTROL
        !end:
    }

    .macro PlayFilter(channelNo,  pattern) {
        inc     Song+channelNo*4+CLOCK
        lda     Song+channelNo*4+CLOCK
        cmp     #TEMPO
        bne     !skipBeat+
            !readNote:
            ldx     Song+channelNo*4+NOTEINDEX
            lda     pattern,x  
            // if REST then skip it
            beq     !next+

            // if end of pattern reset note index
            cmp     #$ff
            bne     !+
                Set      Song+channelNo*4+NOTEINDEX:#0
                jmp     !readNote-
            !:

            sta     SID+3*7+FILTER_CUT_OFF_HI    
        !next:
            inc      Song+channelNo*4+NOTEINDEX
        !skipBeat:
    }

    .macro Render() {
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
    }
}