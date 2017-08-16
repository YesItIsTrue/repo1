
/*------------------------------------------------------------------------
    File        : DV-TKstat-U.p
    Purpose     : 

    Syntax      :

    Description : Program checks all the source locations for data relevant to 
                    the Status so it is easier to see what the correct status is.

    Author(s)   : Doug Luttrell
    Created     : Sat Feb 07 13:41:24 EST 2015
    Notes       :
        
    Revision History:
    -----------------
    1.0 - written by DOUG LUTTRELL on 07/Feb/15.  Original version.
    1.1 - written by DOUG LUTTRELL on 28/Sep/15.  Corrected with the changes from
            the RStP-MPA_RCD-U-1.p code.  Not marked.
    1.2 - written by DOUG LUTTRELL on 01/Oct/15.  Needed to add in the status
            for PRINTED coming from the MPA_ReEngineered date.  Marked by 1dot2.
            Also removed the giant sections of comments.
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE statlist AS CHARACTER 
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,BURNED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO.
DEFINE VARIABLE firstdate AS DATE NO-UNDO.
DEFINE VARIABLE v-trhid         LIKE trh_hist.trh_id            NO-UNDO.
DEFINE VARIABLE v-trhfound      AS LOGICAL                      NO-UNDO. 
DEFINE VARIABLE o-trhID LIKE trh_hist.trh_ID NO-UNDO.
DEFINE VARIABLE o-trherr AS LOGICAL NO-UNDO.
DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 10 NO-UNDO.
DEFINE VARIABLE v-completedate AS DATE LABEL "Set Completion Date" INITIAL 11/30/14 NO-UNDO.
DEFINE VARIABLE v-labpaiddate AS DATE LABEL "Set Lab Paid Date"  INITIAL 12/31/14 NO-UNDO.
DEFINE VARIABLE v-custpaiddate AS DATE LABEL "Set Customer Paid Date" INITIAL 05/31/14 NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.

DEFINE VARIABLE founddiff AS LOG NO-UNDO.

DEFINE VARIABLE datelist AS DATE EXTENT 17 NO-UNDO.

DEFINE VARIABLE updatemode AS LOG INITIAL NO LABEL "Update Mode?" NO-UNDO.

DEFINE VARIABLE x AS INTEGER NO-UNDO.
DEFINE VARIABLE y AS INTEGER NO-UNDO.
DEFINE VARIABLE catchid LIKE trh_hist.trh_id NO-UNDO.
DEFINE VARIABLE catcherr AS LOGICAL NO-UNDO.

DEFINE VARIABLE ITshowmsg AS LOG INITIAL NO NO-UNDO.

DEFINE VARIABLE whatstat AS CHARACTER INITIAL "CREATED" NO-UNDO.
DEFINE VARIABLE initstat LIKE TK_mstr.TK_status NO-UNDO.

DEFINE VARIABLE foundmpa AS LOG NO-UNDO.
DEFINE VARIABLE foundtestres AS LOG NO-UNDO. 
DEFINE VARIABLE foundtksheet AS LOG NO-UNDO.


DEFINE VARIABLE cmdname          AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe" NO-UNDO.
DEFINE VARIABLE emailaddr        AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"  NO-UNDO.
DEFINE VARIABLE messagetxt       AS CHARACTER INITIAL "-m Program " NO-UNDO.
DEFINE VARIABLE subjtxt          AS CHARACTER INITIAL "-s Status Search" NO-UNDO.
DEFINE VARIABLE cmdparams        AS CHARACTER INITIAL "-a" NO-UNDO.


messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
   
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\Status-Search.txt" NO-UNDO.

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "TK_ID" "TK_Test_Seq" "Test_Type" "Current_Status" "Created_Date" "Modified_Date" 
    statlist "Found_Status" "MPA_RCD" "TESTS_RESULT_RCD" "TK_Spreadsheet" "Found_Diff" "New_Complete_Date".

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO. 

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

{emailaddr-USERID.i}.
        
/* ********************  User Interface  ******************** */


UPDATE SKIP(1) 
    v-completedate COLON 30
    v-labpaiddate COLON 30
    v-custpaiddate COLON 30 SKIP(1)
        WITH FRAME a WIDTH 80 SIDE-LABELS. 
        

/* ***************************  Main Block  *************************** */
PAUSE 0 BEFORE-HIDE.

