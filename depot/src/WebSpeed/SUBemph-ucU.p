
/*------------------------------------------------------------------------
    File        : Subr-emphU.p
    Purpose     : Database Maintenance

    Syntax      :

    Description : Subroutine to update the Emph_hist
    Version     : 1.1 
    Author(s)   : Jacob Luttrell
    Created     : Wed Dec 30 11:24:59 MST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucemph-id           LIKE Emph_hist.Emph_emp_ID        NO-UNDO.
DEFINE INPUT PARAMETER i-ucemph-action       LIKE Emph_hist.Emph_action        NO-UNDO.
DEFINE INPUT PARAMETER i-ucemph-actiondate   LIKE Emph_hist.Emph_action_date   NO-UNDO.
DEFINE INPUT PARAMETER i-ucemph-payrate      LIKE Emph_hist.Emph_payrate       NO-UNDO.
DEFINE INPUT PARAMETER i-ucemph-notes        LIKE Emph_hist.Emph_notes         NO-UNDO.
/*DEFINE INPUT PARAMETER i-ucemph-progname     LIKE Emph_hist.Emph_prog_name     NO-UNDO.*/
DEFINE INPUT PARAMETER i-ucemph-createby     LIKE Emph_hist.Emph_created_by    NO-UNDO.
DEFINE INPUT PARAMETER i-ucemph-createdate   LIKE Emph_hist.Emph_create_date   NO-UNDO.
DEFINE INPUT PARAMETER i-ucemph-modifiedby   LIKE Emph_hist.Emph_modified_by   NO-UNDO.
DEFINE INPUT PARAMETER i-ucemph-modifieddate LIKE Emph_hist.Emph_modified_date NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucemph-id          LIKE Emph_hist.Emph_emp_ID        NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemph-action      LIKE Emph_hist.Emph_action        NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemph-actiondate  LIKE Emph_hist.Emph_action_date   NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemph-create      AS LOGICAL INITIAL NO             NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemph-update      AS LOGICAL INITIAL NO             NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemph-avail       AS LOGICAL INITIAL YES            NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucemph-successful  AS LOGICAL INITIAL NO             NO-UNDO. 
DEFINE OUTPUT PARAMETER o-ucemph-error       AS LOGICAL INITIAL NO             NO-UNDO.

/* ***************************  Main Block  *************************** */

mainblock: 
DO TRANSACTION:

    IF i-ucemph-id = 0 THEN 
    DO:
        ASSIGN 
            o-ucemph-error = YES.
        LEAVE mainblock.
    END. 
    
    ELSE 
    DO:
        
        FIND FIRST Emph_hist WHERE
                   Emph_hist.Emph_emp_ID      = i-ucemph-id AND
                   Emph_hist.Emph_action      = i-ucemph-action AND 
                   Emph_hist.Emph_action_date = i-ucemph-actiondate AND
                   Emph_hist.Emph_deleted     = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE Emph_hist THEN 
        DO:
            
            ASSIGN
                o-ucemph-update              = YES
                o-ucemph-successful          = YES
                Emph_hist.Emph_modified_date = TODAY
                Emph_hist.Emph_modified_by   = USERID ("General")
/*                Emph_hist.Emph_prog_name     = i-ucemph-progname*/
                o-ucemph-id                  = Emph_hist.Emph_emp_ID
                o-ucemph-action              = Emph_hist.Emph_action
                o-ucemph-actiondate          = Emph_hist.Emph_action_date                
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE 
        DO:
            
            CREATE Emph_hist.
            
            ASSIGN
                Emph_hist.Emph_emp_ID        = i-ucemph-id
                Emph_hist.Emph_action        = i-ucemph-action 
                Emph_hist.Emph_action_date   = i-ucemph-actiondate
                o-ucemph-create              = YES
                o-ucemph-successful          = YES
                Emph_hist.Emph_create_date   = TODAY
                Emph_hist.Emph_created_by    = USERID ("General")                    
                Emph_hist.Emph_modified_date = TODAY
                Emph_hist.Emph_modified_by   = USERID ("General") 
/*                Emph_hist.Emph_prog_name     = i-ucemph-progname*/
                o-ucemph-id                  = Emph_hist.Emph_emp_ID
                o-ucemph-action              = Emph_hist.Emph_action
                o-ucemph-actiondate          = Emph_hist.Emph_action_date 
                .
                
        END. /*** of not avail ELSE DO ***/
        
        /*** this is to allow blank inputs ***/
        ASSIGN 
            Emph_hist.Emph_notes      = IF i-ucemph-notes     <> "" THEN i-ucemph-notes        ELSE Emph_hist.Emph_notes   
            Emph_hist.Emph_payrate    = IF i-ucemph-payrate   <> 0  THEN i-ucemph-payrate      ELSE Emph_hist.Emph_payrate   
            Emph_hist.Emph_prog_name  = SOURCE-PROCEDURE:FILE-NAME                  /* 1dot1 */     
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */