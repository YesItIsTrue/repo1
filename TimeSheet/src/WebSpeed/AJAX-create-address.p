
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
    
    DEFINE VARIABLE v-addr-id          LIKE addr_mstr.addr_id        NO-UNDO.
    DEFINE VARIABLE v-addr-addr1       LIKE addr_mstr.addr_addr1     NO-UNDO.
    DEFINE VARIABLE v-addr-addr2       LIKE addr_mstr.addr_addr2     NO-UNDO.
    DEFINE VARIABLE v-addr-addr3       LIKE addr_mstr.addr_addr3     NO-UNDO.
    DEFINE VARIABLE v-addr-city        LIKE addr_mstr.addr_city      NO-UNDO.
    DEFINE VARIABLE v-addr-stateprov   LIKE addr_mstr.addr_stateprov NO-UNDO.
    DEFINE VARIABLE v-addr-zip         LIKE addr_mstr.addr_zip       NO-UNDO.
    DEFINE VARIABLE v-addr-country     LIKE addr_mstr.addr_country   NO-UNDO.
    DEFINE VARIABLE v-addr-type        LIKE addr_mstr.addr_type      NO-UNDO.
    
    DEFINE VARIABLE v-addr-create     AS LOGICAL INITIAL NO           NO-UNDO.
    DEFINE VARIABLE v-addr-update     AS LOGICAL INITIAL NO           NO-UNDO.
    DEFINE VARIABLE v-addr-avail      AS LOGICAL INITIAL YES          NO-UNDO.
    DEFINE VARIABLE v-addr-successful AS LOGICAL INITIAL NO           NO-UNDO.
        
    ASSIGN
        jObj = NEW jsonObject()
        v-addr-addr1 = get-value("h-addr1")
        v-addr-addr2 = get-value("h-addr2")
        v-addr-addr3 = get-value("h-addr3")
        v-addr-city = get-value("h-city")
        v-addr-stateprov = get-value("h-stateprov")
        v-addr-zip = get-value("h-zip")
        v-addr-country = get-value("h-country").
        
    RUN VALUE(SEARCH("SUBaddr-ucU.r")) (
        0,
        v-addr-addr1,
        v-addr-addr2,
        v-addr-addr3,
        v-addr-city,
        v-addr-stateprov,
        v-addr-zip,
        v-addr-country,
        "Primary",
        OUTPUT v-addr-id,
        OUTPUT v-addr-create,
        OUTPUT v-addr-update,
        OUTPUT v-addr-avail,
        OUTPUT v-addr-successful
    ).
    
    IF v-addr-successful = YES THEN DO:
        jObj:add("success", "true").
        jObj:add("addrid", v-addr-id).
        jObj:add("prettyAddress", v-addr-addr1 + (IF v-addr-addr2 <> "" THEN ", " + v-addr-addr2 ELSE ", ") + v-addr-city + ", " + v-addr-stateprov + " " + v-addr-zip).
    END.
    ELSE DO:
        jObj:add("error", "Something went wrong while creating that address. Please contact customer support.").
    END.
        
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