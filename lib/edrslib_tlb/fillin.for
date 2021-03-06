      SUBROUTINE FILLIN(IA,NPIX,NLINES,INVALA,SIZE,ILEVEL,CNGMAX,CNGRMS,
     +			NITER,SCALE,IB,NBAD,DSUM,WTSUM,DLAST,WTLAST)
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*PURPOSE
*	TO REPLACE ALL THE INVALID PIXELS IN AN IMAGE WITH A SOLUTION
*	OF LAPLACE'S EQUATION WHICH MATCHES THE VALID DATA IN THE IMAGE
*	AT THE EDGES OF THE INVALID REGIONS. THIS SOLUTION HAS ZERO
*	GRADIENT NORMAL TO ANY IMAGE EDGES WHICH IT MEETS.
*
*METHOD
*	ITERATE, REPLACING EACH INVALID PIXEL WITH A WEIGHTED MEAN OF 
*	ITS VALID NEIGHBOURS IN THE SAME ROW AND COLUMN.
*	THE WEIGHTS DECREASE EXPONENTIALLY WITH A SCALE LENGTH 'SIZE'
*	AND GO TO ZERO AFTER THE FIRST VALID PIXEL IS ENCOUNTERED.
*	THE LENGTH 'SIZE' IS REDUCED BY A FACTOR 2 WHENEVER THE MAX.
*	ABSOLUTE CHANGE IN AN ITERATION IS AT LEAST A FACTOR 4 LESS THAN
*	THE MAX. ABSOLUTE CHANGE OBTAINED SINCE THE CURRENT SCALE LENGTH
*	WAS FIRST USED. ITERATIONS STOP AFTER NITER HAVE BEEN PERFORMED.
*
*ARGUMENTS
*	IA (IN)
*	INTEGER*2(NPIX,NLINES)
*		THE INPUT IMAGE
*	NPIX,NLINES (IN)
*	INTEGER
*		THE DIMENSIONS OF IA
*	INVALA (IN)
*	INTEGER
*		INVALID PIXEL FLAG FOR IA
*	SIZE (IN/OUT)
*	REAL
*		INITIAL SMOOTHING SIZE ON ENTRY. RETURNS THE FINAL
*		SMOOTHING SIZE
*	ILEVEL (IN)
*	INTEGER
*		INTERACTION LEVEL: CONTROLS PRINTING OF RESULTS
*	CNGMAX (OUT)
*	REAL
*		MAXIMUM ABSOLUTE CHANGE IN OUTPUT VALUES WHICH OCCURRED
*		IN THE FINAL ITERATION
*	CNGRMS (OUT)
*	REAL
*		RMS CHANGE IN OUTPUT VALUES WHICH OCCURRED IN THE LAST
*		ITERATION
*	NITER (IN)
*	INTEGER
*		THE NUMBER OF ITERATIONS REQUIRED
*	SCALE (IN)
*	REAL
*		SCALE FACTOR FOR IMAGE IA
*	IB (OUT)
*	INTEGER*2(NPIX,NLINES)
*		THE OUTPUT IMAGE
*	NBAD (OUT)
*	INTEGER
*		THE NUMBER OF INVALID PIXELS REPLACED
*	DSUM,WTSUM (WORKSPACE)
*	REAL(NPIX,NLINES)
*		INTERMEDIATE STORAGE
*	DLAST,WTLAST (WORKSPACE)
*	REAL(NPIX)
*		INTERMEDIATE STORAGE
*
*CALLS
*	THIS PACKAGE:
*		LBGONE
*	STARLINK:
*		WRUSER
*
*NOTES
*	USES INTEGER*2 ARRAYS
*
*WRITTEN BY
*	R.F. WARREN-SMITH
*-----------------------------------------------------------------------
C
C
      INTEGER*2 IA(NPIX,NLINES),IB(NPIX,NLINES)
      REAL DSUM(NPIX,NLINES),WTSUM(NPIX,NLINES),DLAST(NPIX),
     +	   WTLAST(NPIX)
      CHARACTER PRBUF*80
      NBAD=0
