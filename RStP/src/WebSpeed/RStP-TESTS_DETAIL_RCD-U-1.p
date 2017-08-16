   
/*------------------------------------------------------------------------
    File        : RStP-TESTS_DETAIL_RCD-U.p 
    Purpose     : 

    Syntax      :

    Description : Migrate the attached files data from the PATIENT_RCD table to the att_files table.
                    Designed to be run repeatedly in batch.

    Author(s)   : Jacob Luttrell
    Created     : Thu Dec 24 20:19:30 EST 2014
    Notes       :

  ----------------------------------------------------------------------
  Revision History:        
  -----------------
  1.0 - written by DOUG LUTTRELL on 11/Dec/14.  Original version.
  
  1.1 - By Harold Luttrell on 15/Jul/15.
        a.  Added more output data displays for the error log report.  
        b.  Change the output log file name to: 
                RStP-TESTS_DETAIL-RCD-U-log-1.txt.
        c.  Added the THIS-PROCEDURE:FILE-NAME assign to xxxx_prog_name.
        d.  Added the count for each ERROR! message. 
        e.  Removed the preprocessor reference to 
            {&child}, which was pointing at TESTS_DETAIL_RCD and removed the
            reference to {&parent} which was pointing at TESTS_RESULT_RCD.  
        f.  Changed the access method on the FIND statement for the TK_mstr.
        Marked by 1dot1.
  
  1.2 - By Harold Luttrell on 13/Aug/15.
        a.  Changed the "created_by" and "modfied_by" to use the correct
            USERID("database") value to the correct database name.  
            "HHI" for HHI db records and "General" for General db records. 
        b.  Verified the error messages in the log file for correctness.
        Marked by 1dot2.
   
  1.3 - By Harold Luttrell on 14/Sept/15.  
  Description:    added the PROPATH.
    Identified by:  /* PROPATH */      
    
  1.4 - written by DOUG LUTTRELL on 08/Oct/15.  Changed to have A's behave like U's
            but in reverse.  Marked by 1dot4.
     
    Version: 2.0    By Harold Luttrell, Sr.
    Date: 5/Mar/16.
    Description:    Changed database field name from 
                        TK_mstr.TK_testtype to TK_mstr.TK_test_type.                    
    Identified by /* 2dot0 */  
              
    2.1 - written by DOUG LUTTRELL on 28/May/16.  Changed the way the search is
            working to be more precise (and hopefully a little faster).  Checked
            into issue with program not using correct sequence data.  Seems to
            be data related at the parent level.  Marked by 2dot1.
           
    2.11 - written by DOUG LUTTRELL on 30/May/16.  So close and yet so very, very
            far away.  Changed to respect deleted flags.  Also made changes to the
            FIND similar to the ones used in the parent records.  Marked by 211.
                          
    2.2  - written by DOUG LUTTRELL on 01/Jun/16.  Totally revamping the way we
            handle old testkit IDs and testkit Sequences.  Old ones will now be a 
            concatenantion of the old testkit ID, the test type, and the letters
            "OAH" which stands for Old As Heck.  This also changes the way this 
            program does FINDs.  All the finding and creating is done up front
            and then the updating is done down below.  Commented out large swaths
            of code which often did not get marked.  The rest was marked by 2dot2.
            See also RStP-TESTS_RESULT_RCD-U-1.p.
                  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/** specific to this program **/   

DEFINE VARIABLE childcount AS INTEGER NO-UNDO.
DEFINE VARIABLE parentcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-tk_test_seq LIKE TK_mstr.tk_test_seq NO-UNDO.                                                 /* 2dot1 */

DEFINE VARIABLE v-tkid LIKE TKR_det.TKR_ID NO-UNDO.                                                              /* 2dot2 */
DEFINE VARIABLE v-tkseq LIKE TKR_det.TKR_test_seq NO-UNDO.                                                       /* 2dot2 */

DEFINE VARIABLE v-testID LIKE TK_mstr.TK_ID NO-UNDO. 
DEFINE VARIABLE v-create AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-update AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-avail AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-successful AS LOGICAL NO-UNDO. 

