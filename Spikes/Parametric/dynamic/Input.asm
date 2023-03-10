#importonce
#import "_prelude.lib"

.const PORT2   = $dc00
.const UP      = %00000001
.const DOWN    = %00000010
.const LEFT    = %00000100
.const RIGHT   = %00001000
.const FIRE    = %00010000

.const LEFT_AND_FIRE    = %00010100
.const RIGHT_AND_FIRE    = %00011000
.const UP_AND_FIRE    = %00010001
.const DOWN_AND_FIRE    = %00010010

// state
time: .byte 0
_rotation_angle_increment: .byte 0
_slowMo: .byte 4

ReadInput: {
    check_left:
        lda #LEFT
        bit PORT2
        bne check_right

        // do the left action
        lda _rotation_angle_increment
        beq _exit
        dec _rotation_angle_increment
        rts

    check_right:
        lda #RIGHT
        bit PORT2
        bne _exit

        // do the right action
        lda _rotation_angle_increment
        cmp #32
        beq _exit
        inc _rotation_angle_increment
        rts

    // check_down:
    //     lda #DOWN
    //     bit PORT2
    //     beq !+
    //         jmp check_up
    //     !:
    //     inc _slowMo
    //     rts;

    // check_up:
    //     lda #UP
    //     bit PORT2
    //     beq !+
    //         jmp check_left
    //     !:
    //     dec _slowMo
    _exit:
        rts
}
