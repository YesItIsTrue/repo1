
/*------------------------------------------------------------------------
    File        : SUBtrh-HL7-U.p
    Purpose     : Creates transaction history records. 

    Description : An external creation (only) program for the HL7 trh-hist data.
                  NOTE: 
                    Must set the trh_date to the 1st and/or 2nd dates from 
                    the HL7 input data  as the collected date and set the processed 
                    date to TODAY and set the received date from the date on the input file. 
    Author(s)   : Harold Luttrell, Sr.
    Created     : June 19, 2014
 
    Version     : 1.0
    Notes       : Original code.
                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ctrh-id        LIKE trh_hist.trh_id        NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-item      LIKE trh_hist.trh_item      NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-action    LIKE trh_hist.trh_action    NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-qty       LIKE trh_hist.trh_qty       NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-serial    LIKE trh_hist.trh_serial    NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-sequence  LIKE trh_hist.trh_sequence  NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-date      LIKE trh_hist.trh_create_date     NO-UNDO.
DEFINE INPUT PARAMETER i-mtrh-date      LIKE trh_hist.trh_modified_date   NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-trh-date  LIKE trh_hist.trh_date      NO-UNDO.
DEFINE INPUT PARAMETER i-trh_people_id  LIKE trh_hist.trh_people_id NO-UNDO.

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
            trh_hist.trh_item           = i-ctrh-item               /* type */
            trh_hist.trh_action         = i-ctrh-action             /* tk-status */
            trh_hist.trh_qty            = i-ctrh-qty                /* 1 */  
            trh_hist.trh_serial         = i-ctrh-serial             /* tk_id */      
            trh_hist.trh_create_date    = i-ctrh-date               /* 1st date if not blank else 2nd date. */
            trh_hist.trh_created_by     = USERID ("General")
            trh_hist.trh_modified_date  = i-mtrh-date
            trh_hist.trh_modified_by    = USERID ("General")
            trh_hist.trh_sequence       = i-ctrh-sequence           /* Tk-ID-sequence-number */
            trh_hist.trh_date           = i-ctrh-trh-date
            trh_hist.trh_people_id      = i-trh_people_id           /* Tk-ID-people-ID */
            o-ctrh-id                   = trh_hist.trh_id
            o-ctrh-error                = NO         
            trh_hist.trh_prog_name      = THIS-PROCEDURE:FILE-NAME.      
                      
    END.  /*** of no id DO ***/
    
    ELSE 
        
        ASSIGN 
            o-ctrh-error = YES
            .

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */