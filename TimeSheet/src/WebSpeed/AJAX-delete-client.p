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
    DEFINE VARIABLE client-id LIKE Hours_Mstr.Hours_client_ID NO-UNDO.

    ASSIGN
        client-id = INTEGER(html-encode(get-value("clientID"))).
        
    FIND FIRST Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = client-id NO-ERROR.
    IF NOT AVAILABLE (Proj_Mstr) THEN DO:
        
        FIND Client_Mstr WHERE Client_Mstr.Client_people_ID = client-id NO-ERROR.
        IF AVAILABLE (Client_Mstr) THEN DO: 
            
            FIND people_mstr WHERE people_mstr.people_id = client-id NO-ERROR.
            IF AVAILABLE (people_mstr) THEN DO:
                
                IF people_mstr.people_addr_id > 0 THEN DO:      
                    FIND addr_mstr WHERE addr_mstr.addr_id = people_mstr.people_addr_id NO-ERROR.
                    IF AVAILABLE (addr_mstr) THEN
                        DELETE addr_mstr.
                END.
                
                DELETE Client_Mstr.
                DELETE people_mstr.
                
                jObj:add("success", "true").
            END. /* IF AVAILABLE (people_mstr) */
            ELSE 
                jObj:add("error", "Couldn't find a people_id with the provided id of " + STRING(client-id)).
        END. /* IF AVAILABLE (Client_Mstr) */
        ELSE 
            jObj:add("error", "Couldn't find a client with the provided id of " + STRING(client-id)).
            
    END.
    ELSE DO:
        jObj:add("error", "You need to delete all associated projects before deleting this client").
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