
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

DEFINE VARIABLE MyDirName AS CHARACTER INITIAL "C:\apps\HL7\src\Inbound_EDI_Files\" FORMAT "x(60)" NO-UNDO. /** name of the Directory you'd like to Walk **/
/*DEFINE VARIABLE MyDirName       AS CHARACTER INITIAL "C:\apps\HL7\src\Inbound_EDI_Files\" FORMAT "x(60)" NO-UNDO. /** name of the Directory you'd like to Walk **/*/
DEFINE VARIABLE ITmessage       AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE showcounters    AS LOGICAL INITIAL NO NO-UNDO.

DEFINE TEMP-TABLE NameTable   /* freshtest */ 
    FIELD filecount AS INTEGER 
    FIELD afile     AS CHARACTER FORMAT "x(20)"
    FIELD fullfile  AS CHARACTER FORMAT "x(40)"
    FIELD fileattr  AS CHARACTER
        INDEX NT-main-idx AS PRIMARY UNIQUE filecount 
        INDEX NT-word-idx AS WORD-INDEX fullfile. 

DEFINE VARIABLE typecode AS INTEGER NO-UNDO.

DEFINE VARIABLE PDF-fileid  AS INTEGER   NO-UNDO.
DEFINE VARIABLE EDI-fileid  AS INTEGER   NO-UNDO.
DEFINE VARIABLE fileid      AS INTEGER   NO-UNDO.
DEFINE VARIABLE INfile      AS CHARACTER NO-UNDO.
DEFINE VARIABLE HL7file     AS CHARACTER NO-UNDO.
DEFINE VARIABLE SSfile      AS CHARACTER NO-UNDO.
DEFINE VARIABLE ERRfile     AS CHARACTER NO-UNDO.

DEFINE VARIABLE INpath  AS CHARACTER NO-UNDO.
DEFINE VARIABLE HL7path AS CHARACTER NO-UNDO.
DEFINE VARIABLE SSpath  AS CHARACTER NO-UNDO.
DEFINE VARIABLE XML-ERRpath AS CHARACTER NO-UNDO.

DEFINE VARIABLE coredir     AS CHARACTER INITIAL "C:\apps\HL7\src\" NO-UNDO.
DEFINE VARIABLE NewEDIfull  AS CHARACTER INITIAL "C:\apps\HL7\src\Processed_EDI_Files\successful\" NO-UNDO.
DEFINE VARIABLE NewSSfull   AS CHARACTER INITIAL "C:\apps\HL7\src\Processed_SS_Files\successful\" NO-UNDO.

DEFINE VARIABLE reccount    AS INTEGER INITIAL 1 NO-UNDO.
DEFINE VARIABLE iteration   AS INTEGER NO-UNDO.
DEFINE VARIABLE c-nametable AS INTEGER NO-UNDO. /* nametable counter */
DEFINE VARIABLE invalidFiles AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE updatemode  AS LOGICAL LABEL "Run Program in Update Mode?" INITIAL YES NO-UNDO.
DEFINE VARIABLE runthis     AS CHARACTER NO-UNDO.
DEFINE VARIABLE old-EDI     AS CHARACTER NO-UNDO.
DEFINE VARIABLE new-EDI     AS CHARACTER NO-UNDO.
DEFINE VARIABLE err-EDI     AS CHARACTER NO-UNDO.
DEFINE VARIABLE old-SS      AS CHARACTER NO-UNDO.
DEFINE VARIABLE new-SS      AS CHARACTER NO-UNDO.

DEFINE VARIABLE o-file_id   AS INTEGER NO-UNDO.
DEFINE VARIABLE o-fail      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-success   AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-create    AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-update    AS LOGICAL NO-UNDO.
DEFINE VARIABLE comm-line1  AS CHARACTER NO-UNDO.
DEFINE VARIABLE comm-line2  AS CHARACTER NO-UNDO.

DEFINE VARIABLE logfile     AS CHARACTER NO-UNDO.
DEFINE VARIABLE timeInMilliseconds AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE thisday     AS CHARACTER FORMAT "x(7)" NO-UNDO.
DEFINE VARIABLE thisyear    AS CHARACTER NO-UNDO.
DEFINE VARIABLE months      AS CHARACTER INITIAL "JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC" NO-UNDO.