FOR EACH TK_mstr : 
    
    ASSIGN 
        foundmpa        = NO
        foundtestres    = NO 
        foundtksheet    = NO
        whatstat        = "CREATED"
        founddiff       = NO
        initstat        = TK_mstr.tk_status
        firstdate       = ?. 
    
    /** Look for this one in the MPA_RCD table --- Genetic test stuff **/
    FIND MPA_RCD WHERE MPA_RCD.mpa_test_kit_nbr = tk_mstr.tk_id AND 
        MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr = tk_mstr.tk_test_seq AND 
        MPA_RCD.PatientID = tk_mstr.tk_patient_ID 
            NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE (MPA_RCD) THEN 
        FIND MPA_RCD WHERE MPA_RCD.PatientID = tk_mstr.tk_patient_id AND 
            MPA_RCD.MPA_Sample_ID_Number = tk_mstr.tk_lab_sample_ID AND 
            MPA_RCD.MPA_Sample_ID_SeqNbr = tk_mstr.tk_lab_seq AND 
            MPA_RCD.MPA_Test_Type = tk_mstr.tk_test_type
                NO-LOCK NO-ERROR.
            
    IF AVAILABLE (mpa_rcd) THEN DO:
        
        foundmpa = YES. 
        
        IF MPA_RCD.MPA_Date_Results_Sent <> ? 
                AND 
                MPA_RCD.MPA_Date_Results_Sent <> 08/18/15 AND  
                MPA_RCD.MPA_Date_Results_Sent <> 08/19/15 
        THEN 
            ASSIGN 
                datelist[LOOKUP("HHI_RCVD",statlist)]   = IF datelist[LOOKUP("HHI_RCVD",statlist)] = ? THEN 
                                                            MPA_RCD.MPA_Date_Results_Sent 
                                                          ELSE 
                                                            datelist[LOOKUP("HHI_RCVD",statlist)]
                datelist[LOOKUP("LOADED",statlist)]     = IF datelist[LOOKUP("LOADED",statlist)] = ? THEN 
                                                            MPA_RCD.MPA_Date_Results_Sent 
                                                          ELSE 
                                                            datelist[LOOKUP("LOADED",statlist)]
                firstdate                               = IF firstdate < MPA_RCD.MPA_Date_Results_Sent THEN
                                                            firstdate
                                                          ELSE 
                                                             MPA_RCD.MPA_Date_Results_Sent.
                                                                                                                        .
        IF MPA_RCD.MPA_date_processed <> ? 
                AND 
                DATE(MPA_RCD.MPA_date_processed) <> 08/18/15 AND  
                DATE(MPA_RCD.MPA_date_processed) <> 08/19/15 
         THEN                                                                  
            ASSIGN 
                datelist[LOOKUP("PROCESSED",statlist)]  = MPA_RCD.MPA_date_processed 
                datelist[LOOKUP("HHI_RCVD",statlist)]   = IF datelist[LOOKUP("HHI_RCVD",statlist)] = ? THEN         /* infer */
                                                                MPA_RCD.MPA_date_processed
                                                          ELSE 
                                                                datelist[LOOKUP("HHI_RCVD",statlist)]
                datelist[LOOKUP("LOADED",statlist)]     = IF datelist[LOOKUP("LOADED",statlist)] = ? THEN           /* infer */
                                                                MPA_RCD.MPA_date_processed 
                                                         ELSE 
                                                                datelist[LOOKUP("LOADED",statlist)]
                firstdate                               = IF firstdate < DATE(MPA_RCD.MPA_date_processed) THEN
                                                                firstdate
                                                          ELSE 
                                                                DATE(MPA_RCD.MPA_date_processed).                                                                                
        
        IF MPA_RCD.MPA_ReEngineered_Date <> ?                                                                  /* begin 1dot2 */
                AND 
                MPA_RCD.MPA_ReEngineered_Date <> 08/18/15 AND 
                MPA_RCD.MPA_ReEngineered_Date <> 08/19/15
            THEN 
                ASSIGN 
                    datelist[LOOKUP("PRINTED",statlist)]    = MPA_RCD.MPA_ReEngineered_Date                    
                    firstdate                               = IF firstdate < MPA_RCD.MPA_ReEngineered_Date THEN
                                                                firstdate
                                                              ELSE 
                                                                MPA_RCD.MPA_ReEngineered_Date.    
                                                                                                                /* end 1dot2 */
            
            
        IF MPA_RCD.MPA_Date_Analysis_Sent <> ? 
                AND 
                MPA_RCD.MPA_Date_Analysis_Sent <> 08/18/15 AND  
                MPA_RCD.MPA_Date_Analysis_Sent <> 08/19/15 
         THEN   
            ASSIGN 
                datelist[LOOKUP("COMPLETE",statlist)]   = MPA_RCD.MPA_Date_Analysis_Sent
                datelist[LOOKUP("HHI_RCVD",statlist)]   = IF datelist[LOOKUP("HHI_RCVD",statlist)] = ? THEN         /* infer */
                                                                MPA_RCD.MPA_Date_Analysis_Sent
                                                          ELSE
                                                                datelist[LOOKUP("HHI_RCVD",statlist)]
                datelist[LOOKUP("LOADED",statlist)]     = IF datelist[LOOKUP("LOADED",statlist)] = ? THEN           /* infer */
                                                                MPA_RCD.MPA_Date_Analysis_Sent
                                                          ELSE
                                                                datelist[LOOKUP("LOADED",statlist)]
                datelist[LOOKUP("PROCESSED",statlist)]  = IF datelist[LOOKUP("PROCESSED",statlist)] = ? THEN        /* infer */
                                                                MPA_RCD.MPA_Date_Analysis_Sent
                                                          ELSE 
                                                                datelist[LOOKUP("PROCESSED",statlist)]
                firstdate                               = IF firstdate < MPA_RCD.MPA_Date_Analysis_Sent THEN
                                                                firstdate
                                                          ELSE 
                                                                MPA_RCD.MPA_Date_Analysis_Sent.                
            
        IF MPA_RCD.MPA_DateCollected <> ? 
                AND 
                MPA_RCD.MPA_DateCollected <> 08/18/15 AND  
                MPA_RCD.MPA_DateCollected <> 08/19/15 
          THEN 
            ASSIGN 
                datelist[LOOKUP("COLLECTED",statlist)]  = MPA_RCD.MPA_DateCollected
                firstdate                               = IF firstdate < MPA_RCD.MPA_DateCollected THEN
                                                                firstdate
                                                          ELSE 
                                                                MPA_RCD.MPA_DateCollected.            
        
        IF MPA_RCD.MPA_DateReceived <> ? 
                AND 
                MPA_RCD.MPA_DateReceived <> 08/18/15 AND  
                MPA_RCD.MPA_DateReceived <> 08/19/15 
          THEN 
            ASSIGN 
                datelist[LOOKUP("LAB_RCVD",statlist)]   = MPA_RCD.MPA_DateReceived
                firstdate                               = IF firstdate < MPA_RCD.MPA_DateReceived THEN
                                                                firstdate
                                                          ELSE 
                                                                MPA_RCD.MPA_DateReceived.         
        
        IF MPA_RCD.MPA_DateCompleted <> ? 
                AND 
                MPA_RCD.MPA_DateCompleted <> 08/18/15 AND  
                MPA_RCD.MPA_DateCompleted <> 08/19/15 
          THEN 
            ASSIGN 
                datelist[LOOKUP("LAB_PROCESS",statlist)]    = MPA_RCD.MPA_DateCompleted
                firstdate                                   = IF firstdate < MPA_RCD.MPA_DateCompleted THEN
                                                                    firstdate
                                                              ELSE 
                                                                    MPA_RCD.MPA_DateCompleted.         
                         
            
                                
    END.  /** of if avail mpa_rcd **/
    
    
    
    /** Look for this one in the TESTS_RESULT_RCD table --- BioMed test stuff **/
    FIND TESTS_RESULT_RCD WHERE TESTS_RESULT_RCD.PatientID = tk_mstr.tk_patient_id AND 
        TESTS_RESULT_RCD.Lab_Sampleid = tk_mstr.tk_lab_sample_ID AND 
        TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = tk_mstr.tk_lab_seq AND 
        TESTS_RESULT_RCD.Test_Abbv = tk_mstr.tk_test_type AND 
        TESTS_RESULT_RCD.Test_Kit_Nbr = tk_mstr.tk_id 
            NO-LOCK NO-ERROR.
            
    IF AVAILABLE (TESTS_RESULT_RCD) THEN DO:
                   
        foundtestres = YES. 
                   
        IF tests_result_rcd.DateCollected <> ? 
                AND 
                tests_result_rcd.DateCollected <> 08/18/15 AND  
                tests_result_rcd.DateCollected <> 08/19/15 
          THEN 
            ASSIGN 
                datelist[LOOKUP("COLLECTED",statlist)]      = tests_result_rcd.DateCollected
                firstdate                                   = IF firstdate < tests_result_rcd.DateCollected THEN
                                                                    firstdate
                                                              ELSE 
                                                                    tests_result_rcd.DateCollected.                              
        
        IF tests_result_RCD.DateReceived <> ? 
                AND 
                tests_result_RCD.DateReceived <> 08/18/15 AND  
                tests_result_RCD.DateReceived <> 08/19/15 
           THEN 
            ASSIGN 
                datelist[LOOKUP("LAB_RCVD",statlist)]       = tests_result_RCD.DateReceived
                firstdate                                   = IF firstdate < tests_result_RCD.DateReceived THEN
                                                                    firstdate
                                                              ELSE 
                                                                    tests_result_RCD.DateReceived.                         
        
        IF tests_result_RCD.DateCompleted <> ? 
                AND 
                tests_result_RCD.DateCompleted <> 08/18/15 AND  
                tests_result_RCD.DateCompleted <> 08/19/15 
           THEN 
            ASSIGN 
                datelist[LOOKUP("LAB_PROCESS",statlist)]    = tests_result_RCD.DateCompleted
                firstdate                                   = IF firstdate < tests_result_RCD.DateCompleted THEN
                                                                    firstdate
                                                              ELSE 
                                                                    tests_result_RCD.DateCompleted.                   
            
        IF tests_result_RCD.tests_result_date_processed <> ? 
                AND 
                DATE(TESTS_RESULT_RCD.Tests_Result_date_processed) <> 08/18/15 AND  
                DATE(TESTS_RESULT_RCD.Tests_Result_date_processed) <> 08/19/15 
          THEN 
            ASSIGN 
                datelist[LOOKUP("HHI_RCVD",statlist)]   = IF datelist[LOOKUP("HHI_RCVD",statlist)] = ? THEN 
                                                                DATE(TESTS_RESULT_RCD.Tests_Result_date_processed) 
                                                          ELSE 
                                                                datelist[LOOKUP("HHI_RCVD",statlist)]
                datelist[LOOKUP("LOADED",statlist)]     = IF datelist[LOOKUP("LOADED",statlist)] = ? THEN 
                                                                DATE(TESTS_RESULT_RCD.Tests_Result_date_processed) 
                                                          ELSE 
                                                                datelist[LOOKUP("LOADED",statlist)]                                                            
                datelist[LOOKUP("PROCESSED",statlist)]  = DATE(TESTS_RESULT_RCD.Tests_Result_date_processed) 
                firstdate                               = IF firstdate < DATE(TESTS_RESULT_RCD.Tests_Result_date_processed)  THEN
                                                                firstdate
                                                          ELSE 
                                                                DATE(TESTS_RESULT_RCD.Tests_Result_date_processed) . 
                                
    END.  /** of if avail tests_result_rcd **/
    
    
               
    /** Look for this one in the TK Tracking Spreadsheet table --- **/
    FIND import_TK_Tracking_Spreadsheet WHERE import_TK_Tracking_Spreadsheet.Test-Kit-Nbr = tk_mstr.tk_id 
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE (import_TK_Tracking_Spreadsheet) THEN 
        FIND import_TK_Tracking_Spreadsheet WHERE import_TK_Tracking_Spreadsheet.Test-Kit-Nbr = tk_mstr.tk_id AND 
            import_TK_Tracking_Spreadsheet.Lab-Number-Item = tk_mstr.tk_lab_sample_ID 
                NO-LOCK NO-ERROR.
            
    IF AVAILABLE (import_TK_Tracking_Spreadsheet) THEN DO:
                   
        foundtksheet = YES.
                   
        IF DATE(import_TK_Tracking_Spreadsheet.Date-Sent-to-Customer) <> ? THEN 
            ASSIGN 
                datelist[LOOKUP("SHIPPED",statlist)]    = DATE(import_TK_Tracking_Spreadsheet.Date-Sent-to-Customer)
                datelist[LOOKUP("SOLD",statlist)]       = DATE(import_TK_Tracking_Spreadsheet.Date-Sent-to-Customer)
                firstdate                               = IF firstdate < DATE(import_TK_Tracking_Spreadsheet.Date-Sent-to-Customer) THEN
                                                                firstdate
                                                          ELSE 
                                                                DATE(import_TK_Tracking_Spreadsheet.Date-Sent-to-Customer).            
        
        IF DATE(import_TK_Tracking_Spreadsheet.Date-Processed-File) <> ? THEN 
            ASSIGN 
                datelist[LOOKUP("LAB_PROCESS",statlist)]    = DATE(import_TK_Tracking_Spreadsheet.Date-Processed-File)
                firstdate                                   = IF firstdate < DATE(import_TK_Tracking_Spreadsheet.Date-Processed-File) THEN
                                                                    firstdate
                                                              ELSE 
                                                                    DATE(import_TK_Tracking_Spreadsheet.Date-Processed-File).                  
        
        IF import_TK_Tracking_Spreadsheet.Kit-Paid-For = "Y" THEN 
            ASSIGN 
                datelist[LOOKUP("PAID_BY_CUST",statlist)]   = DATE(import_TK_Tracking_Spreadsheet.Date-Sent-to-Customer)
                firstdate                                   = IF firstdate < DATE(import_TK_Tracking_Spreadsheet.Date-Sent-to-Customer) THEN
                                                                    firstdate
                                                              ELSE 
                                                                    DATE(import_TK_Tracking_Spreadsheet.Date-Sent-to-Customer). 
        
        IF DATE(import_TK_Tracking_Spreadsheet.shipped-results-to-client) <> ? THEN 
            ASSIGN 
                datelist[LOOKUP("COMPLETE",statlist)]       = DATE(import_TK_Tracking_Spreadsheet.shipped-results-to-client)
                firstdate                                   = IF firstdate < DATE(import_TK_Tracking_Spreadsheet.shipped-results-to-client) THEN
                                                                    firstdate
                                                              ELSE 
                                                                    DATE(import_TK_Tracking_Spreadsheet.shipped-results-to-client).             
        
        IF DATE(import_TK_Tracking_Spreadsheet.Paid-Vendor-Date) <> ? THEN 
            ASSIGN 
                datelist[LOOKUP("VEND_PAID",statlist)]      = DATE(import_TK_Tracking_Spreadsheet.Paid-Vendor-Date)
                firstdate                                   = IF firstdate < DATE(import_TK_Tracking_Spreadsheet.Paid-Vendor-Date) THEN
                                                                    firstdate
                                                              ELSE 
                                                                    DATE(import_TK_Tracking_Spreadsheet.Paid-Vendor-Date).                 
                                        
    END.  /** of if avail mpa_rcd **/
    
    ASSIGN 
            datelist[LOOKUP("CREATED",statlist)] = (firstdate - 1) /* tk_mstr.tk_create_date */
            y   = 0.            
        
    
    
    /************  Let's see what we found ************/
    DO i = 1 TO 13:                                                             /** status through COMPLETE **/     
       
        IF datelist[i] <> ? THEN DO: 
             
            ASSIGN 
                whatstat    = ENTRY(i,statlist)
                y           = i
                catchid     = 0
                catcherr    = NO. 

            
            /********  Begin 1dot1 ***********/      
            ASSIGN 
                v-trhid     = 0
                v-trhfound  = NO.                               
                                 
            RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
                (TK_mstr.TK_test_type,                                                   
                 whatstat,                                                              
                 TK_mstr.TK_ID,                                                         
                 TK_mstr.TK_test_seq,                                                   
                 datelist[i],                                                              
                 OUTPUT v-trhid,                                                       
                 OUTPUT v-trhfound).                                                     

            IF v-trhfound = NO THEN DO: 
            
                RUN VALUE(SEARCH("SUBtrh-RStP-ucU.r"))                                
                    (0,                                     /* trh_ID */
                    TK_mstr.TK_test_type,
                    whatstat,
                    1,                                      /* trh_qty */
                    "",                                     /* trh_loc */
                    "",                                     /* trh_lot */
                    TK_mstr.tk_ID,
                    "",                                     /* trh_site */
                    TK_mstr.TK_test_seq,
                    datelist[i],                              
                    OUTPUT o-trhID,
                    OUTPUT o-trherr).
                    
            END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
            /************ End of 1dot1 ***************/ 
         
        END.  /** of if datelist[i] <> ? **/
                    
    END.  /** of do i = 1 to 13 **/   
    
    IF y = 0 THEN
        y = 1.

    
    IF whatstat <> tk_mstr.tk_status THEN DO: 
        
        founddiff = YES.
            
    END.    /** of whatstat <> tk_status **/  
        
    ELSE 
        founddiff = NO.
         
    IF whatstat <> tk_mstr.tk_status THEN DO: 
        
        IF LOOKUP(TK_mstr.tk_status,statlist) < LOOKUP(whatstat,statlist) THEN DO:  
                
            ASSIGN 
                TK_mstr.TK_status                       = whatstat
                TK_mstr.TK_modified_date                = datelist[y]
                TK_mstr.TK_modified_by                  = USERID("HHI")
                TK_mstr.TK_prog_name                    = THIS-PROCEDURE:FILE-NAME.

            /********  Begin 1dot1 ***********/      
            ASSIGN 
                v-trhid     = 0
                v-trhfound  = NO.                               
                                 
            RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
                (TK_mstr.TK_test_type,                                                   
                 whatstat,                                                              
                 TK_mstr.TK_ID,                                                         
                 TK_mstr.TK_test_seq,                                                   
                 datelist[y],                                                              
                 OUTPUT v-trhid,                                                       
                 OUTPUT v-trhfound).                                                     

            IF v-trhfound = NO THEN DO: 
            
                RUN VALUE(SEARCH("SUBtrh-RStP-ucU.r"))                                
                    (0,                                     /* trh_ID */
                    TK_mstr.TK_test_type,
                    whatstat,
                    1,                                      /* trh_qty */
                    "",                                     /* trh_loc */
                    "",                                     /* trh_lot */
                    TK_mstr.tk_ID,
                    "",                                     /* trh_site */
                    TK_mstr.TK_test_seq,
                    datelist[y],                              
                    OUTPUT o-trhID,
                    OUTPUT o-trherr).
                            
            END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
            /************ End of 1dot1 ***************/ 
            
        END.  /** of if tk_status < whatstat **/
        
    END.  /** of if founddiff = yes **/     
         
    IF datelist[LOOKUP("COMPLETE",statlist)] = ? THEN DO:                           /** force to be COMPLETE **/
    
        IF y >= lookup("COLLECTED",statlist) AND 
            y <= lookup("BURNED",statlist) AND 
            datelist[y] <= v-completedate THEN DO:
                    
            ASSIGN 
                datelist[LOOKUP("COMPLETE",statlist)]   = datelist[y]
                whatstat                                = "COMPLETE"
                TK_mstr.TK_status                       = whatstat
                TK_mstr.TK_modified_date                = datelist[LOOKUP("COMPLETE",statlist)]
                TK_mstr.TK_modified_by                  = USERID("HHI")
                TK_mstr.TK_prog_name                    = THIS-PROCEDURE:FILE-NAME.

            /********  Begin 1dot1 ***********/      
            ASSIGN 
                v-trhid     = 0
                v-trhfound  = NO.                               
                                 
            RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
                (TK_mstr.TK_test_type,                                                   
                 whatstat,                                                              
                 TK_mstr.TK_ID,                                                         
                 TK_mstr.TK_test_seq,                                                   
                 datelist[LOOKUP("COMPLETE",statlist)],                                                              
                 OUTPUT v-trhid,                                                       
                 OUTPUT v-trhfound).                                                     

            IF v-trhfound = NO THEN DO: 
            
                RUN VALUE(SEARCH("SUBtrh-RStP-ucU.r"))                                
                    (0,                                     /* trh_ID */
                    TK_mstr.TK_test_type,
                    whatstat,
                    1,                                      /* trh_qty */
                    "",                                     /* trh_loc */
                    "",                                     /* trh_lot */
                    TK_mstr.tk_ID,
                    "",                                     /* trh_site */
                    TK_mstr.TK_test_seq,
                    datelist[LOOKUP("COMPLETE",statlist)],                              
                    OUTPUT o-trhID,
                    OUTPUT o-trherr).
                    
            END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
            /************ End of 1dot1 ***************/ 
            
        END.  /** of if collected < y < burned and date < 12/01/14 **/
        
    END.  /** of if datelist for complete = ? **/     
                                                                                
                                                                                IF ITshowmsg = YES THEN DO: 
                                                                                    DISPLAY 
                                                                                        y
                                                                                        ENTRY(y,statlist) 
                                                                                        datelist[y] tk_lab_paid
                                                                                        datelist[LOOKUP("VEND_PAID",statlist)]
                                                                                            WITH FRAME whatisup WIDTH 80.
                                                                                    PAUSE.
                                                                                END.    /** of if itshowmsg = yes **/
                                                                                
    IF TK_mstr.TK_lab_paid = ? THEN DO: 
        
        IF y >= lookup("COLLECTED",statlist) AND 
            y <= lookup("COMPLETE",statlist) AND 
            datelist[y] <= v-labpaiddate THEN DO:
            
            IF datelist[LOOKUP("VEND_PAID",statlist)] <> ? THEN 
                ASSIGN 
                    TK_mstr.TK_lab_paid = datelist[LOOKUP("VEND_PAID",statlist)].
            ELSE 
                ASSIGN 
                    TK_mstr.TK_lab_paid                     = v-labpaiddate
                    datelist[LOOKUP("VEND_PAID",statlist)]  = TK_mstr.tk_lab_paid.
                        
                                                                                    IF ITshowmsg = YES THEN 
                                                                                        MESSAGE "TK_lab_paid = " tk_lab_paid
                                                                                            VIEW-AS ALERT-BOX BUTTONS OK.
            
                    
            ASSIGN 
