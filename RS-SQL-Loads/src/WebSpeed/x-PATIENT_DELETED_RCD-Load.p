
/*------------------------------------------------------------------------
    File        : PATIENT_DELETED_RCD-Load.p
    Purpose     : Load the PATIENT_DELETED_RCD from SQL. 

    Syntax      :

    Description : Loads the Patient_deleted_rcd data into the RS database,
                : Table/Record name: PATIENT_DELETED_RCD

    Author(s)   : Harold Luttrell, Sr.
    Created     : Nov 20, 2015
    
    Version: 1.1    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Changed RUN statement paths to use the rcode folder and to
            use the .r program extensions.
        Identified by /* 1dot1 */
    
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
    FIELD PatDeletionDate                AS CHARACTER FORMAT "x(60)"
    FIELD PatDeletionParty               AS CHARACTER FORMAT "x(128)"
    FIELD Progress_Flag                  AS CHARACTER FORMAT "x(1)"
    FIELD Progress_DateTime              AS CHARACTER FORMAT "x(60)"
                INDEX temp-data AS PRIMARY PatientID. 

DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount3           AS INTEGER NO-UNDO.  
DEFINE VARIABLE IP-Kount4           AS INTEGER NO-UNDO.  
DEFINE VARIABLE IP-Kount5           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount6           AS INTEGER NO-UNDO.                      
DEFINE VARIABLE IP-Kountbadformat   AS INTEGER NO-UNDO.                           
DEFINE VARIABLE ip-seq-nbr          AS INTEGER NO-UNDO.
DEFINE VARIABLE Display-Kount       AS INTEGER NO-UNDO. 
DEFINE VARIABLE check_date          AS DATE NO-UNDO.
DEFINE VARIABLE check_date_time     AS DATE NO-UNDO.
DEFINE VARIABLE in-found            AS INTEGER NO-UNDO.
DEFINE VARIABLE check_numeric       AS INTEGER NO-UNDO. 
DEFINE VARIABLE ip_text             AS CHARACTER FORMAT "x(40)" NO-UNDO.
DEFINE VARIABLE op_text             AS CHARACTER FORMAT "x(40)" NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                              

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt = subjtxt + THIS-PROCEDURE:FILE-NAME.
   
DEFINE STREAM outward.
DEFINE VARIABLE loadlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\SQL-Load-PATIENT_DELETED_RCD-log.txt" NO-UNDO. 

OUTPUT STREAM outward TO value(loadlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "Rcd Count:" 
    "Patient ID:"
    "Pat Last Name:"
    "Pat First Name:"
    "Pat DOB"
    "Message:".  

/* ***************************  Main Block  *************************** */

/*DO ip-seq-nbr = 1 TO 5000:                                        */
/*    IF ip-seq-nbr = 1 THEN                                        */
/*        FIND FIRST PATIENT_DELETED_RCD EXCLUSIVE-LOCK NO-ERROR.*/
/*    ELSE                                                          */
/*        FIND NEXT PATIENT_DELETED_RCD EXCLUSIVE-LOCK NO-ERROR. */
/*    DELETE PATIENT_DELETED_RCD NO-ERROR.                       */
/*    RELEASE PATIENT_DELETED_RCD NO-ERROR.                      */
/*END.                                                              */

IF drive_letter = "P" THEN                                                      
    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\PATIENT_DELETED_RCD_NONULLS.txt".     /*  new o/p file from Dwights cleanup program:   */
ELSE 
    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\PATIENT_DELETED_RCD_NONULLS.txt".  

    REPEAT:

        CREATE tt.
                                                                   
        IMPORT DELIMITER "^" tt.        
                       
        IP-Kount1 = (IP-Kount1 + 1).
 
    END.  /** REPEAT **/ 
   
INPUT CLOSE.  

Main_loop:  
FOR EACH tt NO-LOCK:
    
/*    Display-Kount = (Display-Kount + 1).                                    */
/*    IF Display-Kount < 5 THEN  DO:                                          */
/*/*        IF  tt.email_err <> '' THEN DO:*/                                 */
/*            DISPLAY tt.Patientid    tt.Progress_Flag    tt.Progress_DateTime*/
/*                        WITH FRAME a SIDE-LABELS DOWN WIDTH 250.            */
/*            DOWN WITH FRAME a.                                              */
/*/*        END.*/                                                            */
/*    END.    /**  IF Display-Kount <     **/                                 */
               
        IF  tt.PatientID <> "" THEN DO:         /* tt.PatLastName <> '' THEN */ 

            IP-Kount2 = (IP-Kount2 + 1).
            in-found = 0.            
            ASSIGN 
                ip_text = tt.PatDOB.
            
            IF drive_letter = "P" THEN 
                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot1 */
            ELSE     
                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text). 
            
            ASSIGN 
                tt.PatDOB = op_text. 
                      
            ASSIGN 
                check_date = DATE(tt.PatDOB) NO-ERROR.
            
            IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                     
                EXPORT STREAM outward DELIMITER ";" 
                    IP-Kount2                                           
                    tt.PatientID                                                                 
                    tt.PatLastName                                                              
                    tt.PatFirstName                                                              
                    tt.PatDOB                                                                   
                    "DOB not formatted correctly.  Input NOT loaded.".                           
                    ASSIGN IP-Kount3  = (IP-Kount3  + 1).
                NEXT Main_loop.                           
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/               

            ASSIGN 
                check_date = DATE(tt.PatDeletionDate) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN 
                ASSIGN tt.PatDeletionDate = STRING(TODAY).
                
            ASSIGN 
                check_date = DATE(tt.Progress_DateTime) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN 
                ASSIGN tt.Progress_DateTime = ?.             
                                         
            ASSIGN
                check_numeric = DECIMAL(tt.PatAGE) NO-ERROR.                                    
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN
                ASSIGN tt.PatAGE = "0".

            ASSIGN 
                check_numeric = DECIMAL(tt.Doctor_ID_Number) NO-ERROR.                          
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN
                ASSIGN tt.Doctor_ID_Number = "0".
                              
            ASSIGN 
                check_numeric = int(tt.PatEY) NO-ERROR.                                          
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN
                ASSIGN tt.PatEY = "0".

            ASSIGN
                check_numeric               = DECIMAL(tt.PatientID) NO-ERROR.                   
                
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                      

                EXPORT STREAM outward DELIMITER ";" 
                    IP-Kount2                                           
                    tt.PatientID
                    tt.PatLastName 
                    tt.PatFirstName                                                              
                    tt.PatDOB                                                                       
                    "PatientID not numeric.  Input NOT loaded".                                                         
                ASSIGN IP-Kount4 = (IP-Kount4 + 1).                              
                NEXT Main_loop.                                                                 
            END.  

