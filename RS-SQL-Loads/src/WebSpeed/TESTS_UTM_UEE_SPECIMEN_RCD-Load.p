
/*------------------------------------------------------------------------
    File        : TESTS_UTM_UEE_SPECIMEN_RCD-Load.p
    Purpose     : Load the TESTS_UTM_UEE_SPECIMEN_RCD from SQL. 

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
        Fixed e-mail format to match others.
        Identified by /* 1dot2 */   
             
    1.3 - written by HAROLD LUTTRELL JR. on 03/Oct/17.  Changed to use
            single rcode PROPATH settings pursuant to the rules of
            Release 12 (CMC structure).  Need to include the RUN VALUE(SEARCH
            style commands and eliminate the C: vs. P: business.  Marked by 1dot3. 
                           
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE TEMP-TABLE tt LIKE TESTS_UTM_UEE_SPECIMEN_RCD.

DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount3           AS INTEGER NO-UNDO.                                                     /* 1dot1 */
DEFINE VARIABLE IP-Kountbadformat   AS INTEGER NO-UNDO.                                                     /* 1dot1 */ 
DEFINE VARIABLE ip-seq-nbr          AS INTEGER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                              

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

/* 1dot1 */                                                                                                 /* 1dot1 */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report Attached from "                   NO-UNDO.    /* 1dot2 */
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.    /* 1dot2 */
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.                                  /* 1dot2 */
   
DEFINE STREAM outward.
DEFINE VARIABLE loadlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\SQL-Load-TESTS_UTM_UEE_SPECIMEN_RCD-log.txt" NO-UNDO.

OUTPUT STREAM outward TO value(loadlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "Patient ID:"
    "Sample ID Nbr:"
    "Seq:"
    "Description:".  
 
/* 1dot1 */

/* ***************************  Main Block  *************************** */

INPUT FROM VALUE(SEARCH("Input-Files\TESTS_UTM_UEE_SPECIMEN_RCD_NONULLS.txt")).               /* 1dot3 */

/*IF drive_letter = "P" THEN                                                                             */
/*    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\TESTS_UTM_UEE_SPECIMEN_RCD_NONULLS.txt".      */
/*ELSE                                                                                                   */
/*    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\TESTS_UTM_UEE_SPECIMEN_RCD_NONULLS.txt".*/
 
    REPEAT:

        CREATE tt.
                                                                    
        IMPORT DELIMITER "|" tt.        
                    
        IP-Kount1 = (IP-Kount1 + 1).

    END.  /** REPEAT **/ 
   
INPUT CLOSE.  

Main_loop: 
FOR EACH tt NO-LOCK:
               
        IF  tt.PatientID > 0 THEN DO: 

/* 1dot1 */ 
            FIND FIRST TESTS_UTM_UEE_SPECIMEN_RCD
                WHERE 
                        TESTS_UTM_UEE_SPECIMEN_RCD.PatientID             = DECIMAL(tt.PatientID) AND 
                        TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid          = tt.Lab_Sampleid AND 
                        TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr   = DECIMAL(tt.Lab_Sampleid_SeqNbr) AND 
                        TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv             = tt.Test_Abbv
                    EXCLUSIVE-LOCK NO-ERROR.                                                        
            
            IF AVAILABLE (TESTS_UTM_UEE_SPECIMEN_RCD) THEN DO:                                               
                
                ASSIGN  
                        IP-Kount3 = (IP-Kount3 + 1).                                                           
                                 
                EXPORT STREAM outward DELIMITER ";"                                                 
                    TESTS_UTM_UEE_SPECIMEN_RCD.PatientID                                                
                    TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid                                  
                    TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr                                                                     
                    "Replaced TESTS_UTM_UEE_SPECIMEN_RCD.".  
                                   
/*                DISPLAY STREAM outward                                        */
/*                        {&this-table}.magento-id                           */
/*                        ERROR-STATUS:GET-MESSAGE (1)   FORMAT "x(100)" SKIP(1)*/
/*                    WITH FRAME outdetail1 WIDTH 132 DOWN.                     */
/*                    DOWN WITH FRAME outdetailE1.                              */
                                        
                DELETE  TESTS_UTM_UEE_SPECIMEN_RCD  NO-ERROR.                                              
                 
            END.  /** IF AVAILABLE (TESTS_UTM_UEE_SPECIMEN_RCD) **/    

/* 1dot1 */  
         
            CREATE TESTS_UTM_UEE_SPECIMEN_RCD.
        
            ASSIGN     
                TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid = tt.Lab_Sampleid
                TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr = tt.Lab_Sampleid_SeqNbr
                TESTS_UTM_UEE_SPECIMEN_RCD.PatientID = tt.PatientID
                TESTS_UTM_UEE_SPECIMEN_RCD.Progress_DateTime = DATE(tt.Progress_DateTime)
                TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = tt.Progress_Flag
                TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv = tt.Test_Abbv
                TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Collection_Period = tt.UTM_UEE_Collection_
                TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_pH_upon_receipt = tt.UTM_UEE_pH_upon_recei
                TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Provocation = tt.UTM_UEE_Provocation
                TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Provoking_Agent = tt.UTM_UEE_Provoking_Age
                TESTS_UTM_UEE_SPECIMEN_RCD.UTM_UEE_Volume = tt.UTM_UEE_Volume  
            .  
            
            IF TESTS_UTM_UEE_SPECIMEN_RCD.Progress_DateTime = ? THEN 
                ASSIGN TESTS_UTM_UEE_SPECIMEN_RCD.Progress_DateTime = TODAY. 

            EXPORT STREAM outward DELIMITER ";"                                                 
                    TESTS_UTM_UEE_SPECIMEN_RCD.PatientID                                                
                    TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid                                  
                    TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr                                                                     
                    "New TESTS_UTM_UEE_SPECIMEN_RCD.". 
                                    
            RELEASE TESTS_UTM_UEE_SPECIMEN_RCD.
        
            IP-Kount2 = (IP-Kount2 + 1).
            
        END.    /** IF tt.Doctor_Last_Name <>   **/
    
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
/* 1dot1 */   
           
/** end of program **/
