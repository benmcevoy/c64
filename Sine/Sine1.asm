BasicUpstart2(Start)

#import "../_charscreen.lib"

Start:{

    // TODO: draw a Sine wave
    // can mess with frequency
    // and Cosine too

    // so how do you use it?
    // some thing like below , index into sine,x
    // values are "normalized" to 0:255

    Set x1:#0
    Set w0:#0
loop:
    ldx w0
    lda sine,X
    lsr;lsr;lsr;lsr
    clc
    adc #4
    sta y1

    lda w0
    cmp #0
    bne !+
        ldx x1
        stx x2
        ldy y1
        sty y2
    !:

    Set CharScreen.PenColor:#GREEN
    Call CharScreen.PlotLine : x1: y1: x2: y2
    Set CharScreen.PenColor:#YELLOW
    Call CharScreen.Plot : x1: y1

    ldx x1
    stx x2
    ldy y1
    sty y2

    // this is f = 10
    lda w0
    clc
    adc #10
    sta w0

    inc x1
    lda x1
    cmp #40
    bcs !+
        jmp loop
    !:

    rts
    // screen coords
    x1: .byte 0
    y1: .byte 0

    x2: .byte 0
    y2: .byte 0

    // the angle
    w0: .byte 0
    
}

    // unsigned trig tables
    sine: .fill 256,round(127.5+127.5*sin(toRadians(i*360/256)))
    cosine: .fill 256,round(127.5+127.5*cos(toRadians(i*360/256)))

     // generatered data is:

     /*
128
131
134
137
140
143
146
149
152
155
158
162
165
167
170
173
176
179
182
185
188
190
193
196
198
201
203
206
208
211
213
215
218
220
222
224
226
228
230
232
234
235
237
238
240
241
243
244
245
246
248
249
250
250
251
252
253
253
254
254
254
255
255
255
255
255
255
255
254
254
254
253
253
252
251
250
250
249
248
246
245
244
243
241
240
238
237
235
234
232
230
228
226
224
222
220
218
215
213
211
208
206
203
201
198
196
193
190
188
185
182
179
176
173
170
167
165
162
158
155
152
149
146
143
140
137
134
131
128
124
121
118
115
112
109
106
103
100
97
93
90
88
85
82
79
76
73
70
67
65
62
59
57
54
52
49
47
44
42
40
37
35
33
31
29
27
25
23
21
20
18
17
15
14
12
11
10
9
7
6
5
5
4
3
2
2
1
1
1
0
0
0
0
0
0
0
1
1
1
2
2
3
4
5
5
6
7
9
10
11
12
14
15
17
18
20
21
23
25
27
29
31
33
35
37
40
42
44
47
49
52
54
57
59
62
65
67
70
73
76
79
82
85
88
90
93
97
100
103
106
109
112
115
118
121
124
*/

