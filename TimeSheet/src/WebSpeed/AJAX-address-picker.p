
/*------------------------------------------------------------------------
    File        : AJAX-address-picker.p
    Purpose     : Endpoint for address select2

    Syntax      :

    Description : Returns address data dynamically based on address line 1

    Author(s)   : Andrew Garver
    Created     : Fri Sep 01 23:08:59 EDT 2017
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
        searchTerms = get-value("addr1").
    
    FOR EACH addr_mstr WHERE addr_mstr.addr_addr1 CONTAINS searchTerms AND
     addr_mstr.addr_deleted = ? NO-LOCK BY addr_mstr.addr_addr1:
        jObj = NEW jsonObject().
        jObj:add("id", addr_mstr.addr_id).
        jObj:add("text", addr_mstr.addr_addr1).
        jObj:add("addr2", addr_mstr.addr_addr2).
        jObj:add("cityStateZip", addr_mstr.addr_city + ", " + addr_mstr.addr_stateprov + " " + addr_mstr.addr_zip).
        jObjArray:add(jObj).
    END.
    
    jObj = NEW jsonObject().
    jObj:add("id", "-1").
    jObj:add("text", "New Address").
    jObjArray:add(jObj).
        
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