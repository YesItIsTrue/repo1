   
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
                  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/** specific to this program **/   

DEFINE VARIABLE childcount AS INTEGER NO-UNDO.
DEFINE VARIABLE parentcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-tk_test_seq LIKE TK_mstr.tk_test_seq NO-UNDO.                                                 /* 2dot1 */

/** useful for all RSTP code **/
DEFINE VARIABLE tester           AS CHARACTER INITIAL NO NO-UNDO. 
DEFINE VARIABLE firstrun         AS LOGICAL   INITIAL NO NO-UNDO.                   /* change to YES for the second program */
DEFINE VARIABLE loadedlist       AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER   NO-UNDO.    
    
DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 5 NO-UNDO.                        /* 1dot1 */

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

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.          

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

{emailaddr-USERID.i}. 

/* ***************************  Main Block  *************************** */
for-each_loop:
FOR EACH TESTS_DETAIL_RCD WHERE LOOKUP(TESTS_DETAIL_RCD.Progress_Flag,loadedlist) = 0 EXCLUSIVE-LOCK :        /* 1dot1 */

    childcount = childcount + 1.

    IF tester = "YES" THEN
        IF recordsprocessed = 100 THEN LEAVE for-each_loop.

    recordsprocessed = recordsprocessed + 1.
    
    /**** begin 2dot1 ****/
    FIND FIRST TESTS_RESULT_RCD WHERE TESTS_RESULT_RCD.PatientID = TESTS_DETAIL_RCD.PatientID AND 
        TESTS_RESULT_RCD.lab_sampleid = TESTS_DETAIL_RCD.Lab_Sampleid AND 
        TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr AND 
        TESTS_RESULT_RCD.Test_Abbv = TESTS_DETAIL_RCD.Test_Abbv 
            NO-LOCK NO-ERROR.
             
             /**** Commented out during 2dot1 ****
    FOR EACH TESTS_RESULT_RCD WHERE TESTS_RESULT_RCD.PatientID = TESTS_DETAIL_RCD.PatientID AND          /* 1dot1 */
                         TESTS_RESULT_RCD.Lab_Sampleid = TESTS_DETAIL_RCD.Lab_Sampleid AND                  /* 1dot1 */
                         TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr AND    /* 1dot1 */
                         TESTS_RESULT_RCD.Test_Abbv = TESTS_DETAIL_RCD.Test_Abbv                            /* 1dot1 */
        EXCLUSIVE-LOCK : 
           
    parentcount = parentcount + 1.    
             **** end of 2dot1 comment ******/
             
    /****  End of 2dot1 *****/

    IF AVAILABLE (tests_result_rcd) THEN DO: 
        
        FIND FIRST  TK_mstr WHERE TK_mstr.TK_patient_ID = INTEGER(TESTS_DETAIL_RCD.PatientID) AND               /* 1dot1 */             
            TK_mstr.TK_lab_sample_ID = TESTS_DETAIL_RCD.Lab_Sampleid AND                                /* 1dot1 */ 
            TK_mstr.TK_lab_seq =  INTEGER(TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr) AND                     /* 1dot1 */ 
            TK_mstr.TK_test_type = TESTS_DETAIL_RCD.Test_Abbv  AND                                      /* 2dot0 */ 
            TK_mstr.TK_ID = TESTS_RESULT_RCD.Test_Kit_Nbr                                               /* 1dot1 */ 
                USE-INDEX TK-old-idx                                                                            /* 2dot0 */ 
                NO-LOCK NO-ERROR.                                                                               /* 1dot1 */                 
             
        IF NOT AVAILABLE (TK_mstr) THEN
                
            FIND LAST TK_mstr WHERE                                                 /* 1dot4 */                                   
                TK_mstr.TK_ID = TESTS_RESULT_RCD.Test_Kit_Nbr                /* 1dot4 */  
                    NO-LOCK NO-ERROR.                                                  /* 1dot4 */ 

        IF NOT AVAILABLE (TK_mstr) THEN DO:
            
            EXPORT STREAM outward DELIMITER ";"
                TESTS_DETAIL_RCD.PatientID                                   /* 1dot1 */
                TESTS_DETAIL_RCD.Lab_Sampleid                                /* 1dot1 */
                TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr                         /* 1dot1 */
                TESTS_DETAIL_RCD.Test_Element_Item                           /* 1dot1 */
                TESTS_DETAIL_RCD.Progress_Flag                               /* 1dot1 */
                "ERROR 1! TESTS_DETAIL_RCD not found in the TK_mstr.".
            
            ASSIGN ERROR-count[1] = ERROR-count[1]  + 1.                        /* 1dot1 */  
                  
        END. /*** not avail TK_mstr ***/            

        ELSE DO:
    
            /*****************************************************************************************
             *  Begin ADD section
             *****************************************************************************************/
    
            IF ((TESTS_DETAIL_RCD.Progress_Flag = "" OR                                                                  /* 1dot4 */
                 TESTS_DETAIL_RCD.Progress_Flag = "A") AND firstrun = NO) OR                           /* 1dot1 */         /* 1dot4 */
                (firstrun = YES AND TESTS_DETAIL_RCD.Progress_Flag = "U") THEN   /* 1dot1 */ 
            DO:                                                                                          /* this line is for the initial load only */             
                
                FIND TKR_det WHERE TKR_det.TKR_ID = TK_mstr.TK_ID  AND
                                   TKR_det.TKR_test_seq = TK_mstr.TK_test_seq AND 
                                   TKR_det.TKR_item = TESTS_DETAIL_RCD.Test_Element_Item 
                                   AND
                                   TKR_det.TKR_deleted = ?
                    NO-LOCK NO-ERROR.
                    
                IF AVAILABLE (TKR_det) THEN DO:  
                        
                    EXPORT STREAM outward DELIMITER ";"
                        TK_mstr.TK_ID                                               /* 1dot1 */
                        TK_mstr.TK_test_seq                                         /* 1dot1 */
                        TESTS_DETAIL_RCD.Test_Element_Item                       /* 1dot1 */
                        TESTS_DETAIL_RCD.PatientID                               /* 1dot2 */
                        TESTS_DETAIL_RCD.Lab_Sampleid                            /* 1dot2 */
                        TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr                     /* 1dot2 */
                        TESTS_DETAIL_RCD.Progress_Flag                           /* 1dot1 */
                        TESTS_DETAIL_RCD.Test_Abbv
                        "ERROR 2! TESTS_DETAIL_RCD already exists in TKR_det for an input ADD.".
                        
                    ASSIGN ERROR-count[2] = ERROR-count[2]  + 1
                        TESTS_DETAIL_RCD.Progress_Flag = IF TESTS_DETAIL_RCD.Progress_Flag = "A" THEN      /* 1dot2 */
                                                        "AL"                                                        /* 1dot2 */     
                                                      ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "U" THEN          /* 1dot2 */
                                                        "UL"                                                        /* 1dot2 */
                                                      ELSE                                                          /* 1dot2 */ 
                                                        "IL".                                                       /* 1dot2 */         
                END.  /** of if avail att_files --- error, already exists **/
            
                ELSE DO:        /** normal condition for a blank or A record --- Add the record **/
    
                    CREATE TKR_det.
                        
                    ASSIGN 
                        TK_mstr.TK_lab_sample_ID    = TESTS_DETAIL_RCD.Lab_Sampleid
                        TK_mstr.TK_lab_seq          = TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr
                        TKR_det.TKR_ID              = TK_mstr.TK_ID
                        TKR_det.TKR_test_seq        = TK_mstr.TK_test_seq
                        TKR_det.TKR_item            = TESTS_DETAIL_RCD.Test_Element_Item
                        TKR_det.TKR_lab_result      = TESTS_DETAIL_RCD.Test_ResultAlph
                        TKR_det.TKR_lab_resval      = TESTS_DETAIL_RCD.Test_ResultVal
                        TKR_det.TKR_lab_ref         = TESTS_DETAIL_RCD.TestRefInterval
                        TKR_det.TKR_minusSD         = TESTS_DETAIL_RCD.TestMinusSD
                        TKR_det.TKR_meanSD          = TESTS_DETAIL_RCD.TestMeanSD
                        TKR_det.TKR_plusSD          = TESTS_DETAIL_RCD.TestPlusSD
                        TKR_det.TKR_created_by      = USERID("HHI")                 /* 1dot2 */
                        TKR_det.TKR_create_date     = TODAY         /* TK_mstr.TK_create_date  */        /* 1dot2 */
                        TKR_det.TKR_modified_by     = USERID("HHI")                 /* 1dot2 */
                        TKR_det.TKR_modified_date   = TODAY         /* TK_mstr.TK_modified_date  */        /* 1dot2 */
                        TKR_det.TKR_prog_name       = THIS-PROCEDURE:FILE-NAME      /* 1dot1 */
                        TESTS_DETAIL_RCD.Progress_Flag = IF TESTS_DETAIL_RCD.Progress_Flag = "A" THEN         /* 1dot1 */
                                                        "AL"      /** update the RS database so we don't re-pull --- stands for Add Loaded **/
                                                      ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "U" THEN          /* 1dot1 */
                                                        "UL"
                                                      ELSE 
                                                        "IL".     /** update the RS database so we don't re-pull --- stands for Import Loaded **/
                
                END. /** of else do --- not avail TKR_det --- normal condition **/
            
            END.  /*** of progress_flag = blank or A --- create a record ***/
            
            /*****************************************************************************************
             *  Begin DELETE section
             *****************************************************************************************/            
            
            ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "D" THEN  DO:
                     
                FIND TKR_det WHERE TKR_det.TKR_ID = TK_mstr.TK_ID  AND
                    TKR_det.TKR_test_seq = TK_mstr.TK_test_seq AND 
                    TKR_det.TKR_item = TESTS_DETAIL_RCD.Test_Element_Item AND 
                    TKR_det.TKR_deleted = ? 
                        EXCLUSIVE-LOCK NO-ERROR.
     
                IF NOT AVAILABLE (TKR_det) THEN DO:  
            
                    EXPORT STREAM outward DELIMITER ";"
                        TK_mstr.TK_ID                                               /* 1dot1 */
                        TK_mstr.TK_test_seq                                         /* 1dot1 */
                        TESTS_DETAIL_RCD.Test_Element_Item                       /* 1dot1 */
                        TESTS_DETAIL_RCD.PatientID                               /* 1dot2 */
                        TESTS_DETAIL_RCD.Lab_Sampleid                            /* 1dot2 */
                        TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr                     /* 1dot2 */
                        TESTS_DETAIL_RCD.Progress_Flag                           /* 1dot1 */
                        "ERROR 3! TESTS_DETAIL_RCD already deleted from TKR_det.".
                        
                    ASSIGN ERROR-count[3] = ERROR-count[3]  + 1.                    /* 1dot1 */ 
                    
                END.  /** of if not avail att_files --- error, already missing **/
        
                ELSE DO:        /** normal condition for a D record --- Delete the record **/
    
                    /** DELETE att_files. ******  just kidding, we don't delete this way ****/
                
                    ASSIGN
                        TKR_det.TKR_deleted         = TODAY 
                        TKR_det.TKR_modified_by     = USERID("HHI")             /* 1dot2 */
                        TKR_det.TKR_modified_date   = TODAY
                        TKR_det.TKR_prog_name       = THIS-PROCEDURE:FILE-NAME      /* 1dot1 */ 
                        TESTS_DETAIL_RCD.Progress_Flag = "DL".                   /* 1dot1 */     /** update the RS database so we don't re-pull --- stands for Delete Loaded **/
    
                END.  /*** of else do --- avail att_files --- normal condition ***/
                
            END.  /**** of else if progress_flag = D --- Delete a record ****/
             
                    
            /***************************************************************************************
             * Begin UPDATE section
             ***************************************************************************************/
                     
            ELSE IF (                                                                                                           /* 1dot4 */
                     (TESTS_DETAIL_RCD.Progress_Flag = "U" AND firstrun = NO) OR                                             /* 1dot4 */
                     ((TESTS_DETAIL_RCD.Progress_Flag = "A" OR TESTS_DETAIL_RCD.Progress_Flag = "") AND                         /* 1dot4 */
                      firstrun = YES)                                                                                           /* 1dot4 */
                    )                                                                                                           /* 1dot4 */
                    THEN DO:  
                                                                              
                FIND TKR_det WHERE TKR_det.TKR_ID = TK_mstr.TK_ID  AND
                    TKR_det.TKR_test_seq = TK_mstr.TK_test_seq AND 
                    TKR_det.TKR_item = TESTS_DETAIL_RCD.Test_Element_Item AND 
                    TKR_det.TKR_deleted = ? 
                        EXCLUSIVE-LOCK NO-ERROR.
                
                IF NOT AVAILABLE (TKR_det) THEN DO:  
        
                    EXPORT STREAM outward DELIMITER ";"
                        TK_mstr.TK_ID                                               /* 1dot1 */
                        TK_mstr.TK_test_seq                                         /* 1dot1 */
                        TESTS_DETAIL_RCD.Test_Element_Item                       /* 1dot1 */
                        TESTS_DETAIL_RCD.PatientID                               /* 1dot2 */
                        TESTS_DETAIL_RCD.Lab_Sampleid                            /* 1dot2 */
                        TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr                     /* 1dot2 */
                        TESTS_DETAIL_RCD.Progress_Flag                           /* 1dot1 */
                        "ERROR 4! TESTS_DETAIL_RCD not found in TKR_det to update.".
                    ASSIGN ERROR-count[4] = ERROR-count[4]  + 1.                    /* 1dot1 */ 
    /*                        ASSIGN TESTS_DETAIL_RCD.Progress_Flag = "UL".                /* 1dot2 */*/
                END.  /** of if not avail att_files --- error, record missing **/
    
                ELSE DO:        /** normal condition for a U record --- Update the record **/
        
                    ASSIGN 
                        TK_mstr.TK_lab_sample_ID    = TESTS_DETAIL_RCD.Lab_Sampleid
                        TK_mstr.TK_lab_seq          = TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr
                        TKR_det.TKR_lab_result      = TESTS_DETAIL_RCD.Test_ResultAlph
                        TKR_det.TKR_lab_resval      = TESTS_DETAIL_RCD.Test_ResultVal
                        TKR_det.TKR_lab_ref         = TESTS_DETAIL_RCD.TestRefInterval
                        TKR_det.TKR_minusSD         = TESTS_DETAIL_RCD.TestMinusSD
                        TKR_det.TKR_meanSD          = TESTS_DETAIL_RCD.TestMeanSD
                        TKR_det.TKR_plusSD          = TESTS_DETAIL_RCD.TestPlusSD
                        TKR_det.TKR_modified_by     = USERID("HHI")                                 /* 1dot2 */
                        TKR_det.TKR_modified_date   = TODAY     /* TK_mstr.TK_modified_date  */     /* 1dot2 */
                        TKR_det.TKR_prog_name       = THIS-PROCEDURE:FILE-NAME      /* 1dot1 */                    
                        TESTS_DETAIL_RCD.Progress_Flag = IF TESTS_DETAIL_RCD.Progress_Flag = "A" THEN         /* 1dot4 */
                                                "AL"                                                                /* 1dot4 */     
                                              ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "U" THEN                  /* 1dot4 */
                                                "UL"                                                                /* 1dot4 */
                                              ELSE                                                                  /* 1dot4 */ 
                                                "IL".                                                               /* 1dot4 */
          
                END. /** of else do --- avail att_files --- normal condition ***/
            
    /*            END.  /*** of else if progress_flag = U --- Update a record ***/*/
                        
            END. /** if avail MPA_Rcd **/
                    
            ELSE DO: 
        
                EXPORT STREAM outward DELIMITER ";"
                    TESTS_DETAIL_RCD.PatientID                               /* 1dot1 */
                    TESTS_DETAIL_RCD.Lab_Sampleid                            /* 1dot1 */
                    TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr                     /* 1dot1 */
                    TESTS_DETAIL_RCD.Progress_Flag                           /* 1dot1 */
                    "ERROR 5!  Something UNEXPECTED happened.".      /* yet ironically I coded for it */
                ASSIGN ERROR-count[5] = ERROR-count[5]  + 1.                    /* 1dot1 */ 
            /* if this condition occured you should check the loadlist variable and also the Progress_Flag field */
    
            END.  /*** of else do --- unexpected error! ***/
                    
        END. /** else do found in tk_mstr **/ 
    END.  /** of 4ea. patient_files **/
END.  /** of 4ea. tests_detail_rcd --- for-each_loop **/
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
    ERROR-count[5] "ERROR 5!  Something UNEXPECTED happened.".                  /* 1dot1 */    
    
OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).


/*************************  END OF FILE  **************************/
