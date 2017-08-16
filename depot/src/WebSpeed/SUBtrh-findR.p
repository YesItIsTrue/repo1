
/*------------------------------------------------------------------------
    File        : SUBtrh-findR.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Thu Mar 10 05:48:14 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

findtrh:
DO: 
    
    DEFINE INPUT PARAMETER i-testtype LIKE trh_hist.trh_item NO-UNDO.
    DEFINE INPUT PARAMETER i-tkstat LIKE trh_hist.trh_action NO-UNDO.
    DEFINE INPUT PARAMETER i-TK_ID LIKE trh_hist.trh_serial NO-UNDO.
    DEFINE INPUT PARAMETER i-testseq LIKE trh_hist.trh_sequence NO-UNDO.
/*    DEFINE INPUT PARAMETER i-date LIKE trh_hist.trh_date NO-UNDO.*/
/*    DEFINE INPUT PARAMETER i-createdate LIKE trh_hist.trh_create_date NO-UNDO.*/
    
    DEFINE OUTPUT PARAMETER o-trh_id LIKE trh_hist.trh_id INITIAL 0 NO-UNDO.
    DEFINE OUTPUT PARAMETER o-success AS LOG INITIAL NO NO-UNDO.
    
    
    FIND FIRST trh_hist WHERE trh_hist.trh_item           = i-testtype    AND             /* Like TK_ID prefix, not test_family */
        trh_hist.trh_loc            = ""            AND
        trh_hist.trh_lot            = ""            AND
        trh_hist.trh_serial         = i-TK_ID       AND             /* TK_ID */
        trh_hist.trh_action         = i-tkstat      AND             /* TK_status */
                        
        trh_hist.trh_qty            = 1             AND
        trh_hist.trh_site           = ""            AND
        trh_hist.trh_sequence       = i-testseq     AND             /* TK_test_seq */
/*        trh_hist.trh_date           = i-date        AND*/
/*        trh_hist.trh_create_date    = i-createdate  AND                 /* transaction date */*/
        trh_hist.trh_deleted        = ?                                 /* 1dot1 */       
        NO-LOCK NO-ERROR.  
                            
    IF AVAILABLE (trh_hist) THEN 
        ASSIGN 
            o-trh_id  = trh_hist.trh_id
            o-success = YES.
            
    ELSE 
        ASSIGN 
            o-trh_id  = 0
            o-success = NO.
   
END. /* findtrh */
/* **************************  End of Line  *************************** */