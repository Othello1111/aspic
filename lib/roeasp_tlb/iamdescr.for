C
C
C
      SUBROUTINE IAMDESCR (NAME,STATUS)
C+
C     IAMDESCR.
C
C     Writes a set of descriptors to an EDRS XYlist format file.
C     The descriptors act as titles and are of the format used
C     by the GRASP software. The titles are appropriate to a
C     dataset generated by the ASPIC version of IAM.
C
C  Given;
C   NAME    (C)  Name of the EDRS XYlist.
C  
C  Returned;
C   STATUS  (I)  Return status, = 0 for success.
C
C  Subroutines called;
C   Interim envirn.:-   WRDSCR.
C
C  A C Davenhall./ROE/                                         6/10/83.
C-
      IMPLICIT NONE
C
      INTEGER STATUS
      CHARACTER*(*) NAME
C
      INTEGER INDEX
C
      INTEGER FIELDS
      PARAMETER (FIELDS=15)
      CHARACTER DESCNAM(FIELDS)*7,VALUES(FIELDS)*6
C
      DATA DESCNAM/'HEAD001','HEAD002','HEAD003','HEAD004',
     :             'HEAD005','HEAD006','HEAD007','HEAD008',
     :             'HEAD009','HEAD010','HEAD011','HEAD012',
     :             'HEAD013','HEAD014','HEAD015'/,
     :     VALUES/'UXCEN ','UYCEN ','MAG   ','UMAJAX','UMINAX',
     :            'UTHETA','IXCEN ','IYCEN ','IMAJAX','IMINAX',
     :            'ITHETA','AREA  ','MAXINT','UELLIP','IELLIP'/
      SAVE DESCNAM,VALUES
C
C 
      IF (STATUS.EQ.0) THEN
        DO INDEX=1,FIELDS
          CALL WRDSCR (NAME,DESCNAM(INDEX),VALUES(INDEX),1,STATUS)
        END DO
      END IF
C
      END
