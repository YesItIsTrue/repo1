/*------------------------------------------------------------------------
    File        : ATT-attchwalk-R.p
    Purpose     : To "walk" through all the attached files folders and check to see if each file 
                is attached to the correct patient and test kit.

    Description : All this is supposed to do is load in the data from an ATT_file, raw, unsorted 
                and unformatted.

    Author(s)   : Trae Luttrell
    Created     : Thu Jun 11 10:52:07 EDT 2015
    Updated     : Wed Jun 17 12:27:00 EDT 2015
    Version     : 1.0
    Notes       : v.1.0 - This imports one txt file of a "HE" test and puts it into a temp table, 
                stoping once it finds a field that says "interpretation text".
                
                Tests Covered -
                    No help needed -------- UTEE, FM, CPR, UTM/UEE, 
                    Interpretation text --- HE, UAA,
                    Research Only --------- MPA, MD, MI
                    
                Next Steps:
                    
                    > Create the verification (step/file) where the information pulled from the 
                    attached file is then checked agaisnt the database to verify that the file 
                    is actually attached to the correct patient. 
                    
                    * It would be nice to know which patient the file was attached too, and which one 
                    the data in the file said it SHOULD be attached too. 
                    
                    > Make some sort of umbrella or calling program that runs the Dire Walk, takes
                    each .txt file from that and runs the Attach Walk on it, and does the verification
                    step as well to see if it attached to the correct patient.
                    
    ------------------------------------------------------------------------------------------------------------
    Revision History:
    -----------------
    1.0 - written by TRAE LUTTRELL on 11/Jun/15.  Original version.
    1.1 - written by DOUG LUTTRELL on 11/Aug/17.  Changed to work with the new CMC structure (Version 12).
            Not checked for logic.  Marked by 1dot1.
                                
                    
  ----------------------------------------------------------------------*/
  
/* ***************************  Definitions  ************************** */ 

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/** this Temp table "catches" each LINE of the txt file **/
DEFINE TEMP-TABLE ATTcatcher
    FIELD slot1 AS CHARACTER FORMAT "x(40)"
    FIELD slot2 AS CHARACTER FORMAT "x(40)"
    FIELD slot3 AS CHARACTER 
    FIELD slot4 AS CHARACTER
    FIELD slot5 AS CHARACTER
    FIELD slot6 AS CHARACTER
    FIELD slot7 AS CHARACTER
    FIELD slot8 AS CHARACTER
    FIELD slot9 AS CHARACTER
    FIELD slot10 AS CHARACTER
    FIELD lab-seq AS CHARACTER
        INDEX main-att AS PRIMARY slot1 lab-seq.

/*DEFINE VARIABLE v-filelocation  AS CHARACTER FORMAT "x(60)" NO-UNDO.*/
DEFINE VARIABLE v-testkitID     AS CHARACTER FORMAT "x(12)" NO-UNDO.
DEFINE VARIABLE v-DOB-progress  LIKE people_mstr.people_DOB NO-UNDO.
DEFINE VARIABLE v-lab-sampleID  LIKE TK_mstr.TK_lab_sample_ID NO-UNDO.
DEFINE VARIABLE v-lab-seq       LIKE TK_mstr.TK_lab_seq INITIAL 0 NO-UNDO.
DEFINE VARIABLE v-testtype      LIKE TK_mstr.TK_test_type NO-UNDO.  /*** never used to find anything ***/       /* 1dot1 */
DEFINE VARIABLE c-TK-mstr       AS INTEGER NO-UNDO. /** counter for the TK_mstr ****/
DEFINE VARIABLE c-import        AS INTEGER NO-UNDO. /** counter for the imports ****/
DEFINE VARIABLE v-attpeopleID   LIKE att_files.att_value5 NO-UNDO.
DEFINE VARIABLE c-78            AS INTEGER NO-UNDO. /** counter for the error 7 & 8 fix **/
DEFINE VARIABLE v-attIDint      AS INTEGER NO-UNDO.  
DEFINE VARIABLE v-fullIDint     AS INTEGER NO-UNDO.
DEFINE VARIABLE v-fullpath-ID   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-testtypeholder AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-charholder    AS CHARACTER NO-UNDO. /*** character holder for clean substrings ***/
DEFINE VARIABLE v-nameholder    AS CHARACTER NO-UNDO. /*** name holder for no cross-contamination ***/
DEFINE VARIABLE v-peopholder    AS CHARACTER NO-UNDO. /*** people holder, once again to have strings be happy ***/
DEFINE VARIABLE v-pdf-fl AS CHARACTER FORMAT "x(90)" NO-UNDO.
DEFINE VARIABLE bigchar AS CHARACTER FORMAT "x(90)" NO-UNDO.
DEFINE VARIABLE v-tk_patient_id LIKE TK_mstr.TK_patient_ID NO-UNDO.    
DEFINE VARIABLE v-last-lab-seq AS INTEGER NO-UNDO. /** 1|2|3 **/
DEFINE VARIABLE v-test_seq LIKE TK_mstr.TK_test_seq NO-UNDO.
DEFINE VARIABLE v-test_family LIKE test_mstr.test_family NO-UNDO.

