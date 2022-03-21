#import "_prelude.lib"
#import "_charscreen.lib"
.namespace Background {
	Draw: {
		Set $d020:#DARK_GREY
		Set $d021:#DARK_GREY
		Set CharScreen.PenColor:#GREY
		Set CharScreen.Character:#81

		Call CharScreen.WriteStringLoLoRes:#0:#3:#<line1:#>line1
		Call CharScreen.WriteStringLoRes:#4:#24:#<line1:#>line1
		Call CharScreen.WriteString:#16:#18:#<line1:#>line1
		
		rts

		line1: .text @" go! go! \$ff"
		
	}
}