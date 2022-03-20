BasicUpstart2(Start)

#import "_prelude.lib"
#import "_charscreen.lib"

Start:{

    // one letter is 1x1 character on screen
    Call CharScreen.WriteString:#10:#9:#<message1:#>message1

    // one letter is 8x8 character on screen
    Call CharScreen.WriteStringLoLoRes:#0:#0:#<message1:#>message1

    // one letter is 4x4 character on screen
    Call CharScreen.WriteStringLoRes:#15:#10:#<message1:#>message1

    // TODO: line2 gets messed up due to page boundaries
    Call CharScreen.WriteStringLoRes:#15:#40:#<line2:#>line2
    Call CharScreen.WriteStringLoLoRes:#0:#10:#<line2:#>line2

    rts

    message1: .text @"hello\$ff"
    line2: .text @"\$1c\$1e\$1f\$4e\$77\$4d\$ff"
		
}