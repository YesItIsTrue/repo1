
/*------------------------------------------------------------------------
    File        : DDI-DDIverifierPDF.p
    Description : The regular verifier program was getting a bit too complicated, and the PDF's were ignoring 90% of it anyway. Thus, I made a new one just for PDF's.

    Author(s)   : Trae Luttrell
    Created     : Tue Oct 20 10:41:30 EDT 2015
    Updated     : Tue Oct 20 10:41:30 EDT 2015
    Version     : 1.0
    Notes       :
    
    ------------------------------------------------------------------
    Revision History:
    -----------------
    1.0 - written by TRAE LUTTRELL on 20/Oct/15.  Original Version.  Sort of.
    1.1 - written by DOUG LUTTRELL on 02/Apr/16.  Updated the calls to the 
            SUBtkmstrRSTPucU.p program to match with the fields for version 11.1.
            Marked by SUBtkmstr I suppose.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */ 

ROUTINE-LEVEL ON ERROR UNDO, THROW.  
  
DEFINE VARIABLE v-ITmessages    AS LOGICAL INITIAL NO NO-UNDO. 
  
DEFINE INPUT PARAMETER i-filename       AS CHARACTER NO-UNDO. 
DEFINE INPUT PARAMETER i-filelocation   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-TXTvsPDF       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-lastname       LIKE people_mstr.people_lastname NO-UNDO.
DEFINE INPUT PARAMETER i-firstname      LIKE people_mstr.people_firstname NO-UNDO.
DEFINE INPUT PARAMETER i-PDF-lastname   LIKE people_mstr.people_lastname NO-UNDO.  /*** PDF ***/
DEFINE INPUT PARAMETER i-PDF-firstname  LIKE people_mstr.people_firstname NO-UNDO. /*** PDF ***/
DEFINE INPUT PARAMETER i-testkitID      LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE INPUT PARAMETER i-test_seq       LIKE TK_mstr.TK_test_seq NO-UNDO.
DEFINE INPUT PARAMETER i-test_type      LIKE TK_mstr.TK_test_type NO-UNDO.  
DEFINE INPUT PARAMETER i-DOB-progress   LIKE people_mstr.people_DOB NO-UNDO.
DEFINE INPUT PARAMETER i-lab-sampleID   LIKE TK_mstr.TK_lab_sample_ID NO-UNDO.
DEFINE INPUT PARAMETER i-lab-seq        LIKE TK_mstr.TK_lab_seq NO-UNDO.
DEFINE INPUT PARAMETER i-createdate     AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-trh-COLLECTED  AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-trh-LAB-RCVD   AS DATE NO-UNDO. 
DEFINE INPUT PARAMETER i-trh-LAB-PROCESS AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-loglocation    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-updatemode     AS LOGICAL NO-UNDO.

DEFINE OUTPUT PARAMETER o-whathappened  AS CHARACTER NO-UNDO.

DEFINE VARIABLE x AS INTEGER NO-UNDO.
DEFINE VARIABLE v-tk_patient_id AS INTEGER NO-UNDO.
DEFINE VARIABLE err-number AS INTEGER NO-UNDO. 
DEFINE VARIABLE err-message AS CHARACTER NO-UNDO.
DEFINE VARIABLE export-filelocation AS CHARACTER NO-UNDO. 
DEFINE VARIABLE c-PeopleByNames AS INTEGER NO-UNDO.


/****** variables for the stolen trh hist include ******/
DEFINE VARIABLE v-create-date AS DATE NO-UNDO.
DEFINE VARIABLE v-mod-date AS DATE NO-UNDO.
DEFINE VARIABLE v-TKstat AS CHARACTER NO-UNDO.
DEFINE VARIABLE lazydate AS DATE NO-UNDO.  
DEFINE VARIABLE v-trhid AS INTEGER NO-UNDO. 
DEFINE VARIABLE v-trhfound AS LOGICAL NO-UNDO.  
DEFINE VARIABLE statlist AS CHARACTER 
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,EMAILED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO. 
DEFINE VARIABLE v-error AS LOGICAL NO-UNDO. 
DEFINE VARIABLE v-trhid-new AS INTEGER NO-UNDO.     

