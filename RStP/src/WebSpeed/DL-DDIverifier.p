
/*------------------------------------------------------------------------
    File        : DL-NDDIverifier.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Trae Luttrell
    Created     : Tue Feb 09 14:27:58 EST 2016
    Notes       :
    
    
    ------------------------------------------------------------------
    Revision History:
    -----------------
    1.0 - written by TRAE LUTTRELL on 09/Feb/16.  No telling if this was
            really the original version or not.  Many a hoop has passed.
            
    1.1 - written by DOUG LUTTRELL on 02/Apr/16.  Updated the parameters
            being passed to the SUBtkmstrRSTPucU.p program to match with
            the current (11.1) version of the code.  Also put some numbers
            down the side of the parameter list to help keep track of 
            which field is which.  Marked by SUBtkmstr I guess.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
 
DEFINE INPUT PARAMETER i-filelocation   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-TXTvsPDF       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-lastname       LIKE people_mstr.people_lastname NO-UNDO.
DEFINE INPUT PARAMETER i-firstname      LIKE people_mstr.people_firstname NO-UNDO.
DEFINE INPUT PARAMETER i-testkitID      LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE INPUT PARAMETER i-test_seq       LIKE TK_mstr.TK_test_seq NO-UNDO.
DEFINE INPUT PARAMETER i-test_type      LIKE TK_mstr.TK_test_type NO-UNDO.            
DEFINE INPUT PARAMETER i-DOB-progress   LIKE people_mstr.people_DOB NO-UNDO.
DEFINE INPUT PARAMETER i-test_age       LIKE TK_mstr.TK_test_age NO-UNDO.
DEFINE INPUT PARAMETER i-lab-sampleID   LIKE TK_mstr.TK_lab_sample_ID NO-UNDO.
DEFINE INPUT PARAMETER i-lab-seq        LIKE TK_mstr.TK_lab_seq NO-UNDO.
DEFINE INPUT PARAMETER i-date-col       AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-date-rec       AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-date-comp      AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-createdate     AS DATE NO-UNDO.
DEFINE INPUT PARAMETER i-loglocation    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-updatemode     AS LOGICAL NO-UNDO.

DEFINE OUTPUT PARAMETER o-whathappened  AS CHARACTER NO-UNDO.

DEFINE VARIABLE x AS INTEGER NO-UNDO.    
DEFINE VARIABLE err-number AS INTEGER NO-UNDO.
DEFINE VARIABLE err-message AS CHARACTER NO-UNDO.
DEFINE VARIABLE iAMpatient AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-create-date AS DATE NO-UNDO.
DEFINE VARIABLE v-mod-date AS DATE NO-UNDO.
DEFINE VARIABLE v-TKstat AS CHARACTER NO-UNDO.
DEFINE VARIABLE lazydate AS DATE NO-UNDO. 
DEFINE VARIABLE v-trhid AS INTEGER NO-UNDO. 
DEFINE VARIABLE v-trhfound AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-trhid-new AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-error AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-att_filename AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-att_filepath AS CHARACTER NO-UNDO.
DEFINE VARIABLE export-filelocation AS CHARACTER NO-UNDO.
DEFINE VARIABLE statlist AS CHARACTER 
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,BURNED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO.


DEFINE VARIABLE amIaPatient AS LOGICAL INITIAL NO NO-UNDO. /*** the flag to see if the people and patient mstr's are correct ***/
DEFINE VARIABLE amItkWorthy AS LOGICAL INITIAL NO NO-UNDO. /*** the flag to see if all thing TK_mstr related are correct ***/
DEFINE VARIABLE amIattached AS LOGICAL INITIAL NO NO-UNDO. /*** the flag to see if the Attached Files table is correct ***/
DEFINE VARIABLE NeedApproval AS LOGICAL INITIAL NO NO-UNDO.

DEFINE STREAM to-error.
OUTPUT STREAM to-error TO VALUE(i-loglocation) APPEND.

