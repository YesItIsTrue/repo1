
/*------------------------------------------------------------------------
    File        : RStP-pull-current-data-R.p
    Purpose     : 

    Syntax      :

    Description : Exports data that has been modified since a certain date.

    Author(s)   : Doug Luttrell
    Created     : Tue Jan 20 10:44:03 EST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE sinceday AS DATE LABEL "Since Date" NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
UPDATE SKIP(1)
    sinceday COLON 20 SKIP(1)
        WITH FRAME inward WIDTH 80 SIDE-LABELS.


/**************  General Database Section  *********************/

PAUSE 0 BEFORE-HIDE. 

/** addr_mstr **/
DISPLAY "Starting addr_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\addr_mstr.txt".

FOR EACH addr_mstr WHERE addr_mstr.addr_modified_date > sinceday NO-LOCK: 
    
    EXPORT addr_mstr.
    
END.  /** of 4ea. addr_mstr **/

OUTPUT CLOSE.
    
    
/** att_files **/
DISPLAY "Starting att_files export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\att_files.txt".

FOR EACH att_files WHERE att_files.att_modified_date > sinceday NO-LOCK: 
    
    EXPORT att_files.
    
END.  /** of 4ea. att_files **/

OUTPUT CLOSE.


/** bd_bill_det **/
DISPLAY "Starting bd_bill_det export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\bd_bill_det.txt".

FOR EACH bd_bill_det WHERE bd_bill_det.bd_modified_date > sinceday NO-LOCK: 
    
    EXPORT bd_bill_det.
    
END.  /** of 4ea. bd_bill_det **/

OUTPUT CLOSE.


/** bm_bill_mstr **/
DISPLAY "Starting bm_bill_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\bm_bill_mstr.txt".

FOR EACH bm_bill_mstr WHERE bm_bill_mstr.bm_modified_date > sinceday NO-LOCK: 
    
    EXPORT bm_bill_mstr.
    
END.  /** of 4ea. bm_bill_mstr **/

OUTPUT CLOSE.


/** country_mstr **/
DISPLAY "Starting country_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\country_mstr.txt".

FOR EACH country_mstr WHERE country_mstr.country_modified_date > sinceday NO-LOCK: 
    
    EXPORT country_mstr.
    
END.  /** of 4ea. country_mstr **/

OUTPUT CLOSE.


/** cust_mstr **/
DISPLAY "Starting cust_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\cust_mstr.txt".

FOR EACH cust_mstr WHERE cust_mstr.cust_modified_date > sinceday NO-LOCK: 
    
    EXPORT cust_mstr.
    
END.  /** of 4ea. cust_mstr **/

OUTPUT CLOSE.


/** err_message **/
DISPLAY "Starting err_message export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\err_message.txt".

FOR EACH err_message WHERE err_message.err_modified_date > sinceday NO-LOCK: 
    
    EXPORT err_message.
    
END.  /** of 4ea. err_message **/

OUTPUT CLOSE.


/** grp_mstr **/
DISPLAY "Starting grp_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\grp_mstr.txt".

FOR EACH grp_mstr WHERE grp_mstr.grp_modified_date > sinceday NO-LOCK: 
    
    EXPORT grp_mstr.
    
END.  /** of 4ea. grp_mstr **/

OUTPUT CLOSE.


/** menu_mstr **/
DISPLAY "Starting menu_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\menu_mstr.txt".

FOR EACH menu_mstr WHERE menu_mstr.menu_modified_date > sinceday NO-LOCK: 
    
    EXPORT menu_mstr.
    
END.  /** of 4ea. menu_mstr **/

OUTPUT CLOSE.


/** people_mstr **/
DISPLAY "Starting people_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\people_mstr.txt".

FOR EACH people_mstr WHERE people_mstr.people_modified_date > sinceday NO-LOCK: 
    
    EXPORT people_mstr.
    
END.  /** of 4ea. people_mstr **/

OUTPUT CLOSE.


/** state_mstr **/
DISPLAY "Starting state_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\state_mstr.txt".

FOR EACH state_mstr WHERE state_mstr.state_modified_date > sinceday NO-LOCK: 
    
    EXPORT state_mstr.
    
END.  /** of 4ea. state_mstr **/

OUTPUT CLOSE.


/** trh_hist **/
DISPLAY "Starting trh_hist export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\trh_hist.txt".

FOR EACH trh_hist WHERE trh_hist.trh_modified_date > sinceday NO-LOCK: 
    
    EXPORT trh_hist.
    
END.  /** of 4ea. trh_hist **/

OUTPUT CLOSE.



/*************************  HHI Database Section  *****************************/

/** BFM_mstr **/
DISPLAY "Starting BFM_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\BFM_mstr.txt".

FOR EACH BFM_mstr WHERE BFM_mstr.BFM_modified_date > sinceday NO-LOCK: 
    
    EXPORT BFM_mstr.
    
END.  /** of 4ea. BFM_mstr **/

OUTPUT CLOSE.


/** BHE_mstr **/
DISPLAY "Starting BHE_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\BHE_mstr.txt".

FOR EACH BHE_mstr WHERE BHE_mstr.BHE_modified_date > sinceday NO-LOCK: 
    
    EXPORT BHE_mstr.
    
END.  /** of 4ea. BHE_mstr **/

OUTPUT CLOSE.


/** BMPA_det **/
DISPLAY "Starting BMPA_det export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\BMPA_det.txt".

FOR EACH BMPA_det WHERE BMPA_det.BMPA_modified_date > sinceday NO-LOCK: 
    
    EXPORT BMPA_det.
    
END.  /** of 4ea. BMPA_det **/

OUTPUT CLOSE.


/** BUTEE_mstr **/
DISPLAY "Starting BUTEE_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\BUTEE_mstr.txt".

