
/*------------------------------------------------------------------------

    File        : DireAttachedWalk.p
    Purpose     : To walk through each file in the entire Attached Files directory and pull the information out of 
                each of the source files and check to see if it is in the right spot, in regards to what is in the 
                PROGRESS Databases, General and 

    Description : The joint dirwalk and attchwalk programs.

    Author(s)   : Trae Luttrell
    Created     : Mon Jul 13 11:38:36 EDT 2015
    Updated     : Fri Sep 11 15:42:00 EDT 2015
    Version     : 1.0
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE STREAM filelist.

DEFINE VARIABLE MyDirName AS CHARACTER INITIAL "C:\APPS\BioMed\AttachedFiles\" FORMAT "x(60)" NO-UNDO. /** name of the Directory you'd like to Walk **/
DEFINE VARIABLE ITmessage AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE showcounters AS LOGICAL INITIAL NO NO-UNDO.

DEFINE TEMP-TABLE NameTable   /* freshtest */ 
    FIELD fileid AS INTEGER 
    FIELD afile AS CHARACTER FORMAT "x(20)"
    FIELD fullfile AS CHARACTER FORMAT "x(40)"
    FIELD fileattr AS CHARACTER
        INDEX NT-main-idx AS PRIMARY UNIQUE fileid 
        INDEX NT-word-idx AS WORD-INDEX fullfile. 

DEFINE VARIABLE reccount AS INTEGER INITIAL 1 NO-UNDO.
DEFINE VARIABLE iteration AS INTEGER NO-UNDO.
DEFINE VARIABLE c-nametable AS INTEGER NO-UNDO. /* nametable counter */
DEFINE VARIABLE updatemode AS LOGICAL LABEL "Run Program in Update Mode?" INITIAL NO NO-UNDO.

DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE pinwheel AS CHARACTER FORMAT "x" EXTENT 4 NO-UNDO.
ASSIGN 
    pinwheel[1] = "|"
    pinwheel[2] = "/" 
    pinwheel[3] = "-"
    pinwheel[4] = "\".
 
DEFINE NEW SHARED VARIABLE c-dwightUTMUEE1 AS LOGICAL  NO-UNDO.    
DEFINE NEW SHARED VARIABLE c-dwightUTMUEE2 AS LOGICAL  NO-UNDO.    


/* ***********  Other Output and External Proc Definitions  ********** */
DEFINE STREAM to-error.
DEFINE VARIABLE v-filelocation  AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE errlog AS CHARACTER INITIAL "C:\PROGRESS\WRK\DireAttachedWalk-log.txt" NO-UNDO.
DEFINE VARIABLE attw-result AS INTEGER NO-UNDO. /*** 0 = didn't run, # = the # of the error, 99 = successfully ran. ***/
OUTPUT STREAM to-error TO VALUE(errlog).
EXPORT STREAM to-error DELIMITER ";" "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM to-error DELIMITER ";" /* These are column headers. */
    "Source Text File"
    "Lab Sample ID"                                                 
    "Lab Seq"
    "Last Lab Seq"
    "Source File People ID"
    "ID from att_value5"    /*** which is from the RS side, which is the same as the folder name, in theory ***/
    "Full Path ID"          /*** which IS the same as the folder name ***/
    "TK_patient_ID"
    "Last Name"
    "First Name"
    "Test Kit ID"
    "Test Kit Seq"
    "Test Type"   
    "DOB"
    "Error Number"
    "Error Message".

OUTPUT STREAM to-error CLOSE.

DEFINE STREAM to-dwight.
DEFINE VARIABLE dwightaddress AS CHARACTER INITIAL "C:\PROGRESS\WRK\DwightReport.txt" NO-UNDO.
OUTPUT STREAM to-dwight TO VALUE(dwightaddress).
EXPORT STREAM to-dwight DELIMITER ";"
    "Source File ID"
    "Attached File ID"
    "Full Path ID"
    "Lab Sample ID"
    "Lab Seq"
    "Test Kit ID"
    "Test Type".

