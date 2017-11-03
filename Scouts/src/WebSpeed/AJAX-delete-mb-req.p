/*------------------------------------------------------------------------
    File        : AJAX-delete-mb-req.p
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
    DEFINE VARIABLE req-num LIKE MBR_reqs.MBR_Req_Nbr NO-UNDO.
    DEFINE VARIABLE mb-id LIKE MBR_reqs.MBR_BSA_ID NO-UNDO.
    DEFINE VARIABLE mb-year LIKE MBR_reqs.MBR_year NO-UNDO.
    
    ASSIGN
        req-num = get-value("reqNum")
        mb-id = INTEGER(get-value("mbID"))
        mb-year = INTEGER(get-value("mbYear")).
        
    FIND MBR_reqs WHERE MBR_reqs.MBR_Req_Nbr = req-num AND MBR_reqs.MBR_BSA_ID = mb-id AND 
    MBR_reqs.MBR_year = mb-year AND MBR_reqs.MBR_deleted = ? NO-ERROR.
    IF AVAILABLE (MBR_reqs) THEN DO:
        DELETE MBR_reqs.
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