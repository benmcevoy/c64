BasicUpstart2(start)

*=$080d

start:
        sei             // disable interrupts, essential for flicker
        ldx #0
        ldy #1
loop:        
        lda #150        // target raster line        
        cmp $d012       // compare to target line
        bne *-3         // jump back three, to the cmp
        
        stx $d020
        stx $d021

        // about 35 cycles available here to do stuff before next line

        lda #151
        cmp $d012       // compare to target line
        bne *-3 

        
        sty $d020
        sty $d021

        // cycles available here here to do stuff
        

        jmp loop