      SUBROUTINE ITFGEN
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*PURPOSE
*	TO GENERATE ITF TABLES FOR STANDARD LINEARITY CORRECTIONS
*
*METHOD
*	OBTAIN THE NUMBER OF TABLE ENTRIES AND AN OUTPUT DATASET.
*	DETERMINE THE TYPE OF LINEARITY CORRECTION REQUIRED AND THE
*	RANGE OF VALIDITY, THEN CALL STDLIN TO GENERATE THE TABLE.
*	INSERT REQUIRED ITEMS IN OUTPUT DESCRIPTOR.
*
*ARGUMENTS
*	NONE
*
*STARLINK PARAMETERS
*	NENTRY
*		NUMBER OF ENTRIES IN THE TABLE
*	OUTPUT
*		OUTPUT IMAGE DATASET FOR ITF TABLE
*	ITFTYPE
*		SPECIFIES WHICH CORRECTION IS REQUIRED
*	LOLIMIT
*		LOWER LIMIT OF TABLE VALIDITY
*	UPLIMIT
*		UPPER LIMIT OF TABLE VALIDITY
*	TITLE
*		TITLE FOR THE OUTPUT ITF TABLE
*
*CALLS
*	THIS PACKAGE:
*		GETPAR,GT2DIW,GETCMD,STDLIN,PTDSCR
*	STARLINK:
*		RDKEYC,RDKEYR,FRDATA
*
*NOTES
*	USES VAX %VAL FACILITY
*
*WRITTEN BY
*	R.F. WARREN-SMITH
*-----------------------------------------------------------------------
C
C
      CHARACTER ITFTYP*20,CVAL*1,TITLE(1)*30
C
C SET NUMBER OF SUPPORTED ITF FUNCTIONS AND MAX NUMBER OF COEFFICIENTS
C SPECIFYING THE CORRECTION
C
      PARAMETER (NFUNCT=5,MAXORD=10)
      REAL LIMITU(NFUNCT),LIMITL(NFUNCT),LOLIM,C(MAXORD)
      INTEGER TYPE(NFUNCT)
C
C SET THE TYPE OF EACH ITF CORRECTION:
C 	1: POLYNOMIAL
C	2: ELECTRONOGRAPHIC EMULSION SATURATION CORRECTION
C
      DATA TYPE/1,1,2,2,2/
C
C SET LIMITS FOR THE RANGE OF VALIDITY OF EACH CORRECTION FUNCTION
C
      DATA LIMITU/1.0E10,4095.0,1.0E20,6.0,6.0/
      DATA LIMITL/-1.0E10,4*0.0/
C
C OBTAIN REQUIRED NO. OF ENTRIES IN ITF TABLE
C
      NENTRY=100
      CALL GETPAR('NENTRY','INTEGER',1,2.0,10000.0,.TRUE.,NENTRY,RVAL,
     +IERR)
C
C OBTAIN OUTPUT IMAGE TO CONTAIN TABLE
C
      CALL GT2DIW('OUTPUT',204,.FALSE.,NENTRY,1,IPOINT,IERROU)
C
C OUTPUT IMAGE SUCESSFULLY OBTAINED:
C
      IF(IERROU.EQ.0) THEN
C
C DETERMINE WHICH ITF FUNCTION IS TO BE USED
C
	NITF=1
        CALL GETCMD('ITFTYPE',
     +  'POLYNOMIAL,PDS,ELECTRONOGRAPHIC,L4,G5.',
     +  1,NITF,ITFTYP,LITF,IERR)
C
C SET DEFAULT LOWER AND UPPER TABLE LIMITS
C
	LOLIM=LIMITL(NITF)
	UPLIM=LIMITU(NITF)
C
C IF CORRECTION IS A POLYNOMIAL:
C ------------------------------
C
	IF(TYPE(NITF).EQ.1) THEN
C
C TREAT SPECIAL POLYNOMIAL CORRECTIONS FIRST
C
	  IF(ITFTYP.EQ.'PDS') THEN
