/*------------------------------------------------------------------------
    File        : AJAX-fetch-student-name.p
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
    DEFINE VARIABLE student-id LIKE people_mstr.people_id NO-UNDO.

    ASSIGN
        student-id = INTEGER(get-value("studentID")).
    
    FIND people_mstr WHERE people_mstr.people_id = student-id AND people_mstr.people_deleted = ? NO-ERROR.
    IF AVAILABLE (people_mstr) THEN
        jObj:add("studentName", people_mstr.people_firstname + " " + people_mstr.people_lastname).
        
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