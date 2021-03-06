C+
C    STARLINK PROG MOVE
C
C    ROUTINE TO SHIFT AN IMAGE (1D OR 2D) IN THE X & Y-DIRECTIONS
C    SHIFTS NEED NOT BE INTEGER AND SINC INTERPOLATION IS USED
C
C    PARAMETERS:
C                   1) INPUT IMAGE
C                   2) OUTPUT IMAGE (SAME SIZE AS INPUT)
C                   3) X,Y SHIFT IN PIXELS (NEG TO LOWER VALUES)
C                      (NB TWO VALUES REQUIRED)
C                   4) NTERM NO OF TERMS OF SINC FUNCTION TO USE
C                      (SENSIBLE MIN IS 20, MAX IS 100)
C
C   CDP/RGO   6/5/81
C-
      REAL SHIFT(2)
      INTEGER*4 PIN,STATUS,AXIN(2),POUT,T1
      CHARACTER*72 TEXT
      INCLUDE 'INTERIM(ERRPAR)'
      INCLUDE 'INTERIM(FMTPAR)'
C
C      NOW GET INPUT FRAME
C
      ITRY = 0
    1 CALL RDIMAG('INPUT',FMT_R,2,AXIN,IDIM,PIN,STATUS)
      IF (STATUS.NE.ERR_NORMAL) THEN
         CALL CNPAR('INPUT',STATUS)
         IF(ITRY.EQ.0)  THEN
            ITRY = 1
            GO TO 1
         ENDIF
         CALL EXIT
      END IF
      IF(IDIM.EQ.1)  AXIN(2) = 1
C
C      NOW GET OUTPUT FRAME
C
      ITRY = 0
    2 CALL WRIMAG('OUTPUT',FMT_R,AXIN,IDIM,POUT,ISTAT)
      IF (STATUS.NE.ERR_NORMAL) THEN
         CALL CNPAR('OUTPUT',STATUS)
         IF(ITRY.EQ.0)  THEN
            ITRY = 1
            GO TO 2
         ENDIF
         CALL EXIT
      END IF
C
C   GET MEMORY FOR TEMP STORAGE
C
      CALL GETDYN('TEMP1',FMT_R,AXIN(1)*AXIN(2),T1,STATUS)
      IF(STATUS.NE.ERR_NORMAL)  THEN
         CALL WRUSER('ERROR GETTING MEMORY FOR WORK SPACE',STATUS)
         GO TO 9999
      ENDIF
C
C    GET SHIFT AND NO OF TERMS
C
      CALL RDKEYR('XYSHIFT',.FALSE.,2,SHIFT,NVAL,STATUS)
      IF(STATUS.NE.ERR_NORMAL)  THEN
         CALL CNPAR('SHIFT',STATUS)
         CALL EXIT
      ENDIF
      NTERM = 20
      CALL RDKEYI('NTERM',.TRUE.,1,NTERM,NVAL,ISTAT)
      IF(ISTAT.NE.ERR_NORMAL.AND.ISTAT.NE.ERR_PARNUL)  THEN
         CALL CNPAR('NTERM',ISTAT)
         CALL EXIT
      ENDIF
      IF(NTERM.GT.100) NTERM = 100
      CALL SHIFT_IMAGE_X(%VAL(PIN),AXIN,SHIFT(1),NTERM,%VAL(T1))
      CALL SHIFT_IMAGE_Y(%VAL(T1),AXIN,SHIFT(2),NTERM)
      CALL IMAGE_OUT(%VAL(POUT),AXIN,%VAL(T1))
 9999 CONTINUE
      CALL EXIT
      END
C
      SUBROUTINE SHIFT_IMAGE_X(TEMP,AXIN,PHASE,NTERM,TEMP1)
      INTEGER AXIN(2)
      REAL*4 IWORK(1024),IWORK1(1024),A(200),SAMPLE(200)
      REAL*4 TEMP1(AXIN(1),AXIN(2)),TEMP(AXIN(1),AXIN(2))
      NL = AXIN(1)
      NI = AXIN(2)
      DO 400 IX=1,NI
C
C  **    ZERO OUT RESULT ARRAY
C
         DO 200 J=1,1024
            IWORK1(J)=0
  200       CONTINUE
C
C  **    READ DATA OF THIS X-SECTION
C
      DO 201 K=1,NL
      IWORK(K) = TEMP(K,IX)
  201 CONTINUE
C
C
C
C
      IF(PHASE.GE.0.0)   THEN
         IF(IX.EQ.1)  THEN
           IPHI = INT(PHASE)
           PHI = PHASE - IPHI
           IF(PHI.NE.0.0) PHI=1.0-PHI
           CALL GETSAMP(SAMPLE,PHI,NTERM,PHASE)
         ENDIF
         NC = 0
         NEND = IPHI+1-NTERM
         IF(NEND.GT.0)  NEND=0
      DO 204 K=IPHI+1+NTERM,NL+NEND
         FLUX = 0.0
         NC = NC + 1
         DO 205 I=1,NTERM*2
         A(I) = IWORK(I-1+NC)
  205    CONTINUE
         DO 206 I=1,NTERM*2
         FLUX = FLUX + A(I)*SAMPLE(I)
  206    CONTINUE
         IWORK1(K) = FLUX
  204    CONTINUE
      ELSE
         IF(IX.EQ.1)  THEN
           PHI = -PHASE
           IPHI = INT(PHI)
           PHI = PHI - IPHI
           CALL GETSAMP(SAMPLE,PHI,NTERM,PHASE)
           ENDIF
         NST = NTERM-IPHI
         IF(NST.LT.1)  NST=1
         DO 203 K=NST,NL-IPHI-NTERM
         FLUX = 0.0
         DO 207 J=1,NTERM*2
         A(J) = IWORK(IPHI+K-NTERM+J)
  207    CONTINUE
         DO 208 I=1,NTERM*2
         FLUX = FLUX + A(I)*SAMPLE(I)
  208    CONTINUE
         IWORK1(K) = FLUX
  203    CONTINUE
      ENDIF
