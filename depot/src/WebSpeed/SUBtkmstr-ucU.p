
/*------------------------------------------------------------------------
    File        : upcreate-TK-mstr.p

    Description : The create external program for the TK_mstr table in the HHI Database

    Author(s)   : Trae Luttrell
    Created     : Tue Aug 12 12:24:28 EDT 2014
    Updated     : Thur Sep 11 23:28:00 MST 2014
    Version     : 1.1
    
        - - Version History - - 
        
            0.4 - Based on upcreate-addr-mstr.p , I've gone through and change all the names
            of the different fields and made a variable for every field, however I don't think
            the ID's work like they did in the other tables. For example, its a Character value
            instead of an Integer. 
                   
            1.0 - seems to be working, no testing has been done on this particular upcreate.
            
            1.1 - Sept 11 2014 - Changed to match new DB structure
            1.2 - Feb 12 2016 - Changed to match new DB structure Marked with 1dot2
            1.3 - Mar 11 2016 - Added prog_name updater.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-uctkm-id               LIKE TK_mstr.TK_id              NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-test_type        LIKE TK_mstr.TK_test_type       NO-UNDO.    /* 1dot2 */
DEFINE INPUT PARAMETER i-uctkm-prof             LIKE TK_mstr.TK_prof            NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-test_seq         LIKE TK_mstr.TK_test_seq        NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-domestic         LIKE TK_mstr.TK_domestic        NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-cust_ID          LIKE TK_mstr.TK_cust_ID         NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-patient_ID       LIKE TK_mstr.TK_patient_ID      NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-lab_sample_ID    LIKE TK_mstr.TK_lab_sample_ID   NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-lab_seq          LIKE TK_mstr.TK_lab_seq         NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-test_age         LIKE TK_mstr.TK_test_age        NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-lab_ID           LIKE TK_mstr.TK_lab_ID          NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-status           LIKE TK_mstr.TK_status          NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-comments         LIKE TK_mstr.TK_comments        NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-notes            LIKE TK_mstr.TK_notes           NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-cust_paid        LIKE TK_mstr.tk_cust_paid       NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-lbl_print        LIKE TK_mstr.tk_lbl_print       NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-lab_paid         LIKE TK_mstr.tk_lab_paid        NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-mage_order       LIKE TK_mstr.TK_magento_order   NO-UNDO.    /* 1dot2 */
DEFINE INPUT PARAMETER i-uctkm-cust_pd_date     LIKE TK_mstr.TK_cust_paid_date  NO-UNDO.    /* 1dot2 */
/*DEFINE INPUT PARAMETER i-uctkm-prog_name        LIKE TK_mstr.TK_prog_name       NO-UNDO.    /* 1dot3 */*/

