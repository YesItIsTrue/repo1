 
/*------------------------------------------------------------------------
    File        : RStP-BUTEE-U-3.p
    Purpose     : To convert the old RS database into the new HHI databse, 
        specifically tests that are related to urine. 

    Syntax      :

    Description : The other half of the RStP-BUTEE-U.p This one is for all
        the random Test Kit Types that are not in the 
        TESTS_UTM_UEE_SPECIMEN_RCD table.  Which apparently are only UAA's.
        Locking it down to only UAA's with version 3.1

    Author(s)   : Trae Luttrell
    Created     : Fri Jan 30 20:53:06 MST 2015
    Updated     : Thu Jun 02 08:24:00 EST 2016
    Version     : 3.1
    Notes       : There are two variables that control the behavior of this
                    code for testing purposes.  They are FIRSTRUN and LIMITRUN.
                    FIRSTRUN is a logical that was created to support the fact
                    that changes could have occurred since the Add of the data
                    via some sort of Update.  Thus, FIRSTRUN = YES causes the 
                    program to treat Updates as Adds.  LIMITRUN is primarily for
                    testing purposes and is an integer representing the number
                    of records that should be processed.  If it is set to 0 it
                    will process All the records, rather than None of the records. 
        
********************************************************************************
* 
*  Revision History:
*  -----------------
*  1.0 - written by TRAE LUTTRELL on 30/Jan/15.  Original Version.
*  1.1 - written by DOUG LUTTRELL on 31/Jan/15.  Bug fixes.  Marked by 1dot1.
*  1.2 - altered by Trae Luttrell on 27/May/15. 
    Renaming:
      RStP-BUTEE-U-1 = RStP-BUTEE-U-1
      RStP-BUTEE-U-2 = RStP-BUTEE-U-2
      RStP-BUTEE2-U-1 = RStP-BUTEE-U-3
      RStP-BUTEE2-U-2 = RStP-BUTEE-U-4
*
*  1.3 - By Harold Luttrell on 24/Jul/15.
        a.  Added more output data displays for the error log report.  
        b.  Added the THIS-PROCEDURE:FILE-NAME assign to xxx_prog_name.
        c.  Added the emailaddr-USERID.i code.
        d.  Added total count for each ERROR! message.
        e.  Removed the preprocessor references to 
            {&this-table}, which was pointing at TESTS_RESULT_RCD.
            I did NOT marked this change because there was so many of them I
            didn't want to make the code look junkie.
        Marked by 1dot3.
* 
         
    Version: 2.0    By Harold Luttrell, Sr.
    Date: 5/Mar/16.
    Description:    Changed database field name from 
                        TK_mstr.TK_testtype to TK_mstr.TK_test_type.                    
    Identified by /* 2dot0 */  
    
  3.1 - written by DOUG LUTTRELL on 02/Jun/16.  The continuing saga of the change in the way we 
            identify the old testkits.  See RStP-TESTS_RESULTS_RCD-U-1.p for more details.  Not 
            really marked due to quantity of changes, but possibly marked by 3dot1.  
            Also found that this is only applicable to UAA test types, so locked it down to those.
            Looks like this particular code was responsible for a bunch of different problems with
            testkits of lots of different types being flagged wrong and reacted to differently.  
            This program might actually have been responsible for some of the more major discrepancies
            that we've seen in the tests coming over.
    
    
********************************************************************************        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/** specific to this program **/   


/** useful for all RStP code **/
DEFINE VARIABLE limitrun AS INTEGER INITIAL 0 NO-UNDO.         /** a non-zero number will limit processing to that many records **/
DEFINE VARIABLE firstrun AS LOGICAL INITIAL NO NO-UNDO.        /* change to YES for second program (RStP-BUTEE-U-4.p) */

DEFINE VARIABLE v-tkid LIKE TK_mstr.TK_ID NO-UNDO.                              /* 3dot1 */
DEFINE VARIABLE v-tkseq LIKE TK_mstr.TK_test_seq NO-UNDO.                       /* 3dot1 */

DEFINE VARIABLE loadedlist AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO.    
   
DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 20 NO-UNDO.                        /* 1dot3 */

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
    
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RStP-BUTEE-U-log-3.txt" NO-UNDO.   /* change to 4 for second program (RStP-BUTEE-U-4.p) */

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"                                             /* these are column headers */
    "TESTS_RESULT_RCD.PatientID" "TESTS_RESULT_RCD.Lab_Sampleid" "TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr" "Error Message".


/* ********************  Preprocessor Definitions  ******************** */      
/*&SCOPED-DEFINE this-table   TESTS_RESULT_RCD*/                                /* 1dot3 */ 
 
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
FOR EACH TESTS_RESULT_RCD WHERE LOOKUP(TESTS_RESULT_RCD.Progress_Flag,loadedlist) = 0 AND 
        TESTS_RESULT_RCD.Test_Abbv = "UAA":         /* 3dot1 */

    recordsprocessed = recordsprocessed + 1.
    
    IF (limitrun > 0) AND (recordsprocessed > limitrun) THEN 
        LEAVE main-block.

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

    IF (TESTS_RESULT_RCD.Progress_Flag = "" AND TESTS_RESULT_RCD.Test_Abbv = "UAA") OR 
        (TESTS_RESULT_RCD.Progress_Flag = "A" AND TESTS_RESULT_RCD.Test_Abbv = "UAA") OR 
        (firstrun = YES AND TESTS_RESULT_RCD.Progress_Flag = "U" AND TESTS_RESULT_RCD.Test_Abbv = "UAA")                  /* this line is for the initial load only */

    THEN DO:                           /** Begin ADD section **/
                
        ASSIGN 
            BUTEE_mstr.BUTEE_creatinine     = TESTS_RESULT_RCD.CCreatinine
            BUTEE_mstr.BUTEE_modified_by    = USERID("HHI")                 /* 1dot3 */  /* was General - WRONG database. */
            BUTEE_mstr.BUTEE_modified_date  = TODAY 
            BUTEE_mstr.BUTEE_prog_name      = THIS-PROCEDURE:FILE-NAME.      /* 1dot3 */ 