/*** Outputs for Harold's SUB-Unstring-Name.p ***/
DEFINE VARIABLE o-prefix            AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-firstname         AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-middlename        AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-lastname          AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-suffix            AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-title_desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-prefname          AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-gender            AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-unstring-error    AS LOGICAL NO-UNDO.        /*  YES = errors / NO = no errors. */
DEFINE VARIABLE o-field-in-error    AS CHARACTER NO-UNDO.      /*  Field input name in error, if any. */

/*** Outputs for TK_ucU ***/
DEFINE VARIABLE o-uctkm-id          AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-uctkm-create      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-uctkm-update      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-uctkm-avail       AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-uctkm-successful  AS LOGICAL NO-UNDO.

DEFINE STREAM to-error.  
OUTPUT STREAM to-error TO VALUE(i-loglocation) APPEND. 

/* ***************************  Main Block  *************************** */
PDFverifierLOOP:
DO:
    
    IF i-lab-seq = 0 THEN ASSIGN i-lab-seq = 1.
    
    /**** It never has TK ID's ***/
    
    ASSIGN /** these should already be blank **/
        i-testkitID = "" 
        i-test_seq = 0.
       
        /*MESSAGE "About to FIND on TK_mstr w/ " SKIP
        "lab_sample_ID = " i-lab-sampleID SKIP
        "lab seq = " i-lab-seq VIEW-AS ALERT-BOX BUTTONS OK. */
    
    FIND FIRST TK_mstr WHERE 
        TK_mstr.TK_deleted = ? AND 
        (TK_mstr.TK_lab_sample_ID = i-lab-sampleID AND i-lab-sampleID <> "") AND 
        TK_mstr.TK_lab_seq = i-lab-seq 
        EXCLUSIVE-LOCK NO-ERROR.
    
    IF AVAILABLE (tk_mstr) THEN DO:  /*** find with x ***/
    
        IF i-test_type = "" THEN ASSIGN i-test_type = TK_mstr.TK_test_type.
    
        IF i-test_type <> "" AND TK_mstr.TK_test_type <> "" THEN DO:
    
            IF TK_mstr.TK_test_type <> "" AND TK_mstr.TK_test_type <> i-test_type THEN 
                    ASSIGN i-test_seq = i-test_seq + 100.
            
            IF i-updatemode = YES THEN DO: 
            
                {DL-DDItrh-hist.i}.
                    
                RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r")) /** this ignores blank inputs so it's all good **/
                    (TK_mstr.TK_id,
                    i-test_type,
                    TK_mstr.TK_prof,            
                    i-test_seq,        
                    TK_mstr.TK_domestic,                           
                    TK_mstr.TK_cust_ID,         
                    TK_mstr.TK_patient_ID,  
                    i-lab-sampleID,         
                    i-lab-seq,                  
                    TK_mstr.TK_test_age,                    
                    TK_mstr.TK_lab_ID,          
                    v-TKstat,                                       
                    TK_mstr.TK_comments,        
                    TK_mstr.TK_notes,           
                    TK_mstr.tk_cust_paid,                          
                    TK_mstr.tk_lbl_print,       
                    TK_mstr.TK_lab_paid,        
                    TK_mstr.TK_magento_order, 
                    TK_mstr.TK_cust_paid_date,                      
                    OUTPUT o-uctkm-id,
                    OUTPUT o-uctkm-create,
                    OUTPUT o-uctkm-update,
                    OUTPUT o-uctkm-avail,
                    OUTPUT o-uctkm-successful).                     
            
            END. /*** of updatemode (This was added in late... it's hard to tell what it had screwed up previously) ***/
                
            ASSIGN   
                i-testkitID = TK_mstr.TK_ID
                v-tk_patient_id = TK_mstr.TK_patient_ID
                i-test_seq = TK_mstr.TK_test_seq 
                i-test_type = TK_mstr.TK_test_type.         
             
            FIND people_mstr WHERE 
                people_mstr.people_id = TK_mstr.TK_patient_ID AND  
                people_mstr.people_deleted = ?
                NO-LOCK NO-ERROR.
                
            IF AVAILABLE (people_mstr) THEN DO:  
             
             /*   MESSAGE "Inside the PDF Verifiern People avail." SKIP
                    "DB-Firstname = " people_mstr.people_firstname SKIP
                    "DB-Last name = " people_mstr.people_lastname SKIP 
                    "V-Firstname  = " i-firstname SKIP
                    "V-Lastname   = " i-lastname SKIP
                    VIEW-AS ALERT-BOX BUTTONS OK. */
             
                IF people_mstr.people_firstname = i-firstname AND people_mstr.people_lastname = i-lastname THEN DO:
    
                    ASSIGN i-DOB-progress = people_mstr.people_DOB.
                    
                    {DL-DDIverifierPDFExport.i 499 "PDF: Test Kit found, names matched people_mstr!" "Success"}.
                    LEAVE PDFverifierLOOP.
                    
                END. /** same name!! Whoot! **/
                
                ELSE IF people_mstr.people_lastname = i-firstname AND people_mstr.people_firstname = i-lastname THEN DO:
            
                    ASSIGN i-DOB-progress = people_mstr.people_DOB.
                    
                    {DL-DDIverifierPDFExport.i 409 "PDF: Test Kit found, names fliped from people_mstr!" "Error"}.
                    {DL-DDIcatchallPDFver.i} .
                    LEAVE PDFverifierLOOP.
                    
                END. /** almost the same name... **/
                
                ELSE DO:
                    
                    {DL-DDIverifierPDFExport.i 466 "PDF: Test Kit found, names DO NOT MATCH people_mstr!" "Error"}.
                    {DL-DDIcatchallPDFver.i}.
                    LEAVE PDFverifierLOOP.
                    
                END. /** NOT the same names **/
            
            END. /** people mstr unavailable **/
            
            ELSE DO:              
                
                IF i-DOB-progress <> ? THEN DO:
                    {DL-DDIverifierPDFExport.i 420 "PDF: Test Kit found, people_mstr unavailalble" "Error"}. 
                    {DL-DDIcatchallPDFver.i}.
                    LEAVE PDFverifierLOOP.
                END.
                
                ELSE DO:
                    {DL-DDIverifierPDFExport.i 421 "PDF: Test Kit found, DOB = ?" "Error"}.
                    {DL-DDIcatchallPDFver.i}.   
                    LEAVE PDFverifierLOOP.
                END.
                
            END. /** people mstr unavailable **/
        
            FIND FIRST att_files WHERE 
                 att_files.att_category  = "SOURCE TEST" AND 
                att_files.att_table     = "TK_mstr" AND 
                att_files.att_field1    = "TK_mstr.TK_lab_sample_id" AND    
                att_files.att_value1    = i-lab-sampleID  AND                 
                att_files.att_field2    = "TK_mstr.TK_lab_seq" AND           
                att_files.att_value2    = STRING (x) 
                NO-LOCK NO-ERROR.
        
            IF NOT AVAILABLE (att_files) THEN DO:
        
                IF i-updatemode = YES THEN DO:
            
                    CREATE att_files.
                    
                    ASSIGN 
                        att_files.att_file_id   = NEXT-VALUE(seq-attfile)
                        att_files.att_category  = "SOURCE TEST"
                        att_files.att_table     = "TK_mstr"
                        att_files.att_field1    = "TK_mstr.TK_lab_sample_id"        
                        att_files.att_value1    = i-lab-sampleID                  
                        att_files.att_field2    = "TK_mstr.TK_lab_seq"            
                        att_files.att_value2    = STRING (x)
                        att_files.att_filepath  = SUBSTRING(i-filelocation, (R-INDEX(i-filelocation,"\") + 1))
                        att_files.att_filename  = SUBSTRING(i-filelocation, 1, (R-INDEX(i-filelocation,"\")))
                        att_files.att_created_by = USER("HHI")
                        att_files.att_create_date = TODAY
                        att_files.att_modified_by = USER("HHI")
                        att_files.att_modified_date = TODAY
                        att_files.att_prog_name = "DL-DDIverifier.p".
                    
                    RELEASE att_files.
              
                END. /*** of update mode ***/
            
            END. /*** of not avail att_FILES ***/
    
        END. /*** of test type is NOT blank ****/
    
        
    
    END. /*** of TK_mstr available with x***/ 
    
    ELSE DO: /*** TK_mstr is not available ***/ 
    
    /* MESSAGE "Inside the PDF Verifier. TK_mstr NOT avail." SKIP
            "Pre-export-message 406" VIEW-AS ALERT-BOX BUTTONS OK. */

        c-PeopleByNames = 0.
 
        FOR EACH people_mstr WHERE 
            people_mstr.people_deleted = ? AND 
            ((people_mstr.people_lastname = i-lastname AND 
              people_mstr.people_firstname = i-firstname) OR
             (people_mstr.people_lastname = i-PDF-lastname AND 
              people_mstr.people_firstname = i-PDF-firstname)) AND 
            people_mstr.people_DOB <> ?
            NO-LOCK:  
        
            ASSIGN c-PeopleByNames = c-PeopleByNames + 1. 
        
            IF i-DOB-progress = ? THEN ASSIGN i-DOB-progress = people_mstr.people_DOB.
        
        END.     
        
        IF c-PeopleByNames = 1 THEN DO: 
        
            {DL-DDIverifierPDFExport.i 431 "PDF: Found single record by name, Update?" "Success"}.
            {DL-DDIcatchallPDFver.i}.
            LEAVE PDFverifierLOOP.
            
        END. 
        
        ELSE IF c-PeopleByNames = 0 THEN DO:
         
            {DL-DDIverifierPDFExport.i 432 "PDF: No records with this name, Creation?" "Success"}.
            {DL-DDIcatchallPDFver.i}.
            LEAVE PDFverifierLOOP.
            
        END.
        
        ELSE IF c-PeopleByNames > 1 THEN DO:
        
            {DL-DDIverifierPDFExport.i 433 "PDF: Grandfather Problem or Duplicates" "Error"}.
            {DL-DDIcatchallPDFver.i}.
            LEAVE PDFverifierLOOP.
            
        END. 
        
        ELSE DO:
          
            {DL-DDIverifierPDFExport.i 434 "PDF: Negative People? Contact Solsource" "Error"}.
            {DL-DDIcatchallPDFver.i}.
            LEAVE PDFverifierLOOP.
            
        END. /*** negative numbers?!?! ***/    

    END. /*** TK_mstr completely unavailable  **/
    
    IF i-PDF-firstname <> "" AND i-PDF-lastname <> "" AND i-DOB-progress <> ? AND err-number = 0 THEN DO:             
        
        {DL-DDIverifierPDFExport.i 440 "PDF: Approval Needed" "Success"}.
        {DL-DDIcatchallPDFver.i}.
        LEAVE PDFverifierLOOP.
    
    END.
    
    IF err-number = 0 THEN DO: /*** 399 is the number of the end of the PDF walk ***/
        {DL-DDIverifierPDFExport.i 400 "PDF: Not enough information to verify anything" "Error"}.
        {DL-DDIcatchallPDFver.i}.
    END.  

END. /*** PDFgrabLoop ***/