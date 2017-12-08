
/*------------------------------------------------------------------------
    File        : HL7-Load-Append-Rpts.p
    Purpose     : 

    Syntax      :

    Description : Append/Merge the all the reports to one report file 
                : per run with today's date & time added to the end of the 
                : report file name.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Jul 13, 2017.
    Notes       :
    
                    
    Revision History:
    -----------------
    1.1 - written by Harold Luttrell, Sr. on 15/Sept/17. 
          Added code to accept the input total tests that was processed
          for this scheduled run.  If input value > 0 then merge the 
          other reports else get out of program after merging only the
          first report.
          Marked by /* 1dot1 */  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  c-tests-processed   AS INTEGER                      NO-UNDO.    /* 1dot1 */ 

DEFINE VARIABLE OS-stat                 AS INTEGER                          NO-UNDO.
DEFINE VARIABLE H-File-Name             AS CHARACTER FORMAT  "x(100)"       NO-UNDO.
DEFINE VARIABLE datetime                AS CHARACTER                        NO-UNDO. 

/* ********************  Preprocessor Definitions  ******************** */
/*DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.*/
/*ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). */

{Logs_Rpts_Paths_Folders.i}.    /* Logs/Reports folder path. */ 

FIND Logs_Rpts_Paths_Folders WHERE TT-Logs-Rpts-Seq_Nbr_only = 1 NO-LOCK NO-ERROR. 

ASSIGN datetime = STRING(DATETIME(TODAY, MTIME)).
/*DISPLAY datetime FORMAT "x(40)" SKIP(2).*/

/*ASSIGN H-File-Name = "C:\PROGRESS\WRK\HL7-Load-Rpts-".*/
ASSIGN H-File-Name = TT-Logs-Rpts-Path-Folder + "HL7-Load-Rpts-".
ASSIGN H-File-Name = H-File-Name + SUBSTRING(datetime, 7, 4) + SUBSTRING(datetime, 1, 2) + SUBSTRING(datetime, 4, 2) + "-"
    + SUBSTRING(datetime, 12, 2) + SUBSTRING(datetime, 15, 2) + SUBSTRING(datetime, 18, 2) + SUBSTRING(datetime, 21, 3)  + ".txt".
/*DISPLAY H-File-Name.*/

DEFINE STREAM AppendRPTS.
DEFINE VARIABLE loadRpt AS CHARACTER NO-UNDO.

ASSIGN loadRpt = H-File-Name.

OUTPUT STREAM AppendRPTS TO value(loadRpt) APPEND PAGED. 
 
PUT STREAM AppendRPTS 
    "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP.
    
PUT STREAM AppendRPTS 
    "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP(1). 

PUT STREAM AppendRPTS
    "Reports follow:" SKIP(2).
    
PAGE STREAM AppendRPTS.
OUTPUT STREAM AppendRPTS CLOSE.

/* ***************************  Main Block  *************************** */

     OS-APPEND      
/*            VALUE ("C:\PROGRESS\WRK\HL7-Load-Main-Rpt.txt") VALUE (H-File-Name).*/
            VALUE (TT-Logs-Rpts-Path-Folder + "HL7-Load-Main-Rpt.txt") VALUE (H-File-Name). 
                       
        OS-stat = OS-ERROR. 
        IF  OS-stat <> 0 THEN DISPLAY "OS-ERROR COPY1 = " OS-stat SKIP.

/* Merge the other reports if any tests data was selected during this scheduled run. */         /* 1dot1 */
     IF  c-tests-processed > 0 THEN DO:                                                         /* 1dot1 */
         OS-APPEND      
/*                VALUE ("C:\PROGRESS\WRK\People-Load-Rpt.txt") VALUE (H-File-Name).*/
                VALUE (TT-Logs-Rpts-Path-Folder + "People-Load-Rpt.txt") VALUE (H-File-Name).      
         OS-stat = OS-ERROR. 
         IF  OS-stat <> 0 THEN DISPLAY "OS-ERROR COPY2 = " OS-stat SKIP.        

         OS-APPEND      
/*                VALUE ("C:\PROGRESS\WRK\Address-Load-Rpt.txt") VALUE (H-File-Name).*/
                VALUE (TT-Logs-Rpts-Path-Folder + "Address-Load-Rpt.txt") VALUE (H-File-Name).          
         OS-stat = OS-ERROR. 
         IF  OS-stat <> 0 THEN DISPLAY "OS-ERROR COPY3 = " OS-stat SKIP.        

         OS-APPEND      
/*                VALUE ("C:\PROGRESS\WRK\TestKits-Load-Rpt.txt") VALUE (H-File-Name).*/
                VALUE (TT-Logs-Rpts-Path-Folder + "TestKits-Load-Rpt.txt") VALUE (H-File-Name).            
         OS-stat = OS-ERROR. 
         IF  OS-stat <> 0 THEN DISPLAY "OS-ERROR COPY2 = " OS-stat SKIP.        

         OS-APPEND      
/*                VALUE ("C:\PROGRESS\WRK\TestsDetails-Load-Rpt.txt") VALUE (H-File-Name).*/
                VALUE (TT-Logs-Rpts-Path-Folder + "TestsDetails-Load-Rpt.txt") VALUE (H-File-Name).            
         OS-stat = OS-ERROR. 
         IF  OS-stat <> 0 THEN DISPLAY "OS-ERROR COPY2 = " OS-stat SKIP.  
     END.  /* IF  c-tests-processed > 0 */                                                      /* 1dot1 */

OUTPUT STREAM AppendRPTS TO value(loadRpt) APPEND.
       
PUT STREAM AppendRPTS   
     "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP.
                        
/* End of program. */
