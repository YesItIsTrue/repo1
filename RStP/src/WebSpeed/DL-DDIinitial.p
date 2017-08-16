 /*------------------------------------------------------------------------
    File        : DL-DDIinitial.p
    Purpose     : To find all the files in the directory and to assign the various fields 
                    equal to the various pieces of data in the text file or fullpath.
    Description : This is the initial program for loading files in from the DDI directory 
                    on HHI's server. 
    Author(s)   : Trae Luttrell
    Created     : Tue Oct 06 15:16:05 EDT 2015
    Updated     : Tue Jan 27 10:43:21 EDT 2016
    Version     : 3.0
    Notes       : Originally copied from the DireAttachedWalk.p.
  ----------------------------------------------------------------------*/


/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW. 

DEFINE VARIABLE MyDirName AS CHARACTER FORMAT "x(65)" NO-UNDO.

DEFINE VARIABLE v-ITmessages AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE showcounters AS LOGICAL INITIAL NO NO-UNDO.

DEFINE VARIABLE v-fullname AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-pat-firstname LIKE people_mstr.people_firstname NO-UNDO.
DEFINE VARIABLE v-pat-lastname LIKE people_mstr.people_lastname NO-UNDO.

DEFINE VARIABLE v-nbetween AS CHARACTER  NO-UNDO.  /* a char holder for SUBSTRING action. */
DEFINE VARIABLE v-folderchecker AS CHARACTER  NO-UNDO. /* a char holder for determining if the txt file is in a name folder. */

DEFINE TEMP-TABLE NameTable   /* freshtest */ 
    FIELD tt-fileid AS INTEGER 
    FIELD tt-afile AS CHARACTER FORMAT "x(20)"
    FIELD tt-fullfile AS CHARACTER FORMAT "x(40)"
    FIELD tt-fileattr AS CHARACTER
    FIELD tt-TXTvsPDF AS CHARACTER 
    FIELD tt-createdate AS DATE 
    FIELD tt-pat-firstname LIKE people_mstr.people_firstname
    FIELD tt-pat-lastname LIKE people_mstr.people_lastname
    FIELD tt-test_type LIKE TK_mstr.TK_test_type     
        INDEX NT-main-idx AS PRIMARY UNIQUE tt-fileid 
        INDEX NT-word-idx AS WORD-INDEX tt-fullfile. 
        
DEFINE VARIABLE reccount    AS INTEGER INITIAL 1 NO-UNDO.
DEFINE VARIABLE iteration   AS INTEGER NO-UNDO.
DEFINE VARIABLE c-total     AS INTEGER NO-UNDO. /* name table counter */
DEFINE VARIABLE c-txtfile   AS INTEGER NO-UNDO.   /* text file counter */
DEFINE VARIABLE c-pdffile   AS INTEGER NO-UNDO.   /* pdf file counter */
DEFINE VARIABLE c-other     AS INTEGER NO-UNDO.
DEFINE VARIABLE txt%        AS DECIMAL NO-UNDO.
DEFINE VARIABLE pdf%        AS DECIMAL NO-UNDO.
DEFINE VARIABLE other%      AS DECIMAL NO-UNDO.

DEFINE VARIABLE updatemode AS LOGICAL LABEL "Run Program in Update Mode?" INITIAL NO NO-UNDO.

DEFINE VARIABLE OnTheServer AS LOGICAL LABEL "Are You On The Server?" NO-UNDO.
 
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE pinwheel AS CHARACTER FORMAT "x" EXTENT 4 NO-UNDO.
ASSIGN 
    pinwheel[1] = "|"
    pinwheel[2] = "/ " 
    pinwheel[3] = "-"
    pinwheel[4] = "\".  

FORM SKIP(1)
    c-total COLON 20 LABEL "Total Files"
    SKIP (1)
    c-txtfile COLON 20 LABEL "Text Files" txt% COLON 55 LABEL "Text Percentage"
    c-pdffile COLON 20 LABEL "PDF Files" pdf% COLON 55 LABEL "PDF Percentage"
    c-other COLON 20 LABEL "Other Files" other% COLON 55 LABEL "Other Percentage"
    SKIP (1)
    WITH FRAME counter_report WIDTH 80 SIDE-LABELS TITLE "Files Touched".
 
/* ***********  Other Output and External Proc Definitions  ********** */
DEFINE STREAM walkreport.
DEFINE VARIABLE v-filelocation  AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE walklocation AS CHARACTER INITIAL "C:\PROGRESS\WRK\DL-DDI-Walk-Report.txt" NO-UNDO.
DEFINE VARIABLE walk-result AS INTEGER NO-UNDO. /*** 0 = didn't run, # = the # of the error, 99 = successfully ran. ***/
OUTPUT STREAM walkreport TO VALUE(walklocation).
EXPORT STREAM walkreport DELIMITER ";" "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM walkreport DELIMITER ";" /* These are column headers. */
    "Source Text File"
    "PDF vs TXT"
    "Last Name"
    "First Name"
    "PDF Last Name"
    "PDF First Name" 
    "Test Kit ID"
    "Test Kit Seq"
    "Test Type"   
    "DOB"
    "Lab Sample ID"                                                 
    "Lab Seq"
    "Creation Date"
    "Error Category"
    "Error Number"
    "Error Message".
OUTPUT STREAM walkreport CLOSE. 

DEFINE STREAM filelist.
OUTPUT STREAM filelist TO "C:\PROGRESS\WRK\DDIinitialWalk.txt".
EXPORT STREAM filelist DELIMITER ";" "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM filelist DELIMITER ";" 
    "File_ID" 
    "File_Name" 
    "Full_Path" 
    "File_Attr" 
    "Txt vs PDF"
    "Create Date"
    "Patient First Name" 
    "Patient Last Name" 
    "Test Type".
    
/*** Outputs for Harold's SUB-Unstring-Name.p ***/
 
DEFINE VARIABLE o-prefix            AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-firstname         AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-middlename        AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-lastname          AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-suffix            AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-title_desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-prefname          AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-gender            AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-unstring-error    AS LOGICAL NO-UNDO.        /*  YES = errors / NO = no errors. */
DEFINE VARIABLE o-field-in-error    AS     CHARACTER NO-UNDO.      /*  Field input name in error, if any. */

/* *****************  Internal Procedure NameWalk  ******************** */
PROCEDURE namewalk:
            
    DEFINE INPUT PARAMETER dirname AS CHARACTER FORMAT "x(50)" NO-UNDO.

    ASSIGN 
        iteration = iteration + 1.
                                                                                                         
    INPUT FROM OS-DIR(dirname).
           
        REPEAT: /*** repeats for objects found - folders and files ***/
           
            CREATE NameTable. 

            ASSIGN 
                reccount    = reccount + 1
                tt-fileid      = reccount. 
            
            IMPORT tt-afile tt-fullfile tt-fileattr.            
                                                               
            IF tt-afile = "" OR tt-afile = "." OR tt-afile = ".." OR tt-fileid = 0 THEN
                    
                DELETE NameTable.

            ELSE IF tt-fileattr = "D" AND tt-fileid > 2 AND NOT tt-afile BEGINS "."  THEN DO:
              
                RUN namewalk(tt-fullfile).
            
            END. 
                
        END.  /** of repeat - file list **/
        
    INPUT CLOSE.   
                                                                                      
END. /************************ of namewalk *******************************/

/* ***************************  Main Block  *************************** */

UPDATE SKIP (8) OnTheServer SKIP (8) WITH FRAME maine2 WIDTH 80 SIDE-LABELS .

IF OnTheServer = YES THEN 
    ASSIGN MyDirName = "C:\DATA\HHI\DDI\A\Aarav Kumar".  /** server **/

ELSE 
    ASSIGN MyDirName = "C:\APPS\BioMed\HHI\DDI\K\Katherine Logue".  /** Trae's Box **/

UPDATE SKIP (8) MyDirName COLON 10 SKIP (8) WITH FRAME maine TITLE "Insert Directory Name (Full Path)" WIDTH 80 SIDE-LABELS .
                                                                                               
