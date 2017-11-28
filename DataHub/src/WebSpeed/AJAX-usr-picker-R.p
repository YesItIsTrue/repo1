/*------------------------------------------------------------------------
    File        : AJAX-people-picker.p
    Purpose     : Endpoint for people select2

    Syntax      :

    Description : Returns people data dynamically based on first and last name search

    Author(s)   : Andrew Garver
    Created     : Fri Sep 01 14:26:07 EDT 2017
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
    DEFINE VARIABLE jObj AS jsonObject.
    DEFINE VARIABLE jObjArray AS jsonArray.
    DEFINE VARIABLE jsonResults AS jsonObject.
    DEFINE VARIABLE searchTerms AS CHARACTER NO-UNDO.
    DEFINE VARIABLE numTerms AS INTEGER NO-UNDO.

    ASSIGN 
        jObjArray = NEW jsonArray()
        jsonResults = NEW jsonObject()
        searchTerms = get-value("name")
        numTerms = NUM-ENTRIES(searchTerms, " ").
    
    IF numTerms = 1 THEN DO:
        FOR EACH people_mstr WHERE (people_mstr.people_firstname BEGINS searchTerms OR people_mstr.people_lastname BEGINS searchTerms) AND
        people_mstr.people_deleted = ? NO-LOCK BY people_mstr.people_firstname:
            FIND usr_mstr WHERE usr_mstr.usr_people_ID = people_mstr.people_id NO-ERROR.
            IF AVAILABLE (usr_mstr) THEN DO:
                jObj = NEW jsonObject().
                jObj:add("id", people_mstr.people_id).
                jObj:add("text", people_mstr.people_firstname + " " + people_mstr.people_lastname).
                jObj:add("username", usr_mstr.usr_name).
                jObjArray:add(jObj).
            END.
        END.
    END.
    ELSE IF numTerms > 1 THEN DO:
        FOR EACH people_mstr WHERE people_mstr.people_firstname BEGINS ENTRY(1, searchTerms, " ") AND 
        people_mstr.people_lastname BEGINS ENTRY(2, searchTerms, " ") AND 
        people_mstr.people_deleted = ? NO-LOCK BY people_mstr.people_lastname:
            FIND usr_mstr WHERE usr_mstr.usr_people_ID = people_mstr.people_id NO-ERROR.
            IF AVAILABLE (usr_mstr) THEN DO:
                jObj = NEW jsonObject().
                jObj:add("id", people_mstr.people_id).
                jObj:add("text", people_mstr.people_firstname + " " + people_mstr.people_lastname).
                jObj:add("username", usr_mstr.usr_name).
                jObjArray:add(jObj).
            END.
        END.
    END.
    
    jsonResults:add("results", jObjArray).
    jsonResults:write(OUTPUT cOut).
END PROCEDURE.
 
PROCEDURE outputHeader :
    output-content-type ("application/json":U).  
END PROCEDURE.
 
PROCEDURE process-web-request :
    RUN outputHeader.
    RUN createJson.
 
    {&OUT} STRING(cOut).
END PROCEDURE.