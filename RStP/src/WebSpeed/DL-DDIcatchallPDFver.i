
/*------------------------------------------------------------------------
    File        : DV-DDIcatchallPDFver.i
    Description : The catch all import routine for the DL-DDIverifierPDF.p

    Author(s)   : Trae Luttrell
    Created     : Fri Nov 27 16:43:57 EST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* ***************************  Main Block  *************************** */

IF i-updatemode = YES THEN DO:
    
    ASSIGN export-filelocation = SUBSTRING(i-filelocation,9).
    
    ASSIGN export-filelocation = "http://hhi-dc-4.local/" + export-filelocation.
    
    CREATE catch_all.
      
    ASSIGN 
        catch_all.catch_id = NEXT-VALUE(seq-catch-id)
        catch_all.catch_people_firstname = i-firstname
        catch_all.catch_people_lastname = i-lastname
        catch_all.catch_pdf_firstname = i-PDF-firstname 
        catch_all.catch_pdf_lastname = i-PDF-lastname
        catch_all.catch_people_DOB = i-DOB-progress
        catch_all.catch_people_ID = v-tk_patient_id
        catch_all.catch_patient = ?
        catch_all.catch_cust = ?
        catch_all.catch_TK_ID = i-testkitID 
        catch_all.catch_TK_seq = i-test_seq
        catch_all.catch_TK_testtype = i-test_type
        catch_all.catch_tk_lab_sample_id = i-lab-sampleID 
        catch_all.catch_tk_lab_seq = i-lab-seq
        catch_all.catch_tk_test_age = 0
        catch_all.catch_addr1 = ""
        catch_all.catch_addr2 = ""
        catch_all.catch_addr3 = ""
        catch_all.catch_addr_city = ""
        catch_all.catch_addr_state = ""
        catch_all.catch_addr_country = ""
        catch_all.catch_addr_zip = ""
        catch_all.catch_file_location = export-filelocation
        catch_all.catch_text_vs_PDF = i-TXTvsPDF
        catch_all.catch_orig_error = err-number
        catch_all.catch_orig_prog = " DL-DDIverifierPDF.p "
        catch_all.catch_orig_message = err-message
        catch_all.catch_COLLECTED = i-trh-COLLECTED
        catch_all.catch_LAB_RCVD = i-trh-LAB-RCVD
        catch_all.catch_LAB_PROCESS = i-trh-LAB-PROCESS
        catch_all.catch_HHI_RCVD = i-createdate
        catch_all.catch_modified_by = USERID("HHI")
        catch_all.catch_modified_date = TODAY
        catch_all.catch_created_by = USERID("HHI") 
        catch_all.catch_create_date = TODAY
        .
        
    CREATE orig_catch_all.
    
    ASSIGN  
        orig_catch_all.orig_catch_id = NEXT-VALUE(seq-orig_catch-id)
        orig_catch_all.orig_catch_people_firstname = i-firstname
        orig_catch_all.orig_catch_people_lastname = i-lastname
        orig_catch_all.orig_catch_pdf_firstname = i-PDF-firstname
        orig_catch_all.orig_catch_pdf_lastname = i-PDF-lastname
        orig_catch_all.orig_catch_people_DOB = i-DOB-progress
        orig_catch_all.orig_catch_people_ID = v-tk_patient_id
        orig_catch_all.orig_catch_patient = ?
        orig_catch_all.orig_catch_cust = ?
        orig_catch_all.orig_catch_TK_ID = i-testkitID 
        orig_catch_all.orig_catch_TK_seq = i-test_seq
        orig_catch_all.orig_catch_TK_testtype = i-test_type
        orig_catch_all.orig_catch_tk_lab_sample_id = i-lab-sampleID 
        orig_catch_all.orig_catch_tk_lab_seq = i-lab-seq
        orig_catch_all.orig_catch_tk_test_age = 0
        orig_catch_all.orig_catch_addr1 = ""
        orig_catch_all.orig_catch_addr2 = ""
        orig_catch_all.orig_catch_addr3 = ""
        orig_catch_all.orig_catch_addr_city = ""
        orig_catch_all.orig_catch_addr_state = ""
        orig_catch_all.orig_catch_addr_country = ""
        orig_catch_all.orig_catch_addr_zip = ""
        orig_catch_all.orig_catch_file_location = export-filelocation
        orig_catch_all.orig_catch_text_vs_PDF = i-TXTvsPDF
        orig_catch_all.orig_catch_orig_error = err-number
        orig_catch_all.orig_catch_orig_prog = " DL-DDIverifierPDF.p "
        orig_catch_all.orig_catch_orig_message = err-message
        orig_catch_all.orig_catch_COLLECTED = i-trh-COLLECTED
        orig_catch_all.orig_catch_LAB_RCVD = i-trh-LAB-RCVD
        orig_catch_all.orig_catch_LAB_PROCESS = i-trh-LAB-PROCESS
        orig_catch_all.orig_catch_HHI_RCVD = i-createdate
        orig_catch_all.orig_modified_by = USERID("HHI")
        orig_catch_all.orig_modified_date = TODAY
        orig_catch_all.orig_created_by = USERID("HHI") 
        orig_catch_all.orig_create_date = TODAY
        .  
        
    ASSIGN export-filelocation = "".   
    
END. /*** of update mode ***/
/* ***************************  END OF LINE  ************************** */
