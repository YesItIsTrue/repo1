
/*------------------------------------------------------------------------
    File        : RSTP-FM-U.p
    Purpose     : 

    Syntax      :

    Description : Migrate the TESTS_FM_SPECIMEN_RCD table to the BF_det table.   /* 1dot1 */
                  Designed to be run repeatedly in batch.

    Author(s)   : Mark Jacobs Using framework provided by Doug Luttrell
    Created     : Thu Dec 23 20:19:30 EST 2014
    Notes       :

  ----------------------------------------------------------------------
  Revision History:        
  -----------------
  1.0 - written by Mark Jacobs  on 23/Dec/14.  Original version.
        Using framework provided by Doug Luttrell
  1.1 - By Harold Luttrell on 14/Jul/15.
        a.  Changed the NO-LOCK verb to the EXCLUSIVE-LOCK verb so fields could
            be updated.  
        b.  Added more output data displays for the error log report.  
        c.  Change the output log file name to: 
                RStP_TESTS_FM_SPECIMEN_RCD-U-log-1.txt.
        d.  Modified the FIND TK_mstr code 
            from: 
                BFM_mstr.BHE_test_seq = integer(TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr) 
            to:
                BFM_mstr.BHE_test_seq = TK_mstr.TK_test_seq.
        e.  Added the THIS-PROCEDURE:FILE-NAME assign to BFM_mstr.BFM_prog_name.
        f.  Added total count for each ERROR! message.
        g.  Removed the preprocessor references to 
            {&this-table}, which was pointing at TESTS_FM_SPECIMEN_RCD.
            Marked by 1dot1.  
          
    Version: 2.0    By Harold Luttrell, Sr.
    Date: 5/Mar/16.
    Description:    Changed database field name from 
                        TK_mstr.TK_testtype to TK_mstr.TK_test_type.                    
    Identified by /* 2dot0 */  
  
  2.1 - written by DOUG LUTTRELL on 02/Jun/16.  The continuing saga of the change in the way we 
            identify the old testkits.  See RStP-TESTS_RESULTS_RCD-U-1.p for more details.  Not 
            really marked due to quantity of changes, but possibly marked by 2dot1.  
                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/** specific to this program **/   
DEFINE VARIABLE tester AS CHARACTER INITIAL NO NO-UNDO.

/** useful for all RSTP code **/
DEFINE VARIABLE firstrun AS LOGICAL INITIAL NO NO-UNDO.    /* change to YES for second program */

DEFINE VARIABLE v-tkid LIKE TK_mstr.TK_ID NO-UNDO.                              /* 2dot1 */
DEFINE VARIABLE v-tkseq LIKE TK_mstr.TK_test_seq NO-UNDO.                       /* 2dot1 */

DEFINE VARIABLE loadedlist AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO.    
   
DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 20 NO-UNDO.                        /* 1dot1 */

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
    
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RStP-TESTS_FM_SPECIMEN_RCD-U-log-1.txt" NO-UNDO.   /* Change to 2 for second program */

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "PatientID"
    "TESTS_RESULT_RCD.Test_Kit_Nbr"                                          /* 1dot1 */ 
    "Lab Sample ID"
    "Lab Sample ID Seq"
    "TESTS_FM_SPECIMEN_RCD.progress_flag"                                    /* 1dot1 */
    "Error Message".


/* ********************  Preprocessor Definitions  ******************** */
/*&SCOPED-DEFINE this-table   TESTS_FM_SPECIMEN_RCD*/                           /* 1dot1 */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.        
DEFINE VARIABLE codetorun AS CHARACTER  FORMAT "x(80)" NO-UNDO.           

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).           

{emailaddr-USERID.i}.

