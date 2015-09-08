      SUBROUTINE STARIM(IA,NPIX,NLINES,INVAL,X0,Y0,NXY,ISIZE,SIG0,
     +			AXISR,THETA,NGOOD,SIG)
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*PURPOSE
*	TO FIND THE MEAN AXIS RATIO, SEEING DISK SIZE AND INCLINATION
*	OF A SET OF ELLIPTICAL STAR IMAGES.
*
*METHOD
*	FOR EACH STAR, FORM MARGINAL PROFILES IN X AND Y USING DATA
*	IN A SQUARE SEARCH AREA. ALSO FORM MARGINAL PROFILES IN
*	DIRECTIONS P AND Q, INCLINED AT 45 DEGREES TO X AND Y, USING
*	DATA IN A SEARCH SQUARE INCLINED AT 45 DEGREES. CALL CLNSTA
*	TO REMOVE BACKGROUNDS, NEIGHBOURING STARS, DIRT, ETC. FROM
*	THESE PROFILES, THEN CALL GAUFIT TO FIT A GAUSSIAN TO EACH,
*	TO DETERMINE THE CENTRE, WIDTH AND AMPLITUDE. CALCULATE A MEAN
*	CENTRE FOR EACH STAR. COMBINE THE 4 WIDTH ESTIMATES FROM EACH
*	STAR USING WMODE TO GIVE 4 MEAN WIDTHS, THEN CALL ELLIPS TO
*	CALCULATE THE MEAN STAR IMAGE ELLIPSE PARAMETERS.
*
*ARGUMENTS
*	IA (IN)
*	INTEGER*2(NPIX,NLINES)
*		THE INPUT IMAGE CONTAINING THE STAR IMAGES
*	NPIX,NLINES (IN)
*	INTEGER
*		THE DIMENSIONS OF IA
*	INVAL (IN)
*	INTEGER
*		INVALID PIXEL FLAG FOR IA
*	X0,Y0 (IN/OUT)
*	REAL(NXY)
*		INITIAL APPROXIMATE POSITIONS FOR EACH STAR IMAGE
*		IF THE STAR IS FOUND, AN ACCURATE POSITION IS RETURNED
*	NXY (IN)
*	INTEGER
*		THE NUMBER OF STAR IMAGES TO BE USED
*	ISIZE (IN)
*	INTEGER
*		THE LENGTH OF THE SIDE OF THE SEARCH SQUARE
*	SIG0 (OUT)
*	REAL
*		THE MEAN STAR 'SIGMA'
*	AXISR (OUT)
*	REAL
*		THE MEAN STAR AXIS RATIO
*	THETA (OUT)
*	REAL
*		THE MEAN INCLINATION OF THE STAR MAJOR AXES TO THE
*		X DIRECTION IN RADIANS (X THROUGH Y POSITIVE)
*	NGOOD (OUT)
*	INTEGER
*		THE NUMBER OF STARS SUCCESSFULLY FOUND AND USED IN THE 
*		FIT
*	SIG (OUT)
*	REAL(NXY,5)
*		SIG(I,1), SIG(I,2), SIG(I,3) AND SIG(I,4) RETURN THE
*		GAUSSIAN WIDTHS OF STAR I IN DIRECTIONS INCLINED AT
*		0, 45, 90 AND 135 DEGREES TO THE X AXIS (X THROUGH Y
*		POSITIVE). SIG(I,5) RETURNS THE SUM OF THE AMPLITUDES
*		OF THE 4 PROFILES OF STAR I (I.E. IT IS PROPORTIONAL
*		TO THE AMPLITUDE OF STAR I). IF A STAR WAS NOT FOUND,
*		ALL ITS ENTRIES IN SIG ARE ZERO.
*
*CALLS
*	THIS PACKAGE:
*		CLNSTA,GAUFIT,WMODE,ELLIPS
*
*NOTES
*	USES INTEGER*2 ARRAYS
*
*WRITTEN BY
*	R.F. WARREN-SMITH
*-----------------------------------------------------------------------
C
C
C
C SET MAXIMUM RADIUS FROM CENTRE FOR FORMING THE MARGINAL PROFILES
C AND SET MAXP TO SQRT(2.0) TIMES THIS TO ALLOW BINNING IN THE 45
C DEGREE DIRECTION ALSO
C
      PARAMETER (MAXX=50,
     +		 MAXP=1.41421*MAXX+1.0,
     +		 MAXSIZ=2*MAXX+1)
