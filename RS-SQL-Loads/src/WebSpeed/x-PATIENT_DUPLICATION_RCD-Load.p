
/*------------------------------------------------------------------------
    File        : PATIENT_DUPLICATION_RCD-Load.p
    Purpose     : Load the PATIENT_DUPLICATION_RECORD from SQL. 

    Syntax      :

    Description : Loads the PATIENT_DUPLICATION_RECORD data into the RS database,
                : Table/Record name: PATIENT_DUPLICATION_RECORD

    Author(s)   : Harold Luttrell, Sr.
    Created     : Nov 25, 2015
    
    Version: 1.0    By Harold Luttrell, Sr.
        Date: 25/Nov/15.
        Origional code.
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE TEMP-TABLE tt
    FIELD duplication_id                AS DECIMAL  
    FIELD patientid1                    AS CHARACTER FORMAT "x(10)"
    FIELD patientid2                    AS CHARACTER FORMAT "x(10)"
    FIELD patprefix1                    AS CHARACTER FORMAT "x(04)"
    FIELD patprefix2                    AS CHARACTER FORMAT "x(04)"
    FIELD patfirstname1                 AS CHARACTER FORMAT "x(60)"
    FIELD patfirstname2                 AS CHARACTER FORMAT "x(60)"
    FIELD patmiddlename1                AS CHARACTER FORMAT "x(60)"
    FIELD patmiddlename2                AS CHARACTER FORMAT "x(60)"
    FIELD patlastname1                  AS CHARACTER FORMAT "x(60)"
    FIELD patlastname2                  AS CHARACTER FORMAT "x(60)"
    FIELD patsuffix1                    AS CHARACTER FORMAT "x(60)" 
    FIELD patsuffix2                    AS CHARACTER FORMAT "x(60)" 
    FIELD pataddress1_1                 AS CHARACTER FORMAT "x(60)"
    FIELD pataddress1_2                 AS CHARACTER FORMAT "x(60)"
    FIELD PatAddress2_1                 AS CHARACTER FORMAT "x(60)"
    FIELD PatAddress2_2                 AS CHARACTER FORMAT "x(60)"
    FIELD pataddress3_1                 AS CHARACTER FORMAT "x(60)"
    FIELD pataddress3_2                 AS CHARACTER FORMAT "x(60)"
    FIELD patcity1                      AS CHARACTER FORMAT "x(60)"
    FIELD patcity2                      AS CHARACTER FORMAT "x(60)"
    FIELD patstatepostalabbrev1         AS CHARACTER FORMAT "x(60)"
    FIELD patstatepostalabbrev2         AS CHARACTER FORMAT "x(60)"
    FIELD patzip1                       AS CHARACTER FORMAT "x(10)"
    FIELD patzip2                       AS CHARACTER FORMAT "x(10)"
    FIELD patphonehome1                 AS CHARACTER FORMAT "x(25)"
    FIELD patphonehome2                 AS CHARACTER FORMAT "x(25)"
    FIELD patphonework1                 AS CHARACTER FORMAT "x(25)"
    FIELD patphonework2                 AS CHARACTER FORMAT "x(25)"
    FIELD patphonecell1                 AS CHARACTER FORMAT "x(25)"
    FIELD patphonecell2                 AS CHARACTER FORMAT "x(25)"
    FIELD patfax1                       AS CHARACTER FORMAT "x(25)"
    FIELD patfax2                       AS CHARACTER FORMAT "x(25)"
    FIELD patdob1                       AS CHARACTER FORMAT "x(25)"         /*  "99/99/9999 HH:MM:SS.SSS"  */
    FIELD patdob2                       AS CHARACTER FORMAT "x(25)"         /*  "99/99/9999 HH:MM:SS.SSS"  */
    FIELD patgender1                    AS CHARACTER FORMAT "x(06)"
    FIELD patgender2                    AS CHARACTER FORMAT "x(06)"
    FIELD patcountry1                   AS CHARACTER FORMAT "x(60)"
    FIELD patcountry2                   AS CHARACTER FORMAT "x(60)"
    FIELD timestamp                     AS CHARACTER FORMAT "x(25)"         /*  "99/99/9999 HH:MM:SS.SSS"  */
    FIELD patemail1                     AS CHARACTER FORMAT "x(60)"
    FIELD patemail2                     AS CHARACTER FORMAT "x(60)"
    FIELD Progress_Flag                 AS CHARACTER FORMAT "x(02)" 
    FIELD Progress_DateTime             AS CHARACTER FORMAT "x(25)"         /*  "99/99/9999 HH:MM:SS.SSS"  */
                INDEX temp-data AS PRIMARY duplication_id. 

