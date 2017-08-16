   				 
/*------------------------------------------------------------------------
    File        : subr_Up_Low_Case.p
    Project     : Subroutines.
    Author(s)   : Harold Luttrell, Sr.
    Created     : Thurs Jan 09 2014.
    Notes       : A standard routine that can be used in any PROJECT code.
    
    Description : Program converts the first letter of each word to 
                    UPPER CASE and converts all of the remaining 
                    letters in each word to lower case.
                    
                  The maximum input text field length is set to 60 characters. 
                    
    Usage format: There are a number of different ways you can code/use 
                    this subroutine.  In your <SCRIPT LANGUAGE="SpeedScript"> section, 
                    code one of the following, either example 1 or 2 or 3 or 4.
                    You should use the 1st example, which would make it easier to change
                    the program (subr_Up_Low_Case.p) location.
                        
                    1.  DEFINE VARIABLE    codetorun   AS CHARACTER   NO-UNDO.
                        ASSIGN codetorun = '../depot/rcode/subr_Up_Low_Case.r'.

                        RUN VALUE (codetorun) (ip-city, OUTPUT op_text-out). 
                        ASSIGN ip-city = op_text-out.
                    or    
                        RUN VALUE (codetorun) ('fort Walton beach', OUTPUT op_text-out). 
                        ASSIGN ip-city = op_text-out.
                        
                    2.  RUN "../depot/rcode/subr_Up_Low_Case.r" 
                                (ip-lab-address1, OUTPUT op_text). 
                        ASSIGN ip-lab-address1 = op_text. 
                    
                    3.  RUN "../depot/rcode/subr_Up_Low_Case.r" 
                                ('fort walton beach', OUTPUT op_text-out).
                        ASSIGN ip-city = op_text-out. 
                           
                    4.  ASSIGN ip_text = ip-cust-name.
                        RUN "../depot/rcode/subr_Up_Low_Case.r" (ip_text, OUTPUT op_text). 
                        ASSIGN ip-cust-name = op_text.
                                    
    Revision 1  : 1/11/2014 - By Harold Luttrell, Sr.
                    Added instructions (above) and comments within the code.   
                                    
    Revision 2  : 2/26/2014 - By Harold Luttrell, Sr.
                    Added code to convert the 1st letter after a dash (-) 
                    within the name or data and added code to convert the
                    3rd letter after the characters 'Mc' to UpperCase.                         
  ----------------------------------------------------------------------*/ 				 
	
DEFINE  INPUT    PARAMETER    ip_text     AS CHARACTER FORMAT "x(60)"     NO-UNDO.
 
DEFINE  OUTPUT   PARAMETER    op_text     AS CHARACTER FORMAT "x(60)"     NO-UNDO.
   
DEFINE VARIABLE text_position             AS INTEGER   FORMAT "99"        NO-UNDO.
DEFINE VARIABLE ip_length                 AS INTEGER   FORMAT "99"        NO-UNDO.

/* get the length of the input data, to use for the DO LOOP.  */
     
ip_length = LENGTH(ip_text, "CHARACTER").

/* Converts the first letter of the first word to UPPER CASE and
   converts all of the remaining input data to lower case  
   while moving the input data to the output data area. */
   
ASSIGN op_text = CAPS(SUBSTRING(ip_text, 1, 1) ) + LC(SUBSTRING(ip_text, 2) ). 

/* Loop, converting the first character of each word to UPPER case or CAPS. */

UP-low-LOOP:        /* LABEL for DO LOOP so we can get out when done. */
         
    DO text_position = 1 TO ip_length: 
              
/* Finds the position of a space between each word */ 
        text_position     = INDEX(op_text,' ',text_position).
            
/* Get out of the loop when done because the INDEX command returns a zero value
   when it reaches the end of the entire input data. */             
        IF TEXT_POSITION = 0 THEN
            LEAVE UP-low-LOOP.
                
/* Increase the text_position by 1 to start on the next word. */                 
        text_position     = text_position + 1.

/* Convert the first letter to UPPER CASE. */            
        SUBSTRING(op_text, text_position, 1)  =  CAPS(SUBSTRING(op_text, text_position, 1) ).
    
    END.    /** end of DO statement. **/
    
ASSIGN text_position = 0.    
ASSIGN text_position = INDEX(op_text, '-', 1).
IF  text_position > 0 THEN 
    ASSIGN SUBSTRING(op_text, (text_position + 1), 1) = CAPS(SUBSTRING(op_text, (text_position + 1), 1) ).

ASSIGN text_position = 0.    
ASSIGN text_position = INDEX(op_text, 'Mc', 1).
IF  text_position > 0 THEN 
    ASSIGN SUBSTRING(op_text, (text_position + 2), 1) = CAPS(SUBSTRING(op_text, (text_position + 2), 1) ).   
        
 /* End of SUBROUTINE code. */