	!MSGOpenRam	=	$1869|!addr
	!ControlBox	=	$186A|!addr
	!HDMAChannel	=	7
	!Delay		=	$08	;Per frame. should $01~$10

	!SFXNum		=	$22
	!SFXBank	=	$1DFC

	!MSGNumRAM	=	$1926|!addr
nml:
	RTL
init:

	LDA #$00	;Layer 3 scroll = H: None and V: None
	STA $145F|!addr	;

	REP #$20 
	LDA #$0000
	STA $22		;Layer 3 X to $0000
	LDA #$0100
	STA $24		;Layer 3 Y to $0100
	SEP #$20

	RTL

main:

	LDA $13D4|!addr		;When paused
	BEQ +
	JMP Return		;Don't run
+


	LDA !MSGOpenRam
	BNE .GotoTrigger

	STZ $9D			;Unfreeze
	STZ $13FB|!addr		;Unfreeze
	STZ $13D3|!addr		;Enable pause

	JMP Return

.GotoTrigger

	LDA !MSGOpenRam
	CMP #$01
	BNE +
	JMP .CloseWindow
+
	LDA !ControlBox
	CMP #$14
	BEQ .OpenMSG

	LDA !MSGOpenRam
	CMP #$FF-!Delay
	BEQ .OpenWindow

	DEC !MSGOpenRam
	JMP Return

.OpenWindow

	JSR Freeze

	LDA #!SFXNum		;Message Sound
	STA !SFXBank|!addr		;

	LDA #$01<<!HDMAChannel    	;\  
	TSB $0D9F|!addr           	;/  enable HDMA channel X

	INC !ControlBox		;ControlBox + 1

	JSR Clip
	JSR Windowing

	JMP Return

.OpenMSG

	JSR Freeze

	LDA !MSGNumRAM
	CMP #$01
	BNE +
	JMP .Msg01
+
	LDA !MSGNumRAM
	CMP #$02
	BNE +
	JMP .Msg02
+
	REP #$20 
	LDA #$0000
	STA $22		;Layer 3 X to $0000
	LDA #$0000
	STA $24		;Layer 3 Y to $0000
	SEP #$20
	JMP .Skip01
.Msg01
	REP #$20 
	LDA #$0100
	STA $22		;Layer 3 X to $0100
	LDA #$0000
	STA $24		;Layer 3 Y to $0000
	SEP #$20
	JMP .Skip01

.Msg02
	REP #$20 
	LDA #$0100
	STA $22		;Layer 3 X to $0100
	LDA #$0100
	STA $24		;Layer 3 Y to $0100
	SEP #$20
	JMP .Skip01

.Skip01

	LDA $16					; \ If the player has pressed the BYET button...
	AND #%11110000				; |
	BNE .Press				; /

	LDA $18					; \ If the player has pressed the AX-- button...
	AND #%11000000				; |
	BEQ Return
	
.Press
	LDA #$01
	STA !MSGOpenRam
	JMP Return

.CloseWindow

	JSR Freeze

	LDA !ControlBox
	BEQ .SetToZero

	JSR Windowing

	DEC !ControlBox

	REP #$20 
	LDA #$0000
	STA $22		;Layer 3 X to $0000
	LDA #$0100
	STA $24		;Layer 3 Y to $0100
	SEP #$20

	JMP Return

.SetToZero
	LDA #$01<<!HDMAChannel    	;\  
	TRB $0D9F|!addr           	;/  disable HDMA channel X
	STZ !MSGOpenRam

Return:
	RTL

Freeze:
	LDA #$01		;\Freezing
	STA $9D			;/
	LDA #$01		;\Freezing
	STA $13FB|!addr		;/
	LDA #$01		;
	STA $13D3|!addr		;Disable Pause

	RTS

Clip:


	LDA #%00100010		;\  Clip to black: Inside, Prevent colot math: Inside
	TSB $44     		; | Add subscreen instead of fixed color: True
	LDA #%11010000		; |
	TRB $44     		;/ 

	LDA #%00100000 		; Backdrop for color math
	STA $40     		; mirror of $2131

	LDA #%00100010		;\  values for enabling/inverting BG1/BG2 on window 1/2
	STA $41     		; | mirror of $2123
	LDA #%00100000		; | values for enabling/inverting BG3/BG4 on window 1/2
	STA $42     		; | mirror of $2124
	LDA #%00100010		; | values for enabling/inverting OBJ/Color on window 1/2
	STA $43     		; | mirror of $2125
	            		; | Window 1 enabled on BG1, BG2, BG4, OBJ, Color
	            		; | Window 2 enabled on BG1, BG2, BG4, OBJ, Color
	RTS

Windowing:

	LDA !ControlBox 
	ASL : TAX
	JSR.w (.Windows,x)
	RTS

