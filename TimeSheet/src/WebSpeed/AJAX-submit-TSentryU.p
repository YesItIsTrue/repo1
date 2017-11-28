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
    DEFINE VARIABLE amount      LIKE Hours_Mstr.Hours_amount        NO-UNDO.
    DEFINE VARIABLE clientid    LIKE Hours_Mstr.Hours_client_ID     NO-UNDO.
    DEFINE VARIABLE hours-date  LIKE Hours_Mstr.Hours_date          NO-UNDO.
    DEFINE VARIABLE html-date   AS CHARACTER                        NO-UNDO.
    DEFINE VARIABLE hours-desc  LIKE Hours_Mstr.Hours_description   NO-UNDO.
    DEFINE VARIABLE empid       LIKE Hours_Mstr.Hours_employee_ID   NO-UNDO. 
    DEFINE VARIABLE projname    LIKE Hours_Mstr.Hours_project_name  NO-UNDO.
    
    DEFINE VARIABLE old-clientid LIKE Hours_Mstr.Hours_client_ID NO-UNDO.
    DEFINE VARIABLE old-hours-date LIKE Hours_Mstr.Hours_date NO-UNDO.
    DEFINE VARIABLE old-html-date AS CHARACTER NO-UNDO.
    DEFINE VARIABLE old-projname LIKE Hours_Mstr.Hours_project_name NO-UNDO.
    
    DEFINE VARIABLE o-success  AS LOGICAL                        NO-UNDO.
    
    ASSIGN
        amount = DECIMAL(html-encode(get-value("h-hours")))
        clientid = INTEGER(html-encode(get-value("h-client")))
        html-date = html-encode(get-value("h-date"))
        hours-desc = html-encode(get-value("h-comments"))
        projname = REPLACE(html-encode(get-value("h-project")), "~~", " ")
        old-clientid = INTEGER(html-encode(get-value("h-old-clientid")))
        old-html-date = html-encode(get-value("h-old-date"))
        old-projname = html-encode(get-value("h-old-projname")).
        
    RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (                                               
        html-date,                                                                             
        OUTPUT hours-date                                                                        
    ).
    
    IF old-html-date <> "" THEN 
        RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (                                               
            old-html-date,                                                                             
            OUTPUT old-hours-date                                                                        
        ).
    
    RUN VALUE(SEARCH("session-get-user-id.r")) (
        get-cookie("c-session-token"),
        OUTPUT empid
    ).
    
    FIND Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = clientid AND Proj_Mstr.Proj_name = projname NO-LOCK NO-ERROR.
        IF AVAILABLE (Proj_Mstr) THEN DO:  
            DISPLAY "I am running this thing.".                                                                               
            RUN VALUE(SEARCH("SUBhours-ucU.r")) (
                amount,                 /*Hours_Mstr.Hours_amount      */ 
                clientid,               /*Hours_Mstr.Hours_client_ID   */
                projname,               /*Hours_Mstr.Hours_project_name*/
                hours-date,             /*Hours_Mstr.Hours_date        */
                html-encode(hours-desc),                /*Hours_Mstr.Hours_description */
                empid,                  /*Hours_Mstr.Hours_employee_ID */
                "",             /*Hours_Mstr.Hours_translation */
                ?,                      /*Hours_Mstr.Hours_billed      */  
                ?,                /*Hours_Mstr.Hours_time        */
                "",              /*Hours_Mstr.Hours_time_desc   */
                
                IF old-clientid <> 0 THEN old-clientid ELSE clientid, 
                IF old-projname <> "" THEN old-projname ELSE projname,
                IF old-hours-date <> ? THEN old-hours-date ELSE hours-date,
                ?,
                ?,
                
                OUTPUT o-success        
                ).
                
            IF o-success THEN 
                jObj:Add("success", TRUE).
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