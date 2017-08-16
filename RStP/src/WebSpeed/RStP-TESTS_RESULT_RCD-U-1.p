/*------------------------------------------------------------------------
    File        : RStP_TESTS_RESULT_RCD-U.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Sara Luttrell
    Created     : Tue Dec 30 15:24:45 MST 2014
    Notes       :
        
  Version 1.2 - by DOUG LUTTRELL written on 02/Jan/15.  Includes all the changes
                    that came out as a result of the TESTS_RESULT_RCD version of this
                    program to support the lack of TK_test_seq data in the old system.
                    Not so many changes to this code since there was already a field,
                    but some of the related changes (specifically around not allowing
                    the TK_status to go "backwards" during an Update. 
                         
  1.3 - written by DOUG LUTTRELL on 25/May/15.  Found a major bug in the code from 1.2.
            The change to support multiple sequences wasn't smart enough and it just 
            makes them all the time.  Marked by 1dot3.  
            
  1.4 - By Harold Luttrell on 15/Jul/15.
        a.  Added more output data displays for the error log report.  
        b.  Change the output log file name to: 
                RStP-TESTS_RESULT_RCD-U-log-1.txt.
        c.  Added the THIS-PROCEDURE:FILE-NAME assign to xxxx_prog_name.
        d.  Added the count for each ERROR! message. 
        e.  Changed the access method on the FIND statement for the TK_mstr. 
        f.  Added the emailaddr-USERID.i for e-mail's on solsource's employees
            testing pc's.
            Marked by 1dot4.  
            
   1.5 - By Harold Luttrell on 14/Sept/15.
   Description:    Changed code to use the RUN VALUE(SEARCH) code 
                        instead of using the long path name.
    Identified by:  /* 1dot5 */ 
   
   1.6 - By Harold Luttrell on 23 & 24 & 27/Sept/15.
   Description:    Added code to plug the tk-status to "PROCESSED" if
                    the input date_processed field is blank (?).
                   Added code to create transaction histories if the
                    Tests_Result_RCD.Progress_Flag = "" OR                        
                    Tests_Result_RCD.Progress_Flag = "A" OR 
                    (firstrun = YES AND Tests_Result_RCD.Progress_Flag = "U").
                   and 
                   modified code to use the new history logic that Doug
                   developed.
                   All this new code was setup in 
                        RStP-TESTS=trh-TK-Status-Date-U.i file.  
    Identified by:  /* 1dot6 */             
    
    1.7 - written by DOUG LUTTRELL on 08/Oct/15.  Changed to make the A's work 
            like the U's but in reverse.  Marked by 1dot7.
    
    1.8 - modified by Harold Luttrell, Sr. on 13/Nov/15.
            Removed the code that adds 1 to the v-seqNbr variable.
            If the FIRST TK_mstr was found for a Test_kit_Id then move its
            TK_test_seq to the v-seqNbr variable.
            If not found then find the LAST TK_mstr and if it was found 
            then move its TK_test_seq to the v-seqNbr variable.
            Updated the 'statlist' table to match the one in the RStP-MPA_RCD
            program.
          Identified by /* 1dot8 */  
     1.8.1  - change run .p to run .r
     
     1.9  - Modified  by Harold Luttrell on 1/15/2016.
            Changed the RUN .p to .r. 
            Added "ASSIGN tk__date01 = TODAY" to show the date an update was
                made to the TK_mstr by this program.
            Changed the FIND statement for the TK_mstr.  
            Identified by /* 1dot9 */      
            
     2.0 - written by DOUG LUTTRELL on 16/May/16.  Went back and made the 
            FIND FIRST that was changed to a different FIND in version 1.9
            a conditional thing.  The original one was required to get the
            old school bundles to be match correctly.  The newer one works 
            correctly with the newer data.  The freakin' HHI data is the WORST.
            Also changed the old FIND FIRST to support the new fields that
            were changed in release 11.1.  Marked by 2dot0.
            
    2.1 - written by DOUG LUTTRELL on 25/May/16.  Something still awry on 
            certain conditions in the finding.  I believe that this code is 
            allowing testkits to overwrite each other when the test types 
            don't match.  I'm adding the TK_test_type field into the newer
            find to help prevent that.  This shouldn't have been an issue
            because of the uniqueness of the tk_ID field, but something isn't
            right somewhere.  Found someething wonky.  There was no condition 
            for what to do if it successfully found a record that it should have.
            Added that in for the tk_test_seq as well.  Marked by 2dot1. 
            
    2.11 - written by DOUG LUTTRELL on 30/May/16.  I was apparently smoking
            some form of dope.  Modifying the FINDs to make sure they are
            working on the proper testkit type.  Also included stuff to 
            respect the deleted flags.  Marked by 211.
            
    2.2  - written by DOUG LUTTRELL on 01/Jun/16.  Totally revamping the way we
            handle old testkit IDs and testkit Sequences.  Old ones will now be a 
            concatenantion of the old testkit ID, the test type, and the letters
            "OAH" which stands for Old As Heck.  This also changes the way this 
            program does FINDs.  All the finding and creating is done up front
            and then the updating is done down below.  Commented out large swaths
            of code which often did not get marked.  The rest was marked by 2dot2.
                        
  ----------------------------------------------------------------------*/ 

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

