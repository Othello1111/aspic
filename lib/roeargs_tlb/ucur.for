	.TITLE	ARGS_UCUR

;+  ARGS_UCUR
;
;   Display one of three types of cursor on the ARGS.
;   Called from ARGS_CSICUR
;
;   Original version from RGO (believed to be written by Dave King)
;   with no documentation.  Documentation here added by JAC.
;
;   See documentation for the driving subroutine args_csicur for
;   further details.
;
;   modified by J.A.Cooke/UOE/28June82
;-

	.LIBRARY	/ARGSMAC/

	ARGSDEF	UCUR,<^X400>

	ARGSINPUT
TYPE:	.BLKW	1			; cursor type
NPOS:	.BLKW	1
SIZE:	.BLKW	1
XPOS:	.BLKW	1
YPOS:	.BLKW	1
	ARGSINEND

	ARGSENTRY

	TB_INIT
	DEV	4,5
	.WORD	<^X78>			; light all lamps

	SETAV	DATA,INDEX
	SETLV	0,POSR
	SETVV	TYPE,WORK
	CMPLV	2,WORK
	BRAZE	SQ
	SDM	0
	JMR	DRAW1
SQ:
	SDM	3
DRAW1:
	JSE	DRAW

LOOP:
	TB_READ END,DEC,INC,ACC
	SETVV	TB_DELTAX,WORK
	ADDVV	TB_DELTAY,WORK
	CMPLV	0,WORK
	BRAZE	LOOP
	JSR	ERASE
	ADDVV	TB_DELTAX,XPOS
	ADDVV	TB_DELTAY,YPOS
	JSR	DRAW
	JMR	LOOP
INC:
	JSR	ERASE
	ADDLV	1,SIZE
	JSR	DRAW
	JMR	LOOP
DEC:
	SETVV	SIZE,WORK
	CMPLV	0,WORK
	BRAGT	LOOP
	JSR	ERASE
	SUBLV	1,SIZE
	JSR	DRAW
	JMR	LOOP
ACC:
 	JSR	ERASE			; removed 28Jun82
 	ZWE1	<^X0200>
 	ZDI1	512
 	JSR	DRAW+4
 	ZWE1	<^X0100>
 	JSR	DRAW
	SETVV	INDEX,MOV+6
MOV:	MOV	SIZE,YPOS,INDEX
	ADDLV	3,INDEX
	ADDLV	1,POSR
	SETVV	NPOS,WORK
	CMPVV	POSR,WORK
	BRAZE	END
	JRE	LOOP
END:
	JSR	ERASE
	DEV	4,5
	.WORD	0

	SDM	0			; restore solid vector mode

	STP


ERASE:
	ZDI	0			; ZDI zero because erasing
	JMR	DRAW+2
DRAW:
	ZDI1	256			; ZDI 256 to write in plane 8
	SETVV	TYPE,WORK
	CMPLV	2,WORK
	BRAGT	CIR
	BRAZE	DSQ

	SETVV	YPOS,YCS		; index lines
	SETVV	YPOS,YCE
	SETVV	XPOS,WORK
	SUBVV	SIZE,WORK
	SETVV	WORK,XCE
	SUBLV	10,WORK
	SETVV	WORK,XCS
	JSE	LINE
	SETVV	XPOS,WORK
	ADDVV	SIZE,WORK
	SETVV	WORK,XCS
	ADDLV	10,WORK
	SETVV	WORK,XCE
	JSE	LINE
	SETVV	XPOS,XCS
	SETVV	XPOS,XCE
	SETVV	YPOS,WORK
	SUBVV	SIZE,WORK
	SETVV	WORK,YCE
	SUBLV	10,WORK
	SETVV	WORK,YCS
	JSE	LINE
	SETVV	YPOS,WORK
	ADDVV	SIZE,WORK
	SETVV	WORK,YCS
	ADDLV	10,WORK
	SETVV	WORK,YCE
	JSE	LINE
	JMR	RET

DSQ:					; square
	SETVV	XPOS,XC
	SUBVV	SIZE,XC
	ANDVV	MASK,XC
	SETVV	YPOS,YC
	SUBVV	SIZE,YC
	ANDVV	MASK,YC
	ADDVV	XMAC,XC
	ADDVV	YMAC,YC
	SETVV	XC,XMA
	SETVV	YC,YMA
XMA:	.BLKW	1
YMA:	.BLKW	1
	ADDVV	SIZE,XC
	ADDVV	SIZE,XC
	SETVV	XC,TCX
TCX:	.BLKW	1
	SETVV	YPOS,YC
	ADDVV	SIZE,YC
	ADDVV	YDAC,YC
	SETVV	YC,YDA
YDA:	.BLKW	1
	JMR	RET

CIR:					; circle
	SETVV	XPOS,XOR+2
	SETVV	YPOS,YOR+2
XOR:	XOR	0
YOR:	YOR	0
	SETVV	SIZE,DC+2
DC:	SPC	0,0
	XOR	0
	YOR	0
RET:
	RET	0

LINE:
	SETVV	XCS,XC
	ANDVV	MASK,XC
	ADDVV	XMAC,XC
	SETVV	XC,P1X
	SETVV	YCS,YC
	ANDVV	MASK,YC
	ADDVV	YMAC,YC
	SETVV	YC,P1Y
P1X:	.BLKW	1
P1Y:	.BLKW	1
	SETVV	XCE,XC
	ANDVV	MASK,XC
	ADDVV	XMAC,XC
	SETVV	XC,P2X
	SETVV	YCE,YC
	ANDVV	MASK,YC
	ADDVV	YDAC,YC
	SETVV	YC,P2Y
P2X:	.BLKW	1
P2Y:	.BLKW	1
	RET	0

WORK:	.BLKW	1

XC:	.BLKW	1
YC:	.BLKW	1
XCS:	.BLKW	1
YCS:	.BLKW	1
XCE:	.BLKW	1
YCE:	.BLKW	1

MASK:	.WORD	<^X0FFF>
XMAC:	.WORD	<^XC000>
YMAC:	.WORD	<^XA000>
YDAC:	.WORD	<^XE000>

INDEX:	.BLKW	1
	ARGSOUTPUT
DATA:	.BLKW	768
POSR:	.BLKW	1
	ARGSOUTEND

	ARGSEND	UCUR

	.END

