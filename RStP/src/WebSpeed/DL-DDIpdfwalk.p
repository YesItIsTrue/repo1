
/*------------------------------------------------------------------------
    File        : DL-DDIpdfwalk.p

    Purpose     : To run Dwight's PDF reader on the PDF's in the DDI directory that 
                have no matching text file and pull the useful data out of the header 
                of each file.

    Author(s)   : Trae Luttrell
    Created     : Wed Oct 14 14:49:36 EDT 2015
    Updated     : Wed Oct 14 14:49:36 EDT 2015
    Version     : 1.0
    Notes       : 
                    
  ----------------------------------------------------------------------*/
  
/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW. 

DEFINE VARIABLE v-testkitID     AS CHARACTER FORMAT "x(12)" NO-UNDO.
DEFINE VARIABLE v-DOB-progress  LIKE people_mstr.people_DOB NO-UNDO.
DEFINE VARIABLE v-lab-sampleID  LIKE TK_mstr.TK_lab_sample_ID NO-UNDO.
DEFINE VARIABLE v-lab-seq       LIKE TK_mstr.TK_lab_seq INITIAL 1 NO-UNDO.
DEFINE VARIABLE i-test_typeholder AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-nameholder    AS CHARACTER NO-UNDO. /*** name holder for no cross-contamination ***/
DEFINE VARIABLE v-test_seq      LIKE TK_mstr.TK_test_seq NO-UNDO.
DEFINE VARIABLE x               AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ITmessages    AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE gender          AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-age-holder    AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-test-age      LIKE TK_mstr.TK_test_age NO-UNDO.
DEFINE VARIABLE v-trh-COLLECTED  AS DATE NO-UNDO.
DEFINE VARIABLE v-trh-LAB-RCVD   AS DATE NO-UNDO.
DEFINE VARIABLE v-trh-LAB-PROCESS AS DATE NO-UNDO.
DEFINE VARIABLE v-tk-patient-id LIKE TK_mstr.TK_patient_ID NO-UNDO.
DEFINE VARIABLE i-lab-sampleID LIKE TK_mstr.TK_lab_sample_ID NO-UNDO.
DEFINE VARIABLE export-filelocation AS CHARACTER NO-UNDO.

DEFINE TEMP-TABLE PDFcatcher  
    FIELD slot1 AS CHARACTER FORMAT "x(40)"
    FIELD slot2 AS CHARACTER FORMAT "x(40)"
    FIELD slot3 AS CHARACTER
    FIELD slot4 AS CHARACTER
        INDEX main-index AS PRIMARY slot1.

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

/*****  input / output parmeters  *****/ 
DEFINE INPUT PARAMETER v-filename       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-filelocation   AS CHARACTER FORMAT "x(90)" NO-UNDO.
DEFINE INPUT PARAMETER i-pat-lastname   LIKE people_mstr.people_lastname NO-UNDO.
DEFINE INPUT PARAMETER i-pat-firstname  LIKE people_mstr.people_firstname NO-UNDO.
DEFINE INPUT PARAMETER i-test_type       LIKE TK_mstr.TK_test_type NO-UNDO.
DEFINE INPUT PARAMETER i-createdate     AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-TXTvsPDF       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER loglocation      AS CHARACTER NO-UNDO. /*** location of the outbound log ***/
DEFINE INPUT PARAMETER updatemode       AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER err-number      AS INTEGER NO-UNDO. /* 0 = didn't run, # = the # of the error, 99 = successfully ran. */

DEFINE VARIABLE err-message AS CHARACTER NO-UNDO.

DEFINE VARIABLE c-import AS INTEGER NO-UNDO.
DEFINE VARIABLE v-whathappened  AS CHARACTER NO-UNDO. 
DEFINE VARIABLE whatfile AS CHARACTER NO-UNDO. 
    ASSIGN whatfile = "~"" + i-filelocation + "~"".

/****** variables for the new PDF ripper *******/
DEFINE VARIABLE cmdname AS CHARACTER INITIAL "C:\OpenEdge\workspace\RStP\pdftotext.exe" NO-UNDO.
/*DEFINE VARIABLE cmdname AS CHARACTER INITIAL "P:\OpenEdge\TEST\RStP\pdftotext.exe" NO-UNDO.*/
DEFINE VARIABLE cmdparam AS CHARACTER INITIAL "-raw" NO-UNDO.
DEFINE VARIABLE cmdfileaddress AS CHARACTER NO-UNDO.
    ASSIGN cmdfileaddress = "~"" + i-filelocation + "~"".
