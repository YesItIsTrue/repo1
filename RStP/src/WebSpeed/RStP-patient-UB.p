
/*------------------------------------------------------------------------
    File        : RStP-patient-UB.p
    Purpose     : 

    Syntax      :

    Description : One time pgm to create the Responsible Person and Customer records.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Sat Dec 27 19:52:54 CST 2014
    Notes       :
          
    Updated:        13/Apr/15
    Version:        1.1
    Author:         Harold Luttrell, Sr.
    Description:    Added code for updating data, not only 
                        creating data.
    Identified by:  /* 1dot1 */
    
    Updated:        12/Sept/15
    Version:        1.2
    Author:         Harold Luttrell, Sr.
    Description:    Changed code to use the RUN VALUE(SEARCH) code 
                        instead of using the long path name and to use
                        the new SUBpat-findR.p requiring the DOB as input also.
    Identified by:  /* 1dot2 */
    
    Version 2.0 - Harold Luttrell - 24/May/16.
            Initialize the genderhold variable to ?.  
            Added code to set the genderhold logical from the SUB-UnString-Name.p program.
            Identified by:  /* 2dot0 */
                                         
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/*  Include code.  */

{o-depot-definenames.i}.                                                        /*** depot output define variables ***/
  
/** useful for all RSTP code **/
DEFINE VARIABLE loadedlist AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
       
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO. 

/* DEFINE VARIABLE x                   AS CHARACTER FORMAT "x(70)" NO-UNDO. */
DEFINE VARIABLE String_Pat_Name     AS CHARACTER FORMAT "x(70)" NO-UNDO.  
DEFINE VARIABLE prefix LIKE people_mstr.people_prefix NO-UNDO.
DEFINE VARIABLE firstname LIKE people_mstr.people_firstname NO-UNDO.
DEFINE VARIABLE middlename LIKE people_mstr.people_midname NO-UNDO.
DEFINE VARIABLE lastname LIKE people_mstr.people_lastname NO-UNDO.
DEFINE VARIABLE prefname LIKE people_mstr.people_prefname NO-UNDO.
DEFINE VARIABLE suffix LIKE people_mstr.people_suffix NO-UNDO.
DEFINE VARIABLE title_desc LIKE people_mstr.people_suffix NO-UNDO.

DEFINE VARIABLE genderhold AS LOG NO-UNDO.
DEFINE VARIABLE no_PCPLN AS INTEGER NO-UNDO.
DEFINE VARIABLE PCPN_format_error AS INTEGER NO-UNDO.
DEFINE VARIABLE updated_RP_ID AS INTEGER NO-UNDO.
DEFINE VARIABLE type_O_error AS INTEGER NO-UNDO.

DEFINE VARIABLE it-message      AS LOGICAL INITIAL NO   NO-UNDO.

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.
 
messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
    
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\Progress\WRK\RStP-PATIENT_RCD-UB-log.txt" NO-UNDO.

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name: " THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at: " TODAY STRING(TIME, "HH:MM:SS").
 EXPORT STREAM outward DELIMITER ";"
    "patient_mstr.Patient_ID" 
    "Error Message"
    "PatContactPerson"
    " "
    "people_mstr.people_id".  

/* ********************  Preprocessor Definitions  ******************** */
/*&SCOPED-DEFINE this-table   patient_mstr*/

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.               

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                

{emailaddr-USERID.i}.                                                           /* 1dot4 */
 
/* ***************************  Main Block  *************************** */

Main_loop:    
FOR EACH patient_mstr WHERE patient_mstr.patient__char01 <> "" :  /*  AND patient_mstr.patient_ID < 51  :    */
     
    ASSIGN recordsprocessed = recordsprocessed + 1.                                 
    ASSIGN  firstname = "oops" middlename = "oops.." lastname = "oops.." 
            prefix = "oops..." suffix = "oops...." title_desc = "oops....."
            genderhold = ?.                                                     /* 2dot0 */
            
