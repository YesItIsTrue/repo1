
/*------------------------------------------------------------------------
    File        : RStP-patient-UC.p
    Purpose     : 

    Syntax      :

    Description : One time pgm to create the Customer records.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Thu Jan 01, 2014
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
    
    Updated:        25/Jan/16
    Version:        1.3
    Author:         Harold Luttrell, Sr.
    Description:    Added check for patient_mstr.patient__char02 
                        = "NEW PATIENT" to bypass the record.   
    identified by:  /* 1dot3 */    
        
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
DEFINE VARIABLE updated_cust_ID AS INTEGER NO-UNDO.
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
    INITIAL "C:\Progress\WRK\RStP-PATIENT_RCD-UC-log.txt" NO-UNDO.
 
OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name: " THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at: " TODAY STRING(TIME, "HH:MM:SS").
 EXPORT STREAM outward DELIMITER ";"
    "patient_mstr.Patient_ID" 
    "Error Message"
    "Who Pays Bill"
    " "
    "people_mstr.people_id".  

/* ********************  Preprocessor Definitions  ******************** */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                               

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                

{emailaddr-USERID.i}.                                                           /* 1dot4 */
 
/* ***************************  Main Block  *************************** */

Main_loop:    
FOR EACH patient_mstr WHERE patient_mstr.patient__char02 <> "" AND 
        patient_mstr.patient_ID > 0  :                                      /* 1dot3 */
     
    ASSIGN  recordsprocessed = recordsprocessed + 1.                                 
    ASSIGN  firstname = "oops" middlename = "oops.." lastname = "oops.." 
            prefix = "oops..." suffix = "oops...." title_desc = "oops....."
            genderhold = ?.                                                     /* 2dot0 */ 
     
