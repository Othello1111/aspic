!+
!      DSCL PROCEDURE *** USMASK ***
!
!      WRITTEN BY K F HARTLEY AT RGO ON 21/7/81
!
!      IT PERFORMS "UNSHARP MASKING" ON AN INPUT STARLINK 2D IMAGE
!
!      THE SEQUENCE OF OPERATIONS IS AS FOLLOWS
!         FIRST CONVOLVE THE IMAGE WITH A 5X5 GAUSSIAN OF SIGMA 1
!         THEN SUBTRACT THIS FROM THE ORIGINAL
!         FINALLY EQUALIZE THE HISTOGRAM OF THE OUTPUT IMAGE
!         INTO THE RANGE 0 TO 255
!
!      IT MAY BE INVOKED (WHEN RUNNING DSCL) AS
!
!      USMASK INIMAGE OUTIMAGE
!
!      OR
!
!      USMASK   (WHEN IT WILL PROMPT FOR THE TWO FILES)
!
!      OR
!
!      USMASK/ECHO [INIMAGE OUTIMAGE]      TO SEE WHAT IS GOING ON
!
!      ALL THE PROGRAMS ARE STANDARD ASPIC ONES.
!
!
PUSH 'P1'
DUPE
SMOOTH INPUT=$ OUTPUT=$ BOXSIZ=5 TYPE=GAUSS SIGMA=1.0
SWAP
SUB $ $ $
HISTMATCH $ $ INLIMS= NUMBIN=
STORE 'P2'