DEFINE VARIABLE cmdtextdest AS CHARACTER INITIAL "C:\PROGRESS\WRK\PDFripper2.txt" NO-UNDO.
/*DEFINE VARIABLE c-import AS INTEGER NO-UNDO.*/
DEFINE VARIABLE pdf2lastname LIKE people_mstr.people_lastname NO-UNDO.
DEFINE VARIABLE pdf2firstname LIKE people_mstr.people_firstname NO-UNDO.
DEFINE VARIABLE pdf2test_type LIKE TK_mstr.TK_test_type NO-UNDO.
DEFINE VARIABLE zero-holder AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE c-patientslot AS INTEGER NO-UNDO.
/*DEFINE VARIABLE v-nameholder    AS CHARACTER NO-UNDO. /*** name holder for no cross-contamination ***/*/
DEFINE TEMP-TABLE PDFcatcher2 NO-UNDO
    FIELD slot1 AS CHARACTER FORMAT "x(40)" 
    FIELD slot2 AS CHARACTER FORMAT "x(40)"
    FIELD slot3 AS CHARACTER
    FIELD slot4 AS CHARACTER
    FIELD slot5 AS CHARACTER 
    FIELD slot6 AS CHARACTER 
    FIELD slot7 AS CHARACTER
    FIELD slot8 AS CHARACTER
    FIELD linenumber AS INTEGER
        INDEX main-index AS PRIMARY UNIQUE linenumber
        INDEX pdf2-slot1-idx slot1.

DEFINE VARIABLE PdfHasAName AS LOGICAL INITIAL NO NO-UNDO.

/*****  Streams  *****/
DEFINE STREAM to-error.
OUTPUT STREAM to-error TO VALUE(loglocation) APPEND.

DEFINE STREAM pdfrip2. 

/* this would be a great spot to assign the imported variables to the regular ones. or just replace the regular ones with the imported ones */

/********************************  Start Importing Routine  *************************/

/*INPUT THROUGH P:\OpenEdge\TEST\RStP\pdfext VALUE(whatfile).*/
INPUT THROUGH C:\OpenEdge\workspace\RStP\pdfext VALUE(whatfile).

    StraightImport: 
    REPEAT:
        
        CREATE PDFcatcher.
        
        IMPORT DELIMITER ":" PDFcatcher NO-ERROR.
         
        ASSIGN c-import = c-import + 1.

    END. /** StraightImport **/ 
    
INPUT CLOSE. 
 
IF c-import = 0 THEN DO: {DL-DDIwalkExport.i 2000 "Nothing was imported from the PDF file" "Error"}. END.
 
