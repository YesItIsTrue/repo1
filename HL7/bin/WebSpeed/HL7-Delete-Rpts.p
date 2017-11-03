
/*------------------------------------------------------------------------
    File        : HL7-Delete-Rpts.p
    Purpose     : 

    Syntax      :

    Description : Deletes the HL7-Load-Rpts.YYYYMMDD-time.txt files that are 
                : over two (2) weeks old inorder to keep the disk area
                : cleaned up. 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Mon Jul 17 10:50:12 CDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE OS-stat             AS INTEGER          NO-UNDO.
DEFINE VARIABLE c-nbr-deleted       AS INTEGER          NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE STREAM DeleteRpts.
DEFINE VARIABLE loadRpt AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\HL7_Delete-Rpts-log.txt" NO-UNDO.
OUTPUT STREAM DeleteRpts TO value(loadRpt) APPEND. 

PUT STREAM DeleteRpts 
    "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP.
PUT STREAM DeleteRpts 
    "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP.

/* ***************************  Main Block  *************************** */

PUT STREAM DeleteRpts  "======================================" SKIP.
PUT STREAM DeleteRpts  "*****   Begin HL7 Delete Rpts    *****" SKIP(1).

OS-COMMAND  SILENT    
            VALUE ("DEL " + "C:\Progress\WRK\" + "HL7-Rptslist.txt").
            
ASSIGN OS-stat = OS-ERROR. 

IF  OS-stat NE 0 THEN    PUT STREAM DeleteRpts   "OS-ERROR DEL = " OS-stat SKIP.
     
OS-COMMAND  SILENT   
            VALUE ("DIR " + "C:\Progress\WRK\HL7-Load-Rpts-*.txt" + " >> C:\Progress\WRK\" + "HL7-Rptslist.txt").
            
ASSIGN OS-stat = OS-ERROR.

IF  OS-stat <> 0 THEN   PUT STREAM DeleteRpts   "OS-ERROR DEL = " OS-stat SKIP.

DEFINE  TEMP-TABLE rptslist_data  
        FIELD IP_Field-1  AS CHARACTER FORMAT "x(60)"
        FIELD IP_Field-2  AS CHARACTER FORMAT "x(60)"         
        FIELD IP_Field-3  AS CHARACTER FORMAT "x(60)"
        FIELD IP_Field-4  AS CHARACTER FORMAT "x(60)"
        FIELD IP_Field-5  AS CHARACTER FORMAT "x(80)"
            INDEX temp-data         AS PRIMARY UNIQUE IP_Field-5. 
                     
INPUT FROM "C:\Progress\WRK\HL7-Rptslist.txt". 
         
REPEAT:  
    CREATE   rptslist_data.   
                                                                  
    IMPORT DELIMITER " "  rptslist_data.
    
    IF  IP_Field-1 = "" OR IP_Field-1 = "Volume" OR 
        IP_Field-1 = "0" OR SUBSTRING(IP_Field-2, 1, 4) = "File" OR IP_Field-1 = "Directory" THEN DELETE rptslist_data. 
        
END.  /** REPEAT **/ 
   
INPUT CLOSE. 

PUT STREAM DeleteRpts   " Deleting file(s) before " (TODAY - 14) "." SKIP.
        
FOR EACH rptslist_data  WHERE IP_Field-1 <> "" NO-LOCK :
/*    PUT STREAM DeleteRpts   "IP_Field-1 =" TRIM(IP_Field-1) SKIP.                */
/*    PUT STREAM DeleteRpts   "IP_Field-2 =" IP_Field-2 SKIP.                      */
/*    PUT STREAM DeleteRpts   "IP_Field-3 =" IP_Field-3 SKIP.                      */
/*    PUT STREAM DeleteRpts   "IP_Field-4 =" IP_Field-4 SKIP.                      */
/*    PUT STREAM DeleteRpts   "IP_Field-5 =" TRIM(IP_Field-5)  FORMAT "x(60)" SKIP.*/

    IF  DATE(TRIM(IP_field-1)) < (TODAY - 15) THEN DO:         
        
        ASSIGN c-nbr-deleted = (c-nbr-deleted + 1).
        
        PUT STREAM DeleteRpts   "  " IP_Field-5 FORMAT "x(60)" SKIP.
        
        OS-COMMAND  SILENT    
            VALUE ("DEL " + "C:\Progress\WRK\" + TRIM(IP_Field-5) ).
            
        ASSIGN OS-stat = OS-ERROR. 
    
        IF  OS-stat <> 0 THEN   PUT STREAM DeleteRpts   "OS-ERROR DEL = " INTEGER(OS-stat)  " File: "  IP_Field-5 FORMAT "x(60)" SKIP.
          
    END. 
 
END. 
PUT STREAM DeleteRpts   " " SKIP.
PUT STREAM DeleteRpts   "    Total Files deleted = " c-nbr-deleted FORMAT ">>9"    SKIP(1). 
PUT STREAM DeleteRpts   "*****    End HL7 Delete Rpts     *****" SKIP.
PUT STREAM DeleteRpts   "======================================" SKIP.   
   
OUTPUT STREAM DeleteRpts CLOSE.

/* End of program. */    