/** specific to this program **/   
DEFINE VARIABLE v-testID        LIKE Tests_Result_RCD.Test_Kit_Nbr   NO-UNDO.
DEFINE VARIABLE v-create        AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE v-update        AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE v-avail         AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE v-successful    AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE X               AS INTEGER                      NO-UNDO.
DEFINE VARIABLE v-error         AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE testkit         AS INTEGER                      NO-UNDO.
/*                                                                             */

DEFINE VARIABLE v-tkid LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE VARIABLE v-tkseq LIKE TK_mstr.TK_test_seq NO-UNDO.

DEFINE VARIABLE v-tkstat        LIKE TK_mstr.TK_status          NO-UNDO.
DEFINE VARIABLE v-trhid         LIKE trh_hist.trh_id            NO-UNDO.
DEFINE VARIABLE v-trhfound      AS LOGICAL                      NO-UNDO. 
DEFINE VARIABLE v-seqNbr        AS INTEGER                      NO-UNDO. 

DEFINE VARIABLE statlist AS CHARACTER 
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,BURNED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO.      /* 1dot8 */
    
DEFINE VARIABLE v-create-date   LIKE TK_mstr.TK_create_date     NO-UNDO.
DEFINE VARIABLE v-mod-date      LIKE TK_mstr.tk_modified_date   NO-UNDO.
DEFINE VARIABLE lazydate        AS DATE                         NO-UNDO.        /* because laziness is a virtue in a programmer */    

DEFINE VARIABLE v-trh-comments  LIKE trh_hist.trh_comments  NO-UNDO.            /* 2dot0 */
DEFINE VARIABLE v-trh-other     LIKE trh_hist.trh_other_ID  NO-UNDO.            /* 2dot0 */
DEFINE VARIABLE v-trh-people    LIKE trh_hist.trh_people_ID NO-UNDO.            /* 2dot0 */    
DEFINE VARIABLE v-trh-order     LIKE trh_hist.trh_order     NO-UNDO.            /* 2dot0 */
DEFINE VARIABLE v-trh-date      LIKE trh_hist.trh_date      NO-UNDO.            /* 2dot0 */
DEFINE VARIABLE v-trh-time      LIKE trh_hist.trh_time      NO-UNDO.            /* 2dot0 */
DEFINE VARIABLE v-trh-ref       LIKE trh_hist.trh_ref       NO-UNDO.            /* 2dot0 */

/** useful for all RSTP code **/
DEFINE VARIABLE limitrun AS INTEGER INITIAL 0 NO-UNDO.                          /** a non-zero number will limit processing to that many records **/
DEFINE VARIABLE firstrun AS LOGICAL INITIAL NO   NO-UNDO.       /* change to YES for number 2 program. */

DEFINE VARIABLE loadedlist      AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO.
    
DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 11 NO-UNDO.                        /* 1dot4 */                        /* 2dot2 */

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.       /* 1dot4 */
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.       /* 1dot4 */
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
 
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RStP-TESTS_RESULT_RCD-U-log-1.txt" NO-UNDO.        /* 1dot4 */ /* change to 2 for number 2 program */
 
OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "PatientID"
    "Lab SampleID"
    "Lab SeqNbr"
    "TK_ID"
    "New TK SeqNbr"
    "Progress_Flag"                                                             /* 1dot4 */
    "Error Message".

/* ********************  Preprocessor Definitions  ******************** */

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(1)" NO-UNDO. 

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

{emailaddr-USERID.i}.

