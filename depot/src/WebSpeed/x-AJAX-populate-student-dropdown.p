/*------------------------------------------------------------------------
    File        : AJAX-populate-state-dropdown.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Aug 11 10:43:53 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
USING progress.json.objectmodel.*.
 
CREATE WIDGET-POOL.
DEF VAR cOut AS LONGCHAR.

{src/web2/wrap-cgi.i}
 
RUN process-web-request.
PROCEDURE createJson :
    DEF VAR jObj AS jsonObject.
    jObj = NEW jsonObject().
    
    /* Begin logic */
    DEFINE VARIABLE event-id LIKE event_mstr.event_ID NO-UNDO.

    ASSIGN
        event-id = INTEGER(get-value("eventID")).

    jObj:add("0", "All students").
    
    FOR EACH sched_mstr WHERE sched_event_ID = event-id AND sched_deleted = ?,
        EACH regis_mstr WHERE regis_class_ID = sched_class_ID AND regis_deleted = ? NO-LOCK
        BREAK BY regis_mstr.regis_people_id:
        IF FIRST-OF(regis_mstr.regis_people_id) THEN DO:
            FIND people_mstr WHERE people_mstr.people_id = regis_mstr.regis_people_id AND people_deleted = ? NO-ERROR.
            IF AVAILABLE (people_mstr) THEN
                jObj:add(STRING(people_mstr.people_id), people_mstr.people_firstname + " " + people_mstr.people_lastname).
        END.
    END.  /** of 4ea. state_mstr **/
    
    /* End logic */
 
    jObj:write(OUTPUT cOut).
END PROCEDURE.
 
PROCEDURE outputHeader :
    output-content-type ("application/json":U).  
END PROCEDURE.
 
PROCEDURE process-web-request :
    RUN outputHeader.
    RUN createJson.
 
    {&OUT} STRING(cOut).
END PROCEDURE.