/** useful for all RSTP code **/
DEFINE VARIABLE tester           AS CHARACTER INITIAL NO NO-UNDO. 
DEFINE VARIABLE firstrun         AS LOGICAL   INITIAL NO NO-UNDO.                   /* change to YES for the second program */
DEFINE VARIABLE loadedlist       AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER   NO-UNDO.    
    
DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 11 NO-UNDO.                        /* 1dot1 */

DEFINE VARIABLE cmdname          AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"    NO-UNDO.
DEFINE VARIABLE emailaddr        AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"          NO-UNDO.
DEFINE VARIABLE messagetxt       AS CHARACTER INITIAL "-m Error Report attached from "              NO-UNDO.       /* 1dot1 */
DEFINE VARIABLE subjtxt          AS CHARACTER INITIAL "-s Error Report from "                       NO-UNDO.       /* 1dot1 */
DEFINE VARIABLE cmdparams        AS CHARACTER INITIAL "-a" NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
    
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RStP-TESTS_DETAIL_RCD-U-log-1.txt" NO-UNDO.  /* 1dot1 */ /* change to 2 for the second program */

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "PatientID" 
    "Lab_SampleID" 
    "Lab_SampleID_SeqNbr" 
    "Progress_Flag"                                                             /* 1dot1 */
    "Error Message".


/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE v-seqNbr LIKE TK_mstr.TK_test_seq NO-UNDO.                                                      /* 211 */ 

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.          

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

{emailaddr-USERID.i}. 