/* ***************************  Main Block  *************************** */
main-block: 
FOR EACH Tests_Result_RCD WHERE LOOKUP(Tests_Result_RCD.Progress_Flag,loadedlist) = 0:

    recordsprocessed = recordsprocessed + 1. 
    
    IF (limitrun > 0) AND (recordsprocessed > limitrun) THEN 
        LEAVE main-block.
        
    /********************************************* Begin 2dot2 ********************************************************/
    ASSIGN 
        v-tkid  = ""
        v-tkseq = 1.
        
    IF TESTS_RESULT_RCD.Test_Kit_Nbr = "" THEN DO: 
        
        EXPORT STREAM outward DELIMITER ";"
            TESTS_RESULT_RCD.PatientID
            TESTS_RESULT_RCD.Lab_Sampleid
            TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr
            TESTS_RESULT_RCD.Test_Kit_Nbr
            0
            TESTS_RESULT_RCD.Progress_Flag
            "ERROR 10! Blank Test_Kit_Nbr in  NEXT.".
            
        ASSIGN ERROR-count[10] = ERROR-count[10]  + 1.   
    
        NEXT main-block.
        
    END.  /** of if testkitnbr = "" **/
    
    ELSE DO: 
        
        IF TESTS_RESULT_RCD.Test_Kit_Nbr < "A" OR 
            TESTS_RESULT_RCD.Test_Kit_Nbr BEGINS "CPR" OR 
            TESTS_RESULT_RCD.Test_Kit_Nbr BEGINS "NN" THEN DO: 
                
            ASSIGN 
                v-tkid  = TESTS_RESULT_RCD.Test_Kit_Nbr + "-" + TESTS_RESULT_RCD.Test_Abbv + "-" + "OAH"
                v-tkseq = TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr. 
        
        END.  /** of old style testkit **/ 
        
        ELSE DO: 
            
            ASSIGN 
                v-tkid  = TESTS_RESULT_RCD.Test_Kit_Nbr 
                v-tkseq = TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr.
            
        END.  /** of else do --- current style testkit **/
        
    END.  /** of else do --- testkitnbr <> "" **/
    
    FIND TK_mstr WHERE TK_mstr.TK_ID = v-tkid AND 
        TK_mstr.TK_test_seq = v-tkseq AND 
        TK_mstr.TK_test_type = TESTS_RESULT_RCD.Test_Abbv AND 
        TK_mstr.TK_deleted = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
    IF NOT AVAILABLE (tk_mstr) THEN DO: 
        
        FIND TK_mstr WHERE TK_mstr.TK_ID = v-tkid AND 
            TK_mstr.TK_test_seq = v-tkseq AND 
            TK_mstr.TK_test_type = TESTS_RESULT_RCD.Test_Abbv 
                EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE (tk_mstr) THEN DO:     /** undelete this testkit **/
            
            ASSIGN 
                TK_mstr.TK_deleted          = ?
                TK_mstr.TK_modified_by      = USERID("HHI")
                TK_mstr.TK_modified_date    = TODAY 
                TK_mstr.TK_prog_name        = THIS-PROCEDURE:FILE-NAME.
                
            /*** how to handle other (non-testkit) fields? ***/
            
        END.  /** of if avail tk_mstr **/
            
        ELSE DO:        /*** go ahead and create a TK ***/
            
            ASSIGN 
                v-testID        = ""
                v-create        = ?
                v-update        = ?
                v-avail         = ?
                v-successful    = ?.                
                
            RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r"))                             /* 1dot9 */
                (v-tkid,
                 Tests_Result_RCD.test_Abbv,
                 ?,                                                             /* professional? */
                 v-tkseq,
                 ?,                                                             /* domestic */
                 0,                                                             /* Customer ID */
                 Tests_Result_RCD.PatientID,
                 Tests_Result_RCD.Lab_Sampleid,
                 Tests_Result_RCD.Lab_Sampleid_SeqNbr,
                 Tests_Result_RCD.test_patAGE,                                  /* age at time of test */
                 Tests_Result_RCD.Test_LAB_Name,
                 "",                                                            /** TK_status **/
                 Tests_Result_RCD.Comments,
                 Tests_Result_RCD.Special_Note,
                 ?,                                                             /* tk_cust_paid */          /* 2dot0 */
                 TESTS_RESULT_RCD.Tests_Result_date_processed,                  /* lbl_print */             /* 2dot0 */
                 ?,                                                             /* lab_paid date */         /* 2dot0 */
                 "",                                                            /* MAGENTO_order */         /* 2dot0 */ 
                 ?,                                                             /* cust_paid_date */        /* 2dot0 */ 
                 OUTPUT v-testID,   
                 OUTPUT v-create,
                 OUTPUT v-update,
                 OUTPUT v-avail,  
                 OUTPUT v-successful). 
                     
            IF v-successful = NO OR v-successful = ? THEN DO:                                       /* 1dot4 */
            
                EXPORT STREAM outward DELIMITER ";"
                    Tests_Result_RCD.PatientID 
                    TESTS_RESULT_RCD.Lab_Sampleid
                    Tests_Result_RCD.Lab_Sampleid_SeqNbr
                    Tests_Result_RCD.Test_Kit_Nbr
                    v-seqNbr
                    Tests_Result_RCD.Progress_Flag                              /* 1dot4 */ 
                   "ERROR 3! Add new TK_mstr failed.".
                   
                ASSIGN ERROR-count[3] = ERROR-count[3]  + 1.                    /* 1dot4 */
                
            END.  /* IF v-successful = no */                                    /* 1dot4 */  
            
            ELSE DO: 
                
                FIND TK_mstr WHERE TK_mstr.TK_ID = v-tkid AND 
                    TK_mstr.TK_test_seq = v-tkseq AND 
                    TK_mstr.TK_test_type = TESTS_RESULT_RCD.Test_Abbv AND 
                    TK_mstr.TK_deleted = ?
                        EXCLUSIVE-LOCK NO-ERROR.
                        
                IF NOT AVAILABLE (TK_mstr) THEN DO: 
                    
                    EXPORT STREAM outward DELIMITER ";"
                        Tests_Result_RCD.PatientID 
                        TESTS_RESULT_RCD.Lab_Sampleid
                        Tests_Result_RCD.Lab_Sampleid_SeqNbr
                        v-tkid
                        v-tkseq
                        Tests_Result_RCD.Progress_Flag                              /* 1dot4 */ 
                       "ERROR 11! Add new TK_mstr really failed.".
                       
                    ASSIGN ERROR-count[11] = ERROR-count[11]  + 1.                    /* 1dot4 */
                    
                    NEXT main-block. 
                    
                END.  /* IF v-successful = no */                                    /* 1dot4 */       
                
            END.  /** of else do --- v-successful = YES **/
            
        END.  /** of else do --- not avail tk-mstr **/
    
    END.  /** of if not avail tk_mstr **/
        
    ELSE DO:        /* matched, update time */
        
        /* in here is where the update stuff should be? */
    
    END.  /** of else do --- if avail tk-mstr **/
    