DEFINE OUTPUT PARAMETER o-uctkm-id              LIKE TK_mstr.TK_id              NO-UNDO.
DEFINE OUTPUT PARAMETER o-uctkm-create          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-uctkm-update          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-uctkm-avail           AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE OUTPUT PARAMETER o-uctkm-successful      AS LOGICAL INITIAL NO           NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:
    
    IF i-uctkm-id = "" THEN DO:
    
        CREATE TK_mstr.
    
        ASSIGN
            TK_mstr.TK_id               = i-uctkm-test_type + "-" + STRING (NEXT-VALUE(seq-TK)) /* 1dot2 */
            TK_mstr.TK_test_type        = i-uctkm-test_type                                     /* 1dot2 */
            TK_mstr.TK_prof             = i-uctkm-prof
            TK_mstr.TK_test_seq         = i-uctkm-test_seq
            TK_mstr.TK_domestic         = i-uctkm-domestic
            TK_mstr.TK_cust_ID          = i-uctkm-cust_ID
            TK_mstr.TK_patient_ID       = i-uctkm-patient_ID
            TK_mstr.TK_lab_sample_ID    = i-uctkm-lab_sample_ID
            TK_mstr.TK_lab_seq          = i-uctkm-lab_seq
            TK_mstr.TK_test_age         = i-uctkm-test_age
            TK_mstr.TK_lab_ID           = i-uctkm-lab_ID
            TK_mstr.TK_status           = i-uctkm-status
            TK_mstr.TK_comments         = i-uctkm-comments
            TK_mstr.TK_notes            = i-uctkm-notes
            TK_mstr.TK_create_date      = TODAY
            TK_mstr.TK_created_by       = USERID("Modules")
            TK_mstr.TK_modified_date    = TODAY
            TK_mstr.TK_modified_by      = USERID("Modules")
            TK_mstr.TK_cust_paid        = i-uctkm-cust_paid
            TK_mstr.TK_lbl_print        = i-uctkm-lbl_print
            TK_mstr.TK_lab_paid         = i-uctkm-lab_paid
            o-uctkm-create              = YES 
            o-uctkm-successful          = YES
            o-uctkm-id                  = TK_mstr.TK_id
            TK_mstr.TK_magento_order    = i-uctkm-mage_order                                    /* 1dot2 */
            TK_mstr.TK_cust_paid_date   = i-uctkm-cust_pd_date                                  /* 1dot2 */
            TK_mstr.TK_prog_name        = SOURCE-PROCEDURE:FILE-NAME                            /* 1dot3 */
            . 
            
    END. /*** of if id = "" THEN DO: ***/
    
    ELSE DO:
        
        FIND TK_mstr WHERE
            TK_mstr.TK_id       = i-uctkm-id AND 
            TK_mstr.TK_test_seq = i-uctkm-test_seq AND
            TK_mstr.TK_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE TK_mstr THEN DO:
            
            /*** this is to allow blank inputs ***/
            ASSIGN
                o-uctkm-update              = YES
                o-uctkm-successful          = YES
                TK_mstr.TK_modified_date    = TODAY
                TK_mstr.TK_modified_by      = USERID("Modules")
                o-uctkm-id                  = TK_mstr.TK_id
                TK_mstr.TK_test_type        = IF i-uctkm-test_type      <> "" THEN i-uctkm-test_type        ELSE TK_mstr.TK_test_type       /* 1dot2 */
                TK_mstr.TK_prof             = IF i-uctkm-prof           <> ?  THEN i-uctkm-prof             ELSE TK_mstr.TK_prof   
                TK_mstr.TK_test_seq         = IF i-uctkm-test_seq       <> 0  THEN i-uctkm-test_seq         ELSE TK_mstr.TK_test_seq   
                TK_mstr.TK_domestic         = IF i-uctkm-domestic       <> ?  THEN i-uctkm-domestic         ELSE TK_mstr.TK_domestic  
                TK_mstr.TK_cust_ID          = IF i-uctkm-cust_ID        <> 0  THEN i-uctkm-cust_ID          ELSE TK_mstr.TK_cust_ID
                TK_mstr.TK_patient_ID       = IF i-uctkm-patient_ID     <> 0  THEN i-uctkm-patient_ID       ELSE TK_mstr.TK_patient_ID   
                TK_mstr.TK_lab_sample_ID    = IF i-uctkm-lab_sample_ID  <> "" THEN i-uctkm-lab_sample_ID    ELSE TK_mstr.TK_lab_sample_ID
                TK_mstr.TK_lab_seq          = IF i-uctkm-lab_seq        <> 0  THEN i-uctkm-lab_seq          ELSE TK_mstr.TK_lab_seq               
                TK_mstr.TK_test_age         = IF i-uctkm-test_age       <> 0  THEN i-uctkm-test_age         ELSE TK_mstr.tk_test_age
                TK_mstr.TK_lab_ID           = IF i-uctkm-lab_ID         <> "" THEN i-uctkm-lab_ID           ELSE TK_mstr.TK_lab_ID
                TK_mstr.TK_status           = IF i-uctkm-status         <> "" THEN i-uctkm-status           ELSE TK_mstr.TK_status
                TK_mstr.TK_comments         = IF i-uctkm-comments       <> "" THEN i-uctkm-comments         ELSE TK_mstr.TK_comments
                TK_mstr.TK_notes            = IF i-uctkm-notes          <> "" THEN i-uctkm-notes            ELSE TK_mstr.TK_notes
                TK_mstr.TK_cust_paid        = IF i-uctkm-cust_paid      <> ?  THEN i-uctkm-cust_paid        ELSE TK_mstr.TK_cust_paid
                TK_mstr.TK_lbl_print        = IF i-uctkm-lbl_print      <> ?  THEN i-uctkm-lbl_print        ELSE TK_mstr.TK_lbl_print 
                TK_mstr.TK_lab_paid         = IF i-uctkm-lab_paid       <> ?  THEN i-uctkm-lab_paid         ELSE TK_mstr.TK_lab_paid
                TK_mstr.TK_magento_order    = IF i-uctkm-mage_order     <> "" THEN i-uctkm-mage_order       ELSE TK_mstr.TK_magento_order   /* 1dot2 */
                TK_mstr.TK_cust_paid_date   = IF i-uctkm-cust_pd_date   <> ?  THEN i-uctkm-cust_pd_date     ELSE TK_mstr.TK_cust_paid_date  /* 1dot2 */
                TK_mstr.TK_prog_name        = SOURCE-PROCEDURE:FILE-NAME                                                                    /* 1dot3 */
                . 
                
        END. /*** of avail TK_mstr DO: ***/
        
        /*-- no need for a ELSE ASSIGN o-uctkm-successful = NO because that is the initial value for that variable --*/
         
    END. /*** of no id ELSE DO: ***/ 
    
END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */         