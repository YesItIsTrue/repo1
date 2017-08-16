
/*------------------------------------------------------------------------
    File        : RStP-patient-UA.p
    Purpose     : Program processes the input patient_rcd table.

    <META NAME='AUTHOR' CONTENT='Doug Luttrell'>
    <META NAME='VERSION' CONTENT='2.3'>
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="21/May/14">
    <META NAME="LAST_UPDATED_BY" CONTENT="Harold Luttrell, Sr.">
    <META NAME="LAST_UPDATED" CONTENT="24/May/16">

    Description:    Program goes through the patient_rcd table and
                        creates/updates records in the appropriate locations in
                        the General and HHI databases.
    Created:        21/May/14
    Version:        1.0
    Author:         Doug Luttrell
    
    Updated:        10/Dec/14
    Version:        1.1
    Author:         Harold Luttrell, Sr,
    Description:    Took program from Doug.  Updated program to use the
                        new depot/subroutine names for finding and creating
                        records.
    
    Updated:        31/Dec/14
    Version:        1.2
    Author:         Harold Luttrell, Sr,
    Description:    Modified code to use the new SUB-UnString-Name.p program
                        and  removed the old code that tried to format the 
                        patients names which wasn't working correctly.
                        
    Updated:        6/Jan/15
    Version:        1.3
    Author:         Harold Luttrell, Sr.
    Description:    Change the gender code setting the default value
                        from NO to ?.      
    
    Updated:        12/Jan/15
    Version:        1.4
    Author:         Harold Luttrell, Sr.
    Description:    Converted original .html program to .p code for 
                        automated batch run processing.  
    Identified by:  /* 1dot4 */

    Updated:        13/Apr/15
    Version:        1.5
    Author:         Harold Luttrell, Sr.
    Description:    Added code for updating data, not only 
                        creating data.
    Identified by:  /* 1dot5 */

    Updated:        9/Jun/15
    Version:        1.6
    Author:         Harold Luttrell, Sr.
    Description:    Added code to flag the progress_flag with "DL" 
                        when deleting data.
    Identified by:  /* 1dot6 */

    Updated:        12/Sept/15
    Version:        1.7
    Author:         Harold Luttrell, Sr.
    Description:    Changed code to use the RUN VALUE(SEARCH) code 
                        instead of using the long path name and to use
                        the new SUBpat-findR.p requiring the DOB as input also.
    Identified by:  /* 1dot7 */
    
    Updated:        23/Nov/15
    Version:        1.8
    Author:         Harold Luttrell, Sr.
    Description:    Added code to create a people_mstr record when there 
                        is not one if the input Progress_Flag = 'U'
                        because HHI could add (A) a patient_rcd and then 
                        update (U) it the same day and the SQL extract has
                        only the U not the A in the Progress_Flag.
                    Moved the add "A" logic to after the update "U" logic.
    Identified by:  /* 1dot8 */
    
    Version: 2.0    By Harold Luttrell, Sr.
    Date: 15/Feb/16.
    Description:    Added code to use the new ISO SUBcountry-findR.r and the new
                        ISO SUBstate-findR.r programs to validate the 
                        input country and state values to make sure they are in 
                        the ISO formats.  If not, then change them to the ISO formats.
                        If inputs are not found then print them on the Log report
                        for review.                   
    Identified by /* 2dot0 */   

    Version: 2.1    By Harold Luttrell, Sr.
    Date: 14/Apr/16.
    Description:    Deleted the get out of the loop statements (NEXT Main_loop.) 
                    Added code to re-find the state data using the 
                        hard-code of 'USA'.
                    Added code to check for any ISO Country and State errors and
                        only create the addr_mstr if they are not in error.                   
    Identified by /* 2dot1 */   

    Version: 2.2    By Harold Luttrell, Sr.
    Date: 19/Apr/16.
    Description:    Removed a zero initialization of 0 to the 
                    oldpat_addr_id variable
                    and
                    addded a find first addr_mstr statement using the 
                    oldpat_addr_id variable.                    
    Identified by /* 2dot2 */   
    
    Version: 2.3    By Harold Luttrell, Sr.
    Date: 24/May/16.
    Description:    Initialized the variable: genderhold = ?.                      
    Identified by /* 2dot3 */   
                                    
    Version: 2.31    By Harold Luttrell, Jr.
    Date: 15/Aug/17
    Description:    During recompilation after the change to CMC structure (Version 12), 
                        this program would not compile.  Checking into it revealed 3 assign
                        statements where the final piece of the assign had been commented
                        out and thus the period (.) was missing from the end of the statement.
                        Adding that in fixed it, but I have NO idea how this happened or 
                        how it was working before.  The commented out stuff was not related
                        to any of the current structure or coding changes, and in fact seemed
                        to be related more to version 1.7 than any more current change.  How 
                        could this have been compiled and working???                      
    Identified by:  Not marked.                                     
                                                                                                    
  ----------------------------------------------------------------------*/
ROUTINE-LEVEL ON ERROR UNDO, THROW.
  
  
/*  Include code.  */

{o-depot-definenames.i}.                                                        /*** depot output define variables ***/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE ITmessages AS LOGICAL INITIAL NO      NO-UNDO.                  /** change to YES for DISPLAYs of data on the black screen. */

/*IF ITmessages = YES THEN                       */
/*    DISPLAY "Variable Definition Section" SKIP.*/

DEFINE VARIABLE loadedlist AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
     
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO. 
DEFINE VARIABLE Pat_NO_Tests_kount AS INTEGER NO-UNDO.   
DEFINE VARIABLE Pat_processing_kount AS INTEGER NO-UNDO.
DEFINE VARIABLE Pat_NO_address_kount AS INTEGER NO-UNDO.
DEFINE VARIABLE Patient_Mstr_created_kount AS INTEGER NO-UNDO.
DEFINE VARIABLE Pat_NOT_in_People_mstr AS INTEGER NO-UNDO.
DEFINE VARIABLE Pat_has_Tests_kount AS INTEGER NO-UNDO.

/* 2dot0 */ 
/*DEFINE VARIABLE hold-people-addr-id             LIKE people_mstr.people_addr_id NO-UNDO.    /* 2dot0 */*/
/*DEFINE VARIABLE hold-people-2nd-addr-id         LIKE people_mstr.people_second_addr_ID.     /* 2dot0 */*/
                                                                               
DEFINE VARIABLE BadBState-kount AS INTEGER  NO-UNDO.                            /* 2dot0 */
DEFINE VARIABLE BadBCountry-kount AS INTEGER NO-UNDO.                           /* 2dot0 */
DEFINE VARIABLE BadPState-kount AS INTEGER NO-UNDO.                             /* 2dot0 */
DEFINE VARIABLE h-message AS CHARACTER FORMAT "x(60)"  NO-UNDO.                 /* 2dot0 */
DEFINE VARIABLE h-pgm-name AS CHARACTER FORMAT "x(60)" NO-UNDO.                 /* 2dot0 */
DEFINE VARIABLE starting-position AS INTEGER NO-UNDO.                           /* 2dot0 */
/*DEFINE VARIABLE RS-progress-flag-chg-kount AS INTEGER NO-UNDO.                  /* 2dot0 */*/
/* 2dot0 */ 

DEFINE VARIABLE BYPASS_address_logic AS INTEGER NO-UNDO.
DEFINE VARIABLE PAT_format_error AS INTEGER NO-UNDO.
DEFINE VARIABLE Pat_DOB_invalid_kount AS INTEGER NO-UNDO.
DEFINE VARIABLE Pat_DOB_Blank_kount AS INTEGER NO-UNDO.

DEFINE VARIABLE it-message      AS LOGICAL INITIAL NO   NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.  /** junk counter **/
DEFINE VARIABLE xx AS INTEGER NO-UNDO.
DEFINE VARIABLE newstate LIKE addr_mstr.addr_stateprov NO-UNDO.

DEFINE VARIABLE String_Pat_Name     AS CHARACTER FORMAT "x(70)" NO-UNDO.  
DEFINE VARIABLE prefix LIKE people_mstr.people_prefix NO-UNDO.
DEFINE VARIABLE firstname LIKE people_mstr.people_firstname NO-UNDO.
DEFINE VARIABLE middlename LIKE people_mstr.people_midname NO-UNDO.
DEFINE VARIABLE lastname LIKE people_mstr.people_lastname NO-UNDO.
DEFINE VARIABLE prefname LIKE people_mstr.people_prefname NO-UNDO.
DEFINE VARIABLE suffix LIKE people_mstr.people_suffix NO-UNDO.
DEFINE VARIABLE title_desc LIKE people_mstr.people_suffix NO-UNDO.

