  				 
/*------------------------------------------------------------------------
    File        : subr_CCYY_to_YY.p
    Project     : depot.
    Author(s)   : Harold Luttrell, Sr.
    Created     : Thurs July 21 2014.
    Notes       : A routine to strip the HTML5 century (CCyy) off from the date.
    
    Description : Strips the input HTML5 date (yyyy-mm-dd) to a Progress date field 
                    format and then returns the date for Progress processing.
                    
                  The maximum input html5-date text field length is 10 characters. 
                    
    Usage format:    RUN "../depot/rcode/subr_Strip_YYYY_to_YY.r" (html5-date, OUTPUT Progress-Date). 
                     ASSIGN DB-date-field = Progress-Date.
  
    - - Version History - -
      
          1.0 - Sept 2014 - Original code.

          1.1 - Oct. 3, 2014 - 
                    Modified code to re-format the HTML5 Calendar date 
                    into the Progress date format.                        
                    
    1.2 - written by DOUG LUTTRELL on 14/Apr/16.  Commented out the stuff that causes this sub-procedure to 
            display information.  That can't be the case when compiling from a Windows PC environment to Server 2012.
            Marked by 1dot2.
                                                                  
  ----------------------------------------------------------------------*/ 				 
 	
DEFINE  INPUT    PARAMETER    html5-date     AS CHARACTER FORMAT "x(10)"     NO-UNDO.

DEFINE  OUTPUT   PARAMETER    Progress-Date  AS DATE                         NO-UNDO.

/*   input  example: html5-date = 2014-09-09       */

ASSIGN  Progress-Date = DATE(INT(SUBSTRING(html5-date,6,2)), INT(SUBSTRING(html5-date,9,2)), INT(SUBSTRING(html5-date,1,4))) NO-ERROR.      
    
IF Progress-Date = ? THEN 
    LEAVE.

/***** commented out below in 1dot2 ******/    
/*ELSE                                                           */
/*IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:*/
/*    MESSAGE "Date Error in pgm: subr_CCYY_to_YY.p"  SKIP       */
/*            "Input html5-date  = " html5-date SKIP             */
/*            "Output Progress-Date   = " Progress-Date SKIP     */
/*            "Error-status: = " ERROR-STATUS:ERROR              */
/*            "Error msg:    = " ERROR-STATUS:GET-MESSAGE (1)    */
/*    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                  */
/*END.                                                           */
       
 /* End of SUBROUTINE code. */