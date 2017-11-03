
/*------------------------------------------------------------------------
    File        : Subr-empU.p
    Purpose     : Database Maintenance

    Syntax      :

    Description : Subroutine to update the Emp_Mstr
    
    Version     : 1.1

    Author(s)   : Jacob Luttrell
    Created     : Wed Dec 30 10:40:05 MST 2015 
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucemp-id           LIKE Emp_Mstr.Emp_ID            NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-admin        LIKE Emp_Mstr.Emp_admin         NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-dept         LIKE Emp_Mstr.Emp_dept          NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-basepay      LIKE Emp_Mstr.Emp_base_pay      NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-raisedate    LIKE Emp_Mstr.Emp_raise_date    NO-UNDO.
/*DEFINE INPUT PARAMETER i-ucemp-progname     LIKE Emp_Mstr.Emp_prog_name     NO-UNDO.*/
DEFINE INPUT PARAMETER i-ucemp-loadedpay    LIKE Emp_Mstr.Emp_loaded_pay    NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-transdef     LIKE Emp_Mstr.Emp_trans_def     NO-UNDO.    
DEFINE INPUT PARAMETER i-ucemp-createby     LIKE Emp_Mstr.Emp_created_by    NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-createdate   LIKE Emp_Mstr.Emp_create_date   NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-modifiedby   LIKE Emp_Mstr.Emp_modified_by   NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-modifieddate LIKE Emp_Mstr.Emp_modified_date NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-def_client   LIKE Emp_Mstr.Emp_def_client NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-def_proj     LIKE Emp_Mstr.Emp_def_proj NO-UNDO.
DEFINE INPUT PARAMETER i-ucemp-type         LIKE Emp_Mstr.Emp_type NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucemp-id          LIKE Emp_Mstr.Emp_ID            NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemp-create      AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemp-update      AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemp-avail       AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemp-successful  AS LOGICAL INITIAL NO           NO-UNDO. 
DEFINE OUTPUT PARAMETER o-ucemp-error       AS LOGICAL INITIAL NO           NO-UNDO.

/* ***************************  Main Block  *************************** */

mainblock: 
DO TRANSACTION:

    IF i-ucemp-id = 0 THEN 
    DO:
        ASSIGN 
            o-ucemp-error = YES.
        LEAVE mainblock.
    END. 
    
    ELSE 
    DO:
        
        FIND FIRST Emp_Mstr WHERE
            Emp_Mstr.Emp_ID       = i-ucemp-id AND
            Emp_Mstr.Emp_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE Emp_Mstr THEN 
        DO:
            
            ASSIGN
                o-ucemp-update              = YES
                o-ucemp-successful          = YES
                Emp_Mstr.Emp_modified_date  = TODAY
                Emp_Mstr.Emp_modified_by    = USERID("Modules") 
/*                Emp_Mstr.Emp_prog_name      = i-ucemp-progname*/
                o-ucemp-id                  = Emp_Mstr.Emp_ID                
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE 
        DO:
            
            CREATE Emp_Mstr.
            
            ASSIGN
                Emp_Mstr.Emp_ID            = i-ucemp-id
                o-ucemp-create             = YES
                o-ucemp-successful         = YES
                Emp_Mstr.Emp_create_date   = TODAY
                Emp_Mstr.Emp_created_by    = USERID("Modules")                    
                Emp_Mstr.Emp_modified_date = TODAY
                Emp_Mstr.Emp_modified_by   = USERID("Modules") 
/*                Emp_Mstr.Emp_prog_name     = i-ucemp-progname*/
                o-ucemp-id                 = Emp_Mstr.Emp_ID 
                .
                
        END. /*** of not avail ELSE DO ***/
        
        /*** this is to allow blank inputs ***/
        ASSIGN 
            Emp_Mstr.Emp_loaded_pay = IF i-ucemp-loadedpay <> 0  THEN i-ucemp-loadedpay    ELSE Emp_Mstr.Emp_loaded_pay
            Emp_Mstr.Emp_trans_def  = IF i-ucemp-transdef  <> "" THEN i-ucemp-transdef     ELSE Emp_Mstr.Emp_trans_def   
            Emp_Mstr.Emp_admin      = IF i-ucemp-admin     <> ?  THEN i-ucemp-admin        ELSE Emp_Mstr.Emp_admin   
            Emp_Mstr.Emp_dept       = IF i-ucemp-dept      <> "" THEN i-ucemp-dept         ELSE Emp_Mstr.Emp_dept   
            Emp_Mstr.Emp_base_pay   = IF i-ucemp-basepay   <> 0  THEN i-ucemp-basepay      ELSE Emp_Mstr.Emp_base_pay                
            Emp_Mstr.Emp_raise_date = IF i-ucemp-raisedate <> ?  THEN i-ucemp-raisedate    ELSE Emp_Mstr.Emp_raise_date
            Emp_Mstr.Emp_def_proj   = IF i-ucemp-def_proj  <> ""  THEN i-ucemp-def_proj    ELSE Emp_Mstr.Emp_def_proj
            Emp_Mstr.Emp_def_client = IF i-ucemp-def_client <> 0  THEN i-ucemp-def_client    ELSE Emp_Mstr.Emp_def_client
            Emp_Mstr.Emp_type       = IF i-ucemp-type       <> ""  THEN i-ucemp-type    ELSE Emp_Mstr.Emp_type 
            Emp_Mstr.Emp_prog_name  = SOURCE-PROCEDURE:FILE-NAME                    /* 1dot1 */
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */