
/*------------------------------------------------------------------------
    File        : TheUTfixer-tk.i
    Purpose     : 

    Syntax      :

    Description : this is the triple find tree for the TK_mstr.

    Author(s)   : Trae Luttrell
    Created     : Tue May 17 11:19:00 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* 

        The {1} is the Test Type that you would like the record to have.
        The {2} is the Test Type that you are checking for. 
        The {3} is the part of the variable name that changes.
     
*/
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

        FIND TK_mstr WHERE 
            HHI.TK_mstr.TK_ID = TK_mstr2.TK_ID AND 
            HHI.TK_mstr.TK_test_type = "{1}" AND 
            HHI.TK_mstr.TK_test_seq = TK_mstr2.TK_test_seq
            AND HHI.TK_mstr.TK_lab_sample_ID = TK_mstr2.TK_lab_sample_ID
            AND HHI.TK_mstr.TK_lab_seq = TK_mstr2.TK_lab_seq
            EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE (TK_mstr) THEN DO:
        
            ASSIGN 
                HHI.TK_mstr.TK_prof = IF (TK_mstr2.TK_prof <> ? AND HHI.TK_mstr.TK_prof = ?) THEN TK_mstr2.TK_prof ELSE HHI.TK_mstr.TK_prof 
                HHI.TK_mstr.TK_test_seq = IF (TK_mstr2.TK_test_seq <> 0 AND HHI.TK_mstr.TK_test_seq = 0) THEN TK_mstr2.TK_test_seq ELSE HHI.TK_mstr.TK_test_seq
                HHI.TK_mstr.TK_domestic = IF (TK_mstr2.TK_domestic <> ? AND HHI.TK_mstr.TK_domestic = ?) THEN TK_mstr2.TK_domestic ELSE HHI.TK_mstr.TK_domestic
                HHI.TK_mstr.TK_cust_ID = IF (TK_mstr2.TK_cust_ID <> 0 AND HHI.TK_mstr.TK_cust_ID = 0) THEN TK_mstr2.TK_cust_ID ELSE HHI.TK_mstr.TK_cust_ID
                HHI.TK_mstr.TK_patient_ID = IF (TK_mstr2.TK_patient_ID <> 0 AND HHI.TK_mstr.TK_patient_ID = 0) THEN TK_mstr2.TK_patient_ID ELSE HHI.TK_mstr.TK_patient_ID
                HHI.TK_mstr.TK_lab_sample_ID = IF (TK_mstr2.TK_lab_sample_ID <> "" AND HHI.TK_mstr.TK_lab_sample_ID = "") THEN TK_mstr2.TK_lab_sample_ID ELSE HHI.TK_mstr.TK_lab_sample_ID
                HHI.TK_mstr.TK_lab_seq = IF (TK_mstr2.TK_lab_seq <> 0 AND HHI.TK_mstr.TK_lab_seq = 0) THEN TK_mstr2.TK_lab_seq ELSE HHI.TK_mstr.TK_lab_seq
                HHI.TK_mstr.TK_test_age = IF (TK_mstr2.TK_lab_seq <> 0 AND HHI.TK_mstr.TK_lab_seq = 0) THEN TK_mstr2.TK_lab_seq ELSE HHI.TK_mstr.TK_lab_seq
                HHI.TK_mstr.TK_status = IF (TK_mstr2.TK_status <> "" AND HHI.TK_mstr.TK_status = "") THEN TK_mstr2.TK_status ELSE HHI.TK_mstr.TK_status
                HHI.TK_mstr.TK_comments = IF (TK_mstr2.TK_comments <> "" AND HHI.TK_mstr.TK_comments = "") THEN TK_mstr2.TK_comments ELSE HHI.TK_mstr.TK_comments
                HHI.TK_mstr.TK_notes = IF (TK_mstr2.TK_notes <> "" AND HHI.TK_mstr.TK_notes = "") THEN TK_mstr2.TK_notes ELSE HHI.TK_mstr.TK_notes
                HHI.TK_mstr.TK_cust_paid = IF (TK_mstr2.TK_cust_paid <> ? AND HHI.TK_mstr.TK_cust_paid = ?) THEN TK_mstr2.TK_cust_paid ELSE HHI.TK_mstr.TK_cust_paid
                HHI.TK_mstr.TK_lbl_print = IF (TK_mstr2.TK_lbl_print <> ? AND HHI.TK_mstr.TK_lbl_print = ?) THEN TK_mstr2.TK_lbl_print ELSE HHI.TK_mstr.TK_lbl_print
                HHI.TK_mstr.TK_lab_paid = IF (TK_mstr2.TK_lab_paid <> ? AND HHI.TK_mstr.TK_lab_paid = ?) THEN TK_mstr2.TK_lab_paid ELSE HHI.TK_mstr.TK_lab_paid
                HHI.TK_mstr.TK_lab_ID = IF (TK_mstr2.TK_lab_ID <> "" AND HHI.TK_mstr.TK_lab_ID = "") THEN TK_mstr2.TK_lab_ID ELSE HHI.TK_mstr.TK_lab_ID
                HHI.TK_mstr.TK_magento_order = IF (TK_mstr2.TK_magento_order <> "" AND HHI.TK_mstr.TK_magento_order = "") THEN TK_mstr2.TK_magento_order ELSE HHI.TK_mstr.TK_magento_order
                HHI.TK_mstr.TK_cust_paid_date = IF (TK_mstr2.TK_cust_paid_date <> ? AND HHI.TK_mstr.TK_cust_paid_date = ?) THEN TK_mstr2.TK_cust_paid_date ELSE HHI.TK_mstr.TK_cust_paid_date
                .
            
            RELEASE TK_mstr.
        
            FIND TK_mstr WHERE 
                HHI.TK_mstr.TK_ID = TK_mstr2.TK_ID AND 
                HHI.TK_mstr.TK_test_type = "{2}" AND 
                HHI.TK_mstr.TK_test_seq = TK_mstr2.TK_test_seq
                AND HHI.TK_mstr.TK_lab_sample_ID = TK_mstr2.TK_lab_sample_ID
                AND HHI.TK_mstr.TK_lab_seq = TK_mstr2.TK_lab_seq
                EXCLUSIVE-LOCK NO-ERROR.
            
            IF AVAILABLE (TK_mstr) THEN DO:
            
                IF updatemode = YES THEN DELETE TK_mstr.
                
                c-tk-{3}-d = c-tk-{3}-d + 1.   
            
            END. /*** available UTM-UEE ***/
            
        END. /*** available UTEE ***/
        
        ELSE DO:
        
            FIND TK_mstr WHERE 
                HHI.TK_mstr.TK_ID = TK_mstr2.TK_ID AND 
                HHI.TK_mstr.TK_test_type = "{2}" AND 
                HHI.TK_mstr.TK_test_seq = TK_mstr2.TK_test_seq
                AND HHI.TK_mstr.TK_lab_sample_ID = TK_mstr2.TK_lab_sample_ID
                AND HHI.TK_mstr.TK_lab_seq = TK_mstr2.TK_lab_seq
                EXCLUSIVE-LOCK NO-ERROR.
            
            IF AVAILABLE (TK_mstr) THEN DO:
            
                IF updatemode = YES THEN ASSIGN TK_mstr.TK_test_type = "{1}".
                    
                ASSIGN c-tk-{3}-u = c-tk-{3}-u + 1.  
            
            END. /*** available UTM-UEE ***/
            
        END. /*** not available UTEE ***/
