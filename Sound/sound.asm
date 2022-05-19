#importonce
#import "_prelude.lib"
#import "sid.asm"
#import "instruments.asm"
#import "patterns.asm"

.namespace Sound {

    .const NOTEINDEX = 0
    .const CLOCK = 1
    .const PATTERNSTART = 2
    .const PATTERNINDEX = 4
    .const PATTERN = 5

    Song: {
        v1NoteIndex: .byte 0
        v1Clock:    .byte 0
        v1PatternStart: .word voice1
        v1PatternIndex: .byte 0
        v1Pattern: .word $0000

        v2NoteIndex: .byte 0
        v2Clock:    .byte 0
        v2PatternStart: .word voice2
        v2PatternIndex: .byte 0
        v2Pattern: .word $0000

        v3NoteIndex: .byte 0
        v3Clock:    .byte 0
        v3PatternStart: .word $0000
        v3PatternIndex: .byte 0
        v3Pattern: .word $0000

        controlChannelIndex: .byte 0
        controlChannelClock:    .byte 0
        controlChannelPatternStart: .word $0000
        controlChannelPatternIndex: .byte 0
        controlChannelPattern: .word $0000
    }

    Init: {
        SetInstrument(VOICE1, saw)
        SetInstrument(VOICE2, sawDetune)
        SetInstrument(VOICE3, bass)      

        NextPattern(VOICE1)
        NextPattern(VOICE2)

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
        // UpdateChannel(VOICE3)

        // PlayFilter(MIX, filter)

        inc $d020
        inc $d020
        // end irq
        pla;tay;pla;tax;pla
        rti          
    }
    
    .macro UpdateChannel(channelNo) {
        .var noteClock = Song+channelNo*7+CLOCK
        .var noteIndex = Song+channelNo*7+NOTEINDEX
        .var noteFreqLo = SID+channelNo*7+FREQ_LO
        .var noteFreqHi = SID+channelNo*7+FREQ_HI
        .var noteControl = SID+channelNo*7+CONTROL

        .var instrumentDuration = SID+channelNo+DURATION
        .var instrumentTune = SID+channelNo+TUNE
        
        .var songPattern = Song+channelNo*7+PATTERN
        .var songPatternIndex = Song+channelNo*7+PATTERNINDEX

        .var pattern = __ptr1

        Set pattern:songPattern
        Set pattern+1:songPattern+1

        inc     noteClock
        lda     noteClock
        cmp     instrumentDuration
        beq     cont
        jmp     !skip+

            cont:
            // reset clock
            Set noteClock:#0

            !readNote:
                ldy     noteIndex
                lda     (pattern),y  
                // if REST then skip setting the tone
                beq     !noteExtras+
                // if end of pattern reset note index
                cmp     #$ff
                bne     !++
                    // reset noteIndex
                    Set     noteIndex:#0
                    
                    NextPattern(channelNo)

                    // check for song end $ffff
                    lda songPattern
                    cmp #$ff
                    bne !+
                         lda songPattern+1
                         cmp #$ff
                         bne !+
                            // TODO: start song again?
                            Set     songPatternIndex:#0
                            NextPattern(channelNo)
                    !:

                    jmp     !readNote-
                !:

                // set tone
                tax
                lda     freq_msb,x
                sta     noteFreqHi  
                lda     freq_lsb,x
                // detune is property of instrument
                clc
                adc     instrumentTune
                sta     noteFreqLo
                
                // trigger on
                lda noteControl
                ora #%00000001
                sta noteControl

            !noteExtras:
                inc     noteIndex
                ldy     noteIndex
                lda     (pattern),y  
                // expect duration in the high-low nibbles
                sta     instrumentDuration         
            
                // next note, command or data
                inc     noteIndex

                // MORE COMMANDS HERE I THINK

                jmp !end+

        !skip:
            lda     instrumentDuration
            sec
            sbc     #2
            cmp     noteClock
            bne !end+
                // trigger off
                lda noteControl
                and #%11111110
                sta noteControl
        !end:
    }

    .macro PlayFilter(channelNo,  pattern) {
        inc     Song+channelNo*7+CLOCK
        lda     Song+channelNo*7+CLOCK
        cmp     #TEMPO
        bne     !skipBeat+
            !readNote:
            ldx     Song+channelNo*7+NOTEINDEX
            lda     pattern,x  
            // if REST then skip it
            beq     !next+

            // if end of pattern reset note index
            cmp     #$ff
            bne     !+
                Set      Song+channelNo*7+NOTEINDEX:#0
                jmp     !readNote-
            !:

            sta     SID+3*7+FILTER_CUT_OFF_HI    
        !next:
            inc      Song+channelNo*7+NOTEINDEX
        !skipBeat:
    }

    .macro NextPattern(channelNo) {

        .var index = Song+channelNo*7+PATTERNINDEX
        .var patternStart = Song+channelNo*7+PATTERNSTART
        .var currentPattern = Song+channelNo*7+PATTERN

        // copy to ZP
        Set __ptr0:patternStart
        Set __ptr0+1:patternStart+1

        // calculate object pointer, offset by index*2 (2 bytes)
        lda     index
        asl     // *2
        tay
        
        lda     (__ptr0),y
        sta     currentPattern
        iny
        lda     (__ptr0),y
        sta     currentPattern+1
 
        // increment to next
        inc     index
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