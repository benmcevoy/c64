#importonce
#import "_prelude.lib"
#import "_charscreen.lib"

#import "Sid.asm"


.namespace Tempo {

    ReadInput: {
        .const PORT2   = $dc00
        .const UP      = %00000001
        .const DOWN    = %00000010
        .const LEFT    = %00000100
        .const RIGHT   = %00001000
        .const FIRE    = %00010000

        .const LEFT_AND_FIRE    = %00010100
        .const RIGHT_AND_FIRE    = %00011000
        .const UP_AND_FIRE    = %00010001
        .const DOWN_AND_FIRE    = %00010010

        // hold down fire to change overall tempo
        lda #LEFT_AND_FIRE
        bit PORT2
        bne !++
            lda _frameInterval
            cmp #1
            beq !+
                dec _frameInterval
            !:
            jmp exit
        !:

        lda #RIGHT_AND_FIRE
        bit PORT2
        bne !++
            lda _frameInterval
            cmp #$ff
            beq !+
                inc _frameInterval
            !:
            jmp exit
        !:

        lda #UP_AND_FIRE
        bit PORT2
        bne !++
            lda _selectedVoice
            tax
            lda _voiceOffset, X
            beq !+
                dec _voiceOffset, X
            !:
            jmp exit
        !:

        lda #DOWN_AND_FIRE
        bit PORT2
        bne !++
            lda _selectedVoice
            tax
            lda _voiceOffset, X
            cmp _steps
            beq !+
                inc _voiceOffset, X
            !:
            jmp exit
        !:

        lda #UP
        bit PORT2
        bne !++
            lda _selectedVoice
            cmp #0
            beq !+
                dec _selectedVoice
            !:
            jmp exit
        !:

        lda #DOWN
        bit PORT2
        bne !++
            lda _selectedVoice
            cmp #2
            beq !+
                inc _selectedVoice
            !:
            jmp exit
        !:

        lda #LEFT
        bit PORT2
        bne !++
            lda _selectedVoice
            tax
            lda _voiceNumberOfBeats, X
            beq !+
                dec _voiceNumberOfBeats, X
            !:
            jmp exit
        !:

        lda #RIGHT
        bit PORT2
        bne !++
            lda _selectedVoice
            tax
            lda _voiceNumberOfBeats, X
            cmp _steps
            beq !+
                inc _voiceNumberOfBeats, X
            !:
        !:

    exit:
        rts
    }

    Render: {
        
        lda x
        beq !+
            Set CharScreen.Character:#046
            Set CharScreen.PenColor:#DARK_GRAY
            Call CharScreen.Plot:x:#8
            Call CharScreen.Plot:x:#9
            Call CharScreen.Plot:x:#10
        !:

        lda _stepIndex
        clc; adc #8
        sta x

        ldy #0
        Set CharScreen.Character:#046
        Set CharScreen.PenColor:#DARK_GRAY
        lda _voiceOn, Y
        cmp #1
        bne !+
            Set CharScreen.Character:#81
            Set CharScreen.PenColor:#GREEN
        !:
        Call CharScreen.Plot:x:#8

        iny
        Set CharScreen.Character:#046
        Set CharScreen.PenColor:#DARK_GRAY
        lda _voiceOn, Y
        cmp #1
        bne !+
            Set CharScreen.Character:#81
            Set CharScreen.PenColor:#YELLOW
        !:
        Call CharScreen.Plot:x:#9

        iny
        Set CharScreen.Character:#046
        Set CharScreen.PenColor:#DARK_GRAY
        lda _voiceOn, Y
        cmp #1
        bne !+
            Set CharScreen.Character:#81
            Set CharScreen.PenColor:#BLUE
        !:
        Call CharScreen.Plot:x:#10

        Set CharScreen.Character:#032
        Call CharScreen.Plot:#6:#8
        Call CharScreen.Plot:#6:#9
        Call CharScreen.Plot:#6:#10

        lda _selectedVoice
        clc; adc #8
        sta y

        Set CharScreen.Character:#046
        Set CharScreen.PenColor:#RED
        Call CharScreen.Plot:#6:y

        rts
        x: .byte 0
        y: .byte 0
    }

    Init: {
        // set raster irq line number
        lda    #0
        sta    $d012

        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#10
        Set SID_MIX_FILTER_CONTROL:#%11110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_FREQ_LO:#$b4 
        Set SID_V1_FREQ_HI:#$08
        Set SID_V1_PW_LO:#$00
        Set SID_V1_PW_HI:#$00
        Set SID_V1_ATTACK_DECAY:#$08
        Set SID_V1_SUSTAIN_RELEASE:#$0

        Set SID_V2_FREQ_LO:#$f7 
        Set SID_V2_FREQ_HI:#$0a
        Set SID_V2_PW_LO:#$00
        Set SID_V2_PW_HI:#$00
        Set SID_V2_ATTACK_DECAY:#$08
        Set SID_V2_SUSTAIN_RELEASE:#$00

        Set SID_V3_FREQ_LO:#$0a 
        Set SID_V3_FREQ_HI:#$0d
        Set SID_V3_PW_LO:#$00
        Set SID_V3_PW_HI:#$00
        Set SID_V3_ATTACK_DECAY:#$08
        Set SID_V3_SUSTAIN_RELEASE:#$00

        rts
    }

    OnRasterInterrupt: {
        // ack irq
        lda    #$01
        sta    $d019

        dec _frameCounter
        beq !+
            jmp nextFrame
        !: 

    stepStart:
        MCopy _frameInterval:_frameCounter
        
        // hmm... this is now an unrolled loop

        ldy #0
        lda #0
        sta _voiceOn,Y
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc _voiceOffset, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        beq !+
            // trigger on
            lda  #%00100000
            sta SID_V1_CONTROL
            lda  #%00100001
            sta SID_V1_CONTROL
            
            //inc _voiceOn,Y only works on X index
            lda #1
            sta _voiceOn, Y
        !:
        
        iny
        lda #0
        sta _voiceOn,Y
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc _voiceOffset,Y
        tax

        lda _rhythm, X
        // if 0 then REST
        beq !+
            // trigger on
            lda  #%00100000
            sta SID_V2_CONTROL
            lda  #%00100001
            sta SID_V2_CONTROL      
            lda #1
            sta _voiceOn, Y
        !:

        iny
        lda #0
        sta _voiceOn,Y
        lda _voiceNumberOfBeats, Y
        // *16 so shift 4 times
        asl;asl;asl;asl
        clc 
        adc _stepIndex
        adc _voiceOffset, Y
        tax

        lda _rhythm, X
        // if 0 then REST
        beq !+
            // trigger on
            lda  #%00100000
            sta SID_V3_CONTROL
            lda  #%00100001
            sta SID_V3_CONTROL            
            lda #1
            sta _voiceOn, Y
        !:

        jsr Render

        inc _stepIndex
        lda _stepIndex
        cmp _steps
        bne !+
            Set _stepIndex:#0
        !:

    nextFrame:
        dec _readInputInterval
        bne !+
            jsr ReadInput
            Set _readInputInterval:#8
        !:

        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 1
    _frameInterval: .byte 12
    _readInputInterval: .byte 8
    _stepIndex: .byte 0
    _selectedVoice: .byte 0
    _steps: .byte 8

    // between 0-8 (_steps=8)
    _voiceNumberOfBeats: .byte 1,0,0
    // offset 0-8
    _voiceOffset: .byte 0,0,0
    // flags
    _voiceOn: .byte 0,0,0

    // double up the seqeunce so we can offset into it
    _rhythm: 
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
        .byte 1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0
        .byte 1,0,0,1,0,0,1,0,1,0,0,1,0,0,1,0
        .byte 1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0
        .byte 1,0,1,1,0,1,1,0,1,0,1,1,0,1,1,0
        .byte 1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1
        .byte 1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0
        .byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

    // play the "registers" for a rythmn
    // 
    // pattern 
    // Voice, NumberOfbeats, Offset, Length (1..8), V1 etc or $FF terminator (#ACTION_HANDLED)?
    // and maybe tempo, instrument

    // and a function to drive them, another L.U.T. like sine
}
