
/*------------------------------------------------------------------------

    File        : KYGImporter.p
    Purpose     : 

    Description : 

    Author(s)   : Andrew Garver
    Created     : Mon Dec 5 11:38:36 EDT 2017
    Updated     : Mon Dec 5 11:38:36 EDT 2017
    Version     : 1.0
    Notes       :
           
    Revision History:
    -----------------
    1.1 - written by Harold Luttrell, Sr. on 13/Sept/17. 
          Added code to get the disk drive letter,
          store off the original propath variables, 
          based on the drive letter add the paths projects for the 
          DataHub, depot and KYG in front of the original propath.
          At the end of the program, reset the propath back to the original.
          Marked by /* 1dot1 */.
    1.2 - written by Harold Luttrell, Sr. on 14/Sept/17.
          Moved the Inbound_EDI_Files folder from the 
          C:\APPS\KYG\src\Inbound_EDI_Files\     folder to the
          C:\APPS\KYG\Inbound_EDI_Files\ folder for ease of placement of 
          the input data files.
          Marked by /* 1dot2 */
        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE ITmessages AS LOGICAL INITIAL YES    NO-UNDO.
DEFINE VARIABLE kyg-log-path AS CHARACTER INITIAL "C:\apps\WRK\KYGImporter-Log.txt" NO-UNDO.
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.       /* 1dot1 */                

DEFINE VARIABLE hold-propath AS CHARACTER NO-UNDO.                      /* 1dot1 */                           
DEFINE VARIABLE propath-len AS INTEGER NO-UNDO.                         /* 1dot1 */
ASSIGN  drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1)        /* 1dot1 */
        propath-len  = LENGTH(PROPATH)                                  /* 1dot1 */
        hold-propath = PROPATH.                                         /* 1dot1 */                                                 

IF drive_letter = "P" THEN DO:                                          /* 1dot1 */
    PROPATH =   "P:\OpenEdge\WRK\DataHub\rcode\," +                     /* 1dot1 */                             
                "P:\OpenEdge\WRK\DataHub\src\WebSpeed\," +              /* 1dot1 */ 
                "P:\OpenEdge\WRK\depot\rcode\," +                       /* 1dot1 */                           
                "P:\OpenEdge\WRK\depot\src\WebSpeed\," +                /* 1dot1 */                       
                "P:\OpenEdge\WRK\KYG\rcode\," +                         /* 1dot1 */
                "P:\OpenEdge\WRK\KYG\src\WebSpeed\," +                  /* 1dot1 */
                "P:\OpenEdge\WRK\LABS\rcode\," +                        /* 1dot1 */
                "P:\OpenEdge\WRK\LABS\src\WebSpeed\," +                 /* 1dot1 */  
                "P:\OpenEdge\WRK\TK\rcode\," +                          /* 1dot1 */
                "P:\OpenEdge\WRK\TK\src\WebSpeed\," +                   /* 1dot1 */                                     
                SUBSTRING(PROPATH, 3, propath-len).                     /* 1dot1 */                                                    
END.                                                                    /* 1dot1 */
 
ELSE IF drive_letter = "C" THEN DO:                                     /* 1dot1 */                                            
    PROPATH =   "C:\OpenEdge\workspace\DataHub\rcode\," +               /* 1dot1 */                      
                "C:\OpenEdge\workspace\DataHub\src\WebSpeed\," +        /* 1dot1 */                            
                "C:\OpenEdge\workspace\depot\rcode\," +                 /* 1dot1 */                     
                "C:\OpenEdge\workspace\depot\src\WebSpeed\," +          /* 1dot1 */                 
                "C:\OpenEdge\workspace\KYG\rcode\," +                   /* 1dot1 */
                "C:\OpenEdge\workspace\KYG\src\WebSpeed\," +            /* 1dot1 */
                "C:\OpenEdge\workspace\LABS\rcode\," +                  /* 1dot1 */
                "C:\OpenEdge\workspace\LABS\src\WebSpeed\," +           /* 1dot1 */  
                "C:\OpenEdge\workspace\TK\rcode\," +                    /* 1dot1 */
                "C:\OpenEdge\workspace\TK\src\WebSpeed\," +             /* 1dot1 */                            
                SUBSTRING(PROPATH, 3, propath-len).                     /* 1dot1 */                                                        
END.                                                                    /* 1dot1 */

DEFINE STREAM filelist.

OUTPUT STREAM filelist TO kyg-log-path APPEND.

IF  ITmessages THEN DO:                                                 /* 1dot1 */ 
    PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */   
    PUT UNFORMATTED  "PROPATH =" PROPATH  SKIP. /* displays the PROPATH values in the batch C:\Progress\WRK\KYG_log.txt file. */ /* 1dot1 */
    PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */
END.                                                                    /* 1dot1 */

PAUSE 0 BEFORE-HIDE.

DEFINE VARIABLE MyDirName AS CHARACTER INITIAL "C:\apps\CSVConversion\ConvertedXMLs\" FORMAT "x(60)" NO-UNDO. /** name of the Directory to Walk **/ /* 1dot2 */

DEFINE TEMP-TABLE NameTable 
    FIELD filecount AS INTEGER 
    FIELD afile     AS CHARACTER FORMAT "x(60)"
    FIELD fullfile  AS CHARACTER FORMAT "x(255)"
    FIELD fileattr  AS CHARACTER
        INDEX NT-main-idx AS PRIMARY UNIQUE filecount 
        INDEX NT-word-idx AS WORD-INDEX fullfile. 

DEFINE VARIABLE ss-xml-file-id  AS INTEGER   NO-UNDO.
DEFINE VARIABLE kyg-xml-file-id  AS INTEGER   NO-UNDO.
DEFINE VARIABLE XML-file-id      AS INTEGER   NO-UNDO.

DEFINE VARIABLE corrupted-xml-dir   AS CHARACTER INITIAL "C:\apps\CSVConversion\CorruptSSXMLs\" NO-UNDO.
DEFINE VARIABLE kyg-source-file-dir AS CHARACTER INITIAL "C:\apps\CSVConversion\CSVInput\" NO-UNDO.
DEFINE VARIABLE kyg-corrupt-file-dir AS CHARACTER INITIAL "C:\apps\CSVConversion\CorruptCSVFiles\" NO-UNDO.
DEFINE VARIABLE kyg-processed-file-dir AS CHARACTER INITIAL "C:\apps\CSVConversion\ProcessedCSVs\" NO-UNDO.
DEFINE VARIABLE xml-source-file-dir AS CHARACTER INITIAL "C:\apps\CSVConversion\ConvertedXMLs\" NO-UNDO.
DEFINE VARIABLE processed-xml-dir AS CHARACTER INITIAL "C:\apps\CSVConversion\ProcessedSSXMLs\" NO-UNDO.

DEFINE VARIABLE full-ss-xml-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-corrupted-xml-filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE full-processed-xml-filepath AS CHARACTER NO-UNDO.

DEFINE VARIABLE reccount    AS INTEGER INITIAL 1 NO-UNDO.
DEFINE VARIABLE iteration   AS INTEGER NO-UNDO.

DEFINE VARIABLE invalidFiles AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE updatemode  AS LOGICAL LABEL "Run Program in Update Mode?" INITIAL YES NO-UNDO.

DEFINE VARIABLE runthis     AS CHARACTER NO-UNDO.
DEFINE VARIABLE stripped-filename       AS CHARACTER NO-UNDO.
DEFINE VARIABLE timestamped-filename    AS CHARACTER NO-UNDO.

DEFINE VARIABLE o-fail      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-success   AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-create    AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-update    AS LOGICAL NO-UNDO.

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

/* Convert all KYG files into XML files */
ASSIGN 
    runthis = "C:\apps\CSVConversion\Convert-KYG-to-XML.bat " + kyg-source-file-dir  + " " + xml-source-file-dir + " " + kyg-processed-file-dir + " " + kyg-corrupt-file-dir + " " + kyg-log-path.
    
OS-COMMAND SILENT VALUE(runthis).

/* Process XML files */
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

            IF (R-INDEX(afile,".") > 0 AND SUBSTRING(afile, (R-INDEX(afile,".") + 1)) = "xml") THEN DO:
                
                IF  ITmessages THEN     EXPORT STREAM filelist "1-going    to getStringTimeMilliseconds.r".       /* 1dot1 */
                
                RUN VALUE(SEARCH("getStringTimeMilliseconds.r")) (
                    OUTPUT systime
                    ).
                    
                IF  ITmessages THEN     EXPORT STREAM filelist "1-return from getStringTimeMilliseconds.r".       /* 1dot1 */
                
                ASSIGN
                    stripped-filename    = SUBSTRING(afile,1,INDEX(afile,".xml") - 1)
                    timestamped-filename = stripped-filename + "-" + systime
                    full-processed-xml-filepath = processed-xml-dir + timestamped-filename + ".xml"
                    full-ss-xml-filepath      = xml-source-file-dir + afile
                    full-corrupted-xml-filepath    = corrupted-xml-dir + timestamped-filename + ".xml"
                    runthis                     = "C:\apps\CSVConversion\Convert-KYG-XML-to-SS-XML.bat " + full-ss-xml-filepath  + " " + full-processed-xml-filepath + " " + full-corrupted-xml-filepath
                    .
    
                /* *** XML Conversion *** */
                IF updatemode = YES THEN
                DO:
                
                /* *** UTM_pipeline.jar *** */    
                    OS-COMMAND SILENT VALUE(runthis).

                /* *** eXorcisM_Load.p *** */
                    IF  ITmessages THEN     EXPORT STREAM filelist "2-going  to eXorcisM_Load.r".               /* 1dot1 */
                    
                    RUN VALUE(SEARCH("eXorcisM_Load.r")) (
                        processed-xml-dir,
                        timestamped-filename + ".xml",
                        OUTPUT XML-file-id,
                        OUTPUT o-fail
                        ).
                        
                    IF  ITmessages THEN     EXPORT STREAM filelist "2-return from eXorcisM_Load.r".             /* 1dot1 */
                    
                    IF o-fail = YES THEN DO:
                        EXPORT STREAM filelist DELIMITER ";"
                            filecount full-corrupted-xml-filepath "--" "Error 2: eXorcisM_Load Failed.".
                        ASSIGN invalidFiles = invalidFiles + 1.
                        IF SEARCH(full-corrupted-xml-filepath) = ? THEN
                            OS-RENAME VALUE(full-ss-xml-filepath) VALUE(full-corrupted-xml-filepath).
                    END.
                END.  /* *** XML Conversion *** */
            
            /* *** OS-RENAME *** */
                IF o-fail = NO AND updatemode = YES THEN DO:
                    IF SEARCH(full-processed-xml-filepath) <> ? OR SEARCH(full-corrupted-xml-filepath) <> ? THEN
                        OS-DELETE VALUE(full-ss-xml-filepath).
                    ELSE DO:
                        EXPORT STREAM filelist DELIMITER ";" 
                            filecount full-ss-xml-filepath "--" "Error 3: the processed file was not copied to its appropriate folder.".
                            o-fail = YES.
                    END.
                END. /*** of OS-RENAME ***/
            
            /* *** File attachment *** */
                IF o-fail = NO AND updatemode = YES THEN 
                DO:                         

                    IF  ITmessages THEN     EXPORT STREAM filelist "3-KYG-XML  to SUBatt-ucU.r".                /* 1dot1 */
                                          
                    /* Save KYG-XML File */
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
                        xml-source-file-dir,
                        timestamped-filename + ".xml",
                        "",
                        "",
                        "",
    
                        OUTPUT kyg-xml-file-id,
                        OUTPUT o-create,
                        OUTPUT o-update,
                        OUTPUT o-success
                        ).

                    IF  ITmessages THEN     EXPORT STREAM filelist "3-KYG-XML from SUBatt-ucU.r".               /* 1dot1 */
                                                
                    IF o-success = NO THEN 
                        EXPORT STREAM filelist DELIMITER ";"
                            filecount xml-source-file-dir + timestamped-filename + ".txt " + "--" "Error 5: EDI File Attachment Failed.".                          

                    IF  ITmessages THEN     EXPORT STREAM filelist "4-SS-XML  to SUBatt-ucU.r".                /* 1dot1 */
                            
                    /* Save SS-XML File */                                          
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
                        processed-xml-dir,
                        timestamped-filename + ".xml",
                        "",
                        "",
                        "",
    
                        OUTPUT ss-xml-file-id,
                        OUTPUT o-create,
                        OUTPUT o-update,
                        OUTPUT o-success
                        ).

                    IF  ITmessages THEN     EXPORT STREAM filelist "4-SS-XML from SUBatt-ucU.r".               /* 1dot1 */
                                                
                    IF o-success = NO THEN 
                        EXPORT STREAM filelist DELIMITER ";"
                            filecount processed-xml-dir + timestamped-filename + ".xml " + "--" "Error 6: XML File Attachment Failed.".

                END. /* File attachment */
                
            END. /*** the file is a txt ***/
 
        END. /*** of fileattr = F ***/

    END. /*** Else, because there is a file here ***/

END.  /** of 4ea. nametable --- cleanup **/

/*EXPORT STREAM filelist DELIMITER ";" "Processed: " c-nametable " valid files and " invalidFiles "invalid files.".   /* 1dot1 */*/

EXPORT STREAM filelist DELIMITER ";"
    "******************* END OF LOG *******************".

OUTPUT STREAM filelist CLOSE. /* file list */

PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */ 
/*PUT UNFORMATTED  "Processed   " c-nametable " :valid files and " invalidFiles " :invalid files.".      /* 1dot1 */*/
PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */ 

ASSIGN PROPATH = hold-propath.                                                                  /* 1dot1 */

/********************************   END OF LINE   *******************************/
