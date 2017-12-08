/*------------------------------------------------------------------------
    File        : MAG-CUST-Load-Run-TEST.p
    Purpose     : Connect to the Magento System and extract the Magento Customer
                : data (using program: magentoconnection.exe and its 
                : configuration file: magentoconnection.exe.config),
                : from the last 7 days,
                : then run the MAG_CUST-Load-TEST.p using the extracted 
                : Magento Customer data and then the RStP-MAG-CUST-U program. 

    Description : Program to run the MAG-CUST programs everyday.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="2.1">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="8/May/15">
    <META NAME="LAST_UPDATED" CONTENT="09/Oct/17">
    
    Version: 1.2    By Harold Luttrell, Sr.
        Date: 20/Aug/15.
        Modified code to use the new "RUN VALUE(SEARCH("pgm.r"))
            statement instead of the long pathing name. 
        Identified by /* 1dot2 */  
        
     Version: 1.3    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Remove PROPATH displays.
        Identified by /* 1dot3 */  
     
     Version: 2.0    By Harold Luttrell, Sr.
        Date: 3/Jan/17.
        Modified code to use the new input HL7 folder name: \OpenEdge\WRK\Files-Input\.
        Identified by /* 2dot0 */  
    
    Version 2.1 - written by Harold Luttrell, Sr. on 09/Oct/17.  Changed to use
                    proper database names in accordance with Release 12
                    (CMC structure).  Marked by 2dot1.  

    Version 2.2 - written by Harold Luttrell, Sr. on 17/Oct/17.  
                  Added new program: Magento-Remove-Tilde-Chars.r
                  This program replaces the Tilde's (anywhere within
                  each input data record) with two (2) single quote marks.
                  When a Tilde was present it would not process the rest
                  of the input data for that record.   
                  Marked by 2dot2. 
                                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO. 
  
DEFINE VARIABLE cmdname      AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE cmdparam     AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE t-dte        AS DATE NO-UNDO. 
DEFINE VARIABLE char-dte     AS CHARACTER FORMAT "x(10)" NO-UNDO. 
DEFINE VARIABLE x            AS INTEGER NO-UNDO.
/* ********************  Preprocessor Definitions  ******************** */

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).
/*                                                   */
{UTIL-set_propath-HHI_TEST-U.i}.  						/* 2dot1 */
   
/*DO x = 1 TO NUM-ENTRIES(PROPATH):           */                                /* 1dot3 */
/*    PUT UNFORMATTED  ENTRY(x,PROPATH)  SKIP.*/                                /* 1dot3 */
/*END.                                        */                                /* 1dot3 */

/* ***************************  Main Block  *************************** */
ASSIGN t-dte = (TODAY - 7).     /*  7-28-15 - changed to 7 days instead of 1.  */

ASSIGN char-dte = STRING(YEAR(t-dte), "9999") + "/" + STRING(MONTH(t-dte), "99") + "/" + STRING(DAY(t-dte), "99").

PUT UNFORMATTED "Starting MAG CUST Load Run." SKIP.

PUT UNFORMATTED char-dte SKIP.
    
PUT UNFORMATTED "/**************************************************************" SKIP
                " *                                                             " SKIP
                " * Starting MAG CUST Run - TEST version.                       " SKIP
                " *                                                             " SKIP
                " * ----------------------------------------------------------  " SKIP
                " *                                                             " SKIP
                " * This program is called from TEST-Magento_Customer_Load.bat  " SKIP
                " *                                                             " SKIP
                " * ----------------------------------------------------------  " SKIP
                " *                                                             " SKIP                
                " * Step 1 of 4 - Actual Magento Connection and download.       " SKIP
                " *                                                             " SKIP
                " **************************************************************/" SKIP(1).

ASSIGN cmdname = "P:/OpenEdge/TEST/Batch-Runs/magentoconnection.exe".                            /* 2dot1 */
ASSIGN cmdparam = " " + char-dte + " " + "c:/apps/RStP/Input-Files/MAG-CUST-RCD-Extracted.txt".            /* 2dot1 */
  
PUT UNFORMATTED "1 of 4. : magentoconnection.exe" SKIP(1).
  
OS-COMMAND SILENT 
    VALUE(SEARCH(cmdname))   
    VALUE(cmdparam).  
    
PUT UNFORMATTED "/**************************************************************" SKIP
                " *                                                             " SKIP
                " * Step 2 of 4 - Remove Tilde Characters from input data.      " SKIP
                " *                                                             " SKIP
                " **************************************************************/" SKIP(1).
               
PUT UNFORMATTED "2 of 4. : MAG-CUST-Remove-Tilde-Chars.r" SKIP(1).                              /* 2dot2 */

RUN VALUE(SEARCH("MAG-CUST-Remove-Tilde-Chars.r")).                                             /* 2dot2 */
    
PUT UNFORMATTED "/**************************************************************" SKIP
                " *                                                             " SKIP
                " * Step 3 of 4 - Load data into temporary tables.              " SKIP
                " *                                                             " SKIP
                " **************************************************************/" SKIP(1).
                
PUT UNFORMATTED "3 of 4. : MAG_CUST-Load-TEST.r" SKIP(1).                                       /* 2dot1 */

RUN VALUE(SEARCH("MAG_CUST-Load-TEST.r")).                                                      /* 2dot1 */

PUT UNFORMATTED "/**************************************************************" SKIP
                " *                                                             " SKIP
                " * Step 4 of 4 - Move data temporary tables to real ones.      " SKIP
                " *                                                             " SKIP
                " **************************************************************/" SKIP(1).
                 
PUT UNFORMATTED "4 of 4. : RStP-MAG-CUST-U.r" SKIP(1). 
    
/*     (following program uses subroutine: RStP-MAG-CUST-BIL-U.p & RStP-MAG-CUST.i) */

RUN VALUE(SEARCH("RStP-MAG-CUST-U.r")).                                         /** 1dot2 **/

PUT UNFORMATTED "/**************************************************************" SKIP
                " *                                                             " SKIP
                " * End of MAG CUST Run.                                        " SKIP
                " *                                                             " SKIP
                " **************************************************************/" SKIP(1).

PROPATH = ORIGPROPATH.                                                                        /* 2dot1 */

/*  End of program. */