/*IF drive_letter = "P" THEN                                                                                                                                                                            */
/*    PROPATH = "P:\OpenEdge\WRK\RStP\rcode\,P:\OpenEdge\WRK\RStP\src\,P:\OpenEdge\WRK\depot\rcode\,P:\OpenEdge\WRK\depot\src\WebSpeed\,P:\OpenEdge\WRK\RStP\," + PROPATH.                              */
/*                                                                                                                                                                                                      */
/*IF drive_letter = "C" THEN                                                                                                                                                                            */
/*    PROPATH = "C:\OpenEdge\Workspace\RStP\rcode\,C:\OpenEdge\Workspace\RStP\src\,C:\OpenEdge\Workspace\depot\rcode\,C:\OpenEdge\Workspace\depot\src\WebSpeed\,C:\OpenEdge\Workspace\RStP\," + PROPATH.*/
 
/* ***************************  Main Block  *************************** */
main-block:
FOR EACH TESTS_FM_SPECIMEN_RCD WHERE LOOKUP(TESTS_FM_SPECIMEN_RCD.Progress_Flag,loadedlist) = 0:      /* 1dot1 */
    
    recordsprocessed = recordsprocessed + 1.
    
    IF tester = "YES" AND recordsprocessed >= 100 THEN 
        LEAVE main-block.
        
    FIND TESTS_RESULT_RCD WHERE TESTS_RESULT_RCD.PatientID = TESTS_FM_SPECIMEN_RCD.PatientID AND    /* 1dot1 */
        TESTS_RESULT_RCD.Lab_Sampleid = TESTS_FM_SPECIMEN_RCD.Lab_Sampleid AND                     /* 1dot1 */ 
        TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_FM_SPECIMEN_RCD.Lab_Sampleid_SeqNbr AND       /* 1dot1 */ 
        TESTS_RESULT_RCD.Test_Abbv = TESTS_FM_SPECIMEN_RCD.Test_Abbv                               /* 1dot1 */
            NO-LOCK NO-ERROR.

    IF NOT AVAILABLE (tests_result_rcd) THEN DO: 
         
        EXPORT STREAM outward DELIMITER ";"
            TESTS_FM_SPECIMEN_RCD.PatientID 
            TESTS_FM_SPECIMEN_RCD.Lab_Sampleid 
            TESTS_FM_SPECIMEN_RCD.Lab_Sampleid_SeqNbr
            "Test Type = "
            TESTS_FM_SPECIMEN_RCD.test_abbv 
            TESTS_FM_SPECIMEN_RCD.Progress_Flag
            "ERROR G1! NO TESTS_FM_SPECIMEN_RCD records match any TESTS_RESULT_RCD record.".

        ASSIGN ERROR-count[1] = ERROR-count[1]  + 1.                            /* 2dot3 */

        NEXT main-block.
        
    END.  /** of if not avail tests_result_rcd **/
    
    ELSE DO:
        
        /*****************  Begin 2dot1 ****************/
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

    END.  /** of else do --- if avail tests_result_rcd **/

    FIND BFM_mstr WHERE BFM_mstr.BFM_ID = v-tkid AND 
        BFM_mstr.BFM_test_seq = v-tkseq AND 
        BFM_mstr.BFM_deleted = ? 
            EXCLUSIVE-LOCK NO-ERROR.
            
    IF NOT AVAILABLE (BFM_mstr) THEN DO:
        
        FIND BFM_mstr WHERE BFM_mstr.BFM_ID = v-tkid AND 
            BFM_mstr.BFM_test_seq = v-tkseq 
                EXCLUSIVE-LOCK NO-ERROR. 
                
        IF AVAILABLE (BFM_mstr) THEN DO:      /** undelete the BFM_mstr **/
        
            ASSIGN   
                BFM_mstr.BFM_deleted            = ?
                BFM_mstr.BFM_modified_by        = USERID("HHI")
                BFM_mstr.BFM_modified_date      = TODAY 
                BFM_mstr.BFM_prog_name          = THIS-PROCEDURE:FILE-NAME.
                
        END.  /** of if avail BFM_mstr **/
        
        ELSE DO:        /* go ahead and create a BFM_mstr */
            
            CREATE BFM_mstr.
            
            ASSIGN 
                BFM_mstr.BFM_ID              = v-tkid
                BFM_mstr.BFM_test_seq        = v-tkseq
                BFM_mstr.BFM_provocation     = TESTS_FM_SPECIMEN_RCD.FM_Provocation
                BFM_mstr.BFM_detox_agent     = TESTS_FM_SPECIMEN_RCD.FM_Detoxification_agent
                BFM_mstr.BFM_dosage          = TESTS_FM_SPECIMEN_RCD.FM_Dosage
                BFM_mstr.BFM_dent_amal       = TESTS_FM_SPECIMEN_RCD.FM_Dental_Amalgams
                BFM_mstr.BFM_qty             = TESTS_FM_SPECIMEN_RCD.FM_Quantity
                BFM_mstr.BFM_created_by      = USERID("HHI")
                BFM_mstr.BFM_create_date     = TODAY 
                BFM_mstr.BFM_modified_by     = USERID("HHI")
                BFM_mstr.BFM_modified_date   = TODAY 
                BFM_mstr.BFM_prog_name       = THIS-PROCEDURE:FILE-NAME.         /* 1dot1 */
            
        END.  /** of else do --- create butee_mstr **/

    END.  /** of if not avail butee_mstr **/
            

