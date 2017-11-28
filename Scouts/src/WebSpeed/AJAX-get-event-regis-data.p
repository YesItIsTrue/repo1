/*------------------------------------------------------------------------
    File        : AJAX-get-event-regis-data.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Mon Nov 06 14:26:07 EDT 2017
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
    DEFINE VARIABLE jObj AS jsonObject.
    DEFINE VARIABLE jObjArray AS jsonArray.
    DEFINE VARIABLE jsonResults AS jsonObject.
    DEFINE VARIABLE v-event-id AS INTEGER NO-UNDO.

    ASSIGN 
        jObjArray = NEW jsonArray()
        jsonResults = NEW jsonObject()
        v-event-id = INTEGER(html-encode(get-value("eventID"))).
        
    FOR EACH sched_mstr WHERE sched_mstr.sched_event_ID = v-event-id,
    EACH regis_mstr WHERE regis_mstr.regis_class_ID = sched_mstr.sched_class_ID,
    EACH people_mstr WHERE people_mstr.people_id = regis_mstr.regis_people_id,
    EACH speop_shadow WHERE speop_shadow.speop_ID = people_mstr.people_id NO-LOCK 
    BREAK BY people_mstr.people_id:
        IF FIRST-OF(people_mstr.people_ID) THEN DO: 
            jObj = NEW jsonObject().
            jObj:add("id", people_mstr.people_ID).
            jObj:add("lastName", people_mstr.people_lastname).
            jObj:add("firstName", people_mstr.people_firstname).
            jObj:add("dob", people_mstr.people_DOB).
            jObj:add("stake", speop_shadow.speop_stake).
            jObj:add("ward", speop_shadow.speop_ward).
            jObjArray:add(jObj).
        END.
    END.
    
    jsonResults:add("data", jObjArray).
    jsonResults:write(OUTPUT cOut).
END PROCEDURE.
 
PROCEDURE outputHeader :
    output-content-type ("application/json":U).  
END PROCEDURE.
 
PROCEDURE process-web-request :
    RUN outputHeader.
    RUN createJson.
 
    {&OUT} STRING(cOut).
END PROCEDURE.