/*------------------------------------------------------------------------
    File        : AJAX-get-event-details.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Oct 17 10:43:53 EDT 2017
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
    DEFINE VARIABLE v-event-id LIKE event_mstr.event_ID NO-UNDO.
    DEFINE VARIABLE v-event-location LIKE addr_mstr.addr_city NO-UNDO.

    ASSIGN
        v-event-id = INTEGER(get-value("eventID")).
    
    FOR FIRST event_mstr WHERE event_mstr.event_ID = v-event-id AND event_mstr.event_deleted = ? NO-LOCK 
    BREAK BY YEAR(event_mstr.event_start_date) DESCENDING BY event_mstr.event_start_date BY event_mstr.event_start_time:
            
        IF event_mstr.event_addr_id <> 0 THEN        
            FIND addr_mstr WHERE addr_mstr.addr_id = event_mstr.event_addr_id AND addr_mstr.addr_deleted = ? NO-LOCK NO-ERROR.
                    
        IF AVAILABLE (addr_mstr) THEN 
            ASSIGN v-event-location = addr_mstr.addr_city.
        ELSE 
            ASSIGN v-event-location = "TBA".
            
        jObj:add("what", event_mstr.event_name).
        jObj:add("ages", event_mstr.event__char01).
        jObj:add("startDate", event_mstr.event_start_date).
        jObj:add("startTime", event_mstr.event_start_time).
        jObj:add("endTime", event_mstr.event_end_time).
        jObj:add("location", v-event-location).
        jObj:add("dressCode", event_mstr.event_dress_code).
        jObj:add("success", "true").
    END.
 
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