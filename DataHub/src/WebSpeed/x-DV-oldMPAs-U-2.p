
/*------------------------------------------------------------------------
    File        : DV-oldMPAs-U-2.p
    Purpose     : 

    Syntax      :

    Description : Find all the old MPAs and make sure that their records are properly created in the database.

    Author(s)   : Doug Luttrell
    Created     : Tue Sep 29 21:20:39 EDT 2015
    Notes       :
        
  ************************************************************************
  Revision History:
  -----------------
  1.0 - written by DOUG LUTTRELL on 29/Sep/15.  Original Version.
  1.1 - written by DOUG LUTTRELL on 05/Feb/16.  This program has gotten too convoluted and is
            offtrack.  I have rewritten the flowchart for it, simplifying the process.  Not marked.
                  
  ----------------------------------------------------------------------*/
 
/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE v-tkid LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE VARIABLE v-created AS LOG NO-UNDO.
DEFINE VARIABLE v-updated AS LOG NO-UNDO.
DEFINE VARIABLE v-avail AS LOG NO-UNDO.
DEFINE VARIABLE v-success AS LOG NO-UNDO.
DEFINE VARIABLE v-error AS LOG NO-UNDO.

DEFINE VARIABLE starttime AS DATETIME NO-UNDO.
DEFINE VARIABLE endtime AS DATETIME NO-UNDO.
DEFINE VARIABLE updatemode AS LOG INITIAL YES NO-UNDO.                           /* change this to update database */

DEFINE VARIABLE tempfn LIKE VF1_det.VF1_firstname NO-UNDO.
DEFINE VARIABLE tempmn LIKE VF1_det.VF1_middlename NO-UNDO.
DEFINE VARIABLE templn LIKE VF1_det.VF1_lastname NO-UNDO.
DEFINE VARIABLE temppre LIKE people_mstr.people_prefix NO-UNDO. 
DEFINE VARIABLE tempsuf LIKE people_mstr.people_suffix NO-UNDO. 
DEFINE VARIABLE tempgender LIKE people_mstr.people_gender NO-UNDO.  
DEFINE VARIABLE temppat LIKE patient_mstr.patient_ID NO-UNDO. 
DEFINE VARIABLE temptesttype LIKE VF1_det.VF1_MPA_Test_Type NO-UNDO.
DEFINE VARIABLE tempsampleid LIKE VF1_det.VF1_TKID_SampleID NO-UNDO.
DEFINE VARIABLE tempseq LIKE TK_mstr.TK_test_seq NO-UNDO.
 
/**********  Variables to use in include file *****************/
DEFINE VARIABLE o-fpe-peopleID  LIKE people_mstr.people_id NO-UNDO.
DEFINE VARIABLE o-fpe-addr_ID LIKE people_mstr.people_addr_id NO-UNDO.
DEFINE VARIABLE o-patID LIKE patient_mstr.patient_ID NO-UNDO.
DEFINE VARIABLE o-fpat-ran AS LOG NO-UNDO.
DEFINE VARIABLE o-created AS LOG NO-UNDO.
DEFINE VARIABLE o-updated AS LOG NO-UNDO.
DEFINE VARIABLE o-avail AS LOG NO-UNDO.
DEFINE VARIABLE o-success AS LOG NO-UNDO.
DEFINE VARIABLE o-error AS LOG NO-UNDO. 
DEFINE VARIABLE o-tkid LIKE TK_mstr.TK_ID NO-UNDO. 

DEFINE VARIABLE kount AS INTEGER EXTENT 40 NO-UNDO.                             /* error catcher */

DEFINE VARIABLE x AS INTEGER LABEL "Total" NO-UNDO.
DEFINE VARIABLE y AS INTEGER LABEL "Less Matched" NO-UNDO.
DEFINE VARIABLE z AS INTEGER LABEL "Not Matched" NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE j AS INTEGER NO-UNDO.                                           /** junk counter for CONTAINS search **/

/*** vars for the fullname search ***/
DEFINE  VARIABLE     io-prefix        LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE  VARIABLE     io-firstname     LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE  VARIABLE     io-middlename    LIKE people_mstr.people_midname     NO-UNDO.
DEFINE  VARIABLE     io-lastname      LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE  VARIABLE     io-suffix        LIKE people_mstr.people_suffix      NO-UNDO.
DEFINE  VARIABLE     o-title_desc    LIKE people_mstr.people_title       NO-UNDO.
DEFINE  VARIABLE     o-prefname      LIKE people_mstr.people_prefname    NO-UNDO.
DEFINE  VARIABLE     o-gender        LIKE people_mstr.people_gender      NO-UNDO.
DEFINE  VARIABLE     o-unstring-error AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE  VARIABLE     o-field-in-error AS CHARACTER FORMAT "X(30)"        NO-UNDO.

DEFINE VARIABLE tempDOB AS DATE NO-UNDO.

DEFINE VARIABLE  o-fpe-error     AS LOGICAL INITIAL NO               NO-UNDO.

