
/*------------------------------------------------------------------------
    File        : RSTP-BUTEE-U-1.p

    Description : Migrate the records from the TESTS_UTM_UEE_SPECIMEN_RCD
                    table in the RS database over to the BUTEE_mstr in 
                    the HHI database.
                    

    Author(s)   : Trae Luttrell
    Created     : Fri Dec 26 21:19:30 MST 2014
    Notes       : There are two variables that control the behavior of this
                    code for testing purposes.  They are FIRSTRUN and LIMITRUN.
                    FIRSTRUN is a logical that was created to support the fact
                    that changes could have occurred since the Add of the data
                    via some sort of Update.  Thus, FIRSTRUN = YES causes the 
                    program to treat Updates as Adds.  LIMITRUN is primarily for
                    testing purposes and is an integer representing the number
                    of records that should be processed.  If it is set to 0 it
                    will process All the records, rather than None of the records.

  ----------------------------------------------------------------------
  Revision History:        
  -----------------
  1.0 - written by DOUG LUTTRELL on 11/Dec/14.  Original version.
  2.0 - the original attfile program modified into the BUTEE_mstr code. by TRAE LUTTRELL
  2.1 - wrtten by DOUG LUTTRELL on 02/Jan/15.  Modified to include the requirements for finding
            the correct TK_test_seq info based on the change to the approach used to set that.
            Also included changes for better control during test runs.
  2.2 - altered by Trae Luttrell on 27/May/15. 
    Renaming:
      RStP-BUTEE-U-1 = RStP-BUTEE-U-1
      RStP-BUTEE-U-2 = RStP-BUTEE-U-2
      RStP-BUTEE2-U-1 = RStP-BUTEE-U-3
      RStP-BUTEE2-U-2 = RStP-BUTEE-U-4
      
  2.3 - By Harold Luttrell on 24/Jul/15.
        a.  Added more output data displays for the error log report.  
        b.  Added the THIS-PROCEDURE:FILE-NAME assign to xxx_prog_name.
        c.  Added the emailaddr-USERID.i code.
        d.  Added total count for each ERROR! message.
        e.  Removed the preprocessor references to 
            {&this-table}, which was pointing at TESTS_UTM_UEE_SPECIMEN_RCD.
            I did NOT marked this change because there was so many of them I
            didn't want to make the code look junkie.
        Marked by 2dot3. 
  
  2.4 - By Harold Luttrell on 13/Aug/15.
        a.  Added the ERROR G3 message and counter to the error log report.  
        b.  Added code to FIND the LAST  TK_mstr WHERE   
            TK_mstr.TK_patient_ID    = INTEGER(TESTS_UTM_UEE_SPECIMEN_RCD.PatientID)  AND 
            TK_mstr.TK_lab_sample_ID = TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid        AND 
            TK_mstr.TK_test_type                                            /* 3dot0 */
            without using the TK_mstr.TK_lab_seq data.
        Marked by 2dot4.
         
    Version: 3.0    By Harold Luttrell, Sr.
    Date: 5/Mar/16.
    Description:    Changed database field name from 
                        TK_mstr.TK_testtype to TK_mstr.TK_test_type.                    
    Identified by /* 3dot0 */  
    
  3.1 - written by DOUG LUTTRELL on 02/Jun/16.  The continuing saga of the change in the way we 
            identify the old testkits.  See RStP-TESTS_RESULTS_RCD-U-1.p for more details.  Not 
            really marked due to quantity of changes, but possibly marked by 3dot1.
                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/** specific to this program **/   

/** useful for all RStP code **/
DEFINE VARIABLE limitrun AS INTEGER INITIAL 0 NO-UNDO.         /** a non-zero number will limit processing to that many records **/
DEFINE VARIABLE firstrun AS LOGICAL INITIAL YES NO-UNDO.                         /* change to YES for second program */

DEFINE VARIABLE v-tkid LIKE TK_mstr.TK_ID NO-UNDO.                              /* 3dot1 */
DEFINE VARIABLE v-tkseq LIKE TK_mstr.TK_test_seq NO-UNDO.                       /* 3dot1 */

DEFINE VARIABLE loadedlist AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO.    
   
DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 20 NO-UNDO.                        /* 2dot4 */  

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.    /* 2dot3 */
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.    /* 2dot3 */
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
  
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RStP-BUTEE-U-log-2.txt" NO-UNDO.       /* change to 2 for second program */

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"                                             /* these are column headers */
    "PatientID" "Lab_Sampleid" "Lab_SeqNbr" "TK_ID" "TK_test_seq" "Flag" "Error Message".


