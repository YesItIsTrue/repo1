
/*------------------------------------------------------------------------
    File        : MPA_TEST_DETAILS_RCD-Load.p
    Purpose     : Load the MPA_TEST_DETAILS_RCD from SQL. 

    Syntax      :

    Description : 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Sat Mar 15 10:26:11 CDT 2014
    Revision History:        
    -----------------
    1.0 - written by Harold LUTTRELL on 26/Dec/14.  Original version.
          
    1.1 - Jan 15, 2015 - Added a FIND statement to see if the input 
                            exists and if so then DELETE it.
                         Added the e-mailing of the log report.
          Identified by: 1dot1.

    Version: 1.2    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Fixed e-mail format to match others.
        Identified by /* 1dot2 */
                  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/*  DEFINE TEMP-TABLE tt LIKE MPA_TEST_DETAILS_RCD.   */ 
DEFINE TEMP-TABLE tt
    FIELD PatientID                    AS CHARACTER FORMAT "x(6)"
    FIELD MPA_Sample_ID_Number         AS CHARACTER FORMAT "x(30)" 
    FIELD MPA_Sample_ID_SeqNbr         AS CHARACTER FORMAT "x(1)" 
    FIELD MPA_SNP_ID_Seq_Nbr           AS CHARACTER FORMAT "x(3)"
    FIELD MPA_SNP_ID                   AS CHARACTER FORMAT "x(20)"     
    FIELD MPA_Display_Call             AS CHARACTER FORMAT "x(3)"    
    FIELD MPA_Call                     AS CHARACTER FORMAT "x(20)"
    FIELD MPA_User_Call                AS CHARACTER FORMAT "x(30)"
    FIELD MPA_User_Result              AS CHARACTER FORMAT "x(30)"
    FIELD Progress_Flag                AS CHARACTER FORMAT "X(1)"
    FIELD Progress_DateTime            AS CHARACTER FORMAT "x(60)"
                INDEX temp-data AS PRIMARY PatientID .    

DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO. 
DEFINE VARIABLE IP-Kount3           AS INTEGER NO-UNDO.                                                     /* 1dot1 */
DEFINE VARIABLE IP-Kountbadformat   AS INTEGER NO-UNDO.                                                     /* 1dot1 */ 
DEFINE VARIABLE ip-found            AS INTEGER NO-UNDO.
DEFINE VARIABLE Display-Kount       AS INTEGER NO-UNDO. 
DEFINE VARIABLE check_date          AS DATE NO-UNDO.
/*DEFINE VARIABLE update_flag         AS INTEGER NO-UNDO.                                                     /* 1dot1 */*/
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
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
   
DEFINE STREAM outward.
DEFINE VARIABLE loadlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\SQL-Load-MPA_TESTS_DETAILS_RCD-log.txt" NO-UNDO.

