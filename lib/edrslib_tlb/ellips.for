      SUBROUTINE ELLIPS(SIG,SIG0,AXISR,THETA)
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*PURPOSE
*	TO CALCULATE THE AXIS RATIO, INCLINATION AND MINOR AXIS WIDTH
*	OF A STAR IMAGE, GIVEN THE GAUSSIAN WIDTHS OF MARGINAL PROFILES
*	AT 45 DEGREE INTERVALS
*
*METHOD
*	THE RECIPROCAL OF THE SQUARE OF THE WIDTH VARIES APPROXIMATELY
*	LIKE THE LENGTH OF AN ELLIPSE DIAMETER AS THE ANGLE OF
*	PROJECTION VARIES. THE ROUTINE CALCULATES THE REQUIRED
*	PARAMETERS ASSUMING THIS RELATION HOLDS, THEN ITERATES, 
*	CALCULATING THE EXPECTED DEVIATION FROM THIS LAW AND SUBTRACTING
*	IT FROM THE DATA BEFORE CALCULATING A NEW ESTIMATE. THE SOLUTION
*	OF THE ELLIPSE EQUATIONS IS ANALOGOUS TO USING THE STOKES
*	PARAMETERS OF LINEAR POLARIZATION TO FIND THE ELLIPSE PARAMETERS
*	THE ROUTINE ASSUMES A GAUSSIAN PROFILE FOR THE STAR
*
*ARGUMENTS
*	SIG (IN)
*	REAL(4)
*		THE GAUSSIAN WIDTHS OF THE MARGINAL PROFILES OF THE STAR
*		IN DIRECTIONS AT 0,45,90 AND 135 DEGREES TO THE X AXIS
*	SIG0 (OUT)
*	REAL
*		THE WIDTH OF THE MINOR AXIS OF THE ELLIPSE
*	AXISR (OUT)
*	REAL
*		THE AXIS RATIO OF THE ELLIPSE. 
*	THETA (OUT)
*	REAL
*		THE INCLINATION OF THE MAJOR AXIS TO THE X AXIS IN
*		RADIANS. (X THROUGH Y POSITIVE)
*
*CALLS
*	NONE
*
*WRITTEN BY
*	R.F. WARREN-SMITH
*-----------------------------------------------------------------------
C
C
      PARAMETER (NITER=10,
     +		 TOLLS=1.0E-4,
     +		 TOLLA=1.0E-4,
     +		 TOLLT=1.0E-2)
      PARAMETER (ANG=0.0174533,
     +		 T45=45.0*ANG,
     +		 T90=90.0*ANG,
     +		 T135=135.0*ANG)
      REAL SIG(4),RSIG2(4),T(4)
      DOUBLE PRECISION D(4),DELQ,DELU,AMP1,AMP2
C
C WORK WITH THE RECIPROCALS OF THE WIDTHS SQUARED... THESE VARY
C APPROXIMATELY ELLIPTICALLY WITH INCLINATION ANGLE
C
      DO 1 I=1,4
	RSIG2(I)=(1.0/SIG(I))**2
    1 CONTINUE
C
C SET INITIAL ESTIMATES OF ELLIPSE PARAMETERS
C
      SIG0=1.0
      AXISR=1.0
      THETA=0.0
C
C PERFORM ITERATIONS TO FIND THE ACCURATE PARAMETERS
C
      DO 13 ITER=1,NITER
	RSIG02=(1.0/SIG0)**2
	AXISR2=AXISR**2
	T(1)=THETA
	T(2)=THETA-T45
	T(3)=THETA-T90
	T(4)=THETA-T135
C
C MAKE A CORRECTION TO THE DATA VALUES WHICH IS THE AMOUNT BY WHICH
C THEY WOULD DEVIATE FROM A PURE ELLIPTICAL VARIATION GIVEN THE
C CURRENT ELLIPSE PARAMETERS
C
	DO 12 I=1,4
	  C=COS(T(I))
	  S=SIN(T(I))
	  D(I)=RSIG02*((C*S*(AXISR2-1.0))**2)/(AXISR2*((AXISR2*C*C)+
     +	  (S*S)))
          D(I)=D(I)+RSIG2(I)
   12	CONTINUE
C
C NOW FIND THE ELLIPSE PARAMETERS ASSUMING THE DATA VARIES ELLIPTICALLY
C
	DELQ=D(3)-D(1)
	DELU=D(4)-D(2)
	AMP1=0.5D0*SQRT(DELQ**2+DELU**2)
	AMP2=0.25D0*(D(1)+D(2)+D(3)+D(4))
        AMP1=MIN(AMP1,0.9999D0*AMP2)
	IF(DELQ.EQ.0.0D0.AND.DELU.EQ.0.0D0) THEN
	  THETAN=0.0
	ELSE
	  THETAN=0.5D0*ATAN2(DELU,DELQ)
	ENDIF
	RSIG02=AMP1+AMP2
	SIG0N=SQRT(1.0/MAX(RSIG02,1.0E-10))
	AXISRN=SQRT((AMP1+AMP2)/(AMP2-AMP1))
C
C CALCULATE THE CHANGES TO THE PARAMETERS
C
	DSIG0=ABS(SIG0N-SIG0)
	DAXISR=ABS(AXISRN-AXISR)
	DTHETA=ABS(THETAN-THETA)
	SIG0=SIG0N
	AXISR=AXISRN
	THETA=THETAN
C
C IF THE ACCURACY CRITERION IS MET, EXIT FROM THE ITERATION LOOP
C
	IF(DSIG0.LE.TOLLS.AND.DAXISR.LE.TOLLA.AND.DTHETA.LE.TOLLT)
     +	THEN
	  GO TO 99
	ENDIF
   13 CONTINUE
   99 RETURN
      END