C
C SET COEFFICIENTS FOR STANDARD PDS CORRECTION
C
	    C(1)=-2.097E-3
	    C(2)=1.1207E-3
	    C(3)=1.256E-7
	    C(4)=-2.344E-11
	    DO 16 I=5,MAXORD
	      C(I)=0.0
   16	    CONTINUE
C
C NOW TREAT THE GENERAL POLYNOMIAL CORRECTION
C
	  ELSE
C
C SET DEFAULT COEFFICIENTS, THEN OBTAIN VALUES FROM THE ENVIRONMENT
C
	    DO 17 I=1,MAXORD
	      C(I)=0.0
   17	    CONTINUE
	    C(2)=1.0
	    CALL RDKEYR('CONST',.FALSE.,MAXORD,C,NVAL,ISTAT)
C
C SET DEFAULT TABLE LIMITS FOR THE GENERAL POLYNOMIAL CORRECTION
C
	    LOLIM=0.0
	    UPLIM=1.0
	  ENDIF
C
C IF THE CORRECTION IS AN ELECTRONOGRAPHIC EMULSION SATURATION CORRN.
C -------------------------------------------------------------------
C
	ELSE IF(TYPE(NITF).EQ.2) THEN
C
C TREAT THE SPECIAL CASES FIRST
C
	  IF(ITFTYP.EQ.'L4') THEN
C
C SET THE L4 FILM CONSTANT
C
	    C(1)=18.9
	  ELSE IF(ITFTYP.EQ.'G5') THEN
C
C SET THE G5 FILM CONSTANT
C
	    C(1)=9.45
C
C NOW TREAT THE GENERAL ELECTRONOGRAPHIC CORRECTION
C
	  ELSE
C
C SET THE DEFAULT, THEN OBTAIN A FILM CONSTANT FROM THE ENVIRONMENT
C
	    C(1)=18.9
	    CALL GETPAR('CONST','REAL',1,1.0E-20,1.0E20,.TRUE.,IVAL,
     +	    C(1),IERR)
C
C SET THE DEFAULT TABLE LIMITS FOR THE GENERAL CORRECTION
C
	    LIMITU(NITF)=0.99*C(1)
	    UPLIM=0.5*C(1)
	  ENDIF
	ENDIF
C
C NOW OBTAIN THE TABLE LIMITS FROM THE ENVIRONMENT, USING THE DEFAULTS
C AND CONSTRAINING THEM SO THAT THEY LIE WITHIN THE VALID RANGE OF THE
C CORRECTION SPECIFIED. ALSO ENSURE UPLIM.GE.LOLIM
C
	CALL GETPAR('LOLIMIT','REAL',1,LIMITL(NITF),LIMITU(NITF),
     +	.TRUE.,IVAL,LOLIM,IERR)
	CALL GETPAR('UPLIMIT','REAL',1,LOLIM,LIMITU(NITF),
     +	.TRUE.,IVAL,UPLIM,IERR)
C
C CALL STDLIN TO FILL THE TABLE WITH THE REQUIRED FUNCTION
C
        CALL STDLIN(TYPE(NITF),LOLIM,UPLIM,C,MAXORD,%VAL(IPOINT),
     +	NENTRY,IERR)
C
C PUT TITLE AND UPPER AND LOWER TABLE LIMITS IN OUTPUT DESCRIPTOR
C
        TITLE(1)=ITFTYP(:LITF)//' ITF TABLE'
	CALL RDKEYC('TITLE',.TRUE.,1,TITLE,NVAL,ISTAT)
	CALL PTDSCR('OUTPUT','TITLE','CHARACTER',IVAL,RVAL,
     +  TITLE(1),IERR)
	CALL PTDSCR('OUTPUT','UPLIM','REAL',IVAL,UPLIM,CVAL,IERR)
	CALL PTDSCR('OUTPUT','LOLIM','REAL',IVAL,LOLIM,CVAL,IERR)
      ENDIF
C
C RELEASE DATA AREA AND RETURN
C
      CALL FRDATA(' ',ISTAT)
      RETURN
      END