ASSIGN   
    thisyear = STRING(YEAR(TODAY), "9999")
    thisyear = SUBSTRING(thisyear,3,4) 
    thisday  = STRING(DAY(TODAY), "99") + ENTRY(MONTH(TODAY),months) + thisyear + "-" + STRING(TIME, "HH:MM:SS")
    .

/* ***************************  Main Block  *************************** */
PROCEDURE namewalk:
            
    DEFINE INPUT PARAMETER dirname AS CHARACTER FORMAT "x(50)" NO-UNDO.
    DEFINE OUTPUT PARAMETER iteration AS INTEGER NO-UNDO.

    ASSIGN 
        iteration = iteration + 1.
                                                                                                         
    INPUT FROM OS-DIR(dirname).  /* "c:\progress\wrk\" VALUE( */
           
        REPEAT: /* *** repeats for objects found - folders and files *** */  
                
            CREATE NameTable. 
            
            ASSIGN 
                reccount    = reccount + 1
                filecount   = reccount. 
            
            IMPORT afile fullfile fileattr.            
                                                               
            IF afile = "" OR afile = "." OR afile = ".." OR filecount = 0 OR afile = "DONT_TOUCH" THEN
                DELETE NameTable.
                
        END.  /* *** of repeat - file list *** */
        
    INPUT CLOSE.  
                                                                                      
END. /* of namewalk */
                                                                  
/*UPDATE SKIP (8) MyDirName COLON 15 SKIP (8) WITH FRAME maine TITLE "Insert Directory Name (Full Path)" WIDTH 80 SIDE-LABELS .*/
                                                                                               
RUN namewalk(MyDirName, OUTPUT iteration).   /** name of the directory that you are searching ***/ 
                                                                    IF ITmessage = YES THEN 
                                                                    DO:
                                                                        MESSAGE
                                                                            "afile = " afile SKIP(1) 
                                                                            "iteration = " iteration SKIP(1)
                                                                            "logfile = " logfile 
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "End of namewalk.".
                                                                    END.                                                                    
OUTPUT STREAM filelist TO "C:\apps\HL7\src\Error_log\DireXMLWalk_log.txt" APPEND.

PAUSE 0 BEFORE-HIDE.

EXPORT STREAM filelist DELIMITER ";"
    "******************* DireXMLWalk Log File Initialated *******************".

EXPORT STREAM filelist DELIMITER ";"
    thisday.
    
EXPORT STREAM filelist DELIMITER ";"
    "File_Count" "File_Name" "Full_Path" "File_Attr" "Errors".

/*UPDATE SKIP (8) updatemode SKIP (8) WITH SIDE-LABELS FRAME firstmenu WIDTH 80 TITLE "Program Mode:".*/
  
