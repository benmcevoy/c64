BasicUpstart2(start)

#import "_prelude.lib"
#import "_math.lib"
#import "_debug.lib"

start:
        // Call Math.Mul16:#16:#48

        // // expect 16*48 = 768 = $0300
        // // that works, I'm kind of amazed at how tight his code is

        // DebugPrint __val1
        // DebugPrint __val0


        // // some primes
        // Call Math.Mul16:#13:#37

        // // expect 481 or $01e1
        // DebugPrint __val1
        // DebugPrint __val0


        // // signed multiply
        // Call Math.SMul16:#12:#-8

        // // expect -96 or $ffa0
        // DebugPrint __val1
        // DebugPrint __val0

        // // signed multiply
        // Call Math.SMul16:#-40:#-33

        // // expect 1320 or $0528
        // DebugPrint __val1
        // DebugPrint __val0

        // Call Math.SMul16:#40:#33

        // // expect 1320 or $0528
        // DebugPrint __val1
        // DebugPrint __val0

        // Call Math.SMul16:#-40:#33

        // // expect -1320 or $fad8
        // DebugPrint __val1
        // DebugPrint __val0

        // // unsigned word multiply
        // // 9.5 * 3.75 = 35.625
        // // 9.5 is $09.$80  (as $80 is 128 and that is HALF of 256)
        // // 3.75 is $03c0
        // // provided bytes lo hi
        // Call Math.MulW32:#$80:#$09:#$c0:#$03
        // // expect 35.625 or $0023a000
        // // $23a0 represents $23.$a0
        // // or 35 and (160/256)  or 35.625
        
        // DebugPrint __val3
        // DebugPrint __val2
        // DebugPrint __val1
        // DebugPrint __val0

        // // signed word mulitply
        // // 9.5 * -3.75 = -35.625
        // // 9.5 is $09.$80  (as $80 is 128 and that is HALF of 256)
        // // -3.75 is $fcc0
        // // provided bytes lo hi
        // Call Math.MulW32:#$80:#$09:#$c0:#$fc
        // // expect -35.625 or $0542a000
        
        // DebugPrint __val3
        // DebugPrint __val2
        // DebugPrint __val1
        // DebugPrint __val0

        // // -16.0 * 0.351625 = -5.626
        // // -16.00 is $f000
        // // 0.351652 = $005a
        // // expected result is -5.626 base10
        // // $FB.
        // Call Math.SMulW32:#$00:#$f0:#$5a:#$00
        // // expect -35.625 or $05460000
        
        // DebugPrint __val3
        // DebugPrint __val2
        // DebugPrint __val1
        // DebugPrint __val0

        // Set __tmp1:#$F0
        // Set __tmp0:#$5a

        // DebugPrint __tmp1
        // DebugPrint __tmp0

        // Negate16(__tmp0, __tmp1)

        // DebugPrint __tmp1
        // DebugPrint __tmp0


        Set __tmp3:#$ff
        Set __tmp2:#$f0
        Set __tmp1:#$5a
        Set __tmp0:#$00

        DebugPrint __tmp3
        DebugPrint __tmp2
        DebugPrint __tmp1
        DebugPrint __tmp0

        Negate32(__tmp0, __tmp1, __tmp2, __tmp3)

        DebugPrint __tmp3
        DebugPrint __tmp2
        DebugPrint __tmp1
        DebugPrint __tmp0

        rts
