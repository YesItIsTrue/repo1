/*------------------------------------------------------------------------
    File        : AJAX-get-projects-by-client.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Nov 15 10:43:53 EDT 2017
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
    DEFINE VARIABLE emp-id LIKE event_mstr.event_ID NO-UNDO.
    DEFINE VARIABLE client-list AS CHARACTER INITIAL "" NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE v-is-global-project AS LOGICAL NO-UNDO.
    DEFINE BUFFER proj_mstr2 FOR Proj_Mstr.

    ASSIGN
        emp-id = INTEGER(get-value("empID")).
    
    FOR EACH Client_Mstr WHERE Client_Mstr.Client_deleted = ? NO-LOCK,
    FIRST Hours_Mstr WHERE Hours_Mstr.Hours_client_ID = Client_Mstr.Client_people_ID AND Hours_Mstr.Hours_employee_ID = emp-id AND Hours_Mstr.Hours_deleted = ? NO-LOCK:
        jObj:add(STRING(Client_Mstr.Client_people_ID), Client_Mstr.Client_abbv).
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