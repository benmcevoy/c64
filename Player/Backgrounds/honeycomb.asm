#import "_prelude.lib"
#import "_charscreen.lib"

DrawBackground: {
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

	line1: .text @" \$6a\$d6\$65 \$6a\$d6\$65 \$6a\$d6\$65 \$6a\$d6\$65 \$6a\$d6\$65 \$6a\$d6\$65 \$6a\$d6\$65 \$6a\$d6\$65 \$6a\$d6\$65 \$6a\$d6\$65 \$ff"
	line2: .text @"\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$ff"
	line3: .text @"\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$67\$d6\$65 \$67\$d6\$ff"
	line4: .text @"\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$77\$4d\$6f\$4e\$ff"
}