/*DEFINE VARIABLE c-verification  AS INTEGER INITIAL 0 NO-UNDO. /** counter for the verification ***/*/

/*** Everytimers ***/
DEFINE VARIABLE x AS INTEGER NO-UNDO.
/* DEFINE VARIABLE y AS INTEGER NO-UNDO. */
DEFINE VARIABLE z AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ITmessages AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-ITmessages2 AS LOGICAL INITIAL NO NO-UNDO.

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
DEFINE VARIABLE o-field-in-error    AS CHARACTER NO-UNDO.      /*  Field input name in error, if any. */

/*** PathFix variables ***/

DEFINE VARIABLE codetorun       AS CHARACTER                        NO-UNDO.     
DEFINE VARIABLE depotcode       AS CHARACTER                        NO-UNDO.    
DEFINE VARIABLE drive_letter    AS CHARACTER                        NO-UNDO.    
ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).

/*** Find Patient ***/
DEFINE VARIABLE v-peopleID      AS INTEGER NO-UNDO.
DEFINE VARIABLE v-addrID        AS INTEGER NO-UNDO.
DEFINE VARIABLE o-fpat-exist    AS LOGICAL NO-UNDO. 
DEFINE VARIABLE o-fpat-ran      AS LOGICAL NO-UNDO. 
DEFINE VARIABLE o-fpat-error    AS LOGICAL NO-UNDO.
 
/*** Create Patient ***/
DEFINE VARIABLE o-ucpatient-create      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-ucpatient-update      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-ucpatient-error       AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-ucpatient-successful  AS LOGICAL NO-UNDO.
 
/*****  input / output parmeters  *****/
DEFINE INPUT PARAMETER v-filename       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER v-filelocation   AS CHARACTER FORMAT "x(90)" NO-UNDO.
DEFINE INPUT PARAMETER errlog           AS CHARACTER NO-UNDO. /*** location of the outbound log ***/
DEFINE INPUT PARAMETER dwightaddress    AS CHARACTER NO-UNDO. /** location of the dwight log ***/
DEFINE INPUT PARAMETER updatemode       AS LOGICAL NO-UNDO. 
DEFINE OUTPUT PARAMETER err-number      AS INTEGER NO-UNDO. /* 0 = didn't run, # = the # of the error, 99 = successfully ran. */

/*****  Streams  *****/
DEFINE STREAM to-error.
OUTPUT STREAM to-error TO VALUE(errlog) APPEND.

DEFINE STREAM dwight.
OUTPUT STREAM dwight TO VALUE(dwightaddress) APPEND.
  
DEFINE SHARED VARIABLE c-dwightUTMUEE1 AS LOGICAL NO-UNDO.    
DEFINE SHARED VARIABLE c-dwightUTMUEE2 AS LOGICAL NO-UNDO.

/* Here are some other tests I've been using for tests */
/* H150518-2457-1.txt : normal test, "Artem Bocharov" doesn't exist in my people_mstr  */
/* CPR CSV UTM UEE 03112013.txt : normal test, "Mark Jacobs" exists */

/*ASSIGN v-filelocation = "C:\Users\Trae\Desktop\Cleared_Tests\H150518-2457-1.txt".*/
/*ASSIGN v-filelocation = "C:\Users\Trae\Desktop\Cleared_Tests\CPR CSV UTM UEE 03112013.txt".*/

/*MESSAGE "Inside the ATT-attachwalk-R, updatemode = " updatemode VIEW-AS ALERT-BOX BUTTONS OK.*/

INPUT FROM VALUE (v-filelocation).

    StraightImport: 
    REPEAT:
        
        CREATE ATTcatcher.
        
        IMPORT DELIMITER "," ATTcatcher.
        
        IF ATTcatcher.slot1 = "interpretation text" THEN DO: /****/
    
            DELETE ATTcatcher.
        
            LEAVE StraightImport.
         
        END. /** HE condition **/
        
        ELSE IF ATTcatcher.slot1 = "*For Research Use Only. Not for use in d" THEN DO: /****/
    
            DELETE ATTcatcher.
        
            LEAVE StraightImport.
         
        END. /** MPA condition **/
        
        ELSE DO: /*** this is stuff that happens to every record ***/
                   
            IF ATTcatcher.slot1 = "sampleid" THEN ASSIGN v-lab-seq = v-lab-seq + 1. 
        
            ASSIGN 
                c-import = c-import + 1
                ATTcatcher.lab-seq = STRING(v-lab-seq).
             
        END. /*** ELSE: successful import ***/

    END. /** StraightImport **/
    
INPUT CLOSE. 
 
IF c-import = 0 THEN DO: 

{DV-DAW-export.i 1 "Nothing was imported from source file"}.

END. 


