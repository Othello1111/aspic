      SUBROUTINE ADHC2(PIC,NX,NY,IXC,IYC,VLO,VHI,SHADE,IPIC)
      PARAMETER NINTER=200
      INTEGER NX,NY,IXC,IYC
      INTEGER*2 IPIC(NX*NY),IDUMMY
      REAL PIC(NX*NY),VLO,VHI,VL,D,SCALE,V
      REAL MINVAL,MAXVAL
      DIMENSION VAL(NINTER),XHIS(NINTER),SIG(NINTER),A(10),
     1 NHIS(NINTER)
      DOUBLE PRECISION VAL,XHIS,SIG,A,CHI,RMS,XVAL
      CHARACTER BUFFER*80
C
      MINVAL=VLO
      MAXVAL=VHI
C
      YZERO=SHADE*2.
      YZERO=MIN(MAX(YZERO,0.),2.)
C
C     YZERO CONTROLS SHAPE OF HISTOGRAM OF OUTPUT DENSITIES
C     YZERO=1, FLAT HISTOGRAM
C     YZERO=0, STRONGLY WEIGHTED TOWARDS WHITE
C     YZERO=2, STRONGLY WEIGHTED TOWARDS BLACK
C
C     COEFFICIENTS OF QUADRATIC EQUATION TO BE SOLVED
      B=YZERO
      AQ=1.-YZERO
      A2=2.*AQ
      A4=4.*AQ
      B2=B*B
C
C        COMPUTE 'NINTER' INTERVAL HISTOGRAM OF PIXEL VALUES
C
      NCYCLES=0
      CALL WRUSER('COMPUTING HISTOGRAM OF PIXEL VALUES...',ISTAT)
10       WRITE(BUFFER,1000)MINVAL,MAXVAL
1000     FORMAT('MIN AND MAX VALUES =',2E15.5)
         CALL WRUSER(BUFFER,ISTATUS)
         LOWPTS=0
         DO 15 I=1,NINTER
15       NHIS(I)=0
         XINTER=NINTER
         DX=(MAXVAL-MINVAL)/XINTER
         IF (DX .EQ. 0.)THEN
           CALL WRUSER('FAILED: ALL PIXELS HAVE SAME VALUE',ISTAT)
           STOP
         END IF
         DO 20 I=1,NX*NY
            V=PIC(I)
            K=(V-MINVAL)/DX+1.
            IF (K .LT. 1 )THEN
              LOWPTS=LOWPTS+1
            ELSE IF (K .LE. NINTER)THEN
              NHIS(K)=NHIS(K)+1
            END IF
20       CONTINUE
C
C        COMPUTE NORMALIZED CUMULATIVE HISTOGRAM
C
         PTS=NX*NY
         NHIS(1)=NHIS(1)+LOWPTS
         DO 30 I=2,NINTER
30       NHIS(I)=NHIS(I)+NHIS(I-1)
         DO 35 I=1,NINTER
            VAL(I)=MINVAL+I*DX
            XHIS(I)=NHIS(I)/PTS
35       CONTINUE
C
C        FIT 6 TERM POLYNOMIAL TO CUMULATIVE DIST. FUNC. IN RANGE
C         OF 2 TO 96 PERCENT
C
         J=0
         DO 40 I=1,NINTER
            IF (XHIS(I) .GT. .02 .AND. (XHIS(I) .LT. .96
     1       .OR. J .EQ. 0))THEN
               J=J+1
               XHIS(J)=XHIS(I)
               VAL(J)=VAL(I)
            END IF
40       CONTINUE
         J=MAX(1,J)
         MAXVAL=VAL(J)
         MINVAL=VAL(1)
         WRITE(BUFFER,1001)J
1001     FORMAT(I6,' HISTOGRAM BINS IN 2-96 PERCENT RANGE')
         CALL WRUSER(BUFFER,ISTATUS)
C
C        IF THERE ARE LESS THAN 20 BINS IN THE HISTOGRAM, THEN
C        REDO HISTOGRAM WITH NARROWER LIMITS
C
         IF (J .LT. 20 .AND. NCYCLES .LE. 2)THEN
            NCYCLES=NCYCLES+1
            MINVAL=MINVAL-2.*DX
            MAXVAL=MAXVAL+DX
            GO TO 10
         END IF
C
         IF (J .LT. 7)THEN
          CALL WRUSER('FAILED DUE TO PECULIAR PIXEL DISTRIBUTION.'
     1                ,ISTAT)
          CALL WRUSER(' USUALLY CAUSED IF IMAGE HAS ONLY',ISTAT)
          CALL WRUSER(' A FEW DISCRETE PIXEL VALUES',ISTAT)
          STOP
         END IF
C
C        FOR MAX. PRECISION, NORMALIZE VAL TO RANGE 0-1
C
         DELX=VAL(J)-VAL(1)
         XFST=VAL(1)
         DO 45 I=1,J
45       VAL(I)=(VAL(I)-XFST)/DELX
C
         CALL POLFIT(VAL,XHIS,SIG,J,6,0,A,CHI,RMS)
         WRITE(BUFFER,1002)MINVAL,MAXVAL
1002     FORMAT('GRAY SCALE RANGES FROM',E15.5,' TO',E15.5)
         CALL WRUSER(BUFFER,ISTATUS)
C
C     CALCULATE SCALED INTENSITY (0-255) FOR EACH PIXEL
C
      DO 100 I=1,NX*NY
         VV=PIC(I)
         IF (VV .LT. MINVAL)THEN
            IPIC(I)=0
         ELSE IF (VV .LT. MAXVAL)THEN
            XVAL=(VV-XFST)/DELX
            TEMP=((((A(6)*XVAL+A(5))*XVAL+A(4))*XVAL+A(3))*XVAL+A(2))
     1       *XVAL+A(1)
            IF (SHADE .NE. .5)TEMP=(-B+SQRT(B2+A4*TEMP))/A2
            IPIC(I)=MIN(MAX(0.,TEMP*256.),255.)
         ELSE
            IPIC(I)=255
         END IF
100   CONTINUE
C
C     DISPLAY IMAGE ON ARGS
C
      CALL SRPXI2(IPIC,NX,NX,NY,IXC-NX/2,IYC-NY/2,
     &               16,.FALSE.,IDUMMY,1)
      VLO=MINVAL
      VHI=MAXVAL
      END
