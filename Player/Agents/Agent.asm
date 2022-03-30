#importonce
#import "_prelude.lib"
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
    .label CurrentState = 20 // word
    
    .label Length = 22

    // PICO-8 uses "flags" to associate behaviours, e.g. a tile or char with flag0 set is "collidable", a tile with flag1 set is a health buff, etc.
    // consider if we could use the top nibble of colour ram to store flags per character tile?  Thought about WALL, ANIM0, ANIM1, ANIM2 or WALL, BOUNCY, SLOW, ???
    // ideally flags should be additive so you can combine flags to get rich behaviour, like a bouncy wall or floor

    /* Current object */
    .label Current = __ptr3

    /* @Macro @global
        Invoke method on Current object
    */
    .macro @AgentInvoke(field){
        .var __methodPtr = __ptr1
    
        ldy #field
        lda (Current),Y
        sta __methodPtr
        iny
        lda (Current),Y
        sta __methodPtr + 1

        Call (__methodPtr)
    }

    /* @Macro @global
       Is Current object destroyed?
    */
    .macro @AgentIsDestroyed() {
        Get(Agent.destroyed, __val0)
    }
    
    /* @Macro @global
       Set Current object via index
    */
    .macro @AgentSetCurrent(index) {
        // calculate object pointer, offset by index*2 (2 bytes)
        lda index
        asl // *2
        tax
        
        lda __agents,x
        sta Current
        inx
        lda __agents,x
        sta Current+1
    }

    /* @Macro
       Get field from Current into target byte
    */
    .macro Get(y, target){
        ldy #y
        lda (Agent.Current),Y
        sta target
    }

    /* @Macro
       Get field from Current into target word
    */
    .macro GetW(y, target){
        Get(y, target)
        iny 
        lda (Agent.Current),Y
        sta target+1
    }

    /* @Macro
       Set field on Current object to byte source
    */
    .macro Set(y, source){
        ldy #y
        lda source
        sta (Agent.Current),Y
    }

    /* @Macro
       Set field on Current object to word source
    */
    .macro SetW(y, source){
        Set(y, source)
        iny
        lda source+1
        sta (Agent.Current),Y
    }

    .macro SetPtr(y, ptr){
        ldy #y
        lda #<ptr
        sta (Agent.Current),Y
        iny
        lda #>ptr
        sta (Agent.Current),Y
    }
}
