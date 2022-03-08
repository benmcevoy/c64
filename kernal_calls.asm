BasicUpstart2(Init)

// declare upfront so we can access the size later
// $93 is petscii clear screen char
// the @ literal is required if you include escaped text
.var msg = @"\$93HELLO WORLD"

// print to console output while compiling
Init:
            ldy #$00
   loop:   lda message,y
            jsr $ffd2
            iny
            cpy #msg.size()
            bne loop
          
          rts

// this is the actual memory location
// verify in a hex editor, opcode RTS is $60, so should see $ 60 93 
// and we totally do. totally.
 message: .text msg

 