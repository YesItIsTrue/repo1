/*------------------------------------------------------------------------
    File        : AJAX-delete-question.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Tue Sep 19 10:43:53 EDT 2017
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
    DEFINE VARIABLE v-event-id LIKE dcq_mstr.dcq_event_ID NO-UNDO.
    DEFINE VARIABLE v-question LIKE dcq_mstr.dcq_question NO-UNDO.
    
    ASSIGN
        v-event-id = INTEGER(get-value("eventID"))
        v-question = get-value("question").
        
    FIND dcq_mstr WHERE dcq_mstr.dcq_event_ID = v-event-id AND dcq_mstr.dcq_question = v-question AND dcq_mstr.dcq_deleted = ? NO-ERROR.
    IF AVAILABLE (dcq_mstr) THEN DO:
        DELETE dcq_mstr.
        jObj:Add("success", "true").
    END.
    
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