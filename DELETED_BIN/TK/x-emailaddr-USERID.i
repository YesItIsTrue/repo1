 
/*------------------------------------------------------------------------
    File        : emailaddr-USERID.i
    Purpose     : Have the Solsource USERID's in one include file 
                : for ease of maintenance.
                : It was decided to put this .i file in each
                : Project folder this way we would not create
                : another pathing problem.

    Description : Set up the emailaddr based on the Solsource USERID 
                : testing the program(s) on their own PC's. 

    Author(s)   : Doug Luttrell
    Created     : Wed Jul 08, 2015
    
    Version 1.1 - by Harold Luttrell, Sr.  -  05/Oct/15.
                : Added the default Solsource e-mail address when running at HHI.
                : Identified by /* 1dot1 */

  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

/* Default e-mail address at HHI. */                                            /* 1dot1 */
ASSIGN  emailaddr = "-r hhi.techsupport@mysolsource.com".                       /* 1dot1 */

IF drive_letter = "C" THEN DO:
/*  Drive_letter C logic is for when Solsource employees are testing
    programs on their PC's then if an e-mail is generated it will go to 
    them. */
        
    IF  USERID("General")   = "Doug Luttrell"   OR 
        USERID("HHI")       = "Doug Luttrell"   OR 
        USERID("RS")        = "Doug Luttrell"   THEN 
            ASSIGN 
                emailaddr = "-r doug.luttrell@mysolsource.com".
            
    ELSE IF USERID("General")   = "Harold"  OR  
            USERID("HHI")       = "Harold"  OR  
            USERID("RS")        = "Harold"  THEN 
                ASSIGN 
                    emailaddr = "-r harold.luttrell@mysolsource.com".
            
    ELSE IF USERID("General")   = "Trae"  OR  
            USERID("HHI")       = "Trae"  OR
            USERID("RS")        = "Trae" THEN 
                ASSIGN 
                    emailaddr = "-r trae.luttrell@mysolsource.com".
            
    ELSE 
        ASSIGN 
            emailaddr = "-r hhi.techsupport@mysolsource.com".
    
END.  /** of if drive_letter = C **/
