BasicUpstart2(Start)

#import "_prelude.lib"
#import "_charscreen.lib"

Start:{

    // one letter is 1x1 character on screen
    Call CharScreen.WriteString:#10:#9:#<message1:#>message1

    // one letter is 8x8 character on screen
    Call CharScreen.WriteStringHuge:#0:#0:#<message1:#>message1

    Set CharScreen.Character:#81
    Set CharScreen.PenColor:#BLACK
    // one letter is 4x4 character on screen
    Call CharScreen.WriteStringBig:#15:#10:#<message1:#>message1

    Call CharScreen.WriteStringBig:#15:#40:#<line2:#>line2
    Call CharScreen.WriteStringHuge:#0:#10:#<line2:#>line2

    rts

    message1: .text @"hello\$ff"
    line2: .text @"\$1c\$1e\$1f\$4e\$77\$4d\$ff"
		
}