/*                datelist[LOOKUP("VEND_PAID",statlist)]  = datelist[y]*/
/*                TK_mstr.TK_lab_paid                     = datelist[LOOKUP("VEND_PAID",statlist)]*/
                TK_mstr.TK_modified_date                = TODAY
                TK_mstr.TK_modified_by                  = USERID("HHI")
                TK_mstr.TK_prog_name                    = THIS-PROCEDURE:FILE-NAME.

            /********  Begin 1dot1 ***********/      
            ASSIGN 
                v-trhid     = 0
                v-trhfound  = NO.                               
                                 
            RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
                (TK_mstr.TK_test_type,                                                   
                 "VEND_PAID",                                                              
                 TK_mstr.TK_ID,                                                         
                 TK_mstr.TK_test_seq,                                                   
                 datelist[LOOKUP("VEND_PAID",statlist)],                                                              
                 OUTPUT v-trhid,                                                       
                 OUTPUT v-trhfound).                                                     

            IF v-trhfound = NO THEN DO: 
            
                RUN VALUE(SEARCH("SUBtrh-RStP-ucU.r"))                                
                    (0,                                     /* trh_ID */
                    TK_mstr.TK_test_type,
                    "VEND_PAID",
                    1,                                      /* trh_qty */
                    "",                                     /* trh_loc */
                    "",                                     /* trh_lot */
                    TK_mstr.tk_ID,
                    "",                                     /* trh_site */
                    TK_mstr.TK_test_seq,
                    datelist[LOOKUP("VEND_PAID",statlist)],                              
                    OUTPUT o-trhID,
                    OUTPUT o-trherr).
                    
            END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
            /************ End of 1dot1 ***************/
            
        END.  /** of if collected < y < burned and date < v-labpaiddate **/
            
    END.  /** of if tk_lab_paid = ? **/
                  
    IF TK_mstr.TK_cust_paid = NO OR TK_mstr.TK_cust_paid = ? THEN DO: 
             
