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
    DEFINE VARIABLE v-menu-item AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-group-ids AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-menu_num LIKE menu_mstr.menu_num NO-UNDO.
    DEFINE VARIABLE v-menu_select LIKE menu_mstr.menu_select NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE v-success AS LOGICAL NO-UNDO.
    
    ASSIGN
        v-menu-item = html-encode(get-value("menuItem"))
        v-group-ids = html-encode(get-value("groupIDs")).
    
    IF NUM-ENTRIES (v-menu-item) = 2 THEN DO:
        ASSIGN     
            v-menu_num = ENTRY(1, v-menu-item)
            v-menu_select = INTEGER(ENTRY(2, v-menu-item)).
            
        /* Clear old groups from the user */    
        FOR EACH gmd_det WHERE gmd_det.gmd_menu_num = v-menu_num AND gmd_det.gmd_menu_select = v-menu_select:
            DELETE gmd_det.
        END.
        
        /* Attach new groups to the user */
        DO i = 1 TO NUM-ENTRIES (v-group-ids):
            RUN VALUE(SEARCH("SUBgmd-ucU.r")) (
                v-menu_num,
                v-menu_select,
                ENTRY(i, v-group-ids),
                OUTPUT v-success
            ).
        END. /* DO i = 1 TO NUM-ENTRIES (v-group-ids) */
        
        jObj:Add("success", TRUE).
    END. /* IF NUM-ENTRIES (v-menu-item) = 2 */
    ELSE
        DISPLAY "Yo. There's an error with the value of the menu_item you are trying to update. This value (in the HTML) should be x,x".
    
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