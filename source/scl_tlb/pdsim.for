!
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!
!       !!!!!!!!!!!!!
!       !           !
!       ! PDSIM.SCL !
!       !           !
!       !!!!!!!!!!!!!
!
!
!
! THIS TAKES THE OUTPUT FROM PDSMULTI AND TURNS IT INTO A
! PROPER LINEAR, BUT NOT FLAT FIELDED, IMAGE ON THE DISK.
!
! THE 'CLEAR' IMAGE SHOULD HAVE THE SAME NAME AS THE MAIN IMAGE
! EXCEPT THAT IT SHOULD HAVE AN EXTRA Z AT THE END OF THE NAME.
!
!
! THE STANDARD LOOK UP TABLE FOR THE PDS READING-DENSITY CALIBRATION
! IS STORED IN THE ASPIC DIRECTORY AS 'PDSCAL'.
! THAT IS AS RGVAD::SYS:[STARLINK.PACK.ASPIC]PDSCAL.BDF
!    BUT THIS IS ONLY FOR USE WITH THE 2.5+5.0 PMT, 0.8 LOG
!    SETTING AS IN JAN 1982. YOU MUST MAKE YOUR OWN FOR OTHER
!    SETTINGS OR IF IT HAS CHANGED
!
!
!
!
!
!
! WRITTEN BY:-
!     A.J.PENNY                                            83-6-4
!--------------------------------------------------------------------
!
!
! USES PROGRAMS :-
!          PDSCOR
!
!
! -----------------------------------------------------------------
!
!
!
!
WRITE SYS$OUTPUT "THE TEMPORARY FILES ARE PUT ON THE SAME DISK AS THE INPUT"
WRITE SYS$OUTPUT " "
INQUIRE P1 "PDS MAIN IMAGE HAS NAME (INCLUDE DISK PREFIX) ? "
WRITE SYS$OUTPUT " "
WRITE SYS$OUTPUT "THE CLEAR IMAGE IS ASSUMED TO HAVE THAT FOLLOWED BY Z"
WRITE SYS$OUTPUT " "
INQUIRE P2 "OUTPUT FILE NAME (INCLUDE DISK PREFIX) ?"
WRITE SYS$OUTPUT " "
!
!
!
INQUIRE P5 "PDS CORRECTION LUT FILE (INCLUDE DISK PREFIX) ?"
!
!
!
INQUIRE P7 "TYPE Y FOR FILM SATURATION TO BE ALLOWED FOR, N FOR NOT"
IF P7 .EQS. "N" THEN GOTO 7A
INQUIRE P4 "FILM SATURATION DENSITY?"
7A:
!
!
!
LET PDSCOR_IMAGE='P1'
LET PDSCOR_ITFTABLE='P5'
LET PDSCOR_IMAGER='P1'Z
LET PDSCOR_NUMSEG= 
LET PDSCOR_NTERMS= 
LET PDSCOR_DEVICE=VERS
LET PDSCOR_DEVSIZE=20,20
LET PDSCOR_TEXT=
LET PDSCOR_RANGE1=
LET PDSCOR_RANGE2=
IF P7 .EQS. "Y" THEN LET PDSCOR_CHOICE=YES
IF P7 .EQS. "N" THEN LET PDSCOR_CHOICE=NO
LET PDSCOR_OUTPUT='P2'
LET PDSCOR_TITLE= 
PDSCOR
!
!
