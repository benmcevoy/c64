#importonce
#import "_prelude.lib"
#import "_charscreen.lib"
#import "Sid.asm"
#import "Render.asm"
#import "Input.asm"
#import "Config.asm"

.namespace Tempo {

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
