/*------------------------------------------------------------------------
    File        : RSTP_MPA_Test_details_RCD-U-1.p
    Purpose     : 

    Syntax      :

    Description : Migrate the MPA_TEST_DETAILS_RCD in the RS database to the
                    BMPA_det table in the HHI database.
                    Designed to be run repeatedly in batch.

    Author(s)   : Jacob Luttrell
    Created     : Thu Dec 24 20:19:30 EST 2014
    Notes       :

  ----------------------------------------------------------------------
  Revision History:        
  -----------------
  1.0 - written by R.J. Luttrell on 24/Dec/14.  Original version.
  1.1 - written by Doug Luttrell during the go-live migration.  Modified searches
        to find the correct records.
  1.2 - By Harold Luttrell on 2513/Jul/15.
        a.  Added more output data displays for the error log report. 
        b.  Removed the preprocessor references to 
            {&this-table}, which was pointing at MPA_TEST_DETAILS_RCD.
            I did NOT marked this change because there was so many of them I
            didn't want to make the code look junkie. 
        c.  Modified the FIND TK_mstr code - added the FIRST verb and 
            added the new index.
        d.  Added the THIS-PROCEDURE:FILE-NAME assign to xxx_prog_name.
        e.  Added total count for each ERROR! message.
            Marked by 1dot2.    
   1.3 - written by DOUG LUTTRELL on 08/Oct/15.  Modified to treat A's similar to U's
            but reverse.  Marked by 1dot3.
   
   Version: 2.0    By Harold Luttrell, Sr.
   Date: 8/Mar/16.
   Description:    Removed the FIND statements for the TK_mstr and modified 
                    code to process only the TKR_det and BMPA_det records.                    
   Identified by /* 2dot0 */  
                                 
    2.1 - written by DOUG LUTTRELL on 25/May/16.  Something is awry with this program.
            It seems to be flagging records as loaded that aren't.  Marked by 2dot1.
                                         
    2.2  - written by DOUG LUTTRELL on 01/Jun/16.  Totally revamping the way we
            handle old testkit IDs and testkit Sequences.  Old ones will now be a 
            concatenantion of the old testkit ID, the test type, and the letters
            "OAH" which stands for Old As Heck.  This also changes the way this 
            program does FINDs.  All the finding and creating is done up front
            and then the updating is done down below.  Commented out large swaths
            of code which often did not get marked, though it may be marked by 2dot2.
            See also RStP-TESTS_RESULT_RCD-U-1.p.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/** useful for all RSTP code **/
DEFINE VARIABLE limitrun AS INTEGER INITIAL 0 NO-UNDO.                          /** a non-zero number will limit processing to that many records **/
DEFINE VARIABLE firstrun AS LOGICAL INITIAL NO NO-UNDO.     /* change to YES for run number 2 */

DEFINE VARIABLE v-tkid LIKE TKR_det.TKR_ID NO-UNDO.                             /* 2dot2 */                                                    /* 2dot2 */
DEFINE VARIABLE v-tkseq LIKE TKR_det.TKR_test_seq NO-UNDO.                      /* 2dot2 */

DEFINE VARIABLE v-testID LIKE TK_mstr.TK_ID NO-UNDO. 
DEFINE VARIABLE v-create AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-update AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-avail AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-successful AS LOGICAL NO-UNDO. 

DEFINE VARIABLE testpref AS CHARACTER NO-UNDO.                                                          /* 1dot6 */
DEFINE VARIABLE v-testprefix LIKE TK_mstr.TK_test_type NO-UNDO.                 /* 2dot0 */

DEFINE VARIABLE starting-position AS INTEGER NO-UNDO.                           /* 2dot0 */                      
DEFINE VARIABLE h-pgm-name AS CHARACTER FORMAT "x(60)" NO-UNDO.                 /* 2dot0 */

DEFINE VARIABLE loadedlist       AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER   NO-UNDO.    

DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 20 NO-UNDO.                        /* 1dot2 */
DEFINE VARIABLE v-trhid          LIKE trh_hist.trh_ID            NO-UNDO.       /* 2dot0 */
 
