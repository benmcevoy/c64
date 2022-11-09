#import "_prelude.lib"
#import "_charscreen.lib"
.namespace Background {
	Draw: {

		Set $d020:#GREY
		Set $d021:#DARK_GREY

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
}




	// screen character data
	*=$4000
	BackgroundCharacterData:
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6
	.byte	$D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6, $D6


	// screen color data
	*=$4400
	BackgroundColorData:
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01
	.byte	$01, $01, $07, $0D, $03, $08, $08, $0A, $0A, $02, $02, $0A, $0A, $04, $04, $0E, $0E, $06, $06, $06, $06, $0E, $0E, $03, $03, $0D, $0D, $05, $05, $0D, $0D, $03, $05, $05, $03, $03, $0D, $07, $01, $01