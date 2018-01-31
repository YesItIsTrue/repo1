/*------------------------------------------------------------------------
    File        : AJAX-get-projects-by-client.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Nov 15 10:43:53 EDT 2017
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
    DEFINE VARIABLE empid LIKE Emp_Mstr.Emp_ID NO-UNDO.
    DEFINE VARIABLE addrid LIKE addr_mstr.addr_id NO-UNDO.

    ASSIGN
        empid = INTEGER(html-encode(get-value("employeeID")))
        addrid = INTEGER(html-encode(get-value("addressID"))).
        
    FIND Emp_Mstr WHERE Emp_Mstr.Emp_ID = empid EXCLUSIVE-LOCK.
    IF AVAILABLE (Emp_Mstr) THEN
        DELETE Emp_Mstr.    
    ELSE DO:
        jObj:add("error", "Couldn't find an Employee with the provided id of " + STRING(empid)).
        jObj:write(OUTPUT cOut).
        RETURN.
    END.
        
    FIND people_mstr WHERE people_mstr.people_id = empid EXCLUSIVE-LOCK.
    IF AVAILABLE (people_mstr) THEN DO:         
        DELETE people_mstr.
    END.
    ELSE DO:
        jObj:add("error", "Couldn't find a People Record with the provided id of " + STRING(empid)).
        jObj:write(OUTPUT cOut).
        RETURN.
    END.
   
    IF addrid > 0 THEN DO:      
        FIND addr_mstr WHERE addr_mstr.addr_id = addrid EXCLUSIVE-LOCK.
        IF AVAILABLE (addr_mstr) THEN
            DELETE addr_mstr.
        ELSE DO:
            jObj:add("error", "Couldn't find an Address with the provided id of " + STRING(addrid)).
        jObj:write(OUTPUT cOut).
        RETURN.
        END.
    END.
        
    jObj:add("success", "true").
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