DEFINE VARIABLE c-import        AS INTEGER NO-UNDO. /** counter for the imports ****/
DEFINE VARIABLE v-attpeopleID   LIKE att_files.att_value5 NO-UNDO.
DEFINE VARIABLE v-attIDint      AS INTEGER NO-UNDO.  
DEFINE VARIABLE v-fullIDint     AS INTEGER NO-UNDO. 
DEFINE VARIABLE v-fullpath-ID   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-test_typeholder AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-charholder    AS CHARACTER NO-UNDO. /*** character holder for clean substrings ***/
DEFINE VARIABLE v-nameholder    AS CHARACTER NO-UNDO. /*** name holder for no cross-contamination ***/
DEFINE VARIABLE v-peopholder    AS CHARACTER NO-UNDO. /*** people holder, once again to have strings be happy ***/

DEFINE VARIABLE v-tk_patient_id LIKE TK_mstr.TK_patient_ID NO-UNDO.    
DEFINE VARIABLE v-last-lab-seq AS INTEGER NO-UNDO. /** 1|2|3 **/

DEFINE VARIABLE v-test_family LIKE test_mstr.test_family NO-UNDO.
    
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

/*** Outputs for Harold's SUB-Unstring-Name.p ***/
DEFINE VARIABLE o-prefix            AS CHARACTER NO-UNDO.
/*DEFINE VARIABLE o-firstname         AS CHARACTER NO-UNDO.*/
DEFINE VARIABLE o-middlename        AS CHARACTER NO-UNDO.
/*DEFINE VARIABLE o-lastname          AS CHARACTER NO-UNDO.*/
DEFINE VARIABLE o-suffix            AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-title_desc        AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-prefname          AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-gender            AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-unstring-error    AS LOGICAL NO-UNDO.        /*  YES = errors / NO = no errors. */
DEFINE VARIABLE o-field-in-error    AS CHARACTER NO-UNDO.      /*  Field input name in error, if any. */

/*** Outputs for TK_ucU ***/
DEFINE VARIABLE o-uctkm-id          AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-uctkm-create      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-uctkm-update      AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-uctkm-avail       AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-uctkm-successful  AS LOGICAL NO-UNDO.

DEFINE VARIABLE i-orig-testkitID LIKE i-testkitID NO-UNDO.
    ASSIGN i-orig-testkitID = i-testkitID.
DEFINE VARIABLE i-orig-test_seq LIKE i-test_seq NO-UNDO.
    ASSIGN i-orig-test_seq = i-test_seq.

