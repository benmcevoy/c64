#importonce

.const GRAVITY = 3
.const IMPULSE = -96
.const SPEED = 64
.const GROUND_CHAR = 224
.const GROUND_COLOR = BLACK

// similar to joystick flags
.const ACTION_COLLIDED_UP       = %00000001
.const ACTION_COLLIDED_DOWN     = %00000010
.const ACTION_COLLIDED_LEFT     = %00000100
.const ACTION_COLLIDED_RIGHT    = %00001000
.const ACTION_IS_FIRING         = %00010000
.const ACTION_IS_JUMPING        = %00100000
// default state for the above flags
playerAction: .byte %00100000

.namespace Kernal{
    .label ClearScreen = $E544
}