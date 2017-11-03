
/*------------------------------------------------------------------------
    File        : create-trh-hist.p
    Purpose     : To create transaction history records. 

    Description : An external creation (only) program for the trh-hist table.

    Author(s)   : Trae Luttrell
    Created     : Fri Jul 11 21:55:15 EDT 2014
    Updated     : Tue Jul 15 09:54:00 EDT 2014
    Version     : 1.3
    Notes       : As you may have noticed in the name of this program it is not an
                update procedure. This one only creates transaction histories. Since
                trying to change history is morally wrong and supremely ineffective
                in tracking changes. Thou shalt not lie. 
                
                v. 1.1 seq-people to seq-trh bug. Thanks to Harold Luttrell.
                v. 1.2 By Jacob Luttrell on 16Feb16. Added fields from 
                        trh_comments to trh_ref to match new database design 
                        with v11.1 release.
                v. 2.0 By Jacob Luttrell on 10Mar16. Changed program from simply creating
                        a new record each time it now can update existing records.          
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
/* 1dot2 --> */
DEFINE INPUT PARAMETER i-ctrh-comments  LIKE trh_hist.trh_comments  NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-other     LIKE trh_hist.trh_other_ID  NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-people    LIKE trh_hist.trh_people_ID NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-order     LIKE trh_hist.trh_order     NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-date      LIKE trh_hist.trh_date      NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-time      LIKE trh_hist.trh_time      NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-ref       LIKE trh_hist.trh_ref       NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-warehouse       LIKE trh_hist.trh_warehouse       NO-UNDO.
/* <-- 1dot2 */


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
/*            trh_hist.trh_qty            = i-ctrh-qty*/
/*            trh_hist.trh_loc            = i-ctrh-loc*/
/*            trh_hist.trh_lot            = i-ctrh-lot*/
            trh_hist.trh_serial         = i-ctrh-serial        
            trh_hist.trh_create_date    = TODAY 
            trh_hist.trh_created_by     = USERID("Modules")
/*            trh_hist.trh_modified_date  = TODAY             */
/*            trh_hist.trh_modified_by    = USERID("Modules")*/
/*            trh_hist.trh_site           = i-ctrh-site       */
            trh_hist.trh_sequence       = i-ctrh-sequence
/*        /* 1dot2 --> */                                     */
/*            trh_hist.trh_comments       = i-ctrh-comments   */
/*            trh_hist.trh_other_ID       = i-ctrh-other      */
/*            trh_hist.trh_people_ID      = i-ctrh-people     */
/*            trh_hist.trh_order          = i-ctrh-order      */
/*            trh_hist.trh_date           = i-ctrh-date       */
/*            trh_hist.trh_time           = i-ctrh-time       */
/*            trh_hist.trh_ref            = i-ctrh-ref        */
/*        /* <-- 1dot2 */                                     */
/*            o-ctrh-id                   = trh_hist.trh_id   */
/*            o-ctrh-error                = NO                */
            .      
        
    END.  /*** of no id DO ***/
 /* 2dot0 --> */
    ASSIGN 
        trh_hist.trh_qty            = IF i-ctrh-qty         = 0  THEN trh_hist.trh_qty ELSE i-ctrh-qty 
        trh_hist.trh_loc            = IF i-ctrh-loc         = "" THEN trh_hist.trh_loc ELSE i-ctrh-loc 
        trh_hist.trh_lot            = IF i-ctrh-lot         = "" THEN trh_hist.trh_lot ELSE i-ctrh-lot     
        trh_hist.trh_modified_date  = TODAY
        trh_hist.trh_modified_by    = USERID("Modules")
        trh_hist.trh_site           = IF i-ctrh-site        = "" THEN trh_hist.trh_site ELSE i-ctrh-site 
        /* 1dot2 --> */
        trh_hist.trh_comments       = IF i-ctrh-comments    = "" THEN trh_hist.trh_comments ELSE i-ctrh-comments 
        trh_hist.trh_other_ID       = IF i-ctrh-other       = "" THEN trh_hist.trh_other_ID ELSE i-ctrh-other 
        trh_hist.trh_people_ID      = IF i-ctrh-people      = 0  THEN trh_hist.trh_people_id ELSE i-ctrh-people 
        trh_hist.trh_order          = IF i-ctrh-order       = "" THEN trh_hist.trh_order ELSE i-ctrh-order
        trh_hist.trh_date           = IF i-ctrh-date        = ?  THEN trh_hist.trh_date ELSE i-ctrh-date 
        trh_hist.trh_time           = IF i-ctrh-time        = "" THEN trh_hist.trh_time ELSE i-ctrh-time
        trh_hist.trh_ref            = IF i-ctrh-ref         = "" THEN trh_hist.trh_ref ELSE i-ctrh-ref 
        /* <-- 1dot2 */
        trh_hist.trh_prog_name      = SOURCE-PROCEDURE:FILE-NAME            /* 2dot0 */              
        o-ctrh-id                   = trh_hist.trh_id
        o-ctrh-error                = NO    
        .   
 /* <-- 2dot0 */   
/*    ELSE                      */
/*                              */
/*        ASSIGN                */
/*            o-ctrh-error = YES*/
/*            .                 */

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */