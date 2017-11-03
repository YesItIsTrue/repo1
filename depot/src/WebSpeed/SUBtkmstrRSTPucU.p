
/*------------------------------------------------------------------------
    File        : SUBtkmstrRSTPucU.p
    Purpose     : This is similar to the SUBtkmst-ucU.p however, this will allow you to give an 
        id to this program, and it will create a new on one if it can't find it.

    Author(s)   : Trae Luttrell
    Created     : Sat Dec 20 20:17:04 MST 2014
    Updated     : Sat Dec 20 20:17:04 MST 2014
    Version     : 1.0 
    Notes       : Do not use this with normal code! This is only for the RSTP stuff.
    
    Version 1.1 - Doug Luttrell - 06/Jan/15.  Added ability to pass create and modified dates in.
                    Scratch that.  Handled it a different way.  I think I commented out all
                    my changes, so there is no net effect, but I left them in in case we 
                    need them for something later they can be uncommented.
                    
    Version 1.11 - written by DOUG LUTTRELL on 23/Sep/15.  Added the progname field.  
                    Also release the TK_mstr when done, just in case.  Marked by 1dot11.                    
    
    Version 2.0 - written by Harold LUTTRELL on 15/Feb/16.  Change the field name
                    from 'testtype' to 'test_type' per database changes.  
                    Marked by /* 2dot0 */.  
     
    Version 2.1 - written by Jacob Luttrell on 14/Mar/16.  Added new fields from v11.1.
                    Marked by 1dot2.    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-uctkm-id               LIKE TK_mstr.TK_id              NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-testtype         LIKE TK_mstr.TK_test_type       NO-UNDO.        			/* 2dot0 */
DEFINE INPUT PARAMETER i-uctkm-prof             LIKE TK_mstr.TK_prof            NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-test_seq         LIKE TK_mstr.TK_test_seq        NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-domestic         LIKE TK_mstr.TK_domestic        NO-UNDO.	/* 5 */
DEFINE INPUT PARAMETER i-uctkm-cust_ID          LIKE TK_mstr.TK_cust_ID         NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-patient_ID       LIKE TK_mstr.TK_patient_ID      NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-lab_sample_ID    LIKE TK_mstr.TK_lab_sample_ID   NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-lab_seq          LIKE TK_mstr.TK_lab_seq         NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-test_age         LIKE TK_mstr.TK_test_age        NO-UNDO.	/* 10 */
DEFINE INPUT PARAMETER i-uctkm-lab_ID           LIKE TK_mstr.TK_lab_ID          NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-status           LIKE TK_mstr.TK_status          NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-comments         LIKE TK_mstr.TK_comments        NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-notes            LIKE TK_mstr.TK_notes           NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-cust_paid        LIKE TK_mstr.tk_cust_paid       NO-UNDO.	/* 15 */
DEFINE INPUT PARAMETER i-uctkm-lbl_print        LIKE TK_mstr.tk_lbl_print       NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-lab_paid         LIKE TK_mstr.tk_lab_paid        NO-UNDO.
DEFINE INPUT PARAMETER i-uctkm-magento          LIKE TK_mstr.TK_magento_order   NO-UNDO.        			/* 2dot1 */
DEFINE INPUT PARAMETER i-uctkm-cust-paid-date   LIKE TK_mstr.TK_cust_paid_date  NO-UNDO.	/* 19 */		/* 2dot1 */
/*DEFINE INPUT PARAMETER i-uctkm-prog_name        LIKE TK_mstr.TK_prog_name       NO-UNDO.        			/* 2dot1 */*/
/*DEFINE INPUT PARAMETER i-create-date            LIKE TK_mstr.TK_create_date     NO-UNDO.*/
/*DEFINE INPUT PARAMETER i-mod-date               LIKE TK_mstr.TK_modified_date   NO-UNDO.*/

DEFINE OUTPUT PARAMETER o-uctkm-id              LIKE TK_mstr.TK_id              NO-UNDO.
DEFINE OUTPUT PARAMETER o-uctkm-create          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-uctkm-update          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-uctkm-avail           AS LOGICAL INITIAL YES          NO-UNDO.    /* 1dot11 - not used, could be deleted if fix all calling code */
DEFINE OUTPUT PARAMETER o-uctkm-successful      AS LOGICAL INITIAL NO           NO-UNDO.	/* 5 output */

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:
    
    FIND TK_mstr WHERE TK_mstr.TK_ID = i-uctkm-id AND 
        TK_mstr.TK_test_seq = i-uctkm-test_seq AND 
        TK_mstr.TK_deleted = ? EXCLUSIVE-LOCK NO-ERROR.
    
    IF NOT AVAILABLE TK_mstr THEN DO:
    
        CREATE TK_mstr.
    
        ASSIGN
            TK_mstr.TK_id               = i-uctkm-id /* i-uctkm-testtype + "-" + STRING (NEXT-VALUE(seq-TK)) */
            TK_mstr.TK_test_type        = i-uctkm-testtype                                      /* 2dot0 */
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
/*            TK_mstr.TK_create_date      = i-create-date*/
            TK_mstr.TK_create_date      = TODAY
            TK_mstr.TK_created_by       = USERID("Modules")
/*            TK_mstr.TK_modified_date    = i-mod-date*/
            TK_mstr.TK_modified_date    = TODAY
            TK_mstr.TK_modified_by      = USERID("Modules")
            TK_mstr.TK_cust_paid        = i-uctkm-cust_paid
            TK_mstr.TK_lbl_print        = i-uctkm-lbl_print
            TK_mstr.TK_lab_paid         = i-uctkm-lab_paid
            o-uctkm-create              = YES 
            o-uctkm-successful          = YES
            o-uctkm-id                  = TK_mstr.TK_id
/*            TK_mstr.tk_prog_name        = THIS-PROCEDURE:FILE-NAME                          /* 1dot11 */*/
            TK_mstr.TK_magento_order    = i-uctkm-magento                                     /* 2dot1 */
            TK_mstr.TK_cust_paid_date   = i-uctkm-cust-paid-date                              /* 2dot1 */
/*            TK_mstr.TK_prog_name        = i-uctkm-prog_name                                   /* 2dot1 */*/
            TK_mstr.TK_prog_name        = SOURCE-PROCEDURE:FILE-NAME                          /* 2dot1 */
            
            . 
            
    END. /*** of not available THEN DO: ***/
    
    ELSE DO: /*** If available ***/
            
            /*** this is to allow blank inputs ***/
            ASSIGN
                o-uctkm-update              = YES
                o-uctkm-successful          = YES
/*                TK_mstr.TK_modified_date    = i-mod-date*/
                TK_mstr.TK_modified_date    = TODAY
                TK_mstr.TK_modified_by      = USERID("Custom")
                o-uctkm-id                  = TK_mstr.TK_id
                TK_mstr.TK_test_type        = IF i-uctkm-testtype       <> "" THEN i-uctkm-testtype         ELSE TK_mstr.TK_test_type              /* 2dot0 */
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
                TK_mstr.TK_magento_order    = IF i-uctkm-magento        <> "" THEN i-uctkm-magento          ELSE TK_mstr.TK_magento_order         /* 2dot1 */
                TK_mstr.TK_cust_paid_date   = IF i-uctkm-cust-paid-date <> ?  THEN i-uctkm-cust-paid-date   ELSE TK_mstr.TK_cust_paid_date        /* 2dot1 */
/*                TK_mstr.tk_prog_name        = THIS-PROCEDURE:FILE-NAME              /* 1dot11 */*/
/*                TK_mstr.TK_prog_name        = i-uctkm-prog_name                                                                                   /* 2dot1 */*/
                TK_mstr.TK_prog_name        = SOURCE-PROCEDURE:FILE-NAME                          /* 2dot1 */                
                . 
         
    END. /*** of no id ELSE DO: ***/ 
    
    RELEASE TK_mstr.                                                /** 1dot11 */
    
END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */      