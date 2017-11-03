/*------------------------------------------------------------------------
    File        : TS-ajax-test.p
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
    DEFINE VARIABLE country-iso AS CHARACTER NO-UNDO.

    ASSIGN
        country-iso = IF get-value("countryISO") <> "" THEN get-value("countryISO") ELSE "USA".

    FOR EACH state_mstr  WHERE
        state_mstr.state_deleted = ? AND
        state_mstr.state_primary = YES AND
        state_mstr.state_country_ISO = country-iso NO-LOCK:

        jObj:add(state_mstr.state_iso, state_mstr.state_display_name).

    END.  /** of 4ea. state_mstr **/
    
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