DEFINE VARIABLE cmdname          AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe" NO-UNDO.
DEFINE VARIABLE emailaddr        AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"       NO-UNDO.
DEFINE VARIABLE messagetxt       AS CHARACTER INITIAL "-m Error Report attached from "           NO-UNDO.
DEFINE VARIABLE subjtxt          AS CHARACTER INITIAL "-s Error Report from "                    NO-UNDO.
DEFINE VARIABLE cmdparams        AS CHARACTER INITIAL "-a"                                       NO-UNDO.
 
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
    INITIAL "C:\PROGRESS\WRK\RStP-MPA_TEST_DETAILS_RCD-U-log-1.txt" NO-UNDO.    /* change -1 to -2 for run number 2. */

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "PatientID" 
    "MPA_Sample_ID_Number" 
    "MPA_Sample_ID_SeqNbr" 
    "MPA_SNP_ID" 
    "Progress_Flag"
    "Test Kit ID"
    "Error Message".


/* ********************  Preprocessor Definitions  ******************** */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.              

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).              

{emailaddr-USERID.i}.

/* ***************************  Main Block  *************************** */

main-block:    
FOR EACH MPA_TEST_DETAILS_RCD WHERE LOOKUP(MPA_TEST_DETAILS_RCD.Progress_Flag,loadedlist) = 0: 

    IF (limitrun > 0) AND (recordsprocessed > limitrun) THEN 
        LEAVE main-block.

    recordsprocessed = recordsprocessed + 1.
        
    FIND FIRST MPA_RCD WHERE MPA_RCD.PatientID        = MPA_TEST_DETAILS_RCD.PatientID AND               /* 2dot0 */         
                      MPA_RCD.MPA_Sample_ID_Number    = MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number AND    /* 2dot0 */
                      MPA_RCD.MPA_Sample_ID_SeqNbr    = MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr        /* 2dot0 */
        NO-LOCK NO-ERROR.                                                                                       /* 2dot0 */  
    
    IF AVAILABLE (mpa_rcd) THEN DO: 

        ASSIGN 
            testpref    = CAPS(SUBSTRING(MPA_RCD.MPA_Test_Kit_nbr,1,INDEX(MPA_RCD.MPA_Test_Kit_nbr,"-") - 1)).
                
        FIND test_mstr WHERE test_mstr.test_type = testpref AND 
            test_mstr.test_deleted = ?                                                                  /* 2dot1 */
                NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE (test_mstr) THEN DO: 
            
            EXPORT STREAM outward DELIMITER ";"
                MPA_TEST_DETAILS_RCD.PatientID
                MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number
                MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr
                MPA_TEST_DETAILS_RCD.MPA_SNP_ID
                MPA_TEST_DETAILS_RCD.progress_flag
                MPA_RCD.MPA_Test_Kit_Nbr
                "WARNING 12! No test_mstr found for test type.".
                
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
                "ERROR 10! Blank Test_Kit_Nbr in  NEXT.".
                
            ASSIGN ERROR-count[10] = ERROR-count[10]  + 1.   
        
            NEXT main-block.           
            
        END.  /** of mpa_test_kit_nbr = "" **/
        
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
            
        END.  /** of else do --- mpa_test_kit_nbr <> "" **/
        
        FIND TKR_det WHERE TKR_det.TKR_ID = v-tkid AND 
            TKR_det.TKR_test_seq = v-tkseq AND 
            TKR_det.TKR_item = MPA_TEST_DETAILS_RCD.MPA_SNP_ID AND  
            TKR_det.TKR_deleted = ? 
                EXCLUSIVE-LOCK NO-ERROR.
                
        IF NOT AVAILABLE (tkr_det) THEN DO: 
            
            FIND TKR_det WHERE TKR_det.TKR_ID = v-tkid AND 
                TKR_det.TKR_test_seq = v-tkseq AND 
                TKR_det.TKR_item = MPA_TEST_DETAILS_RCD.MPA_SNP_ID
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
                     MPA_TEST_DETAILS_RCD.MPA_SNP_ID,               /* TKR_item */
                     MPA_TEST_DETAILS_RCD.MPA_Call,                 /* TKR_lab_result */
                     0,                                             /* TKR_lab_resval */
                     "",                                            /* TKR_lab_ref */
                     0,                                             /* TKR_ref_low */
                     0,                                             /* TKR_ref_high */
                     "",                                            /* TKR_ref_uom */
                     "",                                            /* TKR_minusSD */
                     "",                                            /* TKR_meanSD */
                     "",                                            /* TKR_plusSD */
                     MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number,     /* TKR__char01 */
                     MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr,     /* TKR__dec01 */
                     OUTPUT v-testID,
                     OUTPUT v-create,
                     OUTPUT v-update,
                     OUTPUT v-avail,
                     OUTPUT v-successful).
                     
                         
                IF v-successful = NO OR v-successful = ? THEN DO:                                       /* 1dot4 */
                    
                    EXPORT STREAM outward DELIMITER ";"
                        MPA_TEST_DETAILS_RCD.PatientID                                   /* 1dot1 */
                        MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number                                /* 1dot1 */
                        MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr                         /* 1dot1 */
                        MPA_TEST_DETAILS_RCD.MPA_SNP_ID                           /* 1dot1 */
                        MPA_TEST_DETAILS_RCD.Progress_Flag                               /* 1dot1 */
                        "ERROR 6! Add TESTS_DETAIL_RCD failed.".
                    
                    ASSIGN ERROR-count[6] = ERROR-count[6]  + 1.                        /* 1dot1 */                            
                    
                END.  /* IF v-successful = no */                                    /* 1dot4 */  
                
                ELSE DO: 
                    
                    FIND TKR_det WHERE TKR_det.TKR_ID = v-tkid AND 
                        TKR_det.TKR_test_seq = v-tkseq AND 
                        TKR_det.TKR_item = MPA_TEST_DETAILS_RCD.MPA_SNP_ID AND  
                        TKR_det.TKR_deleted = ? 
                            EXCLUSIVE-LOCK NO-ERROR.
                                
                    IF NOT AVAILABLE (TKR_det) THEN DO: 
                        
                        EXPORT STREAM outward DELIMITER ";"
                            MPA_TEST_DETAILS_RCD.PatientID                                   /* 1dot1 */
                            MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number                                /* 1dot1 */
                            MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr                         /* 1dot1 */
                            MPA_TEST_DETAILS_RCD.MPA_SNP_ID                           /* 1dot1 */
                            MPA_TEST_DETAILS_RCD.Progress_Flag                               /* 1dot1 */
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

        FIND BMPA_det WHERE 
            BMPA_det.BMPA_ID          = TKR_det.tkr_id AND 
            BMPA_det.BMPA_test_seq    = TKR_det.tkr_test_seq AND 
            BMPA_det.BMPA_item        = TKR_det.TKR_item  
            /* commented out because we're not going to manage this table
                without the TKR_det.  Thus, it doesn't matter if the TKR_det
                is deleted or not. 
            BMPA_det.BMPA_deleted       = ?
            */
                EXCLUSIVE-LOCK NO-ERROR. 
                
        IF NOT AVAILABLE (BMPA_det) THEN DO: 

            CREATE BMPA_det.
            
            ASSIGN 
                BMPA_det.BMPA_ID            = v-tkid
                BMPA_det.BMPA_test_seq      = v-tkseq
                BMPA_det.BMPA_item          = MPA_TEST_DETAILS_RCD.MPA_SNP_ID                   
                BMPA_det.BMPA_create_date   = TODAY
                BMPA_det.BMPA_created_by    = USERID("HHI").
                                                      
        END.  /** IF NOT AVAILABLE  (BMPA_det) **/            
                                                                      
        ASSIGN 
            BMPA_det.BMPA_dispcall      = MPA_TEST_DETAILS_RCD.MPA_Display_Call
            BMPA_det.BMPA_modified_date = TODAY 
            BMPA_det.BMPA_modified_by   = USERID("HHI")
            BMPA_det.BMPA_prog_name     = THIS-PROCEDURE:FILE-NAME. 
            
