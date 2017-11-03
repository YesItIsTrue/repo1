
/*------------------------------------------------------------------------
    File        : PATIENT_FILES-Load.p
    Purpose     : Load the PATIENT_FILES from SQL. 

    Syntax      :

    Description : 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Sat Mar 15 10:26:11 CDT 2014
    Revision History:        
    -----------------
    1.0 - written by Harold LUTTRELL on 26/Dec/14.  Original version.
          
    1.1 - Jan 14, 2015 - Added a FIND statement to see if the input 
                            exists and if so then DELETE it.
                         Added the e-mailing of the log report.
          Identified by: 1dot1.
    
    Version: 1.2    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Removed dead code and fixed e-mail message to match others.
        Identified by /* 1dot2 */
              
    1.3 - written by HAROLD LUTTRELL JR. on 03/Oct/17.  Changed to use
            single rcode PROPATH settings pursuant to the rules of
            Release 12 (CMC structure).  Need to include the RUN VALUE(SEARCH
            style commands and eliminate the C: vs. P: business.  Marked by 1dot3. 
                          
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE TEMP-TABLE tt LIKE PATIENT_FILES. 

DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount3           AS INTEGER NO-UNDO.                                                 /* 1dot1 */
DEFINE VARIABLE IP-Kountbadformat   AS INTEGER NO-UNDO.                                                 /* 1dot1 */ 
DEFINE VARIABLE ip-found            AS INTEGER NO-UNDO.
DEFINE VARIABLE Display-Kount       AS INTEGER NO-UNDO. 
DEFINE VARIABLE check_date          AS DATE NO-UNDO.
/* ********************  Preprocessor Definitions  ******************** */

 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                             

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

/* 1dot1 */                                                                                             /* 1dot1 */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.    /* 1dot2 */
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.    /* 1dot2 */
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.                                  /* 1dot2 */
   
DEFINE STREAM outward.
DEFINE VARIABLE loadlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\SQL-Load-PATIENT_FILES-log.txt" NO-UNDO.

OUTPUT STREAM outward TO value(loadlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "fileid" 
    "PatientID"
    "filename"
    "lab_sampleid"
    "Description".   
/* 1dot1 */                                                                                         /* 1dot1 */


/* ***************************  Main Block  *************************** */

INPUT FROM VALUE(SEARCH("Input-Files\PATIENT_FILES_NONULLS.txt")).               /* 1dot3 */

/*IF drive_letter = "P" THEN                                                                */
/*    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\PATIENT_FILES_NONULLS.txt".      */
/*ELSE                                                                                      */
/*    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\PATIENT_FILES_NONULLS.txt".*/
 
    REPEAT:

        CREATE tt.
                                                                    
        IMPORT DELIMITER "|" tt.        
                        
        IP-Kount1 = (IP-Kount1 + 1).

    END.  /** REPEAT **/ 
   
INPUT CLOSE.    

Main_loop:  
FOR EACH tt NO-LOCK:
               
        IF  tt.filename <> '' THEN DO: 
            
            ip-found  = 0.
            
            FIND PATIENT_FILES                                                                   /* 1dot1 */ 
                WHERE PATIENT_FILES.fileid  = tt.fileid                                          /* 1dot1 */ 
                    EXCLUSIVE-LOCK NO-ERROR.                                                        /* 1dot1 */
            
            IF AVAILABLE (PATIENT_FILES) THEN DO:                                                /* 1dot1 */
                
                IP-Kount3 = (IP-Kount3 + 1).                                                        /* 1dot1 */
                ip-found  = 1.                 
                        
                DELETE  PATIENT_FILES  NO-ERROR.                                                 /* 1dot1 */
                 
            END.  /** IF AVAILABLE (PATIENT_FILES) **/                                           /* 1dot1 */
            
            CREATE PATIENT_FILES.         
                                      
            ASSIGN     
                PATIENT_FILES.filedesc = tt.filedesc
                PATIENT_FILES.fileid = tt.fileid
                PATIENT_FILES.filename = tt.filename
                PATIENT_FILES.lab_sampleid = tt.lab_sampleid
                PATIENT_FILES.lab_sampleid_seqnbr = tt.lab_sampleid_seqnbr
                PATIENT_FILES.patientid = tt.patientid
                PATIENT_FILES.Progress_DateTime = tt.Progress_DateTime
                PATIENT_FILES.Progress_Flag = tt.Progress_Flag                              
                    NO-ERROR.                                                                       /* 1dot1 */
            
            IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                        /* 1dot1 */ 
                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.fileid                                                                       /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.filename                                                                     /* 1dot1 */ 
                    tt.lab_sampleid                                                                 /* 1dot1 */
                    "Data not formatted correctly.  Input NOT loaded.".                             /* 1dot1 */ 
                    ASSIGN IP-Kountbadformat = (IP-Kountbadformat + 1).                             /* 1dot1 */  
                NEXT Main_loop.                                                                     /* 1dot1 */
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */   
            
            IF PATIENT_FILES.Progress_DateTime = ? THEN 
                ASSIGN PATIENT_FILES.Progress_DateTime = TODAY. 
                
            IF ip-found  = 1 THEN                  
                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    PATIENT_FILES.fileid                                                         /* 1dot1 */
                    PATIENT_FILES.PatientID                                                      /* 1dot1 */ 
                    PATIENT_FILES.filename                                                       /* 1dot1 */  
                    PATIENT_FILES.lab_sampleid                                                   /* 1dot1 */
                    "Replaced PATIENT_FILES.". 
            ELSE                         
                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.fileid                                                                       /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.filename                                                                     /* 1dot1 */ 
                    tt.lab_sampleid                                                                 /* 1dot1 */
                    "New PATIENT_FILES.".                                                           /* 1dot1 */ 
                                   
            RELEASE PATIENT_FILES.
            
            ip-found  = 0.
            IP-Kount2 = (IP-Kount2 + 1).
             
        END.  
    
END.    /** FOR EACH tt **/

/* 1dot1 */                                                                                          /* 1dot1 */
EXPORT STREAM outward DELIMITER ";"
    999999999 
    "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").   
     
EXPORT STREAM outward DELIMITER ";"
    IP-Kount1 "Records imported.".
    
EXPORT STREAM outward DELIMITER ";"
    IP-Kount3 "Records replaced.".
    
EXPORT STREAM outward DELIMITER ";"
    IP-Kountbadformat "Records bypassed - not loaded.".   

EXPORT STREAM outward DELIMITER ";"
    IP-Kount2 "Records added to the DB.".
    
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
