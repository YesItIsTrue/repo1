/*------------------------------------------------------------------------
    File        : AJAX-check-email-availability.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Oct 17 10:43:53 EDT 2017
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
    DEFINE VARIABLE v-abbv LIKE Client_Mstr.Client_abbv NO-UNDO.

    ASSIGN
        v-abbv = html-encode(get-value("clientAbbv")).
    
    FIND FIRST Client_Mstr WHERE Client_Mstr.Client_abbv = v-abbv NO-ERROR.
    IF NOT AVAILABLE (Client_Mstr) THEN
        jObj:add("success", "true").
    ELSE 
        jObj:add("error", "A Client with that abbreviation already exists!").
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