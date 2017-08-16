
/*------------------------------------------------------------------------
    File        : SUBlabid-findR.p
    Purpose     : This is the external find Lab-ID program.

    Description : Validates the input Lab ID against the lab_mstr table. 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Mon Jan 09 10:53:03 CST 2017 
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT  PARAMETER i-flab-ID      LIKE lab_mstr.lab_ID       NO-UNDO. 

DEFINE OUTPUT PARAMETER o-flab-name    LIKE lab_mstr.lab_name     NO-UNDO.
DEFINE OUTPUT PARAMETER o-flab-error   AS LOGICAL INITIAL NO          NO-UNDO.

/* ***************************  Main Block  *************************** */

ASSIGN  o-flab-error = YES. 
   
FIND FIRST  lab_mstr WHERE
            lab_mstr.lab_ID         = i-flab-ID AND 
            lab_mstr.lab_deleted    = ?
    NO-LOCK 
    USE-INDEX lab-main-idx
    NO-ERROR.

IF AVAILABLE lab_mstr THEN DO:
    
    ASSIGN 
        o-flab-name     = lab_mstr.lab_name
        o-flab-error    = NO.
        
END.  /** IF AVAILABLE lab_mstr **/
      
/* *********************  END OF SUBROUTINE  ************************** */  
                           