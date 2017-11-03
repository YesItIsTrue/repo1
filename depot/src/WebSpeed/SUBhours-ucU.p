
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

DEFINE INPUT PARAMETER i-uchours-amount          LIKE Hours_Mstr.Hours_amount           NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-clientid        LIKE Hours_Mstr.Hours_client_ID        NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-projname        LIKE Hours_Mstr.Hours_project_name     NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-date            LIKE Hours_Mstr.Hours_date             NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-desc            LIKE Hours_Mstr.Hours_description      NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-empid           LIKE Hours_Mstr.Hours_employee_ID      NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-translation     LIKE Hours_Mstr.Hours_translation      NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-billed          LIKE Hours_Mstr.Hours_billed           NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-time            LIKE Hours_Mstr.Hours_time             NO-UNDO.
DEFINE INPUT PARAMETER i-uchours-time-desc       LIKE Hours_Mstr.Hours_time_desc        NO-UNDO.
/*DEFINE INPUT PARAMETER i-uchours-progname        LIKE Hours_Mstr.Hours_prog_name        NO-UNDO.*/

DEFINE INPUT PARAMETER i-old-clientid            LIKE Hours_Mstr.Hours_client_ID        NO-UNDO.
DEFINE INPUT PARAMETER i-old-projname            LIKE Hours_Mstr.Hours_project_name     NO-UNDO.
DEFINE INPUT PARAMETER i-old-date                LIKE Hours_Mstr.Hours_date             NO-UNDO.
DEFINE INPUT PARAMETER i-old-time                LIKE Hours_Mstr.Hours_time             NO-UNDO.
DEFINE INPUT PARAMETER i-old-time-desc           LIKE Hours_Mstr.Hours_time_desc        NO-UNDO.   

DEFINE OUTPUT PARAMETER o-uchours-clientid       LIKE Hours_Mstr.Hours_client_ID        NO-UNDO.
DEFINE OUTPUT PARAMETER o-uchours-projname       LIKE Hours_Mstr.Hours_project_name     NO-UNDO.
DEFINE OUTPUT PARAMETER o-uchours-empid          LIKE Hours_Mstr.Hours_employee_ID      NO-UNDO.
DEFINE OUTPUT PARAMETER o-uchours-date           LIKE Hours_Mstr.Hours_date             NO-UNDO.
DEFINE OUTPUT PARAMETER o-uchours-create         AS LOGICAL INITIAL NO                  NO-UNDO.
DEFINE OUTPUT PARAMETER o-uchours-update         AS LOGICAL INITIAL NO                  NO-UNDO.
DEFINE OUTPUT PARAMETER o-uchours-avail          AS LOGICAL INITIAL YES                 NO-UNDO.
DEFINE OUTPUT PARAMETER o-uchours-successful     AS LOGICAL INITIAL NO                  NO-UNDO. 
DEFINE OUTPUT PARAMETER o-uchours-error          AS LOGICAL INITIAL NO                  NO-UNDO.

/* ***************************  Main Block  *************************** */ 

mainblock: 
DO TRANSACTION:

    IF i-uchours-empid = 0 THEN 
    DO:
        ASSIGN 
            o-uchours-error = YES.
        LEAVE mainblock.
    END. 
    
    ELSE 
    DO:
        
        FIND Hours_Mstr WHERE
             Hours_Mstr.Hours_employee_ID    = i-uchours-empid AND 
             Hours_Mstr.Hours_client_ID      = i-old-clientid AND
             Hours_Mstr.Hours_project_name   = i-old-projname AND          
             Hours_Mstr.Hours_date           = i-old-date AND 
             Hours_Mstr.Hours_deleted        = ?
                EXCLUSIVE-LOCK NO-ERROR.
         
        IF AVAILABLE (Hours_Mstr) THEN 
        DO:
        
            IF i-old-clientid <> i-uchours-clientid OR 
               i-old-projname <> i-uchours-projname OR
               i-old-time <> i-uchours-time OR 
               i-old-time-desc <> i-uchours-time-desc OR 
               i-old-date <> i-uchours-date THEN      
        
                ASSIGN 
                    Hours_Mstr.Hours_client_ID = i-uchours-clientid
                    Hours_Mstr.Hours_project_name = i-uchours-projname
                    Hours_Mstr.Hours_time = i-uchours-time
                    Hours_Mstr.Hours_time_desc = i-uchours-time-desc
                    Hours_Mstr.Hours_date = i-uchours-date
                    .
        
            
            ASSIGN
                o-uchours-update                = YES 
                o-uchours-successful            = YES
                Hours_Mstr.Hours_modified_date  = TODAY
                Hours_Mstr.Hours_modified_by    = USERID("Modules")
/*                Hours_Mstr.Hours_prog_name      = i-uchours-progname*/
                o-uchours-clientid              = Hours_Mstr.Hours_client_ID
                o-uchours-projname              = Hours_Mstr.Hours_project_name
                o-uchours-empid                 = Hours_Mstr.Hours_employee_ID    
                o-uchours-date                  = Hours_Mstr.Hours_date                      
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE 
        DO:
            
            CREATE Hours_Mstr.
            
            ASSIGN
                Hours_Mstr.Hours_employee_ID    = i-uchours-empid
                Hours_Mstr.Hours_client_ID      = i-uchours-clientid
                Hours_Mstr.Hours_project_name   = i-uchours-projname
                Hours_Mstr.Hours_date           = i-uchours-date
                o-uchours-create                = YES
                o-uchours-successful            = YES
                Hours_Mstr.Hours_create_date    = TODAY
                Hours_Mstr.Hours_created_by     = USERID("Modules")                    
                Hours_Mstr.Hours_modified_date  = TODAY
                Hours_Mstr.Hours_modified_by    = USERID("Modules") 
/*                Hours_Mstr.Hours_prog_name      = i-uchours-progname*/
                o-uchours-clientid              = Hours_Mstr.Hours_client_ID
                o-uchours-projname              = Hours_Mstr.Hours_project_name    
                o-uchours-empid                 = Hours_Mstr.Hours_employee_ID    
                o-uchours-date                  = Hours_Mstr.Hours_date
                .
                
        END. /*** of not avail ELSE DO ***/
        
        /*** this is to allow blank inputs ***/
        ASSIGN                
            Hours_Mstr.Hours_amount         = IF i-uchours-amount       <> 0  THEN i-uchours-amount         ELSE Hours_Mstr.Hours_amount 
            Hours_Mstr.Hours_description    = IF i-uchours-desc         <> "" THEN i-uchours-desc           ELSE Hours_Mstr.Hours_description  
            Hours_Mstr.Hours_translation    = IF i-uchours-translation  <> "" THEN i-uchours-translation    ELSE Hours_Mstr.Hours_translation 
            Hours_Mstr.Hours_billed         = IF i-uchours-billed       <> ?  THEN i-uchours-billed         ELSE Hours_Mstr.Hours_billed
            Hours_Mstr.Hours_time_desc      = IF i-uchours-time-desc    <> ""  THEN i-uchours-time-desc     ELSE Hours_Mstr.Hours_time_desc
            Hours_Mstr.Hours_time           = IF i-uchours-time         <> ?  THEN i-uchours-time          ELSE Hours_Mstr.Hours_time  
            Hours_Mstr.Hours_prog_name      = SOURCE-PROCEDURE:FILE-NAME                /* 1dot1 */
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */