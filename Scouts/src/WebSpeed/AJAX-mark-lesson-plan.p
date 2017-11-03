/*------------------------------------------------------------------------
    File        : AJAX-mark-lesson-plan.p
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
    DEFINE VARIABLE v-class-id LIKE lesson_plan.lesson_class_id NO-UNDO.
    DEFINE VARIABLE v-date LIKE lesson_plan.lesson_date NO-UNDO.
    DEFINE VARIABLE v-req-nbr LIKE lesson_plan.lesson_req_nbr NO-UNDO.
    DEFINE VARIABLE v-lesson-comp LIKE lesson_plan.lesson_comp NO-UNDO.
    
    ASSIGN
        v-class-id = INTEGER(html-encode(get-value("classID")))
        v-date = DATE(html-encode(get-value("lessonDate")))
        v-req-nbr = html-encode(get-value("reqNumber"))
        v-lesson-comp = LOGICAL(html-encode(get-value("lessonComp"))).
        
    FIND lesson_plan WHERE lesson_plan.lesson_class_id = v-class-id AND lesson_plan.lesson_date = v-date AND 
    lesson_plan.lesson_req_nbr = v-req-nbr AND lesson_plan.lesson_deleted = ? NO-ERROR.
    IF AVAILABLE (lesson_plan) THEN DO:
        ASSIGN
            lesson_plan.lesson_comp = v-lesson-comp
            lesson_plan.lesson_modified_by = USERID("Modules")
            lesson_plan.lesson_modified_date = TODAY
            lesson_plan.lesson_prog_name = SOURCE-PROCEDURE:FILE-NAME.
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