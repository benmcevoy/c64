0 for x=54272to54296:pokex,0:next
1 print chr$(147)
10 let sid = 54272
30 poke sid,37: rem f-lo
40 poke sid+1,4: rem f-hi
50 poke sid+5, 190: rem attack,decay
60 poke sid+6,248: rem sustain, release
70 poke sid+4,1+4+16 : rem square wave on

80 poke sid+23,241: rem filter voice 1 on
81 poke sid+24,31:rem set volume, enable low-pass

82 poke sid+2,100: rem set pulse width
83 poke sid+22,100 : rem set filter freq

90 rem v3
91 poke sid+18,240
92 poke sid+15,4
93 poke sid+19,190
94 poke sid+20,248

100 fhi = 4
110 ff = 16
120 pw = 64
130 flo= 0

200 get k$
210 if k$="q" then fhi=fhi+1
220 if k$="a" then fhi=fhi-1

230 if k$="w" then pw=pw+1
240 if k$="s" then pw=pw-1

250 if k$="e" then ff=ff+1
260 if k$="d" then ff=ff-1

290 if k$="r" then flo=flo+1
300 if k$="f" then flo=flo-1



350 if k$="x" then goto 1000


420 poke sid+1,fhi
430 poke sid+16,pw
440 poke sid+22,ff
450 poke sid+15,fhi
460 poke sid+14,flo

550 print chr$(19)
560 print fhi,pw,ff,flo

600 goto 200


900 end
1000 poke sid+24,0:rem set volume