ELSE PDFgrabLoop: DO: 

    ASSIGN c-import = 0.
                   
    SecondTry:
    DO:

        OS-COMMAND SILENT
            VALUE(cmdname)
            VALUE(cmdparam) 
            VALUE(cmdfileaddress)
            VALUE(cmdtextdest).
                
        INPUT STREAM pdfrip2 FROM VALUE(cmdtextdest).
             
        StraightImport2: 
        REPEAT:
 
            CREATE PDFcatcher2.
            
            ASSIGN 
                c-import = c-import + 1
                PDFcatcher2.linenumber = c-import.
                
            IMPORT STREAM pdfrip2 DELIMITER ":" PDFcatcher2 NO-ERROR. 

        END. /** StraightImport2 **/     

        INPUT STREAM pdfrip2 CLOSE.
    
        FIND FIRST pdfcatcher2 NO-LOCK NO-ERROR.
        
        IF AVAILABLE (pdfcatcher2) THEN DO:
      
            IF PDFcatcher2.slot1 = "Order Number" THEN DO: /*** Genova Path ***/
            
                {DL-DDIwalkexport.i 2201 "PDFr2: Genova Style" "Error"}.
                {DL-DDIcatchallPDFwalk.i}. 
                LEAVE PDFgrabloop.
            
            END. /*** Genova path ***/
       
            IF PDFcatcher2.slot1 = "URINE AMINO ACIDS" THEN DO: /*** Genova Path ***/
            
                IF i-test_type = "" THEN ASSIGN i-test_type = "UAA".
                
                {DL-DDIwalkexport.i 2203 "PDFr2: Urine Amino Acids Test" "Info"}.
            
            END. /*** Genova path ***/
       
        END. /*** of "what is in the first spot of the PDF ripper?" ***/
                   
        FIND FIRST PDFcatcher2 WHERE 
        PDFcatcher2.slot1 = "Patient"
        NO-LOCK NO-ERROR.
    
        IF AVAILABLE (PDFcatcher2) THEN DO:
            
            IF PDFcatcher2.slot2 <> "" THEN DO:
            
                ASSIGN 
                    PdfHasAName = YES
                    v-nameholder = PDFcatcher2.slot2
                    o-firstname = ""
                    o-lastname = "".
         
                RUN VALUE (SEARCH("SUB-UnString-Name.r")) 
                (v-nameholder,
                 v-ITmessages,        /* logical NO or YES. A YES displays the results at the end of this program. */
                 OUTPUT o-prefix,
                 OUTPUT o-firstname,
                 OUTPUT o-middlename,
                 OUTPUT o-lastname, 
                 OUTPUT o-suffix, 
                 OUTPUT o-title_desc,
                 OUTPUT o-prefname,
                 OUTPUT o-gender,
                 OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
                 OUTPUT o-field-in-error) .
                
                {DL-DDIwalkExport.i 2299 "PDFr2: Found the name with PDFripper2!" "Info"}.    
    
            END. /*** Patient name actually has data ***/
            
            ELSE DO: 
                {DL-DDIwalkExport.i 2202 "PDFr2: Patient Name blank in source file!" "Error"}.
                {DL-DDIcatchallPDFwalk.i}.
                LEAVE PDFgrabloop.
            END.
    
        END. /*** patient name 4ea ****/
     
    END. /*** of second try ***/

/*******  Start of Name Finding Stuff  ******/      
    FIND PDFcatcher WHERE PDFcatcher.slot1 = "Name" NO-LOCK NO-ERROR.
            
    IF AVAILABLE (PDFcatcher) THEN DO:

        ASSIGN 
            PdfHasAName     = YES
            v-nameholder    = PDFcatcher.slot2.
             
        RUN VALUE (SEARCH("SUB-UnString-Name.r")) 
        (v-nameholder,
         v-ITmessages,        /* logical NO or YES. A YES displays the results at the end of this program. */
         OUTPUT o-prefix,
         OUTPUT o-firstname,  
         OUTPUT o-middlename,
         OUTPUT o-lastname,
         OUTPUT o-suffix, 
         OUTPUT o-title_desc,
         OUTPUT o-prefname,
         OUTPUT o-gender,
         OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
         OUTPUT o-field-in-error) .
         
    END. /*** of if available name **/

/*    MESSAGE "PdfHasAName = " PdfHasAName VIEW-AS ALERT-BOX BUTTONS OK.*/

    IF PdfHasAName = YES THEN DO:
    
