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
    DEFINE VARIABLE employee-id LIKE Hours_Mstr.Hours_employee_ID NO-UNDO.
    DEFINE VARIABLE client-id LIKE Hours_Mstr.Hours_client_ID NO-UNDO.
    DEFINE VARIABLE project-name LIKE Hours_Mstr.Hours_project_name NO-UNDO.
    DEFINE VARIABLE prog-date LIKE Hours_Mstr.Hours_date NO-UNDO.
    DEFINE VARIABLE html-date AS CHARACTER NO-UNDO.

    ASSIGN
        client-id = INTEGER(html-encode(get-value("h-client")))
        project-name = html-encode(get-value("h-project"))
        html-date = html-encode(get-value("h-date"))
        employee-id = INTEGER(html-encode(get-value("h-empid"))).
        
    IF employee-id <> 0 THEN DO:
        {validate-admin.i "TSadmin"}.
    END.
    ELSE
        RUN VALUE(SEARCH("session-get-user-id.r")) (
            get-cookie("c-session-token"),
            OUTPUT employee-id
        ).
        
    RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (
        html-date,
        OUTPUT prog-date
    ).
    
    DISPLAY prog-date employee-id client-id project-name WITH 2 COL.
    FOR FIRST Hours_Mstr WHERE Hours_Mstr.Hours_date = prog-date AND Hours_Mstr.Hours_employee_ID = employee-id AND 
    Hours_Mstr.Hours_client_ID = client-id AND Hours_Mstr.Hours_project_name = project-name AND 
    Hours_Mstr.Hours_deleted = ? EXCLUSIVE-LOCK:
        DELETE Hours_Mstr.
        jObj:add("success", "true").
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