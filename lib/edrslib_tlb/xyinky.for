      SUBROUTINE XYINKY(ID,X,Y,MAXLEN,LEN,IERR)
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*PURPOSE
*	TO INTERACTIVELY OBTAIN A SET OF X,Y POSITIONS AND ATTACHED
*	CHARACTER IDENTIFIERS FROM THE KEYBOARD AND INSERT THEM IN
*	A LIST OF POSITIONS
*
*METHOD
*	OBTAIN X,Y AND IDENTIFIER FROM THE KEYBOARD AS CHARACTER STRINGS
*	USING STARLINK PARAMETER XYPOSN. IF A NULL IS GIVEN, RETURN WITH
*	THE CURRENT LIST, OTHERWISE CONVERT THE X AND Y POSITIONS TO
*	REAL NUMBERS, CHECKING AND RE-PROMPTING FOR INPUT IF AN ERROR
*	OCCURS. IF THE IDENTIFIER IS BLANK, CREATE ONE USING THE CURRENT
*	COUNT OF BLANK IDENTIFIERS ENTERED. IF THE IDENTIFIER IS IN THE
*	FORM #N, RESET THE BLANK COUNTER TO N. OTHERWISE USE THE
*	IDENTIFIER AS IT STANDS AND ADD IT TO THE LIST.
*	  IF THE LIST IS FULL, CALL XYPRGG TO REMOVE ANY DUPLICATE
*	ENTRIES...IF STILL FULL RETURN. IN ANY CASE
*	CALL XYPRGG BEFORE RETURNING.
*
*ARGUMENTS
*	ID (IN/OUT)
*	BYTE(20,MAXLEN)
*		A LIST OF 20 BYTE ASCII IDENTIFIERS
*	X,Y (IN/OUT)
*	REAL(MAXLEN)
*		LISTS OF X,Y POSITIONS
*	MAXLEN (IN)
*	INTEGER
*		THE MAXIMUM NUMBER OF ENTRIES WHICH CAN BE HELD IN THE
*		LISTS
*	LEN (IN/OUT)
*	INTEGER
*		ON ENTRY, GIVES THE NUMBER OF ENTRIES ALREADY IN THE
*		LISTS ID,X AND Y. ON EXIT, GIVES THE NUMBER OF ENTRIES
*		IN THE OUTPUT LISTS.
*	IERR (OUT)
*	INTEGER
*		ERROR FLAG: ZERO FOR SUCCESS
*		1: LEN .GT. MAXLEN ON ENTRY
*
*STARLINK PARAMETERS
*	XYPOSN
*		USED TO PROMP USER TO ENTER X,Y AND ID (CHARACTER
*		STRINGS) FOR NEXT LIST ENTRY. NULL TERMINATES INPUT
*		SEQUENCE.
*	WHAT/ERROR/
*		ACCESSED IF THE INPUT FROM XYPOSN CANNOT BE CONVERTED
*		TO REAL NUMBER POSITIONS.
*
*CALLS
*	THIS PACKAGE:
*		LBGONE,XYPRGG
*	STARLINK:
*		RDKEYC,CNPAR,CTOR,WRERR,CTOI
*
*NOTES
*	USES BYTE ARRAYS
*
*WRITTEN BY
*	R.F. WARREN-SMITH
*-----------------------------------------------------------------------
C
C
      CHARACTER IDBUF*20,INBUF(3)*80
      LOGICAL EXIT
      REAL X(MAXLEN),Y(MAXLEN)
      BYTE ID(20,MAXLEN)
C
C CHECK ARGUMENTS
C
      IF(MAXLEN.LT.LEN) THEN
	IERR=1
      ELSE
	IERR=0
C
C CHECK LENGTH OF LIST IS NOT -VE, INITIALLISE BLANK IDENTIFIER
C COUNT
C
        LEN=MAX(0,LEN)
        NBLANK=1
C
C LOOP WHILE EXIT HAS NOT BEEN SET AND LIST HAS NOT OVERFLOWED
C ------------------------------------------------------------
C
	EXIT=.FALSE.
   67   IF((.NOT.EXIT).AND.(LEN.LE.MAXLEN)) THEN
