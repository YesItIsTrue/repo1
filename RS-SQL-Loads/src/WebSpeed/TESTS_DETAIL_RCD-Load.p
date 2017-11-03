
/*------------------------------------------------------------------------
    File        : TESTS_DETAIL_RCD-Load.p
    Purpose     : Load the TESTS_DETAIL_RCD from SQL. 

    Syntax      :

    Description : 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Sat Mar 15 10:26:11 CDT 2014
    
    Revision History:        
    -----------------
    1.0 - written by Harold LUTTRELL on 26/Dec/14.  Original version.
          
    1.1 - Fed 26, 2015 - Added a FIND statement to see if the input 
                            exists and if so then DELETE it.
                         Added the e-mailing of the log report.
          Identified by: 1dot1.
          
    Version: 1.2    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Fixed the e-mail format to match others.
        Identified by /* 1dot2 */
                  
    1.3 - written by HAROLD LUTTRELL JR. on 03/Oct/17.  Changed to use
            single rcode PROPATH settings pursuant to the rules of
            Release 12 (CMC structure).  Need to include the RUN VALUE(SEARCH
            style commands and eliminate the C: vs. P: business.  Marked by 1dot3.                  
                  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE TEMP-TABLE tt LIKE TESTS_DETAIL_RCD.

DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount3           AS INTEGER NO-UNDO.                                                     /* 1dot1 */
DEFINE VARIABLE IP-Kountbadformat   AS INTEGER NO-UNDO.                                                     /* 1dot1 */ 
DEFINE VARIABLE ip-found            AS INTEGER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */

 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                               

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

/* 1dot1 */                                                                                                 /* 1dot1 */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"     NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"           NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report Attached from "               NO-UNDO.    /* 1dot2 */
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                        NO-UNDO.    /* 1dot2 */
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                           NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.                                  /* 1dot2 */
   
DEFINE STREAM outward.
DEFINE VARIABLE loadlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\SQL-Load-TESTS_DETAIL_RCD-log.txt" NO-UNDO.

OUTPUT STREAM outward TO value(loadlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "Patient ID:"
    "Sample ID Nbr:"
    "Seq:"
    "Test Abbv"
    "Element Item"
    "Flag"
    "Description:".  
 
/* 1dot1 */        

DEFINE VARIABLE v-testvar AS CHARACTER FORMAT "x(40)" NO-UNDO.

/* ***************************  Main Block  *************************** */

INPUT FROM VALUE(SEARCH("Input-Files\TESTS_DETAIL_RCD_NONULLS.txt")).               /* 1dot3 */
 
    REPEAT:

        CREATE tt.
                                                                    
        IMPORT DELIMITER "|" tt.        
                    
        IP-Kount1 = (IP-Kount1 + 1).

    END.  /** REPEAT **/ 
   
INPUT CLOSE.  

ASSIGN ip-found = 0.
 
Main_loop: 
FOR EACH tt NO-LOCK:
               
        IF  tt.PatientID > 0 THEN DO: 
            
/* 1dot1 */ 
            FIND FIRST TESTS_DETAIL_RCD
                WHERE
                        TESTS_DETAIL_RCD.PatientID           = DECIMAL(tt.PatientID) AND
                        TESTS_DETAIL_RCD.Lab_Sampleid        = tt.Lab_Sampleid AND
                        TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr = DECIMAL(tt.Lab_Sampleid_SeqNbr) AND
                        TESTS_DETAIL_RCD.Test_Abbv           = tt.Test_Abbv AND 
                        TESTS_DETAIL_RCD.Test_Element_Item   = tt.Test_Element_Item
                    EXCLUSIVE-LOCK NO-ERROR.
 
            IF AVAILABLE (TESTS_DETAIL_RCD) THEN DO:

                ASSIGN
                        IP-Kount3 = (IP-Kount3 + 1).

                EXPORT STREAM outward DELIMITER ";"
                    TESTS_DETAIL_RCD.PatientID
                    TESTS_DETAIL_RCD.Lab_Sampleid
                    TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr
                    TESTS_DETAIL_RCD.Test_Abbv
                    TESTS_DETAIL_RCD.Test_Element_Item
                    TESTS_DETAIL_RCD.Progress_Flag
                    "Deleted TESTS_DETAIL_RCD.".

/*                IF  DECIMAL(tt.PatientID)   <> ip-hold-patid    AND                       */
/*                    tt.Lab_Sampleid         <> ip-hold-lab-sampleid AND                   */
/*                    DECIMAL(tt.Lab_Sampleid_SeqNbr) <> ip-hold-seqnbr THEN DO:            */
/*                        ASSIGN  ip-found = 1                                              */
/*                                ip-hold-patid           = DECIMAL(tt.PatientID)           */
/*                                ip-hold-lab-sampleid    = tt.Lab_Sampleid                 */
/*                                ip-hold-seqnbr          = DECIMAL(tt.Lab_Sampleid_SeqNbr).*/
/*                END.                                                                      */

                DELETE  TESTS_DETAIL_RCD  NO-ERROR.

            END.  /** IF AVAILABLE (TESTS_DETAIL_RCD) **/

/* 1dot1 */      
    
            CREATE TESTS_DETAIL_RCD.
        
            ASSIGN     
                TESTS_DETAIL_RCD.Lab_Sampleid = tt.Lab_Sampleid
                TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr = tt.Lab_Sampleid_SeqNbr
                TESTS_DETAIL_RCD.PatientID = tt.PatientID
                TESTS_DETAIL_RCD.Progress_DateTime = DATE(tt.Progress_DateTime)
                TESTS_DETAIL_RCD.Progress_Flag = tt.Progress_Flag
                TESTS_DETAIL_RCD.TestMeanSD = tt.TestMeanSD
                TESTS_DETAIL_RCD.TestMinusSD = tt.TestMinusSD
                TESTS_DETAIL_RCD.TestPlusSD = tt.TestPlusSD
                TESTS_DETAIL_RCD.TestRefInterval = tt.TestRefInterval
                TESTS_DETAIL_RCD.Test_Abbv = tt.Test_Abbv
                TESTS_DETAIL_RCD.Test_Element_Item = tt.Test_Element_Item
                TESTS_DETAIL_RCD.Test_Norm_Value = tt.Test_Norm_Value
                TESTS_DETAIL_RCD.Test_ResultAlph = tt.Test_ResultAlph
                TESTS_DETAIL_RCD.Test_ResultVal = tt.Test_ResultVal
            .  
            
            IF TESTS_DETAIL_RCD.Progress_DateTime = ? THEN 
                ASSIGN TESTS_DETAIL_RCD.Progress_DateTime = TODAY. 

/*            IF DECIMAL(tt.Lab_Sampleid_SeqNbr) = 1 THEN*/
                EXPORT STREAM outward DELIMITER ";"
                    TESTS_DETAIL_RCD.PatientID
                    TESTS_DETAIL_RCD.Lab_Sampleid
                    TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr
                    TESTS_DETAIL_RCD.Test_Abbv
                    TESTS_DETAIL_RCD.Test_Element_Item
                    TESTS_DETAIL_RCD.Progress_Flag 
                    "New TESTS_DETAIL_RCD.".
                                    
            RELEASE TESTS_DETAIL_RCD.
        
            IP-Kount2 = (IP-Kount2 + 1).
            ip-found = 0.
            
        END.    /** tt.PatientID > 0   **/
    
END.    /** FOR EACH tt **/
 
/* 1dot1 */                                                                                                 /* 1dot1 */
EXPORT STREAM outward DELIMITER ";"
    999999999 
    "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").   
     
EXPORT STREAM outward DELIMITER ";"
    IP-Kount1 " Records imported.".
    
EXPORT STREAM outward DELIMITER ";"
    IP-Kount3 " Records replaced.".
    
EXPORT STREAM outward DELIMITER ";"
    IP-Kountbadformat " Data not formatted correctly.  Input NOT loaded.".   

EXPORT STREAM outward DELIMITER ";"
    IP-Kount2 " Records added to the database.".
    
OUTPUT STREAM outward CLOSE.

IF drive_letter = "C" THEN 
    ASSIGN  emailaddr   = "-r harold.luttrell@mysolsource.com".

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(loadlog).
/* 1dot1 */                                                                                                 /* 1dot1 */
      
           
/** end of program **/
