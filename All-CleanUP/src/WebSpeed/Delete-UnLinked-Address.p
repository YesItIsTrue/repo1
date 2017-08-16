 
/*------------------------------------------------------------------------
    File        : Delete-UnLinked-Address.p
    Purpose     : To be run in Batch Mode until what ever is un-linking
                : the addr_mstr has been found and fixed.

    Syntax      :

    Description : Deletes all addr_mstr records that are NOT LINKed
                : to any people_mstr.

    Author(s)   : Harold D. Luttrell, Sr.
    Created     : Wed Apr 01, 2015
    Notes       :
  ----------------------------------------------------------------------*/

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
            CAN-FIND(FIRST  people_mstr WHERE  people_addr_id  = addr_id  NO-LOCK )
     EXCLUSIVE-LOCK  BY addr_addr1 :

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

/*  2nd findings.  */
/*
FOR  EACH  people_mstr 
        WHERE  people_mstr.people_second_addr_ID  > 0  EXCLUSIVE-LOCK  :

    FIND  addr_mstr 
            WHERE  addr_mstr.addr_id = people_mstr.people_second_addr_ID 
        NO-LOCK NO-ERROR. 

    IF NOT AVAILABLE (addr_mstr) THEN DO: 

        ASSIGN recordsprocessed2 = (recordsprocessed2 + 1 ).

        DISPLAY STREAM outward "addr_mstr 2: NOT FOUND:"
                General.people_mstr.people_second_addr_ID     FORMAT "zzzzz9"
                General.people_mstr.people_firstname  FORMAT "x(20)"
                General.people_mstr.people_lastname  FORMAT "x(20)"
                General.people_mstr.people_id     FORMAT "zzzzz9"
            WITH FRAME outdetail2 WIDTH 132 DOWN.
            DOWN WITH FRAME outdetail2.
                
          ASSIGN Deleted-cnt2 = (Deleted-cnt2 + 1).
          
        ASSIGN  General.people_mstr.people_second_addr_ID = 0
                General.people_mstr.people_modified_by  = USERID ("General")
                General.people_mstr.people_modified_date = TODAY
                General.people_mstr.people_prog_name    = THIS-PROCEDURE:FILE-NAME.
      
    END.  /** IF NOT AVAILABLE (addr_mstr) **/

    IF  AVAILABLE (addr_mstr) THEN DO: 
    
        IF  people_mstr.people_addr_ID = 0  THEN DO: 
            ASSIGN  people_mstr.people_addr_id = people_mstr.people_second_addr_ID
                    people_mstr.people_second_addr_ID = 0.
                    
            DISPLAY STREAM outward "addr_mstr 2: Moved to 1:"
                General.people_mstr.people_addr_ID     FORMAT "zzzzz9"
                General.people_mstr.people_firstname  FORMAT "x(20)"
                General.people_mstr.people_lastname  FORMAT "x(20)"
                General.people_mstr.people_id     FORMAT "zzzzz9"
            WITH FRAME outdetail3 WIDTH 132 DOWN.
            DOWN WITH FRAME outdetail3.   
                  
        END.  /**   **/
            
    END.  /** IF AVAILABLE (addr_mstr) **/      
    
END.  /*  2nd findings.  */
    
    DISPLAY STREAM outward
        "End addr_mstr 2: NOT FOUND: processing at:" TODAY STRING(TIME, "HH:MM:SS") SKIP
        recordsprocessed2  COLON 30  SKIP
        Deleted-cnt2       COLON 30  SKIP
        "End of Report." SKIP (3)
    WITH FRAME outtrailer2 WIDTH 120 SIDE-LABELS.
*/

OUTPUT STREAM outward CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).
     