OUTPUT STREAM to-dwight CLOSE.

/* ***************************  Main Block  *************************** */
PROCEDURE namewalk:
            
    DEFINE INPUT PARAMETER dirname AS CHARACTER FORMAT "x(50)" NO-UNDO.

    ASSIGN 
        iteration = iteration + 1.
                                                                                                         
    INPUT FROM OS-DIR(dirname).  /* "c:\progress\wrk\" VALUE( */
           
        REPEAT: /*** repeats for objects found - folders and files ***/
           
            CREATE NameTable. 

            ASSIGN 
                reccount    = reccount + 1
                fileid      = reccount. 
            
            IMPORT afile fullfile fileattr.            
                                                               
            IF afile = "" OR afile = "." OR afile = ".." OR fileid = 0 THEN
                    
                DELETE NameTable.

            ELSE IF fileattr = "D" AND fileid > 2 AND NOT afile BEGINS "."  THEN DO:
              
                RUN namewalk(fullfile).
            
            END. 
                
        END.  /** of repeat - file list **/
        
    INPUT CLOSE.  
                                                                                      
END. /* of namewalk */

UPDATE SKIP (8) MyDirName COLON 15 SKIP (8) WITH FRAME maine TITLE "Insert Directory Name (Full Path)" WIDTH 80 SIDE-LABELS .
                                                                                               
RUN namewalk(MyDirName).   /** name of the directory that you are searching ***/
    
OUTPUT STREAM filelist TO "C:\PROGRESS\WRK\Direwalk-test-2.txt".

PAUSE 0 BEFORE-HIDE.

/*MESSAGE "Done with the Directory Walk, proceeding with the Attach Walk. :]".*/
    
EXPORT STREAM filelist DELIMITER ";" 
    "File_ID" "File_Name" "Full_Path" "File_Attr".

UPDATE SKIP (8) updatemode SKIP (8) WITH SIDE-LABELS FRAME firstmenu WIDTH 80 TITLE "Program Mode:".
  
FOR EACH nametable:     /*** cleanup records ***/ 
       
    IF afile = "" AND fullfile = "" AND fileattr = "" THEN 
        DELETE nametable.
        
    ELSE DO:
        EXPORT STREAM filelist DELIMITER ";" nametable.
        
        IF fileattr = "F" THEN DO: 

            IF (R-INDEX(afile,".") > 0 AND SUBSTRING(afile, (R-INDEX(afile,".") + 1)) = "txt") THEN DO:
                 
                RUN VALUE(SEARCH("ATT-attchwalk-R.p")) 
                    ( afile, fullfile, errlog, dwightaddress, updatemode, OUTPUT attw-result).
                
/*                IF attw-result <> 0 THEN*/ 
                
                    ASSIGN 
                        c-nametable = c-nametable + 1.
                
                IF c-nametable MODULO 10 = 0 THEN DO: 
                        i = i + 1.
                        IF i >= 5 THEN 
                         i = 1.
                        DISPLAY "Processing . . . " pinwheel[i]
                                     WITH FRAME outstat WIDTH 80 NO-LABELS OVERLAY.     
                END.
                
            END. /*** the file is a txt ***/ 
            
        END. /*** of fileattr = F ***/
         
    END. /*** Else, because there is a file here ***/ 
                
END.  /** of 4ea. nametable --- cleanup **/

OUTPUT STREAM filelist CLOSE. /* file list */

MESSAGE c-nametable "text files were found." VIEW-AS ALERT-BOX BUTTONS OK.

IF ITmessage = YES THEN DO:
    
    FOR EACH NameTable NO-LOCK:
        
        DISPLAY NameTable
            WITH WIDTH 132 TITLE "Final Output".
        
    END.  /** of 4ea. NameTable --- Display **/
    
END.  /** of if itmessage = YES **/

/********************************   END OF LINE   *******************************/
