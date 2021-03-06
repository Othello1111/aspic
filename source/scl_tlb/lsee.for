!
!+                         ? HELP E EXIT
!
! I INPUT AN IMAGE                      O OUTPUT AN IMAGE
!                 K KILLS (CLEARS) THE STACK
!
! # CLEARS THE SCREEN                   D DRAWS AN IMAGE CENTRALLY
!                                       T DRAWS A TRIMMED IMAGE CENTRALLY
!                                       P PLACES AN IMAGE ANYWHERE
!
! L GENERAL LUT      1>8  ZOOM ON CENTRE         B BOUNDS OR STATS
! G GREYSCALE LUT    Z    ZOOM ON DEFINED POINT  H HISTOGRAM
! N NEGATIVE LUT
! C COLOUR LUT
!
! + * /     SCALAR OPERATIONS ON IMAGES
!           NB "-" IS NOT AVAILABLE AS IT IS THE DCL "CONTINUATION"
!           CHARACTER , SO USE "+" WITH A NEGATIVE SCALAR.
! A S M R   IMAGE-IMAGE OPERATIONS
!
! F         ENHANCE FAINT DETAILS (BY HISTOGRAM EQUALIZATION)
!
      WRITE SYS$OUTPUT "TYPE '?' TO GET SOME HELP"
COMMAND:
      INQUIRE CH COMMAND
      CHAR:='F$EXTRACT(0,1,CH)'
      IF CHAR .EQS. "?" THEN GOTO HELP
      IF CHAR .EQS. "E" THEN GOTO X
      IF CHAR .EQS. "X" THEN GOTO X
      IF CHAR .EQS. "I" THEN GOTO I
      IF CHAR .EQS. "O" THEN GOTO O
      IF CHAR .EQS. "K" THEN GOTO K
      IF CHAR .EQS. "#" THEN GOTO ACLEAR
      IF CHAR .EQS. "D" THEN GOTO D
	IF CHAR .EQS. "T" THEN GOTO T
      IF CHAR .EQS. "P" THEN GOTO P
      IF CHAR .EQS. "L" THEN GOTO L
      IF CHAR .EQS. "G" THEN GOTO G
      IF CHAR .EQS. "N" THEN GOTO N
      IF CHAR .EQS. "C" THEN GOTO C
      IF CHAR .EQS. "1" THEN GOTO 1
      IF CHAR .EQS. "2" THEN GOTO 2
      IF CHAR .EQS. "3" THEN GOTO 3
      IF CHAR .EQS. "4" THEN GOTO 4
      IF CHAR .EQS. "5" THEN GOTO 5
      IF CHAR .EQS. "6" THEN GOTO 6
      IF CHAR .EQS. "7" THEN GOTO 7
      IF CHAR .EQS. "8" THEN GOTO 8
      IF CHAR .EQS. "Z" THEN GOTO Z
      IF CHAR .EQS. "B" THEN GOTO B
      IF CHAR .EQS. "H" THEN GOTO H
      IF CHAR .EQS. "F" THEN GOTO F
      IF CHAR .EQS. "+" THEN GOTO PLUS
      IF CHAR .EQS. "-" THEN GOTO MINUS
      IF CHAR .EQS. "*" THEN GOTO MULT
      IF CHAR .EQS. "/" THEN GOTO DIV
      IF CHAR .EQS. "A" THEN GOTO A
      IF CHAR .EQS. "S" THEN GOTO S
      IF CHAR .EQS. "M" THEN GOTO M
      IF CHAR .EQS. "R" THEN GOTO R
      IF CHAR .EQS. "Q" THEN GOTO X
      IF CHAR .EQS. " " THEN GOTO COMMAND
      WRITE SYS$OUTPUT "Illegal key - try again"
      GOTO COMMAND
HELP:
      HELP LSEE
      GOTO COMMAND
ACLEAR:
      ACLEAR
      GOTO COMMAND
I:
      PUSH
      GOTO COMMAND
O:
      STORE
      GOTO COMMAND
K:
      CLEAR STACK
      GOTO COMMAND
D:
      ADISP $ = = = =
      GOTO COMMAND
T:
	ADISP $ = =
	GOTO COMMAND
P:
      ADISP $ PVLO= PVHI=
      GOTO COMMAND
L:
      LUTREAD
      GOTO COMMAND
G:
      LUTREAD DSCL_BDFDIR:GLUT
      GOTO COMMAND
N:
      LUTREAD DSCL_BDFDIR:NLUT 
      GOTO COMMAND
C:
      LUTREAD DSCL_BDFDIR:CLUT
      GOTO COMMAND
B:
      STATS $
      GOTO COMMAND
H:
      WRHIST INPUT=$ OUTPUT= NUMBIN=16
      GOTO COMMAND
F:
      HISTMATCH INPUT=$ OUTPUT=$ OUTLIMS=0,255 INLIMS=0,0
      GOTO COMMAND
Z:
      AZOOM
      GOTO COMMAND
1:  
      AZOOM = = 1 1
      GOTO COMMAND
2:
      AZOOM = = 2 2
      GOTO COMMAND
3:
      AZOOM = = 4 4
      GOTO COMMAND
4:
      AZOOM = = 6 6
      GOTO COMMAND
5:
      AZOOM = = 8 8
      GOTO COMMAND
6:
      AZOOM = = 10 10
      GOTO COMMAND
7:
      AZOOM = = 12 12
      GOTO COMMAND
8:
      AZOOM = = 14 14
      GOTO COMMAND
A:
      ADD IN1=$ OUT=$
      GOTO COMMAND
S:
      SUB IN1=$ OUT=$
      GOTO COMMAND
M:
      MULT IN1=$ OUT=$
      GOTO COMMAND
R:
      DIV IN1=$ OUT=$
      GOTO COMMAND
PLUS:
      CADD IN=$ OUT=$
      GOTO COMMAND
MINUS:
      CSUB IN=$ OUT=$
      GOTO COMMAND
MULT:
      CMULT IN=$ OUT=$
      GOTO COMMAND
DIV:
      CDIV IN=$ OUT=$
      GOTO COMMAND
X:
      EXIT