C
C SCAN THE IMAGE, COPYING INPUT PIXELS TO THE OUTPUT IMAGE
C AND COUNTING THE BAD PIXELS
C
      DO 10 J=1,NLINES
	DO 9 I=1,NPIX
	  IB(I,J)=IA(I,J)
	  IF(IA(I,J).EQ.INVALA) NBAD=NBAD+1
    9	CONTINUE
   10 CONTINUE
C
C IF THERE ARE NO VALID PIXELS, ABORT
C
      IF(NBAD.EQ.NPIX*NLINES) GO TO 999
C
C IF THE PROGRESS OF THE ITERATIONS IS TO BE PRINTED, PRINT HEADINGS
C
      IF(ILEVEL.GE.3) THEN
	CALL WRUSER(' ',ISTAT)
	CALL WRUSER('      ITERATION    SMOOTHING LENGTH    '
     +	//'MAX. CHANGE    RMS CHANGE',ISTAT)
	CALL WRUSER('      ---------    ----------------    '
     +	//'-----------    ----------',ISTAT)
      ENDIF
C
C PERFORM THE REQUIRED NUMBER OF RELAXATION ITERATIONS
C
      LASTMX=0
      MAXCNG=0
      DO 144 ITER=1,NITER
C
C SET THE MAXIMUM ABSOLUTE CHANGE SO FAR
C
	LASTMX=MAX(LASTMX,MAXCNG,0)
C
C IF THE MAX CHANGE LAST ITERATION WAS LESS THAN 0.25 OF THE MAX CHANGE
C SO FAR, REDUCE THE SCALE SIZE BY A FACTOR 2 AND RESET THE MAX
C CHANGE SO FAR
C
	IF(MAXCNG*4.LE.LASTMX.AND.ITER.NE.1) THEN
	  SIZE=SIZE*0.5
	  LASTMX=MAXCNG
	ENDIF
C
C INITIALLISE THE MAX ABSOLUTE CHANGE FOR THIS ITERATION
C
	MAXCNG=0
C
C CALCULATE THE LOGARITHMIC DECREMENT FOR THE WEIGHTS IN GOING FROM 1
C PIXEL TO THE NEXT
C
	DEC=EXP(-1.0/SIZE)
C
C INITIALLISE STORAGE FOR FORMING WEIGHTED MEANS
C
	DO 100 J=1,NLINES
	  DO 99 I=1,NPIX
	    DSUM(I,J)=0.0
	    WTSUM(I,J)=0.0
   99	  CONTINUE
  100	CONTINUE
C
C FIRST WORK THROUGH THE IMAGE LINES, SCANNING EACH LINE IN BOTH
C DIRECTIONS
C
	DO 14 J=1,NLINES
	  DO 15 IDIRN=-1,1,2
	    IF(IDIRN.GE.0) THEN
	      IFIRST=1
	      ILAST=NPIX
	    ELSE
	      IFIRST=NPIX
	      ILAST=1
	    ENDIF
C
C INITIALLISE STORES
C	DLAST: WEIGHTED SUM OF PREVIOUS DATA VALUES
C	WTLAST: SUM OF PREVIOUS WEIGHTS
C
	    DLAST(1)=0.0
	    WTLAST(1)=0.0
C
C PROCESS A LINE
C
	    DO 16 I=IFIRST,ILAST,IDIRN
C
C IF THE INPUT PIXEL IS VALID, RESET THE WEIGHTED SUMS
C
	      IF(IA(I,J).NE.INVALA) THEN
	        DLAST(1)=IB(I,J)
		WTLAST(1)=1.0
C
C FOR INVALID LOCATIONS, FORM SUMS FOR WEIGHTED MEAN
C
	      ELSE
C
C DECREMENT THE PREVIOUS WEIGHT
C
		WTLAST(1)=WTLAST(1)*DEC
		DLAST(1)=DLAST(1)*DEC
C
C FORM SUMS FOR THE REPLACEMENT VALUE
C
		DSUM(I,J)=DSUM(I,J)+DLAST(1)
		WTSUM(I,J)=WTSUM(I,J)+WTLAST(1)
C
C IF THIS PIXEL HAS BEEN REPLACED BEFORE, ADD IT INTO THE CURRENT
C WEIGHTED SUMS FOR THIS LINE
C
		IF(IB(I,J).NE.INVALA) THEN
		  WTLAST(1)=WTLAST(1)+1.0
		  DLAST(1)=DLAST(1)+IB(I,J)
		ENDIF
	      ENDIF
   16	    CONTINUE
   15	  CONTINUE
   14	CONTINUE
C
C NOW PERFORM THE SAME PROCESS DOWN THE IMAGE COLUMNS, BUT PROCESSING
C A WHOLE LINE OF DATA AT ONCE
C
	DO 115 JDIRN=-1,1,2
	  IF(JDIRN.GE.0) THEN
	    JFIRST=1
	    JLAST=NLINES
	  ELSE
	    JFIRST=NLINES
	    JLAST=1
	  ENDIF
C
C INITIALLISE STORES FOR A WHOLE LINE
C
	  DO 121 I=1,NPIX
	    DLAST(I)=0.0
	    WTLAST(I)=0.0
  121	  CONTINUE
C
C PROCESS COLUMNS, AS ABOVE, BUT USING A WHOLE LINE OF DATA
C
	  DO 116 J=JFIRST,JLAST,JDIRN
	    DO 126 I=1,NPIX
	      IF(IA(I,J).NE.INVALA) THEN
	        DLAST(I)=IB(I,J)
		WTLAST(I)=1.0
	      ELSE
		WTLAST(I)=WTLAST(I)*DEC
		DLAST(I)=DLAST(I)*DEC
		DSUM(I,J)=DSUM(I,J)+DLAST(I)
		WTSUM(I,J)=WTSUM(I,J)+WTLAST(I)
		IF(IB(I,J).NE.INVALA) THEN
		  WTLAST(I)=WTLAST(I)+1.0
		  DLAST(I)=DLAST(I)+IB(I,J)
	        ENDIF
	      ENDIF
  126	    CONTINUE
  116	  CONTINUE
  115	CONTINUE
C
C SCAN THE INVALID PIXELS, REPLACING THOSE FOR WHICH A NEW WEIGHTED
C MEAN CAN BE FORMED
C
	RMS=0.0
	DO 201 J=1,NLINES
	  DO 200 I=1,NPIX
C
C IF THE INPUT PIXEL WAS INVALID, AND A REPLACEMENT VALUE CAN BE
C FOUND, CALCULATE THE REPLACEMENT VALUE
C
	    IF(IA(I,J).EQ.INVALA.AND.WTSUM(I,J).GT.0.0) THEN
	      NEWVAL=NINT(DSUM(I,J)/WTSUM(I,J))
C
C FIND THE MAXIMUM ABSOLUTE CHANGE THIS ITERATION
C
	      IDIFF=ABS(NEWVAL-IB(I,J))
	      MAXCNG=MAX(MAXCNG,IDIFF)
C
C FORM SUM FOR RMS CHANGE
C
	      RMS=RMS+REAL(IDIFF)**2
	      IB(I,J)=NEWVAL
	    ENDIF
  200 	  CONTINUE
  201	CONTINUE
C
C PRINT THE PROGRESS OF EACH ITERATION, IF REQUIRED
C
	IF(ILEVEL.GE.3) THEN
C
C CALCULATE THE RMS CHANGE THIS ITERATION
C
	  CNGRMS=SCALE*SQRT(RMS/MAX(1,NBAD))
	  WRITE(PRBUF,33)ITER,SIZE,MAXCNG*SCALE,CNGRMS
   33	  FORMAT(6X,I6,9X,G13.6,4X,G13.6,2X,G13.6)
	  CALL WRUSER(PRBUF,ISTAT)
	ENDIF
  144 CONTINUE
      CNGMAX=MAXCNG*SCALE
      CNGRMS=SCALE*SQRT(RMS/MAX(NBAD,1))
  999 RETURN
      END