/* ***************************  Main Block  *************************** */
/* IF i-lab-sampleid = "U130717-2147-1" THEN */
/*IF i-testkitid = "8263" THEN                         */
/*   MESSAGE                                           */
/*        "Start of DL-DDIverifier.p (TXT)" SKIP       */
/*        "i-filelocation = " i-filelocation SKIP      */
/*        "i-lab-sampleID = " i-lab-sampleID SKIP      */
/*        "i-lab-seq = "      i-lab-seq SKIP           */
/*        "x = "              x SKIP                   */
/*        "i-testkitid = "    i-testkitid SKIP         */
/*        "i-test_seq = "     i-test_seq SKIP          */
/*            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/

IF i-lab-seq = 0 THEN ASSIGN i-lab-seq = 1.

ASSIGN x = i-lab-seq.

verification-loop:
DO:

    ASSIGN 
        amIaPatient = NO 
        amItkWorthy = NO
        amIattached = NO
        NeedApproval = NO.   
    
    IF i-DOB-progress <> ? THEN DO:
        
/*        IF i-testkitid = "8263" THEN                         */
/*           MESSAGE                                           */
/*                "Just before RUN pat find" SKIP              */
/*                "i-filelocation = " i-filelocation SKIP      */
/*                "i-lab-sampleID = " i-lab-sampleID SKIP      */
/*                "i-lab-seq = "      i-lab-seq SKIP           */
/*                "x = "              x SKIP                   */
/*                "i-testkitid = "    i-testkitid SKIP         */
/*                "i-test_seq = "     i-test_seq SKIP          */
/*                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.*/
    
        RUN VALUE (SEARCH("SUBpat-findR.r")) 
            (o-prefix,
            i-firstname,
            o-middlename, 
            i-lastname,
            o-suffix,
            i-DOB-progress,
            OUTPUT v-peopleID,
            OUTPUT v-addrID,
            OUTPUT o-fpat-exist,
            OUTPUT o-fpat-ran,
            OUTPUT o-fpat-error).
    
       IF i-testkitid = "8263" THEN 
           MESSAGE 
                "Just after RUN pat find" SKIP
                "i-filelocation = " i-filelocation SKIP
                "i-lab-sampleID = " i-lab-sampleID SKIP
                "i-lab-seq = "      i-lab-seq SKIP
                "x = "              x SKIP
                "i-testkitid = "    i-testkitid SKIP
                "i-test_seq = "     i-test_seq SKIP
                "o-fpat-exist = "   o-fpat-exist
                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
        IF o-fpat-exist = YES THEN DO:

            ASSIGN amIaPatient = YES.

        END. /*** Patient ***/
            
        ELSE IF o-fpat-exist = NO AND o-fpat-ran = YES AND o-fpat-error = NO THEN DO: 
        
            FIND people_mstr WHERE 
                    people_mstr.people_id = v-peopleID 
                    AND people_mstr.people_deleted = ? NO-LOCK NO-ERROR.
                    
            IF AVAILABLE (people_mstr) THEN DO:
  
                ASSIGN amIaPatient = YES.
    
                IF i-updatemode = YES THEN DO:
                
                    RUN VALUE(SEARCH("SUBpat-ucU.r")) 
                        (people_mstr.people_id, /* patient_mstr.patient_id */
                        "",                     /* patient_mstr.patient_notes */
                        people_mstr.people_id,  /* responsible party */
                        0,                      /* doctor_id */
                        0,                      /* cust_id */
                        ?,                      /* patient_verified */
                        OUTPUT v-peopleID,
                        OUTPUT o-ucpatient-create,
                        OUTPUT o-ucpatient-update,
                        OUTPUT o-ucpatient-error,
                        OUTPUT o-ucpatient-successful).                                             
                        
                    IF o-ucpatient-successful = NO THEN DO:
                     
                        amIaPatient = NO.
                        
                    END. /*** patient creation succeeded ***/ 
    
                END. /*** of update mode ***/
           
            END. /*** People Master Available ***/
        
        END. /*** Non-Patient path ***/
        
    END. /*** DOB <> ? ***/
    
   /* MESSAGE "End of Patient Section" SKIP
        "i-filelocation = " i-filelocation SKIP
        "amIaPatient = " amIaPatient SKIP
        VIEW-AS ALERT-BOX BUTTONS OK.  */
    
    /*** insert TK_mstr stuff ***/
    IF i-testkitID <> "" THEN DO:
    
        FIND TK_mstr WHERE    
            TK_mstr.TK_deleted = ? AND
            TK_mstr.TK_id = i-testkitID AND
            TK_mstr.TK_test_seq = i-test_seq
            EXCLUSIVE-LOCK NO-ERROR. 
            
        IF AVAILABLE (tk_mstr) THEN DO: 
       
            IF TK_mstr.TK_test_type <> "" OR i-test_type <> "" THEN DO:  /*** does it have a Test type? ***/
        
                ASSIGN amItkWorthy = YES.
            
                IF TK_mstr.TK_test_type <> "" AND TK_mstr.TK_test_type <> i-test_type THEN 
                    ASSIGN i-test_seq = i-test_seq + 100.
        
                IF i-test_type = "" THEN ASSIGN i-test_type = TK_mstr.TK_test_type. 
        
/*                IF i-testkitid = "8263" THEN                               */
/*                   MESSAGE                                                 */
/*                        "tk_test_seq and i-test_type adjustment" SKIP      */
/*                        "i-lab-sampleID = " i-lab-sampleID SKIP            */
/*                        "i-testkitid = "    i-testkitid SKIP               */
/*                        "i-test_seq = "     i-test_seq SKIP                */
/*                        "i-test_type = "    i-test_type SKIP               */
/*                        "TK_mstr.TK_test_type = " TK_mstr.TK_test_type SKIP*/
/*                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.      */
        
                IF i-updatemode = YES THEN DO:
               