/*            FIND PATIENT_DELETED_RCD                                        */
/*                WHERE PATIENT_DELETED_RCD.PatientID  = DECIMAL(tt.PatientID)*/
/*                    EXCLUSIVE-LOCK NO-ERROR.                                   */
/*                                                                               */
/*            IF AVAILABLE (PATIENT_DELETED_RCD) THEN DO:                     */
/*                                                                               */
/*                IP-Kount6 = (IP-Kount6 + 1).                                   */
/*                in-found = 1.                                                  */
/*                                                                               */
/*                DELETE  PATIENT_DELETED_RCD  NO-ERROR.                      */
/*                                                                               */
/*            END.  /** IF AVAILABLE (PATIENT_DELETED_RCD) **/                */
                      
            CREATE PATIENT_DELETED_RCD.         

            ASSIGN     
                PATIENT_DELETED_RCD.PatientID = DECIMAL(tt.PatientID)
                PATIENT_DELETED_RCD.PatDOB = DATE(tt.PatDOB)
                PATIENT_DELETED_RCD.PatAGE = DECIMAL(tt.PatAGE)
                PATIENT_DELETED_RCD.Doctor_ID_Number = DECIMAL(tt.Doctor_ID_Number)
                PATIENT_DELETED_RCD.PatEY = int(tt.PatEY)
                PATIENT_DELETED_RCD.PatDeletionDate = DATE(tt.PatDeletionDate)
                
                PATIENT_DELETED_RCD.MPA_Sample_ID_Number = tt.MPA_Sample_ID_Number
                PATIENT_DELETED_RCD.PatAddress1 = tt.PatAddress1
                PATIENT_DELETED_RCD.PatAddress2 = tt.PatAddress2
                PATIENT_DELETED_RCD.PatAddress3 = tt.PatAddress3
                PATIENT_DELETED_RCD.PatCity = tt.PatCity
                PATIENT_DELETED_RCD.PatCompany = tt.PatCompany
                PATIENT_DELETED_RCD.PatCondition = tt.PatCondition
                PATIENT_DELETED_RCD.PatConditionCheck = tt.PatConditionCheck
                PATIENT_DELETED_RCD.PatContactPerson = tt.PatContactPerson
                PATIENT_DELETED_RCD.PatCountry = tt.PatCountry
                PATIENT_DELETED_RCD.PatDeletionParty = tt.PatDeletionParty
                PATIENT_DELETED_RCD.PatDummy1_flag = tt.PatDummy1_flag
                PATIENT_DELETED_RCD.PatEMail = tt.PatEMail
                PATIENT_DELETED_RCD.PatEY_Other_Data = tt.PatEY_Other_Data
                PATIENT_DELETED_RCD.PatFax = tt.PatFax
                PATIENT_DELETED_RCD.PatFirstName = tt.PatFirstName
                PATIENT_DELETED_RCD.PatGender = tt.PatGender
                PATIENT_DELETED_RCD.PatIsADoctorClient = tt.PatIsADoctorClient
                PATIENT_DELETED_RCD.PatLastName = tt.PatLastName
                PATIENT_DELETED_RCD.PatMiddleName = tt.PatMiddleName
                PATIENT_DELETED_RCD.PatMPACustomer = tt.PatMPACustomer
                PATIENT_DELETED_RCD.PatNotes = tt.PatNotes
                PATIENT_DELETED_RCD.PatPhoneCell = tt.PatPhoneCell
                PATIENT_DELETED_RCD.PatPhoneHome = tt.PatPhoneHome
                PATIENT_DELETED_RCD.PatPhoneWork = tt.PatPhoneWork
                PATIENT_DELETED_RCD.PatPrefix = tt.PatPrefix
                PATIENT_DELETED_RCD.PatProvidence = tt.PatProvidence
                PATIENT_DELETED_RCD.PatStatePostalAbbrev = tt.PatStatePostalAbbrev
                PATIENT_DELETED_RCD.PatSuffix = tt.PatSuffix
                PATIENT_DELETED_RCD.PatZip = tt.PatZip
                PATIENT_DELETED_RCD.Pat_Verify_Flag = tt.Pat_Verify_Flag
                PATIENT_DELETED_RCD.Progress_DateTime = DATE(tt.Progress_DateTime)
                PATIENT_DELETED_RCD.Progress_Flag = tt.Progress_Flag
                PATIENT_DELETED_RCD.Responsible_Party_EMail = tt.Responsible_Party_EMail
                PATIENT_DELETED_RCD.WhoPaysBill = tt.WhoPaysBill
                    NO-ERROR.    

            IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                     
                EXPORT STREAM outward DELIMITER ";" 
                    IP-Kount2                                           
                    tt.PatientID                                                                 
                    tt.PatLastName 
                    tt.PatFirstName                                                              
                    tt.PatDOB                                                                
                    "DATA not formatted correctly.  Input NOT loaded.".                          
                    ASSIGN IP-Kountbadformat = (IP-Kountbadformat + 1).                           
                NEXT Main_loop.                                                                 
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                
                       
            IF PATIENT_DELETED_RCD.Progress_DateTime = ? THEN 
                ASSIGN PATIENT_DELETED_RCD.Progress_DateTime = TODAY. 
            
            IF  in-found = 1  THEN                
                EXPORT STREAM outward DELIMITER ";"
                    IP-Kount2                                             
                    PATIENT_DELETED_RCD.PatientID                                                     
                    PATIENT_DELETED_RCD.PatLastName                                                  
                    PATIENT_DELETED_RCD.PatFirstName                                                  
                    PATIENT_DELETED_RCD.PatDOB                                                       
                    "Replaced PATIENT_DELETED_RCD.".                                                      
            ELSE               
                EXPORT STREAM outward DELIMITER ";" 
                    IP-Kount2                                            
                    tt.PatientID                                                                 
                    tt.PatLastName                                                             
                    tt.PatFirstName                                                              
                    tt.PatDOB                                                                   
                    "New PATIENT_DELETED_RCD.".                                                         
                
            RELEASE PATIENT_DELETED_RCD.
            IP-Kount5 = (IP-Kount5 + 1).
            in-found = 0.
 
        END.  
    
END.    /** FOR EACH tt **/
   
EXPORT STREAM outward DELIMITER ";"
    999999999 
    "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").   
     
EXPORT STREAM outward DELIMITER ";"
    IP-Kount1 "Records imported.".
    
EXPORT STREAM outward DELIMITER ";"
    IP-Kount3 "DOB not formatted correctly.  Input NOT loaded.".

EXPORT STREAM outward DELIMITER ";"
    IP-Kount4 "PatientID not numeric.  Input NOT loaded.".  

EXPORT STREAM outward DELIMITER ";"
    IP-Kount2 "Records FOR-EACH.".
        
EXPORT STREAM outward DELIMITER ";"
    IP-Kountbadformat "DATA not formatted correctly.  Input NOT loaded.".   

/*EXPORT STREAM outward DELIMITER ";"*/
/*    IP-Kount6 "Records deleted.".  */
    
EXPORT STREAM outward DELIMITER ";"
    IP-Kount5 "Records added/loaded/replaced to the DB.".
    
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
               
/** end of program **/
