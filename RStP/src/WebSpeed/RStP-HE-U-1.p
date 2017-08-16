
/*------------------------------------------------------------------------
    File        : RSTP-HE-U.p
    Purpose     : 

    Syntax      :

    Description : Migrate the TESTS_FM_SPECIMEN_RCD table to the BF_det table.  /* 1dot2 */
                  Designed to be run repeatedly in batch.

    Author(s)   : Mark Jacobs Using framework provided by Doug Luttrell
    Created     : Thu Dec 27 20:19:30 EST 2014
    Notes       : Uncomment line 120 for initial run and change line 36 Logical to YES. 
                : Uncomment line 110 and 191 After database correction for datatype. 

  ----------------------------------------------------------------------
  Revision History:        
  -----------------
  1.0 - written by Mark Jacobs  on 27/Dec/14.  Original version.
    Using framework provided by Doug Luttrell
  1.1 - written by DOUG LUTTRELL on 23/May/15.  Something is awry with the finding of 
            pre-existing records.  Also removed the preprocessor references to 
            {&this-table}, which was pointing at TESTS_HE_SPECIMEN_RATIOS_RCD.
            Marked by 1dot1.
  1.2 - By Harold Luttrell on 13/Jul/15.
        a.  Changed the NO-LOCK verb to the EXCLUSIVE-LOCK verb so fields could
            be updated.  
        b.  Added more output data displays for the error log report.  
        c.  Change the output log file name to: 
                RStP_HE_Specimen_Ratios_RCD-U-log-1.txt.
        d.  Modified the FIND TK_mstr code 
            from: 
                BHE_mstr.BHE_test_seq = integer(TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr) 
            to:
                BHE_mstr.BHE_test_seq = TK_mstr.TK_test_seq
            and
                added the new index.
        e.  Added the THIS-PROCEDURE:FILE-NAME assign to BHE_mstr.BHE_prog_name.
        f.  Added total count for each ERROR! message.
            Marked by 1dot2.  
       
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
DEFINE VARIABLE firstrun AS LOGICAL INITIAL NO NO-UNDO.         /* change to YES for second program */

DEFINE VARIABLE v-tkid LIKE TK_mstr.TK_ID NO-UNDO.                              /* 2dot1 */
DEFINE VARIABLE v-tkseq LIKE TK_mstr.TK_test_seq NO-UNDO.                       /* 2dot1 */

DEFINE VARIABLE loadedlist AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO. 
   
DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 20 NO-UNDO.                        /* 1dot2 */
DEFINE VARIABLE drive_letter    AS CHARACTER                        NO-UNDO.    /* 1dot2 */

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                /* 1dot2 */

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.

{emailaddr-USERID.i}.

DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RStP-HE_Specimen_Ratios_RCD-U-log-1.txt" NO-UNDO.  /* Change to 2 for second program */

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID" 
    "TESTS_RESULT_RCD.Test_Kit_Nbr"                                             /* 1dot2 */
    "TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid"                                 /* 1dot2 */
    "TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr"                          /* 1dot2 */
    "TESTS_HE_SPECIMEN_RATIOS_RCD.Test_Abbv"                                    /* 1dot2 */
    "TESTS_HE_SPECIMEN_RATIOS_RCD.progress_flag"                                /* 1dot2 */ 
    "Error Message".                                                            /* 1dot2 */

 