/*****************************************************************************************
 *  Begin ADD section
 *****************************************************************************************/
                 
    IF ((Tests_Result_RCD.Progress_Flag = "" OR                                                             /* 1dot7 */  
        Tests_Result_RCD.Progress_Flag = "A") AND                                                           /* 1dot7 */
        firstrun = NO) OR                                                                                   /* 1dot7 */
        (firstrun = YES AND Tests_Result_RCD.Progress_Flag = "U")               /* this line is for the initial load only */        
    THEN DO:      
            
        FIND Lab_mstr WHERE Lab_mstr.Lab_ID = TESTS_RESULT_RCD.Test_LAB_Name AND 
            lab_mstr.lab_deleted = ?                                                                    /* 211 */
                NO-LOCK NO-ERROR.  
                         
        IF NOT AVAILABLE (lab_mstr) THEN DO:  
           
            EXPORT STREAM outward DELIMITER ";"
                Tests_Result_RCD.PatientID 
                TESTS_RESULT_RCD.Lab_Sampleid
                Tests_Result_RCD.Lab_Sampleid_SeqNbr
                v-tkid                                                                                  /* 2dot2 */
                v-tkseq                                                                                 /* 2dot2 */
                Tests_Result_RCD.Progress_Flag                              /* 1dot4 */ 
               "ERROR 2! Unknown Lab.  Please use the Lab Maintenance screen to add the Lab.".
               
            ASSIGN ERROR-count[2] = ERROR-count[2]  + 1.                    /* 1dot4 */ 
            
        END.  /** NOT AVAILABLE (lab_mstr) **/
    
                                                IF it-message = YES THEN 
                                                    DISPLAY "before run" 
                                                        v-tkid SKIP 
                                                        v-tkseq SKIP 
                                                        Tests_Result_RCD.test_kit_nbr FORMAT "x(12)" SKIP  
                                                        Tests_Result_RCD.Lab_SampleID_seqNbr.

        RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r"))                             /* 1dot9 */
            (v-tkid,                                                                                    /* 2dot2 */
             Tests_Result_RCD.test_Abbv,
             ?,
             v-tkseq,                                                                                   /* 2dot2 */
             ?,
             0,                                                             /* Customer ID */
             Tests_Result_RCD.PatientID,
             Tests_Result_RCD.Lab_Sampleid,
             Tests_Result_RCD.Lab_Sampleid_SeqNbr,
             Tests_Result_RCD.test_patAGE,                                  /* age at time of test */
             Tests_Result_RCD.Test_LAB_Name,
             "",                                                            /** TK_status **/
             Tests_Result_RCD.Comments,
             Tests_Result_RCD.Special_Note,
             ?,                                 /* tk_cust_paid */          /* 2dot0 */
             Tests_Result_date_processed,       /* lbl_print */             /* 2dot0 */
             ?,                                 /* lab_paid date */         /* 2dot0 */
             "",                                /* MAGENTO_order */         /* 2dot0 */ 
             ?,                                 /* cust_paid_date */        /* 2dot0 */ 
             OUTPUT v-testID,   
             OUTPUT v-create,
             OUTPUT v-update,
             OUTPUT v-avail,  
             OUTPUT v-successful). 
                 
        IF it-message = YES THEN 
            DISPLAY "v-successful = " v-successful SKIP 
                    "v-testID = " v-testID SKIP. 
                 
        IF v-successful = NO THEN DO:                                       /* 1ddot4 */
        
            EXPORT STREAM outward DELIMITER ";"
                Tests_Result_RCD.PatientID 
                TESTS_RESULT_RCD.Lab_Sampleid
                Tests_Result_RCD.Lab_Sampleid_SeqNbr
                v-tkid                                                                                  /* 2dot2 */
                v-tkseq                                                                                 /* 2dot2 */
                Tests_Result_RCD.Progress_Flag                              /* 1dot4 */ 
               "ERROR 3! Add new TK_mstr failed.".
               
            ASSIGN ERROR-count[3] = ERROR-count[3]  + 1.                    /* 1dot4 */
            
        END.  /* IF v-successful = no */                                    /* 1dot4 */    
        
        ELSE DO:
                             
            FIND TK_mstr WHERE TK_mstr.TK_ID = v-testID AND                                                 /* 2dot2 */
                TK_mstr.TK_test_seq = v-seqNbr AND                                                          /* 2dot2 */
                TK_mstr.TK_test_type = TESTS_RESULT_RCD.Test_Abbv AND                                   /* 2dot1 */
                TK_mstr.TK_deleted = ?                                                                          /* 211 */
                    EXCLUSIVE-LOCK NO-ERROR. 
                
            IF NOT AVAILABLE (TK_mstr) THEN DO: 
            
                EXPORT STREAM outward DELIMITER ";"
                    Tests_Result_RCD.PatientID 
                    TESTS_RESULT_RCD.Lab_Sampleid
                    Tests_Result_RCD.Lab_Sampleid_SeqNbr
                    v-tkid                                                                                  /* 2dot2 */
                    v-tkseq                                                                                 /* 2dot2 */
                    Tests_Result_RCD.Progress_Flag                          /* 1dot4 */ 
                    "ERROR 4!  Unable to find TK_mstr record that was created.".
                    
                ASSIGN ERROR-count[4] = ERROR-count[4]  + 1.                /* 1dot4 */
                
            END.  /*** OF ELSE DO --- ERROR TYPE ***/
            
            
            ELSE DO:                      /** make all the history records and figure out the TK_status **/
                
                ASSIGN                                                      /* reset variables to blank before use */
                    v-create-date   = ?
                    v-mod-date      = ?                    
                    v-TKstat        = ""
                    v-trh-comments  = ""                                    /* 2dot0 */
                    v-trh-other     = ""                                    /* 2dot0 */
                    v-trh-people    = 0                                     /* 2dot0 */    
                    v-trh-order     = ""                                    /* 2dot0 */
                    v-trh-date      = ?                                     /* 2dot0 */
                    v-trh-time      = ""                                    /* 2dot0 */
                    v-trh-ref       = "".                                   /* 2dot0 */
                      
                                        
                ASSIGN                                                              /* 2dot0 */                               
                    v-trh-ref   = (TESTS_RESULT_RCD.Lab_Sampleid +                  /* 2dot0 */
                                   " / " +                                          /* 2dot0 */
                                   STRING(DECIMAL(TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr)) ). /* 2dot0 */
                                   
                ASSIGN                                                      /* 2dot0 */
                    v-trh-people    = IF TK_mstr.TK_patient_ID = 0 THEN     /* 2dot0 */
                                         TK_mstr.TK_cust_ID        ELSE     /* 2dot0 */
                                         TK_mstr.TK_patient_ID.             /* 2dot0 */
                
                ASSIGN 
                    v-trh-comments  = IF TK_mstr.TK_comments <> "" THEN     /* 2dot0 */
                                         TK_mstr.TK_comments       ELSE     /* 2dot0 */
                                         TK_mstr.tk_notes.                  /* 2dot0 */
                                         
                
                
                IF Tests_Result_RCD.DateCollected <> ? THEN DO:                    
                
                    ASSIGN 
                        lazydate        = TESTS_RESULT_RCD.DateCollected    /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                        v-tkstat        = "COLLECTED"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                   
                    {RStP-TESTS-trh-TK-Status-Date-U.i}.                                            /* 1dot9 */
                            
                END. /* run --- COLLECTED  --   Tests_Result_RCD.DateCollected <> ? */              
                                                         
                IF Tests_Result_RCD.DateReceived <> ? THEN DO:                    
                
                    ASSIGN 
                        lazydate        = Tests_Result_RCD.DateReceived     /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                   
                        v-tkstat        = "LAB_RCVD"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                                       
                    {RStP-TESTS-trh-TK-Status-Date-U.i}.                                             /* 1dot6 */    
                            
                END. /* run --- LAB_RCVD -- Tests_Result_RCD.DateReceived <> ? */
                        
                IF Tests_Result_RCD.DateCompleted <> ? THEN DO:                    
         
                    ASSIGN 
                        lazydate        = Tests_Result_RCD.DateCompleted    /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                        v-tkstat        = "LAB_PROCESS"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                   
                    {RStP-TESTS-trh-TK-Status-Date-U.i}.                                             /* 1dot6 */ 
   
                END. /* run --- LAB_PROCESS  -- Tests_Result_RCD.DateCompleted <> ? */

