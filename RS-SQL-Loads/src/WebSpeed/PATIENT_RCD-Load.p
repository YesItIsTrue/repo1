
/*------------------------------------------------------------------------
    File        : PATIENT_RCD-Load.p
    Purpose     : Load the PATIENT_RCD from SQL. 

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
        Changed RUN statement paths to use the rcode folder and to
            use the .r program extensions.
        Identified by /* 1dot2 */   
          
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE TEMP-TABLE tt
    FIELD PatientID                      AS CHARACTER FORMAT "x(6)"
    FIELD PatLastName                    AS CHARACTER FORMAT "x(60)"
    FIELD PatFirstName                   AS CHARACTER FORMAT "x(60)"
    FIELD PatMiddleName                  AS CHARACTER FORMAT "x(60)"
    FIELD PatPrefix                      AS CHARACTER FORMAT "x(60)" 
    FIELD PatSuffix                      AS CHARACTER FORMAT "x(60)"
    FIELD PatAddress1                    AS CHARACTER FORMAT "x(60)"
    FIELD PatAddress2                    AS CHARACTER FORMAT "x(60)"
    FIELD PatAddress3                    AS CHARACTER FORMAT "x(60)"
    FIELD PatCity                        AS CHARACTER FORMAT "x(60)"
    FIELD PatStatePostalAbbrev           AS CHARACTER FORMAT "x(2)"
    FIELD PatZip                         AS CHARACTER FORMAT "x(10)"
    FIELD PatPhoneHome                   AS CHARACTER FORMAT "x(25)"
    FIELD PatPhoneCell                   AS CHARACTER FORMAT "x(25)"
    FIELD PatPhoneWork                   AS CHARACTER FORMAT "x(25)"
    FIELD PatFax                         AS CHARACTER FORMAT "x(25)"
    FIELD PatGender                      AS CHARACTER FORMAT "x(6)"
    FIELD PatDOB                         AS CHARACTER FORMAT "x(60)"
    FIELD PatAGE                         AS CHARACTER FORMAT "x(60)"
    FIELD PatCondition                   AS CHARACTER FORMAT "x(200)"
    FIELD PatContactPerson               AS CHARACTER FORMAT "x(60)"
    FIELD PatEMail                       AS CHARACTER FORMAT "x(60)"
    FIELD Responsible_Party_EMail        AS CHARACTER FORMAT "x(60)" 
    FIELD Doctor_ID_Number               AS CHARACTER FORMAT "x(60)"
    FIELD MPA_Sample_ID_Number           AS CHARACTER FORMAT "x(30)"
    FIELD PatCompany                     AS CHARACTER FORMAT "x(60)"
    FIELD PatEY                          AS CHARACTER FORMAT "x(60)"
    FIELD PatEY_Other_Data               AS CHARACTER FORMAT "x(60)"
    FIELD PatMPACustomer                 AS CHARACTER FORMAT "x(1)"
    FIELD PatIsADoctorClient             AS CHARACTER FORMAT "x(1)"
    FIELD PatDummy1_flag                 AS CHARACTER FORMAT "x(1)"
    FIELD WhoPaysBill                    AS CHARACTER FORMAT "x(60)"
    FIELD PatCountry                     AS CHARACTER FORMAT "x(60)"
    FIELD PatProvidence                  AS CHARACTER FORMAT "x(60)"
    FIELD PatNotes                       AS CHARACTER FORMAT "x(8000)"
    FIELD Pat_Verify_Flag                AS CHARACTER FORMAT "x(1)" 
    FIELD PatConditionCheck              AS CHARACTER FORMAT "x(512)" 
    FIELD Progress_Flag                  AS CHARACTER FORMAT "x(1)"
    FIELD Progress_DateTime              AS CHARACTER FORMAT "x(60)"
                INDEX temp-data AS PRIMARY PatientID. 

DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount3           AS INTEGER NO-UNDO.                         /* 1dot1 */
DEFINE VARIABLE IP-Kountbadformat   AS INTEGER NO-UNDO.                         /* 1dot1 */  
DEFINE VARIABLE in-found            AS INTEGER NO-UNDO.
DEFINE VARIABLE Display-Kount       AS INTEGER NO-UNDO.
DEFINE VARIABLE check_numeric       AS INTEGER NO-UNDO. 
DEFINE VARIABLE check_date          AS DATE NO-UNDO.
DEFINE VARIABLE check_date_time     AS DATE NO-UNDO.
DEFINE VARIABLE ip_text             AS CHARACTER FORMAT "x(40)" NO-UNDO.
DEFINE VARIABLE op_text             AS CHARACTER FORMAT "x(40)" NO-UNDO.
/* ********************  Preprocessor Definitions  ******************** */

 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.              

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

/* 1dot1 */                                                                                                 /* 1dot1 */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.                                  /* 1dot2 */
   
DEFINE STREAM outward.
DEFINE VARIABLE loadlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\SQL-Load-PATIENT_RCD-log.txt" NO-UNDO.