/*** vars for the broken up name search ***/
DEFINE  VARIABLE     io-prefix2        LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE  VARIABLE     io-firstname2     LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE  VARIABLE     io-middlename2    LIKE people_mstr.people_midname     NO-UNDO.
DEFINE  VARIABLE     io-lastname2      LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE  VARIABLE     io-suffix2        LIKE people_mstr.people_suffix      NO-UNDO.
DEFINE  VARIABLE     o-title_desc2    LIKE people_mstr.people_title       NO-UNDO.
DEFINE  VARIABLE     o-prefname2      LIKE people_mstr.people_prefname    NO-UNDO.
DEFINE  VARIABLE     o-gender2        LIKE people_mstr.people_gender      NO-UNDO.
DEFINE  VARIABLE     o-unstring-error2 AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE  VARIABLE     o-field-in-error2 AS CHARACTER FORMAT "X(30)"        NO-UNDO.

DEFINE VARIABLE o-trhid LIKE trh_hist.trh_ID NO-UNDO. 


DEFINE VARIABLE tempDOB2 AS DATE NO-UNDO.

DEFINE VARIABLE  o-fpe-peopleID2  LIKE people_mstr.people_id          NO-UNDO.
DEFINE VARIABLE  o-fpe-addr_ID2   LIKE people_mstr.people_addr_id     NO-UNDO.
DEFINE VARIABLE  o-fpe-error2     AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE  o-fpat-ran2      AS LOGICAL INITIAL NO               NO-UNDO.

DEFINE STREAM errlog.
OUTPUT STREAM errlog TO "C:\progress\wrk\exports\OldMPAs_ERRORlog.txt".
EXPORT STREAM errlog DELIMITER ";"
    "exportSample_HoldID" 
    "sample_ID" 
    "gps_id" 
    "batch_ID"
    "VF1_ID" 
    "Firstname" 
    "Middlename" 
    "Lastname" 
    "AcctNbr_TKID_SampleID" 
    "Customer_Type" 
    "Batch_ID" 
    "EY_nbr"
    "DOB"
    "MPA_Test_Type"
    "TK_ID"
    "TK_test_seq"
    "TK_testtype".

DEFINE STREAM outward.
OUTPUT STREAM outward TO "C:\progress\wrk\exports\OldMPAs_Semi_Matching.txt".
EXPORT STREAM outward DELIMITER ";"
    "exportSample_HoldID" "sample_ID" "gps_id" "batch_ID"
    "VF1_ID" "Firstname" "Middlename" "Lastname" 
    "AcctNbr_TKID_SampleID" 
    "Customer_Type" 
    "Batch_ID" "EY_nbr"
    "DOB"
    "MPA_Test_Type".
    
DEFINE STREAM out2.
OUTPUT STREAM out2 TO "C:\progress\wrk\exports\OldMPAs_Non_Matching.txt".
EXPORT STREAM out2 DELIMITER ";"
    "sample_id" 
    "gps_id" 
    "batch_id"
    "Correct_QB"
    "Delete".    
    
DEFINE STREAM goodstuff.
OUTPUT STREAM goodstuff TO "C:\progress\wrk\exports\OldMPAs_Matched.txt".
EXPORT STREAM goodstuff DELIMITER ";"
    "VF1_ID" "Fullname" "Firstname" "Middlename" "Lastname" "DOB"
    "FN-PatientID" "FN-prefix" "FN-firstname" "FN-middlename" "FN-lastname" "FN-suffix" "FN-DOB"
    "P-PatientID" "P-prefix" "P-firstname" "P-middlename" "P-lastname" "P-suffix" "P-DOB".   
    
DEFINE STREAM detdiff.
OUTPUT STREAM detdiff TO "C:\progress\wrk\exports\OldMPAs_Wrong_Details.txt".
EXPORT STREAM detdiff DELIMITER ";"
    "Sample_ID" "SNP_ID" "eD_Call" "TK_ID" "tkr_lab_result".
     
DEFINE BUFFER peop2 FOR people_mstr.
DEFINE STREAM badpat.
OUTPUT STREAM badpat TO "C:\progress\wrk\exports\OldMPAs_Bad_Patients.txt".     
EXPORT STREAM badpat DELIMITER ";"
    "People_ID" "People_Lastname" "People_Firstname" "People_DOB"
    "TK_ID" "Test_Seq" "Patient_ID" "Cust_ID"
    "Patient_Lastname" "Patient_Firstname" "Patient_DOB".
 
starttime = NOW. 
       
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
PAUSE 0 BEFORE-HIDE.

