#importonce
#import "_prelude.lib"
#import "sid.asm"
#import "parametric.song.asm"
// #import "instruments.asm"
// #import "patterns.asm"





.namespace Sound {

    .const NOTEINDEX = 0
    .const CLOCK = 1
    .const PATTERNSTART = 2
    .const PATTERNINDEX = 4
    .const PATTERN = 5

    Song: {
        v1NoteIndex: .byte 0
        v1Clock:    .byte 2
        v1PatternStart: .word voice1
        v1PatternIndex: .byte 0
        v1Pattern: .word $0000

        v2NoteIndex: .byte 0
        v2Clock:    .byte 1
        v2PatternStart: .word voice2
        v2PatternIndex: .byte 0
        v2Pattern: .word $0000

        v3NoteIndex: .byte 0
        v3Clock:    .byte 0
        v3PatternStart: .word voice3
        v3PatternIndex: .byte 0
        v3Pattern: .word $0000

        controlChannelIndex: .byte 0
        controlChannelClock:    .byte 0
        controlChannelPatternStart: .word controlChannel
        controlChannelPatternIndex: .byte 0
        controlChannelPattern: .word $0000
    }

    Init: {
        SetInstrument(VOICE1, instrument0)
        SetInstrument(VOICE2, instrument1)
        SetInstrument(VOICE3, bassInstrument)      

        NextPattern(VOICE1)
        NextPattern(VOICE2)
        NextPattern(VOICE3)
        NextPattern(MIX)

        // filters and whatnot
        Set SID+MIX*7+FILTER_CUT_OFF_LO:#%00000111
        Set SID+MIX*7+FILTER_CUT_OFF_HI:#%00001111
        Set SID+MIX*7+FILTER_CONTROL:#%11110101
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

        UpdateControlChannel()

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
        .var noteAD = SID+channelNo*7+ATTACK_DECAY
        .var noteSR = SID+channelNo*7+SUSTAIN_RELEASE
        .var notePWLo = SID+channelNo*7+PW_LO
        .var notePWHi = SID+channelNo*7+PW_HI


        .var instrumentDuration = SID+channelNo+DURATION
        .var instrumentTune = SID+channelNo+TUNE
        .var instrumentPtrLo = SID+channelNo+INSTRUMENT_LO
        .var instrumentPtrHi = SID+channelNo+INSTRUMENT_HI
        
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
                // if REST then skip setting the note
                bne     !+
                    jmp !noteExtras+
                !:
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

                pha
                // apply instrument
                {
                    // some self modifying whatnot now
                    lda instrumentPtrLo
                    sta instrumentPtr1
                    sta instrumentPtr2
                    lda instrumentPtrHi
                    sta instrumentPtr1+1
                    sta instrumentPtr2+1

                    ldx #0
                    loop:
                        lda instrumentPtr1:$BEEF,X
                        sta SID+channelNo*7+PW_LO, X
                        inx
                        cpx #5
                        bne loop

                    lda instrumentPtr2:$BEEF,X
                    sta SID+TUNE+channelNo
                }
                pla

                // set tone
                tax
                lda     freq_msb,x
                sta     noteFreqHi  
                lda     freq_lsb,x

                // apply extras
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
               
                // MORE COMMANDS HERE I THINK
                // TODO: this is not a very good structure I think, 
                // how would you have many commands?
                // think about midi again , noteOn - noteNumber, velocity or cc,control,data
                // more like command, data, data
                // packing it into a single byte is a hassle
                inc     noteIndex
                ldy     noteIndex
                lda     (pattern),y  

                // .A contains command
                // high nibble is command, low is data
                // $00 do nothing
                // $1x - set instrument sustain volume
                and #%00010000 
                beq !+
                    lda     (pattern),y  
                    and #%00001111
                    asl;asl;asl;asl
                    sta noteSR
                !:
                
                // next note, command or data
                inc     noteIndex
                jmp !end+

        !skip:
            // testing for noteOff, but this is very arbitrary
            lda     instrumentDuration
            sec
            sbc     #TEMPO/2
            cmp     noteClock
            bne !end+
                // trigger off
                lda noteControl
                and #%11111110
                sta noteControl
        !end:
    }

    .macro UpdateControlChannel() {
        .var noteClock = Song+MIX*7+CLOCK
        .var noteIndex = Song+MIX*7+NOTEINDEX
        
        .var songPattern = Song+MIX*7+PATTERN
        .var songPatternIndex = Song+MIX*7+PATTERNINDEX

        .var filterCutOffHi = SID+MIX*7+FILTER_CUT_OFF_HI
        .var pattern = __ptr1

        // TODO: a lot of this looks like it can be DRYed up with UpdateChannel

        Set pattern:songPattern
        Set pattern+1:songPattern+1

        inc     noteClock
        lda     noteClock
        cmp     #TEMPO
        bne     !skipBeat+
            Set noteClock:#0
            !readNote:
            ldy     noteIndex
            lda     (pattern),y  
            // if REST then skip setting the note
            beq     !next+
            // if end of pattern reset note index
            cmp     #$ff
            bne     !++
                // reset noteIndex
                Set     noteIndex:#0
                
                NextPattern(MIX)

                // check for song end $ffff
                lda songPattern
                cmp #$ff
                bne !+
                        lda songPattern+1
                        cmp #$ff
                        bne !+
                        // TODO: start song again?
                        Set     songPatternIndex:#0
                        NextPattern(MIX)
                !:

                jmp     !readNote-
            !:

            sta     filterCutOffHi    
        !next:
            // TODO: should probably support duration too?
            // control channel is on the beat/TEMPO only at the moment

            inc      noteIndex
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