/*****************************************************************************************
 *  Begin ADD section
 *****************************************************************************************/
                
    IF TESTS_FM_SPECIMEN_RCD.Progress_Flag = "" OR               /* 1dot1 */                /** Begin ADD section **/
       TESTS_FM_SPECIMEN_RCD.Progress_Flag = "A" OR              /* 1dot1 */
       (firstrun = YES AND TESTS_FM_SPECIMEN_RCD.Progress_Flag = "U")    /* 1dot1 */        /* this line is for the initial load only */                
        THEN DO:                            
              
        ASSIGN 
            BFM_mstr.BFM_provocation     = TESTS_FM_SPECIMEN_RCD.FM_Provocation
            BFM_mstr.BFM_detox_agent     = TESTS_FM_SPECIMEN_RCD.FM_Detoxification_agent
            BFM_mstr.BFM_dosage          = TESTS_FM_SPECIMEN_RCD.FM_Dosage
            BFM_mstr.BFM_dent_amal       = TESTS_FM_SPECIMEN_RCD.FM_Dental_Amalgams
            BFM_mstr.BFM_qty             = TESTS_FM_SPECIMEN_RCD.FM_Quantity
            BFM_mstr.BFM_modified_by     = USERID("HHI")
            BFM_mstr.BFM_modified_date   = TODAY 
            BFM_mstr.BFM_prog_name       = THIS-PROCEDURE:FILE-NAME         /* 1dot1 */
            TESTS_FM_SPECIMEN_RCD.Progress_Flag = IF TESTS_FM_SPECIMEN_RCD.Progress_Flag = "A" THEN       /* 1dot1 */ 
                                                "AL"      /** update the RS database so we don't re-pull --- stands for Add Loaded **/
                                          ELSE IF TESTS_FM_SPECIMEN_RCD.Progress_Flag = "U" THEN             /* 1dot1 */
                                                "UL"                                                                                          
                                          ELSE IF TESTS_FM_SPECIMEN_RCD.Progress_Flag = "" THEN
                                                "IL"     /** update the RS database so we don't re-pull --- stands for Import Loaded **/
                                          ELSE 
                                                TESTS_FM_SPECIMEN_RCD.Progress_Flag. 
                                                                                                      
    END. /* IF TESTS_FM_SPECIMEN_RCD.Progress_Flag = "" OR "A" THEN DO: */

/************************************************************************************
 *  Begin DELETE section
 ************************************************************************************/
   
    ELSE IF TESTS_FM_SPECIMEN_RCD.Progress_Flag = "D" THEN DO:                       /* 1dot1 */                                                          /** Begin DELETE section */
             
            ASSIGN
                 BFM_mstr.BFM_deleted       = TODAY 
                 BFM_mstr.BFM_modified_by   = USERID("HHI")
                 BFM_mstr.BFM_modified_date = TODAY
                 BFM_mstr.BFM_prog_name     = THIS-PROCEDURE:FILE-NAME          /* 1dot1 */ 
                 TESTS_FM_SPECIMEN_RCD.Progress_Flag = "DL".     /** update the RS database so we don't re-pull --- stands for Delete Loaded **/
    
    END.  /**** of else if progress_flag = D --- Delete a record ****/        
     
