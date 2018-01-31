/*------------------------------------------------------------------------
    File        : PROD-Delete-UnLinked-Address.p
    Purpose     : To be run in Batch Mode until what ever is un-linking
                : the addr_mstr has been found and fixed.

    Syntax      :

    Description : Deletes all addr_mstr records that are NOT LINKed
                : to any people_mstr.

    Author(s)   : Harold D. Luttrell, Sr.
    Created     : Wed Apr 01, 2015
    Notes       :
        
  --------------------------------------------------------------------
  
  Revision History:
  -----------------
  1.0 - written by HAROLD LUTTRELL.  Original Version.
  1.1 - written by DOUG LUTTRELL on 12/Oct/17.  Changed pathing to support
            single rcode directory approach.  Marked by 1dot1.
  1.2 - written by DOUG LUTTRELL on 13/Oct/17.  Corrected the 4ea. / Find 
            to use the new pal_list table pursuant to the Release 12 (CMC
            structure).  Marked 1dot2.
                    
  ----------------------------------------------------------------------*/

{UTIL-set_propath-HHI_PROD-U.i}.                    /* 1dot1 */

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE recordsprocessed1 AS INTEGER LABEL "Records can not find"    NO-UNDO.
DEFINE VARIABLE Deleted-cnt1 AS INTEGER LABEL "     Records Deleted"         NO-UNDO.
DEFINE VARIABLE recordsprocessed2 AS INTEGER LABEL "Records NOT Found"       NO-UNDO.
DEFINE VARIABLE Deleted-cnt2 AS INTEGER LABEL "     Records Zeroed out"      NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
/* ***************************  E-Mail  Definitions  *************************** */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Log Report Attached from HHI-DC-4 running "    NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Log Report from Delete-UnLinked-Address.p"     NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.

/* ********************  Error-Log File Definitions  ******************** */   
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\Delete-UnLinked-Address-Log.txt"     NO-UNDO.
OUTPUT  STREAM outward TO value(errlog). 
DISPLAY STREAM outward 
          "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(80)" SKIP    
          "Start of input processing at: " TODAY STRING(TIME, "HH:MM:SS")
         WITH FRAME outheader WIDTH 120 SIDE-LABELS.


DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.        
DEFINE VARIABLE codetorun AS CHARACTER  FORMAT "x(80)" NO-UNDO.           

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).           

IF drive_letter = "C" THEN 
    ASSIGN  emailaddr   = "-r harold.luttrell@mysolsource.com".

/* ***************************  Main Block  *************************** */
/*  1st findings.  */
FOR  EACH  addr_mstr WHERE  NOT
/*            CAN-FIND(FIRST  people_mstr WHERE  people_addr_id  = addr_id  NO-LOCK )                 /* 1dot2 */*/
        CAN-FIND(FIRST pal_list WHERE pal_list.pal_addr_ID = addr_mstr.addr_id NO-LOCK)                 /* 1dot2 */
     EXCLUSIVE-LOCK:

    ASSIGN recordsprocessed1 = (recordsprocessed1 + 1).

      DISPLAY STREAM outward "addr_mstr: NOT CAN-FIND:"
                addr_id     FORMAT "zzzzz9"
                addr_addr1  FORMAT "x(30)"
                addr_city   FORMAT "x(20)"
                addr_stateprov  FORMAT "x(20)"
                addr_zip
            WITH FRAME outdetail1 WIDTH 132 DOWN.
            DOWN WITH FRAME outdetail1.
            
      ASSIGN Deleted-cnt1 = (Deleted-cnt1 + 1).
      
      DELETE addr_mstr.
      
END.  /*  1st findings.  */

    DISPLAY STREAM outward
        "End addr_mstr: NOT CAN-FIND: processing at:" TODAY STRING(TIME, "HH:MM:SS") SKIP
        recordsprocessed1  COLON 30  SKIP
        Deleted-cnt1       COLON 30  SKIP (2)
    WITH FRAME outtrailer2 WIDTH 120 SIDE-LABELS.

OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).
     
     
/****************************************  End of File  ************************************************/
     