/* ***************************  Main Block  *************************** */
main-block:
FOR EACH TESTS_HE_SPECIMEN_RATIOS_RCD WHERE LOOKUP(TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag,loadedlist) = 0: 

    recordsprocessed = recordsprocessed + 1.
    
    IF tester = "YES" AND recordsprocessed >= 100 THEN 
        LEAVE main-block.
                      
    FIND TESTS_RESULT_RCD WHERE TESTS_RESULT_RCD.patientid = TESTS_HE_SPECIMEN_RATIOS_RCD.patientID AND
         TESTS_RESULT_RCD.Lab_Sampleid = TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid AND 
         TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr AND 
         TESTS_RESULT_RCD.Test_Abbv = TESTS_HE_SPECIMEN_RATIOS_RCD.Test_Abbv
            NO-LOCK NO-ERROR.

    IF NOT AVAILABLE (tests_result_rcd) THEN DO: 
         
        EXPORT STREAM outward DELIMITER ";"
            TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID 
            TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid 
            TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr
            "Test Type = "
            TESTS_HE_SPECIMEN_RATIOS_RCD.test_abbv 
            TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag
            "ERROR G1! NO TESTS_HE_SPECIMEN_RATIOS_RCD records match any TESTS_RESULT_RCD record.".

        ASSIGN ERROR-count[1] = ERROR-count[1]  + 1.                            /* 2dot3 */

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

    FIND BHE_mstr WHERE BHE_mstr.BHE_ID = v-tkid AND 
        BHE_mstr.BHE_test_seq = v-tkseq AND 
        BHE_mstr.BHE_deleted = ? 
            EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAILABLE (BHE_mstr) THEN DO:
        
        FIND BHE_mstr WHERE BHE_mstr.BHE_ID = v-tkid AND 
            BHE_mstr.BHE_test_seq = v-tkseq 
                EXCLUSIVE-LOCK NO-ERROR. 
                
        IF AVAILABLE (BHE_mstr) THEN DO:      /** undelete the BHE_mstr **/
        
            ASSIGN   
                BHE_mstr.BHE_deleted            = ?
                BHE_mstr.BHE_modified_by        = USERID("HHI")
                BHE_mstr.BHE_modified_date      = TODAY 
                BHE_mstr.BHE_prog_name          = THIS-PROCEDURE:FILE-NAME.
                
        END.  /** of if avail BHE_mstr **/
        
        ELSE DO:        /* go ahead and create a BHE_mstr */
            
            CREATE BHE_mstr.
            
            ASSIGN 
                BHE_mstr.BHE_ID              = v-tkid
                BHE_mstr.BHE_test_seq        = v-tkseq
                BHE_mstr.BHE_sample_weight   = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_sample_weight
                BHE_mstr.BHE_sample_type     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_sample_type
                BHE_mstr.BHE_hair_color      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_hair_color
                BHE_mstr.BHE_treatment       = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_treatment 
                BHE_mstr.BHE_shampoo         = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_shampoo
                BHE_mstr.BHE_ratio_ca_mg     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_ca_mg
                BHE_mstr.BHE_ratio_ca_p      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_ca_p
                BHE_mstr.BHE_ratio_na_k      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_na_k
                BHE_mstr.BHE_ratio_zn_cu     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_zn_cu
            /*** this was already commented out.  I suspect there is garbage in this source field. ***/
            /*  BHE_mstr.BHE_ratio_zn_cd     = DECIMAL(TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_zn_cd) */
                BHE_mstr.BHE_total_toxics[1] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_1
                BHE_mstr.BHE_total_toxics[2] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_2
                BHE_mstr.BHE_total_toxics[3] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_3
                BHE_mstr.BHE_total_toxics[4] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_4
                BHE_mstr.BHE_created_by      = USERID("HHI")
                BHE_mstr.BHE_create_date     = TODAY 
                BHE_mstr.BHE_modified_by     = USERID("HHI")
                BHE_mstr.BHE_modified_date   = TODAY          
                BHE_mstr.BHE_prog_name       = THIS-PROCEDURE:FILE-NAME.
            
        END.  /** of else do --- create butee_mstr **/

    END.  /** of if not avail butee_mstr **/


/*****************************************************************************************
 *  Begin ADD section
 *****************************************************************************************/
        
    IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "" OR 
       TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "A" OR
       (firstrun = YES AND TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "U") THEN DO:                            /** Begin ADD section **/

        ASSIGN     
            BHE_mstr.BHE_sample_weight   = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_sample_weight
            BHE_mstr.BHE_sample_type     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_sample_type
            BHE_mstr.BHE_hair_color      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_hair_color
            BHE_mstr.BHE_treatment       = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_treatment 
            BHE_mstr.BHE_shampoo         = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_shampoo
            BHE_mstr.BHE_ratio_ca_mg     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_ca_mg
            BHE_mstr.BHE_ratio_ca_p      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_ca_p
            BHE_mstr.BHE_ratio_na_k      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_na_k
            BHE_mstr.BHE_ratio_zn_cu     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_zn_cu
        /*  BHE_mstr.BHE_ratio_zn_cd     = DECIMAL(TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_zn_cd) */
            BHE_mstr.BHE_total_toxics[1] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_1
            BHE_mstr.BHE_total_toxics[2] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_2
            BHE_mstr.BHE_total_toxics[3] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_3
            BHE_mstr.BHE_total_toxics[4] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_4
            BHE_mstr.BHE_created_by      = USERID("HHI")
            BHE_mstr.BHE_create_date     = TODAY 
            BHE_mstr.BHE_modified_by     = USERID("HHI")
            BHE_mstr.BHE_modified_date   = TODAY          
            BHE_mstr.BHE_prog_name       = THIS-PROCEDURE:FILE-NAME         /* 1dot2 */
            TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "A" THEN  
                                                "AL"      /** stands for Add Loaded **/
                                              ELSE IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "U" THEN
                                                "UL"        /** stands for Update Loaded **/
                                              ELSE IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "" THEN
                                                "IL"     /** stands for Import Loaded **/
                                              ELSE 
                                                TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag.
                                                
    END. /* IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "" OR "A" THEN DO: */

