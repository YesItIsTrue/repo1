
/*------------------------------------------------------------------------
    File        : Save_Inputs.p
    Purpose     : 

    Description : Makes a copy of the input files from a specific directory into
                    a different directory, date / time stamping them along the way.

    Author(s)   : Doug Luttrell
    Created     : Mon May 25 19:32:16 EDT 2015
    Notes       :
        
    Version 1.1 : 7/11/2015 by Harold Luttrell.
                : Corrected drive C path names.
                : Identified by: 1dot1.
        
    Version 1.2 : 7/14/2015 by Harold Luttrell.
                : Added emailaddr-USERID.i code.
                : Identified by: 1dot2.
                
    Version 1.3 : 11/20/2015 by Harold Luttrell.
                : Removed dead code.
                : Not identified.
                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/******************   Local Machine or Server?   ************************/
DEFINE VARIABLE codetorun       AS CHARACTER                        NO-UNDO.    
DEFINE VARIABLE drive_letter    AS CHARACTER                        NO-UNDO. 

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).

/*********  Where they are and where they're going  *************/
DEFINE VARIABLE olddir AS CHARACTER FORMAT "x(60)" NO-UNDO.    
DEFINE VARIABLE newdir AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE errlog AS CHARACTER NO-UNDO.

IF drive_letter = "P" THEN 
    ASSIGN  
        olddir = "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\"
        newdir = "P:\OpenEdge\WRK\RS-SQL-Loads\Processed_Files\"
        errlog = "P:\OpenEdge\WRK\RS-SQL-Loads\LOGS\RStP-save_inputs-U-errlog.txt".
ELSE 
    ASSIGN 
        olddir = "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\"                          /* 1dot1 */
        newdir = "C:\OpenEdge\Workspace\RS-SQL-Loads\Processed_Files\"                      /* 1dot1 */
        errlog = "C:\OpenEdge\Workspace\RS-SQL-Loads\LOGS\RStP-save_inputs-U-errlog.txt".   /* 1dot1 */


/***********  To hold contents of directories  *************/
DEFINE TEMP-TABLE filelist 
    FIELD origfile AS CHARACTER FORMAT "x(60)"
    FIELD fullfile AS CHARACTER FORMAT "x(60)"
    FIELD fileattr AS CHARACTER 
    FIELD buttsy AS CHARACTER 
    FIELD newfile AS CHARACTER FORMAT "x(60)" 
        INDEX fl-orig AS PRIMARY UNIQUE origfile
        INDEX fl-new newfile
        INDEX fl-wordorig AS WORD-INDEX origfile.        

    
DEFINE VARIABLE x AS INTEGER NO-UNDO.       /*** junk counter ***/ 
DEFINE VARIABLE y AS INTEGER NO-UNDO.       /*** another junk counter ***/
DEFINE VARIABLE founddot AS INTEGER NO-UNDO.  /** used to remove files with 2+ periods **/

DEFINE VARIABLE oldpathname AS CHARACTER FORMAT "x(100)" NO-UNDO.
DEFINE VARIABLE newpathname AS CHARACTER FORMAT "x(100)" NO-UNDO.

DEFINE VARIABLE moveresult AS INTEGER NO-UNDO.
DEFINE VARIABLE resdesc AS CHARACTER FORMAT "x(30)" NO-UNDO.
DEFINE VARIABLE ITshowmsg AS LOGICAL INITIAL NO NO-UNDO.

/**********************  Error mail settings  ********************************/
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report Attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.
DEFINE VARIABLE sendemail       AS LOGICAL                                                              NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
 
{emailaddr-USERID.i}.                                                      /* 1dot2 */

/* ********************  Preprocessor Definitions  ******************** */

DEFINE STREAM errstream. 

    
/***********  Load up directory contents  **************/
INPUT FROM OS-DIR(olddir).
OUTPUT STREAM errstream TO VALUE(errlog).