DEFINE VARIABLE genderhold AS LOGICAL   NO-UNDO.
DEFINE VARIABLE check_date LIKE PATIENT_RCD.PatDOB NO-UNDO.

DEFINE VARIABLE oldpat_addr_id LIKE addr_mstr.addr_id NO-UNDO.

/* ***************************  E-Mail  Definitions  *************************** */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Log Report is attached from "                  NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Log Report from "                              NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.


ASSIGN starting-position = R-INDEX (THIS-PROCEDURE:FILE-NAME, "\").                                                     /* 2dot0 */

ASSIGN h-pgm-name = SUBSTRING(THIS-PROCEDURE:FILE-NAME, (starting-position + 1), LENGTH (THIS-PROCEDURE:FILE-NAME) ).   /* 2dot0 */
 
ASSIGN messagetxt = messagetxt  + "\n"                                          /* 2dot0 */
                                + THIS-PROCEDURE:FILE-NAME                      /* 2dot0 */
                                + "\n"                                          /* 2dot0 */
                                + "End of message.".                            /* 2dot0 */

ASSIGN starting-position = R-INDEX (THIS-PROCEDURE:FILE-NAME, "\").                                                     /* 2dot0 */

ASSIGN h-pgm-name = SUBSTRING(THIS-PROCEDURE:FILE-NAME, (starting-position + 1), LENGTH (THIS-PROCEDURE:FILE-NAME) ).   /* 2dot0 */

ASSIGN subjtxt = subjtxt + h-pgm-name.                                          /* 2dot0 */ 
 
/* ********************  Error-Log File Definitions  ******************** */   
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\Progress\WRK\RStP-PATIENT_RCD-UA-log.txt" NO-UNDO.
 
OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name: " THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at: " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "RS TO Prod Patient Migration.".
EXPORT STREAM outward DELIMITER ";"    
    "RS ID's" 
    "Prod ID's"
    "1st Name"  
    "Last Name"
    "DOB"
    "Progress_Flag"
    "Action or Message.".
 
/* ********************  Preprocessor Definitions  ******************** */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.        

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).           

/*IF ITmessages = YES THEN                 */
/*    DISPLAY "Email Address include" SKIP.*/
    
{emailaddr-USERID.i}.                                                           /* 1dot4 */

/* ***************************  Main Block  *************************** */
/*IF ITmessages = YES THEN     */
/*    DISPLAY "Main_loop" SKIP.*/
    
Main_loop:    
FOR EACH PATIENT_RCD WHERE PATIENT_RCD.PatDOB <> ?   
                        AND  LOOKUP(PATIENT_RCD.Progress_Flag,loadedlist) = 0
           EXCLUSIVE-LOCK :  
    
    ASSIGN recordsprocessed = recordsprocessed + 1.                                    

/*******************************************************************************/
/*******************************************************************************/
    IF  PATIENT_RCD.Progress_Flag = "D" THEN DO: 
        
/*        IF ITmessages = YES THEN     */
/*            DISPLAY "Delete Section" SKIP.*/
            
        FIND people_mstr WHERE  
                people_mstr.people_id           = INTEGER (PATIENT_RCD.PatientID) AND
                people_mstr.people_deleted      = ? 
            EXCLUSIVE-LOCK NO-ERROR. 
           
        IF NOT AVAILABLE (people_mstr) THEN DO:

            EXPORT STREAM outward DELIMITER ";"
                PATIENT_RCD.PatientID 
                "Deleted"                                                       /* 1dot6 */
                PATIENT_RCD.PatFirstName 
                PATIENT_RCD.PatLastName 
                PATIENT_RCD.PatDOB 
                PATIENT_RCD.Progress_Flag
                "ERROR-1! RS PatientID not in General Database.".               /* 1dot6 */
            ASSIGN Pat_NOT_in_People_mstr = (Pat_NOT_in_People_mstr + 1).       /* 1dot6 */
            ASSIGN PATIENT_RCD.Progress_Flag = "DL".                         /* 1dot6 */
            NEXT Main_loop.
            
        END.  /** IF NOT AVAILABLE (people_mstr) **/
    
        FIND FIRST TK_mstr 
                WHERE 
                   (TK_mstr.TK_patient_ID  = people_mstr.people_id OR 
                    TK_mstr.TK_cust_ID     = people_mstr.people_id) AND 
                   TK_mstr.TK_deleted     = ?
                   NO-LOCK NO-ERROR. 
          
        IF  AVAILABLE (TK_mstr) THEN DO:
            EXPORT STREAM outward DELIMITER ";"
                PATIENT_RCD.PatientID 
                "Update DataHub"                                                /* 2dot0 */
                PATIENT_RCD.PatFirstName 
                PATIENT_RCD.PatLastName 
                PATIENT_RCD.PatDOB 
                PATIENT_RCD.Progress_Flag
                "ERROR-2! PATIENT_RCD has test data - can not delete People-Master.".                        
            ASSIGN Pat_has_Tests_kount = (Pat_has_Tests_kount + 1).             /* 1dot6 */
            NEXT Main_loop.
        END.  /** IF  AVAILABLE (TK_mstr) **/  
               
        IF AVAILABLE (people_mstr) THEN DO:                             /* 1dot6 */
            ASSIGN 
                 people_mstr.people_deleted       = TODAY                                                       
                 people_mstr.people_modified_by   = USERID("General")                                          
                 people_mstr.people_modified_date = TODAY                                                       
                 people_mstr.people_prog_name     = THIS-PROCEDURE:FILE-NAME
                 PATIENT_RCD.Progress_Flag             = "DL".  
    	END.  /*  IF AVAILABLE (people_mstr) */   
                                                                                
        NEXT Main_loop.                                                                         /* 2dot0 */  
               
    END.    /**  IF  PATIENT_RCD.Progress_Flag = "D"  **/ 
/*******************************************************************************/
/*******************************************************************************/
/*    IF ITmessages = YES THEN              */
/*            DISPLAY "DOB Validation" SKIP.*/
                       
    ASSIGN check_date = PATIENT_RCD.PatDOB NO-ERROR.                            /* 1dot5 */
    
    IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:             /* 1dot5 */
/** Error Message **/                                                           /* 1dot5 */
           EXPORT STREAM outward DELIMITER ";"                                  /* 1dot5 */
                  PATIENT_RCD.PatientID                                      /* 1dot5 */
                  "Update DataHub"                                              /* 2dot0 */
                  PATIENT_RCD.PatFirstName 
                  PATIENT_RCD.PatLastName 
                  PATIENT_RCD.PatDOB
                  PATIENT_RCD.Progress_Flag
                  "RS.Patient DOB is invalid.  Bypassing input PATIENT_RCD.".   /* 1dot5 */   
           ASSIGN Pat_DOB_invalid_kount = (Pat_DOB_invalid_kount + 1).          /* 1dot5 */                           
           NEXT Main_loop.                                                      /* 1dot5 */
    END.                                                                        /* 1dot5 */

    IF PATIENT_RCD.PatDOB = ? THEN DO:                                          /* 1dot5 */
/** Error Message **/                                                           /* 1dot5 */
           EXPORT STREAM outward DELIMITER ";"                                  /* 1dot5 */
                  PATIENT_RCD.PatientID                                      /* 1dot5 */
                  "Update DataHub"                                              /* 2dot0 */
                  PATIENT_RCD.PatFirstName 
                  PATIENT_RCD.PatLastName 
                  PATIENT_RCD.PatDOB
                  PATIENT_RCD.Progress_Flag
                  "RS.Patient DOB is BLANK.  Bypassing input PATIENT_RCD.".     /* 1dot5 */   
           ASSIGN Pat_DOB_Blank_kount = (Pat_DOB_Blank_kount + 1).              /* 1dot5 */                           
           NEXT Main_loop.                                                      /* 1dot5 */
    END.                                                                        /* 1dot5 */ 
    
    
    ASSIGN genderhold = ?.                                                      /* 2dot3 */
    
    IF PATIENT_RCD.PatGender = "Male" THEN 
       ASSIGN genderhold = YES.
    ELSE IF PATIENT_RCD.PatGender = "Female" THEN                            /* 1.3 - Jan 6, 2015  */
       ASSIGN genderhold = NO.                                                  /* 1.3 - Jan 6, 2015  */  
    
    IF  PATIENT_RCD.PatContactPerson = "NEW PATIENT" THEN 
        ASSIGN PATIENT_RCD.PatContactPerson = "".
    IF  PATIENT_RCD.WhoPaysBill = "NEW PATIENT" THEN 
        ASSIGN PATIENT_RCD.WhoPaysBill = "".    
                                                 
    ASSIGN
        newstate = ""                                                           /* 2dot0 */
        newstate            = IF PATIENT_RCD.PatStatePostalAbbrev <> "" THEN 
                                    PATIENT_RCD.PatStatePostalAbbrev 
                              ELSE 
                                    PATIENT_RCD.PatProvidence.     
      
    ASSIGN  String_Pat_Name =   PATIENT_RCD.PatFirstName + " ".
    
    IF  PATIENT_RCD.PatMiddleName <> "" THEN 
        ASSIGN  String_Pat_Name =   String_Pat_Name + PATIENT_RCD.patMiddleName + " ".      

    ASSIGN  String_Pat_Name     =   String_Pat_Name + PATIENT_RCD.PatLastName.
                          
    IF  String_Pat_Name =  PATIENT_RCD.PatAddress1 THEN DO: 
        ASSIGN  PATIENT_RCD.PatAddress1 = PATIENT_RCD.PatAddress2
                PATIENT_RCD.PatAddress2 = PATIENT_RCD.PatAddress3
                PATIENT_RCD.PatAddress3 = "".       
    END.  /*  IF  String_Pat_Name = */    
 
    ASSIGN  firstname = "oops" middlename = "oops." lastname = "oops.." prefix = "oops..." 
            suffix = "oops...." title_desc = "oops.....".   
  
    ASSIGN  String_Pat_Name =   PATIENT_RCD.PatPrefix + " " + PATIENT_RCD.PatFirstName + " ".    
    IF  PATIENT_RCD.PatMiddleName <> "" THEN 
        ASSIGN  String_Pat_Name =   String_Pat_Name + PATIENT_RCD.patMiddleName + " ".      
    ASSIGN  String_Pat_Name     =   String_Pat_Name + PATIENT_RCD.PatLastName.
    ASSIGN  String_Pat_Name     =   String_Pat_Name + PATIENT_RCD.PatSuffix.

/*    IF ITmessages = YES THEN             */
/*            DISPLAY "UnString Name" SKIP.*/

    RUN VALUE(SEARCH("SUB-UnString-Name.r"))                                    /* 1dot7 */
           (String_Pat_Name,                               /* input_name_big_string, */
            it-message,                                    /* if YES then SUB program displays information. */ 
            OUTPUT prefix,                                 /*  o-prefix, */
            OUTPUT firstname,                              /*  o-firstname, */
            OUTPUT middlename,                             /*  o-middlename, */
            OUTPUT lastname,                               /*  o-lastname, */
            OUTPUT suffix,                                 /*  o-suffix, */
            OUTPUT title_desc,                             /*  o-title_desc, */
            OUTPUT prefname,                               /*  o-prefname, */
            OUTPUT genderhold,                             /*  o-gender */
            OUTPUT o-unstring-error,                       /*  YES = errors / NO = no errors. */
            OUTPUT o-field-in-error).                      /*  name of the input field that is in error, if one. */

    IF  o-unstring-error = YES THEN DO: 
            EXPORT STREAM outward DELIMITER ";"
                PATIENT_RCD.PatientID ""
                String_Pat_Name
                ""
                PATIENT_RCD.Progress_Flag
                "ERROR! - input field in error. Input bypassed:  " +            /* 2dot0 */
                o-field-in-error + " = " +
                lastname.
             ASSIGN PAT_format_error = (PAT_format_error + 1).
             NEXT  Main_loop. 
    END.  /** IF  o-unstring-error = YES  **/  
                       
/******  check for address data ******/
    ASSIGN  BYPASS_address_logic = 0                                            /* 1dot8 */
            oldpat_addr_id = 0.                                                 /* 1dot8 */
         
    IF  PATIENT_RCD.PatAddress1 =   "" OR   
        PATIENT_RCD.PatCity     =   "" OR  
        newstate                =   "" OR  
        PATIENT_RCD.PatZip      =   ""    THEN DO:         
/** ERROR TYPE **/                  
          EXPORT STREAM outward DELIMITER ";"
              PATIENT_RCD.PatientID 
              "Update DataHub"                                                  /* 2dot0 */
              PATIENT_RCD.PatFirstName 
              PATIENT_RCD.PatLastName 
              PATIENT_RCD.PatDOB
              PATIENT_RCD.Progress_Flag 
              "Warning-1.  Missing input(s) address (blank) information.  Address-Master will NOT be created.".                            
          ASSIGN Pat_NO_address_kount = (Pat_NO_address_kount + 1)
                 BYPASS_address_logic = 1.                                      /* 1 = NO input address info. */              
    END.  /**  IF  PATIENT_RCD.PatAddress1 =   "" OR   */
    
    ASSIGN Pat_processing_kount = (Pat_processing_kount + 1).                                    


/*******************************************************************************/
/*******************************************************************************/
/* 2dot0 */                         /* 2dot0 */                                 /* 2dot0 */ 
/* 2dot0 */                         /* 2dot0 */                                 /* 2dot0 */        
        
/* Check input Country for ISO Validation. */ 

/*    IF  PATIENT_RCD.PatCountry = "" THEN      */                           /* 2dot1 */ 
/*        ASSIGN PATIENT_RCD.PatCountry = "USA".*/                           /* 2dot1 */ 
    
/*        IF ITmessages = YES THEN                */
/*            DISPLAY "Country Verification" SKIP.*/
                                                                                                                                
    RUN VALUE(SEARCH("SUBcountry-findR.r")) 
                           (PATIENT_RCD.PatCountry,
                            OUTPUT o-fcountry-ISO,
                            OUTPUT o-fcountry-error). 

/*  Country NOT Found in country_mstr. Report error. */                         
    IF  o-fcountry-error =  YES THEN DO:                                        /* logical YES = data is not found */
        IF  PATIENT_RCD.PatCountry = "" THEN 
            ASSIGN  h-message = "Update DataHub-Country is blank.".
        ELSE 
            ASSIGN  h-message = "Verify DataHub & InforMatrix-Country not found in ISO country_mstr.".
            
        EXPORT STREAM outward DELIMITER ";"
                    PATIENT_RCD.PatientID
                    "Verify data"                                        
                    PATIENT_RCD.PatCity
                    PATIENT_RCD.PatStatePostalAbbrev
                    PATIENT_RCD.PatCountry
                    PATIENT_RCD.Progress_Flag
                    h-message. 

        ASSIGN  BadBCountry-kount = (BadBCountry-kount + 1).                                                       
    END.  /* IF o-fcountry-error =  YES */                                      
    
    IF  o-fcountry-error =  NO THEN
        ASSIGN  PATIENT_RCD.PatCountry = o-fcountry-ISO.
                       
/* Check input State for ISO Validation. */ 
    
/*    IF ITmessages = YES THEN                  */
/*            DISPLAY "State Verification" SKIP.*/
                                     
    IF  PATIENT_RCD.PatStatePostalAbbrev <> "" THEN DO: 
                                                                                                                              
        RUN VALUE(SEARCH("SUBstate-findR.r"))
                       (PATIENT_RCD.PatCountry,
                        PATIENT_RCD.PatStatePostalAbbrev,
                        OUTPUT o-fstate-ISO,
                        OUTPUT o-fstate-error).             

/* State NOT Found in state_mstr. Report error. */                              
        IF o-fstate-error =  YES THEN DO:                           /* logical YES = data is not found */
            
            IF  PATIENT_RCD.PatStatePostalAbbrev = "" THEN DO:               /* 2dot1 */ 
                ASSIGN o-fstate-error =  NO.                                    /* 2dot1 */ 
                RUN VALUE(SEARCH("SUBstate-findR.r"))                           /* 2dot1 */ 
                       ("USA",                                                  /* 2dot1 */ 
                        PATIENT_RCD.PatStatePostalAbbrev,                    /* 2dot1 */ 
                        OUTPUT o-fstate-ISO,                                    /* 2dot1 */ 
                        OUTPUT o-fstate-error).                                 /* 2dot1 */  
                IF o-fstate-error =  YES THEN DO:                               /* 2dot1 */ 
                    ASSIGN  h-message = "Verify DataHub & InforMatrix-Country/PatStatePostalAbbrev not found in ISO state_mstr.".   /* 2dot1 */    
                END.                                                            /* 2dot1 */ 
            END.                                                                /* 2dot1 */  
            
/*            IF  PATIENT_RCD.PatStatePostalAbbrev = "" THEN                       */        /* 2dot1 */ 
/*                ASSIGN  h-message = "Update DataHub-PatStatePostalAbbrev is blank.".*/        /* 2dot1 */ 
            ELSE 
                ASSIGN  h-message = "Verify DataHub & InforMatrix-Country/PatStatePostalAbbrev not found in ISO state_mstr.".

            EXPORT STREAM outward DELIMITER ";"
                    PATIENT_RCD.PatientID
                    "Verify data"                                        
                    PATIENT_RCD.PatCity
                    PATIENT_RCD.PatStatePostalAbbrev
                    PATIENT_RCD.PatCountry
                    PATIENT_RCD.Progress_Flag
                    h-message. 
                                               
            ASSIGN  BadBState-kount = (BadBState-kount + 1).                                                    
        END.  /* IF o-fstate-error =  YES */                                     
   
        IF o-fstate-error =  NO THEN                                            
            ASSIGN  PATIENT_RCD.PatStatePostalAbbrev = o-fstate-ISO
                    newstate = o-fstate-ISO.                                         
                
    END.  /* IF  PATIENT_RCD.PatStatePostalAbbrev <> "" */                            
        
    ELSE DO: 
/* Check input Providence for ISO Validation. */  

/*    IF ITmessages = YES THEN                                */
/*            DISPLAY "State Verification with Province" SKIP.*/
                                              
        RUN VALUE(SEARCH("SUBstate-findR.r"))
               (PATIENT_RCD.PatCountry,
                PATIENT_RCD.PatProvidence,
                OUTPUT o-fstate-ISO,
                OUTPUT o-fstate-error).             

/* State NOT Found in state_mstr. Report error. */                              
        IF o-fstate-error =  YES THEN DO:                                       /* logical YES = data is not found */       
                        
            IF  PATIENT_RCD.PatProvidence = "" THEN DO:                      /* 2dot1 */ 
                ASSIGN o-fstate-error =  NO.                                    /* 2dot1 */ 
                RUN VALUE(SEARCH("SUBstate-findR.r"))                           /* 2dot1 */ 
                       ("USA",                                                  /* 2dot1 */ 
                        PATIENT_RCD.PatStatePostalAbbrev,                    /* 2dot1 */ 
                        OUTPUT o-fstate-ISO,                                    /* 2dot1 */ 
                        OUTPUT o-fstate-error).                                 /* 2dot1 */  
                IF o-fstate-error =  YES THEN DO:                               /* 2dot1 */ 
                    ASSIGN  h-message = "Verify DataHub & InforMatrix-Country/PatProvidence not found in ISO state_mstr.".   /* 2dot1 */    
                END.                                                            /* 2dot1 */ 
            END.                                                                /* 2dot1 */     
                    
/*            IF  PATIENT_RCD.PatProvidence = "" THEN                       */   /* 2dot1 */ 
/*                ASSIGN  h-message = "Update DataHub-PatProvidence is blank.".*/   /* 2dot1 */ 
            ELSE 
                ASSIGN  h-message = "Verify DataHub & InforMatrix-Country/PatProvidence not found in ISO state_mstr.".

            EXPORT STREAM outward DELIMITER ";"
                    PATIENT_RCD.PatientID
                    "Verify data"                                        
                    PATIENT_RCD.PatCity
                    PATIENT_RCD.PatProvidence
                    PATIENT_RCD.PatCountry
                    PATIENT_RCD.Progress_Flag
                    h-message. 
                                               
            ASSIGN  BadPState-kount = (BadPState-kount + 1).
        END.  /* IF o-fstate-error =  YES */                                     
   
        IF o-fstate-error =  NO THEN                                            
            ASSIGN  PATIENT_RCD.PatProvidence = o-fstate-ISO
                    newstate = o-fstate-ISO.                                    /* 2dot0 */                 
                       
    END.  /* ELSE DO: */  
              
/* 2dot0 */                         /* 2dot0 */                                 /* 2dot0 */ 
/* 2dot0 */                         /* 2dot0 */                                 /* 2dot0 */ 
/*******************************************************************************/
/*******************************************************************************/


/*******************************************************************************/
/*******************************************************************************/
    IF  PATIENT_RCD.Progress_Flag = "U" THEN DO: 
      
/*    IF ITmessages = YES THEN              */
/*            DISPLAY "Update Section" SKIP.*/
                  
        FIND people_mstr                                                     
            WHERE people_mstr.people_id  =  INTEGER(PATIENT_RCD.PatientID)
                EXCLUSIVE-LOCK NO-ERROR.                                                                       
          
        IF NOT AVAILABLE  (people_mstr) THEN DO:

/*            IF ITmessages = YES THEN            */
/*                    DISPLAY "Patient Find" SKIP.*/
          
            RUN VALUE(SEARCH("SUBpat-findR.r"))                                 /* 1dot7 */        
                           (TRIM(prefix),
                            TRIM(firstname),
                            TRIM(middlename),
                            TRIM(lastname),
                            TRIM(suffix),
                            PATIENT_RCD.PatDOB,                                 /* 1dot7 */                             
                            OUTPUT o-fpe-peopleID,
                            OUTPUT o-fpe-addr_ID,
                            OUTPUT o-fpat-exist,                                /* 1dot7 */
                            OUTPUT o-fpat-ran,                                  /* 1dot8 */
                            OUTPUT o-fpe-error).                                /* 1dot8 */
             
                FIND people_mstr 
                        WHERE people_mstr.people_id  =  o-fpe-peopleID  
                    EXCLUSIVE-LOCK NO-ERROR.

/* 1dot8 */ 
            IF NOT AVAILABLE (people_mstr) THEN DO:
        
/******  need to create a people_mstr record from the RS PATIENT_RCD. ******/

/*                IF ITmessages = YES THEN                   */
/*                        DISPLAY "Patient Find again?" SKIP.*/
            
                RUN VALUE(SEARCH("SUBpat-findR.r"))                                          
                           (TRIM(prefix),
                            TRIM(firstname),
                            TRIM(middlename),
                            TRIM(lastname),
                            TRIM(suffix),
                            PATIENT_RCD.PatDOB,                                                          
                            OUTPUT o-fpe-peopleID,
                            OUTPUT o-fpe-addr_ID,
                            OUTPUT o-fpat-exist,
                            OUTPUT o-fpat-ran,
                            OUTPUT o-fpe-error).             
                                             
                IF o-fpe-peopleID  = 0 THEN DO:
               
/*                    IF ITmessages = YES THEN                  */
/*                        DISPLAY "RStP SQL create people" SKIP.*/
               
                    RUN VALUE(SEARCH("RStP-SQL-create-people-mstr.r"))                                
                       (PATIENT_RCD.PatientID,
                        TRIM(firstname), TRIM(middlename), TRIM(lastname),
                        TRIM(prefix), TRIM(suffix),
                        TRIM(prefname),                                         /* 2dot0 */ 
                        TRIM(PATIENT_RCD.PatCompany),
                        genderhold, 
                        TRIM(PATIENT_RCD.PatPhoneHome), TRIM(PATIENT_RCD.PatPhoneWork), 
                        TRIM(PATIENT_RCD.PatPhoneCell),
                        TRIM(PATIENT_RCD.PatFax), TRIM(PATIENT_RCD.PatEMail), "",
                        oldpat_addr_id,
                        "",                                                             /**  drop per Doug TRIM(PATIENT_RCD.PatContactPerson),  **/ 
                        PATIENT_RCD.PatDOB, 0,               
                        OUTPUT o-ucpeople-id,
                        OUTPUT o-ucpeople-create,
                        OUTPUT o-ucpeople-update,
                        OUTPUT o-ucpeople-avail,
                        OUTPUT o-ucpeople-successful).        
                                    
                    ASSIGN  o-fpe-peopleID = o-ucpeople-id. 
              
                    IF o-ucpeople-successful = NO THEN DO:
                        EXPORT STREAM outward DELIMITER ";"
                            PATIENT_RCD.PatientID ""
                            "CREATE Error from pgm: RStP-SQL-create-people-mstr !  " SKIP
                            "  The returned o-ucpeople-id value = " o-ucpeople-id SKIP
                            "  ABORTing process........." SKIP. 
                        NEXT  Main_loop.
                    END.    /** IF o-ucpeople-successful = NO from utilities pgm. **/
        
                    EXPORT STREAM outward DELIMITER ";"
                        PATIENT_RCD.PatientID
                        o-fpe-peopleID
                        PATIENT_RCD.PatFirstName
                        PATIENT_RCD.PatLastName
                        PATIENT_RCD.PatDOB
                        "people_mstr Created for this UPDATE Progress_Flag.".

                    FIND people_mstr 
                             WHERE people_mstr.people_id  =  o-fpe-peopleID  
                        EXCLUSIVE-LOCK NO-ERROR.
                              
                END.  /*  IF o-fpe-peopleID  = 0  */ 
           
            END.  /*  IF NOT AVAILABLE (people_mstr)  */                  
/* 1dot8 */
            
        END.  /** IF NOT AVAILABLE (people_mstr) **/
    
        IF AVAILABLE (people_mstr) THEN DO: 
            
/*            IF ITmessages = YES THEN                                      */
/*                        DISPLAY "Manually updating the people_mstr." SKIP.*/
            
            ASSIGN  people_mstr.people_company      = PATIENT_RCD.PatCompany     /* 1dot5 */        
                    people_mstr.people_firstname    = PATIENT_RCD.PatFirstName   /* 1dot5 */
                    people_mstr.people_midname      = PATIENT_RCD.PatMiddleName  /* 1dot5 */
                    people_mstr.people_lastname     = PATIENT_RCD.PatLastName    /* 1dot5 */
                    people_mstr.people_prefix       = PATIENT_RCD.PatPrefix      /* 1dot5 */
                    people_mstr.people_suffix       = PATIENT_RCD.PatSuffix      /* 1dot5 */
                    people_mstr.people_prefname     = prefname                      /* 2dot0 */
                    people_mstr.people_gender       = genderhold                    /* 1dot5 */                   
                    people_mstr.people_homephone    = PATIENT_RCD.PatPhoneHome   /* 1dot5 */
                    people_mstr.people_workphone    = PATIENT_RCD.PatPhoneWork   /* 1dot5 */
                    people_mstr.people_cellphone    = PATIENT_RCD.PatPhoneCell   /* 1dot5 */
                    people_mstr.people_fax          = PATIENT_RCD.PatFax         /* 1dot5 */
                    people_mstr.people_email        = PATIENT_RCD.PatEMail       /* 1dot5 */
                    people_mstr.people_email2       = PATIENT_RCD.Responsible_Party_EMail       /* 1dot5 */
                    people_mstr.people_contact      = PATIENT_RCD.PatContactPerson    /* 1dot5 */                    
                    people_mstr.people_title        = title_desc                /* 1dot5 */ 
                    people_mstr.people_prefname     = prefname                  /* 1dot5 */ 
                    people_mstr.people_modified_by  = USERID("General")        /* 1dot5 */ 
                    people_mstr.people_modified_date = TODAY                    /* 1dot5 */ 
                    people_mstr.people_prog_name    = THIS-PROCEDURE:FILE-NAME. /* 1dot5 */  

            ASSIGN people_mstr.people_DOB          = PATIENT_RCD.PatDOB.

            ASSIGN PATIENT_RCD.Progress_Flag = "UL".                            /* 1dot7 */   
            
            ASSIGN oldpat_addr_id = 0.                                          /* 2dot0 */
                     
            IF  people_mstr.people_addr_id = 0 AND 
                BYPASS_address_logic = 0 THEN DO:                               /* 0 = has input address info. */
                          
/*                IF ITmessages = YES THEN                  */
/*                        DISPLAY "About to find addr" SKIP.*/
                                
                RUN VALUE(SEARCH("SUBaddr-findR.r"))                            /* 1dot7 */                   
                    (PATIENT_RCD.PatAddress1, 
                     PATIENT_RCD.pataddress2,
                     PATIENT_RCD.pataddress3,
                     PATIENT_RCD.patcity, 
                     newstate, 
                     PATIENT_RCD.PatZip, 
                     PATIENT_RCD.PatCountry,
                     OUTPUT oldpat_addr_id, 
                     OUTPUT o-faddr-error, OUTPUT o-faddr-ran).
             
                IF  o-faddr-error = YES AND                                     /* 2dot1 */ 
                    o-fcountry-error =  NO AND                                  /* 2dot1 */ 
                    o-fstate-error =  NO                                        /* 2dot1 */   
                        THEN DO: 

/*                    IF ITmessages = YES THEN          */
/*                        DISPLAY "Create address" SKIP.*/

                    RUN VALUE(SEARCH("SUBaddr-ucU.r"))                          /* 1dot7 */ 
                        (0, 
                         PATIENT_RCD.PatAddress1, 
                         PATIENT_RCD.pataddress2,
                         PATIENT_RCD.pataddress3, 
                         PATIENT_RCD.patcity, 
                         newstate, 
                         PATIENT_RCD.PatZip, 
                         PATIENT_RCD.PatCountry,           
                         "",
                         OUTPUT o-ucaddr-id, 
                         OUTPUT o-ucaddr-create, OUTPUT o-ucaddr-update,
                         OUTPUT o-ucaddr-avail, OUTPUT o-ucaddr-successful).
                                               
                    ASSIGN  oldpat_addr_id = o-ucaddr-id. 
                            
                    EXPORT STREAM outward DELIMITER ";"
                            PATIENT_RCD.PatientID
                            oldpat_addr_id
                            PATIENT_RCD.PatAddress1
                            PATIENT_RCD.patcity
                            newstate
                            "addr_mstr Created.".
                    
                END.  /**  IF o-faddr-error = YES  **/
                            
                ASSIGN                                                          /* 2dot0 */
                        people_mstr.people_addr_id  =                   /* 2dot0 */
                            IF oldpat_addr_id <> 0 THEN oldpat_addr_id ELSE     /* 2dot0 */
                                people_mstr.people_addr_id.             /* 2dot0 */
                
                IF  oldpat_addr_id <> 0 THEN                                    /* 2dot0 */
                    EXPORT STREAM outward DELIMITER ";"
                        PATIENT_RCD.PatientID
                        people_mstr.people_id
                        people_mstr.people_firstname
                        people_mstr.people_lastname
                        people_mstr.people_DOB
                        "people_mstr Updated - stored addr_id.".
                                           
                FIND FIRST addr_mstr
                    WHERE addr_mstr.addr_id = oldpat_addr_id
                        EXCLUSIVE-LOCK NO-ERROR.

                IF AVAILABLE (addr_mstr) THEN
                    IF  addr_mstr.addr_type = "" THEN DO: 
                        
/*                        IF ITmessages = YES THEN                             */
/*                            DISPLAY "Manually updating address fields." SKIP.*/
                              
                        ASSIGN  addr_mstr.addr_type          = "billed to"
                                addr_mstr.addr_modified_by   = USERID("General")     
                                addr_mstr.addr_modified_date = TODAY                  
                                addr_mstr.addr_prog_name     = THIS-PROCEDURE:FILE-NAME.  
    
                        EXPORT STREAM outward DELIMITER ";"
                                PATIENT_RCD.PatientID
                                oldpat_addr_id
                                PATIENT_RCD.PatAddress1
                                PATIENT_RCD.patcity
                                newstate
                                "addr_mstr Updated - set addr_type as 'billed to'.".  
                            
                    END.  /*  addr_mstr.addr_type = ""  */
                              
            END.  /* IF  people_mstr.people_addr_id = 0 */

/*           ASSIGN oldpat_addr_id = 0.                                          /* 2dot1 */*/
            
            IF BYPASS_address_logic = 0 THEN DO:                 /* 0 = has input address info. */              

/*                IF ITmessages = YES THEN        */
/*                    DISPLAY "Find address" SKIP.*/

                RUN VALUE(SEARCH("SUBaddr-findR.r"))                                /* 1dot7 */ 
                    (PATIENT_RCD.PatAddress1, 
                     PATIENT_RCD.pataddress2,
                     PATIENT_RCD.pataddress3,
                     PATIENT_RCD.patcity, 
                     newstate, 
                     PATIENT_RCD.PatZip, 
                     PATIENT_RCD.PatCountry,
                     OUTPUT oldpat_addr_id, 
                     OUTPUT o-faddr-error, OUTPUT o-faddr-ran).

/*                IF ITmessages = YES THEN                           */
/*                    DISPLAY "Post Find address" SKIP               */
/*                        "oldpat_addr_id = " oldpat_addr_id SKIP    */
/*                        "o-faddr-error = " o-faddr-error SKIP      */
/*                        "o-fcountry-error = " o-fcountry-error SKIP*/
/*                        "o-fstate-error = " o-fstate-error SKIP    */
/*                            WITH FRAME addr-results NO-LABELS.     */
              
                IF  o-faddr-error = YES AND                                     /* 2dot1 */ 
                    o-fcountry-error =  NO AND                                  /* 2dot1 */ 
                    o-fstate-error =  NO                                        /* 2dot1 */   
                        THEN DO: 

/*                    IF ITmessages = YES THEN          */
/*                        DISPLAY "Update address" SKIP.*/
                     
                    RUN VALUE(SEARCH("SUBaddr-ucU.r"))                              /* 1dot7 */   
                        (0, 
                         PATIENT_RCD.PatAddress1, 
                         PATIENT_RCD.pataddress2,
                         PATIENT_RCD.pataddress3, 
                         PATIENT_RCD.patcity, 
                         newstate, 
                         PATIENT_RCD.PatZip, 
                         PATIENT_RCD.PatCountry,           
                         "",
                         OUTPUT o-ucaddr-id, 
                         OUTPUT o-ucaddr-create, OUTPUT o-ucaddr-update,
                         OUTPUT o-ucaddr-avail, OUTPUT o-ucaddr-successful).

/*                    IF ITmessages = YES THEN               */
/*                        DISPLAY "Post Update address" SKIP.*/
                                               
                    ASSIGN  oldpat_addr_id = o-ucaddr-id. 
                            
                    EXPORT STREAM outward DELIMITER ";"
                            PATIENT_RCD.PatientID
                            oldpat_addr_id
                            PATIENT_RCD.PatAddress1
                            PATIENT_RCD.patcity
                            newstate
                            "addr_mstr Created-2 code.".
         
/*                    IF ITmessages = YES THEN                                                 */
/*                        DISPLAY "About to manually update address for " SKIP                 */
/*                            "new address (o-ucaddr-id) = " o-ucaddr-id SKIP                  */
/*                            "by updating old address (oldpat_addr_id) = " oldpat_addr_id SKIP*/
/*                                  WITH FRAME addr-overlay NO-LABELS.                         */
         
                    FIND FIRST addr_mstr
                        WHERE addr_mstr.addr_id = oldpat_addr_id
                            EXCLUSIVE-LOCK NO-ERROR.
    
                    IF AVAILABLE (addr_mstr) THEN         
                        ASSIGN  addr_mstr.addr_type          = "billed to"
                                addr_mstr.addr_modified_by   = USERID("General")        /* 1dot5 */
                                addr_mstr.addr_modified_date = TODAY                    /* 1dot5 */
                                addr_mstr.addr_prog_name     = THIS-PROCEDURE:FILE-NAME.   /* 1dot5 */
                    
                END.  /**  IF o-faddr-error = YES  **/
                 
/*            IF ITmessages = YES THEN                                             */
/*                    DISPLAY "About to update the people_mstr and addr_mstr" SKIP */
/*                        "Do I have the people_mstr? " AVAILABLE(people_mstr) SKIP*/
/*                        "Do I have the addr_mstr? " AVAILABLE(addr_mstr) SKIP    */
/*                            WITH FRAME addr-bobo NO-LABELS.                      */
                        
                                            
                ASSIGN                                                              /* 2dot0 */
                    people_mstr.people_addr_id  =                       /* 2dot0 */
                            IF oldpat_addr_id <> 0 THEN 
                                oldpat_addr_id 
                            ELSE         /* 2dot0 */
                                people_mstr.people_addr_id.                 /* 2dot0 */
                                                                  
                IF  oldpat_addr_id <> 0 THEN DO:                                            /* 2dot2 */
                    
                    FIND FIRST addr_mstr WHERE addr_mstr.addr_id = oldpat_addr_id           /* 2dot2 */
                            EXCLUSIVE-LOCK NO-ERROR.                                        /* 2dot2 */
                    
                    ASSIGN                                                                  /* 2dot0 */
                        addr_mstr.addr_prog_name        = THIS-PROCEDURE:FILE-NAME  /* 2dot0 */
                        addr_mstr.addr_modified_date    = TODAY                     /* 2dot0 */
                        addr_mstr.addr_modified_by      = USERID ("General").       /* 2dot0 */ 
                          
                END.  /* IF  oldpat_addr_id <> 0 */                                         /* 2dot2 */
                
                FIND addr_mstr 
                    WHERE addr_mstr.addr_id  =  people_mstr.people_addr_id 
                        EXCLUSIVE-LOCK NO-ERROR.
                      
                IF AVAILABLE (addr_mstr) THEN DO:  
               
/*                    IF ITmessages = YES THEN                      */
/*                        DISPLAY "Manually updating address?" SKIP.*/
               
                    ASSIGN  
                        addr_mstr.addr_addr1            = PATIENT_RCD.PatAddress1    /* 1dot5 */
                        addr_mstr.addr_addr2            = PATIENT_RCD.PatAddress2    /* 1dot5 */
                        addr_mstr.addr_addr3            = PATIENT_RCD.PatAddress3    /* 1dot5 */
                        addr_mstr.addr_city             = PATIENT_RCD.PatCity        /* 1dot5 */
                        addr_mstr.addr_stateprov        = PATIENT_RCD.PatStatePostalAbbrev  /* 1dot5 */
                        addr_mstr.addr_zip              = PATIENT_RCD.PatZip         /* 1dot5 */
                        addr_mstr.addr_country          = PATIENT_RCD.PatCountry     /* 1dot5 */ 
                        addr_mstr.addr_stateprov        =                               /* 1dot5 */
                                IF  addr_mstr.addr_stateprov = "" THEN                  /* 1dot5 */
                                    PATIENT_RCD.PatProvidence    ELSE addr_mstr.addr_stateprov  /* 1dot5 */ 
                        addr_mstr.addr_modified_by      = USERID("General")             /* 1dot5 */ 
                        addr_mstr.addr_modified_date    = TODAY                         /* 1dot5 */ 
                        addr_mstr.addr_prog_name        = THIS-PROCEDURE:FILE-NAME      /* 1dot5 */            
                        .
                        
                END.  /** of if avail addr_mstr **/
                
                ELSE 
                    EXPORT STREAM outward DELIMITER ";"
                          PATIENT_RCD.PatientID 
                          o-fpe-peopleID 
                          PATIENT_RCD.PatFirstName 
                          PATIENT_RCD.PatLastName 
                          PATIENT_RCD.PatDOB
                          PATIENT_RCD.Progress_Flag
                          "Warning-2.  RS PatientID does not have an Address-Master for its People-Master.".                               
    
            END.  /* if BYPASS_address_logic = 0 */
                                             
      /********  Create the patient_mstr record, finally  **********/
            FIND patient_mstr WHERE patient_mstr.patient_ID = o-fpe-peopleID AND            /* 1dot7 */
                                        patient_mstr.patient_deleted    = ?
                EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAILABLE (patient_mstr) THEN DO:
            
/*                IF ITmessages = YES THEN                             */
/*                        DISPLAY "Manually create patient_mstr?" SKIP.*/
            
                CREATE patient_mstr.
                ASSIGN 
                    patient_mstr.patient_ID             = o-fpe-peopleID  /* oldpat_people_id */
                    patient_mstr.patient_notes          = PATIENT_RCD.PatNotes
/*                    patient_mstr.patient__char01        = PATIENT_RCD.PatContactPerson*/
/*                    patient_mstr.patient__char02        = PATIENT_RCD.WhoPaysBill     */
                    patient_mstr.patient_RP_ID          = o-fpe-peopleID  /*oldpat_people_id */
                    patient_mstr.patient_doctor_ID      = 0  /* oldpat_docID */
                    patient_mstr.patient_cust_ID        = 0  /* oldpat_cust_ID */
                    patient_mstr.patient_verified       = IF PATIENT_RCD.Pat_Verify_Flag = "Y" THEN 
                                                                YES
                                                          ELSE 
                                                                NO
                    patient_mstr.patient_created_by     = USERID("HHI")      
                    patient_mstr.patient_create_date    = TODAY 
                    patient_mstr.patient_modified_by    = USERID("HHI")
                    patient_mstr.patient_modified_date  = TODAY
                    patient_mstr.patient_prog_name      = THIS-PROCEDURE:FILE-NAME.      /* 1dot5 */
/*                    patient_mstr.patient__dec01         = PATIENT_RCD.PatientID.*/
                              
                EXPORT STREAM outward DELIMITER ";"
                            PATIENT_RCD.PatientID
                            o-fpe-peopleID     /*  oldpat_people_id */
                            PATIENT_RCD.PatFirstName 
                            PATIENT_RCD.PatLastName 
                            PATIENT_RCD.PatDOB
                            PATIENT_RCD.Progress_Flag
                            "patient_mstr Created - for an UPDATE of a new patient.".
                        
                ASSIGN Patient_Mstr_created_kount = (Patient_Mstr_created_kount + 1).
                
            END.  /*** IF NOT AVAILABLE (patient_mstr) ***/
                             
            IF  AVAILABLE (patient_mstr) THEN DO:
                
/*                IF ITmessages = YES THEN                             */
/*                        DISPLAY "Manually update patient_mstr?" SKIP.*/
                
                ASSIGN 
                    patient_mstr.patient_notes          = PATIENT_RCD.PatNotes
/*                    patient_mstr.patient__char01        = PATIENT_RCD.PatContactPerson*/
/*                    patient_mstr.patient__char02        = PATIENT_RCD.WhoPaysBill*/
                    patient_mstr.patient_RP_ID          = o-fpe-peopleID 
                    patient_mstr.patient_verified       = IF PATIENT_RCD.Pat_Verify_Flag = "Y" THEN 
                                                                YES
                                                          ELSE 
                                                                NO    
                    patient_mstr.patient_modified_by    = USERID("HHI")
                    patient_mstr.patient_modified_date  = TODAY
                    patient_mstr.patient_prog_name      = THIS-PROCEDURE:FILE-NAME.       /* 1dot5 */
/*                    patient_mstr.patient__dec01         = PATIENT_RCD.PatientID*/
/*                    patient_mstr.patient__date01        = PATIENT_RCD.PatDOB          /* 1dot7 */*/
/*                    patient_mstr.patient__char03        = PATIENT_RCD.PatEMail.       /* 1dot7 */*/
                    
                EXPORT STREAM outward DELIMITER ";"
                            PATIENT_RCD.PatientID
                            PATIENT_RCD.PatientID
                            PATIENT_RCD.PatFirstName 
                            PATIENT_RCD.PatLastName 
                            PATIENT_RCD.PatDOB
                            PATIENT_RCD.Progress_Flag
                            "patient_mstr Updated.".
            END.   /*** IF  AVAILABLE (patient_mstr) ***/ 
            
        END.  /** IF AVAILABLE (people_mstr) **/

    END.  /*  IF  PATIENT_RCD.Progress_Flag = "U"  */        
/*******************************************************************************/
/*******************************************************************************/

 
/*******************************************************************************/
/*******************************************************************************/
/* 1dot8 */
    IF  PATIENT_RCD.Progress_Flag = "A" OR   
        PATIENT_RCD.Progress_Flag = "" OR 
        PATIENT_RCD.Progress_Flag = "U"                                      /* 1dot8 */
            THEN DO:  

/*    IF ITmessages = YES THEN           */
/*            DISPLAY "Add Section" SKIP.*/
               
/******  need to create an addr_mstr record ******/                 
        IF BYPASS_address_logic = 0 THEN DO:
      
/*    IF ITmessages = YES THEN         */
/*            DISPLAY "addr-find" SKIP.*/
            
                RUN VALUE(SEARCH("SUBaddr-findR.r"))                            /* 1dot7 */    
                (PATIENT_RCD.PatAddress1, 
                 PATIENT_RCD.pataddress2,
                 PATIENT_RCD.pataddress3,
                 PATIENT_RCD.patcity, 
                 newstate, 
                 PATIENT_RCD.PatZip, 
                 PATIENT_RCD.PatCountry,
                 OUTPUT oldpat_addr_id, 
                 OUTPUT o-faddr-error, OUTPUT o-faddr-ran).
          
                IF  o-faddr-error = YES AND                                     /* 2dot1 */ 
                    o-fcountry-error =  NO AND                                  /* 2dot1 */ 
                    o-fstate-error =  NO                                        /* 2dot1 */   
                        THEN DO: 

/*    IF ITmessages = YES THEN           */
/*            DISPLAY "create addr" SKIP.*/
                
                    RUN VALUE(SEARCH("SUBaddr-ucU.r"))                              /* 1dot7 */                  
                        (0,   
                         PATIENT_RCD.PatAddress1, 
                         PATIENT_RCD.pataddress2,
                         PATIENT_RCD.pataddress3, 
                         PATIENT_RCD.patcity, 
                         newstate, 
                         PATIENT_RCD.PatZip, 
                         PATIENT_RCD.PatCountry,           
                         "",
                         OUTPUT o-ucaddr-id, 
                         OUTPUT o-ucaddr-create, OUTPUT o-ucaddr-update,
                         OUTPUT o-ucaddr-avail, OUTPUT o-ucaddr-successful).
                 
                    IF o-ucaddr-create  = NO  THEN DO:
                         EXPORT STREAM outward DELIMITER ";"
                                    PATIENT_RCD.PatientID ""
                                    "CREATE Error from pgm: SUBaddr-ucU !  " SKIP
                                    "  The returned o-ucaddr-id value = " o-ucaddr-id SKIP   
                                    "  ABORTing process.........".                            
                         ASSIGN Pat_NO_address_kount = (Pat_NO_address_kount + 1)
                                BYPASS_address_logic = 1.               
                         NEXT  Main_loop.
                    END.    /** IF value = 0 from utilities pgm. **/
                                           
                    ASSIGN  oldpat_addr_id = o-ucaddr-id. 
                            
                    EXPORT STREAM outward DELIMITER ";"
                            PATIENT_RCD.PatientID
                            oldpat_addr_id
                            PATIENT_RCD.PatAddress1
                            PATIENT_RCD.patcity
                            newstate
                            "addr_mstr Created.".
     
                    FIND FIRST addr_mstr
                        WHERE addr_mstr.addr_id = oldpat_addr_id
                            EXCLUSIVE-LOCK NO-ERROR.
    
                    IF AVAILABLE (addr_mstr) THEN         
                        ASSIGN  addr_mstr.addr_type = "billed to"
                                addr_mstr.addr_modified_by  = USERID("General")         /* 1dot5 */
                                addr_mstr.addr_modified_date = TODAY                    /* 1dot5 */
                                addr_mstr.addr_prog_name  = THIS-PROCEDURE:FILE-NAME.   /* 1dot5 */
                
                END.  /**  IF o-faddr-error = YES  **/
                               
        END.  /**  IF BYPASS_address_logic = 0  **/               
           
/******  need to create a people_mstr record from the RS PATIENT_RCD if one does not exist. ******/
            
/*        IF ITmessages = YES THEN        */
/*            DISPLAY "find patient" SKIP.*/
            
            RUN VALUE(SEARCH("SUBpat-findR.r"))                                 /* 1dot7 */         
                           (TRIM(prefix),
                            TRIM(firstname),
                            TRIM(middlename),
                            TRIM(lastname),
                            TRIM(suffix),
                            PATIENT_RCD.PatDOB,                                 /* 1dot7 */                          
                            OUTPUT o-fpe-peopleID,
                            OUTPUT o-fpe-addr_ID,
                            OUTPUT o-fpat-exist,
                            OUTPUT o-fpat-ran,
                            OUTPUT o-fpe-error).             
                                             
            IF o-fpe-peopleID  = 0 OR                                           /* 2dot1 */ 
               o-fpe-error  = YES  THEN DO:                                     /* 2dot1 */ 
                     
                IF PATIENT_RCD.Progress_Flag = "U" THEN                         /* 1dot8 */                      
                    ASSIGN PATIENT_RCD.Progress_Flag = "UL".                    /* 1dot8 */  
                ELSE                                                            /* 1dot8 */                      
                IF PATIENT_RCD.Progress_Flag = "A" THEN                         /* 1dot7 */
                    ASSIGN PATIENT_RCD.Progress_Flag = "AL".                    /* 1dot7 */
                ELSE                                                            /* 1dot7 */
                    ASSIGN PATIENT_RCD.Progress_Flag = "IL".                    /* 1dot7 */
                
/*                IF ITmessages = YES THEN                             */
/*                    DISPLAY "SQL Create People" SKIP                 */
/*                        SEARCH("RStP-SQL-create-people-mstr.r") SKIP.*/
                             
                RUN VALUE(SEARCH("RStP-SQL-create-people-mstr.r"))              /* 1dot7 */                  
                       (PATIENT_RCD.PatientID,
                        TRIM(firstname), TRIM(middlename), TRIM(lastname),
                        TRIM(prefix), TRIM(suffix), 
                        TRIM(prefname),                                         /* 2dot0 */
                        TRIM(PATIENT_RCD.PatCompany),
                        genderhold, 
                        TRIM(PATIENT_RCD.PatPhoneHome), TRIM(PATIENT_RCD.PatPhoneWork), 
                        TRIM(PATIENT_RCD.PatPhoneCell),
                        TRIM(PATIENT_RCD.PatFax), TRIM(PATIENT_RCD.PatEMail), "",
                        oldpat_addr_id,
                        "",                                                     /**  drop per Doug TRIM(PATIENT_RCD.PatContactPerson),  **/ 
                        PATIENT_RCD.PatDOB, 
                        0,                                                      /* second_addr_ID */  /* 2dot0 */             
                        OUTPUT o-ucpeople-id, 
                        OUTPUT o-ucpeople-create,
                        OUTPUT o-ucpeople-update,
                        OUTPUT o-ucpeople-avail,
                        OUTPUT o-ucpeople-successful).        
                
/*                IF ITmessages = YES THEN                        */
/*                    DISPLAY "Post RStP SQL create people." SKIP.*/
                                    
                ASSIGN  o-fpe-peopleID = o-ucpeople-id. 
              
                IF o-ucpeople-successful = NO THEN DO:
                        EXPORT STREAM outward DELIMITER ";"
                            PATIENT_RCD.PatientID ""
                            "CREATE Error from pgm: RStP-SQL-create-people-mstr !  " SKIP
                            "  The returned o-ucpeople-id value = " o-ucpeople-id SKIP
                            "  ABORTing process........." SKIP. 
                        NEXT  Main_loop.
                END.    /** IF value = NO from utilities pgm. **/
        
                EXPORT STREAM outward DELIMITER ";"
                        PATIENT_RCD.PatientID
                        o-fpe-peopleID
                        PATIENT_RCD.PatFirstName
                        PATIENT_RCD.PatLastName
                        PATIENT_RCD.PatDOB
                        "people_mstr Created.".
                                                
            END.    /**  o-fpe-peopleID  = 0  **/ 
                
            FIND patient_mstr WHERE patient_mstr.patient_ID = o-fpe-peopleID AND 
                                        patient_mstr.patient_deleted    = ?
                NO-LOCK NO-ERROR.
            
            IF  AVAILABLE (patient_mstr) THEN DO:
                    EXPORT STREAM outward DELIMITER ";"
                        PATIENT_RCD.PatientID
                        o-fpe-peopleID
                        PATIENT_RCD.PatFirstName
                        PATIENT_RCD.PatLastName
                        PATIENT_RCD.PatDOB
                        PATIENT_RCD.Progress_Flag
                        "ERROR-3! Patient_mstr found for an ADD of new patient - patient_mstr not created.".
            END.  /* IF  AVAILABLE (patient_mstr)   */
                
            IF  NOT AVAILABLE (patient_mstr) THEN DO:
            
/*                IF ITmessages = YES THEN                      */
/*                    DISPLAY "Manually creating patient?" SKIP.*/
            
                CREATE patient_mstr.
                ASSIGN 
                    patient_mstr.patient_ID             = o-fpe-peopleID  
                    patient_mstr.patient_notes          = PATIENT_RCD.PatNotes
/*                    patient_mstr.patient__char01        = PATIENT_RCD.PatContactPerson*/
/*                    patient_mstr.patient__char02        = PATIENT_RCD.WhoPaysBill*/
                    patient_mstr.patient_RP_ID          = o-fpe-peopleID 
                    patient_mstr.patient_doctor_ID      = 0  
                    patient_mstr.patient_cust_ID        = 0 
                    patient_mstr.patient_verified       = IF PATIENT_RCD.Pat_Verify_Flag = "Y" THEN 
                                                                YES
                                                          ELSE 
                                                                NO
                    patient_mstr.patient_created_by     = USERID("HHI")      
                    patient_mstr.patient_create_date    = TODAY 
                    patient_mstr.patient_modified_by    = USERID("HHI")
                    patient_mstr.patient_modified_date  = TODAY
                    patient_mstr.patient_prog_name      = THIS-PROCEDURE:FILE-NAME.      /* 1dot5 */
/*                    patient_mstr.patient__dec01         = PATIENT_RCD.PatientID.*/
                              
                EXPORT STREAM outward DELIMITER ";"
                            PATIENT_RCD.PatientID
                            o-fpe-peopleID     
                            PATIENT_RCD.PatFirstName 
                            PATIENT_RCD.PatLastName 
                            PATIENT_RCD.PatDOB
                            PATIENT_RCD.Progress_Flag
                            "patient_mstr Created - for an ADD of a new patient.".
                        
                ASSIGN Patient_Mstr_created_kount = (Patient_Mstr_created_kount + 1).
                
            END.  /*** IF NOT AVAILABLE (patient_mstr) ***/
                
            IF PATIENT_RCD.Progress_Flag = "U" THEN                             /* 1dot8 */                      
                ASSIGN PATIENT_RCD.Progress_Flag = "UL".                        /* 1dot8 */  
            ELSE                                                                /* 1dot8 */                      
            IF PATIENT_RCD.Progress_Flag = "A" THEN                             /* 1dot7 */
                ASSIGN PATIENT_RCD.Progress_Flag = "AL".                        /* 1dot7 */
            ELSE                                                                /* 1dot7 */
                ASSIGN PATIENT_RCD.Progress_Flag = "IL".                        /* 1dot7 */    
    END.  /**  IF  PATIENT_RCD.Progress_Flag = "A" OR  = ""  */
/* 1dot8 */
/*******************************************************************************/
/*******************************************************************************/
 
       
END.  /*** Main_loop: of 4ea. patient_rcd ***/ 

/*    IF ITmessages = YES THEN             */
/*            DISPLAY "Final Section" SKIP.*/
            
EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE." SKIP (2).

EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Total Input Records Processed." SKIP (2).

EXPORT STREAM outward DELIMITER ";"    
    Pat_DOB_invalid_kount "DOB invalid format-bypassed." SKIP (2).   
EXPORT STREAM outward DELIMITER ";"    
    Pat_DOB_Blank_kount "DOB Blank-bypassed." SKIP (2).


EXPORT STREAM outward DELIMITER ";"
    Pat_NOT_in_People_mstr "ERROR-1! Patients NOT in People_Mstr."  SKIP (2).       
EXPORT STREAM outward DELIMITER ";"
    Pat_has_Tests_kount "ERROR-2! Patients has Tests Records-bypassed." SKIP (2).         
EXPORT STREAM outward DELIMITER ";"
    Pat_NO_Tests_kount "DELETE - Patients with NO Tests-deleted." SKIP (2).      
EXPORT STREAM outward DELIMITER ";"
    PAT_format_error "ERROR! - input field in error".

/* 2dot */
EXPORT STREAM outward DELIMITER ";" "".
EXPORT STREAM outward DELIMITER ";"
    BadBCountry-kount    "Country not found in ISO country_mstr.".
EXPORT STREAM outward DELIMITER ";"
    BadBState-kount      "State not found in ISO state_mstr.".
EXPORT STREAM outward DELIMITER ";"
    BadPState-kount      "Providence not found in ISO state_mstr.".
EXPORT STREAM outward DELIMITER ";" "".
/* 2dot */
      
EXPORT STREAM outward DELIMITER ";"
    Pat_processing_kount "Records processing." SKIP (2). 
EXPORT STREAM outward DELIMITER ";"
    Pat_NO_address_kount "Warning-1.  Missing input(s) address (blank) information.  Address-Master will NOT be created." SKIP (2). 
EXPORT STREAM outward DELIMITER ";"
    Patient_Mstr_created_kount "Patient Masters created." SKIP (2).

EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS") SKIP (2).
   
OUTPUT STREAM outward CLOSE.

/*IF recordsprocessed > 0 THEN*/
    OS-COMMAND SILENT 
        VALUE(cmdname)  
        VALUE(emailaddr)
        VALUE(messagetxt) 
        VALUE(subjtxt) 
        VALUE(cmdparams) 
        VALUE(errlog).

/*    IF ITmessages = YES THEN        */
/*            DISPLAY "The End." SKIP.*/