/*                     IF i-testkitid = "8263" THEN                              */
/*                       MESSAGE                                                 */
/*                            "Inside updatemode" SKIP                           */
/*                            "i-lab-sampleID = " i-lab-sampleID SKIP            */
/*                            "i-testkitid = "    i-testkitid SKIP               */
/*                            "i-test_seq = "     i-test_seq SKIP                */
/*                            "i-test_type = "    i-test_type SKIP               */
/*                            "TK_mstr.TK_test_type = " TK_mstr.TK_test_type SKIP*/
/*                                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.      */
/*                                                                               */
/*                    MESSAGE "i-testkitid = " i-testkitid                       */
/*                        VIEW-AS ALERT-BOX BUTTONS OK                           */
/*                            TITLE "Pre Hist".                                  */
/*                                                                               */
/*                    IF AVAILABLE (tk_mstr) THEN                                */
/*                            MESSAGE "i-testkitid = " i-testkitid SKIP          */
/*                                "Pre-Avail"                                    */
/*                                    VIEW-AS ALERT-BOX BUTTONS OK-CANCEL.       */
                    
                    {DL-DDItrh-histTXT.i}. 

/*                    IF AVAILABLE (tk_mstr) THEN                         */
/*                            MESSAGE "i-testkitid = " i-testkitid SKIP   */
/*                                "Post-Avail"                            */
/*                                    VIEW-AS ALERT-BOX BUTTONS OK-CANCEL.*/
/*                                                                        */
/*                    MESSAGE "i-testkitid = " i-testkitid                */
/*                        VIEW-AS ALERT-BOX BUTTONS OK                    */
/*                            TITLE "Post Hist".                          */
                                                 
                    /****  the test type in the database is blank after this for some reason. Katherine Logue TK_ID: 8263, May 6th 2016  ****/  
                     IF i-testkitid = "8263" THEN 
                       MESSAGE 
                            "Just after trh-histTXT include file" SKIP
                            "i-lab-sampleID = " i-lab-sampleID SKIP
                            "i-testkitid = "    i-testkitid SKIP
                            "i-test_seq = "     i-test_seq SKIP
                            "i-test_type = "    i-test_type SKIP
                            "TK_mstr.TK_test_type = " TK_mstr.TK_test_type SKIP
                                VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                
