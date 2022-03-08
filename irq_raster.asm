BasicUpstart2(Init)

*=$080d

Init:       sei                  //; set interrupt bit, make the CPU ignore interrupt requests
           lda #%01111111       //; switch off interrupt signals from CIA-1
           sta $DC0D

           and $D011            //; clear most significant bit of VIC's raster register
           sta $D011

           lda $DC0D            //; acknowledge pending interrupts from CIA-1
           lda $DD0D            //; acknowledge pending interrupts from CIA-2

           lda #210             //; set rasterline where interrupt shall occur
           sta $D012

           lda #<Irq            //; set interrupt vectors, pointing to interrupt service routine below
           sta $0314
           lda #>Irq
           sta $0315

           lda #%00000001       //; enable raster interrupt signals from VIC
           sta $D01A

           cli                  //; clear interrupt flag, allowing the CPU to respond to interrupt requests
           rts 

Irq:
        lda #$7
        sta $D020            //; change border colour to yellow

        ldx #$90             //; empty loop to do nothing for just under half a millisecond
        dex; bne *-2
        

        lda #$0
        sta $D020            //; change border colour to black

        asl $D019            //; acknowledge the interrupt by clearing the VIC's interrupt flag

        jmp $EA31            //; jump into KERNAL's standard interrupt service routine to handle keyboard scan, cursor display etc.