
/*------------------------------------------------------------------------
    File        : upcreate-patient-mstr.
    Description : The external updating and creating program for the patient master table.

    Author(s)   : Trae Luttrell
    Created     : Thu Jul 10 12:40:41 EDT 2014
    Updated     : 
    Version     : 1.0
    Notes       : This program is a 'second tier' program, so it is designed around the fact 
                    that you have already made sure that the ID you are passing it is correct, 
                    meaning that you have already CREATED A PEOPLE_ID for the person you are 
                    trying to turn into a patient. 
                 
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
DEFINE INPUT PARAMETER i-ucpatient-people-id    LIKE people_mstr.people_id          NO-UNDO.
DEFINE INPUT PARAMETER i-ucpatient-condition    LIKE patient_mstr.patient_condition NO-UNDO.
DEFINE INPUT PARAMETER i-ucpatient-notes        LIKE patient_mstr.patient_notes     NO-UNDO.
DEFINE INPUT PARAMETER i-ucpatient-RP_ID        LIKE patient_mstr.patient_RP_ID     NO-UNDO.
DEFINE INPUT PARAMETER i-ucpatient-doctor_ID    LIKE patient_mstr.patient_doctor_ID NO-UNDO.
DEFINE INPUT PARAMETER i-ucpatient-cust_ID      LIKE patient_mstr.patient_cust_ID   NO-UNDO.
DEFINE INPUT PARAMETER i-ucpatient-verified     LIKE patient_mstr.patient_verified  NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucpatient-id          LIKE patient_mstr.patient_id    NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpatient-create      AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpatient-update      AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpatient-error       AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpatient-successful  AS LOGICAL INITIAL NO           NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-ucpatient-people-id = 0 THEN 
    DO:
        ASSIGN 
            o-ucpatient-error = YES.
        LEAVE maineblock.
    END. 
    
    ELSE 
    DO:
        
        FIND FIRST patient_mstr WHERE
            patient_mstr.patient_id       = i-ucpatient-people-id AND
            patient_mstr.patient_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE patient_mstr THEN 
        DO: 
            ASSIGN
                o-ucpatient-update                  = YES
                o-ucpatient-successful              = YES
                patient_mstr.patient_modified_date  = TODAY
                patient_mstr.patient_modified_by    = USERID ("HHI")
                o-ucpatient-id                      = patient_mstr.patient_id                
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE 
        DO:
            
            CREATE patient_mstr.
            
            ASSIGN
                patient_mstr.patient_id             = i-ucpatient-people-id
                o-ucpatient-create                  = YES
                o-ucpatient-successful              = YES
                patient_mstr.patient_create_date    = TODAY
                patient_mstr.patient_created_by     = USERID ("HHI")
                patient_mstr.patient_modified_date  = TODAY
                patient_mstr.patient_modified_by    = USERID ("HHI")
                o-ucpatient-id                      = patient_mstr.patient_id 
                .
                
        END. /*** of not avail ELSE DO ***/
        
        ASSIGN 
            patient_mstr.patient_condition  = IF i-ucpatient-condition  <> "" THEN i-ucpatient-condition    ELSE patient_mstr.patient_condition
            patient_mstr.patient_notes      = IF i-ucpatient-notes      <> ?  THEN i-ucpatient-notes        ELSE patient_mstr.patient_notes   
            patient_mstr.patient_RP_ID      = IF i-ucpatient-RP_ID      <> 0  THEN i-ucpatient-RP_ID        ELSE patient_mstr.patient_RP_ID
            patient_mstr.patient_doctor_ID  = IF i-ucpatient-doctor_ID  <> 0  THEN i-ucpatient-doctor_ID    ELSE patient_mstr.patient_doctor_ID
            patient_mstr.patient_cust_ID    = IF i-ucpatient-cust_ID    <> 0  THEN i-ucpatient-cust_ID      ELSE patient_mstr.patient_cust_ID
            patient_mstr.patient_verified   = IF i-ucpatient-verified   <> ?  THEN i-ucpatient-verified     ELSE patient_mstr.patient_verified                
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */