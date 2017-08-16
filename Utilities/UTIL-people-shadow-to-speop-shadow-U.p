
/*------------------------------------------------------------------------
    File        : people-shadow-to-speop-shadow.p
    Purpose     : Code Overhaul 2017

    Syntax      :

    Description : Merges Scouts.people_shadow to Custom_ALL.speop_shadow

    Author(s)   : Andrew Garver
    Created     : Tue Jun 20 09:50:24 EDT 2017
    Notes       : REMEMBER!!! If you are running this from the Progress
                    Client Editor then you must manually add the 
                    C:\OpenEdge\workspace\depot\rcode directory to the
                    PROPATH using the PRO*TOOLS utility.
    
    ------------------------------------------------------------------
    Revision History:
    -----------------
    1.0 - written by ANDREW GARVER on 20/Jun/17.  Original Version.
    1.1 - written by DOUG LUTTRELL on 10/Aug/17.  Added in code to 
            respect the *_deleted fields.  Adjusted some of the finds to
            be more specific.  Marked by 1dot1.
    1.11 - written by DOUG LUTTRELL on 11/Aug/17.  Testing revealed that
            the database changed since this was first written.  Modified
            the resp_type field to be resp_category.  Changed output logs
            to go to the C:\PROGRESS\WRK directory per our standard.  
            Marked by 111.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE STREAM error-log.
DEFINE STREAM new-speop.
DEFINE STREAM new-people.
DEFINE VARIABLE v-int-troop                          AS INTEGER NO-UNDO.

DEFINE VARIABLE v-people-id                          AS INTEGER NO-UNDO.
DEFINE VARIABLE v-created                            AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-updated                            AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-isAvail                            AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-success                            AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-addr-id                            AS INTEGER NO-UNDO.
DEFINE VARIABLE v-find-error                         AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ran                                AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-created-speop-id                   AS INTEGER NO-UNDO.
DEFINE VARIABLE v-correct-seq-id                   AS INTEGER NO-UNDO.
DEFINE VARIABLE c-correct-ids                        AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE c-records-not-found-in-people-master AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE c-incorrect-record-ids               AS INTEGER INITIAL 0 NO-UNDO.

OUTPUT STREAM error-log TO "C:\PROGRESS\WRK\people-shadow-to-speop-shadow.txt" APPEND.    /* 111 */
OUTPUT STREAM new-people TO "C:\PROGRESS\WRK\new-people-mstr-records.csv" APPEND.         /* 111 */
OUTPUT STREAM new-speop TO "C:\PROGRESS\WRK\new-speop-shadow-records.csv" APPEND.         /* 111 */

PROCEDURE CreateSpeopRecord:
    DEFINE OUTPUT PARAMETER o-speop_ID LIKE Custom_ALL.speop_shadow.speop_ID NO-UNDO.
    DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.
     
    IF NOT AVAILABLE (Scouts.people_shadow) THEN
    DO:
        DISPLAY "Error: Scouts.people_shadow not available.".
        RETURN.
    END.
        
    CREATE Custom_ALL.speop_shadow.
    ASSIGN
        Custom_ALL.speop_shadow.speop_stake        = Scouts.people_shadow.people_stake
        Custom_ALL.speop_shadow.speop_ward         = Scouts.people_shadow.people_ward
        Custom_ALL.speop_shadow.speop_lds          = Scouts.people_shadow.people_member
        Custom_ALL.speop_shadow.speop_quorum       = Scouts.people_shadow.people_quorum
        Custom_ALL.speop_shadow.speop_Tsize        = Scouts.people_shadow.people_Tsize
        Custom_ALL.speop_shadow.speop_troop        = v-int-troop
        Custom_ALL.speop_shadow.speop_scout_rank   = Scouts.people_shadow.people_sct_rank
        Custom_ALL.speop_shadow.speop_allergies    = Scouts.people_shadow.people_allergies
        Custom_ALL.speop_shadow.speop_med_con      = Scouts.people_shadow.people_med_con
        Custom_ALL.speop_shadow.speop_photo        = Scouts.people_shadow.people_photo
        Custom_ALL.speop_shadow.speop_par_app      = Scouts.people_shadow.people_par_app
        Custom_ALL.speop_shadow.speop_med_form     = Scouts.people_shadow.people_med_form
        o-speop_ID                                 = Scouts.people_shadow.people_ID
        o-success                                  = TRUE.
        
        RUN UpdateRegisMstr (o-speop_ID).
END PROCEDURE.

