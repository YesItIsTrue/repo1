
/*------------------------------------------------------------------------
    File        : Cleanup-UTM-7-3-U.p
    Purpose     : 

    Syntax      :

    Description : Check all of the different tables to make sure that the 
                    UTM value in the various testtype fields is only 3 characters long
                    instead of 7 characters long.  Problem is there are 4 spaces 
                    following the UTM and the 4 spaces must be removed for the
                    RStP programs.
                    Designed to be run repeatedly in batch.

    Author(s)   : Harold Luttrell
    Created     : Feb 3, 2015
    Notes       :
    Databases   : General
                  HHI
                  RS.
                  
    Tables:     :   trh_hist
                    TK_mstr
                    Test_mstr
                    TESTS_ABBV_RCD
                    TESTS_RESULT_RCD
                    TESTS_DETAIL_RCD
                    TESTS_UTM_UEE_SPECIMEN_RCD.
                    
  ----------------------------------------------------------------------
  Revision History:        
  -----------------
  1.0 - written by Harold LuttrellL on 3/Feb/15.  Original version.
  
  1.1 - 
  ----------------------------------------------------------------------
   
  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE update-UTM  AS LOG INITIAL YES   NO-UNDO.           /**  change to YES to UPDATE the records. !!!!!!! */


/** useful for all RStP code **/
&SCOPED-DEFINE UTM-Y-N    update-UTM

DEFINE VARIABLE loadedlist AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.   

        /* these are 5 settings to control the emailing of the output file */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Log Report Attached from HHI-DC-4. "           NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Log Report from Cleanup-UTM-7-3-U.p"           NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
   
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\Cleanup-UTM-7-3-U-Log.txt" NO-UNDO.                /* change this to be a filename specific to your program */

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"                                             /* These are column headers. You need one for each field    */
    "Test Kit Nbr"                                                      /* that is required for uniqueness in the SOURCE record.    */
    "Error Message".                                                            /* And then this one for the error message column.          */


DEFINE VARIABLE HHI-TK_mstr-processed                   AS INTEGER NO-UNDO. 
DEFINE VARIABLE HHI-TK_mstr-changed                     AS INTEGER NO-UNDO.
DEFINE VARIABLE HHI-test_mstr-processed                 AS INTEGER NO-UNDO. 
DEFINE VARIABLE HHI-test_mstr-changed                   AS INTEGER NO-UNDO.
DEFINE VARIABLE RS-tests_result-processed               AS INTEGER NO-UNDO. 
DEFINE VARIABLE RS-tests_result-changed                 AS INTEGER NO-UNDO.
DEFINE VARIABLE RS-tests_detail-processed               AS INTEGER NO-UNDO. 
DEFINE VARIABLE RS-tests_detail-changed                 AS INTEGER NO-UNDO.
DEFINE VARIABLE RS-tests_UTM-UEE-Specimen-processed     AS INTEGER NO-UNDO. 
DEFINE VARIABLE RS-tests_UTM-UEE-Specimen-changed       AS INTEGER NO-UNDO.
DEFINE VARIABLE RS-test_abbv-processed                  AS INTEGER NO-UNDO. 
DEFINE VARIABLE RS-test_abbv-changed                    AS INTEGER NO-UNDO.
DEFINE VARIABLE General-trh_hist-processed              AS INTEGER NO-UNDO. 
DEFINE VARIABLE General-trh_hist-changed                AS INTEGER NO-UNDO.

/* ***************************  Main Block  *************************** */
EXPORT STREAM outward DELIMITER ";"
        " ".
                        
IF update-UTM = NO THEN  
    EXPORT STREAM outward DELIMITER ";"
        update-UTM               
        " <<<<  NO records will be updated - -  only record counts will be produced.".
ELSE 
    EXPORT STREAM outward DELIMITER ";"
        update-UTM               
        " <<<<  Records will be updated    and   record counts will be produced.".
EXPORT STREAM outward DELIMITER ";"
        " ".        
        
/* HHI database Tables. */
/* Clean up the HHI.TK_mstr */
FOR EACH TK_mstr WHERE TK_mstr.TK_TEST_TYPE BEGINS "UTM" AND  
   TK_mstr.TK_test_type <> "UTM / UEE"  : 

   SET HHI-TK_mstr-processed = HHI-TK_mstr-processed + 1.
   
   IF update-UTM = YES THEN
       ASSIGN TK_mstr.TK_test_type = TRIM(TK_mstr.TK_test_type)
            HHI-TK_mstr-changed = HHI-TK_mstr-changed + 1. 

END.  /** of 4ea. HHI.TK_mstr **/

/* Clean up the HHI.test_mstr */
FOR EACH test_mstr   : 
       
    ASSIGN HHI-test_mstr-processed = HHI-test_mstr-processed + 1.
           
    IF update-UTM = YES THEN                 
       ASSIGN  test_mstr.test_type = TRIM(test_mstr.test_type)
               HHI-test_mstr-changed = HHI-test_mstr-changed + 1.                            
    
END.  /** of 4ea. HHI.test_mstr **/


