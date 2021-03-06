      subroutine rescl4(iin,npix,nlin,bscale,bzero,blank,iout,pinval,
     :                  allrej)
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*PURPOSE
*       To rescale the input image from real format to
*       signed word format by calculating values for bscale and bzero
*       which map the range of input data onto 0.75 of the available
*       signed word number range.
*
*SOURCE
*       RESCL4.FOR in UTILITIES.TLB
*
*ARGUMENTS
*   INPUTS:
*       iin     real array      The input image
*       npix    integer         No. of pixels in each line of the input
*       nlin    integer         No. of lines in the input
*       bscale  real            Scale factor
*       bzero   real            Zero level
*       blank   real            Blank pixel value
*       pinval  logical         If true, then there are some blank pixels
*   OUTPUTS:
*       bscale  real            Scale factor for I*2 image
*       bzero   real            Zero level for I*2 image
*       blank   real            Invalid pixel value for I*2 image
*       iout    integer*2 array The output image
*       allrej  logical         Set true if there are no valid pixels in input
*
*USED BY
*       EDRSIN
*
*SUBROUTINE CALLED
*       None
*
*AUTHOR
*       D.S. Berry (MAVAD::DSB) 26/8/87
*-------------------------------------------------------------------------
*
      parameter (minint=-32767,maxint=32767,inval=-32767)
      real      iin(npix,nlin)
      integer*2 iout(npix,nlin)
      logical   pinval,allrej
*
* FIND THE MAXIMUM AND MINIMUM VALUES OF THE INTEGER INPUT DATA VALUES
*
      allrej=.true.
      do j=1,npix
         do i=1,nlin
            if(iin(i,j).ne.blank.or.(.not.pinval)) then
               valmax=iin(i,j)
               valmin=valmax
               allrej=.false.
               goto 10
            endif
         enddo
      enddo
  10  if(.not.allrej) then
         do j=1,nlin
            do i=1,npix
               rval=iin(i,j)
               if(rval.ne.blank.or.(.not.pinval)) then
                  if(rval.gt.valmax) valmax=rval
                  if(rval.lt.valmin) valmin=rval
               endif
            enddo
         enddo
* CALCULATE BSCALE AND BZERO WHICH WILL RESULT IN THE INPUT DATA
* BEING MAPPED ON TO 0.75 OF THE ENTIRE OUTPUT RANGE
*
         scale=bscale*(valmax-valmin)/(0.75*(maxint-minint))
         zero=bzero+bscale*((valmax+valmin)-
     :         (maxint+minint)*(valmax-valmin)/(0.75*(maxint-minint)))/2
*
* CALCULATE FACTORS FOR SCALING THE INPUT VALUES DIRECTLY ONTO
* THE OUTPUT INTEGERS
*
         if(scale.ne.0) then
            a=bscale/scale
            b=(bzero-zero)/scale
         else
            a=0
            b=0
         endif
*
* RESCALE THE INPUT, GIVING BLANK PIXELS THE EDRS 'INVALID' VALUE
*
         do j=1,nlin
            do i=1,npix
               rval=iin(i,j)
               if(rval.eq.blank.and.pinval) then
                  iout(i,j)=inval
               else
                  iout(i,j)=a*rval+b
               endif
            enddo
         enddo
*
* UPDATE SCALE AND ZERO VALUES AND RETURN
*
         blank=inval
         bscale=scale
         bzero=zero

      endif

      end