C
C DIMENSION ARRAYS
C
      INTEGER*2 IA(NPIX,NLINES)
      INTEGER NX(-MAXX:MAXX),NY(-MAXX:MAXX),NP(-MAXP:MAXP),
     +	      NQ(-MAXP:MAXP),STAR,BINI,BINJ,BINP,BINQ
      REAL X0(NXY),Y0(NXY),SIG(NXY,5),XSUM(-MAXX:MAXX),YSUM(-MAXX:MAXX),
     +	   PSUM(-MAXP:MAXP),QSUM(-MAXP:MAXP),SIGMA(4)
      PARAMETER (NITER=3,ITMODE=10,TOLL=0.001,NGAUIT=15)
C
C DETERMINE THE SIZE OF THE SEARCH AREA AS ODD AND NOT EXCEEDING
C MAXSIZ, THEN DETERMINE THE CORRESPONDING NUMBER OF BINS IN THE
C 45 DEGREE DIRECTIONS
C
      IX=MIN(ISIZE,MAXSIZ)
      IDX=MAX(1,IX/2)
      IDP=NINT(1.41421*IDX)
C
C CONSIDER EACH STAR POSITION IN TURN, COUNTING SUCCESSES IN NGOOD
C
      NGOOD=0
      DO 800 STAR=1,NXY
	X=X0(STAR)
	Y=Y0(STAR)
C
C PERFORM NITER ITERATIONS, EACH TIME CENTERING THE SEARCH AREA ON
C THE PREVIOUS ESTIMATE OF THE STAR CENTRE
C
	DO 87 ITER=1,NITER
	  I0=NINT(MIN(MAX(-1.0E8,X),1.0E8))
	  J0=NINT(MIN(MAX(-1.0E8,Y),1.0E8))
C
C INITIALLISE ARRAYS FOR FORMING THE MARGINAL PROFILES IN THE
C X AND Y DIRECTIONS AND AT 45 DEGREES (P AND Q)
C
	  DO 41 I=-IDX,IDX
	    XSUM(I)=0.0
	    YSUM(I)=0.0
	    NX(I)=0
	    NY(I)=0
   41	  CONTINUE
	  DO 42 I=-IDP,IDP
	    PSUM(I)=0.0
	    QSUM(I)=0.0
	    NP(I)=0
	    NQ(I)=0
   42	  CONTINUE
C
C NOW FORM THE MARGINAL PROFILES, SCANNING A LARGE ENOUGH IMAGE
C AREA TO ACCOMMODATE THE SEARCH SQUARE TURNED THROUGH 45 DEGREES
C
	  DO 81 BINJ=-IDP,IDP
	    J=J0+BINJ
C
C CHECK THAT WE ARE STILL INSIDE THE IMAGE
C
	    IF(J.GE.1.AND.J.LE.NLINES) THEN
	      DO 80 BINI=-IDP,IDP
	        I=I0+BINI
		IF(I.GE.1.AND.I.LE.NPIX) THEN
C
C IF THE PIXEL IS VALID, FIND THE P,Q COORDINATES
C
		  IF(IA(I,J).NE.INVAL) THEN
		    BINP=BINI+BINJ
		    BINQ=BINJ-BINI
C
C IF THE PIXEL LIES IN THE NORMAL SEARCH SQUARE, ADD IT TO THE
C X AND Y MARGINALS
C
		     IF(ABS(BINI).LE.IDX.AND.ABS(BINJ).LE.IDX) THEN
			XSUM(BINI)=XSUM(BINI)+IA(I,J)
			YSUM(BINJ)=YSUM(BINJ)+IA(I,J)
			NX(BINI)=NX(BINI)+1
			NY(BINJ)=NY(BINJ)+1
		      ENDIF
C
C IF THE PIXEL LIES IN THE 45 DEGREE SQUARE, ADD IT TO THE P AND Q
C MARGINALS
C
		    IF(ABS(BINP).LE.IDP.AND.ABS(BINQ).LE.IDP) THEN
		      PSUM(BINP)=PSUM(BINP)+IA(I,J)
		      QSUM(BINQ)=QSUM(BINQ)+IA(I,J)
		      NP(BINP)=NP(BINP)+1
		      NQ(BINQ)=NQ(BINQ)+1
		    ENDIF
		  ENDIF
		ENDIF
   80	      CONTINUE
	    ENDIF
   81	  CONTINUE
C
C EVALUATE THE X AND Y MARGINALS
C
	  DO 31 I=-IDX,IDX
	    IF(NX(I).GT.0) THEN
	      XSUM(I)=XSUM(I)/NX(I)
	    ELSE
	      XSUM(I)=2.0E20
	    ENDIF
	    IF(NY(I).GT.0) THEN
	      YSUM(I)=YSUM(I)/NY(I)
	    ELSE
	      YSUM(I)=2.0E20
	    ENDIF
   31	  CONTINUE
C
C EVALUATE THE P AND Q MARGINALS
C
	  DO 32 I=-IDP,IDP
	    IF(NP(I).GT.0) THEN
	      PSUM(I)=PSUM(I)/NP(I)
	    ELSE
	      PSUM(I)=2.0E20
	    ENDIF
	    IF(NQ(I).GT.0) THEN
	      QSUM(I)=QSUM(I)/NQ(I)
	    ELSE
	      QSUM(I)=2.0E20
	    ENDIF
   32	  CONTINUE
