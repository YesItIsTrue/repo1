/*------------------------------------------------------------------------
    File        : MPA_RCD-Load.p
    Purpose     : Load the MPA_RCD from SQL. 

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
        Changed RUN statement paths to use the rcode folder and to
            use the .r program extensions.
        Identified by /* 1dot2 */
    
              
    Version: 1.3    By Harold Luttrell, Sr.
        Date: 5/Feb/16.
        Added code to export any Error-Messages if encountered, from the system
            using the no-error option. .
        Identified by /* 1dot3 */
            
    1.4 - written by HAROLD LUTTRELL JR. on 03/Oct/17.  Changed to use
            single rcode PROPATH settings pursuant to the rules of
            Release 12 (CMC structure).  Need to include the RUN VALUE(SEARCH
            style commands and eliminate the C: vs. P: business.  Marked by 1dot4.             
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE TEMP-TABLE tt
    FIELD MPA_Test_Kit_Nbr             AS CHARACTER FORMAT "x(30)" 
    FIELD MPA_Test_Kit_Nbr_SeqNbr      AS CHARACTER FORMAT "x(1)" 
    FIELD PatientID                    AS CHARACTER FORMAT "x(6)"
    FIELD MPA_Batch_Number             AS CHARACTER FORMAT "x(3)"
    FIELD MPA_Test_Type                AS CHARACTER FORMAT "x(7)"  
    FIELD MPA_Date_Results_Sent        AS CHARACTER FORMAT "x(60)"
    FIELD MPA_Date_Analysis_Sent       AS CHARACTER FORMAT "x(60)"
    FIELD MPA_Test_PatAGE              AS CHARACTER FORMAT "x(20)"
    FIELD MPA_Nbr_of_SNP_IDs           AS CHARACTER FORMAT "x(20)"
    FIELD MPA_Sample_ID_Number         AS CHARACTER FORMAT "x(30)"
    FIELD MPA_Sample_ID_SeqNbr         AS CHARACTER FORMAT "x(3)"
    FIELD MPA_DateCollected            AS CHARACTER FORMAT "x(60)" 
    FIELD MPA_DateReceived             AS CHARACTER FORMAT "x(60)"
    FIELD MPA_DateCompleted            AS CHARACTER FORMAT "x(60)"
    FIELD MPA_Comments                 AS CHARACTER FORMAT "x(200)"
    FIELD MPA_Special_Note             AS CHARACTER FORMAT "x(200)"
    FIELD MPA_ReEngineered_Date        AS CHARACTER FORMAT "x(60)" 
    FIELD MPA_Test_LAB_Name            AS CHARACTER FORMAT "x(30)"
    FIELD MPA_date_processed           AS CHARACTER FORMAT "x(60)"
    FIELD Progress_Flag                AS CHARACTER FORMAT "X(1)"
    FIELD Progress_DateTime            AS CHARACTER FORMAT "x(60)"
                INDEX temp-data AS PRIMARY MPA_Test_Kit_Nbr. 

DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO. 
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount3           AS INTEGER NO-UNDO.                                                     /* 1dot1 */
DEFINE VARIABLE IP-Kountbadformat   AS INTEGER NO-UNDO.                                                     /* 1dot1 */ 
DEFINE VARIABLE ip-found            AS INTEGER NO-UNDO.
DEFINE VARIABLE Display-Kount       AS INTEGER NO-UNDO. 
DEFINE VARIABLE check_date          AS DATE NO-UNDO.
DEFINE VARIABLE check_date_time     AS DATE NO-UNDO.
DEFINE VARIABLE jerk_date_around    AS CHARACTER FORMAT "x(40)" NO-UNDO.  
DEFINE VARIABLE ip_text             AS CHARACTER FORMAT "x(40)" NO-UNDO.
DEFINE VARIABLE op_text             AS CHARACTER FORMAT "x(40)" NO-UNDO.

DEFINE VARIABLE x                   AS INTEGER NO-UNDO.  /* junk counter for error messages */


/* ********************  Preprocessor Definitions  ******************** */

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                            

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

/* 1dot1 */                                                                                                 /* 1dot1 */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE ITmessages AS LOGICAL INITIAL NO NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt = subjtxt + THIS-PROCEDURE:FILE-NAME.
   
DEFINE STREAM outward.
DEFINE VARIABLE loadlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\SQL-Load-MPA_RCD-log.txt" NO-UNDO.

OUTPUT STREAM outward TO value(loadlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "Testkit ID:" 
    "Seq Nbr:"
    "Patient ID:"
    "Sample ID Nbr:"
    "Description:".  
 
/* 1dot1 */                                                                                                 /* 1dot1 */
 
/* ***************************  Main Block  *************************** */

INPUT FROM VALUE(SEARCH("Input-Files\MPA_RCD_NONULLS.txt")).               /* 1dot4 */

/*IF drive_letter = "P" THEN                                                                                                            */
/*    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\MPA_RCD_NONULLS.txt".     /*  new o/p file from Dwights cleanup program:   */*/
/*ELSE                                                                                                                                  */
/*    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\MPA_RCD_NONULLS.txt".                                                  */
    
    REPEAT:

        CREATE tt.
                                                                    
        IMPORT DELIMITER "|" tt.        
                        
        IP-Kount1 = (IP-Kount1 + 1).

    END.  /** REPEAT **/ 
   
INPUT CLOSE.  

FOR EACH tt WHERE tt.mpa_test_kit_nbr = ''  :
     DELETE  tt.  
END.

Main_loop:                                                                                          /* 1dot1 */
FOR EACH tt WHERE tt.MPA_Test_Kit_Nbr <> "" NO-LOCK:
           
/*        IF  tt.MPA_Test_Kit_Nbr <> "" THEN DO:*/

            ip-found = 0. 
            ASSIGN 
                ip_text = tt.MPA_DateCollected.
                
            RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot4 */                
                
/*            IF drive_letter = "P" THEN                                                                                         */
/*                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*            ELSE                                                                                                               */
/*                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
                
            ASSIGN 
                tt.MPA_DateCollected = op_text.        
            ASSIGN 
                check_date = DATE(tt.MPA_DateCollected) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                         /* 1dot1 */ 
/*                ASSIGN tt.MPA_DateCollected = ?.*/                                                /* 1dot1 */

                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.MPA_Test_Kit_Nbr                                                             /* 1dot1 */ 
                    tt.MPA_Test_Kit_Nbr_SeqNbr                                                      /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.MPA_Sample_ID_Number                                                         /* 1dot1 */
                    "Date Collected not formatted correctly.  Input NOT loaded.".                   /* 1dot1 */  

            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */            
            
            ASSIGN 
                ip_text = tt.MPA_DateCompleted. 
                
            RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot4 */       
                            
/*            IF drive_letter = "P" THEN                                                                                         */
/*                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*            ELSE                                                                                                               */
/*                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
                
            ASSIGN 
                tt.MPA_DateCompleted = op_text. 
            ASSIGN 
                check_date = DATE(tt.MPA_DateCompleted) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                         /* 1dot1 */ 
/*                ASSIGN tt.MPA_DateCompleted = ?.*/                                                /* 1dot1 */

                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.MPA_Test_Kit_Nbr                                                             /* 1dot1 */ 
                    tt.MPA_Test_Kit_Nbr_SeqNbr                                                      /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.MPA_Sample_ID_Number                                                         /* 1dot1 */
                    "Date Completed not formatted correctly.  Input NOT loaded.".                   /* 1dot1 */  

            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */ 
            
            
            ASSIGN 
                ip_text = tt.MPA_DateReceived.
            
            RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot4 */
                        
/*            IF drive_letter = "P" THEN                                                                                         */
/*                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*            ELSE                                                                                                               */
/*                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
            
            ASSIGN   
                tt.MPA_DateReceived = op_text. 
            ASSIGN 
                check_date = DATE(tt.MPA_DateReceived) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                         /* 1dot1 */
/*                ASSIGN tt.MPA_DateReceived = ?.*/                                                 /* 1dot1 */

                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.MPA_Test_Kit_Nbr                                                             /* 1dot1 */ 
                    tt.MPA_Test_Kit_Nbr_SeqNbr                                                      /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.MPA_Sample_ID_Number                                                         /* 1dot1 */
                    "Date Received not formatted correctly.  Input NOT loaded.".                    /* 1dot1 */  

            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */ 


            ASSIGN 
                ip_text = tt.MPA_Date_Analysis_Sent.
            
            RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot4 */
                        
/*            IF drive_letter = "P" THEN                                                                                         */
/*                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*            ELSE                                                                                                               */
/*                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
                 
            ASSIGN 
                tt.MPA_Date_Analysis_Sent = op_text. 
            ASSIGN 
                check_date = DATE(tt.MPA_Date_Analysis_Sent) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                         /* 1dot1 */
/*                ASSIGN tt.MPA_Date_Analysis_Sent = ?.*/                                           /* 1dot1 */

                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.MPA_Test_Kit_Nbr                                                             /* 1dot1 */ 
                    tt.MPA_Test_Kit_Nbr_SeqNbr                                                      /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.MPA_Sample_ID_Number                                                         /* 1dot1 */
                    "Date Analysis Sent not formatted correctly.  Input NOT loaded.".               /* 1dot1 */  

            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */ 


            ASSIGN 
                ip_text = tt.MPA_Date_Results_Sent.
            
            RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot4 */
            
/*            IF drive_letter = "P" THEN                                                                                         */
/*                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*            ELSE                                                                                                               */
/*                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
                
            ASSIGN 
                tt.MPA_Date_Results_Sent = op_text.
            ASSIGN 
                check_date = DATE(tt.MPA_Date_Results_Sent) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                         /* 1dot1 */
/*                ASSIGN tt.MPA_Date_Results_Sent = ?.*/                                            /* 1dot1 */

                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.MPA_Test_Kit_Nbr                                                             /* 1dot1 */ 
                    tt.MPA_Test_Kit_Nbr_SeqNbr                                                      /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.MPA_Sample_ID_Number                                                         /* 1dot1 */
                    "Date Results Sent not formatted correctly.  Input NOT loaded.".                /* 1dot1 */  

            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */ 


            ASSIGN 
                SUBSTRING(jerk_date_around, 1, 3) = SUBSTRING(tt.MPA_date_processed, 6, 3).
            ASSIGN 
                SUBSTRING(jerk_date_around, 4, 2) = SUBSTRING(tt.MPA_date_processed, 9, 2). 
            ASSIGN 
                SUBSTRING(jerk_date_around, 6, 1) = '-'.
            ASSIGN 
                SUBSTRING(jerk_date_around, 7, 4) = SUBSTRING(tt.MPA_date_processed, 1, 4). 
            ASSIGN 
                SUBSTRING(jerk_date_around, 12, 12) = SUBSTRING(tt.MPA_date_processed, 12, 12).
            ASSIGN 
                tt.MPA_date_processed = jerk_date_around.   
            ASSIGN 
                check_date = DATE(tt.MPA_date_processed) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                         /* 1dot1 */
                ASSIGN tt.MPA_date_processed = ?.                                                   /* 1dot1 */
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */ 
            
            ASSIGN 
                ip_text = tt.MPA_ReEngineered_Date.
                
            RUN VALUE(SEARCH("subr_JERK_DATE_AROUND.r")) (ip_text, OUTPUT op_text).     /* 1dot4 */
                            
/*            IF drive_letter = "P" THEN                                                                                         */
/*                RUN "P:\OpenEdge\WRK\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.r" (ip_text, OUTPUT op_text).         /* 1dot2 */*/
/*            ELSE                                                                                                               */
/*                RUN "C:\OpenEdge\Workspace\RS-SQL-Loads\rcode\subr_JERK_DATE_AROUND.R" (ip_text, OUTPUT op_text).              */
                
            ASSIGN 
                tt.MPA_ReEngineered_Date = op_text.
            ASSIGN 
                check_date = DATE(tt.MPA_ReEngineered_Date) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                         /* 1dot1 */
                EXPORT STREAM outward DELIMITER ";"                                 /* 1dot3 */
                    tt.MPA_Test_Kit_Nbr                                             /* 1dot3 */ 
                    tt.MPA_Test_Kit_Nbr_SeqNbr                                      /* 1dot3 */ 
                    tt.PatientID                                                    /* 1dot3 */ 
                    tt.MPA_Sample_ID_Number                                         /* 1dot3 */
                    "See following error message.".                                 /* 1dot3 */                          
            
                DO  x = 1 TO  ERROR-STATUS:NUM-MESSAGES :                           /* 1dot3 */              
                    EXPORT  STREAM  outward DELIMITER  ";"                          /* 1dot3 */
                        x ERROR-STATUS:GET-MESSAGE(x).                              /* 1dot3 */                      
                END.  /** of do x = 1 to num-messages **/                           /* 1dot3 */ 

                ASSIGN tt.MPA_ReEngineered_Date = ?.                                                /* 1dot1 */
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */ 
             
             
            ASSIGN 
                check_date = DATE(tt.Progress_DateTime) NO-ERROR.
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN 
                ASSIGN tt.Progress_DateTime = ?.      
            
            IF tt.Progress_Flag = "Y" THEN 
                ASSIGN tt.Progress_Flag = "U".
            
            FIND FIRST MPA_RCD                                                                         /* 1dot1 */ 
                WHERE   MPA_RCD.MPA_Test_Kit_Nbr = tt.MPA_Test_Kit_Nbr AND                       /* 1dot1 */  
                        MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr = DECIMAL(tt.MPA_Test_Kit_Nbr_SeqNbr) AND    /* 1dot1 */  
                        MPA_RCD.PatientID = DECIMAL(tt.PatientID)                                    /* 1dot1 */ 
                    EXCLUSIVE-LOCK NO-ERROR.                                                        /* 1dot1 */
            
            IF AVAILABLE (MPA_RCD) THEN DO:                                                         /* 1dot1 */
                
                IP-Kount3 = (IP-Kount3 + 1).                                                        /* 1dot1 */
                ip-found  = 1. 
                        
                DELETE  MPA_RCD  NO-ERROR.                                                       /* 1dot1 */
                
                IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:        /* 1dot3 */ 
                    EXPORT STREAM outward DELIMITER ";"                                 /* 1dot3 */
                        tt.MPA_Test_Kit_Nbr                                             /* 1dot3 */ 
                        tt.MPA_Test_Kit_Nbr_SeqNbr                                      /* 1dot3 */ 
                        tt.PatientID                                                    /* 1dot3 */ 
                        tt.MPA_Sample_ID_Number                                         /* 1dot3 */
                        "Data not deleted.  See following error message.".              /* 1dot3 */                          
                
                    DO  x = 1 TO  ERROR-STATUS:NUM-MESSAGES :                           /* 1dot3 */              
                        EXPORT  STREAM  outward DELIMITER  ";"                          /* 1dot3 */
                            x ERROR-STATUS:GET-MESSAGE(x).                              /* 1dot3 */                      
                    END.  /** of do x = 1 to num-messages **/                           /* 1dot3 */ 
                END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/   /* 1dot3 */
                
            END.  /** IF AVAILABLE (MPA_RCD) **/                                                    /* 1dot1 */
            
            oops:
            DO ON QUIT UNDO, LEAVE:             /* 1dot4 - was a transaction within this transaction */
                
            CREATE MPA_RCD.  
                                     
            ASSIGN     
                MPA_RCD.MPA_Test_Kit_Nbr = tt.MPA_Test_Kit_Nbr
                MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr = DECIMAL(tt.MPA_Test_Kit_Nbr_SeqNbr)
                MPA_RCD.PatientID = DECIMAL(tt.PatientID)
                MPA_RCD.MPA_Batch_Number = DECIMAL(tt.MPA_Batch_Number)
                MPA_RCD.MPA_Test_Type = tt.MPA_Test_Type
                MPA_RCD.MPA_Date_Results_Sent = DATE(tt.MPA_Date_Results_Sent)
                MPA_RCD.MPA_Date_Analysis_Sent = DATE(tt.MPA_Date_Analysis_Sent)
                MPA_RCD.MPA_Test_PatAGE = DECIMAL(tt.MPA_Test_PatAGE)
                MPA_RCD.MPA_Nbr_of_SNP_IDs = int(tt.MPA_Nbr_of_SNP_IDs)
                MPA_RCD.MPA_Sample_ID_Number = tt.MPA_Sample_ID_Number
                MPA_RCD.MPA_Sample_ID_SeqNbr = DECIMAL(tt.MPA_Sample_ID_SeqNbr)
                MPA_RCD.MPA_DateCollected = DATE(tt.MPA_DateCollected)
                MPA_RCD.MPA_DateCompleted = DATE(tt.MPA_DateCompleted)
                MPA_RCD.MPA_DateReceived = DATE(tt.MPA_DateReceived)
                MPA_RCD.MPA_Comments = tt.MPA_Comments
                MPA_RCD.MPA_Special_Note = tt.MPA_Special_Note
                MPA_RCD.MPA_ReEngineered_Date = DATE(tt.MPA_ReEngineered_Date)
                MPA_RCD.MPA_Test_LAB_Name = tt.MPA_Test_LAB_Name
                MPA_RCD.MPA_date_processed = DATE(tt.MPA_date_processed)
                MPA_RCD.Progress_Flag = tt.Progress_Flag
/*                MPA_RCD.Progress_DateTime = DATE(tt.Progress_DateTime)*/
                    NO-ERROR.                                                                       /* 1dot1 */
            
            IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                        /* 1dot1 */ 
                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.MPA_Test_Kit_Nbr                                                             /* 1dot1 */ 
                    tt.MPA_Test_Kit_Nbr_SeqNbr                                                      /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.MPA_Sample_ID_Number                                                         /* 1dot1 */
                    "Data not formatted correctly.  Input NOT loaded.".                             /* 1dot1 */ 
                    ASSIGN IP-Kountbadformat = (IP-Kountbadformat + 1).                             /* 1dot1 */                          
                
                DO  x = 1 TO  ERROR-STATUS:NUM-MESSAGES :                       /* 1dot3 */              
                    EXPORT  STREAM  outward DELIMITER  ";"                      /* 1dot3 */
                        x ERROR-STATUS:GET-MESSAGE(x).                          /* 1dot3 */                      
                END.  /** of do x = 1 to num-messages **/                       /* 1dot3 */
                
                UNDO oops, LEAVE.
            END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/                   /* 1dot1 */
            
            IF MPA_RCD.Progress_DateTime = ? THEN 
                ASSIGN MPA_RCD.Progress_DateTime = TODAY. 
            
            IF ip-found = 1 THEN                
                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    MPA_RCD.MPA_Test_Kit_Nbr                                                     /* 1dot1 */ 
                    MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr                                              /* 1dot1 */ 
                    MPA_RCD.PatientID                                                            /* 1dot1 */
                    MPA_RCD.MPA_Sample_ID_Number                                                 /* 1dot1 */  
                    "Replaced MPA_RCD.".                                                            /* 1dot1 */   
            ELSE       
                EXPORT STREAM outward DELIMITER ";"                                                 /* 1dot1 */
                    tt.MPA_Test_Kit_Nbr                                                             /* 1dot1 */ 
                    tt.MPA_Test_Kit_Nbr_SeqNbr                                                      /* 1dot1 */ 
                    tt.PatientID                                                                    /* 1dot1 */ 
                    tt.MPA_Sample_ID_Number                                                         /* 1dot1 */
                    "New MPA_RCD.".                                                                 /* 1dot1 */
                
            RELEASE MPA_RCD.
            
            END.  /* oops */
            
            ip-found = 0.
            IP-Kount2 = (IP-Kount2 + 1).
             
/*        END.  /** tt.MPA_Test_Kit_Nbr <> "" **/*/
    
END.    /** FOR EACH tt **/

/* 1dot1 */                                                                                                 /* 1dot1 */
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