RUN namewalk(MyDirName).   /** name of the directory that you are searching ***/
    
PAUSE 0 BEFORE-HIDE.

/*MESSAGE "Done with the Directory Walk, proceeding with the Attach Walk. :]".*/

UPDATE SKIP (8) updatemode SKIP (8) WITH SIDE-LABELS FRAME firstmenu WIDTH 80 TITLE "Program Mode:".
  
FOR EACH nametable:     /*** cleanup records ***/ 
    
    /**** blanks out all variables not used for counting ***/
    ASSIGN 
        v-fullname = ""
        v-pat-firstname = ""
        v-pat-lastname = ""
        v-nbetween = ""
        v-folderchecker = ""
        o-prefix = ""
        o-firstname = ""
        o-middlename = ""
        o-lastname = ""
        o-suffix = ""
        o-title_desc = ""
        o-prefname = ""
        o-gender = ?
        o-unstring-error = ?
        o-field-in-error = "".
       
    IF (tt-afile = "" AND tt-fullfile = "" AND tt-fileattr = "") 
        OR tt-afile = "Thumbs.db" 
        OR tt-fileattr = "D" THEN 
            DELETE nametable.
        
    ELSE DO:
            
        ASSIGN c-total = c-total + 1. 
        
/*        DISPLAY c-total WITH FRAME counter_report.*/
            
        IF tt-fileattr = "F" THEN DO: 

            IF (R-INDEX(tt-afile,".") > 0 AND SUBSTRING(tt-afile, (R-INDEX(tt-afile,".") + 1)) = "txt") THEN DO:              
                
                ASSIGN tt-TXTvsPDF = "txt".
                
                IF OnTheServer = YES THEN ASSIGN v-folderchecker = SUBSTRING(tt-fullfile,16).
                ELSE ASSIGN v-folderchecker = SUBSTRING(tt-fullfile,23).      /**  This checks if it is in one of the folders that is only one character long  **/
                
                IF INDEX(v-folderchecker,"\",2) = 3 THEN DO:
                    
                    IF OnTheServer = YES THEN ASSIGN v-nbetween = SUBSTRING(tt-fullfile,19).
                    ELSE ASSIGN v-nbetween = SUBSTRING(tt-fullfile,26).
                
                    ASSIGN v-fullname = SUBSTRING(v-nbetween,1,(INDEX(v-nbetween,"\") - 1)).
                    
                    /* Message 
                        "First Time!" SKIP
                        "Search Result = " SEARCH("SUB-UnString-Name.p") SKIP
                        "v-fullname = " v-fullname SKIP
                        "nametable.tt-pat-firstname = " nametable.tt-pat-firstname  SKIP
                         "o-prefix = " o-prefix SKIP 
                         "o-middlename = " o-middlename SKIP
                         "nametable.tt-pat-lastname = " nametable.tt-pat-lastname SKIP 
                         "o-suffix = " o-suffix SKIP
                         "o-title_desc = " o-title_desc SKIP
                         "o-prefname = " o-prefname SKIP
                         "o-gender = " o-gender SKIP
                         "o-unstring-error = " o-unstring-error SKIP          
                         "o-field-in-error = " o-field-in-error SKIP
                        View-As Alert-Box Buttons OK.  */
                      
                    RUN VALUE(SEARCH("SUB-UnString-Name.r")) 
                        (v-fullname,
                         v-ITmessages,                     /* logical NO or YES. A YES displays debug messages. */
                         OUTPUT o-prefix,
                         OUTPUT nametable.tt-pat-firstname,
                         OUTPUT o-middlename,
                         OUTPUT nametable.tt-pat-lastname,
                         OUTPUT o-suffix, 
                         OUTPUT o-title_desc,
                         OUTPUT o-prefname,
                         OUTPUT o-gender,
                         OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
                         OUTPUT o-field-in-error).
                    
                    /* Message 
                        "Second Time..." SKIP
                        "Search Result = " SEARCH("SUB-UnString-Name.p") SKIP
                        "v-fullname = " v-fullname SKIP
                        "nametable.tt-pat-firstname = " nametable.tt-pat-firstname  SKIP
                         "o-prefix = " o-prefix SKIP 
                         "o-middlename = " o-middlename SKIP
                         "nametable.tt-pat-lastname = " nametable.tt-pat-lastname SKIP 
                         "o-suffix = " o-suffix SKIP 
                         "o-title_desc = " o-title_desc SKIP
                         "o-prefname = " o-prefname SKIP
                         "o-gender = " o-gender SKIP
                         "o-unstring-error = " o-unstring-error SKIP          
                         "o-field-in-error = " o-field-in-error SKIP
                        View-As Alert-Box Buttons OK. */
                     
                END. /** of the "I'm in a dir that is a single letter" path. **/    
   
                FOR EACH test_mstr WHERE 
                    INDEX (nametable.tt-afile, test_mstr.test_type) > 0 AND
                    test_mstr.test_deleted = ? NO-LOCK:
    
                    ASSIGN nametable.tt-test_type = test_mstr.test_type.
            
                END. /*** test_mstr 4ea ***/

                FILE-INFO:FILE-NAME = tt-fullfile.
                
                ASSIGN nametable.tt-createdate = FILE-INFO:FILE-MOD-DATE . /** the create date was younger than the Mod date, consistantly, some sort of windows bug from it gettting coppied all over the place most likely. ***/
     
                RUN VALUE(SEARCH("DL-DDItxtwalk.p")) 
                    (nametable.tt-afile,
                    nametable.tt-fullfile,
                    nametable.tt-pat-lastname,
                    nametable.tt-pat-firstname,
                    nametable.tt-test_type, 
                    nametable.tt-createdate,
                    nametable.tt-txtvspdf,
                    walklocation,
                    updatemode,
                    OUTPUT walk-result) NO-ERROR.
     
                ASSIGN 
                    c-txtfile = c-txtfile + 1
                    txt% = (c-txtfile / c-total) * 100. 
                    
/*                DISPLAY c-txtfile txt% WITH FRAME counter_report.*/
                
            END. /*** the file is a txt ***/ 
        
            ELSE IF (R-INDEX(tt-afile,".") > 0 AND SUBSTRING(tt-afile, (R-INDEX(tt-afile,".") + 1)) = "pdf") THEN DO:
               
                ASSIGN tt-TXTvsPDF = "PDF".
               
                IF OnTheServer = YES THEN ASSIGN v-folderchecker = SUBSTRING(tt-fullfile,16).
                
                ELSE ASSIGN v-folderchecker = SUBSTRING(tt-fullfile,23).

                IF INDEX(v-folderchecker,"\",2) = 3 THEN DO:

                IF OnTheServer = YES THEN ASSIGN v-nbetween = SUBSTRING(tt-fullfile,19).
                
                ELSE  ASSIGN v-nbetween = SUBSTRING(tt-fullfile,26).

                    ASSIGN v-fullname = SUBSTRING(v-nbetween,1,(INDEX(v-nbetween,"\") - 1)).
                    
                    RUN VALUE(SEARCH("SUB-UnString-Name.r")) 
                        (v-fullname,
                         v-ITmessages,             /* logical NO or YES. A YES displays the results at the end of this program. */
                         OUTPUT o-prefix,
                         OUTPUT nametable.tt-pat-firstname,
                         OUTPUT o-middlename,
                         OUTPUT nametable.tt-pat-lastname,
                         OUTPUT o-suffix, 
                         OUTPUT o-title_desc,
                         OUTPUT o-prefname,
                         OUTPUT o-gender,
                         OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
                         OUTPUT o-field-in-error).
                   
                    FOR EACH test_mstr WHERE 
                        INDEX (nametable.tt-afile, test_mstr.test_type) > 0 AND
                        test_mstr.test_deleted = ? NO-LOCK
                            BREAK BY test_mstr.test_type DESCENDING:
        
                        ASSIGN nametable.tt-test_type = test_mstr.test_type.
                
                    END. /*** test_mstr 4ea ***/
                    
                    IF nametable.tt-test_type = "UTM UEE" THEN ASSIGN nametable.tt-test_type = "UTEE".
                    ELSE IF nametable.tt-test_type = "UTM-UEE" THEN nametable.tt-test_type = "UTEE".
                    ELSE IF nametable.tt-test_type = "UTM / UEE" THEN nametable.tt-test_type = "UTEE". 
                     
                END. /** of the "I'm in a dir that is a single letter" path. **/
               
                FILE-INFO:FILE-NAME = tt-fullfile.
                
                ASSIGN nametable.tt-createdate = FILE-INFO:FILE-MOD-DATE .
                
                RUN VALUE(SEARCH("DL-DDIpdfwalk.p")) 
                    (nametable.tt-afile,
                    nametable.tt-fullfile,
                    nametable.tt-pat-lastname,
                    nametable.tt-pat-firstname,
                    nametable.tt-test_type, 
                    nametable.tt-createdate,
                    nametable.tt-txtvspdf,
                    walklocation,
                    updatemode,
                    OUTPUT walk-result) NO-ERROR.
               
                ASSIGN 
                    c-pdffile = c-pdffile + 1
                    pdf% = (c-pdffile / c-total) * 100. 
                    
/*                DISPLAY c-pdffile pdf% WITH FRAME counter_report.*/
                
            END. /*** the file is a pdf ***/ 
            
            ELSE DO:
                
                ASSIGN 
                    c-other = c-other + 1
                    other% = (c-other / c-total) * 100. 
                    
/*                DISPLAY c-other other% WITH FRAME counter_report.*/
                
                OUTPUT STREAM walkreport TO VALUE(walklocation) APPEND.
                
                EXPORT STREAM walkreport DELIMITER ";"
                    nametable.tt-fullfile 
                    ?
                    nametable.tt-pat-firstname
                    nametable.tt-pat-lastname
                    "" 
                    ""
                    ""
                    "" 
                    ""
                    ""
                    "" 
                    ""
                    ""
                    "Error"
                    1000
                    "File not a .pdf or .txt".
                
                /**** add and error here for the nonPDF and nonTXT files ****/
                
                OUTPUT STREAM walkreport CLOSE.
                
            END. /** of the other file part ***/ 
            
            IF c-total MODULO 100 = 0 THEN DO:
                i = i + 1.
                IF i >= 5 THEN
                    i = 1.
                DISPLAY "Processing . . . " pinwheel[i]
                WITH FRAME outstat WIDTH 80 NO-LABELS OVERLAY.
                
                ASSIGN 
                    txt% = (c-txtfile / c-total) * 100
                    pdf% = (c-pdffile / c-total) * 100
                    other% = (c-other / c-total) * 100. 
                    
                DISPLAY c-txtfile c-pdffile c-other txt% pdf% other% WITH FRAME counter_report.
                
            END. /*** of c-nametable MODULO ***/
            
        END. /*** of fileattr = F ***/
    
        EXPORT STREAM filelist DELIMITER ";" nametable.
         
    END. /*** Else, because there is a file here ***/ 
                
END.  /** of 4ea. nametable --- cleanup **/

OUTPUT STREAM filelist CLOSE. /* file list */

ASSIGN 
    txt% = (c-txtfile / c-total) * 100
    pdf% = (c-pdffile / c-total) * 100
    other% = (c-other / c-total) * 100. 
    
DISPLAY c-txtfile c-pdffile c-other txt% pdf% other% WITH FRAME counter_report.

MESSAGE c-total " files were found." VIEW-AS ALERT-BOX BUTTONS OK.
/*MESSAGE c-pdffile "text files were found." VIEW-AS ALERT-BOX BUTTONS OK.*/
/*MESSAGE c-txtfile "text files were found." VIEW-AS ALERT-BOX BUTTONS OK.*/

IF v-ITmessages = YES THEN DO:
    
    FOR EACH NameTable NO-LOCK:
         
/*        DISPLAY NameTable                       */
/*            WITH WIDTH 132 TITLE "Final Output".*/
        
    END.  /** of 4ea. NameTable --- Display **/
    
END.  /** of if itmessage = YES **/

/********************************   END OF LINE   *******************************/