main-loop: 
FOR EACH exportSampleMMDDYYYY WHERE exportSampleMMDDYYYY.Progress_Flag <> "D" NO-LOCK: 
    
    ASSIGN 
        kount[1]            = kount[1] + 1    /* Total overall record count from the lab full MPA listing file */
        x                   = x + 1
        io-prefix2          = ""
        io-firstname2       = ""
        io-middlename2      = ""
        io-lastname2        = ""
        io-suffix2          = ""
        o-title_desc2       = ""
        o-prefname2         = ""
        o-gender2           = ?
        o-unstring-error2   = ?
        o-field-in-error2   = ""
        tempDOB             = ?
        tempfn              = ""
        tempmn              = ""
        templn              = ""
        temptesttype        = ""
        tempsampleid        = ""
        .
    
    FIND FIRST VF1_det WHERE VF1_det.VF1_EY_nbr = exportSampleMMDDYYYY.sample_id AND 
        VF1_det.VF1_TKID_SampleID = exportSampleMMDDYYYY.gps_id AND 
        VF1_det.VF1_batch_ID = exportSampleMMDDYYYY.batch_id AND 
        VF1_det.VF1_deleted = ?
            USE-INDEX vf1-mainhit-idx NO-LOCK NO-ERROR. 
                        
    IF NOT AVAILABLE (VF1_det) THEN DO:   
        
        ASSIGN 
            kount[7]    = kount[7] + 1                                                      /* Not matched precisely */ 
            y           = y + 1
            i           = 0.
        
        FOR EACH VF1_det WHERE VF1_det.VF1_EY_nbr = exportSampleMMDDYYYY.sample_id AND 
            VF1_det.VF1_deleted = ? NO-LOCK:
            
            ASSIGN 
                i               = i + 1
                tempDOB         = VF1_det.VF1_GOOD_DOB 
                tempfn          = VF1_det.VF1_firstname 
                tempmn          = VF1_det.VF1_middlename 
                templn          = VF1_det.VF1_lastname 
                temptesttype    = VF1_det.VF1_MPA_Test_Type
                tempsampleid    = VF1_det.VF1_TKID_SampleID.

        END.  /** of 4ea. vf1_det --- just on sample_id **/
        
        IF i = 1 THEN DO: 
            
            kount[8] = kount[8] + 1.                                        /* Single match on Sample ID and EY Number */ 
                            
        END.  /** of if i = 1 --- found a single match **/
            
        ELSE IF i > 1 THEN DO:
            
            ASSIGN 
                kount[9]    = kount[9] + 1                                  /* Multi-match on Sample ID and EY Number */
                z           = z + 1.
                
            EXPORT STREAM errlog DELIMITER ";"
                eS_HoldID 
                sample_id
                gps_id
                batch_ID
                0                           /* VF1_ID */
                tempfn
                tempmn
                templn
                tempsampleid
                ""                          /* Customer_Type */
                ""                          /* Batch_ID */
                ""                          /* EY_nbr */
                tempdob
                temptesttype
                tempsampleid
                0                           /* TK_test_seq */
                temptesttype
                "ERROR!  Multiple matches on this Sample_ID and EY_Number.".

            NEXT main-loop.

        END.   /*** of else if i > 1 ***/             
        
        ELSE DO:
            
            kount[10] = kount[10] + 1.                                          /* Non-matched --- trying a BEGINS string */
            
            i = 0.

            FOR EACH VF1_det WHERE VF1_det.VF1_EY_nbr BEGINS exportSampleMMDDYYYY.sample_id AND 
                VF1_det.VF1_TKID_SampleID = exportSampleMMDDYYYY.gps_id AND 
                VF1_det.VF1_deleted = ? NO-LOCK:

                ASSIGN 
                    i               = i + 1
                    tempDOB         = VF1_det.VF1_GOOD_DOB 
                    tempfn          = VF1_det.VF1_firstname 
                    tempmn          = VF1_det.VF1_middlename 
                    templn          = VF1_det.VF1_lastname 
                    temptesttype    = VF1_det.VF1_MPA_Test_Type
                    tempsampleid    = VF1_det.VF1_TKID_SampleID.

            END.  /** of 4ea. vf1_det --- BEGINS style **/

            IF i = 1 THEN DO: 
                
                kount[22] = kount[22] + 1.                                          /** Re-found a single record by BEGINS **/ 
                                   
            END.  /** of if i = 1 **/
            
            ELSE IF i > 1 THEN DO:
                
                ASSIGN 
                    kount[23]   = kount[23] + 1                                     /** Re-found multiples by BEGINS **/
                    z           = z + 1.

                EXPORT STREAM errlog DELIMITER ";"
                    eS_HoldID 
                    sample_id
                    gps_id
                    batch_ID
                    0                           /* VF1_ID */
                    tempfn
                    tempmn
                    templn
                    tempsampleid
                    ""                          /* Customer_Type */
                    ""                          /* Batch_ID */
                    ""                          /* EY_nbr */
                    tempdob
                    temptesttype
                    tempsampleid
                    0                           /* TK_test_seq */
                    temptesttype
                    "ERROR!  Multiple matches where BEGINS by Sample_ID and EY_Number.".
    
                NEXT main-loop.

            END.  /** of if i > 0 **/

            ELSE DO:
            
                kount[24] = kount[24] + 1.      /* Still no records found by BEGINS */
                
                EXPORT STREAM errlog DELIMITER ";"
                    eS_HoldID 
                    sample_id
                    gps_id
                    batch_ID
                    0                           /* VF1_ID */
                    tempfn
                    tempmn
                    templn
                    tempsampleid
                    ""                          /* Customer_Type */
                    ""                          /* Batch_ID */
                    ""                          /* EY_nbr */
                    tempdob
                    temptesttype
                    tempsampleid
                    0                           /* TK_test_seq */
                    temptesttype
                    "ERROR!  Fix SampleID number manually.".
    
                NEXT main-loop.
                        
            END.  /** else do -- no vf1_dets found again **/
                
        END.  /** of else do -- i=0 **/
        
    END.  /** of if not can-find --- kount[7] branch **/    

    ELSE DO:

        ASSIGN 
            kount[2]            = kount[2] + 1      /* Total of successful direct finds based on the information from QuickBooks */
            tempDOB             = VF1_det.VF1_GOOD_DOB 
            tempfn              = VF1_det.VF1_firstname 
            tempmn              = VF1_det.VF1_middlename 
            templn              = VF1_det.VF1_lastname 
            temptesttype        = VF1_det.VF1_MPA_Test_Type
            tempsampleid        = VF1_det.VF1_TKID_SampleID.

    END. /** of else do --- avail vf1_det mainhit **/

    /***** Verify minimum people requirements *****/
    IF tempfn = "" OR templn = "" OR tempdob = ? THEN DO: 
        
        ASSIGN 
            kount[3]    = kount[3] + 1.                                         /* FN, LN, DOB violation */
            
        EXPORT STREAM errlog DELIMITER ";"
            eS_HoldID 
            sample_id
            gps_id
            batch_ID
            0                           /* VF1_ID */
            tempfn
            tempmn
            templn
            tempsampleid
            ""                          /* Customer_Type */
            ""                          /* Batch_ID */
            ""                          /* EY_nbr */
            tempdob
            temptesttype
            tempsampleid
            0                           /* TK_test_seq */
            temptesttype
            "ERROR!  Firstname, Lastname, or DOB is blank.".

        NEXT main-loop. 
     
    END.  /** of if tempfn, templn, or tempDOB are blank **/

    {DV-oldMPAs-peopleget.i}.                                       /* make sure people and patient exist and FIND people_mstr */ 
    
    /**************  Testkit time  ****************/
    ASSIGN 
        i   = 0.
    
    IF temptesttype = "" THEN 
        temptesttype = "BLANK".
    ELSE IF temptesttype = "Supplemental Panel" THEN 
        temptesttype = "SP".
        
    FOR EACH TK_mstr WHERE TK_mstr.TK_ID = exportSampleMMDDYYYY.gps_id AND 
            TK_mstr.TK_test_type = temptesttype NO-LOCK,
        FIRST test_mstr WHERE test_mstr.test_type = TK_mstr.TK_test_type AND 
            test_mstr.test_family = "MPA" NO-LOCK:
                
        ASSIGN 
            i       = i + 1
            temppat = TK_mstr.tk_patient_id
            tempseq = TK_mstr.TK_test_seq.
            
        IF i > 1 THEN  
            DISPLAY TK_mstr.TK_ID TK_mstr.TK_test_seq.    
            
    END.  /** of 4ea. tk_mstr, etc. **/    
        
    IF i = 0 THEN DO: 
        
        ASSIGN 
            tempseq     = 0
            kount[26]   = kount[26] + 1.                                            /* TK_mstr not found - create */  
        
        FIND LAST TK_mstr WHERE TK_mstr.TK_ID = exportSampleMMDDYYYY.gps_id
            NO-LOCK NO-ERROR.
            
        IF AVAILABLE (tk_mstr) THEN 
            tempseq = TK_mstr.tk_test_seq. 
            
        tempseq = tempseq + 1.
        
        IF updatemode = YES THEN DO TRANSACTION: 
        
            RUN VALUE (SEARCH ("SUBtkmstrRSTPucU.r"))
                (exportSampleMMDDYYYY.gps_id,                   /* TK_ID */ 
                 temptesttype, 
                 ?,                                             /* professional? */
                 tempseq,                                       /* tk_test_seq */
                 ?,                                             /* domestic */
                 0,                                             /* cust_id */
                 people_mstr.people_id,                         /* patient_ID */
                 exportSampleMMDDYYYY.gps_id,                   /* lab_sample_id */
                 tempseq,                                       /* lab_seq */
                 0,                                             /* test_age */
                 "DDI",                                         /* Lab_ID */
                 "COMPLETE",                                    /* status */
                 "",                                            /* comments */
                 "",                                            /* notes */
                 YES,                                           /* cust_paid */
                 YES,                                           /* label printed */
                 01/01/2015,                                    /* lab_paid */
                 OUTPUT o-tkid,
                 OUTPUT o-created,
                 OUTPUT o-updated,
                 OUTPUT o-avail,
                 OUTPUT o-success). 
                                         
            ASSIGN 
                TK_mstr.TK_status           = "COMPLETE"
                TK_mstr.TK_modified_by      = USERID("HHI")
                TK_mstr.TK_modified_date    = TODAY
                TK_mstr.tk_prog_name        = THIS-PROCEDURE:FILE-NAME
                TK_mstr.tk_cust_paid        = YES
                TK_mstr.TK_lab_paid         = 12/31/2012.
            
            
            /*** create PAID_BY_CUST records in the trh_hist ***/   
            ASSIGN 
                o-trhid     = 0
                o-success   = NO.
                 
            RUN VALUE (SEARCH ("SUBtrh-RStP-findR.r"))
                (TK_mstr.tk_test_type, 
                 "PAID_BY_CUST", 
                 TK_mstr.tk_id, 
                 TK_mstr.tk_test_seq, 
                 12/31/2012,                                     /* create date */
                 OUTPUT o-trhid, 
                 OUTPUT o-success).
                 
            IF o-success = NO THEN DO: 
                
                RUN VALUE (SEARCH ("SUBtrh-RStP-ucU.r"))
                    (0,                                             /* trh_id */
                     TK_mstr.tk_test_type,
                     "PAID_BY_CUST",
                     1,                                             /* qty */
                     "",                                            /* loc */
                     "",                                            /* lot */
                     TK_mstr.tk_id,
                     "",                                            /* site */
                     TK_mstr.tk_test_seq,
                     12/31/2012,                                    /* trh_create_date */
                     OUTPUT o-trhid,
                     OUTPUT o-error).       
        
            END.  /** of if o-success = no --- no trh_hist found **/   
            
            
            /**** create VEND_PAID in the trh_hist ****/
            ASSIGN 
                o-trhid     = 0
                o-success   = NO.
                
            RUN VALUE (SEARCH ("SUBtrh-RStP-findR.r"))
                (TK_mstr.tk_test_type, 
                 "VEND_PAID", 
                 TK_mstr.tk_id, 
                 TK_mstr.tk_test_seq, 
                 12/31/2012,                                     /* create date */
                 OUTPUT o-trhid, 
                 OUTPUT o-success).
                 
            IF o-success = NO THEN DO: 
                
                RUN VALUE (SEARCH ("SUBtrh-RStP-ucU.r"))
                    (0,                                             /* trh_id */
                     TK_mstr.tk_test_type,
                     "VEND_PAID",
                     1,                                             /* qty */
                     "",                                            /* loc */
                     "",                                            /* lot */
                     TK_mstr.tk_id,
                     "",                                            /* site */
                     TK_mstr.tk_test_seq,
                     12/31/2012,                                    /* trh_create_date */
                     OUTPUT o-trhid,
                     OUTPUT o-error).       
        
            END.  /** of if o-success = no --- no trh_hist found **/   
            
                            

            /******  Create COMPLETE records in trh_hist ******/   
            ASSIGN 
                o-trhid     = 0
                o-success   = NO.                
                 
            RUN VALUE (SEARCH ("SUBtrh-RStP-findR.r"))
                (TK_mstr.tk_test_type, 
                 "COMPLETE", 
                 TK_mstr.tk_id, 
                 TK_mstr.tk_test_seq, 
                 12/31/2012,                                     /* create date */
                 OUTPUT o-trhid, 
                 OUTPUT o-success).
                 
            IF o-success = NO THEN DO: 
                
                RUN VALUE (SEARCH ("SUBtrh-RStP-ucU.r"))
                    (0,                                             /* trh_id */
                     TK_mstr.tk_test_type,
                     "COMPLETE",
                     1,                                             /* qty */
                     "",                                            /* loc */
                     "",                                            /* lot */
                     TK_mstr.tk_id,
                     "",                                            /* site */
                     TK_mstr.tk_test_seq,
                     12/31/2012,                                    /* trh_create_date */
                     OUTPUT o-trhid,
                     OUTPUT o-error).       
        
            END.  /** of if o-success = no --- no trh_hist found **/                                            
                                         
            /*** create TKR_det records here ***/             
            FOR EACH exportDataMMDDYYYY WHERE exportDataMMDDYYYY.data_sample_id = exportSampleMMDDYYYY.sample_id NO-LOCK: 
                
                FIND TKR_det WHERE TKR_det.TKR_ID = exportSampleMMDDYYYY.gps_id AND 
                    TKR_det.TKR_test_seq = tempseq AND 
                    TKR_det.TKR_item = exportDataMMDDYYYY.data_snp_id
                        NO-LOCK NO-ERROR.
                        
                IF NOT AVAILABLE (tkr_det) THEN DO:
                    
                    CREATE TKR_det.
                    ASSIGN 
                        TKR_det.TKR_ID              = exportSampleMMDDYYYY.gps_id
                        TKR_det.tkr_test_seq        = tempseq
                        TKR_det.tkr_item            = exportDataMMDDYYYY.data_snp_id
                        TKR_det.TKR_lab_result      = exportDataMMDDYYYY.data_call
                        TKR_det.TKR_lab_ref         = exportDataMMDDYYYY.data_display_call
                        TKR_det.TKR_prog_name       = THIS-PROCEDURE:FILE-NAME 
                        TKR_det.TKR_created_by      = USERID("HHI")
                        TKR_det.TKR_create_date     = TODAY 
                        TKR_det.TKR_modified_by     = USERID("HHI")
                        TKR_det.TKR_modified_date   = TODAY. 
                                            
                END.  /** of if not avail tkr_det **/ 
                
                ELSE DO: 
                    
                    EXPORT STREAM errlog DELIMITER ";"
                        eS_HoldID 
                        sample_id
                        gps_id
                        batch_ID
                        0                           /* VF1_ID */
                        tempfn
                        tempmn
                        templn
                        tempsampleid
                        ""                          /* Customer_Type */
                        ""                          /* Batch_ID */
                        ""                          /* EY_nbr */
                        tempdob
                        temptesttype
                        tempsampleid
                        0                           /* TK_test_seq */
                        temptesttype
                        "ERROR!  TKR_det already existed.".
                    
                    UNDO, NEXT main-loop.
                    
                END.  /** of else do --- tkr_det already available **/
                
            END.  /** of 4ea. exportdatammddyyyy **/
                     
        END.  /** of if updatemode = yes **/             
        
    END.  /** of if i = 0 --- no TK_mstr records **/
    
    ELSE IF i = 1 THEN DO: 
    
        kount[25]   = kount[25] + 1.                                                /* Found a single TK_mstr */
    
        /**** In here is where the status update goes ****/
        IF updatemode = YES THEN DO:
            
            FOR EACH TK_mstr WHERE TK_mstr.TK_ID = exportSampleMMDDYYYY.gps_id AND 
                    TK_mstr.TK_test_type = temptesttype,
                FIRST test_mstr WHERE test_mstr.test_type = TK_mstr.TK_test_type AND 
                    test_mstr.test_family = "MPA" NO-LOCK:
                        
                ASSIGN 
                    TK_mstr.TK_status           = "COMPLETE"
                    TK_mstr.TK_modified_by      = USERID("HHI")
                    TK_mstr.TK_modified_date    = TODAY
                    TK_mstr.tk_prog_name        = THIS-PROCEDURE:FILE-NAME
                    TK_mstr.tk_cust_paid        = YES
                    TK_mstr.TK_lab_paid         = 12/31/2012.
                
                
                /*** create PAID_BY_CUST records in the trh_hist ***/   
                ASSIGN 
                    o-trhid     = 0
                    o-success   = NO.
                     
                RUN VALUE (SEARCH ("SUBtrh-RStP-findR.r"))
                    (TK_mstr.tk_test_type, 
                     "PAID_BY_CUST", 
                     TK_mstr.tk_id, 
                     TK_mstr.tk_test_seq, 
                     12/31/2012,                                     /* create date */
                     OUTPUT o-trhid, 
                     OUTPUT o-success).
                     
                IF o-success = NO THEN DO: 
                    
                    RUN VALUE (SEARCH ("SUBtrh-RStP-ucU.r"))
                        (0,                                             /* trh_id */
                         TK_mstr.tk_test_type,
                         "PAID_BY_CUST",
                         1,                                             /* qty */
                         "",                                            /* loc */
                         "",                                            /* lot */
                         TK_mstr.tk_id,
                         "",                                            /* site */
                         TK_mstr.tk_test_seq,
                         12/31/2012,                                    /* trh_create_date */
                         OUTPUT o-trhid,
                         OUTPUT o-error).       
            
                END.  /** of if o-success = no --- no trh_hist found **/   
                
                
                /**** create VEND_PAID in the trh_hist ****/
                ASSIGN 
                    o-trhid     = 0
                    o-success   = NO.
                    
                RUN VALUE (SEARCH ("SUBtrh-RStP-findR.r"))
                    (TK_mstr.tk_test_type, 
                     "VEND_PAID", 
                     TK_mstr.tk_id, 
                     TK_mstr.tk_test_seq, 
                     12/31/2012,                                     /* create date */
                     OUTPUT o-trhid, 
                     OUTPUT o-success).
                     
                IF o-success = NO THEN DO: 
                    
                    RUN VALUE (SEARCH ("SUBtrh-RStP-ucU.r"))
                        (0,                                             /* trh_id */
                         TK_mstr.tk_test_type,
                         "VEND_PAID",
                         1,                                             /* qty */
                         "",                                            /* loc */
                         "",                                            /* lot */
                         TK_mstr.tk_id,
                         "",                                            /* site */
                         TK_mstr.tk_test_seq,
                         12/31/2012,                                    /* trh_create_date */
                         OUTPUT o-trhid,
                         OUTPUT o-error).       
            
                END.  /** of if o-success = no --- no trh_hist found **/   
                
                                

                /******  Create COMPLETE records in trh_hist ******/   
                ASSIGN 
                    o-trhid     = 0
                    o-success   = NO.                
                     
                RUN VALUE (SEARCH ("SUBtrh-RStP-findR.r"))
                    (TK_mstr.tk_test_type, 
                     "COMPLETE", 
                     TK_mstr.tk_id, 
                     TK_mstr.tk_test_seq, 
                     12/31/2012,                                     /* create date */
                     OUTPUT o-trhid, 
                     OUTPUT o-success).
                     
                IF o-success = NO THEN DO: 
                    
                    RUN VALUE (SEARCH ("SUBtrh-RStP-ucU.r"))
                        (0,                                             /* trh_id */
                         TK_mstr.tk_test_type,
                         "COMPLETE",
                         1,                                             /* qty */
                         "",                                            /* loc */
                         "",                                            /* lot */
                         TK_mstr.tk_id,
                         "",                                            /* site */
                         TK_mstr.tk_test_seq,
                         12/31/2012,                                    /* trh_create_date */
                         OUTPUT o-trhid,
                         OUTPUT o-error).       
            
                END.  /** of if o-success = no --- no trh_hist found **/        
                    
            END.  /** of 4ea. tk_mstr, etc. **/
        
        END.  /** of if updatemode = yes --- fix various **/         
    
    
        /**** Verify TK_patient_ID  ****/
        IF temppat <> o-fpe-peopleID THEN DO: 
            
            kount[6] = kount[6] + 1.                                              /* TK_patient_ID is wrong - correcting */
            
            IF updatemode = YES THEN DO:
                
                FOR EACH TK_mstr WHERE TK_mstr.TK_ID = exportSampleMMDDYYYY.gps_id AND 
                        TK_mstr.TK_test_type = temptesttype,
                    FIRST test_mstr WHERE test_mstr.test_type = TK_mstr.TK_test_type AND 
                        test_mstr.test_family = "MPA" NO-LOCK:
                            
                    ASSIGN 
                        TK_mstr.TK_patient_ID = o-fpe-peopleID.
                        
                END.  /** of 4ea. tk_mstr, etc. **/
            
            END.  /** of if updatemode = yes --- fix patient mismatch **/            
            
        END.  /*** of if temppat <> o-fpe-peopleID  --- mismatched patient_ID ***/    
        
        /********  Verify TKR_det  ***********/
        FOR EACH exportDataMMDDYYYY WHERE exportDataMMDDYYYY.data_sample_id = exportSampleMMDDYYYY.sample_id NO-LOCK: 
            
            FIND TKR_det WHERE TKR_det.TKR_ID = exportSampleMMDDYYYY.gps_id AND 
                TKR_det.TKR_test_seq = tempseq AND 
                TKR_det.TKR_item = exportDataMMDDYYYY.data_snp_id
                    EXCLUSIVE-LOCK NO-ERROR.
                    
            IF NOT AVAILABLE (tkr_det) THEN DO:

                kount[29]    = kount[29] + 1.                                       /* No TKR_det found - create one */ 
                
                EXPORT STREAM errlog DELIMITER ";"
                    eS_HoldID 
                    sample_id
                    gps_id
                    batch_ID
                    0                           /* VF1_ID */
                    tempfn
                    tempmn
                    templn
                    tempsampleid
                    ""                          /* Customer_Type */
                    ""                          /* Batch_ID */
                    ""                          /* EY_nbr */
                    tempdob
                    temptesttype
                    tempsampleid
                    0                           /* TK_test_seq */
                    temptesttype
                    "ERROR!  TKR_det does not exist.".
                
                IF updatemode = YES THEN DO:
                
                    CREATE TKR_det.
                    ASSIGN
                        TKR_det.TKR_ID              = exportSampleMMDDYYYY.gps_id
                        TKR_det.tkr_test_seq        = tempseq
                        TKR_det.tkr_item            = exportDataMMDDYYYY.data_snp_id
                        TKR_det.TKR_lab_result      = exportDataMMDDYYYY.data_call
                        TKR_det.TKR_lab_ref         = exportDataMMDDYYYY.data_display_call
                        TKR_det.TKR_prog_name       = THIS-PROCEDURE:FILE-NAME
                        TKR_det.TKR_created_by      = USERID("HHI")
                        TKR_det.TKR_create_date     = TODAY
                        TKR_det.TKR_modified_by     = USERID("HHI")
                        TKR_det.TKR_modified_date   = TODAY.
                     
                END.  /* of if updatemode = yes --- missing TKR_det - create */         
                                        
            END.  /** of if not avail tkr_det **/ 
            
            ELSE DO: 
                
                IF TKR_det.tkr_lab_result   <> exportDataMMDDYYYY.data_call THEN DO: 
                    
                    kount[27]     = kount[27] + 1.                                              /* TKR_det found but wrong result */ 
                    
                    EXPORT STREAM detdiff DELIMITER ";"
                        exportSampleMMDDYYYY.gps_id exportDataMMDDYYYY.data_snp_id exportDataMMDDYYYY.data_call 
                        TKR_det.TKR_ID TKR_det.tkr_lab_result.                    
                    
                    IF updatemode = YES THEN
                        ASSIGN 
                            TKR_det.tkr_lab_result      = exportDataMMDDYYYY.data_call 
                            TKR_det.TKR_modified_date   = TODAY 
                            TKR_det.TKR_modified_by     = USERID("HHI")
                            TKR_det.tkr_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                    
                END.  /** of if lab_result <> data_call **/
                
                ELSE 
                    kount[28]   = kount[28] + 1.                                                /* TKR_det found and OK */
                
            END.  /** of else do --- tkr_det already available **/
            
        END.  /** of 4ea. exportdatammddyyyy **/
        
    END.  /** of if i = 1 --- single TK_mstr record **/
    
    ELSE DO: 
        
        kount[30]   = kount[30] + 1.                                                    /* Too many TK_mstr records */
        
        EXPORT STREAM errlog DELIMITER ";"
            eS_HoldID 
            sample_id
            gps_id
            batch_ID
            0                           /* VF1_ID */
            tempfn
            tempmn
            templn
            tempsampleid
            ""                          /* Customer_Type */
            ""                          /* Batch_ID */
            ""                          /* EY_nbr */
            tempdob
            temptesttype
            tempsampleid
            0                           /* TK_test_seq */
            temptesttype
            "ERROR!  Multiple MPA matches on this TK_ID.".

        NEXT main-loop.        
        
    END.  /** of else do --- multiple TK_mstr records found **/

