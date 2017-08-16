
/*------------------------------------------------------------------------
    File        : UTIL-renumber-people-U.p
    Purpose     : 

    Syntax      :

    Description : Program to renumber the people_id's that exist in other tables based on what the data was previously as 
                    shown by the UTIL EXPORT routines from the 03/Jun/16 run.

    Author(s)   : Doug Luttrell
    Created     : Thu Jun 09 09:21:09 EDT 2016
    Notes       :
        
  ----------------------------------------------------------------------
  Revision History:
  -----------------
  1.0 - written by DOUG LUTTRELL on 09/Jun/16.  Original Version.
  1.1 - written by DOUG LUTTRELL on 02/Jul/16.  Turns out that the program could change things and then change them
            again later on if the first change moved a people_id out into a higher number and then later that higher 
            number came along in the FOR EACH and got changed back to something else.  DOH!  Also it was possible to 
            change the people_ID, which defeats the whole purpose of finding the new people_IDs.  In this program the  
            change was around the reset functions on the __log fields (mostly).  Not marked.  
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE v-foundID LIKE people_mstr.people_id NO-UNDO.
DEFINE VARIABLE v-foundaddrID LIKE people_mstr.people_addr_id NO-UNDO.
DEFINE VARIABLE v-err AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-patran AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-custexist AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-custran AS LOGICAL NO-UNDO.

DEFINE VARIABLE o-result AS CHARACTER NO-UNDO.

DEFINE VARIABLE v-created AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-updated AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-avail AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-success AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-error AS LOGICAL NO-UNDO.

DEFINE VARIABLE updatemode AS LOGICAL LABEL "Update Mode?" NO-UNDO.

DEFINE VARIABLE infile AS CHARACTER FORMAT "x(60)" LABEL "Input File" 
    INITIAL "C:\PROGRESS\WRK\exports\Step_1dot25\EXPORTpeople_mstrR-2.txt" NO-UNDO.

DEFINE STREAM outward.
OUTPUT STREAM outward TO "C:\PROGRESS\WRK\renumber-errors.txt".

DEFINE TEMP-TABLE tpm LIKE people_mstr.         /** Temporary People Master **/

DEFINE VARIABLE v-totcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-currcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-divisor AS INTEGER NO-UNDO.
DEFINE VARIABLE v-fieldsize AS INTEGER INITIAL 18 NO-UNDO.
DEFINE VARIABLE v-progbar AS CHARACTER FORMAT "x(18)" NO-UNDO.

DEFINE VARIABLE statmsg AS CHARACTER FORMAT "x(18)" EXTENT 4 NO-UNDO.

ASSIGN 
    statmsg[1] = "Loading File"
    statmsg[2] = "Checking"
    statmsg[4] = "Dumping".

FORM SKIP(1)
    updatemode COLON 15 SKIP(1)
    infile COLON 15 SKIP(1)
        WITH FRAME inward SIDE-LABELS WIDTH 80.
        
FORM SKIP(1)
    statmsg[1] statmsg[2] statmsg[3] statmsg[4] SKIP(1)
        WITH FRAME a NO-LABELS WIDTH 80
            TITLE "--> Progress Indicators <--".
    
    
/* ***************************  Main Block  *************************** */
UPDATE
    updatemode infile 
        WITH FRAME inward.

DISPLAY statmsg[1]
    WITH FRAME a.
    
/************  Reset the __log fields  ****************/

/** General.db prep **/
FOR EACH cust_mstr WHERE cust_mstr.cust__log01 = YES EXCLUSIVE-LOCK: 
    
    cust_mstr.cust__log01 = NO.
    
END.  /** of 4ea. cust_mstr **/

FOR EACH grp_mstr WHERE grp_mstr.grp__log01 = YES EXCLUSIVE-LOCK: 
    
    grp_mstr.grp__log01 = NO.
   
END.  /** of 4ea. grp_mstr **/

FOR EACH trh_hist WHERE trh_hist.trh__log01 = YES EXCLUSIVE-LOCK: 
    
    trh_hist.trh__log01 = NO.
    
END.  /** of 4ea. trh_hist **/

FOR EACH att_files WHERE att_files.att__log01 = YES EXCLUSIVE-LOCK: 
    
    att_files.att__log01 = NO.
    
END.  /** of 4ea. att_files **/


/** HHI.db prep **/
FOR EACH TK_mstr WHERE TK_mstr.TK__log01 = YES OR TK_mstr.TK__log02 = YES EXCLUSIVE-LOCK: 
    
    ASSIGN 
        TK_mstr.tk__log01   = NO 
        TK_mstr.tk__log02   = NO.
        