/****** Start of the 3 date grabs *******/

        FIND FIRST PDFcatcher WHERE 
            PDFcatcher.slot1 = "Date Collected" NO-LOCK NO-ERROR.
        
        IF AVAILABLE (PDFcatcher) THEN DO:
            
            ASSIGN v-trh-COLLECTED = DATE(pdfcatcher.slot2) NO-ERROR.
        
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                          
            
                ASSIGN v-trh-COLLECTED = ?.
            
                RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (pdfcatcher.slot2, OUTPUT v-trh-COLLECTED).
            
                IF v-trh-collected = ? THEN DO: {DL-DDIwalkExport.i 220 "Date Collected formatted incorrectly in PDF file" "Warning"}. END.
                
                ELSE DO: {DL-DDIwalkExport.i 221 "Date Collected found in PDF file" "Info"}. END.
      
            END.  /** Not formatted like PROGRESS **/                   
        
            ELSE DO: {DL-DDIwalkExport.i 222 "Date Collected formatted correctly in PDF file" "Info"}. END.
        
        END.   /**** if slot one = "Date Collected" ****/
        
        ELSE DO: {DL-DDIwalkExport.i 223 "Date Collected unavailable in PDF file" "Warning"}. END.
        
        FIND FIRST PDFcatcher WHERE 
            PDFcatcher.slot1 = "Date Received" NO-LOCK NO-ERROR.
        
        IF AVAILABLE (PDFcatcher) THEN DO:
            
            ASSIGN v-trh-LAB-RCVD = DATE(pdfcatcher.slot2) NO-ERROR.
        
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                          
            
                ASSIGN v-trh-LAB-RCVD = ?.
            
                RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (pdfcatcher.slot2, OUTPUT v-trh-COLLECTED).
            
                IF v-trh-LAB-RCVD = ? THEN DO: {DL-DDIwalkExport.i 230 "Date LAB-RCVD formatted incorrectly in PDF file" "Warning"}. END.
                
                ELSE DO: {DL-DDIwalkExport.i 231 "LAB-RCVD found in PDF file" "Info"}. END.
      
            END.  /** Not formatted like PROGRESS **/                   
        
            ELSE DO: {DL-DDIwalkExport.i 232 "LAB-RCVD formatted correctly in PDF file" "Info"}. END.
        
        END.   /**** if slot one = "Date Received" ****/
        
        ELSE DO: {DL-DDIwalkExport.i 233 "Date Collected unavailable in PDF file" "Warning"}. END.

        FIND FIRST PDFcatcher WHERE 
            PDFcatcher.slot1 = "Date Completed" NO-LOCK NO-ERROR.
        
        IF AVAILABLE (PDFcatcher) THEN DO:

            ASSIGN v-trh-LAB-PROCESS = DATE(pdfcatcher.slot2).
        
            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                          
            
                ASSIGN v-trh-LAB-PROCESS = ?.
            
                RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (pdfcatcher.slot2, OUTPUT v-trh-LAB-PROCESS).
            
                IF v-trh-LAB-PROCESS = ? THEN DO: {DL-DDIwalkExport.i 240 "Date LAB-PROCESS formatted incorrectly in PDF file" "Warning"}. END.
                
                ELSE DO: {DL-DDIwalkExport.i 241 "LAB-PROCESS found in PDF file" "Info"}. END.
      
            END.  /** Not formatted like PROGRESS **/                   
        
            ELSE DO: {DL-DDIwalkExport.i 242 "LAB-PROCESS formatted correctly in PDF file" "Info"}. END.
        
        END.   /**** if slot one = "Date Completed" ****/
        
        ELSE DO: {DL-DDIwalkExport.i 243 "Date Completed unavailable in PDF file" "Warning"}. END.
    
    /******  Start of Lab Sample ID finding stuff  ******/
    
        FIND FIRST PDFcatcher WHERE    
            PDFcatcher.slot1 = "Lab" NO-LOCK NO-ERROR.
            
        IF AVAILABLE (PDFcatcher) THEN DO: 
        
            ASSIGN v-lab-sampleID = PDFcatcher.slot2.
            
/*            MESSAGE PDFcatcher.slot1 PDFcatcher.slot2 VIEW-AS ALERT-BOX BUTTONS OK.*/
    
        END. /*** PDFcatcher.slot1 = "Lab" ***/
    
        ELSE DO:  
            {DL-DDIwalkExport.i 250 "Lab sample ID unavailable in PDF file" "Error"}. 
            {DL-DDIcatchallPDFwalk.i}. 
            LEAVE PDFgrabloop.
        END.   /*** ELse of PDFcatcher.slot1 = "Lab" ***/
        
    /******* Start of gender grab *********/   
        
        FIND FIRST PDFcatcher WHERE PDFcatcher.slot1 = "Gender" NO-LOCK NO-ERROR.
        
        IF AVAILABLE (PDFcatcher) THEN DO:
                
            IF PDFcatcher.slot2 = "Male" THEN 
                ASSIGN o-gender = YES.
            
            ELSE IF PDFcatcher.slot2 = "Female" THEN 
                ASSIGN o-gender = NO.
           
        END. /** avail gender **/
        
        ELSE DO: {DL-DDIwalkExport.i 260 "Gender unavailable in PDF file" "Warning"}. END.
    
    /******* Age stuff .... *****/
    
        FIND FIRST PDFcatcher WHERE PDFcatcher.slot1 = "Age" NO-LOCK NO-ERROR.
        
        IF AVAILABLE (PDFcatcher) THEN DO:
            
            ASSIGN v-age-holder = DECIMAL(PDFcatcher.slot2).
            
        END. /*** available age ***/   
        
    END. /*** of PdfHasAName = YES ***/
    
    ELSE DO: /*** PDFhasaName = No ***/
        
        {DL-DDIwalkExport.i 301 "Invalid PDF." "Error"}.
        {DL-DDIcatchallPDFwalk.i}.
        LEAVE PDFgrabloop.
    
    END.    /*** name is still blank. ***/  

    IF PDFhasaName = YES THEN DO:   
        
        IF o-firstname <> "" AND i-pat-firstname <> "" AND o-firstname <> i-pat-firstname THEN DO:
            {DL-DDIwalkExport.i 280 "First name in PDF does not match folder first name" "Error"}.
            {DL-DDIcatchallPDFwalk.i}. 
            LEAVE PDFgrabloop. 
        END.
         
        IF o-lastname <> "" AND i-pat-lastname <> "" AND o-lastname <> i-pat-lastname THEN DO:
            {DL-DDIwalkExport.i 290 "Last name in PDF does not match folder last name" "Error"}. 
            {DL-DDIcatchallPDFwalk.i}. 
            LEAVE PDFgrabloop.  
        END.