/*Commented out IN VERSION 3dot1 because this would cause other records NOT TO be created.                                                                                                   */
/*                                                                                                                                                                                           */
/*            TESTS_RESULT_RCD.Progress_Flag     = IF TESTS_RESULT_RCD.Progress_Flag = "A" THEN                                                                                              */
/*                                    "AL"                                                                    /** update the RS database so we don't re-pull --- stands for Add Loaded **/   */
/*                                    ELSE IF TESTS_RESULT_RCD.Progress_Flag = "U" THEN                                                                                                      */
/*                                        "UL"                                                                                                                                               */
/*                                    ELSE                                                                                                                                                   */
/*                                        "IL".                                                               /** update the RS database so we don't re-pull --- stands for Import Loaded **/*/
        
    END.  /*** of progress_flag = blank or A --- create a record ***/

/************************************************************************************
 *  Begin DELETE section
 ************************************************************************************/  
    
    ELSE IF TESTS_RESULT_RCD.Progress_Flag = "D" THEN DO:                                                          /** Begin DELETE section */
                
        ASSIGN
            BUTEE_mstr.BUTEE_deleted       = TODAY 
            BUTEE_mstr.BUTEE_modified_by   = USERID("HHI")                 /* 1dot3 */  /* was General - WRONG database. */
            BUTEE_mstr.BUTEE_modified_date = TODAY 
            BUTEE_mstr.BUTEE_prog_name     = THIS-PROCEDURE:FILE-NAME.      /* 1dot3 */
            
/*Commented out IN VERSION 3dot1 because this would cause other records NOT TO be created.  */
/*            TESTS_RESULT_RCD.Progress_Flag = "DL".                                        */
        
    END.  /**** of else if progress_flag = D --- Delete a record ****/
      
/*************************************************************************************
 *  Begin UPDATE section 
 *************************************************************************************/        
    
    ELSE IF (TESTS_RESULT_RCD.Progress_Flag = "U" AND firstrun = NO) THEN DO:                         /*** Begin UPDATE section ***/
     
        ASSIGN 
            BUTEE_mstr.BUTEE_creatinine     = TESTS_RESULT_RCD.CCreatinine
            BUTEE_mstr.BUTEE_modified_by    = USERID("HHI")                 /* 1dot3 */  /* was General - WRONG database. */
            BUTEE_mstr.BUTEE_modified_date  = TODAY     
            BUTEE_mstr.BUTEE_prog_name      = THIS-PROCEDURE:FILE-NAME.      /* 1dot3 */
            
/*Commented out IN VERSION 3dot1 because this would cause other records NOT TO be created.                                                */
/*            TESTS_RESULT_RCD.Progress_Flag  = "UL".      /** update the RS database so we don't re-pull --- stands for Update Loaded **/*/
                           
    END.  /*** of else if progress_flag = U --- Update a record ***/
    
    ELSE DO: 
        
        EXPORT STREAM outward DELIMITER ";"
            TESTS_RESULT_RCD.PatientID 
                    TESTS_RESULT_RCD.Lab_Sampleid 
                    TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr 
                    "ERROR! Something Unexpected Happened!.".      /* yet ironically I coded for it */
         
         ASSIGN ERROR-count[5] = ERROR-count[5]  + 1.                            /* 1dot3 */
         
         /* If this condition occured you should check the loadlist variable and    */
         /* also the Progress_Flag field.                                           */
    
    END.  /*** of else do --- unexpected error! ***/
   
END.  /** of 4ea. TESTS_UTM_UEE_SPECIMEN_RCD **/

EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Records Processed".   
    
EXPORT STREAM outward DELIMITER ";"                                                         /* 1dot3 */
    ERROR-count[1] "ERROR A2! TESTS_RESULT_RCD record not found in the TK_mstr.".           /* 1dot3 */
EXPORT STREAM outward DELIMITER ";"                                                         /* 1dot3 */
    ERROR-count[2] "ERROR A3! TESTS_RESULT_RCD record already exists in BUTEE_mstr.".   /* 1dot3 */
EXPORT STREAM outward DELIMITER ";"                                                         /* 1dot3 */
    ERROR-count[3] "ERROR 2D! TESTS_RESULT_RCD record already deleted!.".                   /* 1dot3 */   
EXPORT STREAM outward DELIMITER ";"                                                         /* 1dot3 */
    ERROR-count[4] "ERROR 2U! TESTS_RESULT_RCD record unavailable to update!.".             /* 1dot3 */     
EXPORT STREAM outward DELIMITER ";"                                                         /* 1dot3 */
    ERROR-count[5] "ERROR! Something Unexpected Happened!.".                                /* 1dot3 */ 

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
