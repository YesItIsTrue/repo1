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
        
    FOR EACH dcq_mstr WHERE dcq_mstr.dcq_event_ID = v-event-id NO-LOCK:
        jObj = NEW jsonObject().
        jObj:add("question", dcq_mstr.dcq_question).
        jObjArray:add(jObj).
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