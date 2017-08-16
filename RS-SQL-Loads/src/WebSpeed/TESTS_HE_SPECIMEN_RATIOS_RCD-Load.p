
/*------------------------------------------------------------------------
    File        : TESTS_HE_SPECIMEN_RATIOS_RCD-Load.p
    Purpose     : Load the TESTS_HE_SPECIMEN_RATIOS_RCD from SQL. 

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
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE TEMP-TABLE tt LIKE TESTS_HE_SPECIMEN_RATIOS_RCD.

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
    INITIAL "C:\PROGRESS\WRK\SQL-Load-TESTS_HE_SPECIMEN_RATIOS_RCD-log.txt" NO-UNDO.

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

IF drive_letter = "P" THEN                                                      
    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\TESTS_HE_SPECIMEN_RATIOS_RCD_NONULLS.txt".
ELSE 
    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\TESTS_HE_SPECIMEN_RATIOS_RCD_NONULLS.txt". 
 
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
            FIND FIRST TESTS_HE_SPECIMEN_RATIOS_RCD
                WHERE 
                        TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID = DECIMAL(tt.PatientID) AND 
                        TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid = tt.Lab_Sampleid AND 
                        TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr = DECIMAL(tt.Lab_Sampleid_SeqNbr)
                    EXCLUSIVE-LOCK NO-ERROR.                                                        
            
            IF AVAILABLE (TESTS_HE_SPECIMEN_RATIOS_RCD) THEN DO:                                               
                
                ASSIGN  
                        IP-Kount3 = (IP-Kount3 + 1).                                                           
                                 
                EXPORT STREAM outward DELIMITER ";"                                                 
                    TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID                                                
                    TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid                                  
                    TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr                                                                     
                    "Replaced TESTS_HE_SPECIMEN_RATIOS_RCD.".                 
                      
                DELETE  TESTS_HE_SPECIMEN_RATIOS_RCD  NO-ERROR.                                              
                 
            END.  /** IF AVAILABLE (TESTS_HE_SPECIMEN_RATIOS_RCD) **/    

/* 1dot1 */     
                  
            CREATE TESTS_HE_SPECIMEN_RATIOS_RCD.
        
            ASSIGN     
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_hair_color = tt.HE_hair_color
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_ca_mg = tt.HE_Ratio_ca_mg
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_ca_p = tt.HE_Ratio_ca_p
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_na_k = tt.HE_Ratio_na_k
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_zn_cd = tt.HE_Ratio_zn_cd
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_Ratio_zn_cu = tt.HE_Ratio_zn_cu
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_sample_type = tt.HE_sample_type
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_sample_weight = tt.HE_sample_weight
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_shampoo = tt.HE_shampoo
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_1 = tt.HE_total_toxics_1
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_2 = tt.HE_total_toxics_2
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_3 = tt.HE_total_toxics_3
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_total_toxics_4 = tt.HE_total_toxics_4
                TESTS_HE_SPECIMEN_RATIOS_RCD.HE_treatment = tt.HE_treatment
                TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid = tt.Lab_Sampleid
                TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr = tt.Lab_Sampleid_SeqNbr
                TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID = tt.PatientID
                TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_DateTime = DATE(tt.Progress_DateTime)
                TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = tt.Progress_Flag
                TESTS_HE_SPECIMEN_RATIOS_RCD.Test_Abbv = tt.Test_Abbv
            .  
            
            IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_DateTime = ? THEN 
                ASSIGN TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_DateTime = TODAY. 

            EXPORT STREAM outward DELIMITER ";"                                                 
                    TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID                                                
                    TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid                                  
                    TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr                                                                     
                    "New TESTS_HE_SPECIMEN_RATIOS_RCD.".   
                                    
            RELEASE TESTS_HE_SPECIMEN_RATIOS_RCD.
        
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