PROCEDURE UpdateRegisMstr:
        DEFINE INPUT PARAMETER i-speop_id LIKE Scouts.people_shadow.people_ID.
        
        FOR EACH Modules.regis_mstr WHERE Modules.regis_mstr.regis_people_id = i-speop_id AND 
                Modules.regis_mstr.regis_deleted = ? EXCLUSIVE-LOCK:    /* 1dot1 */
            ASSIGN
                Modules.regis_mstr.regis_par_app = Custom_ALL.speop_shadow.speop_par_app
                Modules.regis_mstr.regis_med_form = Custom_ALL.speop_shadow.speop_med_form.    
        END.
END PROCEDURE.

PROCEDURE CreateRespDetRecords:
/*    Find any events in regis_mstr that this person is linked to. For each one, do the following*/
    FOR EACH Modules.regis_mstr WHERE Modules.regis_mstr.regis_people_id = Scouts.people_shadow.people_ID AND
            Modules.regis_mstr.regis_deleted = ? EXCLUSIVE-LOCK:    /* 1dot1 */
        IF Scouts.people_shadow.people_chap THEN DO:
            CREATE Modules.resp_det.
            ASSIGN 
                Modules.resp_det.resp_event_ID  = Modules.regis_mstr.regis_class_ID
                Modules.resp_det.resp_people_ID = v-correct-seq-id
                Modules.resp_det.resp_name      = "Chaperone"
                Modules.resp_det.resp_category  = "CHAPERONE".      /* 111 */
        END.
        IF Scouts.people_shadow.people_ldr THEN DO:
            CREATE Modules.resp_det.
            ASSIGN 
                Modules.resp_det.resp_event_ID  = Modules.regis_mstr.regis_class_ID
                Modules.resp_det.resp_people_ID = v-correct-seq-id
                Modules.resp_det.resp_name      = "Leader"
                Modules.resp_det.resp_category  = "LEADER".         /* 111 */
        END.
        IF Scouts.people_shadow.people_chap THEN DO:
            CREATE Modules.resp_det.
            ASSIGN 
                Modules.resp_det.resp_event_ID  = Modules.regis_mstr.regis_class_ID
                Modules.resp_det.resp_people_ID = v-correct-seq-id
                Modules.resp_det.resp_name      = "Teacher"
                Modules.resp_det.resp_category  = "TEACHER".        /* 111 */
        END.
    END.
END PROCEDURE.

PROCEDURE UpdateTableRecordID:
    DEFINE INPUT PARAMETER i-table-name AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.
    
    CASE i-table-name:
        WHEN "Custom_ALL.speop_shadow" THEN 
            DO:
                IF NOT AVAILABLE (Custom_ALL.speop_shadow) THEN
                DO:
                    DISPLAY "Error: Custom_ALL.speop_shadow not available.".
                    RETURN.
                END.
                
                ASSIGN 
                    Custom_ALL.speop_shadow.speop_ID       = v-correct-seq-id.
                    
                EXPORT STREAM new-speop DELIMITER ";" Custom_ALL.speop_shadow.
            END.
        WHEN "Modules.regis_mstr" THEN
            DO:
                FOR EACH Modules.regis_mstr WHERE Modules.regis_mstr.regis_people_id = Scouts.speop_shadow.speop_ID AND 
                        Modules.regis_mstr.regis_deleted = ? EXCLUSIVE-LOCK:    /* 1dot1 */
                    ASSIGN
                        Modules.regis_mstr.regis_people_id = v-correct-seq-id.    
                END.
            END.
    END CASE.
    
    ASSIGN 
        o-success   = TRUE.
END.

/******************************************************************************************************** 
First check for holes in the General.people_mstr sequence, then check if that hole is filled by General.D_people_mstr. 
Finally, return sequence number if it is missing from both.
*********************************************************************************************************/
PROCEDURE FindAvailableSequenceNumber:
    DEFINE INPUT PARAMETER i-upper-bound AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER o-available-seq-number AS INTEGER NO-UNDO.
    DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL FALSE NO-UNDO.
    
    DEFINE VARIABLE c-seq-number AS INTEGER INITIAL 1 NO-UNDO.
    
    DO WHILE c-seq-number < i-upper-bound:
        IF CAN-FIND (General.people_mstr WHERE General.people_mstr.people_id = c-seq-number AND 
                General.people_mstr.people_deleted = ? no-lock) THEN    /* 1dot1 */
            DO: /*Increment our search to the next id*/
                ASSIGN 
                    c-seq-number = c-seq-number + 1.
            END.
        ELSE IF CAN-FIND (General.D_people_mstr WHERE General.D_people_mstr.D_people_id = c-seq-number AND 
                General.D_people_mstr.D_people_deleted = ? no-lock) THEN    /* 1dot1 */
            DO: /*Increment our search to the next id*/
                ASSIGN 
                    c-seq-number = c-seq-number + 1.
            END.
        ELSE 
            DO: /* Pass back the available sequence number */
                ASSIGN 
                    o-success              = TRUE
                    o-available-seq-number = c-seq-number.
                RETURN.
            END.
    END.
