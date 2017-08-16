
/*------------------------------------------------------------------------
    File        : DL-DDIcatchallPDFwalk.i
    Purpose     : 

    Syntax      :

    Description : This is a version of the DL-DDIcatchall importer that is for the DL-DDIpdfwalk.p

    Author(s)   : Trae Luttrell
    Created     : Fri Nov 27 16:04:23 EST 2015
    Notes       :
  ----------------------------------------------------------------------*/


/* ***************************  Main Block  *************************** */

IF updatemode = YES THEN DO:
    
    ASSIGN export-filelocation = SUBSTRING(i-filelocation,9).
    
    ASSIGN export-filelocation = "http://hhi-dc-4.local/" + export-filelocation.
    
    CREATE catch_all. 
    
    ASSIGN  
        catch_all.catch_id = NEXT-VALUE(seq-catch-id)
        catch_all.catch_people_firstname = i-pat-firstname
        catch_all.catch_people_lastname = i-pat-lastname
        catch_all.catch_pdf_firstname = o-firstname
        catch_all.catch_pdf_lastname = o-lastname
        catch_all.catch_people_DOB = v-DOB-progress
        catch_all.catch_people_ID = v-tk-patient-id
        catch_all.catch_patient = ?
        catch_all.catch_cust = ?
        catch_all.catch_TK_ID = v-testkitID 
        catch_all.catch_TK_seq = v-test_seq
        catch_all.catch_TK_testtype = i-test_type
        catch_all.catch_tk_lab_sample_id = v-lab-sampleID 
        catch_all.catch_tk_lab_seq = x
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
        catch_all.catch_orig_prog = " DL-DDIpdfwalk.p "
        catch_all.catch_orig_message = err-message
        catch_all.catch_COLLECTED = v-trh-COLLECTED
        catch_all.catch_LAB_RCVD = v-trh-LAB-RCVD
        catch_all.catch_LAB_PROCESS = v-trh-LAB-PROCESS
        catch_all.catch_HHI_RCVD = i-createdate
        catch_all.catch_modified_by = USERID("HHI")
        catch_all.catch_modified_date = TODAY
        catch_all.catch_created_by = USERID("HHI") 
        catch_all.catch_create_date = TODAY
        .
    
    CREATE orig_catch_all .
    
    ASSIGN 
        orig_catch_all.orig_catch_id = NEXT-VALUE(seq-orig_catch-id)
        orig_catch_all.orig_catch_people_firstname = i-pat-firstname
        orig_catch_all.orig_catch_people_lastname = i-pat-lastname
        orig_catch_all.orig_catch_pdf_firstname = o-firstname
        orig_catch_all.orig_catch_pdf_lastname = o-lastname
        orig_catch_all.orig_catch_people_DOB = v-DOB-progress
        orig_catch_all.orig_catch_people_ID = v-tk-patient-id
        orig_catch_all.orig_catch_patient = ?
        orig_catch_all.orig_catch_cust = ?
        orig_catch_all.orig_catch_TK_ID = v-testkitID 
        orig_catch_all.orig_catch_TK_seq = v-test_seq
        orig_catch_all.orig_catch_TK_testtype = i-test_type
        orig_catch_all.orig_catch_tk_lab_sample_id = v-lab-sampleID 
        orig_catch_all.orig_catch_tk_lab_seq = x
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
        orig_catch_all.orig_catch_orig_prog = " DL-DDIpdfwalk.p "
        orig_catch_all.orig_catch_orig_message = err-message
        orig_catch_all.orig_catch_COLLECTED = v-trh-COLLECTED
        orig_catch_all.orig_catch_LAB_RCVD = v-trh-LAB-RCVD
        orig_catch_all.orig_catch_LAB_PROCESS = v-trh-LAB-PROCESS
        orig_catch_all.orig_catch_HHI_RCVD = i-createdate
        orig_catch_all.orig_modified_by = USERID("HHI")
        orig_catch_all.orig_modified_date = TODAY
        orig_catch_all.orig_created_by = USERID("HHI") 
        orig_catch_all.orig_create_date = TODAY
        .    
        
    ASSIGN export-filelocation = "".

END. /*** update mode ***/
/* *************************  END OF LINE  *************************** */