/*                        IF AVAILABLE (tk_mstr) THEN                     */
/*                            MESSAGE "i-testkitid = " i-testkitid SKIP   */
/*                                "FKMS"                                  */
/*                                    VIEW-AS ALERT-BOX BUTTONS OK-CANCEL.*/
/*                                                                        */
/*                        IF NOT AVAILABLE (tk_mstr) THEN                 */
/*                            MESSAGE "i-testkitid = " i-testkitid skip   */
/*                                "Sound of Silence"                      */
/*                                    VIEW-AS ALERT-BOX BUTTONS OK-CANCEL.*/
                                    
                        
                    RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r")) /** this ignores blank inputs so it's all good **/
                        (i-testkitid,            
                        i-test_type,
                        TK_mstr.TK_prof,            
                        i-test_seq,             
                        TK_mstr.TK_domestic,                     
                        TK_mstr.TK_cust_ID,         
                        v-peopleID,  /**/
                        i-lab-sampleID,         /**/                  
                        i-lab-seq,   
                        TK_mstr.TK_test_age,    /**/      
                        TK_mstr.TK_lab_ID,          
                        v-TKstat,               /**/
                        TK_mstr.TK_comments,        
                        TK_mstr.TK_notes,           
                        TK_mstr.tk_cust_paid,             
                        TK_mstr.tk_lbl_print,       
                        TK_mstr.TK_lab_paid,        
                        tk_mstr.tk_magento_order,
                        tk_mstr.tk_cust_paid_date,          
                        OUTPUT o-uctkm-id,
                        OUTPUT o-uctkm-create,
                        OUTPUT o-uctkm-update,
                        OUTPUT o-uctkm-avail,
                        OUTPUT o-uctkm-successful).
                        
                       IF i-testkitid = "8263" THEN 
                           MESSAGE 
                                "Just after SUB TK Mstr RStP" SKIP
                                "i-lab-sampleID = " i-lab-sampleID SKIP
                                "i-testkitid = "    i-testkitid SKIP
                                "i-test_seq = "     i-test_seq SKIP
                                "i-test_type = "    i-test_type SKIP
                                "o-uctkm-successful = " o-uctkm-successful SKIP
                                    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                        
                    IF o-uctkm-successful = NO THEN DO:
        
                        ASSIGN amItkWorthy = NO.       
        
                    END. /*** didn't update/create the TK_mstr! ***/
                        
                END. /*** of update mode ***/
                
            END. /*** test types are not blank. ***/
                            
        END. /*** of TK_mstr available ***/
    
    END. /*** of TK_ID variable is blank ***/
    
    IF i-testkitID = "" OR NOT AVAILABLE (TK_mstr) THEN DO: /*** try to find with no TK_ID **/
    
        ASSIGN 
            i-testkitID = i-orig-testkitID
            i-test_seq = i-orig-test_seq. 
    
        FIND FIRST TK_mstr WHERE   
            TK_mstr.TK_deleted = ? AND
            TK_mstr.TK_lab_sample_ID = i-lab-sampleID AND 
            TK_mstr.TK_lab_seq = i-lab-seq 
            EXCLUSIVE-LOCK NO-ERROR.
                
        IF AVAILABLE (tk_mstr) THEN DO: 
        
            IF TK_mstr.TK_test_type <> "" AND i-test_type <> "" THEN DO:
        
                ASSIGN 
                    i-testkitID = TK_mstr.TK_ID
                    i-test_seq = TK_mstr.TK_test_seq
                    amItkWorthy = YES.
            
                IF TK_mstr.TK_test_type <> "" AND TK_mstr.TK_test_type <> i-test_type THEN 
                        ASSIGN i-test_seq = i-test_seq + 100.
            
                IF i-updatemode = YES THEN DO: 
                                    
                    {DL-DDItrh-histTXT.i}.
                    
                    /* MESSAGE "Inside TK_2 Updatemdode: After TRH include" SKIP
                            "i-filelocation = " i-filelocation SKIP
                            "amIaPatient = " amIaPatient SKIP
                            "amItkWorthy = " amItkWorthy SKIP
                            VIEW-AS ALERT-BOX BUTTONS OK. */
                                    
                    RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r")) /** this ignores blank inputs so it's all good **/
                        (TK_mstr.TK_id,             /* same as variable becuase of the find */
                        i-test_type,
                        TK_mstr.TK_prof,            
                        i-test_seq,        /* same as variable becuase of the find */     
                        TK_mstr.TK_domestic,                     
                        TK_mstr.TK_cust_ID,         
                        v-peopleID,  /**/
                        i-lab-sampleID,         /**/                  
                        i-lab-seq,   
                        TK_mstr.TK_test_age,    /**/      
                        TK_mstr.TK_lab_ID,          
                        v-TKstat,               /**/
                        TK_mstr.TK_comments,        
                        TK_mstr.TK_notes,           
                        TK_mstr.tk_cust_paid,             
                        TK_mstr.tk_lbl_print,       
                        TK_mstr.TK_lab_paid,        
                        tk_mstr.tk_magento_order,
                        tk_mstr.tk_cust_paid_date,          
                        OUTPUT o-uctkm-id,
                        OUTPUT o-uctkm-create,
                        OUTPUT o-uctkm-update,
                        OUTPUT o-uctkm-avail,
                        OUTPUT o-uctkm-successful).         
                    
                  /*  MESSAGE "Inside TK_2 Updatemdode: After RUN tk_mstr ucU" SKIP
                            "i-filelocation = " i-filelocation SKIP
                            "amIaPatient = " amIaPatient SKIP
                            "amItkWorthy = " amItkWorthy SKIP
                            VIEW-AS ALERT-BOX BUTTONS OK. */
                        
                    IF o-uctkm-successful = NO THEN DO:
        
                        ASSIGN amItkWorthy = NO.       
         
                    END. /*** didn't update/create the TK_mstr! ***/
                        
                END. /*** of update mode ***/
          
            END. /*** test types are not blank. ***/
                            
        END. /*** of TK_mstr available with Lab Sample ID ***/
        
    END. /*** of TK_mst.TK_ID = "" or NOT AVAIL ***/      
 
    ELSE IF i-testkitID <> "" AND i-test_seq <> 0 THEN ASSIGN NeedApproval = YES.
 
   /* MESSAGE "End of TK sections" SKIP 
            "i-filelocation = " i-filelocation SKIP 
            "amIaPatient = " amIaPatient SKIP
            "amItkWorthy = " amItkWorthy SKIP
            /*"i-testkitID = " i-testkitID SKIP
            "i-lab-sampleID = " i-lab-sampleID SKIP
            "i-lab-seq = " i-lab-seq SKIP
            "x = " x */
            VIEW-AS ALERT-BOX BUTTONS OK. */
    
