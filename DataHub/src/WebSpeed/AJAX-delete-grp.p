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
    DEFINE VARIABLE v-grp_ID LIKE grp_mstr.grp_ID NO-UNDO.
    
    ASSIGN
        v-grp_ID = get-value("groupID").
        
    FIND grp_mstr WHERE grp_mstr.grp_ID = v-grp_ID AND grp_mstr.grp_deleted = ? NO-ERROR.
    IF AVAILABLE (grp_mstr) THEN DO:
        
        FOR EACH gud_det WHERE gud_det.gud_grp_id = v-grp_ID:
            DELETE gud_det.
        END.
        
        FOR EACH gmd_det WHERE gmd_det.gmd_grp_id = v-grp_ID:
            DELETE gmd_det.
        END.
        
        DELETE grp_mstr.
        jObj:Add("success", "true").
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