/************************************************************************************
 *  Begin DELETE section
 ************************************************************************************/
    
    ELSE IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "D" THEN DO:                                                          /** Begin DELETE section */
    
        ASSIGN
            BHE_mstr.BHE_deleted       = TODAY 
            BHE_mstr.BHE_modified_by   = USERID("HHI")
            BHE_mstr.BHE_modified_date = TODAY 
            BHE_mstr.BHE_prog_name     = THIS-PROCEDURE:FILE-NAME       /* 1dot2 */
            TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "DL".     /** update the RS database so we don't re-pull --- stands for Delete Loaded **/

    END.  /**** of else if progress_flag = D --- Delete a record ****/        
    
/*************************************************************************************
 *  Begin UPDATE section 
 *************************************************************************************/        
             
    ELSE IF (TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "U" AND firstrun = NO) THEN DO:                                                      /*** Begin UPDATE section ***/
                                           
        ASSIGN               
            BHE_mstr.BHE_sample_weight   = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_sample_weight
            BHE_mstr.BHE_sample_type     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_sample_type
            BHE_mstr.BHE_hair_color      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_hair_color
            BHE_mstr.BHE_treatment       = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_treatment 
            BHE_mstr.BHE_shampoo         = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_shampoo
            BHE_mstr.BHE_ratio_ca_mg     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_ca_mg
            BHE_mstr.BHE_ratio_ca_p      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_ca_p
            BHE_mstr.BHE_ratio_na_k      = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_na_k
            BHE_mstr.BHE_ratio_zn_cu     = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_zn_cu
      /*    BHE_mstr.BHE_ratio_zn_cd     = DECIMAL(TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_zn_cd)  */ 
            BHE_mstr.BHE_total_toxics[1] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_1
            BHE_mstr.BHE_total_toxics[2] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_2
            BHE_mstr.BHE_total_toxics[3] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_3
            BHE_mstr.BHE_total_toxics[4] = TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_4
            BHE_mstr.BHE_modified_by     = USERID("HHI")
            BHE_mstr.BHE_modified_date   = TODAY 
            BHE_mstr.BHE_prog_name       = THIS-PROCEDURE:FILE-NAME     /* 1dot2 */  
            TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "UL".      /** update the RS database so we don't re-pull --- stands for Update Loaded **/
                       
    END.  /*** of else if progress_flag = U --- Update a record ***/ 
   
    ELSE DO: 
        
        EXPORT STREAM outward DELIMITER ";"
            TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID 
            TESTS_RESULT_RCD.Test_Kit_Nbr                                   /* 1dot2 */ 
            TESTS_HE_SPECIMEN_RATIOS_RCD.lab_sampleid 
            TESTS_HE_SPECIMEN_RATIOS_RCD.lab_sampleid_seqnbr
            TESTS_HE_SPECIMEN_RATIOS_RCD.Test_Abbv                          /* 1dot2 */
            TESTS_HE_SPECIMEN_RATIOS_RCD.progress_flag                      /* 1dot2 */    
            "ERROR 5!  Something UNEXPECTED happened.".      /* yet ironically I coded for it */
        
        ASSIGN ERROR-count[5] = ERROR-count[5]  + 1.                        /* 1dot2 */
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
    
EXPORT STREAM outward DELIMITER ";"                                                                             /* 1dot2 */
    ERROR-count[1] "ERROR 1! TK_mstr not found for TESTS_HE_SPECIMEN_RATIOS_RCD and/or TESTS_RESULT_RCD.".      /* 1dot2 */
EXPORT STREAM outward DELIMITER ";"                                                                             /* 1dot2 */
    ERROR-count[2] "ERROR 2! HE_SPECIMEN_RATIOS already exists in BHE_mstr for an ADD.".                    /* 1dot2 */
EXPORT STREAM outward DELIMITER ";"                                                                             /* 1dot2 */
    ERROR-count[3] "ERROR 3! TESTS_HE_SPECIMEN_RATIOS_RCD already deleted from BHE_mstr.".               /* 1dot2 */   
EXPORT STREAM outward DELIMITER ";"                                                                             /* 1dot2 */
    ERROR-count[4] "ERROR 4! TESTS_HE_SPECIMEN_RATIOS_RCD not found in BHE_det to update.".              /* 1dot2 */ 
EXPORT STREAM outward DELIMITER ";"                                                                             /* 1dot2 */
    ERROR-count[5] "ERROR 5!  Something UNEXPECTED happened.".                                                  /* 1dot2 */

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