/* ***************************  Main Block  *************************** */
main-block:                                                                                                     /* 2dot2 */
FOR EACH TESTS_DETAIL_RCD WHERE LOOKUP(TESTS_DETAIL_RCD.Progress_Flag,loadedlist) = 0 EXCLUSIVE-LOCK :        /* 1dot1 */

    childcount = childcount + 1.

    IF tester = "YES" AND recordsprocessed >= 100 THEN                                                          /* 2dot2 */
        LEAVE main-block.                                                                                       /* 2dot2 */

    recordsprocessed = recordsprocessed + 1. 
    
    /**** begin 2dot1 ****/
    FIND TESTS_RESULT_RCD WHERE TESTS_RESULT_RCD.PatientID = TESTS_DETAIL_RCD.PatientID AND 
        TESTS_RESULT_RCD.lab_sampleid = TESTS_DETAIL_RCD.Lab_Sampleid AND 
        TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr AND 
        TESTS_RESULT_RCD.Test_Abbv = TESTS_DETAIL_RCD.Test_Abbv 
            NO-LOCK NO-ERROR.
                        
    /****  End of 2dot1 *****/

    IF AVAILABLE (tests_result_rcd) THEN DO: 
        
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
        
        FIND TKR_det WHERE TKR_det.TKR_ID = v-tkid AND 
            TKR_det.TKR_test_seq = v-tkseq AND 
            TKR_det.TKR_item = TESTS_DETAIL_RCD.Test_Element_Item AND 
            TKR_det.TKR_deleted = ? 
                EXCLUSIVE-LOCK NO-ERROR.
                
        IF NOT AVAILABLE (tkr_det) THEN DO: 
            
            FIND TKR_det WHERE TKR_det.TKR_ID = v-tkid AND 
                TKR_det.TKR_test_seq = v-tkseq AND 
                TKR_det.TKR_item = TESTS_DETAIL_RCD.Test_Element_Item 
                    EXCLUSIVE-LOCK NO-ERROR.
            
            IF AVAILABLE (tk_mstr) THEN DO:     /** undelete this testkit **/
                
                ASSIGN 
                    TKR_det.TKR_deleted         = ?
                    TKR_det.TKR_modified_by     = USERID("HHI")
                    TKR_det.TKR_modified_date   = TODAY 
                    TKR_det.tkr_prog_name       = THIS-PROCEDURE:FILE-NAME.
                    
                /*** how to handle other (non-testkit) fields? ***/
                
            END.  /** of if avail tk_mstr **/
                
            ELSE DO:        /*** go ahead and create a TKR ***/
                
                ASSIGN 
                    v-testID        = ""
                    v-create        = ?
                    v-update        = ?
                    v-avail         = ?
                    v-successful    = ?.                
                
                RUN VALUE(SEARCH("SUBtkrdet-RStP-ucU.r"))
                    (v-tkid,
                     v-tkseq,
                     TESTS_DETAIL_RCD.Test_Element_Item,
                     TESTS_DETAIL_RCD.Test_ResultAlph,
                     TESTS_DETAIL_RCD.Test_ResultVal,
                     TESTS_DETAIL_RCD.TestRefInterval,
                     0,                                     /* TKR_ref_low */
                     0,                                     /* TKR_ref_high */
                     "",                                    /* TKR_ref_uom */
                     TESTS_DETAIL_RCD.TestMinusSD,
                     TESTS_DETAIL_RCD.TestMeanSD,
                     TESTS_DETAIL_RCD.TestPlusSD,
                     TESTS_DETAIL_RCD.Lab_Sampleid,         /* TKR__char01 */
                     TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr,  /* TKR__dec01 */
                     OUTPUT v-testID,
                     OUTPUT v-create,
                     OUTPUT v-update,
                     OUTPUT v-avail,
                     OUTPUT v-successful).
                     
                         
                IF v-successful = NO OR v-successful = ? THEN DO:                                       /* 1dot4 */
                    
                    EXPORT STREAM outward DELIMITER ";"
                        TESTS_DETAIL_RCD.PatientID                                   /* 1dot1 */
                        TESTS_DETAIL_RCD.Lab_Sampleid                                /* 1dot1 */
                        TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr                         /* 1dot1 */
                        TESTS_DETAIL_RCD.Test_Element_Item                           /* 1dot1 */
                        TESTS_DETAIL_RCD.Progress_Flag                               /* 1dot1 */
                        "ERROR 6! Add TESTS_DETAIL_RCD failed.".
                    
                    ASSIGN ERROR-count[6] = ERROR-count[6]  + 1.                        /* 1dot1 */                            
                    
                END.  /* IF v-successful = no */                                    /* 1dot4 */  
                
                ELSE DO: 
                    
                    FIND TKR_det WHERE TKR_det.TKR_ID = v-tkid AND 
                        TKR_det.TKR_test_seq = v-tkseq AND 
                        TKR_det.TKR_item = TESTS_DETAIL_RCD.Test_Element_Item AND 
                        TKR_det.TKR_deleted = ? 
                            EXCLUSIVE-LOCK NO-ERROR.
                                
                    IF NOT AVAILABLE (TKR_det) THEN DO: 
                        
                        EXPORT STREAM outward DELIMITER ";"
                            Tests_Result_RCD.PatientID 
                            TESTS_RESULT_RCD.Lab_Sampleid
                            Tests_Result_RCD.Lab_Sampleid_SeqNbr
                            v-tkid
                            v-tkseq
                            Tests_Result_RCD.Progress_Flag                              /* 1dot4 */ 
                           "ERROR 11! Add new TKR_det really failed.".
                           
                        ASSIGN ERROR-count[11] = ERROR-count[11]  + 1.                    /* 1dot4 */
                        
                        NEXT main-block. 
                        
                    END.  /* IF v-successful = no */                                    /* 1dot4 */       
                    
                END.  /** of else do --- v-successful = YES **/
                
            END.  /** of else do --- not avail tk-mstr **/
        
        END.  /** of if not avail tk_mstr **/
        
        ELSE DO:        /* matched, update time */
            
            /* in here is where the update stuff should be? */
            /* Not really, because the above could be creating records we need below */
        
        END.  /** of else do --- if avail tk-mstr **/        
        
    
        /*****************************************************************************************
         *  Begin ADD section
         *****************************************************************************************/

        IF ((TESTS_DETAIL_RCD.Progress_Flag = "" OR                                                                  /* 1dot4 */
             TESTS_DETAIL_RCD.Progress_Flag = "A") AND firstrun = NO) OR                           /* 1dot1 */         /* 1dot4 */
            (firstrun = YES AND TESTS_DETAIL_RCD.Progress_Flag = "U") THEN   /* 1dot1 */ 
        DO:                                                                                          /* this line is for the initial load only */             
            
            ASSIGN 
                v-testID        = ""
                v-create        = ?
                v-update        = ?
                v-avail         = ?
                v-successful    = ?.                
            
            RUN VALUE(SEARCH("SUBtkrdet-RStP-ucU.r"))
                (v-tkid,
                 v-tkseq,
                 TESTS_DETAIL_RCD.Test_Element_Item,
                 TESTS_DETAIL_RCD.Test_ResultAlph,
                 TESTS_DETAIL_RCD.Test_ResultVal,
                 TESTS_DETAIL_RCD.TestRefInterval,
                 0,                                     /* TKR_ref_low */
                 0,                                     /* TKR_ref_high */
                 "",                                    /* TKR_ref_uom */
                 TESTS_DETAIL_RCD.TestMinusSD,
                 TESTS_DETAIL_RCD.TestMeanSD,
                 TESTS_DETAIL_RCD.TestPlusSD,
                 TESTS_DETAIL_RCD.Lab_Sampleid,         /* TKR__char01 */
                 TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr,  /* TKR__dec01 */
                         OUTPUT v-testID,
                         OUTPUT v-create,
                         OUTPUT v-update,
                         OUTPUT v-avail,
                         OUTPUT v-successful).
 
            IF v-successful = YES THEN DO:
                         
                IF TESTS_DETAIL_RCD.Progress_Flag = "A" THEN 
                    TESTS_DETAIL_RCD.Progress_Flag = "AL".   
                ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "" THEN
                    TESTS_DETAIL_RCD.Progress_Flag = "IL".
                ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "U" THEN
                    TESTS_DETAIL_RCD.Progress_Flag = "UL".
                    
            END.  /** of if v-successful = yes **/                             
            
        END.  /*** of progress_flag = blank or A --- create a record ***/
        
        /*****************************************************************************************
         *  Begin DELETE section
         *****************************************************************************************/            
        
        ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "D" THEN  DO:
                 
            ASSIGN
                TKR_det.TKR_deleted         = TODAY 
                TKR_det.TKR_modified_by     = USERID("HHI")             /* 1dot2 */
                TKR_det.TKR_modified_date   = TODAY
                TKR_det.TKR_prog_name       = THIS-PROCEDURE:FILE-NAME      /* 1dot1 */ 
                TESTS_DETAIL_RCD.Progress_Flag = "DL". /* 1dot1 */      /** update the RS database so we don't re-pull **/
                                                                        /** DL stands for Delete Loaded **/
        
        END.  /**** of else if progress_flag = D --- Delete a record ****/
         
                
        /***************************************************************************************
         * Begin UPDATE section
         ***************************************************************************************/
                 
        ELSE IF (                                                                                          /* 1dot4 */
                 (TESTS_DETAIL_RCD.Progress_Flag = "U" AND firstrun = NO) OR                               /* 1dot4 */
                 ((TESTS_DETAIL_RCD.Progress_Flag = "A" OR TESTS_DETAIL_RCD.Progress_Flag = "") AND        /* 1dot4 */
                  firstrun = YES)                                                                          /* 1dot4 */
                )                                                                                          /* 1dot4 */
                THEN DO:  
                                                                          
            ASSIGN 
                v-testID        = ""
                v-create        = ?
                v-update        = ?
                v-avail         = ?
                v-successful    = ?.                
            
            RUN VALUE(SEARCH("SUBtkrdet-RStP-ucU.r"))
                (v-tkid,
                 v-tkseq,
                 TESTS_DETAIL_RCD.Test_Element_Item,
                 TESTS_DETAIL_RCD.Test_ResultAlph,
                 TESTS_DETAIL_RCD.Test_ResultVal,
                 TESTS_DETAIL_RCD.TestRefInterval,
                 0,                                     /* TKR_ref_low */
                 0,                                     /* TKR_ref_high */
                 "",                                    /* TKR_ref_uom */
                 TESTS_DETAIL_RCD.TestMinusSD,
                 TESTS_DETAIL_RCD.TestMeanSD,
                 TESTS_DETAIL_RCD.TestPlusSD,
                 TESTS_DETAIL_RCD.Lab_Sampleid,         /* TKR__char01 */
                 TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr,  /* TKR__dec01 */
                         OUTPUT v-testID,
                         OUTPUT v-create,
                         OUTPUT v-update,
                         OUTPUT v-avail,
                         OUTPUT v-successful).
 
            IF v-successful = YES THEN DO:
                         
                IF TESTS_DETAIL_RCD.Progress_Flag = "A" THEN 
                    TESTS_DETAIL_RCD.Progress_Flag = "AL".   
                ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "" THEN
                    TESTS_DETAIL_RCD.Progress_Flag = "IL".
                ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "U" THEN
                    TESTS_DETAIL_RCD.Progress_Flag = "UL".
                    
            END.  /** of if v-successful = yes **/ 
                
        END. /** if progress_flag = U **/
                
        ELSE DO: 
    
            EXPORT STREAM outward DELIMITER ";"
                TESTS_DETAIL_RCD.PatientID                               /* 1dot1 */
                TESTS_DETAIL_RCD.Lab_Sampleid                            /* 1dot1 */
                TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr                     /* 1dot1 */
                TESTS_DETAIL_RCD.Progress_Flag                           /* 1dot1 */
                "ERROR 999!  Something UNEXPECTED happened.".      /* yet ironically I coded for it */
            
            ASSIGN ERROR-count[5] = ERROR-count[5]  + 1.                    /* 1dot1 */ 
            
            /* if this condition occured you should check the loadlist variable and */
            /* also the Progress_Flag field */

        END.  /*** of else do --- unexpected error! ***/

    END.  /** of if avail tests_result_rcd **/

    ELSE DO:            /* some sort of orphan */
        
        EXPORT STREAM outward DELIMITER ";"
            TESTS_DETAIL_RCD.PatientID
            TESTS_DETAIL_RCD.Lab_Sampleid
            TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr
            TESTS_DETAIL_RCD.Test_Abbv
            TESTS_DETAIL_RCD.Test_Element_Item
            TESTS_DETAIL_RCD.Progress_Flag
            "ERROR 7! Testkit result is an orphan. NEXT.".
            
        ASSIGN ERROR-count[7] = ERROR-count[7]  + 1.   
    
        NEXT main-block.
        
    END.  /** of else do -- not avail tests_result_rcd **/
    
