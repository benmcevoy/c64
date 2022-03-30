BasicUpstart2(Init)

*=$080d

Init:      sei                  //; set interrupt bit, make the CPU ignore interrupt requests
           
           lda #<Irq            //; set interrupt vectors, pointing to interrupt service routine below
           sta $0314
           lda #>Irq
           sta $0315

           cli                  //; clear interrupt flag, allowing the CPU to respond to interrupt requests
           rts 

Irq:
        inc $D020            //; change border colour
        jmp $EA31            //; jump into KERNAL's standard interrupt service routine to handle keyboard scan, cursor display etc.