END.  /** of 4ea. tk_mstr **/

FOR EACH catch_all WHERE catch_all.catch__log01 = YES EXCLUSIVE-LOCK: 
    
    catch_all.catch__log01 = NO. 
    
END.  /** of 4ea. catch_all **/

FOR EACH doctor_mstr WHERE doctor_mstr.doctor__log01 = YES EXCLUSIVE-LOCK: 
    
    doctor_mstr.doctor__log01 = NO.
    
END.  /** of 4ea. doctor_mstr **/

FOR EACH HHI.lab_mstr WHERE lab_mstr.lab__log01 = YES EXCLUSIVE-LOCK: 
    
    lab_mstr.lab__log01 = NO. 
    
END.  /** of 4ea. lab_mstr **/

FOR EACH orig_catch_all WHERE orig_catch_all.orig__log01 = YES EXCLUSIVE-LOCK: 
    
    orig_catch_all.orig__log01 = NO. 
    
END.  /** of 4ea. orig_catch_all **/

FOR EACH patient_mstr WHERE patient_mstr.patient__log01 = YES OR 
    patient_mstr.patient__dec02 > 0 OR 
    patient_mstr.patient__dec03 > 0 OR 
    patient_mstr.patient__dec04 > 0 EXCLUSIVE-LOCK: 
        
    ASSIGN 
        patient_mstr.patient__log01 = NO
        patient_mstr.patient__dec02 = 0
        patient_mstr.patient__dec03 = 0
        patient_mstr.patient__dec04 = 0.
        
END.  /** of 4ea. patient_mstr **/

FOR EACH pcl_det WHERE pcl_det.pcl__log01 = YES EXCLUSIVE-LOCK: 
     
     pcl_det.pcl__log01 = NO.
     
END.  /** of 4ea. pcl_det **/

FOR EACH scust_shadow WHERE scust_shadow.scust__log01 = YES OR 
    scust_shadow.scust__log02 = YES EXCLUSIVE-LOCK:
        
    ASSIGN 
        scust_shadow.scust__log01 = NO 
        scust_shadow.scust__log02 = NO. 
        
END.  /** of 4ea. scust_shadow **/
    
    
    

/************  END OF __log field reset ***************/
    
    
/*INPUT FROM "C:\PROGRESS\WRK\allpeople.txt".*/

INPUT FROM VALUE(infile).

REPEAT: 
    
    CREATE tpm.
    
    IMPORT DELIMITER ";" tpm.
    
    ASSIGN 
        v-totcount  = v-totcount + 1.
    
END.  

INPUT CLOSE.

DISPLAY statmsg[2]
    WITH FRAME a.
    
check-loop: 
FOR EACH tpm: 

    ASSIGN 
        v-foundID       = 0 
        v-foundaddrID   = 0
        v-err           = NO  
        v-patran        = NO
        v-custexist     = NO 
        v-custran       = NO.
    
    IF tpm.people_id = 0 THEN DO: 
        
        ASSIGN 
            v-totcount  = v-totcount - 1.
            
        DELETE tpm.
        
        NEXT check-loop.
        
    END.  /** of if people_id = 0 **/
    
    
    ASSIGN 
        v-currcount = v-currcount + 1
        v-divisor   = v-totcount / v-fieldsize.
    
