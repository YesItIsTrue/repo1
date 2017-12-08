
/*------------------------------------------------------------------------
    File        : SUBhours-ucU.p
    Purpose     : Database Update

    Syntax      :

    Description : Subroutine to create and update the Hours_Mstr table in the TimeSheet database

    Version     : 1.1

    Author(s)   : Jacob Luttrell
    Created     : Fri Jan 01 09:21:22 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-amount          LIKE Hours_Mstr.Hours_amount           NO-UNDO.
DEFINE INPUT PARAMETER i-clientid        LIKE Hours_Mstr.Hours_client_ID        NO-UNDO.
DEFINE INPUT PARAMETER i-projname        LIKE Hours_Mstr.Hours_project_name     NO-UNDO.
DEFINE INPUT PARAMETER i-date            LIKE Hours_Mstr.Hours_date             NO-UNDO.
DEFINE INPUT PARAMETER i-desc            LIKE Hours_Mstr.Hours_description      NO-UNDO.
DEFINE INPUT PARAMETER i-empid           LIKE Hours_Mstr.Hours_employee_ID      NO-UNDO.
DEFINE INPUT PARAMETER i-translation     LIKE Hours_Mstr.Hours_translation      NO-UNDO.
DEFINE INPUT PARAMETER i-billed          LIKE Hours_Mstr.Hours_billed           NO-UNDO.
DEFINE INPUT PARAMETER i-time            LIKE Hours_Mstr.Hours_time             NO-UNDO.
DEFINE INPUT PARAMETER i-time-desc       LIKE Hours_Mstr.Hours_time_desc        NO-UNDO.

DEFINE INPUT PARAMETER i-old-clientid            LIKE Hours_Mstr.Hours_client_ID        NO-UNDO.
DEFINE INPUT PARAMETER i-old-projname            LIKE Hours_Mstr.Hours_project_name     NO-UNDO.
DEFINE INPUT PARAMETER i-old-date                LIKE Hours_Mstr.Hours_date             NO-UNDO.
DEFINE INPUT PARAMETER i-old-time                LIKE Hours_Mstr.Hours_time             NO-UNDO.
DEFINE INPUT PARAMETER i-old-time-desc           LIKE Hours_Mstr.Hours_time_desc        NO-UNDO.   
 
DEFINE OUTPUT PARAMETER o-success          AS LOGICAL INITIAL NO                  NO-UNDO.

/* ***************************  Main Block  *************************** */ 

mainblock: 
DO TRANSACTION:

    IF i-empid <> 0 THEN DO:
        
        FIND FIRST Hours_Mstr WHERE
             Hours_Mstr.Hours_employee_ID    = i-empid AND 
             Hours_Mstr.Hours_client_ID      = i-old-clientid AND
             Hours_Mstr.Hours_project_name   = i-old-projname AND          
             Hours_Mstr.Hours_date           = i-old-date
             EXCLUSIVE-LOCK NO-ERROR.
         
        IF AVAILABLE (Hours_Mstr) THEN DO:
        
            IF i-old-clientid <> i-clientid OR 
               i-old-projname <> i-projname OR
               i-old-time <> i-time OR 
               i-old-time-desc <> i-time-desc OR 
               i-old-date <> i-date THEN      
        
                ASSIGN 
                    Hours_Mstr.Hours_client_ID = i-clientid
                    Hours_Mstr.Hours_project_name = i-projname
                    Hours_Mstr.Hours_time = i-time
                    Hours_Mstr.Hours_time_desc = i-time-desc
                    Hours_Mstr.Hours_date = i-date
                    .
        
            
            ASSIGN
                o-success            = YES
                Hours_Mstr.Hours_modified_date  = TODAY
                Hours_Mstr.Hours_modified_by    = USERID("Modules")
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
        ELSE DO:
            
            CREATE Hours_Mstr.
            
            ASSIGN
                Hours_Mstr.Hours_employee_ID    = i-empid
                Hours_Mstr.Hours_client_ID      = i-clientid
                Hours_Mstr.Hours_project_name   = i-projname
                Hours_Mstr.Hours_date           = i-date
                o-success                       = YES
                Hours_Mstr.Hours_create_date    = TODAY
                Hours_Mstr.Hours_created_by     = USERID("Modules")                    
                Hours_Mstr.Hours_modified_date  = TODAY
                Hours_Mstr.Hours_modified_by    = USERID("Modules") 
                .
                
        END. /*** of not avail ELSE DO ***/
        
        /*** this is to allow blank inputs ***/
        ASSIGN                
            Hours_Mstr.Hours_amount         = IF i-amount       <> 0  THEN i-amount         ELSE Hours_Mstr.Hours_amount 
            Hours_Mstr.Hours_description    = IF i-desc         <> "" THEN i-desc           ELSE Hours_Mstr.Hours_description  
            Hours_Mstr.Hours_translation    = IF i-translation  <> "" THEN i-translation    ELSE Hours_Mstr.Hours_translation 
            Hours_Mstr.Hours_billed         = IF i-billed       <> ?  THEN i-billed         ELSE Hours_Mstr.Hours_billed
            Hours_Mstr.Hours_time_desc      = IF i-time-desc    <> ""  THEN i-time-desc     ELSE Hours_Mstr.Hours_time_desc
            Hours_Mstr.Hours_time           = IF i-time         <> ?  THEN i-time          ELSE Hours_Mstr.Hours_time  
            Hours_Mstr.Hours_prog_name      = SOURCE-PROCEDURE:FILE-NAME                /* 1dot1 */
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */