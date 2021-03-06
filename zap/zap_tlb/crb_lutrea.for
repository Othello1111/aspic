	SUBROUTINE CRB_LUTREAD
C
C+	PROGRAM LUTREAD
C
C	SENDS A COLOUR LOOKUP TABLE TO THE ARGS
C
C	OPTIONAL THRESHHOLDS AND LOGGING OF THE SCALE
C
C	PARAMETERS
C		LUT:	COLOUR LOOKUP TABLE
C		LIMITS:	RANGE IN ARGS LOOKUP TABLE ONTO WHICH LUT
C			IS TO BE MAPPED
C		LOG:    TRUE IFF A LOG SCALE IS TO BE USED
C
C     THE LAST TWO ARE CONNECTION FILE DEFAULTED
C
C	WFL RGO FEB 1981 - MODIF JULY 1981 FOR NEW ARGS ROUTINES
C
C-
	IMPLICIT INTEGER (A-Z)
      INCLUDE 'INTERIM(ERRPAR)'
      INCLUDE 'INTERIM(FMTPAR)'
	INTEGER LIMITS(2),AXIS(2)
	LOGICAL LLOG
C
C	READ THE INPUT LUT
C
10	CALL RDIMAG('LUTGR',FMT_SL,2,AXIS,NAXIS,INPTR,STATUS)
	IF (STATUS.NE.ERR_NORMAL) THEN
		CALL CNPAR('LUTGR',STATUS)
		GOTO 10
	ENDIF
	IF (NAXIS.NE.2.OR.AXIS(1).NE.3.OR.AXIS(2).NE.256) THEN
		CALL WRUSER('MUST BE 3*256 IMAGE',STATUS)
		CALL CNPAR('LUT',STATUS)
		GOTO 10
	ENDIF
C
C	NOW READ LIMITS
C
20	CALL RDKEYI('LIMITG',.FALSE.,2,LIMITS,I,STATUS)
	IF (STATUS.NE.ERR_NORMAL) THEN
		CALL CNPAR('LIMITS',STATUS)
		GOTO 20
	ENDIF
	IF (I.NE.2) THEN
		CALL WRUSER('MUST BE TWO LIMITS',STATUS)
		CALL CNPAR('LIMITS',STATUS)
		GOTO 20
	ENDIF
	DO I=1,2
		IF (LIMITS(I).LT.0.OR.LIMITS(I).GT.255) THEN
			CALL WRUSER('MUST BE IN RANGE [0,255]',STATUS)
			CALL CNPAR('LIMITS',STATUS)
			GOTO 20
		ENDIF
	ENDDO
C
C	NOW READ LOG
C
30	CALL RDKEYL('LOGG',.FALSE.,1,LLOG,I,STATUS)
	IF (STATUS.NE.ERR_NORMAL) THEN
		CALL CNPAR('LOG',STATUS)
		GOTO 30
	ENDIF
C
C	AND CALL LUTREAD2
C
	CALL LUTREAD2(%VAL(INPTR),LIMITS(1),LIMITS(2),LLOG)
	END
C