/*    MESSAGE v-totcount " - " v-fieldsize " - " v-currcount " - " v-divisor.*/
    
    IF (v-currcount MODULO v-divisor) = 0 THEN DO:  
         
        ASSIGN 
            v-progbar = v-progbar + CHR(219)
            statmsg[3]  = statmsg[3] + CHR(177).
        
        DISPLAY statmsg[3]
            WITH FRAME a.
        
    END.  /** if modulo = 0 **/
    
    IF tpm.people_dob <> ? THEN DO: 
        
        RUN VALUE(SEARCH("SUBpeop-datefindR.r"))
            (tpm.people_prefix, 
             tpm.people_firstname, 
             tpm.people_midname, 
             tpm.people_lastname, 
             tpm.people_suffix, 
             tpm.people_dob,
             OUTPUT v-foundID, 
             OUTPUT v-foundaddrID,
             OUTPUT v-err, 
             OUTPUT v-patran).
    
    END.  /** of tpm.people_dob <> ? **/
    
    IF v-foundID = 0 /* AND v-patran = YES */ THEN DO:
    
        ASSIGN 
            v-foundID       = 0 
            v-foundaddrID   = 0
            v-err           = NO  
            v-patran        = NO
            v-custexist     = NO 
            v-custran       = NO.    
      
        IF tpm.people_email <> "" THEN DO: 
            
            RUN VALUE(SEARCH("SUBcust-findR.r"))
                (tpm.people_prefix, 
                 tpm.people_firstname, 
                 tpm.people_midname, 
                 tpm.people_lastname, 
                 tpm.people_suffix, 
                 tpm.people_email, 
                 OUTPUT v-foundID, 
                 OUTPUT v-foundaddrID,
                 OUTPUT v-custexist,
                 OUTPUT v-custran,
                 OUTPUT v-err).        
    
        END.  /** of if people_email <> "" **/
        
        IF v-foundID = 0 /* AND v-custran = YES */ THEN DO: 
    
            ASSIGN 
                tpm.people__char01  = "CREATE"
                tpm.people__char02  = IF tpm.people_dob <> ? AND tpm.people_email <> "" THEN 
                                        "BOTH"
                                      ELSE IF tpm.people_dob <> ? THEN 
                                        "PATIENT"
                                      ELSE IF tpm.people_email <> "" THEN 
                                        "CUSTOMER"
                                      ELSE 
                                        "OTHER"
                tpm.people__dec03   = tpm.people__dec03 + 1.
        
            ASSIGN 
                v-foundID   = 0
                v-created   = NO
                v-updated   = NO
                v-avail     = NO
                v-success   = NO.
            
            IF updatemode = YES THEN DO: 
                    
                RUN VALUE(SEARCH("SUBpeop-ucU.r"))
                    (0, 
                     tpm.people_firstname, 
                     tpm.people_midname, 
                     tpm.people_lastname, 
                     tpm.people_prefix, 
                     tpm.people_suffix,  
                     tpm.people_company, 
                     tpm.people_gender, 
                     tpm.people_homephone,  
                     tpm.people_workphone, 
                     tpm.people_cellphone, 
                     tpm.people_fax, 
                     tpm.people_email, 
                     tpm.people_email2, 
                     tpm.people_addr_id, 
                     tpm.people_contact, 
                     tpm.people_dob, 
                     tpm.people_second_addr_ID, 
                     tpm.people_prefname,
                     "",
                     OUTPUT v-foundID, 
                     OUTPUT v-created,
                     OUTPUT v-updated, 
                     OUTPUT v-avail, 
                     OUTPUT v-success).            
                       
                IF v-success = YES THEN DO: 
                    
                    IF tpm.people__char02 = "BOTH" OR tpm.people__char02 = "PATIENT" THEN DO: 
                        
                        RUN VALUE(SEARCH("SUBpat-ucU.r"))
                            (v-foundID,
                             "",                /* old condition field */
                             "",                /* notes */
                             0,                 /* RP ID */
                             0,                 /* doctor_ID */
                             0,                 /* cust_ID --- not necessarily this person even if BOTH */
                             NO,                /* verified? */
                             OUTPUT v-foundID,
                             OUTPUT v-created,
                             OUTPUT v-updated, 
                             OUTPUT v-error, 
                             OUTPUT v-success).
    
                    END.  /** of BOTH or PATIENT --- create patient_mstr **/
                                    
                    IF tpm.people__char02 = "BOTH" OR tpm.people__char02 = "CUSTOMER" THEN DO: 
                        
                        RUN VALUE(SEARCH("SUBcust-ucU.r"))
                            (v-foundID,
                             "",                    /* CC Nbr */
                             0,                     /* Security Code */
                             "",                    /* Card Type */
                             0,                     /* Exp Month */
                             0,                     /* Exp Year */
                             OUTPUT v-foundID,
                             OUTPUT v-created,
                             OUTPUT v-updated, 
                             OUTPUT v-error, 
                             OUTPUT v-success).
                             
                        RUN VALUE(SEARCH("SUBscust-ucU.r"))
                            (v-foundID,
                             "",                    /* Magento ID */
                             ?,                     /* Professional */
                             "",                    /* Doctor_ID */
                             OUTPUT v-foundID,
                             OUTPUT v-created,
                             OUTPUT v-updated, 
                             OUTPUT v-error, 
                             OUTPUT v-success).                         
                             
                    END.  /** of BOTH or CUSTOMER --- create cust_mstr **/
                    
                END.  /*** of if v-success = yes --- create records ***/

            END.  /** of if updatemode = yes **/
                                
            ASSIGN 
                v-foundID   = 0
                v-created   = NO
                v-updated   = NO
                v-avail     = NO
                v-success   = NO.
        
        END.    /** of if v-foundid = 0 and v-custran = yes --- customer record ***/
        
        ELSE IF v-foundID <> tpm.people_ID THEN DO: 
            
            ASSIGN 
                tpm.people__char01  = "CHANGE"
                tpm.people__char02  = IF tpm.people_dob <> ? AND tpm.people_email <> "" THEN 
                                        "BOTH"
                                      ELSE IF tpm.people_dob <> ? THEN 
                                        "PATIENT"
                                      ELSE IF tpm.people_email <> "" THEN 
                                        "CUSTOMER"
                                      ELSE 
                                        "OTHER"
                tpm.people__dec03   = tpm.people__dec03 + 1
                tpm.people__dec02   = v-foundID.
        
            IF updatemode = YES THEN DO: 
                
                RUN VALUE(SEARCH("SUB-convert_ID-U.r"))
                    (tpm.people_id, 
                     v-foundID,
                     OUTPUT o-result).
            
            END.  /** of updatemode = yes **/
            
            EXPORT STREAM outward
                tpm.people_id v-foundID o-result.
                
            ASSIGN 
                o-result = "".
                
        END.  /** of else if v-foundID <> people_id --- customer record **/         
                 
                 
        ELSE IF v-foundID = tpm.people_id THEN DO: 
            
            ASSIGN 
                tpm.people__char01  = "MATCH"            
                tpm.people__char02  = "CUSTOMER"
                tpm.people__dec03   = tpm.people__dec03 + 1.
                
        END.  /** of else if v-foundID = people_id **/
        
        ELSE DO:
            
            ASSIGN 
                tpm.people__char01  = "UNKNOWN"
                tpm.people__dec03   = tpm.people__dec03 + 1.
                
        END.  /** of else do **/                 
                 
    END.  /** of if v-foundID = 0 and v-patran = YES **/
    
    ELSE IF v-foundID <> tpm.people_id THEN DO: 
    
        ASSIGN 
            tpm.people__char01  = "CHANGE"
            tpm.people__char02  = "PATIENT"
            tpm.people__dec03   = tpm.people__dec03 + 1
            tpm.people__dec02   = v-foundID.
    
        IF updatemode = YES THEN DO: 
            
            RUN VALUE(SEARCH("SUB-convert_ID-U.r"))
                (tpm.people_id, 
                 v-foundID,
                 OUTPUT o-result).
        
        END.  /** of if updatemode = yes **/
        
        EXPORT STREAM outward
            tpm.people_id v-foundID o-result.
            
        ASSIGN 
            o-result = "".
    
    END.  /** of else if v-foundID <> people_ID **/
    
    ELSE IF v-foundID = tpm.people_id THEN DO: 
        
        ASSIGN 
            tpm.people__char01  = "MATCH"            
            tpm.people__char02  = "PATIENT"
            tpm.people__dec03   = tpm.people__dec03 + 1.
            
    END.  /** of else if v-foundID = people_id **/
    
    ELSE DO:
        
        ASSIGN 
            tpm.people__char01  = "UNKNOWN"
            tpm.people__dec03   = tpm.people__dec03 + 1.
            
    END.  /** of else do **/
    
