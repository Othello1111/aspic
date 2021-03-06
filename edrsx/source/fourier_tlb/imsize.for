      subroutine imsize(insiz,outsiz,ierr)
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*PURPOSE
*       Calculates the size of an image axis which can be used by 
*	NAG Fourier transform routines. If the input value is acceptable
*	then it is returned as the output value. Otherwise the next 
*	largest acceptable size is returned.
*
*SOURCE
*       IMSIZE.FOR in FOURIER.TLB
*
*METHOD
*       The axis size must not have any prime factors greater than
*       19, and must not have more than 20 prime factors (including
*       repeated factors).
*          If these conditions are not met by the supplied axis
*       size, the output axis size is incremented and the test
*       repeated.
*
*ARGUMENTS
*   INPUTS:
*       insiz   integer         The input axis size
*   OUTPUTS:
*       outsiz  integer         The output axis size
*       ierr    integer         Error status 0 - Success
*                                            1 - Failure
*
*SUBROUTINES CALLED
*       none
*
*VAX SPECIFICS
*       implicit none
*       do while
*       enddo
*       end of line comments
*
*AUTHOR
*       D.S. Berry (MAVAD::DSB) 20/4/88
*-------------------------------------------------------------------
*
      implicit none

*
* DECLARE ARGUMENTS
*
      integer   insiz,outsiz,ierr

*
* DECLARE LOCAL VARIABLES
*
      logical more      ! True if answer not found
      integer factor    ! No. of prime factors in insiz
      integer iprime    ! Pointer to current prime factor
      integer primes(8) ! Array to hold primes upto 19
      integer reming    ! Value remaining after division by prime factor

      data primes/2,3,5,7,11,13,17,19/

*
* INITIALISE THINGS
*
      ierr=0
      outsiz=insiz-1
      more=.true.

*
* LOOP UNTIL SUCCESS OR FAILURE DETECTED
*
      do while(more)

*
* INCREMENT OUTPUT IMAGE SIZE
*
         outsiz=outsiz+1

*
* CHECK THAT OUTSIZ HAS NO PRIME FACTOR GREATER THAN 19, AND THAT
* IT DOESN'T HAVE MORE THAN 20 PRIME FACTORS IN TOTAL.
*
         reming=outsiz
         factor=0
         iprime=1
         do while(iprime.le.8.and.more)

*
* IF REMING IS DIVISIBLE BY THE CURRENT PRIME, DIVIDE OUT THE EFFECT
* OF THIS FACTOR AND INCREMENT NO OF FACTORS. IF AFTER DIVISION,
* THE REMAINING VALUE IS ONE, THEN SUCCESS.
*
           if(mod(reming,primes(iprime)).eq.0) then
               reming=reming/primes(iprime)
               factor=factor+1
               if(reming.eq.1) more=.false.
            else

*
* IF THE CURRENT PRIME DOES NOT GO INTO REMING, THEN TRY THE NEXT PRIME
*
               iprime=iprime+1
            endif
         enddo

*
* IF SUCCESS WAS ACHIEVED WITH MORE THAN 20 FACTORS THEN IT WON'T DO
*
         if(factor.gt.20) more=.true.

*
* IF NO SUCCESSFUL VALUE HAS BEEN FOUND AND THE OUTPUT IMAGE IS TWICE
* THE SIZE OF THE INPUT IMAGE, THEN GIVE UP.
*
         if(outsiz.gt.2*insiz) then
            ierr=1
            more=.false.
         endif
      enddo

*
* FINISH
*
      end