C
C SET DEFAULT INPUT TO BLANKS AND OBTAIN THE INPUT STRING CONTAINING
C THE X,Y POSITION AND IDENTIFIER
C
   66   INBUF(1)=' '
        INBUF(2)=' '
        INBUF(3)=' '
	CALL RDKEYC('XYPOSN',.FALSE.,3,INBUF,NVAL,IEND)
C
C CANCEL INPUT PARAMETER FOR USE NEXT TIME
C
	CALL CNPAR('XYPOSN',ISTAT)
C
C INTERPRET USER INPUT LINE
C
          CALL LBGONE(INBUF(1))
	  CALL LBGONE(INBUF(2))
	  CALL LBGONE(INBUF(3))
          CALL CTOR(INBUF(1),X(LEN+1),IOERR1)
          CALL CTOR(INBUF(2),Y(LEN+1),IOERR2)
          IDBUF=INBUF(3)
          IOERR=MAX(IOERR1,IOERR2)
C
C IF A NULL ENTRY WAS MADE, SET IOERR TO INDICATE END OF INPUT
C
          IF(IEND.NE.0) IOERR=-1
C
C IF INPUT COULD NOT BE READ, GIVE MESSAGE AND PROMPT FOR NEW INPUT
C
	  IF(IOERR.GT.0) THEN
	      CALL WRERR('WHAT')
	      GO TO 66
C
C END OF INPUT.. SET EXIT
C
	  ELSE IF(IOERR.LT.0) THEN
	    EXIT=.TRUE.
	  ELSE
C
C OTHERWISE INPUT IS OK. TEST IF LIST OF INPUT HAS OVERFLOWED
C
              IF(LEN.GE.MAXLEN) THEN
		EXIT=.TRUE.
	      ELSE
C
C INCREMENT LIST LENGTH IF IT WILL NOT OVERFLOW
C
		LEN=LEN+1
		EXIT=.FALSE.
C
C TREAT THE SPECIAL CASES OF BLANK IDENTIFIER OR '#N'
C ----------------------------------------------------
C
C REMOVE LEADING BLANKS FROM IDENTIFIER AND TEST IF ALL BLANK
C
		CALL LBGONE(IDBUF)
		IF(IDBUF.EQ.' ') THEN
C
C IF BLANK, GENERATE AN IDENTIFIER FROM THE BLANK COUNT IN THE FORM
C '#N' AND INCREMENT THE BLANK COUNT
C
		  WRITE(IDBUF,'(I20)')NBLANK
		  IDBUF(1:1)='#'
	          CALL LBGONE(IDBUF(2:))
		  NBLANK=NBLANK+1
C
C IF ID STARTS WITH # THEN SEE IF IT IS FOLLOWED BY AN INTEGER
C IF SO, RESET NBLANK AND PUT ID IN #N STANDARD FORM
C RESET NBLANK SO THAT SUBSEQUENT BLANK IDENTIFIERS ARE CONVERTED TO
C SEQUENTIALLY NUMBERED '#N' FORM
C
		ELSE IF(IDBUF(1:1).EQ.'#') THEN
		  CALL CTOI(IDBUF(2:),NB,ISTATB)
		  IF(ISTATB.EQ.0) THEN
		    NBLANK=NB+1
		    WRITE(IDBUF,'(I20)')NB
		    IDBUF(1:1)='#'
		    CALL LBGONE(IDBUF(2:))
		  ENDIF
		ENDIF
C
C PUT ID INTO IDENTIFIER LIST
C
		DO 16 I=1,20
		  ID(I,LEN)=ICHAR(IDBUF(I:I))
   16		CONTINUE
	      ENDIF
	    ENDIF
C
C IF LIST IS FULL, CALL XYPRGG TO REMOVE DUPLICATE ENTRIES
C
	    IF(LEN.GE.MAXLEN) THEN
	      CALL XYPRGG(X,Y,ID,LEN,NSAVE,IERR)
	      LEN=NSAVE
	    ENDIF
C
C IF LIST IS STILL FULL, RETURN
C
	    IF(LEN.GE.MAXLEN) THEN
	      EXIT=.TRUE.
	    ENDIF
	    GO TO 67
	  ENDIF
C
C PURGE THE LIST BEFORE LEAVING
C
          IF(LEN.GT.1) THEN
	    CALL XYPRGG(X,Y,ID,LEN,NSAVE,IERR)
	    LEN=NSAVE
	  ENDIF
	ENDIF
	RETURN
	END