END.    /**** OF 4ea. exportSampleMMDDYYYY ****/

DISPLAY STREAM goodstuff 

    "Kount[1]  = "   kount[1]   "Total overall record count from the lab full MPA listing file" SKIP 
    "Kount[2]  = "   kount[2]   "Total of successful direct finds based on the information from QuickBooks" SKIP 
    "Kount[3]  = "   kount[3]   "FN, LN, DOB violation" SKIP 
    "Kount[4]  = "   kount[4]   "Person not found - creating one" SKIP
    "Kount[5]  = "   kount[5]   "Person found" SKIP
    "Kount[6]  = "   kount[6]   "TK_patient_ID is wrong - correcting" SKIP
    "Kount[7]  = "   kount[7]   "Not matched precisely" SKIP
    "Kount[8]  = "   kount[8]   "Single match on Sample ID and EY Number" SKIP
    "Kount[9]  = "   kount[9]   "Multi-match on Sample ID and EY Number" SKIP
    "Kount[10] = "  kount[10]   "Non-matched --- trying a BEGINS string" SKIP

    "Kount[21] = "  kount[21]   "" SKIP
    "Kount[22] = "  kount[22]   "Re-found a single record by BEGINS" SKIP
    "Kount[23] = "  kount[23]   "Re-found multiples by BEGINS" SKIP
    "Kount[24] = "  kount[24]   "Still no records found by BEGINS" SKIP
    "Kount[25] = "  kount[25]   "Found a single TK_mstr" SKIP
    "Kount[26] = "  kount[26]   "TK_mstr not found - create" SKIP
    "Kount[27] = "  kount[27]   "TKR_det found but wrong result" SKIP
    "Kount[28] = "  kount[28]   "TKR_det found and OK" SKIP
    "Kount[29] = "  kount[29]   "No TKR_det found - create one" SKIP
    "Kount[30] = "  kount[30]   "Too many TK_mstr records" SKIP    
        
        WITH FRAME gs NO-LABELS WIDTH 232.
    
