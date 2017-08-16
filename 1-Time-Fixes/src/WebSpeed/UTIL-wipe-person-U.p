/*************************************************************************
 *
 *  UTIL-wipe-person-U.p - Version 1.0
 *
 *  This program prompts for a People_ID and then actually deletes all
 *  related records to that Person.
 *
 *  --------------------------------------------------------------------
 *
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 27/Jan/16.  Original Version.
 *
 *************************************************************************/

def var peopleid like people_mstr.people_id no-undo.

update skip(1)
    peopleid colon 20 skip(1)
        with frame a width 80 side-labels.

for each people_mstr where people_id = peopleid,
    each tk_mstr where tk_patient_id = people_id,
    each tkr_det where tkr_id = tk_id and 
        tkr_test_seq = tk_test_seq 
    break by people_id by tk_id: 

   delete tkr_det.
   
   if last-of(tk_id) then do:
   
        for each BFM_mstr where BFM_mstr.BFM_ID = tk_mstr.tk_id and 
            BFM_mstr.BFM_test_seq = tk_mstr.tk_test_seq:
            
            delete bfm_mstr.
            
        end.
        
        for each bhe_mstr where BHE_mstr.BHE_ID = tk_mstr.tk_id and 
            BHE_mstr.BHE_test_seq = tk_mstr.tk_test_seq:
            
            delete bhe_mstr.
            
        end.
        
        for each BMPA_det where BMPA_det.BMPA_ID = tk_mstr.tk_id and 
            BMPA_det.BMPA_test_seq = tk_mstr.tk_test_seq:
            
            delete BMPA_det.
            
        end.
        
        for each BUTEE_mstr where BUTEE_mstr.BUTEE_ID = tk_mstr.tk_id and 
            BUTEE_mstr.BUTEE_test_seq = tk_mstr.tk_test_seq:
            
            delete BUTEE_mstr.
            
        end.
   
        delete tk_mstr.
   
   end. /** of if last-of tk_id **/
   
   
   if last-of(people_id) then do: 
   
        for each patient_mstr where patient_mstr.patient_ID = people_mstr.people_id:
        
            delete patient_mstr.
            
        end.
        
        for each pcl_det where pcl_det.pcl_patient_id = people_mstr.people_id:
        
            delete pcl_det.
            
        end.
        
        delete people_mstr.     
        
   end.  /** of if last-of people_id **/
   
end.    /** of 4ea. tk_mstr, etc. **/



/*************  Delete from RS also *************/

for each patient_rcd where PATIENT_RCD.PatientID = peopleid:

    for each mpa_rcd where MPA_RCD.PatientID = patient_rcd.patientid:    
    
        delete mpa_rcd.
        
    end.
    
    for each MPA_TEST_DETAILS_RCD where MPA_TEST_DETAILS_RCD.PatientID = patient_rcd.patientid:
    
        delete MPA_TEST_DETAILS_RCD.
        
    end.
    
    for each patient_files where 
        PATIENT_FILES.patientid = patient_rcd.patientid:
    
        delete patient_files.
        
    end.
    
    for each TESTS_DETAIL_RCD where 
        TESTS_DETAIL_RCD.PatientID = patient_rcd.patientID:
    
        delete TESTS_DETAIL_RCD.
        
    end.
    
    for each TESTS_FM_SPECIMEN_RCD where 
        TESTS_FM_SPECIMEN_RCD.PatientID = patient_RCD.patientid:
    
        delete TESTS_FM_SPECIMEN_RCD.
        
    end.
    
    for each TESTS_HE_SPECIMEN_RATIOS_RCD where 
        TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID = patient_rcd.patientID:
    
        delete TESTS_HE_SPECIMEN_RATIOS_RCD.
        
    end.
    
    for each TESTS_RESULT_RCD where 
        TESTS_RESULT_RCD.PatientID = patient_rcd.patientid:
       
        delete TESTS_RESULT_RCD.
        
    end.  

    for each TESTS_UTM_UEE_SPECIMEN_RCD where
        TESTS_UTM_UEE_SPECIMEN_RCD.PatientID = patient_rcd.patientid:
        
        delete TESTS_UTM_UEE_SPECIMEN_RCD.
        
    end. 
    
    delete patient_rcd.

end.  /** of 4ea. patient_rcd, etc. **/

/****************************   END OF FILE   *************************/