FOR EACH nametable EXCLUSIVE-LOCK:     /*** cleanup records ***/

    IF afile = "" AND fullfile = "" AND fileattr = "" OR afile = "DONT_TOUCH" THEN

        DELETE nametable.

    ELSE DO:

        EXPORT STREAM filelist DELIMITER ";" nametable.

        IF fileattr = "F" THEN DO:

            IF (R-INDEX(afile,".") > 0 AND SUBSTRING(afile, (R-INDEX(afile,".") + 1)) = "txt") THEN DO:
                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE
                                                                            "afile = " afile SKIP(1)
                                                                            "fullfile = " fullfile SKIP(1)
                                                                            "SSfile = " SSfile
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "Before XMLgen.p".
                                                                    END.             
                RUN VALUE(SEARCH("XMLgen.r")) (
                    afile,
                    OUTPUT INfile,
                    OUTPUT HL7file,
                    OUTPUT SSfile,
                    OUTPUT ERRfile,
                    OUTPUT o-fail
                    ).
                
                IF o-fail = YES THEN 
                    EXPORT STREAM filelist DELIMITER ";"
                       filecount afile fullfile "--" "Error 1: XMLgen Failed.".
                

                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE
                                                                            "afile = " afile SKIP(1)
                                                                            "fullfile = " fullfile SKIP(1)
                                                                            "SSfile = " SSfile
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "After XMLgen.p. Before ASSIGN statement".
                                                                    END.
                RUN VALUE(SEARCH("getStringTimeMilliseconds.r")) (
                    OUTPUT timeInMilliseconds
                    ).                                                                    
                                                                    
                ASSIGN
                    INpath  = "Inbound_EDI_Files\" + INfile
                    HL7path = "HL7_XML_Files\" + HL7file
                    SSpath  = NewSSfull + SSfile
                    XML-ERRpath = "Processed_SS_Files\failed\" + ERRfile
                    runthis = "C:\apps\HL7\src\Pipeline_batch.bat " + INpath + " " + HL7path + " " + SSpath + " " + XML-ERRpath
                    old-EDI = coredir + INpath
                    old-SS  = coredir + SSpath
                    new-EDI = NewEDIfull + timeInMilliseconds + "_" + INfile
                    new-SS  = NewSSfull + SSfile
                    err-EDI = coredir + "Processed_EDI_Files\failed\" + INfile
                    .  
                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE
                                                                            "INpath = " INpath SKIP(1)
                                                                            "HL7path = " HL7path SKIP(1)
                                                                            "XML-ERRpath = " XML-ERRpath SKIP(1)
                                                                            "SSfile = " SSfile SKIP(1)
                                                                            "SSpath = " SSpath
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "After ASSIGN statement. Before XML Conversion".
                                                                    END.
            /* *** XML Conversion *** */
                IF o-fail = NO AND updatemode = YES THEN
                DO:
                
                /* *** UTM_pipeline.jar *** */    
                    OS-COMMAND SILENT VALUE(runthis).
                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE
                                                                            "SSfile = " SSfile
                                                                             SEARCH("eXorcisM_Load.r")
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "After UTM_pipeline.jar. Before eXorcisM_Load".
                                                                    END.
                /* *** eXorcisM_Load.p *** */
                    RUN VALUE(SEARCH("eXorcisM_Load.r")) (
                        NewSSFull,
                        SSfile,
                        OUTPUT fileid,
                        OUTPUT o-fail
                        ).
                     
                    IF o-fail = YES THEN DO:
                        EXPORT STREAM filelist DELIMITER ";"
                            filecount SSfile NewSSFull "--" "Error 2: eXorcisM_Load Failed.".
                        ASSIGN invalidFiles = invalidFiles + 1.
                        IF SEARCH(err-EDI) = ? THEN
                            OS-RENAME VALUE(old-EDI) VALUE(err-EDI). 
                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE
                                                                            "SSfile = " SSfile SKIP(1)
                                                                            "fileid = " fileid SKIP(1)
                                                                            "o-fail = " o-fail
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "After eXorcisM_Load.p. Before OS-RENAME.".
                                                                    END.
                    END.
                END.  /* *** XML Conversion *** */
            
            /* *** OS-RENAME *** */
                IF o-fail = NO AND updatemode = YES THEN DO:
                    IF SEARCH(new-EDI) = ? THEN
                                          
                        OS-RENAME VALUE(old-EDI) VALUE(new-EDI).
                    
                    ELSE DO:
                        
                        EXPORT STREAM filelist DELIMITER ";"
                            filecount INfile NewEDIfull "--" "Error 3: EDI file already exists in completed folder.".                       
                        
                        o-fail = YES.
                    END. 
                    IF SEARCH(new-SS) = ? THEN     
                        
                        OS-RENAME VALUE(old-SS) VALUE(new-SS).
                    
                    ELSE DO:
                        
                        EXPORT STREAM filelist DELIMITER ";"
                            filecount SSfile NewSSfull "--" "Error 4: SS file already exists in completed folder.".
                        
                        o-fail = YES.    
                    END.
                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE
                                                                            "old-EDI = " old-EDI SKIP(1)
                                                                            "new-EDI = " new-EDI SKIP(1)
                                                                            "old-SS = " old-SS SKIP(1)
                                                                            "fileid = " fileid SKIP(1)
                                                                            "new-SS = " new-SS
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "After OS-RENAME. Before EDI-fileid ASSIGN.".
                                                                    END.
                                                                        
                    /** OS-RENAME PDF file **/
                   
                END. /*** of OS-RENAME ***/
            /* *** File attachment *** */
                IF o-fail = NO AND updatemode = YES THEN 
                DO:
                          
                    ASSIGN
                        EDI-fileid = NEXT-VALUE(seq-attfile)
                        PDF-fileid = NEXT-VALUE(seq-attfile).
                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE                                                                          
                                                                            "fileid = " fileid SKIP(1)
                                                                            "EDI-fileid = " EDI-fileid SKIP(1)
                                                                            SEARCH("SUBatt-ucU.r")
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "After EDI-fileid ASSIGN. Before File attachment.".
                                                                    END.                              
                    
                    /** run SUBatt-ucU for the PDF file as well **/
                    
                    RUN VALUE(SEARCH("SUBatt-ucU.r")) (
                        EDI-fileid,
                        "fs_mstr",
                        "fs_file_ID",
                        EDI-fileid,
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        NewEDIfull,
                        INfile,
                        "",
                        "",
                        "",
    
                        OUTPUT EDI-fileid,
                        OUTPUT o-create,
                        OUTPUT o-update,
                        OUTPUT o-success
                        ).
                        
                    IF o-success = NO THEN 
                        EXPORT STREAM filelist DELIMITER ";"
                            filecount INfile NewEDIfull "--" "Error 5: EDI File Attachment Failed.".                          
                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE
                                                                            "EDI-fileid = " EDI-fileid SKIP(1)
                                                                            "o-create = " o-create SKIP(1)
                                                                            "o-update = " o-update SKIP(1)
                                                                            "o-success = " o-success SKIP(1)
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "After EDI file assignment. Before SS file assignment".
                                                                    END.                                                                                                       
                    RUN VALUE(SEARCH("SUBatt-ucU.r")) (
                        fileid,
                        "fs_mstr",
                        "fs_file_ID",
                        fileid,
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        "",
                        NewSSfull,
                        SSfile,
                        "",
                        "",
                        "",
    
                        OUTPUT fileid,
                        OUTPUT o-create,
                        OUTPUT o-update,
                        OUTPUT o-success
                        ).
    
                    IF o-success = NO THEN 
                        EXPORT STREAM filelist DELIMITER ";"
                            filecount SSfile NewSSfull "--" "Error 6: SS File Attachment Failed.".
    
                        ASSIGN
                            c-nametable = c-nametable + 1.
                                                                    IF ITmessage = YES THEN
                                                                    DO:
                                                                        MESSAGE
                                                                            "fileid = " fileid SKIP(1)
                                                                            "o-create = " o-create SKIP(1)
                                                                            "o-update = " o-update SKIP(1)
                                                                            "o-success = " o-success SKIP(1)
                                                                            "c-nametable = " c-nametable SKIP(1)
                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                            TITLE "After SS file Assignment. End of 4ea.".
                                                                    END.
                END. /* File attachment */

            END. /*** the file is a txt ***/

        END. /*** of fileattr = F ***/

    END. /*** Else, because there is a file here ***/

END.  /** of 4ea. nametable --- cleanup **/

EXPORT STREAM filelist DELIMITER ";"
    "******************* END OF LOG *******************".

OUTPUT STREAM filelist CLOSE. /* file list */

MESSAGE "Processed" c-nametable "valid files and" invalidFiles "invalid files." VIEW-AS ALERT-BOX BUTTONS OK.
                                                                    IF ITmessage = YES THEN 
                                                                    DO:
                                                                
                                                                        FOR EACH NameTable NO-LOCK:
                                                                    
                                                                            DISPLAY NameTable
                                                                                WITH WIDTH 132 TITLE "Final Output".
                                                                    
                                                                        END.  /** of 4ea. NameTable --- Display **/
                                                                    
                                                                    END.

/********************************   END OF LINE   *******************************/