/*    IF datelist[LOOKUP("PAID_BY_CUST",statlist)] <> ? THEN DO:*/
    
        IF y >= lookup("COLLECTED",statlist) AND 
            y <= lookup("COMPLETE",statlist) AND 
            datelist[y] <= v-custpaiddate THEN DO:
                
            ASSIGN 
                TK_mstr.TK_cust_paid                        = YES  
                TK_mstr.TK_modified_date                    = TODAY
                TK_mstr.TK_modified_by                      = USERID("HHI")
                TK_mstr.TK_prog_name                        = THIS-PROCEDURE:FILE-NAME.
                
/*            IF datelist[LOOKUP("PAID_BY_CUST",statlist)] = ? THEN           */
/*                ASSIGN                                                      */
/*                    datelist[LOOKUP("PAID_BY_CUST",statlist)] = datelist[y].*/
                    
            IF datelist[LOOKUP("PAID_BY_CUST",statlist)] = ? THEN       /** still ? **/ 
                ASSIGN 
                    datelist[LOOKUP("PAID_BY_CUST",statlist)] = v-custpaiddate.
                 
                
            /********  Begin 1dot1 ***********/      
            ASSIGN 
                v-trhid     = 0
                v-trhfound  = NO.                               
                                 
            RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
                (TK_mstr.TK_test_type,                                                   
                 "PAID_BY_CUST",                                                              
                 TK_mstr.TK_ID,                                                         
                 TK_mstr.TK_test_seq,                                                   
                 datelist[LOOKUP("PAID_BY_CUST",statlist)],                                                              
                 OUTPUT v-trhid,                                                       
                 OUTPUT v-trhfound).                                                     

            IF v-trhfound = NO THEN DO: 
            
                RUN VALUE(SEARCH("SUBtrh-RStP-ucU.r"))                                
                    (0,                                     /* trh_ID */
                    TK_mstr.TK_test_type,
                    "PAID_BY_CUST",
                    1,                                      /* trh_qty */
                    "",                                     /* trh_loc */
                    "",                                     /* trh_lot */
                    TK_mstr.tk_ID,
                    "",                                     /* trh_site */
                    TK_mstr.TK_test_seq,
                    datelist[LOOKUP("PAID_BY_CUST",statlist)],                              
                    OUTPUT o-trhID,
                    OUTPUT o-trherr).
                                       
            END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
            /************ End of 1dot1 ***************/                     
 
        END.  /** of if collected < y < burned and date < 12/01/14 **/
        