FOR EACH BUTEE_mstr WHERE BUTEE_mstr.BUTEE_modified_date > sinceday NO-LOCK: 
    
    EXPORT BUTEE_mstr.
    
END.  /** of 4ea. BUTEE_mstr **/

OUTPUT CLOSE.


/** SNP_mstr **/
DISPLAY "Starting SNP_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\SNP_mstr.txt".

FOR EACH SNP_mstr WHERE SNP_mstr.SNP_modified_date > sinceday NO-LOCK: 
    
    EXPORT SNP_mstr.
    
END.  /** of 4ea. SNP_mstr **/

OUTPUT CLOSE.


/** TKR_det **/
DISPLAY "Starting TKR_det export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\TKR_det.txt".

FOR EACH TKR_det WHERE TKR_det.TKR_modified_date > sinceday NO-LOCK: 
    
    EXPORT TKR_det.
    
END.  /** of 4ea. TKR_det **/

OUTPUT CLOSE.


/** TK_mstr **/
DISPLAY "Starting TK_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\TK_mstr.txt".

FOR EACH TK_mstr WHERE TK_mstr.TK_modified_date > sinceday NO-LOCK: 
    
    EXPORT TK_mstr.
    
END.  /** of 4ea. TK_mstr **/

OUTPUT CLOSE.


/** bip_bill_input **/
DISPLAY "Starting bip_bill_input export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\bip_bill_input.txt".

FOR EACH bip_bill_input WHERE bip_bill_input.bip_modified_date > sinceday NO-LOCK: 
    
    EXPORT bip_bill_input.
    
END.  /** of 4ea. bip_bill_input **/

OUTPUT CLOSE.


/** condition_mstr **/
DISPLAY "Starting condition_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\condition_mstr.txt".

FOR EACH condition_mstr WHERE condition_mstr.condition_modified_date > sinceday NO-LOCK: 
    
    EXPORT condition_mstr.
    
END.  /** of 4ea. condition_mstr **/

OUTPUT CLOSE.


/** doctor_mstr **/
DISPLAY "Starting doctor_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\doctor_mstr.txt".

FOR EACH doctor_mstr WHERE doctor_mstr.doctor_modified_date > sinceday NO-LOCK: 
    
    EXPORT doctor_mstr.
    
END.  /** of 4ea. doctor_mstr **/

OUTPUT CLOSE.


/** lab_mstr **/
DISPLAY "Starting lab_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\lab_mstr.txt".

FOR EACH HHI.lab_mstr WHERE lab_mstr.lab_modified_date > sinceday NO-LOCK: 
    
    EXPORT lab_mstr.
    
END.  /** of 4ea. lab_mstr **/

OUTPUT CLOSE.


/** marker_list **/
DISPLAY "Starting marker_list export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\marker_list.txt".

FOR EACH marker_list WHERE marker_list.marker_modified_date > sinceday NO-LOCK: 
    
    EXPORT marker_list.
    
END.  /** of 4ea. marker_list **/

OUTPUT CLOSE.


/** patient_mstr **/
DISPLAY "Starting patient_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\patient_mstr.txt".

FOR EACH patient_mstr WHERE patient_mstr.patient_modified_date > sinceday NO-LOCK: 
    
    EXPORT patient_mstr.
    
END.  /** of 4ea. patient_mstr **/

OUTPUT CLOSE.


/** pcl_det **/
DISPLAY "Starting pcl_det export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\pcl_det.txt".

FOR EACH pcl_det WHERE pcl_det.pcl_modified_date > sinceday NO-LOCK: 
    
    EXPORT pcl_det.
    
END.  /** of 4ea. pcl_det **/

OUTPUT CLOSE.


/** scust_shadow **/
DISPLAY "Starting scust_shadow export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\scust_shadow.txt".

FOR EACH scust_shadow WHERE scust_shadow.scust_modified_date > sinceday NO-LOCK: 
    
    EXPORT scust_shadow.
    
END.  /** of 4ea. scust_shadow **/

OUTPUT CLOSE.


/** suppl_list **/
DISPLAY "Starting suppl_list export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\suppl_list.txt".

FOR EACH suppl_list WHERE suppl_list.suppl_modified_date > sinceday NO-LOCK: 
    
    EXPORT suppl_list.
    
END.  /** of 4ea. suppl_list **/

OUTPUT CLOSE.


/** test_mstr **/
DISPLAY "Starting test_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\test_mstr.txt".

FOR EACH test_mstr WHERE test_mstr.test_modified_date > sinceday NO-LOCK: 
    
    EXPORT test_mstr.
    
END.  /** of 4ea. test_mstr **/

OUTPUT CLOSE.


/** tl_mstr **/
DISPLAY "Starting tl_mstr export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\tl_mstr.txt".

FOR EACH tl_mstr WHERE tl_mstr.tl_modified_date > sinceday NO-LOCK: 
    
    EXPORT tl_mstr.
    
END.  /** of 4ea. tl_mstr **/

OUTPUT CLOSE.


/** tld_det **/
DISPLAY "Starting tld_det export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\tld_det.txt".

FOR EACH tld_det WHERE tld_det.tld_modified_date > sinceday NO-LOCK: 
    
    EXPORT tld_det.
    
END.  /** of 4ea. tld_det **/

OUTPUT CLOSE.


/** trr_det **/
DISPLAY "Starting trr_det export." SKIP.

OUTPUT TO "c:\progress\wrk\exports\trr_det.txt".

FOR EACH trr_det WHERE trr_det.trr_modified_date > sinceday NO-LOCK: 
    
    EXPORT trr_det.
    
END.  /** of 4ea. trr_det **/

OUTPUT CLOSE.


/*****************************  End of File  **********************************/

