
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
                
    Version     : 1.1
                : By Harold, Sr.  10/03/2017.
                : Changed the USERID's database names to the CMC database names.
                : Identified by /* 1dot1 */
                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-Admin-Update-OverRyde AS LOGICAL  INITIAL NO   NO-UNDO.
DEFINE INPUT PARAMETER i-testtype       LIKE trh_hist.trh_item      NO-UNDO.
DEFINE INPUT PARAMETER i-tkstat         LIKE trh_hist.trh_action    NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-qty       LIKE trh_hist.trh_qty       NO-UNDO.
DEFINE INPUT PARAMETER i-tk_id          LIKE trh_hist.trh_serial    NO-UNDO.
DEFINE INPUT PARAMETER i-tk_test_seq    LIKE trh_hist.trh_sequence  NO-UNDO.
DEFINE INPUT PARAMETER i-ctrh-date      LIKE trh_hist.trh_create_date     NO-UNDO.
DEFINE INPUT PARAMETER i-mtrh-date      LIKE trh_hist.trh_modified_date   NO-UNDO.
DEFINE INPUT PARAMETER i-trh-date       LIKE trh_hist.trh_date      NO-UNDO.
DEFINE INPUT PARAMETER i-trh_people_id  LIKE trh_hist.trh_people_id NO-UNDO.

DEFINE OUTPUT PARAMETER o-ctrh-id       LIKE trh_hist.trh_id        NO-UNDO.
DEFINE OUTPUT PARAMETER o-ctrh-error    AS LOGICAL INITIAL NO       NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    FIND FIRST  trh_hist WHERE 
                trh_hist.trh_serial   = i-tk_id         AND         /* TK_ID */
                trh_hist.trh_sequence = i-tk_test_seq   AND         /* TK_test_seq */
                trh_hist.trh_action   = i-tkstat        AND         /* TK_status */
                trh_hist.trh_item     = i-testtype      AND         /* Like TK_ID prefix, not test_family */
                trh_hist.trh_deleted  = ?                       
                    EXCLUSIVE-LOCK NO-ERROR.  

    IF  NOT AVAILABLE (trh_hist) THEN DO: 
        
        CREATE trh_hist.
        
        ASSIGN 
            trh_hist.trh_id             = NEXT-VALUE (seq-trh)
            trh_hist.trh_serial         = i-tk_id                         /* TK_ID */
            trh_hist.trh_sequence       = i-tk_test_seq                   /* Tk-ID-sequence-number */
            trh_hist.trh_action         = i-tkstat                        /* TK_status */
            trh_hist.trh_item           = i-testtype                      /* type */  
            trh_hist.trh_created_by     = USERID ("MODULES")                                /* 1dot1 */
            trh_hist.trh_create_date    = i-ctrh-date                     /* 1st date if not blank else 2nd date. */            
            trh_hist.trh_qty            = i-ctrh-qty                        /* 1 */      
            trh_hist.trh_date           = i-trh-date
            trh_hist.trh_people_id      = i-trh_people_id                   /* Tk-ID-people-ID */
            trh_hist.trh_modified_date  = i-mtrh-date
            trh_hist.trh_modified_by    = USERID ("MODULES")                /* 1dot1 */
            trh_hist.trh_prog_name      = THIS-PROCEDURE:FILE-NAME
            o-ctrh-id                   = trh_hist.trh_ID
            .
    END.  /*  IF NOT AVAILABLE (trh_hist)  */
    ELSE 
    IF  i-Admin-Update-OverRyde = YES THEN
        ASSIGN 
            trh_hist.trh_qty            = i-ctrh-qty                        /* 1 */      
            trh_hist.trh_date           = i-trh-date
            trh_hist.trh_people_id      = i-trh_people_id                   /* Tk-ID-people-ID */
            trh_hist.trh_modified_date  = i-mtrh-date
            trh_hist.trh_modified_by    = USERID ("MODULES")                /* 1dot1 */
            trh_hist.trh_prog_name      = THIS-PROCEDURE:FILE-NAME
            o-ctrh-id                   = trh_hist.trh_ID
            .      
 
END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */