#importonce 
#import "_prelude.lib"
// zero page
.const readInputDelay = 4
.const AXIS = 8
.const TRAILS = 11
.const WIDTH = 51
.const HEIGHT = 51
.const OFFSET = 15
.const SLOWMO = %00000011


.label _readInputInterval = $20 // byte
.label PenColor = $21 // byte
.label xRelative = $22 // word
.label yRelative = $24 // word
.label sineAngle = $26 // word
.label cosineAngle = $28 // word
.label x2a = $2a // word
.label y2a = $2c // word
.label x1 = $2e // byte
.label y1 = $2f // byte
.label time = $30 // byte
.label clock = $31 // byte
.label _rotation_angle_increment = $32 // byte
.label _slowMo = $33 // byte 

// indexes
.label j = $34 // byte
.label x = $35 // byte
.label y = $36 // byte 
.label startAngle = $37 // word
.label writePointer = $39 // byte 
.label erasePointer = $3A // byte 
.label CENTERX = $3b
.label CENTERY = $3c

.label palette = $40

.var palleteList = List()
.eval palleteList.add(CYAN,LIGHT_BLUE,PURPLE,LIGHT_RED,
        ORANGE,YELLOW,LIGHT_GREEN,GREEN,
        LIGHT_BLUE,BLUE,BLUE,BLUE,
        ORANGE,YELLOW,LIGHT_GREEN,GREEN)

// .eval palleteList.add(  0,6,11,4,
//                         14,5,3,13,
//                         7,1,1,7,
//                         13,15,5,12)

.label xTrails = $50
.label yTrails = $50 + (AXIS*TRAILS)

.macro InitializeState() {
    Set _readInputInterval:#readInputDelay
    Set PenColor:#BLACK
    Set xRelative:#0
    Set xRelative+1:#0
    Set yRelative:#0
    Set yRelative+1:#0
    Set sineAngle:#0
    Set sineAngle+1:#0
    Set cosineAngle:#0
    Set cosineAngle+1:#0
    Set x2a:#0
    Set x2a+1:#0
    Set y2a:#0
    Set y2a+1:#0
    Set x1:#0
    Set y1:#0
    Set time:#0
    Set clock:#0
    Set _rotation_angle_increment:#0
    Set _slowMo:#SLOWMO
    Set CENTERX:#(WIDTH/2)
    Set CENTERY:#(HEIGHT/2)
    Set y:CENTERY
    Set erasePointer:#44
    


    .for(var i=0; i<palleteList.size(); i++) {
        Set palette+i:#palleteList.get(i)
    }
}