/*** Insert some code here to grab the create date of the import file on disk for the PROCESSED date ***/  
/*** If successul in making a section for the PROCESSED date then need to adjust the sections below  ***/
/*** where that date is being created in the system based on LOADED and PROCESSED sections.         ***/   

/* 1dot6 */
                IF  TESTS_RESULT_RCD.Tests_Result_date_processed = ? AND                         
                    v-TKstat = "LAB_PROCESS" THEN                                       
                        ASSIGN TESTS_RESULT_RCD.Tests_Result_date_processed = TODAY.    
/* 1dot6 */                      
                IF TESTS_RESULT_RCD.Tests_Result_date_processed <> ? THEN DO: 
                                                             
                    ASSIGN 
                        lazydate        = TESTS_RESULT_RCD.Tests_Result_date_processed              /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate      
                        v-TKstat        = "PROCESSED"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                   
                    {RStP-TESTS-trh-TK-Status-Date-U.i}.                                             /* 1dot6 */  
                                
                END. /* Tests_Result_date_processed <> ? then do --- PROCESSED */            
                            
                /***********  END OF MOVED DATE STUFF ***********/
                
                /** put in a catch to make sure that we don't move a status backwards during an Update **/
                IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN 
                    v-TKstat = v-TKstat.
                ELSE 
                    v-TKstat = TK_mstr.TK_status. 
                               
                RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r"))                     /* 1dot9 */     
                    (v-tkid,                                                                                /* 2dot2 */
                     Tests_Result_RCD.test_Abbv,
                     ?,
                     v-tkseq,                                                                               /* 2dot2 */
                     ?,
                     0,                                                             /* Customer ID */
                     Tests_Result_RCD.PatientID,
                     Tests_Result_RCD.lab_sampleid,
                     Tests_Result_RCD.Lab_SampleID_SeqNbr,
                     Tests_Result_RCD.Test_PatAGE,                                       /* age at time of test */
                     Tests_Result_RCD.Test_LAB_Name,                                                         
                     v-TKstat,                                                            /* TK_status */
                     Tests_Result_RCD.Comments,
                     Tests_Result_RCD.Special_Note,
                     ?,                                 /* tk_cust_paid */          /* 2dot0 */
                     Tests_Result_date_processed,       /* lbl_print */             /* 2dot0 */
                     ?,                                 /* lab_paid date */         /* 2dot0 */
                     "",                                /* MAGENTO_order */         /* 2dot0 */ 
                     ?,                                 /* cust_paid_date */        /* 2dot0 */ 
                     OUTPUT v-testID,   
                     OUTPUT v-create,
                     OUTPUT v-update,
                     OUTPUT v-avail,  
                     OUTPUT v-successful). 
                         
                                            IF it-message = YES THEN 
                                                DISPLAY "v-successful update = " v-successful SKIP
                                                        "v-testID update = " v-testID SKIP.   
     
                IF v-successful = NO THEN DO:                                   
                    EXPORT STREAM outward DELIMITER ";"
                        Tests_Result_RCD.PatientID 
                        TESTS_RESULT_RCD.Lab_Sampleid
                        Tests_Result_RCD.Lab_Sampleid_SeqNbr
                        v-tkid                                                                          /* 2dot2 */
                        v-tkseq                                                                         /* 2dot2 */
                        Tests_Result_RCD.Progress_Flag                            
                       "ERROR 7! Update of TK_mstr record failed.".
                    ASSIGN ERROR-count[7] = ERROR-count[7]  + 1.                  
                END.  /*  IF v-successful = NO  */                              
                
                ELSE    /** v-successful = yes **/    
                           
                    ASSIGN
                        tk__date01                  = TODAY                     /* 1dot9 */
                        v-create-date               = IF v-create-date = ? THEN TODAY ELSE v-create-date
                        v-mod-date                  = IF v-mod-date = ? THEN TODAY ELSE v-mod-date
                        TK_mstr.TK_create_date      = IF TK_mstr.TK_create_date <= v-create-date THEN TK_mstr.TK_create_date ELSE v-create-date
                        TK_mstr.TK_modified_date    = IF TK_mstr.TK_modified_date >= v-mod-date THEN TK_mstr.TK_modified_date ELSE v-mod-date                    
                        TK_mstr.TK_status           = v-tkstat  
                        TK_mstr.TK__char01          = "BioMed"
                        TK_mstr.TK_prog_name        = THIS-PROCEDURE:FILE-NAME                              /* 1dot4 */
                        Tests_Result_RCD.Progress_Flag = IF Tests_Result_RCD.Progress_Flag = "A" THEN  
                                                            "AL"      /** stands for Add Loaded **/
                                                      ELSE IF Tests_Result_RCD.Progress_Flag = "U" THEN
                                                            "UL"                                                            
                                                      ELSE 
                                                            "IL".     /** stands for Import Loaded **/
                                      
                                      
            END.  /*** of else do --- avail tk_mstr ***/
        
        END. /* ELSE DO --- v-successful = yes */
                
    END.  /*** THEN DO: of progress_flag = blank or A --- create a record ***/                


