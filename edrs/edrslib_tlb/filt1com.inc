 
* COMMON BLOCK TO HOLD THE DATA FOR INTERPOLATING BETWEEN KNOWN
* WAVELENGTHS FOR OPTICAL FILTERS IN THE PROGRAM FILTSPEC
*
* DEFINE THE MAXIMUM NUMBER OF FILTERS AND THE MAXIMUM NUMBER
* OF DATA POINTS PER FILTER
*
      parameter (maxfil=10,maxpts=100)
 
*
* DECLARE ARRAYS, ETC.
*
*    WAVEL - WAVELENGTHS AT WHICH FILTER RESPONSE IS KNOWN
*    DENS - FILTER TRANSMISSION (EXPRESSED AS A DENSITY)
*    ELEMTS - NUMBER (OR THICKNESS) OF FILTER ELEMENTS IN SYSTEM
*    WMIN,WMAX - DEFINE WAVELENGTH RANGE OVER WHICH COMBINED RESPONSE IS
*             CALCULABLE
*    NPTS - NUMBER OF DATA POINTS DEFINING EACH FILTER RESPONSE
*    NFIL - NUMBER OF FILTER RESPONSES STORED
*
      real wavel(maxpts,maxfil),dens(maxpts,maxfil),elemts(maxfil),wmin
     : ,wmax
      integer npts(maxfil),nfil
 
*
* COMMON BLOCK TO HOLD ACCUMULATED FILTER DATA
*
      common /fltbl1/wavel,dens,elemts,wmin,wmax,npts,nfil
