#importonce
#import "_prelude.lib"
#import "_debug.lib"
#import "AgentTable.asm"

// declare the layout in bytes
.namespace Agent {
    /* this is like a header file */
    /* offset in bytes, order is important */
    .label destroyed = 0
    .label x = 1 // word
    .label y = 3 // word
    .label z = 5
    .label dx = 6 
    .label dy = 7 
    .label Update = 8 // word  
    .label Render = 10 // word
    .label glyph = 12
    .label color = 13
    .label x0 = 14 // word
    .label y0 = 16 // word
    .label bgGlyph = 18
    .label bgColor = 19
    
    .label Length = 20

    // PICO-8 uses "flags" to associate behaviours, e.g. a tile or char with flag0 set is "collidable", a tile with flag1 set is a health buff, etc.
    // consider if we could use the top nibble of colour ram to store flags per character tile?  Thought about WALL, ANIM0, ANIM1, ANIM2 or WALL, BOUNCY, SLOW, ???
    // ideally flags should be additive so you can combine flags to get rich behaviour, like a bouncy wall or floor

    .label __objectPtr = __ptr3

    //@Call
    Invoke: {
        .var field = __arg0
        .var __methodPtr = __ptr1
    
        ldy field
        lda (__objectPtr),Y
        sta __methodPtr
        iny
        lda (__objectPtr),Y
        sta __methodPtr + 1

        Call (__methodPtr)

        rts
    }

    //@Call
    IsDestroyed: {
        Get(Agent.destroyed, __val0)
        rts
    }

    //@Call
    SetCurrentObject: {
        .var index = __arg0

        // calculate object pointer, offset by index*2 (2 bytes)
        lda index
        asl // *2
        tax
        
        lda __agents,x
        sta __objectPtr
        inx
        lda __agents,x
        sta __objectPtr+1

        rts
    }

    .macro Get(y, target){
        ldy #y
        lda (Agent.__objectPtr),Y
        sta target
    }

    .macro GetW(y, target){
        Get(y, target)
        iny 
        lda (Agent.__objectPtr),Y
        sta target+1
    }

    .macro Set(y, source){
        ldy #y
        lda source
        sta (Agent.__objectPtr),Y
    }

    .macro SetW(y, source){
        Set(y, source)
        iny
        lda source+1
        sta (Agent.__objectPtr),Y
    }
}