/*************************************************************************************
 *  Begin UPDATE section 
 *************************************************************************************/        
             
    ELSE IF (TESTS_FM_SPECIMEN_RCD.Progress_Flag = "U" AND firstrun = NO) THEN DO:        /* 1dot1 */      /*** Begin UPDATE section ***/
                                   
        ASSIGN               
            BFM_mstr.BFM_provocation     = TESTS_FM_SPECIMEN_RCD.FM_Provocation
            BFM_mstr.BFM_detox_agent     = TESTS_FM_SPECIMEN_RCD.FM_Detoxification_agent
            BFM_mstr.BFM_dosage          = TESTS_FM_SPECIMEN_RCD.FM_Dosage
            BFM_mstr.BFM_dent_amal       = TESTS_FM_SPECIMEN_RCD.FM_Dental_Amalgams
            BFM_mstr.BFM_qty             = TESTS_FM_SPECIMEN_RCD.FM_Quantity
            BFM_mstr.BFM_modified_by     = USERID("HHI")
            BFM_mstr.BFM_modified_date   = TODAY 
            BFM_mstr.BFM_prog_name       = THIS-PROCEDURE:FILE-NAME         /* 1dot1 */    
            TESTS_FM_SPECIMEN_RCD.Progress_Flag = "UL".      /** update the RS database so we don't re-pull --- stands for Update Loaded **/
               
    END.  /*** of else if progress_flag = U --- Update a record ***/ 
   
    ELSE DO: 
        
        EXPORT STREAM outward DELIMITER ";"
            TESTS_FM_SPECIMEN_RCD.PatientID 
            TESTS_RESULT_RCD.Test_Kit_Nbr                                            /* 1dot1 */  
            TESTS_FM_SPECIMEN_RCD.Lab_Sampleid 
            TESTS_FM_SPECIMEN_RCD.Lab_Sampleid_SeqNbr
            TESTS_FM_SPECIMEN_RCD.Progress_Flag                                      /* 1dot1 */ 
            "ERROR 5!  Something UNEXPECTED happened.".      /* yet ironically I coded for it */
        
        ASSIGN ERROR-count[5] = ERROR-count[5]  + 1.                                    /* 1dot1 */ 
        /* If this condition occured you should check the loadlist variable and */
        /* also the Progress_Flag field.                                        */
 
    END.  /*** of else do --- unexpected error! ***/
    
END.  /** of 4ea. patient_files **/


EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Records Processed".
    
EXPORT STREAM outward DELIMITER ";"                                                                      /* 1dot1 */
    ERROR-count[1] "ERROR 1! TK_mstr not found for TESTS_FM_SPECIMEN_RCD and/or TESTS_RESULT_RCD.".      /* 1dot1 */
EXPORT STREAM outward DELIMITER ";"                                                                      /* 1dot1 */
    ERROR-count[2] "ERROR 2! TESTS_FM_SPECIMEN_RCD already exists in BFM_mstr.".                  /* 1dot1 */
EXPORT STREAM outward DELIMITER ";"                                                                      /* 1dot1 */
    ERROR-count[3] "ERROR 3! TESTS_FM_SPECIMEN_RCD already deleted from BFM_mstr.".               /* 1dot1 */   
EXPORT STREAM outward DELIMITER ";"                                                                      /* 1dot1 */
    ERROR-count[4] "ERROR 4! TESTS_FM_SPECIMEN_RCD not found in DFM_det to update.".              /* 1dot1 */ 
EXPORT STREAM outward DELIMITER ";"                                                                      /* 1dot1 */
    ERROR-count[5] "ERROR 5!  Something UNEXPECTED happened.".                                           /* 1dot1 */

EXPORT STREAM outward DELIMITER ";"                                                                      /* 2dot3 */
    ERROR-count[10] "ERROR 10! Blank Test_Kit_Nbr in  NEXT.".  

OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).
    
/*************************  END OF FILE  **************************/
