
/*------------------------------------------------------------------------
    File        : UTIL-mergeclean-U.p
    Purpose     : 

    Syntax      :

    Description : Utility to cleanup records that were merged more than once in the SQL system.

    Author(s)   : Doug Luttrell
    Created     : Fri Nov 20 09:40:23 EST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE x AS INTEGER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

FOR EACH PATIENT_DELETED_RCD 
    BREAK BY PATIENT_DELETED_RCD.PatientID:
                 
    IF FIRST-OF (PATIENT_DELETED_RCD.PatientID) THEN 
        x = 0.
    
    x = x + 1.

    IF LAST-OF (PATIENT_DELETED_RCD.PatientID) THEN DO: 
    
        IF x > 1 THEN DO: 
        
            FIND PATIENT_RCD WHERE PATIENT_RCD.PatLastName = PATIENT_DELETED_RCD.PatLastName AND 
                PATIENT_RCD.PatFirstName = PATIENT_DELETED_RCD.PatLastName AND 
                PATIENT_RCD.PatDOB = PATIENT_DELETED_RCD.PatDOB AND 
                PATIENT_RCD.PatientID <> PATIENT_DELETED_RCD.PatientID EXCLUSIVE-LOCK NO-ERROR.
                
            IF AVAILABLE (PATIENT_RCD) THEN 
                ASSIGN 
                    PATIENT_RCD.Progress_Flag = "U".
                    
            FOR EACH PATIENT_RCD WHERE PATIENT_RCD.PatientID = PATIENT_DELETED_RCD.PatientID EXCLUSIVE-LOCK: 
                
                DISPLAY PATIENT_RCD.PatientID 
                    PATIENT_RCD.PatFirstName FORMAT "x(12)" 
                    PATIENT_RCD.PatLastName FORMAT "x(20)"
                    PATIENT_RCD.PatDOB
                    PATIENT_RCD.Progress_Flag FORMAT "XX" SKIP.
                    
/*                DELETE PATIENT_RCD.*/
                
            END.  /** of 4ea. patient_rcd --- delete patient_rcd **/
        
        END.  /** of if x > 1 **/
                 
        x = 0. 
            
    END.  /** of if last-of patient_id **/                  

END.  /** of 4ea. patient_deleted_rcd **/


/**********************************   END OF FILE  *********************************/