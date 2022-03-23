BasicUpstart2(start)

#import "_prelude.lib"
#import "_math.lib"
#import "_debug.lib"

start:
        Call Math.Mul16:#16:#48

        // expect 16*48 = 768 = $0300
        // that works, I'm kind of amazed at how tight his code is

        DebugPrint __val1
        DebugPrint __val0


        // some primes
        Call Math.Mul16:#13:#37

        // expect 481 or $01e1
        DebugPrint __val1
        DebugPrint __val0


        // signed multiply
        Call Math.SMul16:#12:#-8

        // expect -96 or $ffa0
        DebugPrint __val1
        DebugPrint __val0

        // signed multiply
        Call Math.SMul16:#-40:#-33

        // expect 1320 or $0528
        DebugPrint __val1
        DebugPrint __val0

        Call Math.SMul16:#40:#33

        // expect 1320 or $0528
        DebugPrint __val1
        DebugPrint __val0

        Call Math.SMul16:#-40:#33

        // expect -1320 or $fad8
        DebugPrint __val1
        DebugPrint __val0

        // groovy

        rts