DEFINE VARIABLE testie  AS DATETIME NO-UNDO.
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
    INITIAL "C:\PROGRESS\WRK\SQL-Load-PATIENT_DUPLICATION_RCD-log.txt" NO-UNDO. 

OUTPUT STREAM outward TO value(loadlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "Duplication ID:" 
    "Patient ID 1:"
    "Pat Last Name 1:"
    "Pat First Name 1:"
    "Pat DOB 1"
    "Message:".  

/* ***************************  Main Block  *************************** */

FOR EACH PATIENT_DUPLICATION_RECORD EXCLUSIVE-LOCK:
    DELETE PATIENT_DUPLICATION_RECORD. 
END.

IF drive_letter = "P" THEN                                                      
    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\PATIENT_DUPLICATION_RCD_NONULLS.txt".     /*  new o/p file from Dwights cleanup program:   */
ELSE 
    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\PATIENT_DUPLICATION_RCD_NONULLS.txt".  

    REPEAT:

        CREATE tt.
                                                                   
        IMPORT DELIMITER "^" tt.        
                       
        IP-Kount1 = (IP-Kount1 + 1).
 
    END.  /** REPEAT **/ 
   
INPUT CLOSE.  
DISPLAY IP-Kount1.

Main_loop:  
FOR EACH tt NO-LOCK:
        
    Display-Kount = (Display-Kount + 1).
    IF Display-Kount < 5 THEN  DO:
            DISPLAY tt.patientid1 tt.patientid2  tt.patfirstname1 tt.patdob1 tt.patdob2
                    tt.Progress_DateTime tt.timestamp testie
                    tt.Progress_Flag    tt.Progress_DateTime
                        SKIP(2)
                        WITH FRAME a SIDE-LABELS DOWN WIDTH 80.
            DOWN WITH FRAME a.
    END.    /**  IF Display-Kount <     **/
               
        IF  tt.patientid1 <> "0" THEN DO:       

            IP-Kount2 = (IP-Kount2 + 1).
            in-found = 0.            
            ASSIGN 
                ip_text = tt.patdob1.
            
            IF drive_letter = "P" THEN 
                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).    
            ELSE     
                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text). 
            
            ASSIGN 
                tt.patdob1 = op_text. 
            ASSIGN 
                ip_text = tt.patdob2.
            
            IF drive_letter = "P" THEN 
                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).    
            ELSE     
                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text). 
            
            ASSIGN 
                tt.patdob2 = op_text. 
                
            IF tt.patdob1 <> "" THEN DO:          
                ASSIGN 
                    check_date = DATE(tt.patdob1) NO-ERROR.           
                IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                     
                    EXPORT STREAM outward DELIMITER ";" 
                        IP-Kount2                                           
                        tt.patientid1                                                                 
                        tt.patlastname1                                                              
                        tt.patfirstname1                                                              
                        tt.patdob1                                                                   
                        "patdob1 not formatted correctly.  Input NOT loaded.".                           
                        ASSIGN IP-Kount3  = (IP-Kount3  + 1).
                    NEXT Main_loop.                           
                END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/               
            END.  /*  IF tt.patdob1 <> ""  */
            
            IF tt.patdob2 <> "" THEN DO: 
                ASSIGN 
                    check_date = DATE(tt.patdob2) NO-ERROR.
                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                     
                    EXPORT STREAM outward DELIMITER ";" 
                        IP-Kount2                                           
                        tt.patientid2                                                                 
                        tt.patlastname2                                                              
                        tt.patfirstname2                                                              
                        tt.patdob2                                                                   
                        "patdob2 not formatted correctly.  Input NOT loaded.".                           
                        ASSIGN IP-Kount3  = (IP-Kount3  + 1).
                    NEXT Main_loop.                           
                END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/  
            END.  /*  IF tt.patdob2 <> ""  */

            ASSIGN 
                ip_text = tt.timestamp.
            
            IF drive_letter = "P" THEN 
                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).    
            ELSE     
                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text). 
            
            ASSIGN 
                tt.timestamp = op_text.  
                                                       
            ASSIGN
                check_date_time  = DATETIME(tt.timestamp) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN
                ASSIGN tt.timestamp = "?".

            ASSIGN
                check_date = DATE(tt.progress_datetime) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN
                ASSIGN tt.progress_datetime = STRING(TODAY).

            ASSIGN
                check_numeric               = DECIMAL(tt.patientid1) NO-ERROR.                   
                
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                      

                EXPORT STREAM outward DELIMITER ";" 
                    IP-Kount2                                           
                    tt.patientid1
                    tt.patlastname1 
                    tt.patfirstname1                                                              
                    tt.patdob1                                                                       
                    "patientid1 not numeric.  Input NOT loaded".                                                         
                ASSIGN IP-Kount4 = (IP-Kount4 + 1).                              
                NEXT Main_loop.                                                                 
            END.  

            ASSIGN
                check_numeric               = DECIMAL(tt.patientid2) NO-ERROR.                   
                
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                      

                EXPORT STREAM outward DELIMITER ";" 
                    IP-Kount2                                           
                    tt.patientid2
                    tt.patlastname2 
                    tt.patfirstname2                                                              
                    tt.patdob1                                                                       
                    "patientid2 not numeric.  Input NOT loaded".                                                         
                ASSIGN IP-Kount4 = (IP-Kount4 + 1).                              
                NEXT Main_loop.                                                                 
            END.  

