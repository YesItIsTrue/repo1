
/*------------------------------------------------------------------------
    File        : upcreate-doctor-mstr.p
    Description : The external update or create utility program for the doctor-mstr
                    in the HHI database.

    Author(s)   : Trae Luttrell
    Created     : Fri Jul 11 18:01:11 EDT 2014
    Updated     :
    Version     : 1.1
    Notes       :
                
                !!!!! IMPORTANT !!!!! - this is a "second tier" creation program. This means that if there
                    is not a people_ID passed to this program, it will throw an error. You then need to make
                    sure that (A) it is actually passing what you think it is or (B) run the upcreate-people
                    external program to create a people_ID with that number.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
DEFINE INPUT PARAMETER i-ucdoctor-people-id    LIKE people_mstr.people_id           NO-UNDO.
DEFINE INPUT PARAMETER i-ucdoctor-TCP_code     LIKE doctor_mstr.doctor_TCP_code     NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucdoctor-id          LIKE doctor_mstr.doctor_id      NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucdoctor-create      AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucdoctor-update      AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucdoctor-error       AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucdoctor-successful  AS LOGICAL INITIAL NO           NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-ucdoctor-people-id = 0 THEN 
    DO:
        ASSIGN 
            o-ucdoctor-error = YES.
        LEAVE maineblock.
    END. 
    
    ELSE 
    DO:
        
        FIND FIRST doctor_mstr WHERE
            doctor_mstr.doctor_id       = i-ucdoctor-people-id AND
            doctor_mstr.doctor_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE doctor_mstr THEN 
        DO:
            
            /*** this is to allow blank inputs ***/
            ASSIGN
                o-ucdoctor-update                 = YES
                o-ucdoctor-successful             = YES
                doctor_mstr.doctor_modified_date  = TODAY
                doctor_mstr.doctor_modified_by    = USERID("Modules")
                o-ucdoctor-id                     = doctor_mstr.doctor_id                
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE 
        DO:
            
            CREATE doctor_mstr.
            
            ASSIGN
                doctor_mstr.doctor_id            = i-ucdoctor-people-id
                o-ucdoctor-create                = YES
                o-ucdoctor-successful            = YES
                doctor_mstr.doctor_create_date   = TODAY
                doctor_mstr.doctor_created_by    = USERID("Modules")
                doctor_mstr.doctor_modified_date = TODAY
                doctor_mstr.doctor_modified_by   = USERID("Modules")
                o-ucdoctor-id                    = doctor_mstr.doctor_id 
                .
                
        END. /*** of not avail ELSE DO ***/
        
        ASSIGN 
            doctor_mstr.doctor_TCP_code = IF i-ucdoctor-TCP_code  <> "" THEN i-ucdoctor-TCP_code    ELSE doctor_mstr.doctor_TCP_code                  
            doctor_mstr.doctor_prog_name = SOURCE-PROCEDURE:FILE-NAME                         /* 1dot1 */
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */