BasicUpstart2(start)

#import "_prelude.lib"
#import "_math.lib"
#import "_debug.lib"

start:
        Call Math.Mult_U8_U16:#16:#48

        // expect 16*48 = 768 = $0300
        // that works, I'm kind of amazed at how tight his code is

        DebugPrint __val1
        DebugPrint __val0


        // some primes
        Call Math.Mult_U8_U16:#13:#37

        // expect 481 or $01e1
        DebugPrint __val1
        DebugPrint __val0

        rts

        