/* ********************  Preprocessor Definitions  ******************** */
/*&SCOPED-DEFINE this-table   TESTS_UTM_UEE_SPECIMEN_RCD*/                      /* 2dot3 */
 
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
FOR EACH TESTS_UTM_UEE_SPECIMEN_RCD WHERE LOOKUP(TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag,loadedlist) = 0:    /* 2dot3 */ 

    recordsprocessed = recordsprocessed + 1.

    IF (limitrun > 0) AND (recordsprocessed > limitrun) THEN 
        LEAVE main-block.   
        
    FIND TESTS_RESULT_RCD WHERE 
             TESTS_RESULT_RCD.PatientID = TESTS_UTM_UEE_SPECIMEN_RCD.PatientID AND 
             TESTS_RESULT_RCD.Lab_Sampleid = TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid AND 
             TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr AND 
             TESTS_RESULT_RCD.Test_Abbv = TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv 
             NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE (tests_result_rcd) THEN DO: 
         
        EXPORT STREAM outward DELIMITER ";"
            TESTS_UTM_UEE_SPECIMEN_RCD.PatientID 
            TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid 
            TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr
            "Test Type = "
            TESTS_UTM_UEE_SPECIMEN_RCD.test_abbv 
            TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag
            "ERROR G1! NO TESTS_UTM_UEE_SPECIMEN_RCD records match any TESTS_RESULT_RCD record.".

        ASSIGN ERROR-count[1] = ERROR-count[1]  + 1.                            /* 2dot3 */

        NEXT main-block. 
        
    END.  /** of if not avail tests_result_rcd **/
    
    ELSE DO:
        
        /*****************  Begin 3dot1 ****************/
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
                TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag
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

    FIND BUTEE_mstr WHERE BUTEE_mstr.BUTEE_ID = v-tkid AND 
        BUTEE_mstr.BUTEE_test_seq = v-tkseq AND  
        BUTEE_mstr.BUTEE_deleted = ? 
            EXCLUSIVE-LOCK NO-ERROR.
    
    IF NOT AVAILABLE (butee_mstr) THEN DO:
        
        FIND BUTEE_mstr WHERE BUTEE_mstr.BUTEE_ID = v-tkid AND 
            BUTEE_mstr.BUTEE_test_seq = v-tkseq 
                EXCLUSIVE-LOCK NO-ERROR. 
                
        IF AVAILABLE (butee_mstr) THEN DO:      /** undelete the BUTEE_mstr **/
        
            ASSIGN   
                BUTEE_mstr.BUTEE_deleted        = ?
                BUTEE_mstr.BUTEE_modified_by    = USERID("HHI")
                BUTEE_mstr.BUTEE_modified_date  = TODAY 
                BUTEE_mstr.BUTEE_prog_name      = THIS-PROCEDURE:FILE-NAME.     

        END.  /** of if avail butee_mstr **/
        
        ELSE DO:        /* go ahead and create a butee_mstr */
            
            CREATE BUTEE_mstr.
            
            ASSIGN 
                BUTEE_mstr.BUTEE_ID             = v-tkid
                BUTEE_mstr.BUTEE_test_seq       = v-tkseq
                BUTEE_mstr.BUTEE_rcpt_pH        = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_pH_upon_receipt
                BUTEE_mstr.BUTEE_volume         = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Volume 
                BUTEE_mstr.BUTEE_coll_per       = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Collection_Period
                BUTEE_mstr.BUTEE_provocation    = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Provocation
                BUTEE_mstr.BUTEE_prov_agent     = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Provoking_Agent
                BUTEE_mstr.BUTEE_creatinine     = TESTS_RESULT_RCD.CCreatinine 
                BUTEE_mstr.BUTEE_created_by     = USERID("HHI")
                BUTEE_mstr.BUTEE_create_date    = TODAY 
                BUTEE_mstr.BUTEE_modified_by    = USERID("HHI")
                BUTEE_mstr.BUTEE_modified_date  = TODAY
                BUTEE_mstr.BUTEE_prog_name      = THIS-PROCEDURE:FILE-NAME.
            
        END.  /** of else do --- create butee_mstr **/

    END.  /** of if not avail butee_mstr **/
    
/*****************************************************************************************
 *  Begin ADD section
 *****************************************************************************************/

    IF TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "" OR 
        TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "A" OR 
        (firstrun = YES AND TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "U")                  /* this line is for the initial load only */    
    THEN DO:                           /** Begin ADD section **/

        ASSIGN 
            BUTEE_mstr.BUTEE_rcpt_pH        = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_pH_upon_receipt
            BUTEE_mstr.BUTEE_volume         = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Volume 
            BUTEE_mstr.BUTEE_coll_per       = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Collection_Period
            BUTEE_mstr.BUTEE_provocation    = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Provocation
            BUTEE_mstr.BUTEE_prov_agent     = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Provoking_Agent
            BUTEE_mstr.BUTEE_creatinine     = TESTS_RESULT_RCD.CCreatinine
            BUTEE_mstr.BUTEE_modified_by    = USERID("HHI")                 /* 2dot3 */  /* was General - WRONG database. */
            BUTEE_mstr.BUTEE_modified_date  = TODAY 
            BUTEE_mstr.BUTEE_prog_name      = THIS-PROCEDURE:FILE-NAME      /* 2dot3 */ 
            TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag     = IF TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "A" THEN  
                                                    "AL"        /* stands for Add Loaded */                                                              /** update the RS database so we don't re-pull --- stands for Add Loaded **/
                                              ELSE IF TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "U" THEN
                                                    "UL"        /* stands for Update Loaded */
                                              ELSE IF TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "" THEN 
                                                    "IL"        /* stands for Import Loaded */
                                              ELSE 
                                                TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag.

    END.  /** of progress_flag = A or "" ---- ADD section **/

