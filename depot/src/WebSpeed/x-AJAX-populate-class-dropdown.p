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

    jObj:add("0", "All classes").
    
    FOR EACH sched_mstr WHERE sched_event_ID = event-id AND sched_deleted = ? NO-LOCK:
        FIND MB_mstr WHERE MB_BSA_ID = sched_BSA_ID AND MB_deleted = ? NO-ERROR.
        IF AVAILABLE (MB_mstr) THEN
            jObj:add(STRING(sched_class_ID), MB_name + " - Period " + sched_period).    
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