C
C
C
  250  DO 202 K=1,NL
       TEMP1(K,IX) = IWORK1(K)
  202  CONTINUE
  400    CONTINUE
      RETURN
      END
C
      SUBROUTINE SHIFT_IMAGE_Y(TEMP,AXIN,PHASE,NTERM)
      INTEGER AXIN(2)
      REAL*4 IWORK(1024),IWORK1(1024),A(200),SAMPLE(200)
      REAL TEMP(AXIN(1),AXIN(2))
      NL = AXIN(1)
      NI = AXIN(2)
      DO 400 IX=1,NL
C
C  **    ZERO OUT RESULT ARRAY
C
         DO 200 J=1,1024
            IWORK1(J)=0
  200       CONTINUE
C
C  **    READ DATA OF THIS X-SECTION
C
      DO 201 K=1,NI
      IWORK(K) = TEMP(IX,K)
  201 CONTINUE
C
C
C
C
      IF(PHASE.GE.0.0)   THEN
         IF(IX.EQ.1)  THEN
           IPHI = INT(PHASE)
           PHI = PHASE - IPHI
           IF(PHI.NE.0.0) PHI=1.0-PHI
           CALL GETSAMP(SAMPLE,PHI,NTERM,PHASE)
         ENDIF
         NC = 0
         NEND = IPHI+1-NTERM
         IF(NEND.GT.0)  NEND=0
      DO 204 K=IPHI+1+NTERM,NI+NEND
         FLUX = 0.0
         NC = NC + 1
         DO 205 I=1,NTERM*2
         A(I) = IWORK(I-1+NC)
  205    CONTINUE
         DO 206 I=1,NTERM*2
         FLUX = FLUX + A(I)*SAMPLE(I)
  206    CONTINUE
         IWORK1(K) = FLUX
  204    CONTINUE
      ELSE
         IF(IX.EQ.1)  THEN
           PHI = -PHASE
           IPHI = INT(PHI)
           PHI = PHI - IPHI
           CALL GETSAMP(SAMPLE,PHI,NTERM,PHASE)
           ENDIF
         NST = NTERM-IPHI
         IF(NST.LT.1)  NST=1
         DO 203 K=NST,NI-IPHI-NTERM
         FLUX = 0.0
         DO 207 J=1,NTERM*2
         A(J) = IWORK(IPHI+K-NTERM+J)
  207    CONTINUE
         DO 208 I=1,NTERM*2
         FLUX = FLUX + A(I)*SAMPLE(I)
  208    CONTINUE
         IWORK1(K) = FLUX
  203    CONTINUE
      ENDIF
C
C
C
  250  DO 202 K=1,NI
       TEMP(IX,K) = IWORK1(K)
  202  CONTINUE
  400    CONTINUE
      RETURN
      END
C
C
      SUBROUTINE GETSAMP(SAMPLE,PHI,NTERM,PHASE)
      REAL*4  SAMPLE(NTERM*2)
      CHARACTER*72  TEXT
      REAL*8  X
C
C    CREATE LOOK UP TABLE OF INTERPOLATION COEFFICIENTS
C
      DO 50 I=1,NTERM*2
      SAMPLE(I) = 0.0
   50 CONTINUE
      IF(PHI.NE.0.0)  THEN
          K = 0
          DO 181 I=(NTERM-1),0,-1
          K = K + 1
          X = (DFLOAT(I)+DBLE(PHI))*3.141592654D0
          SAMPLE(K) = SNGL(DSIN(X)/X)
  181 CONTINUE
          DO 182 I=1,NTERM
          K = K + 1
          X = (DFLOAT(I)-DBLE(PHI))*3.141592654D0
          SAMPLE(K) = SNGL(DSIN(X)/X)
  182 CONTINUE
          CALL COSBEL(SAMPLE,NTERM*2)
      ELSE
          IF(PHASE.LT.0.0)   SAMPLE(NTERM) = 1.0
          IF(PHASE.GE.0.0)   SAMPLE(NTERM+1) = 1.0
      ENDIF
      RETURN
      END
C
C
C
      SUBROUTINE COSBEL(ARRAY,NN)
      REAL*4 ARRAY(NN)
      DO 1001 I=1,NN/10
      FUDGE = SIN(FLOAT(I-1)*1.5708/FLOAT(NN/10))
      ARRAY(I) = FUDGE*ARRAY(I)
      ARRAY(NN+1-I) = FUDGE*ARRAY(NN+1-I)
 1001 CONTINUE
      RETURN
      END
C
C
      SUBROUTINE IMAGE_OUT(IDAT,AXIN,TEMP1)
      INTEGER AXIN(2)
      REAL*4 IDAT(AXIN(1),AXIN(2)),TEMP1(AXIN(1),AXIN(2))
      DO 100 J=1,AXIN(2)
      DO 100 I=1,AXIN(1)
      IDAT(I,J) = TEMP1(I,J)
  100 CONTINUE
      RETURN
      END