/****************************************************************************************
 *  Begin ADD Section
 ****************************************************************************************/     
        IF ((MPA_TEST_DETAILS_RCD.Progress_Flag = "" OR                                   /* 1dot3 */
                  MPA_TEST_DETAILS_RCD.Progress_Flag = "A") AND firstrun = NO) OR                     /* 1dot3 */
                (firstrun = YES AND MPA_TEST_DETAILS_RCD.Progress_Flag = "U") THEN DO:              /* this line is for the initial load only */       

            ASSIGN 
                v-testID        = ""
                v-create        = ?
                v-update        = ?
                v-avail         = ?
                v-successful    = ?.                
            
            RUN VALUE(SEARCH("SUBtkrdet-RStP-ucU.r"))
                (v-tkid,
                 v-tkseq, 
                 MPA_TEST_DETAILS_RCD.MPA_SNP_ID,               /* TKR_item */
                 MPA_TEST_DETAILS_RCD.MPA_Call,                 /* TKR_lab_result */
                 0,                                             /* TKR_lab_resval */
                 "",                                            /* TKR_lab_ref */
                 0,                                             /* TKR_ref_low */
                 0,                                             /* TKR_ref_high */
                 "",                                            /* TKR_ref_uom */
                 "",                                            /* TKR_minusSD */
                 "",                                            /* TKR_meanSD */
                 "",                                            /* TKR_plusSD */
                 MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number,     /* TKR__char01 */
                 MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr,     /* TKR__dec01 */
                 OUTPUT v-testID,
                 OUTPUT v-create,
                 OUTPUT v-update,
                 OUTPUT v-avail,
                 OUTPUT v-successful).
 
            IF v-successful = YES THEN DO:
                         
                IF MPA_TEST_DETAILS_RCD.Progress_Flag = "A" THEN 
                    MPA_TEST_DETAILS_RCD.Progress_Flag = "AL".   
                ELSE IF MPA_TEST_DETAILS_RCD.Progress_Flag = "" THEN
                    MPA_TEST_DETAILS_RCD.Progress_Flag = "IL".
                ELSE IF MPA_TEST_DETAILS_RCD.Progress_Flag = "U" THEN
                    MPA_TEST_DETAILS_RCD.Progress_Flag = "UL".
                    
            END.  /** of if v-successful = yes **/  
                    
        END.  /*** of progress_flag = blank or A --- create a record ***/
        
