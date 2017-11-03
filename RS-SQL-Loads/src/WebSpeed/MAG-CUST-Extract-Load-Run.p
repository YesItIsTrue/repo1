/*------------------------------------------------------------------------
    File        : MAG-CUST-Extract-Load-Run.p
    Purpose     : Connect to the Magento System and extract the Magento Customer
                : data (using program: magentoconnection.exe and its 
                : configuration file: magentoconnection.exe.config),
                : from the last 24 hours or since the last run,
                : then run the RS-MAG_CUST_RCD-Load.p using the extracted 
                : Magento Customer data and then the RStP-MAG-CUST-U program. 

    Description : Program to run the MAG-CUST programs everyday.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="2.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="8/May/15">
    <META NAME="LAST_UPDATED" CONTENT="3/Jan/17">
    
    Version: 1.2    By Harold Luttrell, Sr.
        Date: 20/Aug/15.
        Modified code to use the new "RUN VALUE(SEARCH("pgm.r"))
            statement instead of the long pathing name. 
        Identified by /** 1dot2 **/  
     
     Version: 1.3    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Remove PROPATH displays.
        Identified by /* 1dot3 */  
     
     Version: 2.0    By Harold Luttrell, Sr.
        Date: 3/Jan/17.
        Modified code to use the new input HL7 folder name: \OpenEdge\WRK\Files-Input\.
        Identified by /* 2dot0 */  
    
    Version 2.1 - written by HAROLD LUTTRELL, JR. on 03/Oct/17.  Changed to use
                    proper database names in accordance with Release 12
                    (CMC structure).  Marked by 2dot1.  
                               
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
   
/*DO x = 1 TO NUM-ENTRIES(PROPATH):           */                                /* 1dot3 */
/*    PUT UNFORMATTED  ENTRY(x,PROPATH)  SKIP.*/                                /* 1dot3 */
/*END.                                        */                                /* 1dot3 */

/* ***************************  Main Block  *************************** */
ASSIGN t-dte = (TODAY - 7).     /*  7-28-15 - changed to 7 days instead of 1.  */

ASSIGN char-dte = STRING(YEAR(t-dte), "9999") + "/" + STRING(MONTH(t-dte), "99") + "/" + STRING(DAY(t-dte), "99").

    
PUT UNFORMATTED "Starting MAG CUST Run." SKIP.

ASSIGN cmdname = "P:/OpenEdge/Batch-Runs/magentoconnection.exe".
/*ASSIGN cmdparam = " " + char-dte + " P:/OpenEdge/WRK/Files-Input/MAG-CUST-RCD-Extracted.txt".                       /* 2dot0 */*/
ASSIGN cmdparam = " " + char-dte + " Input-Files/MAG-CUST-RCD-Extracted.txt".                   /* 2dot1 */


IF drive_letter = "C" THEN DO:
    ASSIGN cmdname = "C:/OpenEdge/Batch-Runs/magentoconnection.exe".
    ASSIGN cmdparam = " " + char-dte + " C:/OpenEdge/WRK/Files-Input/MAG-CUST-RCD-Extracted.txt".                   /* 2dot0 */      
END.  /* IF drive_letter = "C" THEN DO: */  

IF  USERID("CORE")        = "Harold.Luttrell"  THEN DO:                                /* 2dot1 */                  /* 2dot0 */
    ASSIGN cmdname = "C:/OpenEdge/Batch-Runs/magentoconnection.exe".                                                /* 2dot0 */
    ASSIGN cmdparam = " " + char-dte + " Q:/OpenEdge/WRK/Files-Input/MAG-CUST-RCD-Extracted.txt".                   /* 2dot0 */ 
END.  /* IF drive_letter = "q" THEN DO: */                                                                          /* 2dot0 */
    
PUT UNFORMATTED "1 of 3. : magentoconnection.exe" SKIP.   
    OS-COMMAND SILENT 
        VALUE(cmdname)   
        VALUE(cmdparam).  
     
PUT UNFORMATTED "2 of 3. : MAG_CUST-Load.r" SKIP.                                                                   /* 2dot0 */

RUN VALUE(SEARCH("MAG_CUST-Load.r")).                                                                               /* 2dot0 */
 
PUT UNFORMATTED "3 of 3. : RStP-MAG-CUST-U.r" SKIP. 
    
/*     (following program uses subroutine: RStP-MAG-CUST-BIL-U.p & RStP-MAG-CUST.i) */

RUN VALUE(SEARCH("RStP-MAG-CUST-U.r")).                                         /** 1dot2 **/

PUT UNFORMATTED "  End of MAG CUST Run." SKIP.

/*  End of program. */