DISPLAY STREAM out2 

    "Kount[1]  = "   kount[1]   "Total overall record count from the lab full MPA listing file" SKIP 
    "Kount[2]  = "   kount[2]   "Total of successful direct finds based on the information from QuickBooks" SKIP 
    "Kount[3]  = "   kount[3]   "FN, LN, DOB violation" SKIP 
    "Kount[4]  = "   kount[4]   "Person not found - creating one" SKIP
    "Kount[5]  = "   kount[5]   "Person found" SKIP
    "Kount[6]  = "   kount[6]   "TK_patient_ID is wrong - correcting" SKIP
    "Kount[7]  = "   kount[7]   "Not matched precisely" SKIP
    "Kount[8]  = "   kount[8]   "Single match on Sample ID and EY Number" SKIP
    "Kount[9]  = "   kount[9]   "Multi-match on Sample ID and EY Number" SKIP
    "Kount[10] = "  kount[10]   "Non-matched --- trying a BEGINS string" SKIP

    "Kount[21] = "  kount[21]   "" SKIP
    "Kount[22] = "  kount[22]   "Re-found a single record by BEGINS" SKIP
    "Kount[23] = "  kount[23]   "Re-found multiples by BEGINS" SKIP
    "Kount[24] = "  kount[24]   "Still no records found by BEGINS" SKIP
    "Kount[25] = "  kount[25]   "Found a single TK_mstr" SKIP
    "Kount[26] = "  kount[26]   "TK_mstr not found - create" SKIP
    "Kount[27] = "  kount[27]   "TKR_det found but wrong result" SKIP
    "Kount[28] = "  kount[28]   "TKR_det found and OK" SKIP
    "Kount[29] = "  kount[29]   "No TKR_det found - create one" SKIP
    "Kount[30] = "  kount[30]   "Too many TK_mstr records" SKIP  
            
        WITH FRAME o2 NO-LABELS WIDTH 232.