END.

PROCEDURE CreatePeopleMasterRecordWithFirstAvailableSequenceNumber:
    CREATE people_mstr.
    ASSIGN 
        General.people_mstr.people_id           = v-correct-seq-id
        General.people_mstr.people_firstname    = Scouts.people_shadow.people_firstname
        General.people_mstr.people_midname      = ""
        General.people_mstr.people_lastname     = Scouts.people_shadow.people_lastname
        General.people_mstr.people_prefix       = ""
        General.people_mstr.people_suffix       = ""
        General.people_mstr.people_company      = ""
        General.people_mstr.people_gender       = ?
        General.people_mstr.people_homephone    = ""
        General.people_mstr.people_workphone    = ""
        General.people_mstr.people_cellphone    = ""
        General.people_mstr.people_fax          = ""
        General.people_mstr.people_email        = ""
        General.people_mstr.people_email2       = ""
        General.people_mstr.people_addr_id      = 0
        General.people_mstr.people_contact      = ""
        General.people_mstr.people_DOB          = Scouts.people_shadow.people_DOB
        people_mstr.people_create_date          = TODAY
        people_mstr.people_created_by           = USERID ("General")
        people_mstr.people_modified_date        = TODAY
        people_mstr.people_modified_by          = USERID ("General")
        people_mstr.people_second_addr_ID       = 0
        people_mstr.people_prefname             = ""
        people_mstr.people_title                = ""
        people_mstr.people_prog_name            = SOURCE-PROCEDURE:FILE-NAME     /* 2dot2 */
        .      
END PROCEDURE.

/* ***************************  Main Block  *************************** */
FOR EACH Scouts.people_shadow EXCLUSIVE-LOCK:     
    RUN VALUE(SEARCH("SUBpeop-datefindR.r"))
        ("", Scouts.people_shadow.people_firstname, "", Scouts.people_shadow.people_lastname, "", Scouts.people_shadow.people_DOB,
        OUTPUT v-people-id, OUTPUT v-addr-id, OUTPUT v-find-error, OUTPUT v-ran).
        
    IF v-find-error = NO AND v-people-id = Scouts.people_shadow.people_ID THEN /*If a record was found that matched on both info and id*/
    DO: /*set the correct speop_id to matched record*/
        ASSIGN 
            c-correct-ids      = c-correct-ids + 1
            v-correct-seq-id = v-people-id.
    END.
    ELSE IF v-find-error = NO AND v-people-id <> Scouts.people_shadow.people_ID THEN /*A matching record was found but the ID was wrong*/
        DO: /*Update the created speop record's ID to the id of the matched General.people_mstr record.*/
            ASSIGN 
                c-incorrect-record-ids = c-incorrect-record-ids + 1
                v-correct-seq-id     = v-people-id.
        END.
    ELSE IF v-find-error = YES THEN /*If no record could be found by ID or by info*/
        DO: /*Create a new General.people_mstr record*/
           RUN FindAvailableSequenceNumber (10000, OUTPUT v-correct-seq-id, OUTPUT v-success).
           RUN CreatePeopleMasterRecordWithFirstAvailableSequenceNumber.

           ASSIGN 
               c-records-not-found-in-people-master = c-records-not-found-in-people-master + 1.
        END.
    ELSE
        DISPLAY "Error: Logic is broken.".
    
    FIND Custom_ALL.speop_shadow WHERE Custom_ALL.speop_shadow.speop_ID = v-correct-seq-id AND  /* 1dot1 */
        Custom_ALL.speop_shadow.speop_deleted = ? NO-ERROR.     /* 1dot1 */
    IF NOT AVAILABLE (Custom_ALL.speop_shadow) THEN
        RUN CreateSpeopRecord (OUTPUT v-created-speop-id, OUTPUT v-success).
    
    RUN UpdateTableRecordID ("Custom_ALL.speop_shadow", OUTPUT v-success).
    RUN UpdateTableRecordID ("Modules.regis_mstr", OUTPUT v-success).
    
    RUN CreateRespDetRecords.
END.

EXPORT STREAM error-log "Total records with correct IDs: " c-correct-ids.
EXPORT STREAM error-log "Total records with wrong IDs: " c-incorrect-record-ids.
EXPORT STREAM error-log "Total records not in the DB: " c-records-not-found-in-people-master.
