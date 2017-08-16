  				 
/*------------------------------------------------------------------------
    File        : JERK_DATE_AROUND.p
    Project     : Subroutines.
    Author(s)   : Harold Luttrell, Sr.
    Created     : Thurs Mar 28 2014.
    Notes       : A one-time routine to be used in the SQL to Progress process.
    
    Description : Moves the input date (yyyy-mm-dd) to a temp field as mm-dd-yyyy 
                    and then move the temp field back to the input date field.
                    
                  The maximum input text field length is set to 60 characters. 
                    
    Usage format: There are a number of different ways you can code/use 
                    this subroutine.  In your <SCRIPT LANGUAGE="SpeedScript"> section, 
                    code one of the following, either example 1 or 2 or 3 or 4.
                    You should use the 1st example, which would make it easier to change
                    the program (JERK_DATE_AROUND.p) location.
                                             
                    1.  ASSIGN ip_text = ip-date field.
                        RUN "..\Subroutines\rcode\JERK_DATE_AROUND.p" (ip_text, OUTPUT op_text). 
                        ASSIGN ip-date field = op_text.
                                                            
  ----------------------------------------------------------------------*/ 				 
 	
DEFINE  INPUT    PARAMETER    ip_text     AS CHARACTER FORMAT "x(40)"     NO-UNDO.
 
DEFINE  OUTPUT   PARAMETER    op_text     AS CHARACTER FORMAT "x(40)"     NO-UNDO.
 
/*MESSAGE "ip_text = " ip_text                                     */
/*                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/
ASSIGN op_text = ''.

/*   input =  2012-12-06       */
ASSIGN 
    SUBSTRING(op_text, 1, 3) = SUBSTRING(ip_text, 6, 3).
ASSIGN 
    SUBSTRING(op_text, 4, 2) = SUBSTRING(ip_text, 9, 2). 
ASSIGN 
    SUBSTRING(op_text, 6, 1) = '-'.
ASSIGN 
    SUBSTRING(op_text, 7, 4) = SUBSTRING(ip_text, 1, 4). 
ASSIGN 
    SUBSTRING(op_text, 13, 12) = SUBSTRING(ip_text, 12, 12).

/*MESSAGE "op_text = " op_text                                     */
/*                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/
                               
 /* End of SUBROUTINE code. */