/**  3rd set of records.  **/ 
  /* work on the prefix, then title, then any suffix - in the PatContactPerson field. */

        IF patient_mstr.patient__char01 = "NEW" OR 
            patient_mstr.patient__char01 = "NEW PATIENT" THEN DO: 
            ASSIGN patient_mstr.patient__char01 = "".
            NEXT Main_loop.
        END.

        RUN VALUE(SEARCH("SUB-UnString-Name.r"))                                /* 1dot2 */                                                           
                        (patient_mstr.patient__char01,                 /* input_name_big_string, */
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
                    patient_mstr.Patient_ID 
                   "ERROR! - input field in error." 
                   o-field-in-error
                   patient_mstr.patient__char01.
                   
                 ASSIGN patient_mstr.patient__char01 = "".
                 ASSIGN PCPN_format_error = (PCPN_format_error + 1).
                 NEXT  Main_loop. 
        END.  /** IF  o-unstring-error = YES  **/          

        IF  TRIM(lastname) = "" THEN  DO: 
            ASSIGN no_PCPLN = (no_PCPLN + 1).        
            EXPORT STREAM outward DELIMITER ";"
                    patient_mstr.Patient_ID
                    patient_mstr.patient__char01
                    TRIM(lastname)
                    "?"
                    "NO PatContactPerson Last Name.".
            NEXT  Main_loop.           
        END.  /*  IF  TRIM(lastname) = ""  */

        RUN VALUE(SEARCH("SUBpeop-findR.r"))                                     /* 1dot2 */                                                           
                       (TRIM(prefix),
                        TRIM(firstname),
                        TRIM(middlename),
                        TRIM(lastname),
                        TRIM(suffix),
                        OUTPUT o-fpe-peopleID,
                        OUTPUT o-fpe-addr_ID,
                        OUTPUT o-fpat-ran,
                        OUTPUT o-fpe-error).
                            
        IF o-fpe-peopleID  = 0 THEN DO:

            RUN VALUE(SEARCH("SUBpeop-ucU.r"))                                  /* 1dot2 */ 
                       (0,   
                        TRIM(firstname), TRIM(middlename), TRIM(lastname),
                        TRIM(prefix), TRIM(suffix), "",
                        genderhold, 
                        "", "", "",
                        "", "", "",
                        0,
                        "", 
                        ?,
                        0, 
                        prefname,                                               /* 1dot2 */     
                        "",                                     /* title */         
                        OUTPUT o-ucpeople-id,
                        OUTPUT o-ucpeople-create,
                        OUTPUT o-ucpeople-update,
                        OUTPUT o-ucpeople-avail,
                        OUTPUT o-ucpeople-successful).        
  
            IF o-ucpeople-successful = NO THEN DO:
                   EXPORT STREAM outward DELIMITER ";"
                    patient_mstr.Patient_ID 
                    "CREATE Error from pgm: SUBpeop-ucU !  " SKIP
                    "  The returned o-ucpeople-id value = " o-ucpeople-id SKIP
                    "  ABORTing process........." SKIP 
                   patient_mstr.patient__char01.
                LEAVE.
            END.    /** IF value = NO from utilitie SUBpeop-ucU.r pgm. **/
        
            ASSIGN  o-fpe-peopleID = o-ucpeople-id
                    o-fcust-ID     = o-ucpeople-id. 
                    
            EXPORT STREAM outward DELIMITER ";"
                    o-fpe-peopleID
                    o-fpe-peopleID
                    TRIM(firstname)
                    TRIM(lastname)
                    "?"
                    "people_mstr Created. NO DOB.".
                    
        END.    /**  o-fpe-peopleID  = 0  **/  
                                        
        FIND people_mstr WHERE people_mstr.people_id = o-fpe-peopleID  AND 
                               people_mstr.people_deleted = ? 
            EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE (people_mstr) THEN DO:

            ASSIGN patient_mstr.patient_RP_ID         = people_mstr.people_id
                   patient_mstr.patient_modified_date = TODAY
                   patient_mstr.patient_modified_by   = USERID("HHI")
                   patient_mstr.patient_prog_name     = THIS-PROCEDURE:FILE-NAME.
                     
            ASSIGN updated_RP_ID = (updated_RP_ID + 1).
             
            EXPORT STREAM outward DELIMITER ";"
                    o-fpe-peopleID
                    people_mstr.people_id
                    TRIM(firstname)
                    TRIM(lastname)
                    "?"
                    "patient_mstr patient_RP_ID Updated.".
                    
            ASSIGN patient_mstr.patient__char01 = "".
            
            ASSIGN people_mstr.people_title     = title_desc.
            ASSIGN people_mstr.people_prefix    = prefix. 
            ASSIGN people_mstr.people_suffix    = suffix. 
            ASSIGN people_mstr.people_prefname  = prefname.
            ASSIGN people_mstr.people_gender    = genderhold.                   /* 2dot0 */
            
            ASSIGN people_mstr.people_modified_date        = TODAY
                   people_mstr.people_modified_by          = USERID("General")
                   people_mstr.people_prog_name            = THIS-PROCEDURE:FILE-NAME. 
                   
            EXPORT STREAM outward DELIMITER ";"
                    o-fpe-peopleID
                    people_mstr.people_id
                    prefix
                    suffix
                    title_desc
                    "people_mstr prefix, suffix, title-desc, prefname, gender updated.".        /* 2dot0 */
                                                      
            NEXT Main_loop.
        END.    /**  IF AVAILABLE (people_mstr)  **/
           
        IF  lastname <> people_mstr.people_lastname THEN DO: 
            EXPORT STREAM outward DELIMITER ";"
                patient_mstr.Patient_ID 
               "ERROR!  Type-O error or unexpected error. "
               patient_mstr.patient__char01 " <> " String_Pat_Name.
             ASSIGN type_O_error = (type_O_error + 1).
             NEXT  Main_loop. 
        END.  /** patient_mstr.patient__char01  **/  
     
        EXPORT STREAM outward DELIMITER ";"
                patient_mstr.Patient_ID 
               "  Notify Solsource IT - thank you. " 
               patient_mstr.patient__char01.             
 
END.  /*** of 4ea. patient_rcd ***/ 

EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE.".

EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Total Input Records Processed.".
EXPORT STREAM outward DELIMITER ";"
    no_PCPLN "NO PatContactPerson Last Name.".     
EXPORT STREAM outward DELIMITER ";"
    PCPN_format_error "PatContactPerson Name not formated correctly for computers.". 
EXPORT STREAM outward DELIMITER ";"
    updated_RP_ID "Total patient_mstr RP-ID updated.".   
EXPORT STREAM outward DELIMITER ";"
    type_O_error "Type-O error or Name sizes are not the same.".

EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
   
OUTPUT STREAM outward CLOSE.

/*IF recordsprocessed > 0 THEN*/
    OS-COMMAND SILENT 
        VALUE(cmdname)  
        VALUE(emailaddr)
        VALUE(messagetxt) 
        VALUE(subjtxt) 
        VALUE(cmdparams) 
        VALUE(errlog).
