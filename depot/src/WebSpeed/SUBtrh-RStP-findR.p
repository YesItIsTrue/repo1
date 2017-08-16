
/*------------------------------------------------------------------------
    File        : SUBtrh-RStP-findR.p
    Purpose     : To find transaction history records from a historical date. 

    Author(s)   : Doug Luttrell
    Created     : Sat Sep 26 12:30:00 EDT 2015
    Updated     : Sat Sep 26 12:30:00 EDT 2015
    Version     : 1.0
    Notes       : Based on the former internal procedure "findtrh".
                
    Revision History:
    -----------------
    1.0 - written by DOUG LUTTRELL on 26/Sep/15.  Based on findtrh internal 
            procedure that was within the RStP-MPA_RCD-U-1.p code.  
            
    1.1 - written by DOUG LUTTRELL on 04/Dec/15.  Added the trh_deleted code
            so that deleted transaction history records are not accessed.
            Marked by 1dot1.
    
    2.0 - By Harold Luttrell on 26/feb/16.  Change the incoming date to be 
            stored in the new trh_date field.
            Identified by /* 2dot0 */.
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

findtrh:
DO: 
    
    DEFINE INPUT PARAMETER i-testtype LIKE trh_hist.trh_item NO-UNDO.
    DEFINE INPUT PARAMETER i-tkstat LIKE trh_hist.trh_action NO-UNDO.
    DEFINE INPUT PARAMETER i-TK_ID LIKE trh_hist.trh_serial NO-UNDO.
    DEFINE INPUT PARAMETER i-testseq LIKE trh_hist.trh_sequence NO-UNDO.
    DEFINE INPUT PARAMETER i-trhdate LIKE trh_hist.trh_date NO-UNDO.            /* 2dot0 */
    
    DEFINE OUTPUT PARAMETER o-trh_id LIKE trh_hist.trh_id INITIAL 0 NO-UNDO.
    DEFINE OUTPUT PARAMETER o-success AS LOG INITIAL NO NO-UNDO.
    
    
    FIND FIRST trh_hist WHERE trh_hist.trh_item     = i-testtype    AND         /* Like TK_ID prefix, not test_family */
                        trh_hist.trh_loc            = ""            AND
                        trh_hist.trh_lot            = ""            AND
                        trh_hist.trh_serial         = i-TK_ID       AND         /* TK_ID */
                        trh_hist.trh_action         = i-tkstat      AND         /* TK_status */
                        
                        trh_hist.trh_qty            = 1             AND
                        trh_hist.trh_site           = ""            AND
                        trh_hist.trh_sequence       = i-testseq     AND         /* TK_test_seq */
                        trh_hist.trh_date           = i-trhdate     AND         /* transaction date */  /* 2dot0 */
                        trh_hist.trh_deleted        = ?                         /* 1dot1 */
                            NO-LOCK NO-ERROR.  
                            
    IF AVAILABLE (trh_hist) THEN 
        ASSIGN 
            o-trh_id    = trh_hist.trh_id
            o-success   = YES.
            
    ELSE 
        ASSIGN 
            o-trh_id    = 0
            o-success   = NO.
   
END. /* findtrh */
/* **************************  End of Line  *************************** */