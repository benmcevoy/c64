BasicUpstart2(start)
//#define FASTMATH
#import "_prelude.lib"
#import "_math.lib"

start:

           

            Sat16 dx: dHi
            SMulW32 dx:dHi:friction:friction+1
            Set dx:__val1
            DebugPrint __val3
            DebugPrint __val2
            DebugPrint __val1
            DebugPrint __val0

            DebugPrintLine
            DebugPrint dx
        rts
dx: .byte 48
friction: .word $0010

dHi: .byte 0