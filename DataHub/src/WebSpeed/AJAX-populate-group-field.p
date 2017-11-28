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
    DEF VAR jObjArray AS jsonArray.
    DEF VAR jsonResults AS jsonObject.
    
    /* Begin logic */
    DEFINE VARIABLE v-key AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-table AS CHARACTER NO-UNDO.
    
    ASSIGN
        jObjArray = NEW jsonArray()
        jsonResults = NEW jsonObject()
        v-key = get-value("key")
        v-table = get-value("table").
        
    CASE v-table:
        WHEN "gud_det" THEN DO:
            FOR EACH gud_det WHERE gud_det.gud_people_ID = INTEGER(v-key) NO-LOCK:
                jObj = NEW jsonObject().
                jObj:add("groupID", gud_det.gud_grp_id).
                jObjArray:add(jObj).
            END.
        END.
        WHEN "gmd_det" THEN DO:
            DEFINE VARIABLE v-menu_num LIKE menu_mstr.menu_num NO-UNDO.
            DEFINE VARIABLE v-menu_select LIKE menu_mstr.menu_select NO-UNDO.
            
            IF NUM-ENTRIES (v-key, "~~") = 2 THEN DO:
                ASSIGN 
                    v-menu_num = ENTRY(1, v-key, "~~")
                    v-menu_select = INTEGER(ENTRY(2, v-key, "~~")).
                    
                FOR EACH gmd_det WHERE gmd_det.gmd_menu_num = v-menu_num AND gmd_det.gmd_menu_select = v-menu_select NO-LOCK:
                    jObj = NEW jsonObject().
                    jObj:add("groupID", gmd_det.gmd_grp_id).
                    jObjArray:add(jObj).
                END.
            END. /* IF NUM-ENTRIES (v-key) = 2 */
            ELSE 
                DISPLAY "This value (in the HTML) should be x.x".
        END.
    END. /* CASE */
    /* End logic */
 
    jsonResults:add("results", jObjArray).
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