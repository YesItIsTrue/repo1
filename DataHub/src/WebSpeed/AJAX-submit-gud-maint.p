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
    DEFINE VARIABLE v-people-id LIKE gud_det.gud_people_ID NO-UNDO.
    DEFINE VARIABLE v-group-ids AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE v-success AS LOGICAL NO-UNDO.
    
    ASSIGN
        v-people-id = INTEGER(html-encode(get-value("userID")))
        v-group-ids = html-encode(get-value("groupIDs")).
    
    /* Clear old groups from the user */    
    FOR EACH gud_det WHERE gud_det.gud_people_ID = v-people-id:
        DELETE gud_det.
    END.
    
    /* Attach new groups to the user */
    DO i = 1 TO NUM-ENTRIES (v-group-ids):
        RUN VALUE(SEARCH("SUBgud-ucU.r")) (
            v-people-id,
            ENTRY(i, v-group-ids),
            OUTPUT v-success
        ).
    END.
    
    jObj:Add("success", TRUE).
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