/**************************************************************************************
 *  Begin DELETE section 
 **************************************************************************************/   
        ELSE IF MPA_TEST_DETAILS_RCD.Progress_Flag = "D" THEN DO: 

            IF  AVAILABLE (TKR_det) THEN DO:    
                       
                ASSIGN
                    TKR_det.TKR_deleted         = TODAY 
                    TKR_det.TKR_modified_by     = USERID("HHI")
                    TKR_det.TKR_modified_date   = TODAY 
                    TKR_det.TKR_prog_name       = THIS-PROCEDURE:FILE-NAME.
                    
            END.  /*** IF AVAILABLE (TKR_det) ***/

/*  Commented out because we're not going to manage the BMPA_det without the TKR_det.   */
/*  Thus, it doesn't matter if the TKR_det is deleted or not.                           */
     
/*            IF  AVAILABLE (BMPA_det) THEN DO:                                */
/*                ASSIGN                                                       */
/*                    BMPA_det.BMPA_deleted         = TODAY                    */
/*                    BMPA_det.BMPA_modified_by     = USERID("HHI")            */
/*                    BMPA_det.BMPA_modified_date   = TODAY                    */
/*                    BMPA_det.BMPA_prog_name       = THIS-PROCEDURE:FILE-NAME.*/
/*            END.  /*** IF AVAILABLE (BMPA_det) ***/                          */
    
            IF AVAILABLE (TKR_det) AND AVAILABLE (BMPA_det) THEN
                ASSIGN MPA_TEST_DETAILS_RCD.Progress_Flag = "DL".       /** update the RS database so we don't re-pull --- stands for Delete Loaded **/       
                
        END.  /**** of  if progress_flag = D --- Delete a record ****/