ELSE DO: /*** ELSE = Something Exists, so keep going ***/

    v-charholder = SUBSTRING(v-filelocation,1, (R-INDEX (v-filelocation,"\") - 1 )).
    v-fullpath-id = SUBSTRING(v-charholder,(R-INDEX(v-charholder,"\") + 1)).

    verification-loop:
    DO x = 1 TO v-lab-seq:
        
        
/******  Start of Lab Sample ID finding stuff  ******/

        FIND ATTcatcher WHERE 
            ATTcatcher.slot1 = "sampleid" AND 
            ATTcatcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (ATTcatcher) THEN ASSIGN v-lab-sampleID = ATTcatcher.slot2.
    
        ELSE DO: 
        
            {DV-DAW-export.i 2 "lab sample ID/sampleid unavailable in source file"}.
            
        END.
           
/*******  Start of Name Finding Stuff  ******/      
  
        FIND ATTcatcher WHERE 
            ATTcatcher.slot1 = "patient name" AND  
            ATTcatcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (ATTcatcher) THEN DO:        
/*            {../datahub/src/webspeed/pathfix.i "SUB-UnString-Name.r"}.*/   
/*MESSAGE SEARCH("SUB-UnString-Name.p") VIEW-AS ALERT-BOX BUTTONS OK.*/
            RUN VALUE(SEARCH("SUB-UnString-Name.p")) 
                (ATTcatcher.slot2,
                 v-ITmessages2,                     /* logical NO or YES. A YES displays the results at the end of this program. */
                 OUTPUT o-prefix,
                 OUTPUT o-firstname,
                 OUTPUT o-middlename,
                 OUTPUT o-lastname,
                 OUTPUT o-suffix, 
                 OUTPUT o-title_desc,
                 OUTPUT o-prefname,
                 OUTPUT o-gender,
                 OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
                 OUTPUT o-field-in-error).
       
        END. /*** if available "patient name" - regular tests ***/
        
        ELSE DO: 
        
            FIND ATTcatcher WHERE
                ATTcatcher.slot1 = "patient lastname" AND 
                ATTcatcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
                
            IF AVAILABLE (ATTcatcher) THEN DO:
                
                ASSIGN o-lastname = ATTcatcher.slot2.
                
                FIND ATTcatcher WHERE 
                    ATTcatcher.slot1 = "patient suffix" AND 
                    ATTcatcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
                    
                IF AVAILABLE (ATTcatcher) THEN DO:
                    
                    ASSIGN o-suffix = ATTcatcher.slot2.
                    
                    FIND ATTcatcher WHERE
                        ATTcatcher.slot1 = "patient firstname" AND 
                        ATTcatcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
                        
                    IF AVAILABLE (ATTcatcher) THEN DO:
                    
                        ASSIGN o-firstname = ATTcatcher.slot2.
                        
                        FIND ATTcatcher WHERE
                            ATTcatcher.slot1 = "patient middlename" AND 
                            ATTcatcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
                            
                        IF AVAILABLE (ATTcatcher) THEN DO: 
                        
                            ASSIGN 
                                o-middlename = ATTcatcher.slot2
                                v-nameholder = o-firstname + " " + o-middlename + " " + o-lastname + " " + o-suffix . 
                            
/*                            MESSAGE "name = " v-nameholder VIEW-AS ALERT-BOX BUTTONS OK.*/
                            
                            ASSIGN
                                o-firstname = ""
                                o-middlename = ""
                                o-lastname = ""
                                o-suffix = "".
                        
                            RUN VALUE (SEARCH("SUB-UnString-Name.p")) 
                            (v-nameholder,
                             v-ITmessages2,        /* logical NO or YES. A YES displays the results at the end of this program. */
                             OUTPUT o-prefix,
                             OUTPUT o-firstname,
                             OUTPUT o-middlename,
                             OUTPUT o-lastname,
                             OUTPUT o-suffix, 
                             OUTPUT o-title_desc,
                             OUTPUT o-prefname,
                             OUTPUT o-gender,
                             OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
                             OUTPUT o-field-in-error).
                        
                        
                        END. /***  of got all the name pieces  ***/
                        
                        ELSE DO: 
                        
                            {DV-DAW-export.i 3 "middle name unavailable in source file"}.

                        END. /*** Error number 3 ***/
                        
                    END. /*** of firstname available ***/
                    
                    ELSE DO: 
                    
                        {DV-DAW-export.i 4 "first name unavailable in source file"}.
                        
                    END.  
                    
                END. /*** of suffix available ***/
                
                ELSE DO: 
                
                    {DV-DAW-export.i 5 "suffix unavailable in source file"}.
                    
                END.
                
            END. /*** if available MPA style tests (if available lastname) ***/
            
            ELSE DO: 
            
                {DV-DAW-export.i 6 "Did not find any name fields in source file"}.
                
            END.

        END. /*** of ELSE DO: MPA name finding part ***/
        
    /****** End of the Name Finding Stuff | Start of Test Type finding for MPA's ******/
    
        FIND ATTcatcher WHERE 
            ATTcatcher.slot1 = "testtype" AND 
            ATTcatcher.lab-seq = STRING (x - 1) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (ATTcatcher) THEN ASSIGN v-testtype = ATTcatcher.slot2.
    
    /****** End of Test Type finding for MPA's | Start of TK_ID finding stuff ******/
        
        FIND ATTcatcher WHERE 
            ((ATTcatcher.slot1 = "client ref") OR (ATTcatcher.slot1 = "clientref")) AND 
                ATTcatcher.lab-seq = STRING (x) NO-LOCK NO-ERROR. 
            
        IF AVAILABLE (ATTcatcher) THEN DO:
            
            ASSIGN v-testkitID = ATTcatcher.slot2.
            
            IF v-testtype = "" THEN DO:
            
                IF v-filename MATCHES "*FM*" THEN
                    v-testtype = "FM".
                ELSE IF v-filename MATCHES "*HE *" THEN
                    v-testtype = "HE".
                ELSE IF v-filename MATCHES "*UAA*" THEN
                    v-testtype = "UAA".
                ELSE IF v-filename MATCHES "*UTM UEE*" THEN
                    v-testtype = "UTM / UEE".
                ELSE IF v-filename MATCHES "*UTM-UEE*" THEN
                    v-testtype = "UTM / UEE".    
                ELSE IF v-filename MATCHES "*UTM*" THEN 
                    v-testtype = "UTM".   
                       
                ELSE IF v-testtype = "" THEN DO:
                    
                    ASSIGN v-testtypeholder = SUBSTRING (v-testkitID,1,INDEX(v-testkitID,"-") - 1).
                    
                    IF v-testtypeholder MATCHES "*FM*" THEN
                        v-testtype = "FM".
                    ELSE IF v-testtypeholder MATCHES "*HE*" THEN
                        v-testtype = "HE".
                    ELSE IF v-testtypeholder MATCHES "*UAA*" THEN
                        v-testtype = "UAA".
                    ELSE IF v-testtypeholder MATCHES "*UTM UEE*" THEN
                        v-testtype = "UTM / UEE".
                    ELSE IF v-testtypeholder MATCHES "*UTM-UEE*" THEN
                        v-testtype = "UTM / UEE".    
                    ELSE IF v-testtypeholder MATCHES "*UTM*" THEN 
                        v-testtype = "UTM". 
                    ELSE IF v-testtypeholder MATCHES "*UTEE*" THEN 
                        v-testtype = "UTM / UEE".
                    ELSE IF v-testtypeholder MATCHES "*UTMUEE*" THEN 
                        v-testtype = "UTM / UEE". 
                    
                END. /*** substring-ing do ***/                
                
            END. /**** end of v-testtype = "" tree ***/    
            
        END. /*** of if available client ref (AKA TK_ID) ***/
            
        ELSE DO: 
        
            {DV-DAW-export.i 7 "client ref/TK_ID unavailable in the source file"}.
            
        END. 
        
    /****** End of TK_ID Finding Stuff | Start of DOB finding stuff *******/
    
        FIND ATTcatcher WHERE 
            ATTcatcher.slot1 = "patient dob" AND 
            ATTcatcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (ATTcatcher) THEN ASSIGN v-DOB-progress = DATE (ATTcatcher.slot2).

        ELSE DO: {DV-DAW-export.i 8 "patient DOB unavailable in source file"}. END.

    /****** End of DOB Finding Stuff  ******/
    
/*    IF                                     */
/*    v-testtype = "CMI"  OR                 */
/*    v-testtype = "CMIP" OR                 */
/*    v-testtype = "M+D"  OR                 */
/*    v-testtype = "M+I"  OR                 */
/*    v-testtype = "M+IP" OR                 */
/*    v-testtype = "MD"   OR                 */
/*    v-testtype = "MDP"  OR                 */
/*    v-testtype = "MI"   OR                 */
/*    v-testtype = "MIP"  OR                 */
/*    v-testtype = "OMI"  OR                 */
/*    v-testtype = "OMIP" OR                 */
/*    v-testtype = "UMI"  THEN               */
/*        ASSIGN v-test_family = "MPA".      */
/*                                           */
/*    ELSE ASSIGN v-test_family = v-testtype.*/
        
/*    ELSE ASSIGN v-test_family = "BIOMED".*/
    
/*        FIND test_mstr WHERE                                                                   */
/*            test_mstr.test_type = v-testtype                                                   */
/*            NO-LOCK NO-ERROR.                                                                  */
/*                                                                                               */
/*        IF AVAILABLE (test_mstr) THEN DO:                                                      */
/*                                                                                               */
/*            ASSIGN v-test_family = test_mstr.test_family.                                      */
/*                                                                                               */
/*        END. /*** if available test_mstr ***/                                                  */
/*                                                                                               */
/*        ELSE IF v-testtype <> "" THEN DO:                                                      */
/*                                                                                               */
/*            IF v-test_family = "" THEN DO:                                                     */
/*                ASSIGN v-test_family = v-testtype.                                             */
/*            END.                                                                               */
/*                                                                                               */
/*            {DV-DAW-export.i 9 "test_mstr unavailable where v-testtype = test_mstr.test_type"}.*/
/*                                                                                               */
/*        END. /*** test_mstr unavailable ***/                                                   */
    
        IF v-ITmessages = YES THEN 
            DISPLAY "End of Extraction." v-lab-sampleID x o-lastname o-firstname v-testkitID v-testtype v-DOB-progress err-number 
                WITH 2 COL FRAME b TITLE "From Input File".
       
       
        
/************************************************************************************************************************/        
        
/*    {../datahub/src/webspeed/pathfix.i "SUBpat-findR.r"}.*/
    
    RUN VALUE (SEARCH("SUBpat-findR.p")) 
        (o-prefix,
        o-firstname,
        o-middlename,
        o-lastname,
        o-suffix,
        v-DOB-progress,
        OUTPUT v-peopleID,
        OUTPUT v-addrID,
        OUTPUT o-fpat-exist,
        OUTPUT o-fpat-ran,
        OUTPUT o-fpat-error).
        
    ASSIGN depotcode = "".
    
    IF o-fpat-exist = YES THEN DO:
        
        FIND people_mstr WHERE 
            people_mstr.people_id = v-peopleID AND 
            people_mstr.people_deleted = ? /* should be useless */ NO-LOCK NO-ERROR.
            
        IF AVAILABLE (people_mstr) THEN DO:

            FIND FIRST TK_mstr WHERE 
                TK_mstr.TK_lab_sample_ID = v-lab-sampleID AND 
                TK_mstr.TK_lab_seq = x AND
                TK_mstr.TK_deleted = ?
                NO-LOCK NO-ERROR.
            
            IF AVAILABLE (tk_mstr) THEN DO: 
            
                ASSIGN  
                    v-testkitID = TK_mstr.TK_ID
                    v-tk_patient_id = TK_mstr.TK_patient_ID 
                    v-test_seq = TK_mstr.TK_test_seq .
                    
                IF v-testtype <> "MPA" THEN ASSIGN v-testtype = TK_mstr.TK_test_type.                       /* 1dot1 */
    
                IF people_mstr.people_id = TK_mstr.TK_patient_ID THEN DO:
    
/*                    {DV-DAW-export.i 69 "Patient Found: people_ID = TK_patient_ID"}.*/
    
                END. /*** of = id's ***/
    
                ELSE DO:
                     
                    IF updatemode = YES THEN DO:
                    
                        FIND FIRST TK_mstr WHERE 
                            TK_mstr.TK_lab_sample_ID = v-lab-sampleID AND 
                            TK_mstr.TK_lab_seq = x AND
                            TK_mstr.TK_deleted = ?
                            EXCLUSIVE-LOCK NO-ERROR.
    
                        IF AVAILABLE (tk_mstr) THEN DO:                                                 /* 1dot1 */
                        
                            ASSIGN 
                                TK_mstr.TK_patient_ID = people_mstr.people_id
                                TK_mstr.TK_modified_date = TODAY
                                TK_mstr.TK_modified_by = USERID("HHI")
                                TK_mstr.TK_prog_name = THIS-PROCEDURE:FILE-NAME.
                        
                        END. /** Database Update **/
                           
                        ELSE DO:
                            
                            {DV-DAW-export.i 666 "Patient Found: Database Update Failed!}. /** pretty much the worst error ever. **/
                            NEXT verification-loop. 
                        
                        END.    
    
                    END. /*** update mode ***/
                    
                    {DV-DAW-export.i 60 "Patient Found: people_ID <> TK_patient_ID"}. /** pretty much the worst error ever. **/
                    NEXT verification-loop.
    
                END. /*** of <> id's ***/

            END. /*** of TK_mstr available ***/ 
            
            ELSE DO: /*** TK_mstr is not available ***/
            
                FIND LAST TK_mstr WHERE 
                    TK_mstr.TK_lab_sample_ID = v-lab-sampleID AND 
                    TK_mstr.TK_deleted = ?
                    NO-LOCK NO-ERROR.
                    
                IF AVAILABLE (TK_mstr) THEN DO: 
                
                    ASSIGN v-last-lab-seq = TK_mstr.TK_lab_seq.
    
                    IF TK_mstr.TK_test_seq > x THEN DO:
                    
                        {DV-DAW-moveDwight-U.i}.
                        {DV-DAW-export.i 45 "Patient Found: TK_mstr.TK_test_seq > x variable"}.
                        NEXT verification-loop.
                        
                    END.
                    
                    ELSE DO:
                    
                        {DV-DAW-moveDwight-U.i}.
                        {DV-DAW-export.i 445 "Patient Found: TK_mstr.TK_test_seq LT x variable"}.
                        NEXT verification-loop.
                    
                    END. 
    
                END.
            
                ELSE DO:
            
                    {DV-DAW-moveDwight-U.i}.
                    {DV-DAW-export.i 42 "Patient Found: TK_mstr completely unavailable"}.
                    NEXT verification-loop.
            
                END. 
            
            END. /*** TK_mstr unavailable  **/

            FIND att_files WHERE 
                att_files.att_table  = "TK_mstr"                        AND 
                att_files.att_field1 = "TK_mstr.TK_lab_sample_id"       AND 
                att_files.att_value1 = v-lab-sampleID                   AND
                att_files.att_field2 = "TK_mstr.TK_lab_seq"             AND 
                att_files.att_value2 = STRING (x)                       AND /*** actually the lab_seq ***/
                att_files.att_field5 = "RS Patient ID"                  AND 
                att_files.att_value5 = STRING (people_mstr.people_id) AND /** Unhappy line Aug 4th ***/
                att_files.att_category = "SOURCE CSV" AND 
                att_files.att_deleted = ?            
                USE-INDEX att-val-idx NO-LOCK NO-ERROR.
                 
            IF AVAILABLE (att_files) THEN DO: 

                ASSIGN v-attpeopleID = att_files.att_value5.
                
                /***  It's all good :) ***/
                {DV-DAW-export.i 99 "Patient Found: Source File patient ID matched the Att value 5"}.
                NEXT verification-loop.
                
            END. /*** available ATT_Files ***/
                
            ELSE DO:  /*** att_file was not available ***/
                
                FIND att_files WHERE 
                    att_files.att_table  = "TK_mstr"                        AND 
                    att_files.att_field1 = "TK_mstr.TK_lab_sample_id"       AND 
                    att_files.att_value1 = v-lab-sampleID                   AND
                    att_files.att_field2 = "TK_mstr.TK_lab_seq"             AND 
                    att_files.att_value2 = STRING (x)             AND 
                    att_files.att_category = "SOURCE CSV" AND 
                    att_files.att_deleted = ?                
                    USE-INDEX att-val-idx NO-LOCK NO-ERROR.
                
                IF AVAILABLE (att_files) THEN DO:

                    /***  It's all good :) ***/       
                    {DV-DAW-export.i 999 "Patient Found: Attached File ID is blank, but att files table is available."}.                    
                    NEXT verification-loop.
                                         
                END. /*** att_files available ***/

                ELSE DO:  /*** if att_files are unavaiable ***/
                    
                    {DV-DAW-moveDwight-U.i}.
                    {DV-DAW-export.i 11 "Patient Found: Attach File table is unavailable}.
                    NEXT verification-loop.
                        
                END. /*** ***/

            END. /*** att_file w/ peopleID not available ***/
        
        END. /*** of if patient is available ***/

    END. /*** of patient exists ***/
    
    ELSE IF o-fpat-exist = NO AND o-fpat-ran = YES AND o-fpat-error = NO THEN DO:
        
        FIND people_mstr WHERE 
            people_mstr.people_id = v-peopleID 
            AND people_mstr.people_deleted = ? NO-LOCK NO-ERROR.
            
        IF AVAILABLE (people_mstr) THEN DO:

            IF updatemode = YES THEN DO:
            
                RUN VALUE(SEARCH("SUBpat-ucU.p")) 
                    (people_mstr.people_id, /* patient_mstr.patient_id */
                    "",                     /* patient_mstr.patient_condition */
                    "",                     /* patient_mstr.patient_notes */
                    people_mstr.people_id,  /*responsible party */
                    0,                      /* doctor_id */
                    0,                      /* cust_id */
                    ?,                      /* patient_verified */
                    OUTPUT v-peopleID,
                    OUTPUT o-ucpatient-create,
                    OUTPUT o-ucpatient-update,
                    OUTPUT o-ucpatient-error,
                    OUTPUT o-ucpatient-successful).                                             
        
                IF o-ucpatient-successful = NO THEN DO:
                
                    {DV-DAW-export.i 50 "Non-patient: Patient Create Failed!}.
                    NEXT verification-loop.
                    
                END. /*** patient creation failed ***/

            END. /*** of update mode ***/

            FIND FIRST TK_mstr WHERE 
                TK_mstr.TK_lab_sample_ID = v-lab-sampleID AND 
                TK_mstr.TK_lab_seq = x AND
                TK_mstr.TK_deleted = ?
                NO-LOCK NO-ERROR.
            
            IF AVAILABLE (tk_mstr) THEN DO: 
            
                ASSIGN  
                    v-testkitID = TK_mstr.TK_ID
                    v-tk_patient_id = TK_mstr.TK_patient_ID
                    v-test_seq = TK_mstr.TK_test_seq .
    
                IF v-testtype <> "MPA" THEN ASSIGN v-testtype = TK_mstr.TK_test_type.                       /* 1dot1 */
    
                IF people_mstr.people_id = TK_mstr.TK_patient_ID THEN DO:
    
/*                    {DV-DAW-export.i 68 "Non-patient: people_ID = TK_patient_ID"}.*/
    
                END. /*** of = id's ***/
    
                ELSE DO:

                    IF updatemode = YES THEN DO:

                        FIND FIRST TK_mstr WHERE
                            TK_mstr.TK_lab_sample_ID = v-lab-sampleID AND
                            TK_mstr.TK_lab_seq = x AND
                            TK_mstr.TK_deleted = ?
                            EXCLUSIVE-LOCK NO-ERROR.

                        IF AVAILABLE (tk_mstr) THEN DO:                                                 /* 1dot1 */

                            ASSIGN
                                TK_mstr.TK_patient_ID = people_mstr.people_id
                                TK_mstr.TK_modified_date = TODAY
                                TK_mstr.TK_modified_by = USERID("HHI")
                                TK_mstr.TK_prog_name = THIS-PROCEDURE:FILE-NAME.

                        END. /** Database Update **/

                        ELSE DO:

                            {DV-DAW-export.i 616 "Non-patient: Database Update Failed!}.
                            NEXT verification-loop.

                        END.

                    END. /*** update mode ***/

                    {DV-DAW-export.i 61 "Non-patient: people_ID <> TK_patient_ID"}.
                    NEXT verification-loop.

                END. /*** of <> id's ***/

            END. /*** of TK_mstr available ***/ 
            
            ELSE DO: /*** TK_mstr is not available ***/
            
/*                {DV-DAW-moveDwight-U.i}.*/
                {DV-DAW-export.i 43 "Non-patient: TK_mstr unavailable, part 1"}.
/*                NEXT verification-loop.*/
            
            END. /*** TK_mstr unavailable  **/
            
            FIND LAST TK_mstr WHERE 
                TK_mstr.TK_lab_sample_ID = v-lab-sampleID AND 
                TK_mstr.TK_deleted = ?
                NO-LOCK NO-ERROR.
                
            IF AVAILABLE (TK_mstr) THEN DO: 
                
                ASSIGN v-last-lab-seq = TK_mstr.TK_lab_seq.

                IF TK_mstr.TK_test_seq > x THEN DO:
                
                    /***  Our Fault ***/
                    {DV-DAW-export.i 44 "Non-patient: TK_mstr.TK_lab_seq > x variable"}.
                    NEXT verification-loop.
                
                END.
            
                ELSE DO:
                    
                    {DV-DAW-export.i 444 "Non-patient: TK_mstr.TK_test_seq LT x variable"}.
                    NEXT verification-loop.
                
                END. 
            
            END.

            ELSE DO: /*** TK_mstr is seriously not available ***/
            
                {DV-DAW-moveDwight-U.i}.
                {DV-DAW-export.i 432 "Non-patient: TK_mstr unavailable, part 2"}.
                NEXT verification-loop.
            
            END. /*** TK_mstr unavailable  **/

            FIND att_files WHERE  
                att_files.att_table  = "TK_mstr"                        AND 
                att_files.att_field1 = "TK_mstr.TK_lab_sample_id"       AND 
                att_files.att_value1 = v-lab-sampleID                   AND
                att_files.att_field2 = "TK_mstr.TK_lab_seq"             AND 
                att_files.att_value2 = STRING (x)            AND 
                att_files.att_field5 = "RS Patient ID"                  AND 
                att_files.att_value5 = STRING (people_mstr.people_id)    
                AND att_files.att_category = "SOURCE CSV" AND 
                att_files.att_deleted = ?          
                USE-INDEX att-val-idx NO-LOCK NO-ERROR.
                 
            IF AVAILABLE (att_files) THEN DO: 
                
                ASSIGN v-attpeopleID = att_files.att_value5.
                
                /***  It's all good :) ***/    
                {DV-DAW-export.i 97 "Non-patient: Source File people ID matched the Att value 5"}.
                NEXT verification-loop.
        
            END. /*** available att_files w/ people-id **/
                    
            ELSE DO:  /*****  No files available w/ people_id  *****/
                
                FIND att_files WHERE 
                    att_files.att_table  = "TK_mstr"                        AND 
                    att_files.att_field1 = "TK_mstr.TK_lab_sample_id"       AND 
                    att_files.att_value1 = v-lab-sampleID                   AND
                    att_files.att_field2 = "TK_mstr.TK_lab_seq"             AND 
                    att_files.att_value2 = STRING (x)             AND 
                    att_files.att_field5 = "RS Patient ID"  
                    AND att_files.att_category = "SOURCE CSV" AND
                    att_files.att_deleted = ?                
                    USE-INDEX att-val-idx NO-LOCK NO-ERROR.
                
                IF AVAILABLE (att_files) THEN DO:
                    
                    IF att_files.att_value5 <> "" THEN DO:
                        
                        ASSIGN v-attpeopleID = att_files.att_value5.
                        
                        /***  It's all good :) ***/    
                        {DV-DAW-export.i 913 "Non-patient: Found att files with different people id than the people master"}.
                        NEXT verification-loop.
                         
                    END.    /*** end of att_vlaue 5 = something ***/
                    
                    ELSE DO:  /** attfiles unavailable with lab sample id and lab seq  and att_value5 = "" ***/
                        
                        ASSIGN v-attpeopleID = "there was nothing there!".
                        
                        {DV-DAW-moveDwight-U.i}.    
                        {DV-DAW-export.i 13 "Non-patient: find att files failed for the people master record and there was no value in att value 5"}.
                        NEXT verification-loop.
                    
                    END. /** attfiles unavailable with lab sample id and lab seq  and att_value5 = "" ***/
                                         
                END. /** attfiles available with lab sample id and lab seq and nothing in v-people-id***/
                
            END. /*** ELSE DO: find  available att_files w/o people-id***/
        
        END. /*** if the people_mstr avaible, not a patient ***/

    END. /***  of ELSE: patient doesn't exist  ***/
    
    ELSE IF o-fpat-exist = NO AND o-fpat-ran = YES AND o-fpat-error = YES THEN DO:
        
        
        /**************  Removing with version 1dot1  ***********************
        FIND FIRST PATIENT_DELETED_RCD WHERE
/*            PATIENT_DELETED_RCD.PatDOB = v-DOB-progress AND*/
            PATIENT_DELETED_RCD.PatLastName = o-lastname AND 
            PATIENT_DELETED_RCD.PatFirstName = o-firstname
            NO-LOCK NO-ERROR.
    
        IF AVAILABLE (PATIENT_DELETED_RCD) THEN DO:

            /* it is likely that we will need to run Grandpa Harold's Code that brings the RS PATIENT DELETED RCD table data across into PROGRESS */

            {DV-DAW-moveDwight-U.i}.                 
            {DV-DAW-export.i 96 "Probable Merge - No people master record found, but a RS PATIENT DELETED RCD was found"}.
            NEXT verification-loop.
            
        END. /*** Probable Merge success # 96 ***/
        
        ELSE DO:
      *********************  end of 1dot1 ****************************/
        
            FIND FIRST TK_mstr WHERE 
                    TK_mstr.TK_lab_sample_ID = v-lab-sampleID AND 
                    TK_mstr.TK_lab_seq = x AND
                    TK_mstr.TK_deleted = ?
                    NO-LOCK NO-ERROR.
                
            IF AVAILABLE (tk_mstr) THEN DO:  /*** find with x ***/
            
                ASSIGN  
                    v-testkitID = TK_mstr.TK_ID
                    v-tk_patient_id = TK_mstr.TK_patient_ID
                    v-test_seq = TK_mstr.TK_test_seq.
        
                IF v-testtype <> "MPA" THEN ASSIGN v-testtype = TK_mstr.TK_test_type.                       /* 1dot1 */
        
                FIND people_mstr WHERE 
                    people_mstr.people_id = TK_mstr.TK_patient_ID AND 
                    people_mstr.people_deleted = ?
                    NO-LOCK NO-ERROR.
                    
                IF AVAILABLE (people_mstr) THEN DO:
    
                    {DV-DAW-moveDwight-U.i}.
                    {DV-DAW-export.i 25 "Nobody: This test belongs to someone else."}.    
                    NEXT verification-loop.
                
                END.
                
                ELSE DO:
                
                    {DV-DAW-moveDwight-U.i}.
                    {DV-DAW-export.i 26 "Nobody: Orphaned TK record."}.
                    NEXT verification-loop.
                    
                END. /** people mstr unavailable **/
            
            END. /*** of TK_mstr available with x***/ 
            
            ELSE DO: /*** TK_mstr is not available ***/
            
/*                {DV-DAW-moveDwight-U.i}.*/
                {DV-DAW-export.i 22 "Nobody: TK_mstr unavailable, part 1"}.
/*                NEXT verification-loop.*/
            
            END. /*** TK_mstr unavailable  **/
            
            FIND LAST TK_mstr WHERE 
                TK_mstr.TK_lab_sample_ID = v-lab-sampleID AND 
                TK_mstr.TK_deleted = ?
                NO-LOCK NO-ERROR.
                
            IF AVAILABLE (TK_mstr) THEN DO: 
            
                ASSIGN v-last-lab-seq = TK_mstr.TK_lab_seq.
            
                IF TK_mstr.TK_lab_seq > x THEN DO:
                    
                    {DV-DAW-moveDwight-U.i}.
                    {DV-DAW-export.i 27 "Nobody: TK_mstr.TK_lab_seq > x-lab-seq variable"}.
                    NEXT verification-loop.
                    
                END. 
            
                ELSE DO: 
            
                    {DV-DAW-moveDwight-U.i}.
                    {DV-DAW-export.i 277 "Nobody: TK_mstr.TK_lab_seq LT x-lab-seq variable"}.
                    NEXT verification-loop.
            
                END. 
            
            END. 
            
            ELSE DO: /*** TK_mstr is not available at all ***/
            
                {DV-DAW-moveDwight-U.i}.
                {DV-DAW-export.i 222 "Nobody: TK_mstr unavailable, part 2"}.
                NEXT verification-loop.
            
            END. /*** TK_mstr completely unavailable  **/
                        
/*        END. /** of ELSE: this isn't a probable merge. **/                                          /* 1dot1 */*/
        
    END. /*** of nobody found ***/

    IF err-number = 0 THEN DO:
    
/*        {DV-DAW-moveDwight-U.i}.*/
           
        {DV-DAW-export.i 0 "Went all the way through the ATT-attachwalk-R without triggering any errors or successes"}.
    
    END. /*** err-number = 0 ***/

  END. /*** do x = 1 to v-lab-seq: ***/
            
END. /******************************************  of ELSE DO: All the data extraction stuff  ************************************/
    
OUTPUT STREAM to-error CLOSE.

/* *************************  END OF FILE  ***************************** */ 
                       
