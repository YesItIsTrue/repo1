
/*------------------------------------------------------------------------
    File        : create-trh-hist.p
    Purpose     : To create transaction history records. 

    Description : An external creation (only) program for the trh-hist table.

    Author(s)   : Trae Luttrell
    Created     : Fri Jul 11 21:55:15 EDT 2014
    Updated     : Tue Jul 15 09:54:00 EDT 2014
    Version     : 1.1
    Notes       : As you may have noticed in the name of this program it is not an
                update procedure. This one only creates transaction histories. Since
                trying to change history is morally wrong and supremely ineffective
                in tracking changes. Thou shalt not lie. 
                
                v. 1.1 seq-people to seq-trh bug. Thanks to Harold Luttrell.
  -----------------------------------------------------------------------
                v. 1.2 written by DOUG LUTTRELL based off of 1.1.  This is for the
                        RStP stuff ONLY.  (Since it allows the changing of history.)
                
                v. 1.21 written by DOUG LUTTRELL on 23/Sep/15.  Added the progname field.
                        Marked by 1dot21.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ctrh-id        LIKE trh_hist.trh_id        NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-item      LIKE trh_hist.trh_item      NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-action    LIKE trh_hist.trh_action    NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-qty       LIKE trh_hist.trh_qty       NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-loc       LIKE trh_hist.trh_loc       NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-lot       LIKE trh_hist.trh_lot       NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-serial    LIKE trh_hist.trh_serial    NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-site      LIKE trh_hist.trh_site      NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-sequence  LIKE trh_hist.trh_sequence  NO-UNDO.

DEFINE INPUT PARAMETER i-ctrh-date      LIKE trh_hist.trh_create_date   NO-UNDO.

DEFINE OUTPUT PARAMETER o-ctrh-id       LIKE trh_hist.trh_id        NO-UNDO.
DEFINE OUTPUT PARAMETER o-ctrh-error    AS LOGICAL INITIAL YES      NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-ctrh-id = 0 THEN 
    DO:
    
        CREATE trh_hist.
    
        ASSIGN 
            trh_hist.trh_id             = NEXT-VALUE (seq-trh)
            trh_hist.trh_item           = i-ctrh-item
            trh_hist.trh_action         = i-ctrh-action
            trh_hist.trh_qty            = i-ctrh-qty
            trh_hist.trh_loc            = i-ctrh-loc
            trh_hist.trh_lot            = i-ctrh-lot    
            trh_hist.trh_serial         = i-ctrh-serial        
            trh_hist.trh_create_date    = i-ctrh-date 
            trh_hist.trh_created_by     = USERID ("General")
            trh_hist.trh_modified_date  = i-ctrh-date
            trh_hist.trh_modified_by    = USERID ("General")
            trh_hist.trh_site           = i-ctrh-site
            trh_hist.trh_sequence       = i-ctrh-sequence
            o-ctrh-id                   = trh_hist.trh_id
            o-ctrh-error                = NO         
            trh_hist.trh_prog_name      = THIS-PROCEDURE:FILE-NAME                  /* 1dot21 */
            .      
        
    END.  /*** of no id DO ***/
    
    ELSE 
        
        ASSIGN 
            o-ctrh-error = YES
            .

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */