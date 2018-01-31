
/*------------------------------------------------------------------------

    File        : DireXMLWalk-TEST.p
    Purpose     : To walk through each file in the entire "C:\apps\HL7\Inbound_EDI_Files\" directory and 
                : pull the information out of each of the input files and 
                : then pass the data to the eXorcisM_Load.p program to extract the information and 
                : store the detail data fields in the Core DB, tables: fs_mstr and atn_det
                : for the HL7-Load-Main.p program to process the data.

    Description : Process the input Test Results data files from DDI.
                : The joint dirwalk and attchwalk programs.
                
    Author(s)   : Trae Luttrell
    Created     : Mon Jul 13 11:38:36 EDT 2015
    Updated     : Fri Sep 11 15:42:00 EDT 2015
    Version     : 1.0
           
    Revision History:
    -----------------
    1.1 - written by Harold Luttrell, Sr. on 13/Sept/17. 
          Added code to get the disk drive letter,
          store off the original propath variables, 
          based on the drive letter add the paths projects for the 
          DataHub, depot and HL7 in front of the original propath.
          At the end of the program, reset the propath back to the original.
          Marked by /* 1dot1 */.
    
    1.2 - written by Harold Luttrell, Sr. on 14/Sept/17.
          Moved the Inbound_EDI_Files folder from the 
          C:\APPS\HL7\src\Inbound_EDI_Files\     folder to the
          C:\APPS\HL7\Inbound_EDI_Files\ folder for ease of placement of 
          the input data files.
          Marked by /* 1dot2 */
    
    1.3 - written by Harold Luttrell, Sr. on 24/Oct/17. 
          Changed to use single rcode PROPATH settings in accordance 
          with Release 12 (CMC structure).  This also replaces the old 
          drive P and C structures.
          Marked by /* 1dot3 */
          
    1.4 - Commented out check for matching pdf. We seem to be going back and forth
          on this, but for now, all files are processed whether they have a matching pdf
          or not. - Andrew Garver
              
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
   
{UTIL-set_propath-HHI_TEST-U.i}.                                          /* 1dot3 */ 
 
DEFINE VARIABLE ITmessages AS LOGICAL INITIAL YES    NO-UNDO.

DEFINE STREAM filelist.

OUTPUT STREAM filelist TO "C:\apps\HL7\ErrorLog\DireXMLWalk_TEST_log.txt" APPEND.

IF  ITmessages THEN DO:                                                 /* 1dot1 */ 
    PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */   
    PUT UNFORMATTED  "PROPATH =" PROPATH  SKIP. /* displays the PROPATH values in the batch C:\Progress\WRK\HL7_log.txt file. */ /* 1dot1 */
    PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */
END.                                                                    /* 1dot1 */

PAUSE 0 BEFORE-HIDE.

DEFINE VARIABLE MyDirName AS CHARACTER INITIAL "C:\apps\HL7\Inbound_EDI_Files_TEST\" FORMAT "x(60)" NO-UNDO. /** name of the Directory to Walk **/ /* 1dot2 */

DEFINE TEMP-TABLE NameTable 
    FIELD filecount AS INTEGER 
    FIELD afile     AS CHARACTER FORMAT "x(60)"
    FIELD fullfile  AS CHARACTER FORMAT "x(255)"
    FIELD fileattr  AS CHARACTER
        INDEX NT-main-idx AS PRIMARY UNIQUE filecount 
        INDEX NT-word-idx AS WORD-INDEX fullfile. 

DEFINE VARIABLE PDF-file-id  AS INTEGER   NO-UNDO.
DEFINE VARIABLE EDI-file-id  AS INTEGER   NO-UNDO.
DEFINE VARIABLE XML-file-id      AS INTEGER   NO-UNDO.

DEFINE VARIABLE successful-EDI-dir  AS CHARACTER INITIAL "C:\apps\HL7\Processed_TEST\EDI\Successful\" NO-UNDO.
DEFINE VARIABLE successful-XML-dir   AS CHARACTER INITIAL "C:\apps\HL7\Processed_TEST\XML\Successful\" NO-UNDO.
DEFINE VARIABLE successful-PDF-dir AS CHARACTER INITIAL "C:\apps\HL7\Processed_TEST\PDF\Successful\" NO-UNDO.
DEFINE VARIABLE failed-EDI-dir AS CHARACTER INITIAL "C:\apps\HL7\Processed_TEST\EDI\Error\" NO-UNDO.
DEFINE VARIABLE failed-XML-dir AS CHARACTER INITIAL "C:\apps\HL7\Processed_TEST\XML\Error\" NO-UNDO.
DEFINE VARIABLE failed-PDF-dir AS CHARACTER INITIAL "C:\apps\HL7\Processed_TEST\PDF\Error\" NO-UNDO.
DEFINE VARIABLE source-file-dir AS CHARACTER INITIAL "C:\apps\HL7\Inbound_EDI_Files_TEST\" NO-UNDO.                  /* 1dot2 */
DEFINE VARIABLE HL7-XML-dir AS CHARACTER INITIAL "C:\apps\HL7\src\HL7_XML_Files\" NO-UNDO.

DEFINE VARIABLE full-original-EDI-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-original-PDF-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-successful-EDI-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-successful-PDF-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-successful-XML-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-error-EDI-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-error-PDF-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-error-XML-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-HL7-filepath AS CHARACTER NO-UNDO.

DEFINE VARIABLE reccount    AS INTEGER INITIAL 1 NO-UNDO.
DEFINE VARIABLE iteration   AS INTEGER NO-UNDO.
DEFINE VARIABLE c-nametable AS INTEGER NO-UNDO. /* nametable counter */
DEFINE VARIABLE invalidFiles AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE updatemode  AS LOGICAL LABEL "Run Program in Update Mode?" INITIAL YES NO-UNDO.

DEFINE VARIABLE runthis     AS CHARACTER NO-UNDO.
DEFINE VARIABLE stripped-filename       AS CHARACTER NO-UNDO.
DEFINE VARIABLE timestamped-filename    AS CHARACTER NO-UNDO.

DEFINE VARIABLE o-file_id   AS INTEGER NO-UNDO.
DEFINE VARIABLE o-fail      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-success   AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-create    AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-update    AS LOGICAL NO-UNDO.
DEFINE VARIABLE comm-line1  AS CHARACTER NO-UNDO.
DEFINE VARIABLE comm-line2  AS CHARACTER NO-UNDO.

DEFINE VARIABLE thisday     AS CHARACTER FORMAT "x(7)" NO-UNDO.
DEFINE VARIABLE thisyear    AS CHARACTER NO-UNDO.
DEFINE VARIABLE months      AS CHARACTER INITIAL "JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC" NO-UNDO.
DEFINE VARIABLE systime     AS CHARACTER INITIAL "" NO-UNDO.

ASSIGN   
    thisyear = STRING(YEAR(TODAY), "9999")
    thisyear = SUBSTRING(thisyear,3,4) 
    thisday  = STRING(DAY(TODAY), "99") + ENTRY(MONTH(TODAY),months) + thisyear + "-" + STRING(TIME, "HH:MM:SS")
    .

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

/* ***************************  Main Block  *************************** */

RUN namewalk(MyDirName, OUTPUT iteration).   /** name of the directory that you are searching ***/ 

EXPORT STREAM filelist DELIMITER ";"
    "******************* DireXMLWalk Log File Initialated *******************".
    
IF  ITmessages THEN                                                                 /* 1dot1 */
    EXPORT STREAM filelist DELIMITER ";"                                            /* 1dot1 */
        "iteration=" iteration "   reccount=" reccount "   filecount=" filecount.   /* 1dot1 */

EXPORT STREAM filelist DELIMITER ";"
    thisday.
  
EXPORT STREAM filelist DELIMITER ";"
    "File_Count" "File_Name" "Full_Path" "File_Attr" "Errors".
  