/*            FIND PATIENT_DUPLICATION_RECORD                                        */
/*                WHERE PATIENT_DUPLICATION_RECORD.patientid1  = DECIMAL(tt.patientid1)*/
/*                    EXCLUSIVE-LOCK NO-ERROR.                                   */
/*                                                                               */
/*            IF AVAILABLE (PATIENT_DUPLICATION_RECORD) THEN DO:                     */
/*                                                                               */
/*                IP-Kount6 = (IP-Kount6 + 1).                                   */
/*                in-found = 1.                                                  */
/*                                                                               */
/*                DELETE  PATIENT_DUPLICATION_RECORD  NO-ERROR.                      */
/*                                                                               */
/*            END.  /** IF AVAILABLE (PATIENT_DUPLICATION_RECORD) **/                */
                      
            CREATE PATIENT_DUPLICATION_RECORD.         

            ASSIGN  
                PATIENT_DUPLICATION_RECORD.duplication_id = tt.duplication_id   /*  DECIMAL(tt.duplication_id)  */
                PATIENT_DUPLICATION_RECORD.patientid1 = DECIMAL(tt.patientid1)
                PATIENT_DUPLICATION_RECORD.patientid2 = DECIMAL(tt.patientid2)
                PATIENT_DUPLICATION_RECORD.patdob1 = DATE(tt.patdob1)
                PATIENT_DUPLICATION_RECORD.patdob2 = DATE(tt.patdob2)
                PATIENT_DUPLICATION_RECORD.Progress_DateTime = DATE(tt.Progress_DateTime)
                PATIENT_DUPLICATION_RECORD.timestamp = DATE(tt.timestamp)
                
                PATIENT_DUPLICATION_RECORD.patprefix1 = tt.patprefix1
                PATIENT_DUPLICATION_RECORD.patprefix2 = tt.patprefix2
                PATIENT_DUPLICATION_RECORD.patfirstname1 = tt.patfirstname1
                PATIENT_DUPLICATION_RECORD.patfirstname2 = tt.patfirstname2
                PATIENT_DUPLICATION_RECORD.patmiddlename1 = tt.patmiddlename1
                PATIENT_DUPLICATION_RECORD.patmiddlename2 = tt.patmiddlename2
                PATIENT_DUPLICATION_RECORD.patlastname1 = tt.patlastname1
                PATIENT_DUPLICATION_RECORD.patlastname2 = tt.patlastname2
                PATIENT_DUPLICATION_RECORD.patsuffix1 = tt.patsuffix1
                PATIENT_DUPLICATION_RECORD.patsuffix2 = tt.patsuffix2
                PATIENT_DUPLICATION_RECORD.PatAddress1_1 = tt.PatAddress1_1
                PATIENT_DUPLICATION_RECORD.PatAddress1_2 = tt.PatAddress1_2
                PATIENT_DUPLICATION_RECORD.PatAddress2_1 = tt.PatAddress2_1
                PATIENT_DUPLICATION_RECORD.PatAddress2_2 = tt.PatAddress2_2
                PATIENT_DUPLICATION_RECORD.PatAddress3_1 = tt.PatAddress3_1
                PATIENT_DUPLICATION_RECORD.PatAddress3_2 = tt.PatAddress3_2               
                PATIENT_DUPLICATION_RECORD.patcity1 = tt.patcity1
                PATIENT_DUPLICATION_RECORD.patcity2 = tt.patcity2               
                PATIENT_DUPLICATION_RECORD.patstatepostalabbrev1 = tt.patstatepostalabbrev1
                PATIENT_DUPLICATION_RECORD.patstatepostalabbrev2 = tt.patstatepostalabbrev2
                PATIENT_DUPLICATION_RECORD.patzip1 = tt.patzip1
                PATIENT_DUPLICATION_RECORD.patzip2 = tt.patzip2
                PATIENT_DUPLICATION_RECORD.patphonehome1 = tt.patphonehome1
                PATIENT_DUPLICATION_RECORD.patphonehome2 = tt.patphonehome2
                PATIENT_DUPLICATION_RECORD.patphonework1 = tt.patphonework1
                PATIENT_DUPLICATION_RECORD.patphonework2 = tt.patphonework2
                PATIENT_DUPLICATION_RECORD.patphonecell1 = tt.patphonecell1
                PATIENT_DUPLICATION_RECORD.patphonecell2 = tt.patphonecell2
                PATIENT_DUPLICATION_RECORD.patfax1 = tt.patfax1
                PATIENT_DUPLICATION_RECORD.patfax2 = tt.patfax2
                PATIENT_DUPLICATION_RECORD.patgender1 = tt.patgender1
                PATIENT_DUPLICATION_RECORD.patgender2 = tt.patgender2                
                PATIENT_DUPLICATION_RECORD.patcountry1 = tt.patcountry1
                PATIENT_DUPLICATION_RECORD.patcountry2 = tt.patcountry2
                PATIENT_DUPLICATION_RECORD.patemail1 = tt.patemail1
                PATIENT_DUPLICATION_RECORD.patemail2 = tt.patemail2               
                PATIENT_DUPLICATION_RECORD.Progress_Flag = tt.Progress_Flag
                    NO-ERROR.    

            IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                     
                EXPORT STREAM outward DELIMITER ";" 
                    IP-Kount2                                           
                    tt.patientid1                                                                 
                    tt.patlastname1 
                    tt.patfirstname1                                                              
                    tt.patdob1                                                                
                    "DATA not formatted correctly for computer processing.  Input NOT loaded.".                          
                    ASSIGN IP-Kountbadformat = (IP-Kountbadformat + 1).                           
                NEXT Main_loop.                                                                 
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                
                       
            IF PATIENT_DUPLICATION_RECORD.Progress_DateTime = ? THEN 
                ASSIGN PATIENT_DUPLICATION_RECORD.Progress_DateTime = TODAY. 
            
            IF  in-found = 1  THEN                
                EXPORT STREAM outward DELIMITER ";"
                    IP-Kount2                                             
                    PATIENT_DUPLICATION_RECORD.patientid1                                                     
                    PATIENT_DUPLICATION_RECORD.patlastname1                                                  
                    PATIENT_DUPLICATION_RECORD.patfirstname1                                                  
                    PATIENT_DUPLICATION_RECORD.patdob1                                                       
                    "Replaced PATIENT_DUPLICATION_RECORD.".                                                      
            ELSE               
                EXPORT STREAM outward DELIMITER ";" 
                    IP-Kount2                                            
                    tt.patientid1                                                                 
                    tt.patlastname1                                                             
                    tt.patfirstname1                                                              
                    tt.patdob1                                                                   
                    "New PATIENT_DUPLICATION_RECORD.".                                                         
                
            RELEASE PATIENT_DUPLICATION_RECORD.
            IP-Kount5 = (IP-Kount5 + 1).
            in-found = 0.
 
        END.  
    
END.    /** FOR EACH tt **/
 
FIND PATIENT_DUPLICATION_RECORD 
    WHERE PATIENT_DUPLICATION_RECORD.duplication_id = 0 EXCLUSIVE-LOCK NO-ERROR.
IF AVAILABLE (PATIENT_DUPLICATION_RECORD)  THEN 
   DELETE PATIENT_DUPLICATION_RECORD.  
   
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
    IP-Kount4 "patientid1 not numeric.  Input NOT loaded.".  

EXPORT STREAM outward DELIMITER ";"
    IP-Kount2 "Records FOR-EACH.".
        
EXPORT STREAM outward DELIMITER ";"
    IP-Kountbadformat "DATA not formatted correctly for computer processing.  Input NOT loaded.".   

/*EXPORT STREAM outward DELIMITER ";"*/
/*    IP-Kount6 "Records deleted.".  */
    
EXPORT STREAM outward DELIMITER ";"
    IP-Kount5 "Records added/loaded/replaced in the DB.".
    
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