/************************************************************************************
 *  Begin DELETE section
 ************************************************************************************/
                 
    ELSE IF TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "D" THEN DO:                                                          /** Begin DELETE section */
              
        ASSIGN
            BUTEE_mstr.BUTEE_deleted        = TODAY 
            BUTEE_mstr.BUTEE_modified_by    = USERID("HHI")                 /* 2dot3 */  /* was General - WRONG database. */
            BUTEE_mstr.BUTEE_modified_date  = TODAY 
            BUTEE_mstr.BUTEE_prog_name      = THIS-PROCEDURE:FILE-NAME      /* 2dot3 */
            TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag     = "DL".     /** update the RS database so we don't re-pull --- stands for Delete Loaded **/
        
    END.  /**** of else if progress_flag = D --- Delete a record ****/
          
/*************************************************************************************
 *  Begin UPDATE section 
 *************************************************************************************/        

    ELSE IF (TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "U" AND firstrun = NO) THEN DO:                         /*** Begin UPDATE section ***/
                
        ASSIGN 
            BUTEE_mstr.BUTEE_rcpt_pH        = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_pH_upon_receipt
            BUTEE_mstr.BUTEE_volume         = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Volume 
            BUTEE_mstr.BUTEE_coll_per       = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Collection_Period
            BUTEE_mstr.BUTEE_provocation    = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Provocation
            BUTEE_mstr.BUTEE_prov_agent     = TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Provoking_Agent
            BUTEE_mstr.BUTEE_creatinine     = TESTS_RESULT_RCD.CCreatinine
            BUTEE_mstr.BUTEE_modified_by    = USERID("HHI")                  /* 2dot3 */  /* was General - WRONG database. */
            BUTEE_mstr.BUTEE_modified_date  = TODAY  
            BUTEE_mstr.BUTEE_prog_name      = THIS-PROCEDURE:FILE-NAME      /* 2dot3 */                   
            TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag     = "UL".      /** update the RS database so we don't re-pull --- stands for Update Loaded **/
        
    END.  /*** of else if progress_flag = U --- Update a record ***/
        
    ELSE DO: 
    
        EXPORT STREAM outward DELIMITER ";"
            TESTS_UTM_UEE_SPECIMEN_RCD.PatientID 
            TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid 
            TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr
            "Test Type = "
            TESTS_UTM_UEE_SPECIMEN_RCD.test_abbv 
            TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag
            "ERROR! Something Unexpected Happened!.". 
             
         ASSIGN ERROR-count[6] = ERROR-count[6]  + 1.                        /* 2dot3 */
         
        /* If this condition occured you should check the loadlist variable and */
        /* also the Progress_Flag field                                         */

    END.  /*** of else do --- unexpected error! ***/
       
END.  /** of 4ea. TESTS_UTM_UEE_SPECIMEN_RCD **/

EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Records Processed".
    
EXPORT STREAM outward DELIMITER ";"                                                                      /* 2dot3 */
    ERROR-count[1] "ERROR G1! NO TESTS_UTM_UEE_SPECIMEN_RCD records match any TESTS_RESULT_RCD record.". /* 2dot3 */
    
/*EXPORT STREAM outward DELIMITER ";"                                                                      /* 2dot3 */*/
/*    ERROR-count[2] "ERROR G2! NO TESTS_UTM_UEE_SPECIMEN_RCD record matches any TK_mstr record.".         /* 2dot3 */*/
/*EXPORT STREAM outward DELIMITER ";"                                                                      /* 2dot4 */*/
/*    ERROR-count [7] "ERROR G3! TESTS_UTM_UEE_SPECIMEN_RCD.lab_Sampleid matches TK_mstr records.".        /* 2dot4 */*/
/*EXPORT STREAM outward DELIMITER ";"                                                                      /* 2dot3 */*/
/*    ERROR-count[3] "ERROR A1! TESTS_UTM_UEE_SPECIMEN_RCD record already exists in BUTEE_mstr.".      /* 2dot3 */*/
/*EXPORT STREAM outward DELIMITER ";"                                                                      /* 2dot3 */*/
/*    ERROR-count[4] "ERROR D1! BUTEE_mstr record already deleted.".                                       /* 2dot3 */*/
/*EXPORT STREAM outward DELIMITER ";"                                                                      /* 2dot3 */*/
/*    ERROR-count[5] "ERROR U2! BUTEE_mstr record not found to update.".                                   /* 2dot3 */*/

EXPORT STREAM outward DELIMITER ";"                                                                      /* 2dot3 */
    ERROR-count[6] "ERROR! Something Unexpected Happened!.".                                             /* 2dot3 */
    
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
