BasicUpstart2(Start)

#import "_charscreen.lib"

.const LENGTH = 42
yOffset: .byte 0
lines: .byte 0

Start: {

    Set $d020:#BLACK
    Set $d021:#BLUE
    Set CharScreen.PenColor:#BLACK

    !loop:
    ldx length
    // for a pattern - four nibbles
    Set byteLine:dither,X
    plot()
    

    inc length
    lda length
    cmp #LENGTH
    bne !loop-

    Set length:#0
    lda yOffset
    clc 
    adc #4
    sta yOffset
    Set x:#0

    inc lines
    lda lines
    cmp #13
    bne !loop-

    rts
}

.macro plot(){
    // for each bit
    ldx #0
    ldy #0
    Set y:yOffset

    plot:
        lda byteLine
        // shift msb into carry
        asl
        sta byteLine
        // test carry
        bcc !+
            Call CharScreen.PlotH:x:y
        !:

        
        inc y
        iny
        cpy #4
        bne !+
            ldy #0
            Set y:yOffset
            inc x

        !:

        
        inx 
        cpx #8
        bne plot

    
}

x: .byte 0
y: .byte 0
byteLine: .byte 0
length: .byte 0

    dither: 
    .byte %00000000
    .byte %00000000
    .byte %00000000

    .byte %00000000
    .byte %00000000    

    .byte %00000000
    .byte %00000000

    .byte %00000000
    .byte %00000000    

    .byte %10000000
    .byte %00100000 

    .byte %10000000
    .byte %10100000

    .byte %10100000
    .byte %10100000

    .byte %10100100
    .byte %10100001

    .byte %10100100
    .byte %10100101

    .byte %10101101
    .byte %10100101

    .byte %10101101
    .byte %10100111

    .byte %10101101
    .byte %10101111

    .byte %10101111
    .byte %10101111   

    .byte %11101111        
    .byte %10111111

    .byte %11101111        
    .byte %11111111

    .byte %11111111    
    .byte %11111111  

    .byte %11111111    
    .byte %11111111  

    .byte %11111111    
    .byte %11111111                        

    .byte %11111111    
    .byte %11111111                        
    .byte %11111111   
    .byte %11111111       
    .byte %11111111           