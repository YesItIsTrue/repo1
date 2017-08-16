
/*------------------------------------------------------------------------
    File        : DVcatchallDuplicateRemoverU.p

    Description : This program removes perfect duplicates from the Catch All table in the HHI database.	

    Author(s)   : Trae Luttrell
    Created     : Thu Apr 14 14:00:06 EDT 2016
    Updated     : Thu Apr 14 14:01:00 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE x AS INTEGER NO-UNDO.
DEFINE VARIABLE y AS INTEGER NO-UNDO.
DEFINE VARIABLE testmode AS LOGICAL INITIAL YES NO-UNDO. 

DEFINE BUFFER catch_all2 FOR catch_all. 
/* ***************************  Main Block  *************************** */

FOR EACH catch_all2 NO-LOCK BREAK 
    BY catch_all2.catch_file_location
    BY catch_all2.catch_people_lastname
    BY catch_all2.catch_people_firstname
    BY catch_all2.catch_PDF_lastname
    BY catch_all2.catch_PDF_firstname
    BY catch_all2.catch_people_DOB
    BY catch_all2.catch_TK_testtype
    BY catch_all2.catch_TK_testtype
    BY catch_all2.catch_TK_ID
    BY catch_all2.catch_TK_seq
    BY catch_all2.catch_tk_lab_sample_id
    BY catch_all2.catch_TK_lab_seq
    BY catch_all2.catch_orig_error:
    
    ASSIGN y = y + 1.
    
    IF FIRST-OF (catch_all2.catch_orig_error) THEN DO:
    
        FOR EACH catch_all WHERE 
            HHI.catch_all.catch_file_location = catch_all2.catch_file_location AND
            HHI.catch_all.catch_people_lastname = catch_all2.catch_people_lastname AND 
            HHI.catch_all.catch_people_firstname = catch_all2.catch_people_firstname AND 
            HHI.catch_all.catch_PDF_lastname    = catch_all2.catch_PDF_lastname AND 
            HHI.catch_all.catch_PDF_firstname   = catch_all2.catch_PDF_firstname AND
            HHI.catch_all.catch_people_DOB  = catch_all2.catch_people_DOB AND
            HHI.catch_all.catch_TK_testtype = catch_all2.catch_TK_testtype AND
            HHI.catch_all.catch_TK_ID   = catch_all2.catch_TK_ID AND
            HHI.catch_all.catch_TK_seq = catch_all2.catch_TK_seq AND 
            HHI.catch_all.catch_tk_lab_sample_id = catch_all2.catch_tk_lab_sample_id AND 
            HHI.catch_all.catch_TK_lab_seq = catch_all2.catch_TK_lab_seq AND 
            HHI.catch_all.catch_orig_error = catch_all2.catch_orig_error AND 
            RECID(catch_all) <> RECID(catch_all2)
        EXCLUSIVE-LOCK:
        
            IF testmode = YES THEN DELETE catch_all.
            
            ASSIGN x = x + 1.
        
        END.
    
    END.
        
END.

DISPLAY x " of " y " records were deleted from the Catch All Table".