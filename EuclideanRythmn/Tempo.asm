#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Sid.asm"
#import "Render.asm"
#import "Config.asm"

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
        lda #RIGHT_AND_FIRE
        bit PORT2
        bne !++
            lda _frameInterval
            cmp #1
            beq !+
                dec _frameInterval
            !:
            jmp exit
        !:

        lda #LEFT_AND_FIRE
        bit PORT2
        bne !++
            lda _frameInterval
            cmp #$ff
            beq !+
                inc _frameInterval
            !:
            jmp exit
        !:

        // lda #DOWN_AND_FIRE
        // bit PORT2
        // bne !++
        //     lda _transpose
        //     beq !+
        //         dec _transpose
        //     !:
        //     jmp exit
        // !:

        // // transpose
        // lda #UP_AND_FIRE
        // bit PORT2
        // bne !++
        //     lda _transpose
        //     cmp #scale_length
        //     beq !+
        //         inc _transpose
        //     !:
        //     jmp exit
        // !:

        //offset or rotation
        lda #UP_AND_FIRE
        bit PORT2
        bne !++
            lda _selectedVoice
            tax
            lda _voiceOffset, X
            beq !+
                dec _voiceOffset, X
                jmp exit
            !:
            lda #7
            sta _voiceOffset, X
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
                jmp exit
            !:
            lda #0
            sta _voiceOffset, X
            jmp exit
        !:

        lda #DOWN
        bit PORT2
        bne !++
            lda _selectedVoice
            cmp #0
            beq !+
                dec _selectedVoice
                jmp exit
            !:
            Set _selectedVoice:#2
            jmp exit
        !:

        lda #UP
        bit PORT2
        bne !++
            lda _selectedVoice
            cmp #2
            beq !+
                inc _selectedVoice
                jmp exit
            !:
            Set _selectedVoice:#0
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

    
    Init: {
        // set next raster irq line number
        lda    #0
        sta    $d012

        // init SID
        Set SID_MIX_FILTER_CUT_OFF_LO:#%00000111  
        Set SID_MIX_FILTER_CUT_OFF_HI:#10
        Set SID_MIX_FILTER_CONTROL:#%01110111
        Set SID_MIX_VOLUME:#%00011111

        Set SID_V1_ATTACK_DECAY:#$09
        Set SID_V2_ATTACK_DECAY:#$09
        Set SID_V3_ATTACK_DECAY:#$09

        SetPulseWidth(0, $08, $00)
        SetPulseWidth(1, $06, $00)
        SetPulseWidth(2, $0A, $00)

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
        
        SetChord(Min, _transpose)

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
            SetWaveForm(0, Silence)
            SetWaveForm(0, Triangle)
            
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
            SetWaveForm(1, Silence)
            SetWaveForm(1, Square)    
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
            SetWaveForm(2, Silence)
            SetWaveForm(2, Square)           
            lda #1
            sta _voiceOn, Y
        !:

        ldx _filterIndex
        lda _filter, X
        sta SID_MIX_FILTER_CUT_OFF_HI
        inc _filterIndex

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
            Set _readInputInterval:#4
        !:

        // end irq
        pla;tay;pla;tax;pla
        rti          
    }

    _frameCounter: .byte 1
    _frameInterval: .byte 32
    _readInputInterval: .byte 4

    _filterIndex: .byte 0
    _filter: 
        // round(resolution + dcOffset + resolution * sin(toradians(i * 360 * f / resolution )))
        // e.g. fill sine wave offset 16 with 4 bit resolution
        .var speed = 1; .var low = 1; .var high = 8

        .fill 16,round(high+low+high*sin(toRadians(i*360*(speed+0)/high)))
        .fill 16,round(high+low+high*sin(toRadians(i*360*(speed+0)/high)))

        .eval high = 12
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
        
        .eval high = 8
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
        
        .eval high = 12
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))

        .eval high = 8
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+4)/high)))
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+8)/high)))
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
        .fill 32,round(high+low+high*sin(toRadians(i*360*(speed+2)/high)))
        .byte $ff
}