.Windows
    dw .Win00
    dw .Win01
    dw .Win02
    dw .Win03
    dw .Win04
    dw .Win05
    dw .Win06
    dw .Win07
    dw .Win08
    dw .Win09
    dw .Win0A
    dw .Win0B
    dw .Win0C
    dw .Win0D
    dw .Win0E
    dw .Win0F
    dw .Win10
    dw .Win11
    dw .Win12
    dw .Win13
    dw .Win14





.Win00		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable00        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable00>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win01		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable01        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable01>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================	
;===============================		
.Win02		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable02        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable02>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win03		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable03        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable03>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win04		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable04        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable04>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win05		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable05        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable05>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win06		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable06        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable06>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win07		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable07        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable07>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win08		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable08        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable08>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win09		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable09        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable09>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win0A		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable0A        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable0A>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win0B		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable0B        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable0B>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win0C		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable0C        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable0C>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win0D		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable0D        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable0D>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win0E		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable0E        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable0E>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win0F		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable0F        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable0F>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win10		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable10        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable10>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win11		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable11        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable11>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win12		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable12        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable12>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win13		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable13        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable13>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		
;===============================		
.Win14		
	REP #$20                  	;\  Get into 16 bit mode
	LDA #$2601                	; | Register $2126 using mode 1
	STA $4300+(!HDMAChannel*16)	; | 43X0 = transfer mode, 43X1 = register
		
	LDA #WindowTable14        	; | High byte and low byte of table addresse.
	STA $4302+(!HDMAChannel*16)	; | 43X2 = low byte, 43X3 = high byte
	SEP #$20                  	; | Back to 8 bit mode
	LDA.b #WindowTable14>>16   	; | Bank byte of table addresse.
	STA $4304+(!HDMAChannel*16)	;/  = bank byte
		
	RTS                       	; Return
;===============================		


WindowTable00:
   db $80 : db $FF, $00      ; 
   db $60 : db $FF, $00      ; 
   db $00 

WindowTable01:
   db $4D : db $FF, $00
   db $04 : db $7B, $84
   db $80 : db $FF, $00
   db $0F : db $FF, $00
   db $00

WindowTable02:
   db $4B : db $FF, $00
   db $08 : db $77, $88
   db $80 : db $FF, $00
   db $0D : db $FF, $00
   db $00

WindowTable03:
   db $49 : db $FF, $00
   db $0C : db $73, $8C
   db $80 : db $FF, $00
   db $0B : db $FF, $00
   db $00

WindowTable04:
   db $47 : db $FF, $00
   db $10 : db $6F, $90
   db $80 : db $FF, $00
   db $09 : db $FF, $00
   db $00

WindowTable05:
   db $45 : db $FF, $00
   db $14 : db $6B, $94
   db $80 : db $FF, $00
   db $07 : db $FF, $00
   db $00

WindowTable06:
   db $43 : db $FF, $00
   db $18 : db $67, $98
   db $80 : db $FF, $00
   db $05 : db $FF, $00
   db $00

WindowTable07:
   db $41 : db $FF, $00
   db $1C : db $63, $9C
   db $80 : db $FF, $00
   db $03 : db $FF, $00
   db $00

WindowTable08:
   db $3F : db $FF, $00
   db $20 : db $5F, $A0
   db $80 : db $FF, $00
   db $01 : db $FF, $00
   db $00

WindowTable09:
   db $3D : db $FF, $00
   db $24 : db $5B, $A4
   db $7F : db $FF, $00
   db $00


WindowTable0A:
   db $3B : db $FF, $00
   db $28 : db $58, $A8
   db $7D : db $FF, $00
   db $00


WindowTable0B:
   db $39 : db $FF, $00
   db $2C : db $54, $AB
   db $7B : db $FF, $00
   db $00


WindowTable0C:
   db $37 : db $FF, $00
   db $30 : db $50, $AF
   db $79 : db $FF, $00
   db $00


WindowTable0D:
   db $35 : db $FF, $00
   db $34 : db $4C, $B3
   db $77 : db $FF, $00
   db $00


WindowTable0E:
   db $33 : db $FF, $00
   db $38 : db $48, $B7
   db $75 : db $FF, $00
   db $00


WindowTable0F:
   db $31 : db $FF, $00
   db $3C : db $44, $BB
   db $73 : db $FF, $00
   db $00


WindowTable10:
   db $2F : db $FF, $00
   db $40 : db $40, $BF
   db $71 : db $FF, $00
   db $00


WindowTable11:
   db $2D : db $FF, $00
   db $44 : db $3C, $C3
   db $6F : db $FF, $00
   db $00


WindowTable12:
   db $2B : db $FF, $00
   db $48 : db $38, $C7
   db $6D : db $FF, $00
   db $00


WindowTable13:
   db $29 : db $FF, $00
   db $4C : db $34, $CB
   db $6B : db $FF, $00
   db $00


WindowTable14:
   db $27 : db $FF, $00
   db $50 : db $30, $CF
   db $69 : db $FF, $00
   db $00

