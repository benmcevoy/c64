so confused.

SID regsiters gernally are ROM
there are a handful that can be read, like voice 3 

anyway, in my earlier efforts I used a set of normal RAM registers
then copied them to sid every frame (or whenever)

By coincidence I do this in reverse order - from 54296 down to 54272

```
 .macro Render() {
        // memcpy SID 0..24
        ldx #24
        loop:
            lda SID,x
            sta SID_ACTUAL,x
            dex
            bne loop

        // unroll the last iteration, saves some cmp/bra
        lda SID,x
        sta SID_ACTUAL,x
    }
```

This avoids some issue with ADSR and gating.  I am really not sure what that issue is, but
suffice to say it seems you cannot retrigger a note without a couple of frames delay?

if i strobe that pin (off then on) I expect to retrigger

oh, and it does.

I set the envelope to 
attack zero - it takes no time to reach MAX volume
decay 7 - it takes some millisecond to decay to the sustain volume
sustain zero
release zero - don't care as volume was zero anyway

so i have this envelope like `|\__`

ok this is fine.