/*****************************************************  END of Secondary PDFwalk  *********************************************/ 
            
        FIND FIRST TK_mstr WHERE
            TK_mstr.TK_deleted = ? AND 
            (TK_mstr.TK_lab_sample_ID = v-lab-sampleID  AND v-lab-sampleID <> "") AND 
            (TK_mstr.TK_test_type = i-test_type AND i-test_type <> "") 
         NO-LOCK NO-ERROR.
         
        IF AVAILABLE (TK_mstr) THEN DO:
        
            DO: {DL-DDIwalkExport.i 909 "PDF: TK_mstr found with Test TYpe" "Info"}. END. 
         
            ASSIGN 
                v-tk-patient-id = TK_mstr.TK_patient_ID
                v-test_seq = TK_mstr.TK_test_seq
                v-testkitID = TK_mstr.TK_ID.
         
            IF TK_mstr.TK_patient_ID <> 0 THEN DO:
                     
                FIND people_mstr WHERE 
                     people_mstr.people_id = TK_mstr.TK_patient_ID AND 
                     people_mstr.people_deleted = ? NO-LOCK NO-ERROR.
                     
                IF AVAILABLE people_mstr THEN DO:

                     ASSIGN v-DOB-progress = people_mstr.people_DOB.   
                     /*** i can't know for sure if this person is a patient becuase I didn't check it and you can't trust the TK_patient_id ***/
                     
                     DO: {DL-DDIwalkExport.i 966 "PDF: DOB found" "Info"}. END.
                     
                END. /*** people_mstr available ***/
                                 
            END. /*** TK_patient_ID available ***/
         
            IF TK_mstr.TK_test_age <> 0 AND  v-age-holder <> 0 THEN DO:
            
                IF TK_mstr.TK_test_age >= (v-age-holder - 1) AND TK_mstr.TK_test_age <= (v-age-holder + 1) THEN DO:
           
                    DO: {DL-DDIwalkExport.i 967 "PDF: Test Ages are within 1 year" "Info"}. END.
                
                END. /*** within a year of the age ***/
   
                ELSE DO: 
                    {DL-DDIwalkExport.i 968 "PDF: Test Ages are more than a year apart" "Error"}.
                    {DL-DDIcatchallPDFwalk.i}. 
                    LEAVE PDFgrabloop.
                END.
   
            END. /*** there is stuff in the test age stuff ***/

            ELSE DO: {DL-DDIwalkExport.i 969 "PDF: Test Ages are blank" "Info"}. END.

        END. /*** available tk_mstr ***/
       
        {DL-DDIwalkExport.i 399 "Reached End of DDIpdfwalk, proceeding with DDIverifierPDF" "Info"}.
        
        OUTPUT STREAM to-error CLOSE.
        
        RUN VALUE(SEARCH("DL-DDIverifierPDF.p"))
            (v-filename,
            i-filelocation,  
            i-TXTvsPDF,
            i-pat-lastname,
            i-pat-firstname, 
            o-lastname,
            o-firstname,
            v-testkitID,
            v-test_seq,    
            i-test_type,
            v-DOB-progress,
            v-lab-sampleID,
            v-lab-seq, 
            i-createdate,
            v-trh-COLLECTED,
            v-trh-LAB-RCVD,
            v-trh-LAB-PROCESS,
            loglocation,
            updatemode, 
            OUTPUT v-whathappened) .

    END.

END.
    