C
C CALL CLNSTA TO REMOVE THE BACKGROUND AND NEIGHBOURING STARS, DIRT
C ETC. FROM EACH PROFILE
C
	  CALL CLNSTA(XSUM(-IDX),-IDX,IDX,0.0)
	  CALL CLNSTA(YSUM(-IDX),-IDX,IDX,0.0)
	  CALL CLNSTA(PSUM(-IDP),-IDP,IDP,0.0)
	  CALL CLNSTA(QSUM(-IDP),-IDP,IDP,0.0)
C
C CALL GAUFIT TO FIT A GAUSSIAN TO EACH PROFILE
C
	  CALL GAUFIT(XSUM(-IDX),-IDX,IDX,NGAUIT,TOLL,AX,XCEN,SIGX,
     +	  BACK,IERRX)
	  CALL GAUFIT(YSUM(-IDX),-IDX,IDX,NGAUIT,TOLL,AY,YCEN,SIGY,
     +	  BACK,IERRY)
	  CALL GAUFIT(PSUM(-IDP),-IDP,IDP,NGAUIT,TOLL,AP,PCEN,SIGP,
     +	  BACK,IERRP)
	  CALL GAUFIT(QSUM(-IDP),-IDP,IDP,NGAUIT,TOLL,AQ,QCEN,SIGQ,
     +	  BACK,IERRQ)
C
C IF NO FATAL ERRORS WERE ENCOUNTERED, CALCULATE A MEAN CENTRE
C POSITION FROM THE CENTRES OF EACH PROFILE. OTHERWISE EXIT
C FROM THE ITERATION LOOP WHICH FINDS THE CENTRE
C
	  IERRFT=MAX(IERRX,IERRY,IERRP,IERRQ)
	  IF(IERRFT.EQ.0) THEN
	    XNEW=I0+(XCEN+0.5*(PCEN-QCEN))*0.5
	    YNEW=J0+(YCEN+0.5*(PCEN+QCEN))*0.5
C
C CALCULATE SHIFT OF CENTRE THIS ITERATION... IF IT SATISFIES THE
C ACCURACY CRITERION, EXIT FROM THE CENTRE-FINDING ITERATION LOOP
C
            SHIFT=SQRT((X-XNEW)**2+(Y-YNEW)**2)
	    X=XNEW
	    Y=YNEW
	    IF(SHIFT.LE.TOLL) THEN
	      GO TO 601
	    ENDIF
	  ELSE
	    GO TO 601
	  ENDIF
   87	CONTINUE
C
C IF THE CENTRE WAS FOUND SUCCESSFULLY, RECORD THE WIDTHS OF EACH
C PROFILE AND THE STAR CENTRE AND FORM A WEIGHT FROM 
C THE STAR AMPLITUDE
C
  601	IF(IERRFT.EQ.0) THEN
	  NGOOD=NGOOD+1
C
C CORRECT FOR DIFFERENT BIN SPACING IN THE P,Q DIRECTIONS
C
	  SIGP=0.7071068*SIGP
	  SIGQ=0.7071068*SIGQ
	  X0(STAR)=X
	  Y0(STAR)=Y
	  SIG(STAR,1)=SIGX
	  SIG(STAR,2)=SIGP
	  SIG(STAR,3)=SIGY
	  SIG(STAR,4)=SIGQ
	  SIG(STAR,5)=AP+AQ+AX+AY
C
C IF THE CENTRE WAS NOT FOUND SUCCESSFULLY, RECORD THE WEIGHT AS ZERO
C
	ELSE
	  SIG(STAR,1)=0.0
	  SIG(STAR,2)=0.0
	  SIG(STAR,3)=0.0
	  SIG(STAR,4)=0.0
	  SIG(STAR,5)=0.0
	ENDIF
  800 CONTINUE
C
C IF AT LEAST ONE STAR WAS SUCCESSFUL, CALL WMODE TO FIND A MEAN
C WIDTH FOR EACH PROFILE DIRECTION
C
      IF(NGOOD.GE.1) THEN
	DO 34 NSIG=1,4
	  CALL WMODE(SIG(1,NSIG),SIG(1,5),NGOOD,0.01,ITMODE,TOLL,
     +	  SIGMA(NSIG),ERR)
   34	CONTINUE
C
C CALL ELLIPS TO FIND THE PARAMETERS OF AN ELLIPTICAL STAR IMAGE
C FROM THE MARGINAL WIDTHS
C
	CALL ELLIPS(SIGMA,SIG0,AXISR,THETA)
      ENDIF
      RETURN
      END