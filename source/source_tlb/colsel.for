	PROGRAM COLSEL
C
C	PROGRAM COLSEL
C
C+	STARLINK PROGRAM TO SELECT COLOURS FROM A PALETTE (WHICH WILL
C	BE DISPLAYED ON THE ARGS) AND TO WRITE A LOOKUP TABLE
C	WITH THEM EQUALLY SPACED (NORMALLY FOLLOWED BY A RUN OF A
C	PROGRAM THAT MATCHES THIS EQUALLY SPACED LUT TO SOME REAL DATA)
C
C	WFL RGO DEC 1980 - MODIF JULY 1981 FOR NEW ARGS ROUTINES
C
C	PARAMETERS:-
C			INPUT (DEFAULTED TO STANDARD)	LOOKUP TABLE
C			OUTPUT	OUTPUT LUT
C			SELECT	SELECTED COLOURS FROM PALETTE
C				(UP TO 32 - THOSE AFTER THE 32ND WILL
C				BE IGNORED)
C-
	IMPLICIT INTEGER (A-Z)
      INCLUDE 'INTERIM(ERRPAR)'
      INCLUDE 'INTERIM(FMTPAR)'
	INTEGER AXIS(2)
C
C	NOW READ THE INPUT LOOKUP TABLE
C
10	CALL RDIMAG('INPUT',FMT_SL,2,AXIS,NAXIS,INPTR,STATUS)
	IF (STATUS.NE.ERR_NORMAL) THEN
		CALL CNPAR('INPUT',STATUS)
		GOTO 10
	ENDIF
	IF (NAXIS.NE.2.OR.AXIS(1).NE.3.OR.AXIS(2).NE.256) THEN
		CALL WRUSER('MUST BE 3*256 IMAGE',STATUS)
		CALL CNPAR('INPUT',STATUS)
		GOTO 10
	ENDIF
C
C	NOW GET THE OUTPUT LOOKUP TABLE
C
20	CALL WRIMAG('OUTPUT',FMT_SL,AXIS,NAXIS,OUTPTR,STATUS)
	IF (STATUS.NE.ERR_NORMAL) THEN
		CALL CNPAR('OUTPUT',STATUS)
		GOTO 20
	ENDIF
C
C	COLSEL2 DOES THE REST (NB IT ISSUES THE RDKEYI FOR 'SELECT')
C
	CALL COLSEL2(%VAL(INPTR),%VAL(OUTPTR))
C
C	FREE DATA AND EXIT
C
	CALL FRDATA(' ',STATUS)
	CALL EXIT
	END
C
	SUBROUTINE COLSEL2(INPUT,OUTPUT)
C
C	ROUTINE TO:-
C	1	DISPLAY COLOURED PALETTE ON THE ARGS WITH COLOURS FROM
C		'INPUT'
C	2	INVITE THE USER TO SELECT SOME COLOURS
C	3	DISPLAY THE SELECTED COLOURS ON THE ARGS
C	4	WRITE THE SELECTED COLOURS (EQUALLY SPACED) TO 'OUTPUT'
C
C	ARGUMENTS:-
C		INPUT	INPUT LOOKUP TABLE
C		OUTPUT	OUTPUT LOOKUP TABLE
C
C	PARAMETER:-
C		SELECT	SELECTED COLOURS (UP TO 32)
C
C	WFL RGO DEC 1980
C
      INCLUDE 'INTERIM(ERRPAR)'
	PARAMETER (MAXSELECT=32)
	INTEGER INPUT(3,0:255),OUTPUT(3,0:255),SELECT(0:MAXSELECT-1),
     +		STATUS
	CHARACTER C*2
C
C	FIRST OF ALL, ASSIGN THE ARGS
C
	CALL SRINIT(0,.FALSE.,STATUS)
	IF (STATUS.NE.0) THEN
		CALL WRUSER('NO ARGS',STATUS)
		GOTO 999
	ENDIF
C
C	NOW CLEAR THE SCREEN
C
	CALL SRBLOC(0,0,511,511,0)
C
C	ENSURE ZOOM FACTORS ARE BOTH UNITY
C
	CALL IZOOM(256,256,1,1)
C
C	AND LOAD THE LOOKUP TABLE (ENSURE LEVEL 0 IS BLANK)
C
	CALL SRCOL1(0,0,0,0)
	CALL SRCOLS(1,255,INPUT)
C
C	NOW PUT UP THE PALETTE BOXES
C
	DO I=0,3
		KMIN=466-96*I
		KMAX=KMIN+27
		DO J=0,15
			LMIN=2+32*J
			LMAX=LMIN+27
			CALL SRBLOC(LMIN,KMIN,LMAX,KMAX,64*I+4*J+2)
		ENDDO
	ENDDO
C
C	AND LABEL THEM WITH NUMBERS (1-64)
C
	CALL ARGS_S1('SSB',13)
	CALL ARGS_S1('SSZ',0)
	CALL ARGS_S1('ZDI',255)
	DO I=0,63
		WRITE (C,'(I2)') I+1
		CALL ARGS_S1('XMA',32*MOD(I,16)+7)
		CALL ARGS_S1('YMA',96*((63-I)/16)+144)
		DO J=1,2
			CALL ARGS_S1('JSI',ICHAR(C(J:J)))
		ENDDO
	ENDDO
	CALL SRSEND
C
C	THE USER CAN NOW SELECT HIS COLOURS - THEN DISPLAY AND SAVE THEM
C
10	CALL RDKEYI('SELECT',.FALSE.,MAXSELECT,SELECT,NSELECT,STATUS)
	IF (STATUS.NE.ERR_NORMAL) THEN
		CALL CNPAR('SELECT',STATUS)
		GOTO 10
	ENDIF
	DO I=0,NSELECT-1
		IF (SELECT(I).LT.1.OR.SELECT(I).GT.64) THEN
			CALL WRUSER('ALL MUST BE IN RANGE [1,64]',STATUS)
			CALL CNPAR('SELECT',STATUS)
			GOTO 10
		ENDIF
	ENDDO
	DO I=0,255
		J=4*SELECT((NSELECT*I)/256)-2
		CALL SRBLOC(2*I,64,2*I+1,127,J)
		DO K=1,3
			OUTPUT(K,I)=INPUT(K,J)
		ENDDO
	ENDDO
C
C	THAT'S IT
C
999	RETURN
	END