	SUBROUTINE CRB_LUTE
C
C+	PROGRAM LUTE
C
C       STARLINK PROGRAM THAT USES THE TRACKERBALL BUTTONS
C	TO ALLOW INTERACTIVE MAPPING OF A PREDEFINED COLOUR TABLE
C	ON TO AN ARGS IMAGE.
C
C	THE IMAGE SHOULD BE DISPLAYED, PREFERABLY WITH A SET OF BLOCKS
C
C      THE 4 BUTTONS ARE :-
C               1 (GREEN,LEFT) CHANGE TO NEXT COLOUR
C               2              MOVE THE BOUNDARY TO THE LEFT
C               3              MOVE THE BOUNDARY TO THE RIGHT
C               4 (RED,RIGHT)  FILL THR LUT AND EXIT
C      N.B. *** IGNORE THE CURSOR ITSELF ***
C
C	PARAMETERS:-
C		LUT	INPUT LOOKUP TABLE
C		OUTPUT	OPTIONAL OUTPUT LOOKUP TABLE
C               STEP    INCREMENT IN BOUNDARY (DEFAULTED TO 3)
C
C	WRITTEN LATE 1980 WFL - BOTCHED TO FIT NEW ARGS ROUTINES
C	IN JULY 1981
C       MODFIFIED TO USE THE BUTTONS BY K F HARTLEY IN SEPT 1981
C
	IMPLICIT INTEGER (A-Z)
      INCLUDE 'INTERIM(ERRPAR)'
      INCLUDE 'INTERIM(FMTPAR)'
	INTEGER AXIS(2),OUTLUT(3,0:255)
C
C	ASSIGN ARGS
C
	CALL SRINIT(0,.FALSE.,STATUS)
	IF (STATUS.NE.ERR_NORMAL) THEN
		GOTO 999
	ENDIF
C
C	NOW OBTAIN THE INPUT LUT
C
10	CALL RDIMAG('LUT',FMT_SL,2,AXIS,NAXIS,LUTPTR,STATUS)
	IF (STATUS.NE.ERR_NORMAL) THEN
		CALL WRUSER('BAD LOOKUP TABLE',STATUS)
		CALL FRDATA('LUT',STATUS)
		CALL CNPAR('LUT',STATUS)
		GOTO 10
	ENDIF
C
C      AND THE STEP SIZE
C
   15 CALL RDKEYI('STEP2',.FALSE.,1,STEP,I,STATUS)
      IF (STATUS.NE.ERR_NORMAL) THEN
         CALL WRUSER('BAD VALUE FOR STEP',STATUS)
         CALL CNPAR('STEP2',STATUS)
         GO TO 15
      END IF
C
C	AND CALL MAPTAB
C
	CALL MAPTAB(%VAL(LUTPTR),OUTLUT,STEP)
C
C	GIVE USER THE OPTION OF SAVING THE LOOKUP TABLE
C
20	CALL WRIMAG('OUTPUT',FMT_SL,AXIS,NAXIS,OUTPTR,STATUS)
	IF (STATUS.GT.ERR_PARNUL) THEN
		CALL CNPAR('OUTPUT',STATUS)
		GOTO 20
	ELSE IF (STATUS.EQ.ERR_NORMAL) THEN
		CALL ASP_COPCON(FMT_SL,FMT_SL,OUTLUT,%VAL(OUTPTR),
     +		3*256,STATUS)
	ENDIF
999	CALL FRDATA(' ',STATUS)
	CALL CNPAR('LUT',ISTAT)
	CALL CNPAR('OUTPUT',ISTAT)
	END
C
