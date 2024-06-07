db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

	!FreeRAM = $1869|!addr


	!MSGNum     = $00
	!MSGNumRAM  = $1926|!addr

MarioBelow:

	LDA #$FF
	STA !FreeRAM

	LDA #!MSGNum
	STA !MSGNumRAM

MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "<description>"