OUTPUT STREAM outward TO value(loadlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name " THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "Patient ID:"
    "Sample ID Nbr:"
    "Seq Nbr:"
    "SNP-ID Seq Nbr:"
    "Description".   
/* 1dot1 */                                                                                                 /* 1dot1 */
 

/* ***************************  Main Block  *************************** */

IF drive_letter = "P" THEN                                                      
    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\MPA_TEST_DETAILS_RCD_NONULLS.txt". 
ELSE
    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\MPA_TEST_DETAILS_RCD_NONULLS.txt".  

    REPEAT:

        CREATE tt.
                                                                    
        IMPORT DELIMITER "|" tt.        
                        
        IP-Kount1 = (IP-Kount1 + 1).

    END.  /** REPEAT **/ 
   
INPUT CLOSE.  

ASSIGN ip-found = 0.

Main_loop: 
FOR EACH tt NO-LOCK:
                       
        IF  tt.MPA_Sample_ID_Number <> '' THEN DO: 
/* 1dot1 */ 
                                                       
            FIND FIRST MPA_TEST_DETAILS_RCD                                                                 
                WHERE   MPA_TEST_DETAILS_RCD.PatientID               = DECIMAL(tt.PatientID) AND      
                        MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number    = tt.MPA_Sample_ID_Number AND    
                        MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr    = DECIMAL(tt.MPA_Sample_ID_SeqNbr) AND   
                        MPA_TEST_DETAILS_RCD.MPA_SNP_ID_Seq_Nbr      = int(tt.MPA_SNP_ID_Seq_Nbr)             
                    EXCLUSIVE-LOCK NO-ERROR.                                                        
            
            IF AVAILABLE (MPA_TEST_DETAILS_RCD) THEN DO:                                               
                
                ASSIGN  
                        IP-Kount3 = (IP-Kount3 + 1).
                
                IF int(tt.MPA_SNP_ID_Seq_Nbr) = 1 THEN 
                        ip-found  = 1.                                                                       
                       
                DELETE  MPA_TEST_DETAILS_RCD  NO-ERROR.                                              
                 
            END.  /** IF AVAILABLE (MPA_TEST_DETAILS_RCD) **/                                                 
 /* 1dot1 */
            
            CREATE MPA_TEST_DETAILS_RCD.         
                                 
            ASSIGN 
                check_date = DATE(tt.Progress_DateTime) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN 
                ASSIGN tt.Progress_DateTime = ?.   
            
            IF tt.Progress_Flag = "Y" THEN 
                ASSIGN tt.Progress_Flag = "A".
                                            
            ASSIGN                         
                MPA_TEST_DETAILS_RCD.PatientID            = DECIMAL(tt.PatientID)
                MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number = tt.MPA_Sample_ID_Number
                MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr = DECIMAL(tt.MPA_Sample_ID_SeqNbr)
                MPA_TEST_DETAILS_RCD.MPA_SNP_ID_Seq_Nbr   = int(tt.MPA_SNP_ID_Seq_Nbr)
                MPA_TEST_DETAILS_RCD.MPA_Call             = tt.MPA_Call
                MPA_TEST_DETAILS_RCD.MPA_Display_Call     = tt.MPA_Display_Call
                MPA_TEST_DETAILS_RCD.MPA_SNP_ID           = tt.MPA_SNP_ID
                MPA_TEST_DETAILS_RCD.MPA_User_Call        = tt.MPA_User_Call
                MPA_TEST_DETAILS_RCD.MPA_User_Result      = tt.MPA_User_Result
                MPA_TEST_DETAILS_RCD.Progress_DateTime    = DATE(tt.Progress_DateTime) 
                MPA_TEST_DETAILS_RCD.Progress_Flag        = tt.Progress_Flag    
                     NO-ERROR.                                                                       /* 1dot1 */
            
            IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                        /* 1dot1 */ 
                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.MPA_Sample_ID_Number                                                         /* 1dot1 */ 
                    tt.MPA_Sample_ID_SeqNbr                                                         /* 1dot1 */ 
                    tt.MPA_SNP_ID_Seq_Nbr                                                           /* 1dot1 */
                    "Data not formatted correctly.  Input NOT loaded.".                             /* 1dot1 */ 
                    ASSIGN IP-Kountbadformat = (IP-Kountbadformat + 1).                             /* 1dot1 */  
                NEXT Main_loop.                                                                     /* 1dot1 */
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */   
            
            IF MPA_TEST_DETAILS_RCD.Progress_DateTime = ? THEN 
                ASSIGN MPA_TEST_DETAILS_RCD.Progress_DateTime = TODAY. 
           
            IF ip-found = 1 AND 
               int(tt.MPA_SNP_ID_Seq_Nbr) = 1 THEN                              
                 EXPORT STREAM outward DELIMITER ";"                                                 
                    MPA_TEST_DETAILS_RCD.PatientID                                                
                    MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number                                  
                    MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr                                 
                    MPA_TEST_DETAILS_RCD.MPA_SNP_ID_Seq_Nbr                                      
                    "Replaced MPA_TEST_DETAILS_RCD.".     
            ELSE                     
            IF  int(tt.MPA_SNP_ID_Seq_Nbr) = 1 THEN 
                EXPORT STREAM outward DELIMITER ";"                                                 
                    MPA_TEST_DETAILS_RCD.PatientID                                                
                    MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number                                  
                    MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr                                 
                    MPA_TEST_DETAILS_RCD.MPA_SNP_ID_Seq_Nbr                                      
                    "New MPA_TEST_DETAILS_RCD.".
                
            RELEASE MPA_TEST_DETAILS_RCD NO-ERROR.
            
            ASSIGN  
                    IP-Kount2 = (IP-Kount2 + 1)
                    ip-found  = 0.
             
        END.  
    
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
