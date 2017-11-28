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
    DEFINE VARIABLE v-menu-id AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-menu_num LIKE menu_mstr.menu_num NO-UNDO.
    DEFINE VARIABLE v-menu_select LIKE menu_mstr.menu_select NO-UNDO.
    DEFINE VARIABLE v-menu_title LIKE menu_mstr.menu_title NO-UNDO.
    DEFINE VARIABLE v-menu_exprog LIKE menu_mstr.menu_exprog NO-UNDO.
    DEFINE VARIABLE v-menu_module LIKE menu_mstr.menu_module NO-UNDO.
    DEFINE VARIABLE v-menu__char01 LIKE menu_mstr.menu__char01 NO-UNDO.
    DEFINE VARIABLE v-menu_hidden LIKE menu_mstr.menu_hidden NO-UNDO.
    DEFINE VARIABLE v-delete-menu-record AS LOGICAL NO-UNDO.
    DEFINE VARIABLE v-create-menu-record AS LOGICAL NO-UNDO.
    
    DEFINE BUFFER menu_mstr2 FOR menu_mstr.
    
    ASSIGN
        v-menu-id = html-encode(get-value("menuID")) 
        v-menu_num = html-encode(get-value("menuNum"))  
        v-menu_select = INTEGER(html-encode(get-value("menuSelect")))  
        v-menu_title = html-encode(get-value("menuTitle"))  
        v-menu_exprog = html-encode(get-value("menuExprog"))  
        v-menu_module = html-encode(get-value("menuModule"))  
        v-menu__char01 = html-encode(get-value("menuIcon"))  
        v-menu_hidden = LOGICAL(html-encode(get-value("menuHidden")))
        v-delete-menu-record = IF html-encode(get-value("deleteMenuRecord")) <> "" THEN YES ELSE NO
        v-create-menu-record = IF html-encode(get-value("createMenuRecord")) <> "" THEN YES ELSE NO. 
        
    IF NUM-ENTRIES(v-menu-id, "~~") = 2 OR v-create-menu-record = YES THEN DO:
        
        IF v-create-menu-record = YES THEN DO:
            IF v-menu_num <> "" THEN DO:
                FIND menu_mstr WHERE menu_mstr.menu_num = v-menu_num AND menu_mstr.menu_select = v-menu_select NO-ERROR.
                IF NOT AVAILABLE (menu_mstr) THEN DO:
                    CREATE menu_mstr.
                    ASSIGN 
                        menu_mstr.menu_num = v-menu_num
                        menu_mstr.menu_select = v-menu_select
                        menu_mstr.menu_create_date = TODAY 
                        menu_mstr.menu_created_by = USERID("Core").
                END. /* IF NOT AVAILABLE (menu_mstr) */
                ELSE DO:
                    jObj:Add("error", "A menu_mstr record with that menu_num and menu_select aleady exisits!").
                    jObj:write(OUTPUT cOut).
                    LEAVE.
                END.
            END. /* IF v-menu_num <> "" AND v-menu_select <> 0 */
            ELSE DO:
                jObj:Add("error", "You must supply correct values for both menu_num and menu_select!").
                jObj:write(OUTPUT cOut).
                LEAVE.
            END.
        END. /* IF v-create-menu-record = YES */
        
        IF NOT v-create-menu-record THEN 
            FIND menu_mstr WHERE menu_mstr.menu_num = ENTRY(1, v-menu-id, "~~") AND menu_mstr.menu_select = INTEGER(ENTRY(2, v-menu-id, "~~")) NO-ERROR.
            
        IF AVAILABLE (menu_mstr) AND v-delete-menu-record = NO THEN DO:
            
            IF v-menu_num <> "" THEN DO:
                IF v-create-menu-record = NO AND (v-menu_num <> ENTRY(1, v-menu-id, "~~") OR v-menu_select <> INTEGER(ENTRY(2, v-menu-id, "~~"))) THEN /* If the user is attempting to update a menu item's menu_num or menu_select... */ 
                    FIND menu_mstr2 WHERE menu_mstr2.menu_num = v-menu_num AND menu_mstr2.menu_select = v-menu_select NO-ERROR. /* check to make sure there isn't another menu item with the same combo */
                    
                IF NOT AVAILABLE (menu_mstr2) THEN DO: 
                    ASSIGN 
                        menu_mstr.menu_num = IF v-menu_num <> "" THEN v-menu_num ELSE menu_mstr.menu_num
                        menu_mstr.menu_select = v-menu_select 
                        menu_mstr.menu_title = v-menu_title 
                        menu_mstr.menu_exprog = v-menu_exprog 
                        menu_mstr.menu_module = v-menu_module 
                        menu_mstr.menu__char01 = v-menu__char01 
                        menu_mstr.menu_hidden = v-menu_hidden 
                        menu_mstr.menu_modified_date = TODAY 
                        menu_mstr.menu_modified_by = USERID("Core")
                        menu_mstr.menu_prog_name = THIS-PROCEDURE:FILE-NAME.
                        
                    jObj:Add("success", "true").
                END.
                ELSE DO:
                    jObj:Add("error", "A menu_mstr record with that menu_num and menu_select aleady exisits!").
                    jObj:write(OUTPUT cOut).
                    LEAVE.
                END.
            END.
            ELSE DO:
                jObj:Add("error", "You must supply correct values for both menu_num and menu_select!").
                jObj:write(OUTPUT cOut).
                LEAVE.
            END.
        END. /* IF AVAILABLE (menu_mstr) AND v-delete-menu-record = NO */
        
        IF AVAILABLE (menu_mstr) AND v-delete-menu-record = YES THEN DO:
            DELETE menu_mstr.
            jObj:Add("success", "true").
        END. /* IF AVAILABLE (menu_mstr) AND v-delete-menu-record = YES */
    END. /* IF NUM-ENTRIES(v-menu-id, "~~") = 2 OR v-create-menu-record = YES */
    ELSE DO:
        jObj:Add("error", "Malformatted html: menu row id should resemble x.x").
        jObj:write(OUTPUT cOut).
        LEAVE.
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