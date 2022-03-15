#import "_prelude.lib"
#import "_charscreen.lib"
.namespace Background {
	Draw: {

		Set $d020:#DARK_GREY
		Set $d021:#DARK_GREY
		Set CharScreen.PenColor:#GREY

		Call CharScreen.WriteString:#0:#0:#<line1:#>line1
		Call CharScreen.WriteString:#0:#1:#<line2:#>line2
		Call CharScreen.WriteString:#0:#2:#<line3:#>line3
		Call CharScreen.WriteString:#0:#3:#<line4:#>line4

		Call CharScreen.WriteString:#0:#4:#<line1:#>line1
		Call CharScreen.WriteString:#0:#5:#<line2:#>line2
		Call CharScreen.WriteString:#0:#6:#<line3:#>line3
		Call CharScreen.WriteString:#0:#7:#<line4:#>line4
		
		Call CharScreen.WriteString:#0:#8:#<line1:#>line1
		Call CharScreen.WriteString:#0:#9:#<line2:#>line2
		Call CharScreen.WriteString:#0:#10:#<line3:#>line3
		Call CharScreen.WriteString:#0:#11:#<line4:#>line4
		
		Call CharScreen.WriteString:#0:#12:#<line1:#>line1
		Call CharScreen.WriteString:#0:#13:#<line2:#>line2
		Call CharScreen.WriteString:#0:#14:#<line3:#>line3
		Call CharScreen.WriteString:#0:#15:#<line4:#>line4
		
		Call CharScreen.WriteString:#0:#16:#<line1:#>line1
		Call CharScreen.WriteString:#0:#17:#<line2:#>line2
		Call CharScreen.WriteString:#0:#18:#<line3:#>line3
		Call CharScreen.WriteString:#0:#19:#<line4:#>line4

		Call CharScreen.WriteString:#0:#20:#<line1:#>line1
		Call CharScreen.WriteString:#0:#21:#<line2:#>line2
		Call CharScreen.WriteString:#0:#22:#<line3:#>line3
		Call CharScreen.WriteString:#0:#23:#<line4:#>line4

		Call CharScreen.WriteString:#0:#24:#<line1:#>line1

		rts

		line1: .text @" \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b\$ff"
		line2: .text @"\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$ff"
		line3: .text @"\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$5a\$4b \$55\$ff"
		line4: .text @"\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$4a\$4d\$49\$4e\$ff"
	}
}