/* RS database Tables. */
/* Clean up the RS.TESTS_RESULT_RCD */
FOR EACH TESTS_RESULT_RCD
   WHERE TESTS_RESULT_RCD.Test_Abbv BEGINS "UTM" AND  TESTS_RESULT_RCD.Test_Abbv <> "UTM / UEE"  :

   ASSIGN RS-tests_result-processed = RS-tests_result-processed + 1.
           
   IF update-UTM = YES THEN                 
      ASSIGN  TESTS_RESULT_RCD.Test_Abbv = TRIM(TESTS_RESULT_RCD.Test_Abbv)
              RS-tests_result-changed = RS-tests_result-changed + 1.  
    
END.  /** of 4ea. RS.TESTS_RESULT_RCD **/

/* Clean up the RS.TESTS_DETAIL_RCD */
FOR EACH TESTS_DETAIL_RCD 
    WHERE TESTS_DETAIL_RCD.Test_Abbv BEGINS "UTM" AND  TESTS_DETAIL_RCD.Test_Abbv <> "UTM / UEE"  :
        
    ASSIGN RS-tests_detail-processed = RS-tests_detail-processed + 1.

    IF update-UTM = YES THEN
       ASSIGN  TESTS_DETAIL_RCD.Test_Abbv = TRIM(TESTS_DETAIL_RCD.Test_Abbv)
               RS-tests_detail-changed = RS-tests_detail-changed + 1. 
    
END.  /** of 4ea. RS.TESTS_DETAIL_RCD **/

/* Clean up the RS.TESTS_UTM_UEE_SPECIMEN_RCD */
FOR EACH TESTS_UTM_UEE_SPECIMEN_RCD WHERE TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv BEGINS "UTM" AND  
    TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv <> "UTM / UEE"  : 
        
    ASSIGN RS-tests_UTM-UEE-Specimen-processed = RS-tests_UTM-UEE-Specimen-processed + 1.
          
    IF update-UTM = YES THEN                 
       ASSIGN TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv = TRIM(TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv)
              RS-tests_UTM-UEE-Specimen-changed = RS-tests_UTM-UEE-Specimen-changed + 1. 
    
END.  /** of 4ea. RS.TESTS_UTM_UEE_SPECIMEN_RCD **/

/*/* Clean up the RS.TESTS_ABBV_RCD */                                   */
/*FOR EACH TESTS_ABBV_RCD   :                                            */
/*                                                                       */
/*    ASSIGN RS-test_abbv-processed = RS-test_abbv-processed + 1.        */
/*                                                                       */
/*    IF update-UTM = YES THEN                                           */
/*       ASSIGN TESTS_ABBV_RCD.Test_Abbv = TRIM(TESTS_ABBV_RCD.Test_Abbv)*/
/*              RS-test_abbv-changed = RS-test_abbv-changed + 1.         */
/*                                                                       */
/*END.  /** of 4ea. RS.TESTS_ABBV_RCD **/                                */


/* Gemeral database Table. */
/* Clean up the General.trh_hist */
FOR EACH trh_hist 
    WHERE trh_hist.trh_item BEGINS "UTM" AND  trh_hist.trh_item <> "UTM / UEE"  :
    
    ASSIGN General-trh_hist-processed = General-trh_hist-processed + 1.
        
    IF update-UTM = YES THEN                 
       ASSIGN trh_hist.trh_item = TRIM(trh_hist.trh_item) 
              General-trh_hist-changed = General-trh_hist-changed + 1.    
    
END.  /** of 4ea. General.trh_hist **/


/** closing off the output file **/
EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"    
    HHI-TK_mstr-processed "HHI.TK_mstr Processed".
EXPORT STREAM outward DELIMITER ";"
    HHI-TK_mstr-changed "HHI.TK_mstr Changed".
EXPORT STREAM outward DELIMITER ";"    
    HHI-test_mstr-processed "HHI.test_mstr Processed".
EXPORT STREAM outward DELIMITER ";"
    HHI-test_mstr-changed "HHI.test_mstr Changed".
EXPORT STREAM outward DELIMITER ";"    
    RS-tests_result-processed "RS.TESTS_RESULT_RCD Processed".
EXPORT STREAM outward DELIMITER ";"
    RS-tests_result-changed "RS.TESTS_RESULT_RCD Changed". 
EXPORT STREAM outward DELIMITER ";"    
    RS-tests_detail-processed "RS.TESTS_DETAIL_RCD Processed".
EXPORT STREAM outward DELIMITER ";"
    RS-tests_detail-changed "RS.TESTS_DETAIL_RCD Changed".  
EXPORT STREAM outward DELIMITER ";"    
    RS-tests_UTM-UEE-Specimen-processed "RS.TESTS_UTM_UEE_SPECIMEN_RCD Processed".
EXPORT STREAM outward DELIMITER ";"
    RS-tests_UTM-UEE-Specimen-changed "RS.TESTS_UTM_UEE_SPECIMEN_RCD Changed".  
EXPORT STREAM outward DELIMITER ";"    
    RS-test_abbv-processed "RS.TESTS_ABBV_RCD Processed".
EXPORT STREAM outward DELIMITER ";"
    RS-test_abbv-changed "RS.TESTS_ABBV_RCD Changed".
EXPORT STREAM outward DELIMITER ";"    
    General-trh_hist-processed "General.trh_hist Processed".
EXPORT STREAM outward DELIMITER ";"
    General-trh_hist-changed "General.trh_hist Changed".       
OUTPUT STREAM outward CLOSE.

/* emailing the output file */
OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).
    
/*************************  END OF FILE  **************************/