/************************************************************************************
 *  Begin DELETE section
 ************************************************************************************/

    ELSE IF Tests_Result_RCD.Progress_Flag = "D" THEN DO:                                 
            
            ASSIGN
                TK_mstr.TK_deleted              = TODAY 
                TK_mstr.TK_modified_by          = USERID("HHI")
                TK_mstr.TK_modified_date        = TODAY
                TK_mstr.TK_prog_name            = THIS-PROCEDURE:FILE-NAME             /* 1dot4 */ 
                Tests_Result_RCD.Progress_Flag  = "DL".     /** update the database --- stands for Delete Loaded **/

    END.  /**** ELSE IF Tests_Result_RCD.Progress_Flag = "D"  ****/
            
/*************************************************************************************
 *  Begin UPDATE section 
 *************************************************************************************/        
            
    ELSE IF (                                                                                                           /* 1dot7 */
             (Tests_Result_RCD.Progress_Flag = "U" AND firstrun = NO) OR                                                /* 1dot7 */
             ((TESTS_RESULT_RCD.Progress_Flag = "A" OR TESTS_RESULT_RCD.Progress_Flag = "") AND                         /* 1dot7 */
              firstrun = YES)                                                                                           /* 1dot7 */
            ) THEN DO:                                                                                                  /* 1dot7 */

        
        /*********** PUT DATE STUFF HERE ****************/
        
        ASSIGN                                                              /* reset variable to blank before use */
            v-create-date   = ?
            v-mod-date      = ?
            v-TKstat        = ""  
            v-trh-comments  = ""                                    /* 2dot0 */
            v-trh-other     = ""                                    /* 2dot0 */
            v-trh-people    = 0                                     /* 2dot0 */    
            v-trh-order     = ""                                    /* 2dot0 */
            v-trh-date      = ?                                     /* 2dot0 */
            v-trh-time      = ""                                    /* 2dot0 */
            v-trh-ref       = "".                                   /* 2dot0 */
              
                                
        ASSIGN                                                              /* 2dot0 */                               
            v-trh-ref   = (TESTS_RESULT_RCD.Lab_Sampleid +                  /* 2dot0 */
                           " / " +                                          /* 2dot0 */
                           STRING(DECIMAL(TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr)) ). /* 2dot0 */
                           
        ASSIGN                                                      /* 2dot0 */
            v-trh-people    = IF TK_mstr.TK_patient_ID = 0 THEN     /* 2dot0 */
                                 TK_mstr.TK_cust_ID        ELSE     /* 2dot0 */
                                 TK_mstr.TK_patient_ID.             /* 2dot0 */
        
        ASSIGN 
            v-trh-comments  = IF TK_mstr.TK_comments <> "" THEN     /* 2dot0 */
                                 TK_mstr.TK_comments       ELSE     /* 2dot0 */
                                 TK_mstr.tk_notes.                  /* 2dot0 */
              
        IF Tests_Result_RCD.DateCollected <> ? THEN DO:  
                              
            ASSIGN 
                lazydate        = Tests_Result_RCD.DateCollected            /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate   
                v-TKstat        = "COLLECTED"
                v-trh-date      = lazydate.                         /* 2dot0 */
                                   
            {RStP-TESTS-trh-TK-Status-Date-U.i}.                                             /* 1dot6 */
                                           
        END.  /** Tests_Result_RCD.DateCollected <> ? **/
                                      
        IF Tests_Result_RCD.DateReceived <> ? THEN DO:   
            
            ASSIGN 
                lazydate        = Tests_Result_RCD.DateReceived             /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate  
                v-TKstat        = "LAB_RCVD"
                v-trh-date      = lazydate.                         /* 2dot0 */
                                       
                   
            {RStP-TESTS-trh-TK-Status-Date-U.i}.                                             /* 1dot6 */
                        
        END. /* if DateReceived <> ? then do --- LAB_RCVD */
            
        IF Tests_Result_RCD.DateCompleted <> ? THEN DO: 
                                                      
            ASSIGN 
                lazydate        = Tests_Result_RCD.DateCompleted            /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate  
                v-TKstat        = "LAB_PROCESS"
                v-trh-date      = lazydate.                         /* 2dot0 */
                   
                   
            {RStP-TESTS-trh-TK-Status-Date-U.i}.                                             /* 1dot6 */
                                          
        END. /* if DateCompleted <> ? then do --- LAB_PROCESS */

        IF  TESTS_RESULT_RCD.Tests_Result_date_processed = ? AND                /* 1dot6 */           
            v-TKstat = "LAB_PROCESS" THEN                                       /* 1dot6 */
                ASSIGN TESTS_RESULT_RCD.Tests_Result_date_processed = TODAY.    /* 1dot6 */
                
        IF TESTS_RESULT_RCD.Tests_Result_date_processed <> ? THEN DO: 
                                                     
            ASSIGN 
                lazydate        = TESTS_RESULT_RCD.Tests_Result_date_processed              /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate      
                v-TKstat        = "PROCESSED"
                v-trh-date      = lazydate.                         /* 2dot0 */
               
                   
            {RStP-TESTS-trh-TK-Status-Date-U.i}.                                             /* 1dot6 */
                      
        END. /* Tests_Result_date_processed <> ? then do --- PROCESSED */            
                    
        /***********  END OF MOVED DATE STUFF ***********/
        
        /** put in a catch to make sure that we don't move a status backwards during an Update **/
        IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN 
            v-TKstat = v-TKstat.
        ELSE 
            v-TKstat = TK_mstr.TK_status. 
                       
        RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r"))                             /* 1dot9 */
            (v-tkid,                                                                                    /* 2dot2 */
             Tests_Result_RCD.test_Abbv,
             ?,
             v-tkseq,                                                                                   /* 2dot2 */
             ?,
             0,                                                             /* Customer ID */
             Tests_Result_RCD.PatientID,
             Tests_Result_RCD.lab_sampleid,
             Tests_Result_RCD.Lab_SampleID_SeqNbr,
             Tests_Result_RCD.Test_PatAGE,                                       /* age at time of test */
             Tests_Result_RCD.Test_LAB_Name,                                                         
             v-TKstat,                                                            /* TK_status */
             Tests_Result_RCD.Comments,
             Tests_Result_RCD.Special_Note,
             ?,                                 /* tk_cust_paid */          /* 2dot0 */
             Tests_Result_date_processed,       /* lbl_print */             /* 2dot0 */
             ?,                                 /* lab_paid date */         /* 2dot0 */
             "",                                /* MAGENTO_order */         /* 2dot0 */ 
             ?,                                 /* cust_paid_date */        /* 2dot0 */ 
             OUTPUT v-testID,   
             OUTPUT v-create,
             OUTPUT v-update,
             OUTPUT v-avail,  
             OUTPUT v-successful). 
                 
        IF it-message = YES THEN 
            DISPLAY "v-successful update = " v-successful SKIP
                    "v-testID update = " v-testID SKIP.   
 
            IF v-successful = NO THEN DO:                                       /* 1dot4 */
            EXPORT STREAM outward DELIMITER ";"
                Tests_Result_RCD.PatientID 
                TESTS_RESULT_RCD.Lab_Sampleid
                Tests_Result_RCD.Lab_Sampleid_SeqNbr
                v-tkid                                                                                      /* 2dot2 */
                v-tkseq                                                                                     /* 2dot2 */
                Tests_Result_RCD.Progress_Flag                              /* 1dot4 */ 
               "ERROR 7! Update of TK_mstr record failed.".
            ASSIGN ERROR-count[7] = ERROR-count[7]  + 1.                    /* 1dot4 */
        END.  /*  IF v-successful = NO  */                                  /* 1dot4 */
        ELSE    /** v-successful = yes **/                    
                 
            ASSIGN  
                tk__date01                  = TODAY                         /* 1dot9 */              
                v-create-date               = IF v-create-date = ? THEN TODAY ELSE v-create-date
                v-mod-date                  = IF v-mod-date = ? THEN TODAY ELSE v-mod-date
                TK_mstr.TK_create_date      = IF TK_mstr.TK_create_date <= v-create-date THEN TK_mstr.TK_create_date ELSE v-create-date
                TK_mstr.TK_modified_date    = IF TK_mstr.TK_modified_date >= v-mod-date THEN TK_mstr.TK_modified_date ELSE v-mod-date 
                TK_mstr.TK_status           = v-tkstat                      /* 1dot6 */  
                TK_mstr.TK__char01          = "BioMed"                      /* 1dot6 */
                TK_mstr.TK_prog_name        = THIS-PROCEDURE:FILE-NAME      /* 1dot4 */                
                Tests_Result_RCD.Progress_Flag = IF Tests_Result_RCD.Progress_Flag = "A" THEN                       /* 1dot7 */
                                                        "AL"      /** stands for Add Loaded **/                     /* 1dot7 */
                                                  ELSE IF Tests_Result_RCD.Progress_Flag = "U" THEN                 /* 1dot7 */
                                                        "UL"                                                        /* 1dot7 */    
                                                  ELSE                                                              /* 1dot7 */
                                                        "IL".     /** stands for Import Loaded **/                  /* 1dot7 */
       
    END.  /*** of else if progress_flag = U --- Update a record ***/
    
    ELSE DO: 
                 
        EXPORT STREAM outward DELIMITER ";"
                Tests_Result_RCD.PatientID 
                TESTS_RESULT_RCD.Lab_Sampleid
                Tests_Result_RCD.Lab_Sampleid_SeqNbr
                v-tkid                                                                                  /* 2dot2 */
                v-tkseq                                                                                 /* 2dot2 */
                Tests_Result_RCD.Progress_Flag                                  /* 1dot4 */ 
                "ERROR 999!  Something UNEXPECTED happened.".      /* yet ironically I coded for it */
        ASSIGN ERROR-count[8] = ERROR-count[8]  + 1.                            /* 1dot4 */
            /* if this condition occured you should check the loadlist variable and also the Progress_Flag field */
    END.  /**  ELSE DO:  */
   