OUTPUT STREAM outward TO value(loadlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "Patient_ID" 
    "Last Name"
    "First Name"
    "DOB"
    "Description".   
/* 1dot1 */                                                                                                 /* 1dot1 */
 

/* ***************************  Main Block  *************************** */

IF drive_letter = "P" THEN                                                      
    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\PATIENT_RCD_NONULLS.txt".    /*  new o/p file from Dwights cleanup program:   */
ELSE 
    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\PATIENT_RCD_NONULLS.txt".    /*  new o/p file from Dwights cleanup program:   */

    REPEAT:

        CREATE tt.
                                                                    
        IMPORT DELIMITER "^" tt.             /* tried: |  - Dwight is using the | in his data fields! */
                        
        IP-Kount1 = (IP-Kount1 + 1).

    END.  /** REPEAT **/ 
   
INPUT CLOSE.   
 
Main_loop:                                                                                              /* 1dot1 */
FOR EACH tt NO-LOCK:
                      
        IF  tt.PatientID <> "" THEN DO:                   /*    tt.PatLastName <> "" THEN DO:     */
        
            in-found = 0.            
            ASSIGN 
                ip_text = tt.PatDOB.
            
            IF drive_letter = "P" THEN 
                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */
            ELSE     
                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text). 
            
            ASSIGN 
                tt.PatDOB = op_text. 
                      
            ASSIGN 
                check_date = DATE(tt.PatDOB) NO-ERROR.
            
            IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                    /* 1dot1 */ 
                EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
                    tt.PatientID                                                                /* 1dot1 */ 
                    tt.PatLastName                                                              /* 1dot1 */ 
                    tt.PatFirstName                                                             /* 1dot1 */ 
                    tt.PatDOB                                                                   /* 1dot1 */
                    "DOB not formatted correctly.  Input NOT loaded.".                          /* 1dot1 */ 
                    ASSIGN IP-Kountbadformat = (IP-Kountbadformat + 1).                         /* 1dot1 */  
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/               /* 1dot1 */

            ASSIGN 
                check_date = DATE(tt.Progress_DateTime) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN 
                ASSIGN tt.Progress_DateTime = ?.             
                                         
            ASSIGN
                check_numeric = DECIMAL(tt.PatAGE) NO-ERROR.                                    /* 1dot1 */
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN
                ASSIGN tt.PatAGE = "0".

            ASSIGN 
                check_numeric = DECIMAL(tt.Doctor_ID_Number) NO-ERROR.                          /* 1dot1 */
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN
                ASSIGN tt.Doctor_ID_Number = "0".
                              
            ASSIGN 
                check_numeric = int(tt.PatEY) NO-ERROR.                                         /* 1dot1 */ 
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN
                ASSIGN tt.PatEY = "0".

            ASSIGN
                check_numeric               = DECIMAL(tt.PatientID) NO-ERROR.                   /* 1dot1 */
                
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                     /* 1dot1 */ 

                EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
                    tt.PatientID                                                                /* 1dot1 */ 
                    "PatientID not numeric."                                                    /* 1dot1 */ 
                    "Last good record count ="                                                  /* 1dot1 */ 
                    IP-Kount2                                                                   /* 1dot1 */
                    "Input NOT loaded".                                                         /* 1dot1 */
                ASSIGN IP-Kountbadformat = (IP-Kountbadformat + 1).                             /* 1dot1 */ 
                NEXT Main_loop.                                                                 /* 1dot1 */
            END.   
                      
            FIND PATIENT_RCD                                                                 /* 1dot1 */ 
                WHERE PATIENT_RCD.PatientID  = DECIMAL(tt.PatientID)                         /* 1dot1 */ 
                    EXCLUSIVE-LOCK NO-ERROR.                                                    /* 1dot1 */
            
            IF AVAILABLE (PATIENT_RCD) THEN DO:                                              /* 1dot1 */
                
                IP-Kount3 = (IP-Kount3 + 1).                                                    /* 1dot1 */
                in-found = 1.                 
                        
                DELETE  PATIENT_RCD  NO-ERROR.                                               /* 1dot1 */
                 
            END.  /** IF AVAILABLE (PATIENT_RCD) **/                                            /* 1dot1 */
               
            CREATE PATIENT_RCD.         
            
            ASSIGN
                PATIENT_RCD.PatientID               = DECIMAL(tt.PatientID) 
                PATIENT_RCD.PatDOB                  = DATE(tt.PatDOB) 
                PATIENT_RCD.PatAGE                  = DECIMAL(tt.PatAGE)
                PATIENT_RCD.Doctor_ID_Number        = DECIMAL(tt.Doctor_ID_Number)
                PATIENT_RCD.PatEY                   = int(tt.PatEY)
                PATIENT_RCD.MPA_Sample_ID_Number    = tt.MPA_Sample_ID_Number
                PATIENT_RCD.PatAddress1             = tt.PatAddress1
                PATIENT_RCD.PatAddress2             = tt.PatAddress2
                PATIENT_RCD.PatAddress3             = tt.PatAddress3
                PATIENT_RCD.PatCity                 = tt.PatCity
                PATIENT_RCD.PatCompany              = tt.PatCompany
                PATIENT_RCD.PatCondition            = tt.PatCondition
                PATIENT_RCD.PatContactPerson        = tt.PatContactPerson
                PATIENT_RCD.PatCountry              = tt.PatCountry
                PATIENT_RCD.PatDummy1_flag          = tt.PatDummy1_flag
                PATIENT_RCD.PatEMail                = tt.PatEMail
                PATIENT_RCD.PatEY_Other_Data        = tt.PatEY_Other_Data
                PATIENT_RCD.PatFax                  = tt.PatFax
                PATIENT_RCD.PatFirstName            = tt.PatFirstName
                PATIENT_RCD.PatGender               = tt.PatGender
                PATIENT_RCD.PatIsADoctorClient      = tt.PatIsADoctorClient
                PATIENT_RCD.PatLastName             = tt.PatLastName
                PATIENT_RCD.PatMiddleName           = tt.PatMiddleName
                PATIENT_RCD.PatMPACustomer          = tt.PatMPACustomer
                PATIENT_RCD.PatNotes                = tt.PatNotes
                PATIENT_RCD.PatPhoneCell            = tt.PatPhoneCell
                PATIENT_RCD.PatPhoneHome            = tt.PatPhoneHome
                PATIENT_RCD.PatPhoneWork            = tt.PatPhoneWork
                PATIENT_RCD.PatPrefix               = tt.PatPrefix
                PATIENT_RCD.PatProvidence           = tt.PatProvidence
                PATIENT_RCD.PatStatePostalAbbrev    = tt.PatStatePostalAbbrev
                PATIENT_RCD.PatSuffix               = tt.PatSuffix
                PATIENT_RCD.PatZip                  = tt.PatZip
                PATIENT_RCD.Pat_Verify_Flag         = tt.Pat_Verify_Flag
                PATIENT_RCD.Responsible_Party_EMail = tt.Responsible_Party_EMail
 /*               PATIENT_RCD.PatCondition            = tt.PatConditionCheck  */
                PATIENT_RCD.Verified_Flag_BAD       = tt.PatConditionCheck
                PATIENT_RCD.WhoPaysBill             = tt.WhoPaysBill
                PATIENT_RCD.Progress_Flag           = tt.Progress_Flag
                PATIENT_RCD.Progress_DateTime       = DATE(tt.Progress_DateTime)
                    NO-ERROR.                                                                   /* 1dot1 */
            
            IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                    /* 1dot1 */ 
                EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
                    tt.PatientID                                                                /* 1dot1 */ 
                    tt.PatLastName                                                              /* 1dot1 */ 
                    tt.PatFirstName                                                             /* 1dot1 */ 
                    tt.PatDOB                                                                   /* 1dot1 */
                    "Data not formatted correctly.  Input NOT loaded.".                         /* 1dot1 */ 
                    ASSIGN IP-Kountbadformat = (IP-Kountbadformat + 1).                         /* 1dot1 */  
                NEXT Main_loop.                                                                 /* 1dot1 */
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/               /* 1dot1 */
            
            IF  PATIENT_RCD.PatContactPerson = "NEW PATIENT" THEN 
                ASSIGN PATIENT_RCD.PatContactPerson = "".
            IF  PATIENT_RCD.WhoPaysBill = "NEW PATIENT" THEN 
                ASSIGN PATIENT_RCD.WhoPaysBill = "".   
                
            IF PATIENT_RCD.Progress_Flag      = "Y" THEN 
                ASSIGN PATIENT_RCD.Progress_Flag  = "".
                
            IF PATIENT_RCD.Progress_DateTime = ? THEN 
                ASSIGN PATIENT_RCD.Progress_DateTime = TODAY. 
                
            IF  in-found = 1  THEN                
                EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
                    PATIENT_RCD.PatientID                                                    /* 1dot1 */ 
                    PATIENT_RCD.PatLastName                                                  /* 1dot1 */ 
                    PATIENT_RCD.PatFirstName                                                 /* 1dot1 */ 
                    PATIENT_RCD.PatDOB                                                       /* 1dot1 */
                    "Replaced PATIENT_RCD.".                                                    /* 1dot1 */  
            ELSE               
                EXPORT STREAM outward DELIMITER ";"                                             /* 1dot1 */
                    tt.PatientID                                                                /* 1dot1 */ 
                    tt.PatLastName                                                              /* 1dot1 */ 
                    tt.PatFirstName                                                             /* 1dot1 */ 
                    tt.PatDOB                                                                   /* 1dot1 */
                    "New PATIENT_RCD.".                                                         /* 1dot1 */
                                   
            RELEASE PATIENT_RCD.
            
            in-found = 0.
            IP-Kount2 = (IP-Kount2 + 1).
             
        END.  
    
END.    /** FOR EACH tt **/

/* 1dot1 */                                                                                      /* 1dot1 */
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
/* 1dot1 */                                                                                      /* 1dot1 */
               
/** end of program **/
