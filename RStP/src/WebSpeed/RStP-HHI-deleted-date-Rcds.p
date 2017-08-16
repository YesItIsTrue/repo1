/******************************************************************************
 *
 *  RStP-HHI-deleted-date-Rcds.p - 30/Sept/15 - Version 1.0
 * 
 * -----------------------------------------------------------------------
 *
 *  Description:
 *  ------------
 *  Removes/deletes all HHI table records 
 *  where the "*_deleted" field is not equal to ?. 
 *  MUST be run before any of the other RStP programs.
 *
 * -----------------------------------------------------------------------
 *
 *  Revision History:
 *  ----------------- 
 *  1.0 - Original program by Harold Luttrell on 30/Sept/15.
 *  1.1 - written by DOUG LUTTRELL on 11/Aug/17.  Interestingly enough we were just 
 *          discussing the fact that I *thought* we had a program that cleaned up
 *          the "*_deleted" records.  Changed as part of the CMC structure change 
 *          (Version 12).  Marked by 1dot1.  Seems like this program needs a lot
 *          of tables added to it now.
 *
 ******************************************************************************/


/****************************  Variable Definition Section  ************************/

/********************************  Main Code  **************************/

FOR EACH BFM_mstr WHERE BFM_mstr.BFM_deleted <> ? EXCLUSIVE-LOCK:     

    DELETE BFM_mstr.

END.  /*** of 4ea. BFM_mstr ***/
       
FOR EACH BHE_mstr WHERE BHE_mstr.BHE_deleted <> ? EXCLUSIVE-LOCK:
 
DELETE BHE_mstr.

END.    /** of 4ea. BHE_mstr **/									
			
FOR EACH BMPA_det WHERE BMPA_det.BMPA_deleted <> ? EXCLUSIVE-LOCK:

	DELETE BMPA_det.
	
END. /** of 4ea. BMPA_det **/

FOR EACH BUTEE_mstr WHERE BUTEE_mstr.BUTEE_deleted <> ? EXCLUSIVE-LOCK:

	DELETE BUTEE_mstr.
	
END. /** of 4ea. BUTEE_mstr **/

/***************  1dot1 ******************
FOR EACH SNP_mstr WHERE SNP_mstr.SNP_deleted <> ? EXCLUSIVE-LOCK:

	DELETE SNP_mstr.
	
END. /** of 4ea. SNP_mstr **/			  
************* end of 1dot1 ***************/ 

			
FOR EACH TKR_det WHERE TKR_det.TKR_deleted <> ? EXCLUSIVE-LOCK:

	DELETE TKR_det.
	
END. /** of 4ea. TKR_det **/			  

FOR EACH TK_mstr WHERE TK_mstr.TK_deleted <> ? EXCLUSIVE-LOCK:

	DELETE TK_mstr.
	
END.  /*** of 4ea. TK_mstr ***/
    
FOR EACH bip_bill_input WHERE  bip_bill_input.bip_deleted <> ? EXCLUSIVE-LOCK:

	DELETE bip_bill_input.
	
END. /** of 4ea. bip_bill_input **/

FOR EACH condition_mstr WHERE  condition_mstr.condition_deleted <> ? EXCLUSIVE-LOCK:

    DELETE condition_mstr.
    
END. /** of 4ea. condition_mstr **/

FOR EACH doctor_mstr WHERE  doctor_mstr.doctor_deleted <> ? EXCLUSIVE-LOCK:

    DELETE doctor_mstr.
    
END. /** of 4ea. doctor_mstr **/

FOR EACH lab_mstr WHERE  lab_mstr.lab_deleted <> ? EXCLUSIVE-LOCK:

    DELETE lab_mstr.
    
END. /** of 4ea. lab_mstr **/

FOR EACH marker_list WHERE  marker_list.marker_deleted <> ? EXCLUSIVE-LOCK:

    DELETE marker_list.
    
END. /** of 4ea. marker_list **/

FOR EACH patient_mstr WHERE  patient_mstr.patient_deleted <> ? EXCLUSIVE-LOCK:

    DELETE patient_mstr.
    
END. /** of 4ea. patient_mstr **/

FOR EACH pcl_det WHERE  pcl_det.pcl_deleted <> ? EXCLUSIVE-LOCK:

    DELETE pcl_det.
    
END. /** of 4ea. pcl_det **/

FOR EACH scust_shadow WHERE  scust_shadow.scust_deleted <> ? EXCLUSIVE-LOCK:

    DELETE scust_shadow.
    
END. /** of 4ea. scust_shadow **/

FOR EACH suppl_list WHERE  suppl_list.suppl_deleted <> ? EXCLUSIVE-LOCK:

    DELETE suppl_list.
    
END. /** of 4ea. suppl_list **/

FOR EACH test_mstr WHERE  test_mstr.test_deleted <> ? EXCLUSIVE-LOCK:

    DELETE test_mstr.
    
END. /** of 4ea. test_mstr **/

FOR EACH tl_mstr WHERE  tl_mstr.tl_deleted <> ? EXCLUSIVE-LOCK:

    DELETE tl_mstr.
    
END. /** of 4ea. tl_mstrt **/             

FOR EACH tld_det WHERE  tld_det.tld_deleted <> ? EXCLUSIVE-LOCK:

    DELETE tld_det.
    
END. /** of 4ea. tld_det **/                  

FOR EACH trr_det WHERE  trr_det.trr_deleted <> ? EXCLUSIVE-LOCK:

    DELETE trr_det.
    
END. /** of 4ea. trr_det **/

/*****************************  End of FIle.  *******************************/