DISPLAY STREAM outward 

    "Kount[1]  = "   kount[1]   "Total overall record count from the lab full MPA listing file" SKIP 
    "Kount[2]  = "   kount[2]   "Total of successful direct finds based on the information from QuickBooks" SKIP 
    "Kount[3]  = "   kount[3]   "FN, LN, DOB violation" SKIP 
    "Kount[4]  = "   kount[4]   "Person not found - creating one" SKIP
    "Kount[5]  = "   kount[5]   "Person found" SKIP
    "Kount[6]  = "   kount[6]   "TK_patient_ID is wrong - correcting" SKIP
    "Kount[7]  = "   kount[7]   "Not matched precisely" SKIP
    "Kount[8]  = "   kount[8]   "Single match on Sample ID and EY Number" SKIP
    "Kount[9]  = "   kount[9]   "Multi-match on Sample ID and EY Number" SKIP
    "Kount[10] = "  kount[10]   "Non-matched --- trying a BEGINS string" SKIP

    "Kount[21] = "  kount[21]   "" SKIP
    "Kount[22] = "  kount[22]   "Re-found a single record by BEGINS" SKIP
    "Kount[23] = "  kount[23]   "Re-found multiples by BEGINS" SKIP
    "Kount[24] = "  kount[24]   "Still no records found by BEGINS" SKIP
    "Kount[25] = "  kount[25]   "Found a single TK_mstr" SKIP
    "Kount[26] = "  kount[26]   "TK_mstr not found - create" SKIP
    "Kount[27] = "  kount[27]   "TKR_det found but wrong result" SKIP
    "Kount[28] = "  kount[28]   "TKR_det found and OK" SKIP
    "Kount[29] = "  kount[29]   "No TKR_det found - create one" SKIP
    "Kount[30] = "  kount[30]   "Too many TK_mstr records" SKIP  
            
        WITH FRAME ow NO-LABELS WIDTH 232.
    
OUTPUT STREAM badpat CLOSE.    
OUTPUT STREAM detdiff CLOSE.
OUTPUT STREAM goodstuff CLOSE.
OUTPUT STREAM out2 CLOSE.
OUTPUT STREAM outward CLOSE.

endtime = NOW.

DISPLAY x y z
   WITH FRAME end1.

DISPLAY starttime endtime ((endtime - starttime) / 1000)
    WITH FRAME end2.
