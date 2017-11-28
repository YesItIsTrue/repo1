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
    DEFINE VARIABLE v-menu-items AS CHARACTER NO-UNDO FORMAT "x(70)".
    DEFINE VARIABLE v-group-ids AS CHARACTER NO-UNDO FORMAT "x(70)".
    DEFINE VARIABLE v-update-type AS CHARACTER NO-UNDO FORMAT "x(70)".
    DEFINE VARIABLE v-menu_num LIKE menu_mstr.menu_num NO-UNDO.
    DEFINE VARIABLE v-menu_select LIKE menu_mstr.menu_select NO-UNDO.
    DEFINE VARIABLE i AS INTEGER NO-UNDO.
    DEFINE VARIABLE j AS INTEGER NO-UNDO.
    DEFINE VARIABLE v-success AS LOGICAL INITIAL YES NO-UNDO.
    
    ASSIGN
        v-menu-items = html-encode(get-value("menuIDs"))
        v-group-ids = html-encode(get-value("groupIDs"))
        v-update-type = html-encode(get-value("updateType")).
    
    DO i = 1 TO NUM-ENTRIES(v-menu-items, ","):
        IF NUM-ENTRIES(ENTRY(i, v-menu-items, ","), "~~") = 2 THEN DO:
            ASSIGN     
                v-menu_num = ENTRY(1, ENTRY(i, v-menu-items, ","), "~~")
                v-menu_select = INTEGER(ENTRY(2, ENTRY(i, v-menu-items, ","), "~~")).
            
            IF v-update-type <> "append" THEN DO:
                /* Clear old groups from the menu item */    
                FOR EACH gmd_det WHERE gmd_det.gmd_menu_num = v-menu_num AND gmd_det.gmd_menu_select = v-menu_select:
                    DELETE gmd_det.
                END.
            END.
            
            /* Attach new groups to the user */
            DO j = 1 TO NUM-ENTRIES (v-group-ids):
                FIND gmd_det WHERE gmd_det.gmd_menu_num = v-menu_num AND gmd_det.gmd_menu_select = v-menu_select AND gmd_det.gmd_grp_id = ENTRY(j, v-group-ids) NO-ERROR.
                IF NOT AVAILABLE (gmd_det) THEN  
                    RUN VALUE(SEARCH("SUBgmd-ucU.r")) (
                        v-menu_num,
                        v-menu_select,
                        ENTRY(j, v-group-ids),
                        OUTPUT v-success
                    ).
            END. /* DO i = 1 TO NUM-ENTRIES (v-group-ids) */
        END. /* IF NUM-ENTRIES (v-menu-items) = 2 */
        ELSE DO:
            DISPLAY "This value (in the HTML) should be x.x".
            v-success = NO.
            LEAVE.
        END.
    END. /* DO i = 1 TO NUM-ENTRIES(v-menu-items, ",") */
    
    IF v-success THEN 
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