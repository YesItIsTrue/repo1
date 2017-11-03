
/*------------------------------------------------------------------------
    File        : TESTS_RESULT_RCD-Load.p
    Purpose     : Load the TESTS_RESULT_RCD from SQL. 

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
        Changed RUN statement paths to use the rcode folder and to
            use the .r program extensions.
        Identified by /* 1dot2 */
        
    1.3 - written by HAROLD LUTTRELL JR. on 03/Oct/17.  Changed to use
            single rcode PROPATH settings pursuant to the rules of
            Release 12 (CMC structure).  Need to include the RUN VALUE(SEARCH
            style commands and eliminate the C: vs. P: business.  Marked by 1dot3. 
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE TEMP-TABLE tt
    FIELD     PatientID                     AS CHARACTER  FORMAT  "x(6)"
    FIELD     Lab_Sampleid                  AS CHARACTER  FORMAT  "x(30)"
    FIELD     Lab_Sampleid_SeqNbr           AS CHARACTER  FORMAT  "x(2)"
    FIELD     Test_LAB_Name                 AS CHARACTER  FORMAT  "x(45)"
    FIELD     Test_Abbv                     AS CHARACTER  FORMAT  "x(20)"
    FIELD     Test_PatAGE                   AS CHARACTER  FORMAT  "x(20)"
    FIELD     DateCollected                 AS CHARACTER  FORMAT  "x(30)"
    FIELD     DateReceived                  AS CHARACTER  FORMAT  "x(30)"
    FIELD     DateCompleted                 AS CHARACTER  FORMAT  "x(30)"
    FIELD     CCreatinine                   AS CHARACTER  FORMAT  "x(30)"               
    FIELD     Test_Kit_Nbr                  AS CHARACTER  FORMAT  "x(30)"
    FIELD     Comments                      AS CHARACTER  FORMAT  "x(200)"
    FIELD     Special_Note                  AS CHARACTER  FORMAT  "x(200)"
    FIELD     Tests_Result_date_processed   AS CHARACTER  FORMAT  "x(60)"
    FIELD     Progress_Flag                 AS CHARACTER  FORMAT  "x(1)"
    FIELD     Progress_DateTime             AS CHARACTER  FORMAT  "x(60)"    
                    INDEX temp-data AS PRIMARY PatientID.


DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount3           AS INTEGER NO-UNDO.                                                     /* 1dot1 */
DEFINE VARIABLE IP-Kountbadformat   AS INTEGER NO-UNDO.                                                     /* 1dot1 */ 
DEFINE VARIABLE ip-found            AS INTEGER NO-UNDO.
DEFINE VARIABLE check_date          AS DATE  NO-UNDO.
DEFINE VARIABLE check_date_time     AS DATETIME NO-UNDO.
DEFINE VARIABLE jerk_date_around    AS CHARACTER FORMAT "x(40)" NO-UNDO.  
DEFINE VARIABLE ip_text             AS CHARACTER FORMAT "x(40)" NO-UNDO.
DEFINE VARIABLE op_text             AS CHARACTER FORMAT "x(40)" NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
 
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                             

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

/* 1dot1 */                                                                                                 /* 1dot1 */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from  "                  NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME. 
   
DEFINE STREAM outward.
DEFINE VARIABLE loadlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\SQL-Load-TESTS_RESULT_RCD-log.txt" NO-UNDO.

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
    "Testkit ID:" 
    "Description:".  
 
/* 1dot1 */                                                                                                 /* 1dot1 */

/* ***************************  Main Block  *************************** */


INPUT FROM VALUE(SEARCH("Input-Files\TESTS_RESULT_RCD_NONULLS.txt")).               /* 1dot3 */
/*                                                                                             */
/*IF drive_letter = "P" THEN                                                                   */
/*    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\TESTS_RESULT_RCD_NONULLS.txt".      */
/*ELSE                                                                                         */
/*    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\TESTS_RESULT_RCD_NONULLS.txt".*/
 
    REPEAT:

        CREATE tt.
                                                                    
        IMPORT DELIMITER "|" tt.        
                    
        IP-Kount1 = (IP-Kount1 + 1).

    END.  /** REPEAT **/ 
   
INPUT CLOSE. 
  
ASSIGN ip-found = 0.

Main_loop: 
FOR EACH tt NO-LOCK:
               
        IF  DECIMAL(tt.PatientID) > 0 THEN DO:  
/* 1dot1 */ 
            FIND FIRST TESTS_RESULT_RCD
                WHERE 
                        TESTS_RESULT_RCD.PatientID = DECIMAL(tt.PatientID) AND 
                        TESTS_RESULT_RCD.Lab_Sampleid = tt.Lab_Sampleid AND 
                        TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = DECIMAL(tt.Lab_Sampleid_SeqNbr) AND 
                        TESTS_RESULT_RCD.Test_Abbv           = tt.Test_Abbv AND 
                        TESTS_RESULT_RCD.Test_Kit_Nbr        = tt.Test_Kit_Nbr
                    EXCLUSIVE-LOCK NO-ERROR.                                                        
            
            IF AVAILABLE (TESTS_RESULT_RCD) THEN DO:                                               
                
                ASSIGN  
                        IP-Kount3 = (IP-Kount3 + 1).                                                            
                                 
                EXPORT STREAM outward DELIMITER ";"                                                 
                    TESTS_RESULT_RCD.PatientID                                                
                    TESTS_RESULT_RCD.Lab_Sampleid                                  
                    TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr                                 
                    TESTS_RESULT_RCD.Test_Abbv
                    TESTS_RESULT_RCD.Test_Kit_Nbr                                      
                    "Deleted TESTS_RESULT_RCD.".                 
                      
                DELETE  TESTS_RESULT_RCD  NO-ERROR.                                              
                 
            END.  /** IF AVAILABLE (TESTS_RESULT_RCD) **/    

/* 1dot1 */          
            CREATE TESTS_RESULT_RCD.
            
            IF tt.DateCollected <> '' THEN DO:
                  
                ASSIGN 
                    ip_text = tt.DateCollected.
                    
                RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot3 */                
/*                                                                                                                                   */
/*                IF drive_letter = "P" THEN                                                                                         */
/*                    RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*                ELSE                                                                                                               */
/*                    RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
/*                                                                                                                                   */

                ASSIGN 
                    tt.DateCollected = op_text.                           
                     
                ASSIGN 
                    check_date = DATE(tt.DateCollected) NO-ERROR.
                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO: 
                    MESSAGE "PatientID = " tt.PatientID " / DateCollected error = " tt.DateCollected
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. 
                    ASSIGN tt.DateCollected = ?.
                END.
            END. 
            IF tt.DateCollected = '' THEN 
                ASSIGN tt.DateCollected = '?'.                
                
            IF tt.DateReceived <> '' THEN DO:
              
                ASSIGN 
                    ip_text = tt.DateReceived.
                    
                RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot3 */    
                    
/*                IF drive_letter = "P" THEN                                                                                         */
/*                    RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*                ELSE                                                                                                               */
/*                    RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
                     
                ASSIGN 
                    tt.DateReceived = op_text.                           
                     
                ASSIGN 
                    check_date = DATE(tt.DateReceived) NO-ERROR.
                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
                    MESSAGE "PatientID = " tt.PatientID " / DateReceived error = " tt.DateReceived
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. 
                    ASSIGN tt.DateReceived = ?.
                END. 
            END. 
            IF tt.DateReceived = '' THEN 
                ASSIGN tt.DateReceived = '?'.
                                
            IF tt.DateCompleted <> '' THEN DO:
               
                ASSIGN 
                    ip_text = tt.DateCompleted.
                    
                RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot3 */    
                    
/*                IF drive_letter = "P" THEN                                                                                         */
/*                    RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*                ELSE                                                                                                               */
/*                    RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
                     
                ASSIGN 
                    tt.DateCompleted = op_text. 
                        
                ASSIGN 
                    check_date = DATE(tt.DateCompleted) NO-ERROR.
                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
                    MESSAGE "PatientID = " tt.PatientID " / DateCompleted error = " tt.DateCompleted
                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. 
                    ASSIGN tt.DateCompleted = ?.
                END.
            END.
            IF tt.DateCompleted = '' THEN 
                ASSIGN tt.DateCompleted = '?'.              
            
            IF tt.Tests_Result_date_processed <> '' THEN DO:
                   ASSIGN 
                       SUBSTRING(jerk_date_around, 1, 3) = SUBSTRING(tt.Tests_Result_date_processed, 6, 3).
                   ASSIGN 
                       SUBSTRING(jerk_date_around, 4, 2) = SUBSTRING(tt.Tests_Result_date_processed, 9, 2). 
                   ASSIGN 
                       SUBSTRING(jerk_date_around, 6, 1) = '-'.
                   ASSIGN 
                       SUBSTRING(jerk_date_around, 7, 4) = SUBSTRING(tt.Tests_Result_date_processed, 1, 4). 
                   ASSIGN 
                       SUBSTRING(jerk_date_around, 12, 12) = SUBSTRING(tt.Tests_Result_date_processed, 12, 12).
                   ASSIGN 
                       tt.Tests_Result_date_processed = jerk_date_around.                       
            END. 
               
            IF tt.Tests_Result_date_processed = '' THEN 
                ASSIGN tt.Tests_Result_date_processed = '?'.
                
            ASSIGN 
                check_date_time = DATETIME(tt.Tests_Result_date_processed) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
/*                MESSAGE "PatientID = " tt.PatientID " / TESTS_Result_date_processed error = " tt.Tests_Result_date_processed*/
/*                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.                                                                  */
                    
                ASSIGN tt.Tests_Result_date_processed = ?.
            END. 
                     
            ASSIGN  
                TESTS_RESULT_RCD.PatientID = DECIMAL(tt.PatientID)
                TESTS_RESULT_RCD.Lab_Sampleid = tt.Lab_Sampleid
                TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = DECIMAL(tt.Lab_Sampleid_SeqNbr)
                TESTS_RESULT_RCD.Test_Abbv = tt.Test_Abbv 
                TESTS_RESULT_RCD.Test_LAB_Name = tt.Test_LAB_Name  
                TESTS_RESULT_RCD.Test_PatAGE = DECIMAL(tt.Test_PatAGE)
                TESTS_RESULT_RCD.DateCollected = DATE(tt.DateCollected)
                TESTS_RESULT_RCD.DateReceived = DATE(tt.DateReceived)
                TESTS_RESULT_RCD.DateCompleted = DATE(tt.DateCompleted)   
                TESTS_RESULT_RCD.CCreatinine = DECIMAL(tt.CCreatinine)
                TESTS_RESULT_RCD.Test_Kit_Nbr = tt.Test_Kit_Nbr
                TESTS_RESULT_RCD.Comments = tt.Comments
                TESTS_RESULT_RCD.Special_Note = tt.Special_Note
                TESTS_RESULT_RCD.Tests_Result_date_processed = DATE(tt.Tests_Result_date_processed) 
                TESTS_RESULT_RCD.Progress_Flag = tt.Progress_Flag
/*                TESTS_RESULT_RCD.Progress_DateTime =  DATE(tt.Progress_DateTime)*/
            .  
            
            IF TESTS_RESULT_RCD.Progress_DateTime = ? THEN 
                ASSIGN TESTS_RESULT_RCD.Progress_DateTime = TODAY. 

/*            IF ip-found = 1 THEN                           */
/*                EXPORT STREAM outward DELIMITER ";"        */
/*                    TESTS_RESULT_RCD.PatientID          */
/*                    TESTS_RESULT_RCD.Lab_Sampleid       */
/*                    TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr*/
/*                    TESTS_RESULT_RCD.Test_Abbv          */
/*                    TESTS_RESULT_RCD.Test_Kit_Nbr       */
/*                    "Replaced TESTS_RESULT_RCD.".          */
/*            ELSE                                           */
                EXPORT STREAM outward DELIMITER ";"                                                 
                    TESTS_RESULT_RCD.PatientID                                                
                    TESTS_RESULT_RCD.Lab_Sampleid                                  
                    TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr                                 
                    TESTS_RESULT_RCD.Test_Abbv
                    TESTS_RESULT_RCD.Test_Kit_Nbr                                      
                    "New TESTS_RESULT_RCD.".         
                                    
            RELEASE TESTS_RESULT_RCD.
        
            IP-Kount2 = (IP-Kount2 + 1).
            ip-found = 0.
            
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
/* 1dot1 */                                                                                                 /* 1dot1 */
      
           
/** end of program **/