FOR EACH nametable EXCLUSIVE-LOCK:     /*** cleanup records ***/
    
    IF afile = "" AND fullfile = "" AND fileattr = "" OR afile = "DONT_TOUCH" THEN

        DELETE nametable.

    ELSE DO:

        EXPORT STREAM filelist DELIMITER ";" nametable.

        IF fileattr = "F" THEN DO:

            IF (R-INDEX(afile,".") > 0 AND SUBSTRING(afile, (R-INDEX(afile,".") + 1)) = "txt") THEN DO:
                
                IF  ITmessages THEN     EXPORT STREAM filelist "1-going    to getStringTimeMilliseconds.r".       /* 1dot1 */
                
                RUN VALUE(SEARCH("getStringTimeMilliseconds.r")) (
                    OUTPUT systime
                    ).
                    
                IF  ITmessages THEN     EXPORT STREAM filelist "1-return from getStringTimeMilliseconds.r".       /* 1dot1 */
                
                ASSIGN
                    stripped-filename               = SUBSTRING(afile,1,INDEX(afile,".txt") - 1)
                    timestamped-filename            = stripped-filename + "-" + systime
                    full-HL7-filepath               = HL7-XML-dir + timestamped-filename + ".xml"
                    full-original-EDI-filepath      = source-file-dir + afile
                    full-original-PDF-filepath      = source-file-dir + stripped-filename + ".pdf"
                    full-successful-EDI-filepath    = successful-EDI-dir + timestamped-filename + ".txt"
                    full-successful-PDF-filepath    = successful-PDF-dir + timestamped-filename + ".pdf"
                    full-successful-XML-filepath    = successful-XML-dir + timestamped-filename + ".xml"
                    full-error-EDI-filepath         = failed-EDI-dir + timestamped-filename + ".txt"
                    full-error-PDF-filepath         = failed-PDF-dir + timestamped-filename + ".pdf"
                    full-error-XML-filepath         = failed-XML-dir + timestamped-filename + ".xml"
                    runthis                     = "C:\apps\HL7\src\Pipeline_batch.bat " + full-original-EDI-filepath  + " " + full-HL7-filepath + " " + full-successful-XML-filepath + " " + full-error-XML-filepath
                    .

/*                IF SEARCH(full-original-PDF-filepath) = ? THEN DO:        */   /* 1dot4 */
/*                    EXPORT STREAM filelist DELIMITER ";"                  */
/*                        "Loner File Ignored: " full-original-EDI-filepath.*/
/*                END.                                                      */
/*                ELSE DO:                                                  */
    
                /* *** XML Conversion *** */
                    IF updatemode = YES THEN
                    DO:
                    
                    /* *** UTM_pipeline.jar *** */    
                        OS-COMMAND SILENT VALUE(runthis).
    
                    /* *** eXorcisM_Load.p *** */
                        IF  ITmessages THEN     EXPORT STREAM filelist "2-going  to eXorcisM_Load.r".               /* 1dot1 */
                        
                        RUN VALUE(SEARCH("eXorcisM_Load.r")) (
                            successful-XML-dir,
                            timestamped-filename + ".xml",
                            OUTPUT XML-file-id,
                            OUTPUT o-fail
                            ).
                            
                        IF  ITmessages THEN     EXPORT STREAM filelist "2-return from eXorcisM_Load.r".             /* 1dot1 */
                        
                        IF o-fail = YES THEN DO:
                            EXPORT STREAM filelist DELIMITER ";"
                                filecount full-successful-EDI-filepath "--" "Error 2: eXorcisM_Load Failed.".
                            EXPORT STREAM filelist DELIMITER ";"
                                "successful-XML-dir =" successful-XML-dir.
                            EXPORT STREAM filelist DELIMITER ";"
                                "XML-file-id        =" XML-file-id.    
                            ASSIGN invalidFiles = invalidFiles + 1.
                            IF SEARCH(full-error-EDI-filepath) = ? THEN
                                OS-RENAME VALUE(full-original-EDI-filepath) VALUE(full-error-EDI-filepath).
                            IF SEARCH(full-error-PDF-filepath) = ? THEN     
                                OS-RENAME VALUE(full-original-PDF-filepath) VALUE(full-error-PDF-filepath). 
                        END.
                    END.  /* *** XML Conversion *** */
                
                /* *** OS-RENAME *** */
                    IF o-fail = NO AND updatemode = YES THEN DO:
                        IF SEARCH(full-successful-EDI-filepath) = ? THEN
                            OS-RENAME VALUE(full-original-EDI-filepath) VALUE(full-successful-EDI-filepath).
                        ELSE DO:
                            EXPORT STREAM filelist DELIMITER ";"
                                filecount full-successful-EDI-filepath "--" "Error 3: EDI file already exists in completed folder.".                       
                            o-fail = YES.
                        END. 
                        IF SEARCH(full-successful-PDF-filepath) = ? THEN     
                            OS-RENAME VALUE(full-original-PDF-filepath) VALUE(full-successful-PDF-filepath).
                        ELSE 
                        DO:
                            EXPORT STREAM filelist DELIMITER ";"
                                filecount full-successful-PDF-filepath "--" "Error 8: PDF file already exists in completed folder.".
                            o-fail = YES.    
                        END.
                    END. /*** of OS-RENAME ***/
                
                /* *** File attachment *** */
                    IF o-fail = NO AND updatemode = YES THEN 
                    DO:                         

                        IF  ITmessages THEN     EXPORT STREAM filelist "3-EDI  to SUBatt-ucU.r".                /* 1dot1 */
                                              
                        /* Save EDI File */
                        RUN VALUE(SEARCH("SUBatt-ucU.r")) (
                            NEXT-VALUE(seq-attfile),
                            "fs_mstr",
                            "fs_file_ID",
                            XML-file-id,
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            successful-EDI-dir,
                            timestamped-filename + ".txt",
                            "",
                            "",
                            "",
        
                            OUTPUT EDI-file-id,
                            OUTPUT o-create,
                            OUTPUT o-update,
                            OUTPUT o-success
                            ).

                        IF  ITmessages THEN     EXPORT STREAM filelist "3-EDI from SUBatt-ucU.r".               /* 1dot1 */
                                                    
                        IF o-success = NO THEN 
                            EXPORT STREAM filelist DELIMITER ";"
                                filecount full-successful-EDI-filepath "--" "Error 5: EDI File Attachment Failed.".                          
    
                        IF  ITmessages THEN     EXPORT STREAM filelist "4-PDF  to SUBatt-ucU.r".                /* 1dot1 */
                                
                        /* Save PDF File */                                          
                        RUN VALUE(SEARCH("SUBatt-ucU.r")) (
                            NEXT-VALUE(seq-attfile),
                            "fs_mstr",
                            "fs_file_ID",
                            XML-file-id,
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            successful-PDF-dir,
                            timestamped-filename + ".pdf",
                            "",
                            "",
                            "",
        
                            OUTPUT PDF-file-id,
                            OUTPUT o-create,
                            OUTPUT o-update,
                            OUTPUT o-success
                            ).

                        IF  ITmessages THEN     EXPORT STREAM filelist "4-PDF from SUBatt-ucU.r".               /* 1dot1 */
                                                    
                        IF o-success = NO THEN 
                            EXPORT STREAM filelist DELIMITER ";"
                                filecount full-successful-PDF-filepath "--" "Error 6: PDF File Attachment Failed.".
            
                        IF  ITmessages THEN     EXPORT STREAM filelist "5-XML  to SUBatt-ucU.r".                /* 1dot1 */
                                                   
                        /* Save XML File */                                                                                                     
                        RUN VALUE(SEARCH("SUBatt-ucU.r")) (
                            XML-file-id,
                            "fs_mstr",
                            "fs_file_ID",
                            XML-file-id,
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            "",
                            successful-XML-dir,
                            timestamped-filename + ".xml",
                            "",
                            "",
                            "",
        
                            OUTPUT XML-file-id,
                            OUTPUT o-create,
                            OUTPUT o-update,
                            OUTPUT o-success
                            ).
 
                        IF  ITmessages THEN     EXPORT STREAM filelist "5-XML from SUBatt-ucU.r".               /* 1dot1 */
                               
                        IF o-success = NO THEN 
                            EXPORT STREAM filelist DELIMITER ";"
                                filecount full-successful-XML-filepath "--" "Error 7: SS File Attachment Failed.".
        
                            ASSIGN
                                c-nametable = c-nametable + 1.
    
                    END. /* File attachment */
                    
/*                END. /* The file is not a loner */*/
                
            END. /*** the file is a txt ***/
 
        END. /*** of fileattr = F ***/

    END. /*** Else, because there is a file here ***/

END.  /** of 4ea. nametable --- cleanup **/

EXPORT STREAM filelist DELIMITER ";" "Processed: " c-nametable " valid files and " invalidFiles "invalid files.".   /* 1dot1 */

EXPORT STREAM filelist DELIMITER ";"
    "******************* END OF LOG *******************".

OUTPUT STREAM filelist CLOSE. /* file list */

PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */ 
PUT UNFORMATTED  "Processed   " c-nametable " :valid files and " invalidFiles " :invalid files.".      /* 1dot1 */
PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */ 

PROPATH = ORIGPROPATH.                                                              /* 1dot3 */

/********************************   END OF LINE   *******************************/
