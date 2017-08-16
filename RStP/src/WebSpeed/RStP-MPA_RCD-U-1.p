/*------------------------------------------------------------------------
    File        : RSPT-MPA_RCD-U.p
    Purpose     :  

    Syntax      :

    Description : 

    Author(s)   : Sara Luttrell
    Created     : Wed Dec 17 18:30:45 MST 2014 - LAST UPDATES: 12/24/14
    Notes       :
        
  Version 1.1 - by DOUG LUTTRELL written on 27/Dec/14 based on 1.0 by SARA LUTTRELL.
                    Needed to address some of the missing fields (especially 
                    TK_status).  Cleaned up some of the IF structure.  Not marked.
             
  Version 1.2 - by DOUG LUTTRELL written on 02/Jan/15.  Includes all the changes
                    that came out as a result of the TESTS_RESULT_RCD version of this
                    program to support the lack of TK_test_seq data in the old system.
                    Not so many changes to this code since there was already a field,
                    but some of the related changes (specifically around not allowing
                    the TK_status to go "backwards" during an Update).
  
   Version 1.3 - by Harold Luttrell modified on 30/Apr/15.  Too many input parameters
                    being passed to the RUN trh-altered statement.  
                    Deleted the last input parameter which was a ?,  .
   
   Version 1.4 - By Harold Luttrell on 13/Jul/15.
        a.  Added more output data displays for the error log report. 
        b.  Removed the preprocessor references to 
            {&this-table}, which was pointing at MPA_RCD.
            I did NOT mark this change because there was so many of them I
            didn't want to make the code look junkie. 
        c.  Modified the FIND TK_mstr code - added the FIRST verb and 
            added the new index.
        d.  Added the THIS-PROCEDURE:FILE-NAME assign to xxx_prog_name.
        e.  Added total count for each ERROR! message.
            Marked by 1dot4. 
            
      
   Version 1.5 - By Harold Luttrell on 14/Sept/15.  
   Description:    Changed code to use the RUN VALUE(SEARCH) code 
                        instead of using the long path name and to use
                        the new SUBpat-findR.p requiring the DOB as input also.
    Identified by:  /* 1dot5 */                                  
    
    Version 1.6 - by Doug Luttrell written on 21/Sep/15.  Somewhat marked by 1dot6.
                    There were a ton of changes though, so I don't think they are
                    all marked.
                    a.  Added extra headers to the export stream of errors.  
                    b.  Added create & modified by to the TK_mstr.
                    c.  Modified trh_hist creation to only create records if 
                        they don't already exist (preventing more duplicates 
                        during a re-run because of an updated testkit record).  
                    d.  Added in code to create some of the missing historical 
                        data (TK_status stuff) for certain records where the previous
                        status information could be inferred.  
                    e.  Removed internal procedures to use the external versions.
                        Create SUBtrh-RStP-findR.p to go along with the previously
                        created SUBtrh-RStP-ucU.p which was being used even though
                        the internal procedure was available that did the same thing.
                    f.  Created an extra Error type (#9) that is for failed trh_hist
                        creation.  If we start getting a bunch of these we'll need
                        to expand all the #9's to be individual things.
                    g.  Added in code to prevent TK_status from rolling back to a 
                        previous status.    
                    h.  Changed the Update code to NOT wipe out the extra fields in 
                        the TK_mstr that the MPA_RCD table does not have.  (Professional,
                        Domestic, Customer ID, Customer Paid, Label Printed, Lab Paid).
                    i.  Changed the Update code to mirror the Add code (now that it's 
                        corrected).  It's starting to look like this code could be 
                        reduced to about 3 external procedures and maybe 1 include.
                        Oh well, maybe next release.
                    j.  Added code to correct the difference in the testkit type between
                        the old SQL system (where things were MPA types for the MPA family)
                        and the current production environment where MPA is a test_family and
                        the test_type is the prefix of the testkit.
                                
    Version 1.61 - written by DOUG LUTTRELL on 30/Sep/15.  Forgot to include the MPA_ReEngineeredDate
                        as the field that controls the label printing.  Also including the trh_hist
                        records for the PRINTED status.  Marked by 1dot61.
                                                    
    Version 1.62 - written by DOUG LUTTRELL on 08/Oct/15.  Modified to allow the A's to work like the U's
                        but in reverse.  Marked by 162.
                        
    Version 1.63 - written by DOUG LUTTRELL on 21/Nov/15.  Corrected all the RUN statements to run the *.r code.
                        Not marked.                        
        
    Version: 2.0    By Harold Luttrell, Sr.
    Date: 25/Feb/16.
    Description:    Changed database field name from TK_mstr.TK_testtype to TK_mstr.TK_test_type.
                    Created the: RStP-MPA-trh-TK-Status-Date-U.i file with the common logic
                        to create the transaction history record with the TK_status and date.
                        This reduce the number of lines of code from 2,267 to 977 and 
                        makes it easier to maintain these programs. 
                    Added code to use the new trh_hist fields/columns and the TK_mstr fields.                    
    Identified by /* 2dot0 */  
    
    Version 2.1 - written by DOUG LUTTRELL on 30/May/16.  Changed FINDs to respect the deleted flags.
                    Also fixed so that the MPA and BioMed old stuff doesn't overwrite each other.
                    Marked by 2dot1.
   
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
DEFINE VARIABLE v-testID        LIKE MPA_RCD.MPA_Test_Kit_Nbr   NO-UNDO.
DEFINE VARIABLE v-create        AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE v-update        AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE v-avail         AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE v-successful    AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE X               AS INTEGER                      NO-UNDO.
DEFINE VARIABLE v-error         AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE testkit         AS INTEGER                      NO-UNDO.

DEFINE VARIABLE v-tkid LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE VARIABLE v-tkseq LIKE TK_mstr.TK_test_seq NO-UNDO.

DEFINE VARIABLE v-tkstat        LIKE TK_mstr.TK_status          NO-UNDO.
DEFINE VARIABLE v-trhid         LIKE trh_hist.trh_id            NO-UNDO.
DEFINE VARIABLE v-trhfound      AS LOGICAL                      NO-UNDO. 

DEFINE VARIABLE labeldate AS DATE NO-UNDO.                                                              /* 1dot61 */

DEFINE VARIABLE statlist AS CHARACTER 
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,BURNED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO.
    
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

DEFINE VARIABLE testpref AS CHARACTER NO-UNDO.                                                          /* 1dot6 */
DEFINE VARIABLE v-testprefix LIKE TK_mstr.TK_test_type NO-UNDO.                 /* 2dot0 */
DEFINE VARIABLE starting-position AS INTEGER NO-UNDO.                           /* 2dot0 */                      
DEFINE VARIABLE h-pgm-name AS CHARACTER FORMAT "x(60)" NO-UNDO.                 /* 2dot0 */
 
/** useful for all RSTP code **/
DEFINE VARIABLE limitrun AS INTEGER INITIAL 0 NO-UNDO.                          /** a non-zero number will limit processing to that many records **/

DEFINE VARIABLE firstrun AS LOGICAL INITIAL NO NO-UNDO.                         /* change to YES for 2nd program */

DEFINE VARIABLE loadedlist      AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO.    

DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 20 NO-UNDO.                        /* 1dot4 */

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

ASSIGN starting-position = R-INDEX (THIS-PROCEDURE:FILE-NAME, "\").             /* 2dot0 */

ASSIGN h-pgm-name = SUBSTRING(THIS-PROCEDURE:FILE-NAME, (starting-position + 1), LENGTH (THIS-PROCEDURE:FILE-NAME) ).   /* 2dot0 */
 
ASSIGN messagetxt = messagetxt  + "\n"                                          /* 2dot0 */
                                + THIS-PROCEDURE:FILE-NAME                      /* 2dot0 */
                                + "\n"                                          /* 2dot0 */
                                + "End of message.".                            /* 2dot0 */

ASSIGN starting-position = R-INDEX (THIS-PROCEDURE:FILE-NAME, "\").             /* 2dot0 */

ASSIGN h-pgm-name = SUBSTRING(THIS-PROCEDURE:FILE-NAME, (starting-position + 1), LENGTH (THIS-PROCEDURE:FILE-NAME) ).   /* 2dot0 */

ASSIGN subjtxt = subjtxt + h-pgm-name.                                          /* 2dot0 */ 
    
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RStP-MPA_RCD-U-log-1.txt" NO-UNDO.             /* change to 2 for second program */                 

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "Patient_ID" 
    "TK_ID"
    "TK_test_seq"
    "Lab_Sample_ID"                                                                             /* 1dot6 */
    "Lab_Sample_Seq"                                                                            /* 1dot6 */
    "Progress_Flag"                                                                             /* 1dot6 */
    "Error Message".
 

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO. 

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

{emailaddr-USERID.i}.
   
/* ***************************  Main Block  *************************** */
main-block: 
FOR EACH MPA_RCD WHERE LOOKUP(MPA_RCD.Progress_Flag,loadedlist) = 0: 
        
    recordsprocessed = recordsprocessed + 1. 
    
    IF (limitrun > 0) AND (recordsprocessed > limitrun) THEN 
        LEAVE main-block.   

    ASSIGN 
        testpref    = CAPS(SUBSTRING(MPA_RCD.MPA_Test_Kit_nbr,1,INDEX(MPA_RCD.MPA_Test_Kit_nbr,"-") - 1)).
            
    FIND test_mstr WHERE test_mstr.test_type = testpref AND 
        test_mstr.test_deleted = ?                                                                  /* 2dot1 */
            NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE (test_mstr) THEN DO: 
        
        EXPORT STREAM outward DELIMITER ";"
            MPA_RCD.PatientID 
            MPA_RCD.MPA_Test_Kit_Nbr
            MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr
            MPA_RCD.MPA_Sample_ID_Number
            MPA_RCD.MPA_Sample_ID_SeqNbr
            MPA_RCD.progress_flag
            "ERROR 12! No test_mstr found for test type.".
            
        ASSIGN 
            ERROR-count[12] = ERROR-count[12]  + 1
            v-testprefix    = MPA_RCD.MPA_test_type.     
        
    END.  /** of if not available test_mstr **/
    
    ELSE DO: 
        
        IF test_mstr.test_family = "MPA" THEN
            v-testprefix = testpref.
        ELSE 
            v-testprefix = MPA_RCD.MPA_test_type.            
                   
    END. /** of else do -- if avail test_mstr **/
    
    /********************************************* Begin 2dot2 ********************************************************/
    ASSIGN 
        v-tkid  = ""
        v-tkseq = 1.
        
    IF MPA_RCD.MPA_Test_Kit_Nbr = "" THEN DO: 
        
        EXPORT STREAM outward DELIMITER ";"
            MPA_RCD.PatientID
            MPA_RCD.MPA_Sample_ID_Number
            MPA_RCD.MPA_Sample_ID_SeqNbr
            MPA_RCD.MPA_Test_Kit_Nbr
            MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr
            MPA_RCD.Progress_Flag
            "ERROR 10! Blank MPA_Test_Kit_Nbr in  NEXT.".
            
        ASSIGN ERROR-count[10] = ERROR-count[10]  + 1.   
    
        NEXT main-block.
        
    END.  /** of if testkitnbr = "" **/
    
    ELSE DO: 
        
        IF MPA_RCD.MPA_Test_Kit_Nbr < "A" OR 
            MPA_RCD.MPA_Test_Kit_Nbr BEGINS "CPR" OR  
            MPA_RCD.MPA_Test_Kit_Nbr BEGINS "NN" THEN DO: 
                
            ASSIGN 
                v-tkid  = MPA_RCD.MPA_Test_Kit_Nbr + "-" + v-testprefix + "-" + "OAH"
                v-tkseq = MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr.
                
        END.  /** of old style testkit **/ 
        
        ELSE DO: 
            
            ASSIGN 
                v-tkid  = MPA_RCD.MPA_Test_Kit_Nbr 
                v-tkseq = MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr.
            
        END.  /** of else do --- current style testkit **/
        
    END.  /** of else do --- testkitnbr <> "" **/
    
    FIND TK_mstr WHERE TK_mstr.TK_ID = v-tkid AND 
        TK_mstr.TK_test_seq = v-tkseq AND 
        TK_mstr.TK_test_type = MPA_RCD.MPA_test_type AND 
        TK_mstr.TK_deleted = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
    IF NOT AVAILABLE (tk_mstr) THEN DO: 
        
        FIND TK_mstr WHERE TK_mstr.TK_ID = v-tkid AND 
            TK_mstr.TK_test_seq = v-tkseq AND 
            TK_mstr.TK_test_type = MPA_RCD.MPA_test_type 
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
                 MPA_RCD.MPA_test_type,
                 ?,                                                             /* professional? */
                 v-tkseq,
                 ?,                                                             /* domestic */
                 0,                                                             /* Customer ID */
                 MPA_RCD.PatientID,
                 MPA_RCD.MPA_Sample_ID_Number, 
                 MPA_RCD.MPA_Sample_ID_SeqNbr,
                 MPA_RCD.MPA_Test_PatAGE,                                       /* age at time of test */
                 MPA_RCD.MPA_Test_LAB_Name, 
                 "",                                                            /** TK_status **/
                 MPA_RCD.MPA_Comments, 
                 MPA_RCD.MPA_Special_Note, 
                 ?,                                                             /* tk_cust_paid */          /* 2dot0 */
                 MPA_RCD.MPA_ReEngineered_Date,                                 /* lbl_print */             /* 2dot0 */
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
                    MPA_RCD.PatientID
                    MPA_RCD.MPA_Sample_ID_Number
                    MPA_RCD.MPA_Sample_ID_SeqNbr
                    v-tkid
                    v-tkseq
                    MPA_RCD.Progress_Flag                              /* 1dot4 */ 
                    "ERROR 3! Add new TK_mstr failed.".
                   
                ASSIGN ERROR-count[3] = ERROR-count[3]  + 1.                    /* 1dot4 */
                
            END.  /* IF v-successful = no */                                    /* 1dot4 */  
            
            ELSE DO: 
                
                FIND TK_mstr WHERE TK_mstr.TK_ID = v-tkid AND 
                    TK_mstr.TK_test_seq = v-tkseq AND 
                    TK_mstr.TK_test_type = MPA_RCD.MPA_test_type AND 
                    TK_mstr.TK_deleted = ?
                        EXCLUSIVE-LOCK NO-ERROR.
                        
                IF NOT AVAILABLE (TK_mstr) THEN DO: 
                    
                    EXPORT STREAM outward DELIMITER ";"
                        MPA_RCD.PatientID
                        MPA_RCD.MPA_Sample_ID_Number
                        MPA_RCD.MPA_Sample_ID_SeqNbr
                        v-tkid
                        v-tkseq
                        MPA_RCD.Progress_Flag                              /* 1dot4 */  
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
    
    /***********************************************************************
     *  Begin ADD section
     ***********************************************************************/    
    IF ((MPA_RCD.Progress_Flag = "" OR                                        
        MPA_RCD.Progress_Flag = "A") AND firstrun = NO) OR                      /* 162 */ 
        (firstrun = YES AND MPA_RCD.Progress_Flag = "U")                        /* aka - this path for U is only in program 2 */        
        THEN DO:                              
                                                    
        RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r"))                             /* 1dot5 */ 
            (v-tkid,
             v-testprefix,                                                  /* TK_test_type */           /* 1dot6 */
             ?,                                                             /* Professional? */
             v-tkseq,
             ?,                                                             /* Domestic? */
             0,                                                             /* Customer ID */
             MPA_RCD.PatientID,
             MPA_RCD.MPA_sample_ID_number,
             MPA_RCD.MPA_Sample_ID_SeqNbr,
             MPA_RCD.MPA_test_patAGE,                                       /* age at time of test */
             MPA_RCD.MPA_Test_LAB_Name,
             "",                                                            /* TK_Status */                                              
             MPA_RCD.MPA_Comments,
             MPA_RCD.MPA_Special_Note,
             ?,                                 /* tk_cust_paid */          /* 2dot0 */
             MPA_RCD.MPA_ReEngineered_Date,     /* lbl_print */             /* 2dot0 */
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
                 
        IF v-successful = NO THEN DO:               	                    /** Failed to create a TK_mstr record **/
            
            EXPORT STREAM outward DELIMITER ";"
                MPA_RCD.PatientID 
                v-tkid
                v-tkseq
                MPA_RCD.MPA_Sample_ID_Number
                MPA_RCD.MPA_Sample_ID_SeqNbr
                MPA_RCD.progress_flag
                "ERROR 2! v-successful = NO.".
               
            ASSIGN ERROR-count[2] = ERROR-count[2]  + 1.                    /* 1dot4 */
            
        END.  /* IF v-successful = NO */  

        ELSE DO:
                             
            FIND TK_mstr WHERE TK_mstr.TK_ID = v-tkid AND 
                TK_mstr.TK_test_seq = v-tkseq AND 
                TK_mstr.TK_test_type = v-testprefix AND                                                 /* 2dot1 */
                TK_mstr.TK_deleted = ?
                    EXCLUSIVE-LOCK NO-ERROR. 
                
            IF NOT AVAILABLE (TK_mstr) THEN DO: 
            
                EXPORT STREAM outward DELIMITER ";"
                    MPA_RCD.PatientID
                    v-tkid
                    v-tkid
                    MPA_RCD.MPA_Sample_ID_Number
                    MPA_RCD.MPA_Sample_ID_SeqNbr
                    MPA_RCD.progress_flag
                    "ERROR 3!  Unable to find record that was created.".
                    
                ASSIGN ERROR-count[3] = ERROR-count[3]  + 1.                /* 1dot4 */
                
            END.  /*** OF ELSE DO --- ERROR TYPE ***/
            
            ELSE DO:	       /** make all the history records and figure out the TK_status **/
                
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
                    v-trh-ref   = (MPA_RCD.MPA_Sample_ID_Number +                   /* 2dot0 */
                                   " / " +                                          /* 2dot0 */
                                   STRING(DECIMAL(MPA_RCD.MPA_Sample_ID_SeqNbr)) ). /* 2dot0 */
                                   
                ASSIGN                                                      /* 2dot0 */
                    v-trh-people    = IF TK_mstr.TK_patient_ID = 0 THEN     /* 2dot0 */
                                         TK_mstr.TK_cust_ID        ELSE     /* 2dot0 */
                                         TK_mstr.TK_patient_ID.             /* 2dot0 */
                
                ASSIGN 
                    v-trh-comments  = IF TK_mstr.TK_comments <> "" THEN     /* 2dot0 */
                                         TK_mstr.TK_comments       ELSE     /* 2dot0 */
                                         TK_mstr.tk_notes.                  /* 2dot0 */
                                         
                IF MPA_RCD.MPA_DateCollected <> ? THEN DO:                  /** COLLECTED **/               
                
                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_DateCollected         /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate 
                        v-tkstat        = "COLLECTED"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                        
                END. /* run --- COLLECTED */
                                                                            
                IF MPA_RCD.MPA_DateReceived <> ? THEN DO:                   /** LAB_RCVD **/                      
                
                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_DateReceived          /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                   
                        v-tkstat        = "LAB_RCVD"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                        
                END. /* run --- LAB_RCVD */
                                               
                IF MPA_RCD.MPA_DateCompleted <> ? THEN DO:      	        /** LAB_PROCESS **/                 
                    
                    /** we could probably infer LAB_RCVD at this point but I want to hold off on that for a while **/
                
                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_DateCompleted         /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                        v-tkstat        = "LAB_PROCESS"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                     
                END. /* run --- LAB_PROCESS */
                                                                 
/*** Insert some code here to grab the create date of the import file on disk for the HHI_RCVD date ***/  
/*** If successul in making a section for the HHI_RCVD date then need to adjust the sections below  ***/
/*** where that date is being created in the system based on LOADED and PROCESSED sections.         ***/                                                                                           
                                                                                                   
                IF MPA_RCD.MPA_Date_Results_Sent <> ? THEN DO:              /** LOADED, inferring HHI_RCVD **/           

                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_Date_Results_Sent     /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                        v-tkstat        = "HHI_RCVD"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                                            
                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_Date_Results_Sent     /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                        v-tkstat        = "LOADED"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                        
                END. /* run --- LOADED */
                           
                IF MPA_RCD.MPA_Date_processed <> ? THEN DO:     /** PROCESSED, inferring HHI_RCVD & LOADED **/

                    IF MPA_RCD.MPA_Date_Results_Sent = ? THEN DO:	  /** inference of HHI_RCVD & LOADED for PROCESSED **/
                        
                        ASSIGN
                            lazydate        = MPA_RCD.MPA_Date_processed     /* serves no purpose but to save me typing */
                            v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                            v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate
                            v-tkstat        = "HHI_RCVD"
                            v-trh-date      = lazydate.                     /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
  
                            ASSIGN 
                                lazydate        = MPA_RCD.MPA_Date_processed     /* serves no purpose but to save me typing */
                            v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                            v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                            v-tkstat        = "LOADED"
                            v-trh-date      = lazydate.                     /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */

                    END.  /*** of if MPA_RCD.MPA_Date_Results_Sent = ? --- infer HHI_RCVD and LOADED ***/
                                                                                                                       
                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_Date_processed        /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                             
                        v-tkstat        = "PROCESSED"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                            
                END. /* run --- PROCESSED */      
                    
                IF MPA_RCD.MPA_ReEngineered_Date <> ? THEN DO:      /** PRINTED --- 1dot61 **/
                
                    /********  Begin 1dot6 ***********/
                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_ReEngineered_Date     /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                        v-tkstat        = "PRINTED"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                
                END.    /** of if MPA_ReEngineered_Date <> ? --- PRINTED **/
                                    
                IF MPA_RCD.MPA_Date_Analysis_Sent <> ? THEN DO:             /** COMPLETE, inferring HHI_RCVD, LOADED, & PROCESSED **/                    

                    IF MPA_RCD.MPA_Date_processed = ? THEN DO:              /** inferrence of PROCESSED **/

                        IF MPA_RCD.MPA_Date_Results_Sent = ? THEN DO:       /** inferrence of HHI_RCVD & LOADED **/
                        
                            /********  Begin 1dot6 ***********/
                            ASSIGN 
                                lazydate        = MPA_RCD.MPA_Date_Analysis_Sent     /* serves no purpose but to save me typing */
                                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                                v-tkstat        = "HHI_RCVD"
                                v-trh-date      = lazydate.                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */                                               
                    
                            /********  Begin 1dot6 ***********/
                            ASSIGN 
                                lazydate        = MPA_RCD.MPA_Date_Analysis_Sent     /* serves no purpose but to save me typing */
                                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                                v-tkstat        = "LOADED"
                                v-trh-date      = lazydate.                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */

                        END.  /*** of if MPA_RCD.MPA_Date_Results_Sent = ? --- HHI_RCVD & LOADED ***/
                        /************ End of 1dot6 ***************/
                                               
                        ASSIGN 
                            lazydate        = MPA_RCD.MPA_Date_Analysis_Sent        /* serves no purpose but to save me typing */
                            v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                            v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                             
                            v-tkstat        = "PROCESSED"
                            v-trh-date      = lazydate.                     /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                                
                    END. /* of if MPA_Date_processed --- PROCESSED */    
                    
                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_Date_Analysis_Sent    /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                         
                        v-tkstat        = "COMPLETE"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */

                END. /* run --- COMPLETE */                 
                            
                /** don't allow the status to roll backwards **/                                
                IF LOOKUP(v-tkstat,statlist) > LOOKUP(TK_mstr.TK_status,statlist) THEN
                    ASSIGN 
                        TK_mstr.TK_status = v-tkstat.
                ELSE 
                    ASSIGN 
                        TK_mstr.TK_status = TK_mstr.TK_status.  
                /** end of prevent status rollback **/
                                  
                ASSIGN
                    TK_mstr.TK_prog_name        = THIS-PROCEDURE:FILE-NAME          /* 1dot4 */
                    v-create-date               = IF v-create-date = ? THEN TODAY ELSE v-create-date
                    v-mod-date                  = IF v-mod-date = ? THEN TODAY ELSE v-mod-date
                    TK_mstr.TK_create_date      = IF TK_mstr.TK_create_date <= v-create-date THEN TK_mstr.TK_create_date ELSE v-create-date
                    TK_mstr.TK_created_by       = IF TK_mstr.TK_created_by = "" THEN USERID("HHI") ELSE TK_mstr.TK_created_by       /* 1dot6 */
                    TK_mstr.TK_modified_date    = IF TK_mstr.TK_modified_date >= v-mod-date THEN TK_mstr.TK_modified_date ELSE v-mod-date
                    TK_mstr.TK_modified_by      = USERID("HHI")                                                                     /* 1dot6 */
                    TK_mstr.TK__dec01           = MPA_RCD.MPA_batch_number
                    TK_mstr.TK__dec02           = MPA_RCD.MPA_Nbr_of_SNP_IDs
                    TK_mstr.TK__char01          = "MPA"
                    MPA_RCD.Progress_Flag       = IF MPA_RCD.Progress_Flag = "A" THEN   
                                                        "AL"      /** stands for Add Loaded **/
                                                  ELSE IF MPA_RCD.Progress_Flag = "U" THEN
                                                        "UL"      /** stands for Update Loaded **/                                                      
                                                  ELSE IF MPA_RCD.Progress_Flag = "" THEN
                                                        "IL"     /** stands for Import Loaded **/
                                                  ELSE MPA_RCD.Progress_Flag.
                                      
                                      
            END.  /*** of else do --- avail tk_mstr ***/
        
        END. /* ElSE DO --- v-successful = yes */
            
    END.  /*** of progress_flag = blank or A --- create a record ***/
    
    
    /***********************************************************************
     *  Begin DELETE section
     ***********************************************************************/
    ELSE IF MPA_RCD.Progress_Flag = "D" THEN DO:                                 

        ASSIGN
            TK_mstr.TK_deleted          = TODAY 
            TK_mstr.TK_modified_by      = USERID("HHI")
            TK_mstr.TK_modified_date    = TODAY 
            TK_mstr.TK_prog_name        = THIS-PROCEDURE:FILE-NAME             /* 1dot4 */
            MPA_RCD.Progress_Flag       = "DL".     /** update the database --- stands for Delete Loaded **/
    
    END.  /**** of else if progress_flag = D --- Delete a record ****/
    
            
    /***********************************************************************
     *  Begin UPDATE section
     ***********************************************************************/              
    ELSE IF (
            (MPA_RCD.Progress_Flag = "U" AND firstrun = NO) OR 
            ((MPA_RCD.Progress_Flag = "A" OR MPA_RCD.Progress_Flag = "") AND                                        /* 162 */ 
            firstrun = YES)                                                                                         /* 162 */
            ) THEN DO:                    /** aka - program 1 **/                         

            
        /*********************  Duplicate process as the A section  *******************************************/
        /** make all the history records and figure out the TK_status **/
        
        ASSIGN                                                      /* reset variables to blank before use */
            v-create-date   = ?
            v-mod-date      = ?
            v-TKstat        = ""  
            v-trh-comments  = ""                                            /* 2dot0 */
            v-trh-other     = ""                                            /* 2dot0 */
            v-trh-people    = 0                                             /* 2dot0 */    
            v-trh-order     = ""                                            /* 2dot0 */
            v-trh-date      = ?                                             /* 2dot0 */
            v-trh-time      = ""                                            /* 2dot0 */
            v-trh-ref       = "".                                           /* 2dot0 */
                                       
        ASSIGN                                                              /* 2dot0 */                               
            v-trh-ref   = (MPA_RCD.MPA_Sample_ID_Number +                   /* 2dot0 */
                           " / " +                                          /* 2dot0 */
                           STRING(DECIMAL(MPA_RCD.MPA_Sample_ID_SeqNbr)) ). /* 2dot0 */
                           
        ASSIGN                                                      /* 2dot0 */
            v-trh-people    = IF TK_mstr.TK_patient_ID = 0 THEN     /* 2dot0 */
                                 TK_mstr.TK_cust_ID        ELSE     /* 2dot0 */
                                 TK_mstr.TK_patient_ID.             /* 2dot0 */
        
        ASSIGN 
            v-trh-comments  = IF TK_mstr.TK_comments <> "" THEN     /* 2dot0 */
                                 TK_mstr.TK_comments       ELSE     /* 2dot0 */
                                 TK_mstr.tk_notes.                  /* 2dot0 */
                
        IF MPA_RCD.MPA_DateCollected <> ? THEN DO:      /** COLLECTED **/               
        
            ASSIGN 
                lazydate        = MPA_RCD.MPA_DateCollected         /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate 
                v-tkstat        = "COLLECTED"
                v-trh-date      = lazydate.                                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                
        END. /* run --- COLLECTED */              
                                            
        IF MPA_RCD.MPA_DateReceived <> ? THEN DO:       /** LAB_RCVD **/                      
        
            ASSIGN 
                lazydate        = MPA_RCD.MPA_DateReceived          /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                   
                v-tkstat        = "LAB_RCVD"
                v-trh-date      = lazydate.                                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                
        END. /* run --- LAB_RCVD */
                
        IF MPA_RCD.MPA_DateCompleted <> ? THEN DO:      /** LAB_PROCESS **/                 
            
            /** we could probably infer LAB_RCVD at this point but I want to hold off on that for a while **/
        
            ASSIGN 
                lazydate        = MPA_RCD.MPA_DateCompleted         /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                v-tkstat        = "LAB_PROCESS"
                v-trh-date      = lazydate.                                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */           
             
        END. /* run --- LAB_PROCESS */
                                                                     
/*** Insert some code here to grab the create date of the import file on disk for the HHI_RCVD date ***/  
/*** If successul in making a section for the HHI_RCVD date then need to adjust the sections below  ***/
/*** where that date is being created in the system based on LOADED and PROCESSED sections.         ***/                                                                                           
                                     
/*** use this type of command if you get ahold of the file -    lazydate = FILE-INFO:FILE-MOD-DATE. ***/                                     
                                                                               
        IF MPA_RCD.MPA_Date_Results_Sent <> ? THEN DO:         /** LOADED, inferring HHI_RCVD **/           
        
            /********  Begin 1dot6 ***********/
            ASSIGN 
                lazydate        = MPA_RCD.MPA_Date_Results_Sent     /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                v-tkstat        = "HHI_RCVD"
                v-trh-date      = lazydate.                                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */                  
        
            ASSIGN 
                lazydate        = MPA_RCD.MPA_Date_Results_Sent     /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                v-tkstat        = "LOADED"
                v-trh-date      = lazydate.                                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                
        END. /* run --- LOADED */
   
            IF MPA_RCD.MPA_Date_processed <> ? THEN DO:     /** PROCESSED, inferring HHI_RCVD & LOADED **/

            IF MPA_RCD.MPA_Date_Results_Sent = ? THEN DO:     /** inference of HHI_RCVD & LOADED for PROCESSED **/
       
                /********  Begin 1dot6 ***********/
                ASSIGN 
                    lazydate        = MPA_RCD.MPA_Date_processed     /* serves no purpose but to save me typing */
                    v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                    v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                    v-tkstat        = "HHI_RCVD"
                    v-trh-date      = lazydate.                             /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */  
         
                /********  Begin 1dot6 ***********/
                ASSIGN 
                    lazydate        = MPA_RCD.MPA_Date_processed     /* serves no purpose but to save me typing */
                    v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                    v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                    v-tkstat        = "LOADED"
                    v-trh-date      = lazydate.                             /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
            
            END.  /*** of if MPA_RCD.MPA_Date_Results_Sent = ? --- infer HHI_RCVD and LOADED ***/
            /************ End of 1dot6 ***************/  
                                                
            ASSIGN 
                lazydate        = MPA_RCD.MPA_Date_processed        /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                             
                v-tkstat        = "PROCESSED"
                v-trh-date      = lazydate.                                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                    
        END. /* run --- PROCESSED */      
           
        IF MPA_RCD.MPA_ReEngineered_Date <> ? THEN DO:      /** PRINTED --- 1dot61 **/
        
            /********  Begin 1dot6 ***********/
            ASSIGN 
                lazydate        = MPA_RCD.MPA_ReEngineered_Date     /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                v-tkstat        = "PRINTED"
                v-trh-date      = lazydate.                                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */                
        
        END.    /** of if MPA_ReEngineered_Date <> ? --- PRINTED **/
        
                            
        IF MPA_RCD.MPA_Date_Analysis_Sent <> ? THEN DO:     /** COMPLETE, inferring HHI_RCVD, LOADED, & PROCESSED **/                    

            IF MPA_RCD.MPA_Date_processed = ? THEN DO:  /** inferrence of PROCESSED **/

                IF MPA_RCD.MPA_Date_Results_Sent = ? THEN DO:   /** inferrence of HHI_RCVD & LOADED **/
                    
                    /********  Begin 1dot6 ***********/
                    ASSIGN 
                        lazydate        = MPA_RCD.MPA_Date_Analysis_Sent     /* serves no purpose but to save me typing */
                        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
                        v-tkstat        = "HHI_RCVD"
                        v-trh-date      = lazydate.                         /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */ 
                
                END.  /*** of if MPA_RCD.MPA_Date_Results_Sent = ? --- HHI_RCVD & LOADED ***/
                /************ End of 1dot6 ***************/  
                                                
                ASSIGN 
                    lazydate        = MPA_RCD.MPA_Date_Analysis_Sent        /* serves no purpose but to save me typing */
                    v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                    v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                             
                    v-tkstat        = "PROCESSED"
                    v-trh-date      = lazydate.                             /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */
                        
            END. /* of if MPA_Date_processed --- PROCESSED */    
                    
            ASSIGN 
                lazydate        = MPA_RCD.MPA_Date_Analysis_Sent    /* serves no purpose but to save me typing */
                v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                         
                v-tkstat        = "COMPLETE"
                v-trh-date      = lazydate.                                 /* 2dot0 */
                        
{RStP-MPA-trh-TK-Status-Date-U.i}.                                              /* 2dot0 */

        END. /* run --- COMPLETE */                 
                    
        
        /**********************************************************************************************************/
            
 
 
            /** put in a catch to make sure that we don't move a status backwards during an Update **/
        IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN 
            v-TKstat = v-TKstat.
        ELSE 
            v-TKstat = TK_mstr.TK_status. 
        
        /* 1dot61 */    
        IF TK_mstr.TK_lbl_print = ? OR (TK_mstr.TK_lbl_print > MPA_RCD.MPA_ReEngineered_Date) THEN 
            labeldate = MPA_RCD.MPA_ReEngineered_Date.
        ELSE 
            labeldate = TK_mstr.TK_lbl_print.
        
        /** update the TK_mstr record **/            
        RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r"))
            (TK_mstr.tk_ID,                                                 /* 1dot6 */
             v-testprefix,              /* TK_test_type */                  /* 1dot6 */
             TK_mstr.TK_prof,                                               /* 1dot6 */
             TK_mstr.TK_test_seq,                                           /* 1dot6 */
             TK_mstr.TK_domestic,                                           /* 1dot6 */
             TK_mstr.TK_cust_ID,                                            /* 1dot6 */
             MPA_RCD.PatientID,
             MPA_RCD.MPA_sample_ID_number,
             MPA_RCD.MPA_Sample_ID_SeqNbr,
             MPA_RCD.MPA_Test_PatAGE,                                       /* age at time of test */
             MPA_RCD.MPA_Test_LAB_Name,                                                         
             v-TKstat,                                                      /* TK_status */
             MPA_RCD.MPA_Comments,
             MPA_RCD.MPA_Special_Note,
             ?,                                 /* tk_cust_paid */          /* 2dot0 */
             MPA_RCD.MPA_ReEngineered_Date,     /* lbl_print */             /* 2dot0 */
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
                MPA_RCD.PatientID 
                MPA_RCD.MPA_Test_Kit_Nbr
                MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr
                MPA_RCD.MPA_Sample_ID_Number
                MPA_RCD.MPA_Sample_ID_SeqNbr
                MPA_RCD.progress_flag
               "ERROR 6! Update of TK_mstr failed.".
               
            ASSIGN ERROR-count[6] = ERROR-count[6]  + 1.                            /* 1dot4 */
            
        END.  /* IF v-successful = NO */
        
        ELSE DO:    /** v-successful = yes **/                    
                 
            FIND TK_mstr WHERE TK_mstr.TK_ID = v-tkid AND         /* 1dot6 */
                TK_mstr.TK_test_seq = v-tkseq AND 
                TK_mstr.TK_test_type = v-testprefix AND                                                 /* 2dot1 */
                TK_mstr.TK_deleted = ?                                      /* 1dot4 */
                    EXCLUSIVE-LOCK NO-ERROR.
            
            IF NOT AVAILABLE(tk_mstr) THEN DO:
                
                EXPORT STREAM outward DELIMITER ";"
                    MPA_RCD.PatientID 
                    MPA_RCD.MPA_Test_Kit_Nbr
                    MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr
                    MPA_RCD.MPA_Sample_ID_Number
                    MPA_RCD.MPA_Sample_ID_SeqNbr
                    MPA_RCD.progress_flag
                   "ERROR 7! Unable to FIND TK_mstr after UPDATE.".
                   
                ASSIGN ERROR-count[7] = ERROR-count[7]  + 1.                            /* 1dot4 */
                
            END.  /** of if not avail tk_mstr --- error **/
            
            ELSE DO:            /** if avail TK_mstr **/ 
                               
                ASSIGN 
/****** commenting out these updates because they should be being done up above in the external procedure  *********/
/*                        v-create-date               = IF v-create-date = ? THEN TODAY ELSE v-create-date                                       */
/*                        v-mod-date                  = IF v-mod-date = ? THEN TODAY ELSE v-mod-date                                             */
/*                        TK_mstr.TK_create_date      = IF TK_mstr.TK_create_date <= v-create-date THEN TK_mstr.TK_create_date ELSE v-create-date*/
/*                        TK_mstr.TK_modified_date    = IF TK_mstr.TK_modified_date >= v-mod-date THEN TK_mstr.TK_modified_date ELSE v-mod-date  */
/*                        TK_mstr.TK_modified_by      = USERID("HHI")                             /* 1dot6 */                                    */
                    TK_mstr.TK__dec01           = MPA_RCD.MPA_batch_number
                    TK_mstr.TK__dec02           = MPA_RCD.MPA_Nbr_of_SNP_IDs
                    MPA_RCD.Progress_Flag = IF MPA_RCD.Progress_Flag = "A" THEN        /* 162 */  
                                                        "AL"      /** stands for Add Loaded **/                     /* 162 */
                                                  ELSE IF MPA_RCD.Progress_Flag = "U" THEN                          /* 162 */
                                                        "UL"    /**  stands for Update Loaded **/                   /* 162 */                                
                                                  ELSE IF MPA_RCD.Progress_Flag = "" THEN
                                                        "IL"     /** stands for Import Loaded **/                  /* 162 */
                                                  ELSE MPA_RCD.Progress_Flag.
                    
            END.  /** of ELSE DO -- if avail TK_mstr **/              
           
        END.  /** of ELSE DO --- v-successful = YES **/
               
    END.  /*** of else if progress_flag = U --- Update a record ***/
    
    ELSE DO: 
               
        EXPORT STREAM outward DELIMITER ";"
                MPA_RCD.PatientID
                MPA_RCD.MPA_Test_Kit_Nbr
                MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr
                MPA_RCD.MPA_Sample_ID_Number
                MPA_RCD.MPA_Sample_ID_SeqNbr
                MPA_RCD.progress_flag
                "ERROR 8!  Something UNEXPECTED happened.".      /* yet ironically I coded for it */
                
        ASSIGN ERROR-count[8] = ERROR-count[8]  + 1.                            /* 1dot4 */
        
    END.  /*** of else do --- unexpected error! ***/
   
END.  /** of 4ea. patient_files **/

EXPORT STREAM outward DELIMITER ";"
    999999999 
    999999999
    999999999
    "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Records Processed".
   
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot4 */
    ERROR-count[1] "ERROR 1! TK_mstr.TK_ID AND TK_test_seq combination already exists.".     /* 1dot4 */    /* 1dot6 */
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot4 */
    ERROR-count[2] "ERROR 2! v-successful = NO.".                               /* 1dot4 */
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot4 */
    ERROR-count[3] "ERROR 3!  Unable to find record that was created.".         /* 1dot4 */   
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot4 */
    ERROR-count[4] "ERROR 4! MPA record already deleted from database.".        /* 1dot4 */ 
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot4 */
    ERROR-count[5] "ERROR 5! Record not found to update.".                      /* 1dot4 */
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot4 */
    ERROR-count[6] "ERROR 6! Update of TK_mstr failed.".                        /* 1dot4 */   
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot4 */
    ERROR-count[7] "ERROR 7! Unable to FIND TK_mstr after UPDATE.".             /* 1dot4 */ 
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot4 */
    ERROR-count[8] "ERROR 8!  Something UNEXPECTED happened.".                  /* 1dot4 */
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot6 */
    ERROR-count[9] "ERROR 9!  trh_hist create failed.".                         /* 1dot6 */
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot6 */
    ERROR-count[10] "ERROR 10! No test_mstr found for test type.".              /* 1dot6 */
            
EXPORT STREAM outward DELIMITER ";"                                             
    ERROR-count[11] "ERROR 11! Add new TK_mstr really failed.".                
EXPORT STREAM outward DELIMITER ";"                                             
    ERROR-count[12] "ERROR 12! No test_mstr found for test type.".
            
OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).
    
/*************************  END OF FILE  **************************/