/*        ELSE                              */
/*            ASSIGN                        */
/*                TK_mstr.TK_cust_paid = NO.*/
                
    END.  /** of if tk_cust_paid = no **/ 

    ELSE DO:        /** tk_cust_paid = yes **/
        
        /********  Begin 1dot1 ***********/      
        ASSIGN 
            v-trhid     = 0
            v-trhfound  = NO.                               
                             
        RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
            (TK_mstr.TK_test_type,                                                   
             "PAID_BY_CUST",                                                              
             TK_mstr.TK_ID,                                                         
             TK_mstr.TK_test_seq,                                                   
             datelist[LOOKUP("PAID_BY_CUST",statlist)],                                                              
             OUTPUT v-trhid,                                                       
             OUTPUT v-trhfound).                                                     

        IF v-trhfound = NO THEN DO: 
        
            IF datelist[LOOKUP("PAID_BY_CUST",statlist)] = ? THEN 
                ASSIGN 
                    datelist[LOOKUP("PAID_BY_CUST",statlist)] = IF datelist[y] < v-custpaiddate THEN datelist[y] ELSE v-custpaiddate.
                    
            IF datelist[LOOKUP("PAID_BY_CUST",statlist)] = ? THEN       /** still ? **/ 
                ASSIGN 
                    datelist[LOOKUP("PAID_BY_CUST",statlist)] = v-custpaiddate.                        
        
            RUN VALUE(SEARCH("SUBtrh-RStP-ucU.r"))                                
                (0,                                     /* trh_ID */
                TK_mstr.TK_test_type,
                "PAID_BY_CUST",
                1,                                      /* trh_qty */
                "",                                     /* trh_loc */
                "",                                     /* trh_lot */
                TK_mstr.tk_ID,
                "",                                     /* trh_site */
                TK_mstr.TK_test_seq,
                datelist[LOOKUP("PAID_BY_CUST",statlist)],                              
                OUTPUT o-trhID,
                OUTPUT o-trherr).
                
        END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
        /************ End of 1dot1 ***************/                     
                
    END.  /** of else do --- tk_cust_paid = YES **/
    
         
    EXPORT STREAM outward DELIMITER ";" 
        tk_mstr.tk_id 
        tk_mstr.tk_test_seq 
        tk_mstr.tk_test_type 
        initstat 
        tk_mstr.tk_create_date
        tk_mstr.tk_modified_date
        datelist 
        whatstat
        foundmpa
        foundtestres
        foundtksheet
        founddiff
        datelist[y].
        
        
    /************  Reset variables  *************/    
    DO x = 1 TO NUM-ENTRIES(statlist):
    
        datelist[x] = ?.
        
    END.  /** of do x = 1 to 17 **/
         
         
END.  /** of 4ea. tk_mstr **/

EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").

OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT
    VALUE(cmdname)
    VALUE(emailaddr)
    VALUE(messagetxt)
    VALUE(subjtxt)
    VALUE(cmdparams)
    VALUE(errlog).


/***************************  END OF FILE  *******************************/