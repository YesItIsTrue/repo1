/*------------------------------------------------------------------------
    File        : TL-DDItxtwalk.p
    Purpose     : To "walk" through all the text files in the DDI directory and pull the useful data
                out of the header of each file.

    Author(s)   : Trae Luttrell
    Created     : Thu Oct 08 15:31:07 EDT 2015
    Updated     : Thu Oct 08 15:31:07 EDT 2015
    Version     : 1.0
    Notes       : 
                    
  ----------------------------------------------------------------------*/
  
/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW. 

/** this Temp table "ches" each LINE of the txt file **/
DEFINE TEMP-TABLE TXTcher
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

DEFINE VARIABLE v-testkitID     AS CHARACTER FORMAT "x(12)" NO-UNDO.
DEFINE VARIABLE v-DOB-progress  LIKE people_mstr.people_DOB NO-UNDO.
DEFINE VARIABLE v-lab-sampleID  LIKE TK_mstr.TK_lab_sample_ID NO-UNDO.
DEFINE VARIABLE v-lab-seq       LIKE TK_mstr.TK_lab_seq NO-UNDO.
DEFINE VARIABLE i-test_typeholder AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-nameholder    AS CHARACTER NO-UNDO. /*** name holder for no cross-contamination ***/
DEFINE VARIABLE v-test_seq LIKE TK_mstr.TK_test_seq NO-UNDO.
DEFINE VARIABLE x AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ITmessages AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE c-import AS INTEGER NO-UNDO.

DEFINE VARIABLE v-testage AS DECIMAL NO-UNDO.
DEFINE VARIABLE i-date-col AS DATE NO-UNDO.
DEFINE VARIABLE i-date-rec AS DATE NO-UNDO.
DEFINE VARIABLE i-date-comp AS DATE NO-UNDO.

/*** Outputs for Harold's SUB-Unstring-Name.p ***/
DEFINE VARIABLE o-prefix            AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-firstname         AS CHARACTER NO-UNDO. /*** for the PDF name ***/
DEFINE VARIABLE o-middlename        AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-lastname          AS CHARACTER NO-UNDO. /*** for the PDF name ***/ 
DEFINE VARIABLE o-suffix            AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-title_desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-prefname          AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-gender            AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-unstring-error    AS LOGICAL NO-UNDO.        /*  YES = errors / NO = no errors. */
DEFINE VARIABLE o-field-in-error    AS CHARACTER NO-UNDO.      /*  Field input name in error, if any. */
      
/*****  input / output parmeters  *****/  
DEFINE INPUT PARAMETER v-filename       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-filelocation    AS CHARACTER FORMAT "x(90)" NO-UNDO. 
DEFINE INPUT PARAMETER i-pat-lastname   LIKE people_mstr.people_lastname NO-UNDO.
DEFINE INPUT PARAMETER i-pat-firstname  LIKE people_mstr.people_firstname NO-UNDO.
DEFINE INPUT PARAMETER i-test_type       LIKE TK_mstr.TK_test_type NO-UNDO.
DEFINE INPUT PARAMETER i-createdate     AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-TXTvsPDF       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER logloion      AS CHARACTER NO-UNDO. /*** loion of the outbound log ***/
DEFINE INPUT PARAMETER i-updatemode       AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER err-number      AS INTEGER NO-UNDO. /* 0 = didn't run, # = the # of the error, 99 = successfully ran. */

DEFINE VARIABLE err-message     AS CHARACTER NO-UNDO.
DEFINE VARIABLE export-filelocation AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-whathappened  AS CHARACTER NO-UNDO.
DEFINE VARIABLE i-firstname     AS CHARACTER NO-UNDO.
DEFINE VARIABLE i-lastname      AS CHARACTER NO-UNDO.
DEFINE VARIABLE i-DOB-progress  AS DATE NO-UNDO. 
DEFINE VARIABLE v-peopleID      AS INTEGER NO-UNDO.
DEFINE VARIABLE o-fpat-exist    AS LOGICAL NO-UNDO.
DEFINE VARIABLE i-testkitID     LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE VARIABLE i-test_seq      LIKE TK_mstr.TK_test_seq NO-UNDO.
DEFINE VARIABLE i-lab-sampleID  LIKE TK_mstr.TK_lab_sample_ID NO-UNDO.
DEFINE VARIABLE i-lab-seq       LIKE TK_mstr.TK_lab_seq NO-UNDO.
DEFINE VARIABLE i-loglocation   AS CHARACTER NO-UNDO.

/*****  Streams  *****/
DEFINE STREAM to-error.
OUTPUT STREAM to-error TO VALUE(logloion) APPEND.

/* this would be a great spot to assign the imported variables to the regular ones. or just replace the regular ones with the imported ones */

/********************************  Start Importing Routine  *************************/
v-lab-seq = 0.

INPUT FROM VALUE (i-filelocation).

    StraightImport: 
    REPEAT:
        
        CREATE TXTcher.
        
        IMPORT DELIMITER "," TXTcher.
        
        IF TXTcher.slot1 = "interpretation text" OR 
            TXTcher.slot1 = "*For Research Use Only." OR 
            TXTcher.slot1 = "L-configured amino acids" THEN DO: /****/
    
            DELETE TXTcher.
        
            LEAVE StraightImport.
         
        END. /** HE condition **/
        
        ELSE DO: /*** this is stuff that happens to every record ***/
                   
            IF TXTcher.slot1 = "sampleid" THEN ASSIGN v-lab-seq = v-lab-seq + 1. 
        
            ASSIGN 
                TXTcher.lab-seq = STRING(v-lab-seq)
                c-import = c-import + 1.
                
        END. /*** ELSE: successful import ***/

    END. /** StraightImport **/ 
    
INPUT CLOSE. 
 
IF c-import = 0 THEN DO: 
    {DL-DDIwalkExport.i 1 "Nothing was imported from source file" "Error"}. 
    {DL-DDIcatchall.i}
END. 

ELSE maine-loop: DO: /*** ELSE = Something Exists, so keep going ***/

/*    IF v-lab-seq > 2 THEN MESSAGE "x greater than 2... test type:" i-test_type " file:" v-filename " lab-seq:" v-lab-seq VIEW-AS ALERT-BOX BUTTONS OK.*/

/*    IF v-filename = "CSV UTM UEE 07152013.TXT" then do:*/
/*                                                       */
/*        output to "C:\progress\wrk\whiskey.txt".       */
/*                                                       */
/*        FOR EACH TXTcher                               */
/*            NO-LOCK:                                   */
/*                                                       */
/*            export delimiter ";"                       */
/*                lab-seq slot1 slot2.                   */
/*                                                       */
/*        END.  /** of 4ea. txtcher - export **/         */
/*                                                       */
/*        output close.                                  */
/*                                                       */
/*    end. /** of if v-filename = our one **/            */
    
   /* MESSAGE 
        "v-filename = " v-filename SKIP
        "i-pat-firstname = " i-pat-firstname SKIP
        "i-pat-lastname = " i-pat-lastname SKIP      
        "o-firstname = " o-firstname SKIP            
        "o-lastname = " o-lastname SKIP              
        "v-lab-seq = " v-lab-seq SKIP                
        VIEW-AS ALERT-BOX BUTTONS OK.   */             

    verification-loop: 
    DO x = 1 TO v-lab-seq:
    
        /* MESSAGE 
            "Just INSIDE the top fo the verification-loop" SKIP
            "v-lab-sampleID = " v-lab-sampleID SKIP
            "v-test_seq = " v-test_seq SKIP
            "v-lab-seq = " v-lab-seq SKIP
            "x = " x SKIP 
                VIEW-AS ALERt-BOX BUTTONS OK. */
     
/******  Start of Lab Sample ID finding stuff  ******/

        /* MESSAGE 
            "About to Find sampleid" SKIP
            "v-lab-sampleID = " v-lab-sampleID SKIP
            "v-test_seq = " v-test_seq SKIP
            "v-lab-seq = " v-lab-seq SKIP
            "x = " x SKIP 
                VIEW-AS ALERt-BOX BUTTONS OK. */

        FIND FIRST TXTcher WHERE  
            TXTcher.slot1 = "sampleid" AND 
            TXTcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (TXTcher) THEN ASSIGN v-lab-sampleID = TXTcher.slot2.
    
        ELSE DO: {DL-DDIwalkExport.i 2 "lab sample ID/sampleid unavailable in source file" "Warning"}. END.
           
/*******  Start of Name Finding Stuff  ******/      
  
       /*  MESSAGE 
            "About to Find patient name" SKIP
            "v-lab-sampleID = " v-lab-sampleID SKIP
            "v-test_seq = " v-test_seq SKIP
            "v-lab-seq = " v-lab-seq SKIP
            "x = " x SKIP 
                VIEW-AS ALERt-BOX BUTTONS OK. */
  
        FIND FIRST TXTcher WHERE 
            TXTcher.slot1 = "patient name" AND  
            TXTcher.lab-seq = STRING(x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (TXTcher) AND i-pat-lastname = "" AND i-pat-firstname = "" THEN DO:        

            RUN VALUE(SEARCH("SUB-UnString-Name.r")) 
                (TXTcher.slot2,
                 v-ITmessages,                     /* logical NO or YES. A YES displays the results at the end of this program. */
                 OUTPUT o-prefix,
                 OUTPUT i-pat-firstname,
                 OUTPUT o-middlename,
                 OUTPUT i-pat-lastname,
                 OUTPUT o-suffix, 
                 OUTPUT o-title_desc,
                 OUTPUT o-prefname,
                 OUTPUT o-gender,
                 OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
                 OUTPUT o-field-in-error).
       
        END. /*** if available patient name - regular tests */
        
        ELSE IF i-pat-lastname = "" AND i-pat-firstname = "" THEN DO: 
        
            /* MESSAGE 
                "About to Find patient lastname" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK. */
        
            FIND FIRST TXTcher WHERE
                TXTcher.slot1 = "patient lastname" AND 
                TXTcher.lab-seq = STRING(x) NO-LOCK NO-ERROR.
                
            IF AVAILABLE (TXTcher) THEN ASSIGN i-pat-lastname = TXTcher.slot2.
            
            ELSE DO: {DL-DDIwalkExport.i 5 "last name unavailable in source file" "Warning"}. END.
                 
            FIND FIRST TXTcher WHERE 
                TXTcher.slot1 = "patient suffix" AND 
                TXTcher.lab-seq = STRING(x) NO-LOCK NO-ERROR.
                
            IF AVAILABLE (TXTcher) THEN ASSIGN o-suffix = TXTcher.slot2.
            
            ELSE DO: {DL-DDIwalkExport.i 5 "suffix unavailable in source file" "Warning"}. END.      
                    
            FIND FIRST TXTcher WHERE
                TXTcher.slot1 = "patient firstname" AND 
                TXTcher.lab-seq = STRING(x) NO-LOCK NO-ERROR.
                
            IF AVAILABLE (TXTcher) THEN ASSIGN i-pat-firstname = TXTcher.slot2.
            
            ELSE DO: {DL-DDIwalkExport.i 4 "first name unavailable in source file" "Warning"}. END.
                        
            FIND FIRST TXTcher WHERE
                TXTcher.slot1 = "patient middlename" AND 
                TXTcher.lab-seq = STRING(x) NO-LOCK NO-ERROR.
                            
            IF AVAILABLE (TXTcher) THEN ASSIGN o-middlename = TXTcher.slot2.

            ELSE DO: {DL-DDIwalkExport.i 3 "middle name unavailable in source file" "Warning"}. END. 
                                
            ASSIGN v-nameholder = i-pat-firstname + " " + o-middlename + " " + i-pat-lastname + " " + o-suffix.
                    
            ASSIGN
                i-pat-firstname = ""
                o-middlename = ""
                i-pat-lastname = ""
                o-suffix = "".
                     
            RUN VALUE (SEARCH("SUB-UnString-Name.r")) 
                (v-nameholder,
                 v-ITmessages,        /* logical NO or YES. A YES displays the results at the end of this program. */
                 OUTPUT o-prefix,
                 OUTPUT i-pat-firstname,
                 OUTPUT o-middlename,
                 OUTPUT i-pat-lastname,
                 OUTPUT o-suffix, 
                 OUTPUT o-title_desc,
                 OUTPUT o-prefname,
                 OUTPUT o-gender,
                 OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
                 OUTPUT o-field-in-error).

        END. /*** of ELSE DO: MPA name finding part ***/
        
/*        IF o-firstname = "" THEN ASSIGN o-firstname = i-pat-firstname.*/
/*                                                                      */
/*        IF o-lastname = "" THEN ASSIGN o-lastname = i-pat-lastname.   */
        
    /****** End of the Name Finding Stuff | Start of Test Type finding for MPA's ******/
    
        /* MESSAGE 
                "About to Find testype" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK.*/
    
        FIND FIRST TXTcher WHERE 
            TXTcher.slot1 = "test_type" AND 
            TXTcher.slot2 = "MPA" NO-LOCK NO-ERROR.
            
        IF AVAILABLE (TXTcher) AND i-test_type = "" THEN ASSIGN i-test_type = TXTcher.slot2.
        
        ELSE IF i-test_type <> "" THEN ASSIGN i-test_type = i-test_type.

    /****** End of Test Type finding for MPA's | Start of TK_ID finding stuff ******/
        
        /*  MESSAGE 
                "About to Find client ref" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK. */
        
        FIND FIRST TXTcher WHERE 
            ((TXTcher.slot1 = "client ref") OR (TXTcher.slot1 = "clientref")) AND 
                TXTcher.lab-seq = STRING (x) NO-LOCK NO-ERROR. 
            
        IF AVAILABLE (TXTcher) AND i-testkitID = "" THEN 
            ASSIGN 
                v-testkitID = TXTcher.slot2
                v-test_seq  = x.
        
        IF i-test_type = "" THEN DO:
                
            ASSIGN i-test_typeholder = SUBSTRING (v-testkitID,1,INDEX(v-testkitID,"-") - 1).
        
            FIND FIRST test_mstr WHERE
                test_mstr.test_type = i-test_typeholder NO-LOCK NO-ERROR.
                
            IF AVAILABLE (test_mstr) THEN ASSIGN i-test_type = test_mstr.test_type.    
        
           /* IF i-test_typeholder MATCHES "*FM*" THEN
                i-test_type = "FM".
            ELSE IF i-test_typeholder MATCHES "*HE*" THEN
                i-test_type = "HE".
            ELSE IF i-test_typeholder MATCHES "*UAA*" THEN
                i-test_type = "UAA".
            ELSE IF i-test_typeholder MATCHES "*UTM UEE*" THEN
                i-test_type = "UTEE".
            ELSE IF i-test_typeholder MATCHES "*UTM-UEE*" THEN
                i-test_type = "UTEE".    
            ELSE IF i-test_typeholder MATCHES "*UTM*" THEN 
                i-test_type = "UTM". 
            ELSE IF i-test_typeholder MATCHES "*UTEE*" THEN 
                i-test_type = "UTEE".
            ELSE IF i-test_typeholder MATCHES "*UTMUEE*" THEN 
                i-test_type = "UTEE".       */    
            
        END. /**** end of i-test_type = "" ***/    

    /****** End of TK_ID Finding Stuff | Start of DOB finding stuff *******/
    
       /* MESSAGE 
                "About to Find patient DOB" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK. */
    
        FIND FIRST TXTcher WHERE 
            TXTcher.slot1 = "patient dob" AND  
            TXTcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (TXTcher) THEN DO:
        
            IF TXTcher.slot2 = "" THEN DO: 

                ASSIGN 
                i-firstname     = o-firstname
                i-lastname      = o-lastname
                i-lab-sampleID  = v-lab-sampleID
                o-fpat-exist    = NO
                i-test_seq      = v-test_seq
                i-testkitID     = v-testkitID
                .
                
                {DL-DDIwalkExport.i 8000 "patient DOB blank in source file" "Error"}.  
                {DL-DDIcatchall.i}
                LEAVE maine-loop. 
                              
            END. /*** of the DOB being blank in the TXT file ***/
            
            ELSE ASSIGN v-DOB-progress = DATE(TXTcher.slot2).
        
        END.
        
        ELSE DO: 
        
            ASSIGN   /**** so that the catchall.i works properly **/
                i-firstname     = o-firstname
                i-lastname      = o-lastname
                i-lab-sampleID  = v-lab-sampleID
                o-fpat-exist    = NO
                i-test_seq      = v-test_seq
                i-testkitID     = v-testkitID.
        
            {DL-DDIwalkExport.i 8 "patient DOB unavailable in source file" "Error"}. 
            {DL-DDIcatchall.i}
            LEAVE maine-loop.
        END.
  
    /***** End of DOB Finding Stuff | Start of Test Age Finding stuff ********/
    
         /* MESSAGE 
                "About to Find patient age" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK. */
    
        FIND FIRST TXTcher WHERE 
            TXTcher.slot1 = "patient age" AND  
            TXTcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (TXTcher) THEN ASSIGN v-testage = DECIMAL(TXTcher.slot2).     
    
    /***** End of Test Age Finding Stuff | Start of the Three Date Finds *******/
    
         /* MESSAGE 
                "About to Find date collected" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK.*/
                            
        FIND FIRST TXTcher WHERE 
            TXTcher.slot1 = "date collected" AND  
            TXTcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (TXTcher) THEN ASSIGN i-date-col = DATE(TXTcher.slot2). 
        
        /*  MESSAGE 
                "About to Find date received" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK. */
        
        FIND FIRST TXTcher WHERE 
            TXTcher.slot1 = "date received" AND  
            TXTcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (TXTcher) THEN ASSIGN i-date-rec = DATE(TXTcher.slot2). 
        
        /* MESSAGE 
                "About to Find date completed" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK. */
        
        FIND FIRST TXTcher WHERE 
            TXTcher.slot1 = "date completed" AND  
            TXTcher.lab-seq = STRING (x) NO-LOCK NO-ERROR.
            
        IF AVAILABLE (TXTcher) THEN ASSIGN i-date-comp = DATE(TXTcher.slot2). 
        
        ASSIGN err-number = 9.

          /*  MESSAGE 
                "About to EXPORT error 9" SKIP
                "v-lab-sampleID = " v-lab-sampleID SKIP
                "v-test_seq = " v-test_seq SKIP
                "v-lab-seq = " v-lab-seq SKIP
                "x = " x SKIP 
                    VIEW-AS ALERt-BOX BUTTONS OK. */

        EXPORT STREAM to-error DELIMITER ";"
            i-filelocation 
            i-TXTvsPDF 
            i-pat-lastname 
            i-pat-firstname 
            o-lastname
            o-firstname
            v-testkitID
            v-test_seq  
            i-test_type 
            v-DOB-progress
            v-lab-sampleID
            x /*** actually the lab seq ***/
            i-createdate
            "Info"
            err-number
            "Reached End of DDItxtwalk, proceeding with DDIverifier".

        
     /*   MESSAGE 
            "Pre-run: Text Verifier" SKIP
            "v-lab-sampleID = " v-lab-sampleID SKIP
            "v-test_seq = " v-test_seq SKIP
            "v-lab-seq = " v-lab-seq SKIP
            "x = " x 
            SKIP VIEW-AS ALERt-BOX BUTTONS OK. */
       
        OUTPUT STREAM to-error CLOSE.
        
        RUN VALUE(SEARCH("DL-DDIverifier.p"))
            (i-filelocation,
            i-TXTvsPDF,  
            i-pat-lastname,
            i-pat-firstname,  
            v-testkitID,
            v-test_seq,
            i-test_type,
            v-DOB-progress, 
            v-testage,
            v-lab-sampleID,
            /* v-lab-seq, */
            x,
            i-date-col,
            i-date-rec,
            i-date-comp, 
            i-createdate, 
            logloion,
            i-updatemode, 
            OUTPUT v-whathappened).
      
        OUTPUT STREAM to-error TO VALUE(logloion) APPEND.
      
        /* MESSAGE 
            "Post-run: Text Verifier" SKIP
            "v-lab-sampleID = " v-lab-sampleID SKIP
            "v-test_seq = " v-test_seq SKIP
            "v-lab-seq = " v-lab-seq SKIP
            "x = " x 
            SKIP VIEW-AS ALERt-BOX BUTTONS OK. */

        
    END. /****** End of Verifiion Loop ******/
        
END. /*** end of else do ***/
    
