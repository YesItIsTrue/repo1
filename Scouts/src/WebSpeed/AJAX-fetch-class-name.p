/*------------------------------------------------------------------------
    File        : AJAX-fetch-class-name.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Aug 11 10:43:53 EDT 2017
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
    DEFINE VARIABLE class-id LIKE MB_mstr.MB_BSA_ID NO-UNDO.

    ASSIGN
        class-id = INTEGER(get-value("classID")).
    
    FIND sched_mstr WHERE sched_mstr.sched_class_ID = class-id AND sched_mstr.sched_deleted = ? NO-ERROR.
    IF AVAILABLE (sched_mstr) THEN
        FIND MB_mstr WHERE MB_mstr.MB_BSA_ID = sched_mstr.sched_BSA_ID AND MB_mstr.MB_deleted = ? NO-ERROR.
    IF AVAILABLE (MB_mstr) THEN DO:
        jObj:add("className", MB_mstr.MB_name).
        FIND FIRST att_files WHERE att_files.att_table = "MB_mstr" AND 
        att_files.att_field1 = "MB_BSA_ID" AND 
        att_files.att_value1 = STRING(MB_mstr.MB_BSA_ID) AND                                                                  /* 111 */
        att_files.att_deleted = ? AND 
        att_files.att_category = "IMAGE"
        NO-LOCK NO-ERROR.
        IF AVAILABLE (att_files) THEN DO:
            jObj:add("imgPath", att_files.att_filepath + "/" + att_files.att_filename).
        END.
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