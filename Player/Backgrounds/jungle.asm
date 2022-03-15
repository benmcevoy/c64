#import "_prelude.lib"
.namespace Background {
	Draw: {

		Set $d020:#DARK_GREY
		Set $d021:#LIGHT_GREEN

		// this code generated by http://petscii.krissz.hu/
		// screen and color pointer low bytes
		lda #$00
		sta $fd
		sta $f7
		// screen pointer high byte $0400
		lda #$04
		sta $fe
		// colorpointer high byte $d800
		lda #$d8
		sta $f8

		lda #<BackgroundCharacterData
		sta $fb
		lda #>BackgroundCharacterData
		sta $fc

		lda #<BackgroundColorData
		sta $f9
		lda #>BackgroundColorData
		sta $fa

		ldx #$00
		ldy #$00
		lda ($fb),y
		sta ($fd),y
		lda ($f9),y
		sta ($f7),y
		iny
		bne *-9

		inc $fc
		inc $fe
		inc $fa
		inc $f8

		inx
		cpx #$04
		bne *-24

		rts
	}

	// attempt to copy http://www.polyducks.com/assets/boko-woods-large.png

	// screen character data
	*=$2800
	BackgroundCharacterData:
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $EF, $EF, $EF, $EF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $D1, $A0, $A0, $69, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $EF, $EF, $EF, $EF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $D1, $A0, $A0, $69, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $EF, $EF, $EF, $EF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $D1, $A0, $A0, $69, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $EF, $EF, $EF, $EF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $68, $68, $20, $20, $68, $68, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $A0, $A0, $A0, $DF, $20, $20, $20, $20, $20, $20, $20, $66, $66, $66, $66, $66, $66, $66, $66, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $5F, $A0, $DF, $20, $20, $20, $20, $20, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $A0, $DF, $20, $A0, $A0, $DF, $20, $20, $20, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $3D, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $D7, $A0, $A0, $20, $5F, $A0, $A0, $DF, $E9, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $D7, $A0, $20, $20, $20, $5F, $A0, $A0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $A0, $A0, $DF, $20, $20, $20, $A0, $A0, $E9, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $D7, $A0, $A0, $D7, $A0, $20, $20, $A0, $A0, $A0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $A0, $A0, $A0, $A0, $DF, $20, $A0, $A0, $A0, $20, $20, $20, $55, $51, $20, $20, $20, $55, $49, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $D7, $A0, $A0, $A0, $D7, $A0, $20, $A0, $DF, $20, $20, $20, $20, $4A, $73, $51, $20, $20, $EC, $FB, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $A0, $D7, $A0, $A0, $A0, $20, $A0, $A0, $A0, $A0, $DF, $20, $DF, $6B, $4B, $20, $20, $EC, $FB, $20, $66, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $5F, $69, $5F, $69, $5F, $69, $5F, $A0, $A0, $5F, $A0, $A0, $A0, $A0, $4B, $E9, $20, $66, $A0, $A0, $20, $66, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $E6, $DF, $E9, $69, $DD, $DD, $C8, $A0, $A0, $E6, $A0, $A0, $D7, $A0, $A0, $A0, $A0, $66, $A0, $A0, $20, $66, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $E6, $D7, $69, $E6, $EB, $CB, $C8, $A0, $69, $20, $20, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $A0, $DF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $A0, $CA, $C3, $F3, $A0, $C8, $A0, $E9, $67, $67, $20, $20, $20, $69, $6F, $6F, $6F, $6F, $6F, $5F, $E6, $E9, $A0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $A0, $A0, $A0, $DD, $C8, $C8, $A0, $A0, $67, $67, $5F, $69, $5F, $20, $A0, $D3, $A0, $A0, $A0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $A0, $A0, $A0, $A0, $DD, $C8, $C8, $A0, $A0, $67, $67, $20, $E9, $DF, $E9, $A0, $A0, $A0, $A0, $D3, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
		.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20

	// screen color data
	*=$2be8
	BackgroundColorData:
		.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $01, $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $01, $01, $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $01, $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $01, $01, $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $01, $01, $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $01, $01, $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $01, $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $05, $05, $05, $05, $0E, $0E, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $0E, $05, $05, $05, $0E, $0E, $0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $0E, $05, $0E, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $0E, $0E, $0E, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $0E, $0E, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $05, $05, $0E, $0E, $0E, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $0E, $05, $05, $05, $05, $0E, $0E, $05, $05, $05, $0E, $0E, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $05, $05, $05, $0E, $0E, $01, $01, $0E, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $01, $01, $01, $0E, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $01, $01, $01, $0E, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $05, $05, $05, $05, $05, $05, $05, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
		.byte	$0E, $00, $0E, $0E, $0E, $0E, $0E, $05, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
}