froot-loop: 
REPEAT:
    
    CREATE filelist.
    IMPORT origfile fullfile fileattr.
    
    /**** cleanup blank records, directories, etc. *****/
    IF origfile = ""  OR 
        fileattr <> "F" THEN DO:
            
            EXPORT STREAM errstream filelist.
            EXPORT STREAM errstream "Blank or non-File attribute".
            DELETE filelist.
            NEXT froot-loop.
            
    END.  /** of if origfile = "", etc. **/        
            
    /**** cleanup multiple dots in a filename  *****/        
    ASSIGN 
        founddot    = 0
        x           = 0.
            
    DO x = 1 TO LENGTH(origfile):
        
        IF SUBSTRING(origfile,x,1) = "." THEN 
            founddot = founddot + 1.        
            
    END. /** of do x = 1 to length(origfile) **/
       
    IF founddot > 1 THEN DO:
        
        EXPORT STREAM errstream filelist.
        EXPORT STREAM errstream "Too many dots".
        DELETE filelist.        
        NEXT froot-loop.
        
    END.  /** of if founddot > 1 **/ 
                
    IF origfile MATCHES "*NONULLS*" THEN DO:
        EXPORT STREAM errstream filelist.
        EXPORT STREAM errstream "Found a NONULLS file.".
        DELETE filelist.
        NEXT froot-loop.
    END.  /** of if origfile matches *NONULLS* --- delete the NoNulls from the list **/
                
    /******  Break into component parts  ************/            
    ASSIGN 
        buttsy      = SUBSTRING(origfile, R-INDEX(origfile,"."))
 /*       origfile    = SUBSTRING(origfile, 1, R-INDEX(origfile,"."))  */
        y           = y + 1.
                 
    IF y MODULO 1000 = 0 THEN 
        DISPLAY y origfile buttsy.         
             
END.  /** of repeat - file list **/


INPUT CLOSE.

/* ***************************  Main Block  *************************** */

ASSIGN 
    x = 0.
    
FOR EACH filelist NO-LOCK:
    
    ASSIGN 
        newfile = STRING(origfile) +
                    "_" + 
                    STRING(YEAR(TODAY),"9999") +
                    "-" + 
                    STRING(MONTH(TODAY),"99") +
                    "-" +
                    STRING(DAY(TODAY),"99") +
                    "_" +
                    REPLACE(STRING(TIME,"HH:MM:SS"),":","-") + 
                    buttsy.
    
    ASSIGN 
        oldpathname     = olddir + origfile
        newpathname     = newdir + newfile.

                                                                                IF ITshowmsg = YES THEN 
                                                                                    DISPLAY 
                                                                                        olddir FORMAT "x(100)" SKIP 
                                                                                        origfile FORMAT "x(100)" SKIP 
                                                                                        newdir FORMAT "x(100)" SKIP 
                                                                                        newfile FORMAT "x(100)" SKIP 
                                                                                        oldpathname SKIP 
                                                                                        newpathname SKIP(1)
                                                                                            WITH FRAME a WIDTH 132 1 COL TITLE "What Happened".
   
    OS-COPY value(oldpathname) value(newpathname).  /*  better than OS-RENAME */
   
    /** Error Checking **/
    moveresult  = OS-ERROR. 
    
    CASE moveresult:
        WHEN 0 THEN 
            resdesc = "No Error".
        WHEN 1 THEN 
            resdesc = "Not Owner".
        WHEN 2 THEN 
            resdesc = "No such file or directory".
        WHEN 3 THEN 
            resdesc = "Interrupted system call".
        WHEN 4 THEN 
            resdesc = "I/O error".
        WHEN 5 THEN 
            resdesc = "Bad file number".
        WHEN 6 THEN 
            resdesc = "No more processes".
        WHEN 7 THEN 
            resdesc = "Not enough core memory".
        WHEN 8 THEN 
            resdesc = "Permission denied".
        WHEN 9 THEN 
            resdesc = "Bad address".
        WHEN 10 THEN 
            resdesc = "File exists".
        WHEN 11 THEN 
            resdesc = "No such device".
        WHEN 12 THEN 
            resdesc = "Not a directory".
        WHEN 13 THEN
            resdesc = "Is a directory".
        WHEN 14 THEN 
            resdesc = "File table overflow".
        WHEN 15 THEN 
            resdesc = "Too many open files".
        WHEN 16 THEN 
            resdesc = "File too large".
        WHEN 17 THEN 
            resdesc = "No space left on device".
        WHEN 18 THEN 
            resdesc = "Directory not empty".
        WHEN 999 THEN 
            resdesc = "Unmapped error".                 
    END CASE.  /** moveresult **/  
       
    IF moveresult <> 0 THEN DO: 
        DISPLAY origfile moveresult resdesc.
        IF moveresult <> 13 THEN 
            sendemail = YES.
    END. /** if moveresult <> 0 **/
    
END.  /** OF 4ea. filelist **/

OUTPUT STREAM errstream CLOSE.

IF sendemail = YES THEN 
    OS-COMMAND SILENT 
        VALUE(cmdname)  
        VALUE(emailaddr)
        VALUE(messagetxt) 
        VALUE(subjtxt) 
        VALUE(cmdparams) 
        VALUE(errlog).

/*************************   END OF FILE   *****************************/