/********************************************************************************
 *  Begin UPDATE section
 ********************************************************************************/            
        ELSE IF (MPA_TEST_DETAILS_RCD.Progress_Flag = "U" AND firstrun = NO) OR 
                ((MPA_TEST_DETAILS_RCD.Progress_Flag = "A" OR 
                  MPA_TEST_DETAILS_RCD.Progress_Flag = "") AND              /* 1dot3 */
                 firstrun = YES) THEN DO:                                                        
    
            IF AVAILABLE (TKR_det) THEN DO: 
                
                ASSIGN 
                    v-testID        = ""
                    v-create        = ?
                    v-update        = ?
                    v-avail         = ?
                    v-successful    = ?.                
                
                RUN VALUE(SEARCH("SUBtkrdet-RStP-ucU.r"))
                    (v-tkid,
                     v-tkseq, 
                     MPA_TEST_DETAILS_RCD.MPA_SNP_ID,               /* TKR_item */
                     MPA_TEST_DETAILS_RCD.MPA_Call,                 /* TKR_lab_result */
                     0,                                             /* TKR_lab_resval */
                     "",                                            /* TKR_lab_ref */
                     0,                                             /* TKR_ref_low */
                     0,                                             /* TKR_ref_high */
                     "",                                            /* TKR_ref_uom */
                     "",                                            /* TKR_minusSD */
                     "",                                            /* TKR_meanSD */
                     "",                                            /* TKR_plusSD */
                     MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number,     /* TKR__char01 */
                     MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr,     /* TKR__dec01 */
                     OUTPUT v-testID,
                     OUTPUT v-create,
                     OUTPUT v-update,
                     OUTPUT v-avail,
                     OUTPUT v-successful).
        
                IF AVAILABLE (BMPA_det) THEN     
                    ASSIGN 
                        BMPA_det.BMPA_dispcall      = MPA_TEST_DETAILS_RCD.MPA_Display_Call
                        BMPA_det.BMPA_modified_date = TODAY
                        BMPA_det.BMPA_modified_by   = USERID("HHI")
                        BMPA_det.BMPA_prog_name     = THIS-PROCEDURE:FILE-NAME
                        MPA_TEST_DETAILS_RCD.Progress_Flag  = IF MPA_TEST_DETAILS_RCD.Progress_Flag = "A" THEN    /* 1dot3 */
                                            "AL"      /** stands for Add Loaded **/                                     /* 1dot3 */
                                          ELSE IF MPA_TEST_DETAILS_RCD.Progress_Flag = "U" THEN                      /* 1dot3 */
                                            "UL"    /** stands for Update Loaded **/                                    /* 1dot3 */
                                          ELSE IF MPA_TEST_DETAILS_RCD.Progress_Flag = "I" THEN                                                                         /* 1dot3 */
                                            "IL"     /** stands for Import Loaded **/                                  /* 1dot3 */
                                          ELSE 
                                            MPA_TEST_DETAILS_RCD.Progress_Flag.
        
            END.  /** of if avail tkr_det **/
                        
        END.  /*** of else if progress_flag = U --- Update a record ***/
    
        ELSE DO: 
        
            EXPORT STREAM outward DELIMITER ";"
                MPA_TEST_DETAILS_RCD.PatientID 
                MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number 
                MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr
                MPA_TEST_DETAILS_RCD.MPA_SNP_ID
                MPA_TEST_DETAILS_RCD.progress_flag 
                ""
                "ERROR 999! Something unexpected happened!".
                
            ASSIGN ERROR-count[2] = ERROR-count[2]  + 1.    
            
        END.  /** of else do --- something unexpected happened **/
       
    END.  /** of if avail mpa_rcd **/
        
    ELSE DO:        /** some sort of orphan **/
         
        EXPORT STREAM outward DELIMITER ";"
            MPA_TEST_DETAILS_RCD.PatientID 
            MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number 
            MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr
            MPA_TEST_DETAILS_RCD.MPA_SNP_ID
            MPA_TEST_DETAILS_RCD.progress_flag 
            ""
            "ERROR 1! Teskit result is an orphan.  NEXT.".
            
        ASSIGN ERROR-count[1] = ERROR-count[1]  + 1.                            /* 1dot2 */

        NEXT main-block.                                                     /* 2dot0 */
       
    END. /*** not avail mpa_rcd ***/            
   
END.  /** of 4ea. patient_files **/


EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Records Processed".
 
EXPORT STREAM outward DELIMITER ";"                                                 
    ERROR-count[1] "ERROR 1! Teskit result is an orphan.  NEXT.".       
        
EXPORT STREAM outward DELIMITER ";"                                                 
    ERROR-count[2] "ERROR 999! Something unexpected happened!".        

EXPORT STREAM outward DELIMITER ";"                                                   
    ERROR-count[6] "ERROR 6! Add TESTS_DETAIL_RCD failed.".                         

EXPORT STREAM outward DELIMITER ";"       
    ERROR-count[10] "ERROR 10! Blank Test_Kit_Nbr in  NEXT.".       

EXPORT STREAM outward DELIMITER ";"       
    ERROR-count[11] "ERROR 11! Add new TKR_det really failed.".
           
EXPORT STREAM outward DELIMITER ";"       
    ERROR-count[12] "WARNING 12! No test_mstr found for test type.".       
       
OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).


/*************************  END OF FILE  **************************/