END.  /** of 4ea. Tests_Result_RCD --- main-block **/

EXPORT STREAM outward DELIMITER ";"
    999999999 
    999999999
    999999999
    999999999
    999999999
    999999999
    "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Records Processed".
    
EXPORT STREAM outward DELIMITER ";"                                                     /* 1dot4 */
    ERROR-count[1] "ERROR 1! TK_mstr.TK_ID or TK_test_seq already exists.  Add NOT done!".            /* 1dot4 */
EXPORT STREAM outward DELIMITER ";"                                                     /* 1dot4 */
    ERROR-count[2] "ERROR 2! Unknown Lab.  Please use the Lab Maintenance screen to add the Lab.".    /* 1dot4 */
EXPORT STREAM outward DELIMITER ";"                                                     /* 1dot4 */
    ERROR-count[3] "ERROR 3! Add new TK_mstr failed.".                                  /* 1dot4 */   
EXPORT STREAM outward DELIMITER ";"                                                     /* 1dot4 */
    ERROR-count[4] "ERROR 4!  Unable to find TK_mstr record that was created.".         /* 1dot4 */ 
EXPORT STREAM outward DELIMITER ";"                                                     /* 1dot4 */
    ERROR-count[5] "ERROR 5! Tests_Result record not found to delete from database.".   /* 1dot4 */    
EXPORT STREAM outward DELIMITER ";"                                                     /* 1dot4 */
    ERROR-count[6] "ERROR 6! TK_mstr record not found to Update.".                      /* 1dot4 */   
EXPORT STREAM outward DELIMITER ";"                                                     /* 1dot4 */
    ERROR-count[7] "ERROR 7! Update of TK_mstr record failed.".                         /* 1dot4 */ 
EXPORT STREAM outward DELIMITER ";"                                                     /* 1dot4 */
    ERROR-count[8] "ERROR 999!  Something UNEXPECTED happened.".                        /* 1dot4 */ 
EXPORT STREAM outward DELIMITER ";"                                                    
    ERROR-count[9] "ERROR 9!  trh_hist create failed.".  
EXPORT STREAM outward DELIMITER ";"                                                    
    ERROR-count[10] "ERROR 10! Blank Test_Kit_Nbr in  NEXT.".                      
EXPORT STREAM outward DELIMITER ";"                                                    
    ERROR-count[11] "ERROR 11! Add new TK_mstr really failed.".
           
OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).
    
/*************************  END OF FILE  **************************/

                                                      
