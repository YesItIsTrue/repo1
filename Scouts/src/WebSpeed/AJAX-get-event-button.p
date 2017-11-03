/*------------------------------------------------------------------------
    File        : AJAX-get-event-button.p
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
    DEFINE VARIABLE v-people-id LIKE people_mstr.people_id NO-UNDO.
    DEFINE VARIABLE v-event-registered AS LOGICAL INITIAL NO NO-UNDO.
    DEFINE VARIABLE v-button-html AS CHARACTER NO-UNDO.

    ASSIGN
        v-event-id = INTEGER(get-value("eventID"))
        v-people-id = INTEGER(get-value("peopleID")).

    FOR EACH regis_mstr WHERE regis_mstr.regis_people_id = v-people-id AND regis_mstr.regis_deleted = ?,
    EACH sched_mstr WHERE sched_mstr.sched_class_ID = regis_mstr.regis_class_ID AND sched_mstr.sched_event_ID = v-event-id AND sched_mstr.sched_deleted = ? NO-LOCK:
        ASSIGN v-event-registered = YES.
        jObj:add("buttonHTML", "<center><button type='button' class='w3-btn-block w3-theme-dark w3-round i-signup-btn' style='font-size: xx-large;'>You're registered!</button></center>").
    END.
    
    IF NOT v-event-registered THEN DO:
        FIND event_mstr WHERE event_mstr.event_ID = v-event-id AND event_mstr.event_deleted = ? NO-ERROR.
        IF AVAILABLE (event_mstr) THEN DO:
            IF event_mstr.event_URL <> "" THEN DO:
                IF event_mstr.event_URL BEGINS "event-one-click-signup." THEN
                    v-button-html = "<a href=~"" + event_mstr.event_URL + "~"><center><button id='register-btn' type='submit' class='w3-btn-block w3-green w3-round i-signup-btn' style='font-size: xx-large;'>I'm IN!</button></center></a>".
                ELSE
                    v-button-html = "<a href=~"" + event_mstr.event_URL + "~"><center><button id='register-btn' type='submit' class='w3-btn-block w3-green w3-round i-signup-btn' style='font-size: xx-large;'>Sign up!</button></center></a>".
                
                jObj:add("buttonHTML", v-button-html).
            END.
            ELSE
                jObj:add("buttonHTML", "<center><button type='button' class='w3-btn-block w3-grey w3-round i-signup-btn'>Registration not yet available</button></center>").
        END.
    END.
            
    jObj:add("success", "true").
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