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
    DEFINE VARIABLE client-id LIKE event_mstr.event_ID NO-UNDO.
    DEFINE VARIABLE emp-id LIKE Emp_Mstr.Emp_ID NO-UNDO.
    DEFINE VARIABLE client-list AS CHARACTER INITIAL "" NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE v-is-global-project AS LOGICAL NO-UNDO.
    DEFINE BUFFER proj_mstr2 FOR Proj_Mstr.

    ASSIGN
        client-id = INTEGER(html-encode(get-value("clientID")))
        emp-id = INTEGER(html-encode(get-value("empID"))).
    
    IF emp-id <> 0 THEN DO:
        FOR EACH Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = client-id AND Proj_Mstr.proj_deleted = ? NO-LOCK,
        FIRST Hours_Mstr WHERE Hours_Mstr.Hours_employee_ID = emp-id AND Hours_Mstr.Hours_project_name = Proj_Mstr.Proj_name AND Hours_Mstr.Hours_client_ID = client-id NO-LOCK
        BREAK BY Proj_Mstr.Proj_name:
            jObj:add(Proj_Mstr.Proj_name, Proj_Mstr.Proj_name).
        END.  /** of 4ea. state_mstr **/
    END.
    ELSE IF client-id = 9999999 THEN DO:
        FOR EACH Client_Mstr NO-LOCK:
            ASSIGN
                client-list = client-list + IF client-list <> "" THEN "," + STRING(Client_Mstr.Client_people_ID) ELSE STRING(Client_Mstr.Client_people_ID).  
        END. /* FOR EACH Client_Mstr */
        
        FOR EACH Proj_Mstr NO-LOCK BREAK BY Proj_Mstr.Proj_name:
            IF FIRST-OF (Proj_Mstr.Proj_name) THEN DO:
                v-is-global-project = YES.
                DO i = 1 TO NUM-ENTRIES(client-list):
                    FIND proj_mstr2 WHERE proj_mstr2.Proj_client_ID = INTEGER(ENTRY(i, client-list)) AND proj_mstr2.Proj_name = Proj_Mstr.Proj_name NO-ERROR.
                    IF NOT AVAILABLE(proj_mstr2) THEN DO:
                        v-is-global-project = NO.
                        LEAVE.
                    END. /* IF NOT AVAILABLE(proj_mstr2) */
                END. /* DO i = 1 TO NUM-ENTRIES(client-list) */
                
                IF v-is-global-project THEN 
                    jObj:add(Proj_Mstr.Proj_name, Proj_Mstr.Proj_name).
            END. /* IF FIRST-OF (Proj_Mstr.Proj_name) */
        END. /* FOR EACH Proj_Mstr */
    END.
    ELSE DO:
        FOR EACH Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = client-id AND Proj_Mstr.proj_deleted = ? NO-LOCK:
            jObj:add(Proj_Mstr.Proj_name, Proj_Mstr.Proj_name).
        END.  /** of 4ea. state_mstr **/
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