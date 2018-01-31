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
    DEFINE VARIABLE client-id LIKE Proj_Mstr.Proj_client_ID NO-UNDO.
    DEFINE VARIABLE project-name LIKE Proj_Mstr.Proj_name NO-UNDO.

    ASSIGN
        client-id = INTEGER(html-encode(get-value("clientID")))
        project-name = html-encode(get-value("projName")).
        
    IF client-id = 9999999 THEN DO:
        FOR EACH Client_Mstr EXCLUSIVE-LOCK:
            FIND Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = Client_Mstr.Client_people_ID AND Proj_Mstr.Proj_name = project-name NO-ERROR.
            IF AVAILABLE (Proj_Mstr) THEN DO:
                DELETE Proj_Mstr.
            END.
        END.
        jObj:add("success", "true").
    END.
    ELSE DO:
        FIND Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = client-id AND Proj_Mstr.Proj_name = project-name NO-ERROR.
        IF AVAILABLE (Proj_Mstr) THEN DO:
            DELETE Proj_Mstr.
            jObj:add("success", "true").
        END.
        ELSE 
            jObj:add("error", "Looks like that project has already been deleted!").
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