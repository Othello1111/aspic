      FUNCTION FCHISQ (Y,YFIT,NPTS,N,NFREE)
C+
C     Function:- FCHISQ.
C
C     function to evaluate the "chi-squared" - really
C     the mean square residual between a set of data
C     and some fit to that data.
C
C  Given;
C   Y     (RA) Set of datapoints.
C   YFIT  (RA) Set of values generated by fit to the data.
C   NPTS  (I)  No. of data points.
C   N     (I)  Size of arrays Y & YFIT.
C   NFREE (I)  Number of degrees of freedom.
C
C  Returned;
C   FCHISQ (R) Mean square residual.
C
C  A C Davenhall./St Andrews/                         Spring 81
C  A C Davenhall./ROE/      {Modified}                5/8/82.
C
C  (Based on a routine of the same name in Bevington)
C-
      INTEGER NPTS,N,NFREE
      REAL Y(N),YFIT(N)
C
      DOUBLE PRECISION CHISQ
      CHISQ=0.0E0
C
C      ACCUMULATE CHI SQUARE.
C
      DO I =1,NPTS
         WW=Y(I)-YFIT(I)
         CHISQ=CHISQ+(WW*WW)
      ENDDO
C
C      DIVIDE BY NO. OF DEGREE OF FREEDOM.
C      ( NOT A LOT IN THIS SOCIALIST STATE!)
C
      FREE=NFREE
      FCHISQ=CHISQ/FREE
      END