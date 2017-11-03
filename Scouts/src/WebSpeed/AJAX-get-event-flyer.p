/*------------------------------------------------------------------------
    File        : AJAX-get-event-flyer.p
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
    DEFINE VARIABLE v-event-id AS CHARACTER NO-UNDO.

    ASSIGN
        v-event-id = get-value("eventID").
    
    FIND FIRST att_files WHERE att_files.att_value1 = v-event-id AND att_files.att_category = "FLYER" AND att_files.att_deleted = ? NO-ERROR.
        IF AVAILABLE (att_files) THEN DO:
            jObj:add("flyer", att_files.att_filepath + att_files.att_filename).
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