END.  /** of 4ea. tests_detail_rcd --- main-block **/

EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Records Processed".
EXPORT STREAM outward DELIMITER ";"
    childcount "Records from TESTS_DETAIL_RCD".
EXPORT STREAM outward DELIMITER ";"
    parentcount "Records from TESTS_RESULT_RCD".
    
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
    ERROR-count[1] "ERROR 1! TESTS_DETAIL_RCD not found in the TK_mstr.".       /* 1dot1 */
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
    ERROR-count[2] "ERROR 2! TESTS_DETAIL_RCD already exists in TKR_det.".      /* 1dot1 */
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
    ERROR-count[3] "ERROR 3! TESTS_DETAIL_RCD already deleted from TKR_det.".   /* 1dot1 */   
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
    ERROR-count[4] "ERROR 4! TESTS_DETAIL_RCD not found in TKR_det to update.". /* 1dot1 */ 
EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
    ERROR-count[5] "ERROR 999!  Something UNEXPECTED happened.".                  /* 1dot1 */  

EXPORT STREAM outward DELIMITER ";"                                             /* 2dot2 */              
    ERROR-count[6] "ERROR 6! Add TESTS_DETAIL_RCD failed.".                /* 2dot2 */
EXPORT STREAM outward DELIMITER ";"                                             /* 2dot2 */              
    ERROR-count[7] "ERROR 7! Testkit result is an orphan. NEXT.".                /* 2dot2 */    
EXPORT STREAM outward DELIMITER ";"                                             /* 2dot2 */              
    ERROR-count[10] "ERROR 10! Blank Test_Kit_Nbr in  NEXT.".                /* 2dot2 */
EXPORT STREAM outward DELIMITER ";"                                             /* 2dot2 */
    ERROR-count[11] "ERROR 11! Add new TKR_det really failed.".                 /* 2dot2 */
    
OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).


/*************************  END OF FILE  **************************/