/**  4th set of records.  **/                 
    /********  create a people_mstr record for the customer from the whopaysbill field. *******/
                                                     
 /*   IF PATIENT_RCD.whopaysbill <> "" AND PATIENT_RCD.whopaysbill <> "NEW PATIENT" THEN DO:  */

        IF patient_mstr.patient__char02 = "NEW" OR 
           patient_mstr.patient__char02 = "NEW PATIENT" THEN DO:            /* 1dot3 */
            ASSIGN patient_mstr.patient__char02 = "".
            NEXT Main_loop.
        END.

        RUN VALUE(SEARCH("SUB-UnString-Name.r"))                                /* 1dot2 */
                        (patient_mstr.patient__char02,                 /* input_name_big_string, */
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
                   patient_mstr.patient__char02.
                   
                 ASSIGN PCPN_format_error = (PCPN_format_error + 1).
                 ASSIGN patient_mstr.patient__char02 = "".
                 NEXT Main_loop. 
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

        RUN VALUE(SEARCH("SUBpeop-findR.r"))                                    /* 1dot2 */
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
                        "",              /* title */         
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
                   patient_mstr.patient__char02.
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
                    "people_mstr Created without their DOB.".
      
        END.    /**  o-fpe-peopleID  = 0  **/  

                                         
        FIND people_mstr WHERE people_mstr.people_id = o-fpe-peopleID  AND 
                               people_mstr.people_deleted = ?
            EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE (people_mstr) THEN DO:

            ASSIGN patient_mstr.patient_cust_ID       = people_mstr.people_id
                   patient_mstr.patient_modified_date = TODAY
                   patient_mstr.patient_modified_by   = USERID("HHI")
                   patient_mstr.patient_prog_name     = THIS-PROCEDURE:FILE-NAME. 
                     
            ASSIGN updated_cust_ID = (updated_cust_ID + 1).
            
            EXPORT STREAM outward DELIMITER ";"
                    o-fpe-peopleID
                    people_mstr.people_id
                    TRIM(firstname)
                    TRIM(lastname)
                    "?"
                    "patient_mstr CUST-ID updated.".
                    
            ASSIGN patient_mstr.patient__char02 = "".   
                             
            ASSIGN people_mstr.people_title = title_desc.
            ASSIGN people_mstr.people_prefix = prefix. 
            ASSIGN people_mstr.people_suffix = suffix. 
            ASSIGN people_mstr.people_prefname = prefname.
            ASSIGN people_mstr.people_gender   = genderhold.                    /* 2dot0 */
                
            ASSIGN  people_mstr.people_modified_date        = TODAY
                    people_mstr.people_modified_by          = USERID("General")
                    people_mstr.people_prog_name            = THIS-PROCEDURE:FILE-NAME.
                                                       
            NEXT Main_loop.
        END.    /**  IF AVAILABLE (people_mstr)  **/
           
        IF  lastname <> people_mstr.people_lastname THEN DO: 
            EXPORT STREAM outward DELIMITER ";"
                patient_mstr.Patient_ID 
               "ERROR!  Type-O error or unexpected error. "
               patient_mstr.patient__char02 " <> " String_Pat_Name.
             ASSIGN type_O_error = (type_O_error + 1).
             NEXT  Main_loop. 
        END.  /** patient_mstr.patient__char02  **/  
                       
/**  5th set of records.  **/      
    /********  create a cust_mstr record ********/

        RUN VALUE(SEARCH("SUBcust-findR.r"))                                    /* 1dot2 */ 
                       (TRIM(prefix),
                        TRIM(firstname),
                        TRIM(middlename),
                        TRIM(lastname),
                        TRIM(suffix),
                        "",
                        OUTPUT o-fcust-ID,
                        OUTPUT o-fcust-addr-ID,
                        OUTPUT o-fcust-exist,
                        OUTPUT o-fcust-ran,
                        OUTPUT o-fcust-error). 
     
     IF o-fcust-ID = 0 THEN DO: 

        RUN VALUE(SEARCH("SUBcust-ucU.r"))                                      /* 1dot2 */ 
                       (people_mstr.people_id,
                        "", 0, "", 0, 0,
                        OUTPUT o-uccust-id,
                        OUTPUT o-uccust-create,
                        OUTPUT o-uccust-update,
                        OUTPUT o-uccust-error,
                        OUTPUT o-uccust-successful). 

        ASSIGN  o-fcust-ID = o-uccust-id.
                                  
     END.  /**  IF o-fcust-ID = 0  **/    
     
/**  6th set of records.  **/    
    /********  create a scust_shadow record to go with the cust_mstr  ********/
        
        RUN VALUE(SEARCH("SUBscust-findR.r"))                                   /* 1dot2 */                                              
                       (TRIM(prefix),
                        TRIM(firstname),
                        TRIM(middlename),
                        TRIM(lastname),
                        TRIM(suffix),
                        "",
                        OUTPUT o-fshadc-ID,
                        OUTPUT o-fshadc-addr-ID,
                        OUTPUT o-fshadc-magento-ID,
                        OUTPUT o-fshadc-exist,
                        OUTPUT o-fshadc-ran,
                        OUTPUT o-fshadc-error). 
   
     IF o-fshadc-exist = NO THEN DO: 
        
        RUN VALUE(SEARCH("SUBscust-ucU.r"))                                     /* 1dot2 */                                              
                       (o-fshadc-ID,
                        "", NO, 0,
                        OUTPUT o-ucscust-id,
                        OUTPUT o-ucscust-create,
                        OUTPUT o-ucscust-update,
                        OUTPUT o-ucscust-error,
                        OUTPUT o-ucscust-successful). 

        ASSIGN  o-fshadc-ID = o-ucscust-id.
                                
     END.  /**  IF o-fcust-ID = 0  **/
     
END.  /*** of 4ea. patient_rcd ***/ 

EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE.".

EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Total Input Records Processed.". 
EXPORT STREAM outward DELIMITER ";"
    no_PCPLN "NO Who-Pays-Bill-Name Last Name.".   
EXPORT STREAM outward DELIMITER ";"
    PCPN_format_error "Who Pays Bill Name not formated correctly for computers.". 
EXPORT STREAM outward DELIMITER ";"
    updated_cust_ID "Total patient_mstr CUST-ID updated.".   
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
        