/********************************************  att_files stuff  ************************************************/
    FIND FIRST att_files WHERE 
        att_files.att_category = "SOURCE CSV" AND
        att_files.att_deleted = ? AND 
        att_files.att_table  = "TK_mstr"                        AND 
        att_files.att_field1 = "TK_mstr.TK_lab_sample_id"       AND 
        att_files.att_value1 = i-lab-sampleID                   AND
        att_files.att_field2 = "TK_mstr.TK_lab_seq"             AND 
        att_files.att_value2 = STRING(i-lab-seq)         
        NO-LOCK NO-ERROR.
    
    IF AVAILABLE (att_files) THEN DO:
    
        ASSIGN amIattached = YES.
        
    END. /*** att_files available ***/    
    
    ELSE DO:
    
        IF i-updatemode = YES THEN DO:
                    
            CREATE att_files.
                
            ASSIGN 
                att_files.att_file_id       = NEXT-VALUE(seq-attfile)
                att_files.att_category      = "SOURCE CSV"
                att_files.att_table         = "TK_mstr"
                att_files.att_field1        = "TK_mstr.TK_lab_sample_id"        
                att_files.att_value1        = i-lab-sampleID                  
                att_files.att_field2        = "TK_mstr.TK_lab_seq"            
                att_files.att_value2        = STRING(i-lab-seq)
                att_files.att_filepath      = SUBSTRING(i-filelocation, (R-INDEX(i-filelocation,"\") + 1))
                att_files.att_filename      = SUBSTRING(i-filelocation, 1, (R-INDEX(i-filelocation,"\")))
                att_files.att_created_by    = USER("HHI")
                att_files.att_create_date   = TODAY
                att_files.att_modified_by   = USER("HHI")
                att_files.att_modified_date = TODAY
                att_files.att_prog_name     = "DL-DDIverifier.p".
       
            RELEASE att_files.
            
            ASSIGN amIattached = YES.
                
        END. /*of update mode */ 
    
    END. /*** of att_files not available  ***/
  
    IF NeedApproval = YES AND amIaPatient = YES THEN DO:
        {DL-DDIverifierExport.i 9999 "Test Kit needs approval" "Success"}.
        {DL-DDIcatchall.i}.  
    END.
  
    ELSE IF amIaPatient = YES AND amItkWorthy = YES THEN DO:
        {DL-DDIverifierExport.i 10000 "Patient and Test Kit requirements all set!" "Success"}.    
    END. 
    
    ELSE IF amIaPatient = NO AND amItkWorthy = NO THEN DO:
        {DL-DDIverifierExport.i 11000 "Patient and Test Kit requirements unmet" "Error"}.
        {DL-DDIcatchall.i}. 
    END.
    
    ELSE IF amIaPatient = NO AND amItkWorthy = YES THEN DO:
        {DL-DDIverifierExport.i 12000 "Patient requirements unmet, Test Kit data all set" "Error"}.
        {DL-DDIcatchall.i}.
    END.
    
    ELSE IF amIaPatient = YES AND amItkWorthy = NO THEN DO:
        {DL-DDIverifierExport.i 13000 "Test Kit requirements unmet, Patient data all set" "Error"}.
        {DL-DDIcatchall.i}.
    END.

    ELSE DO:
        {DL-DDIverifierExport.i 90000 "What the heck?" "Error"}.
    END. 

    IF err-number = 0 THEN DO:
        {DL-DDIverifierExport.i 0 "The Unknown Error - Text Verifier "Error"}.
        {DL-DDIcatchall.i}.
    END.

END. /*** verification-loop ***/    

         
