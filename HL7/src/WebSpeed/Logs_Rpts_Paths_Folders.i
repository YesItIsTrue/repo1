
/*------------------------------------------------------------------------
    File        : Logs_Rpts_Paths_Folders.i
    Purpose     : To pass the path folder for the logs/reports that are
                : generated from the UTIL-set_propath-HHI_xxxx-U.i code
                : for batch programs due to the CMC structure implementation.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="30/Oct/17">
    <META NAME="LAST_UPDATED" CONTENT="30/Oct/17">

    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 30/Oct/17.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
DEFINE {1} {2} SHARED TEMP-TABLE Logs_Rpts_Paths_Folders    
    FIELD TT-Logs-Rpts-Seq_Nbr_only        AS INTEGER           /* sequence nbr (1 - nnn) for this temp file. */

    FIELD TT-Logs-Rpts-Path-Folder         AS CHARACTER         /* contains the log/report folder path-from 
                                                                   the UTIL-set_propath-HHI_xxxx-U.i code.   */          
         
            INDEX temp-data         AS PRIMARY UNIQUE  TT-Logs-Rpts-Seq_Nbr_only .
            