END.  /*** of 4ea. tpm --- check-loop ***/

DISPLAY statmsg[4]
    WITH FRAME a.

OUTPUT TO "C:\progress\wrk\allpeople-modified.txt".

EXPORT DELIMITER ";"
    "people_id" 
    "people_firstname" "people_midname" "people_lastname" "people_prefix" "people_suffix"
    "people_addr_id"
    "people_company"
    "people_gender"
    "people_homephone" "people_workphone" "people_cellphone" "people_fax"
    "people_email" "people_email2"
    "people_contact"
    "people_DOB"
    "people_created_by" "people_create_date"
    "people_modified_by" "people_modified_date"
    "people__char01" "people__char02" "people__char03"
    "people__date01" "people__date02" "people__date03"
    "people__log01" "people__log02" "people__log03"
    "people__dec01" "people__dec02" "people__dec03" "people__dec04" "people__dec05"
    "people_deleted"
    "people_second_addr_ID"
    "people_title"
    "people_prefname"
    "prog_name".

FOR EACH tpm NO-LOCK: 
    
    EXPORT DELIMITER ";"
        tpm.
        
END.  /** of 4ea. tpm **/

OUTPUT CLOSE. 

OUTPUT STREAM outward CLOSE.

/*************************    END OF FILE   *****************************/
