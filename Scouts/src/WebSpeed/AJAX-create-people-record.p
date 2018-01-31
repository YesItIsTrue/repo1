
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
    jObj = NEW jsonObject().
    
    DEFINE VARIABLE v-people-id        LIKE people_mstr.people_id          NO-UNDO.
    DEFINE VARIABLE v-people-firstname LIKE people_mstr.people_firstname   NO-UNDO.
    DEFINE VARIABLE v-people-midname   LIKE people_mstr.people_midname     NO-UNDO.
    DEFINE VARIABLE v-people-lastname  LIKE people_mstr.people_lastname    NO-UNDO.
    DEFINE VARIABLE v-people-prefix    LIKE people_mstr.people_prefix      NO-UNDO.
    DEFINE VARIABLE v-people-suffix    LIKE people_mstr.people_suffix      NO-UNDO.
    DEFINE VARIABLE v-people-company   LIKE people_mstr.people_company     NO-UNDO.
    DEFINE VARIABLE v-people-gender    LIKE people_mstr.people_gender      NO-UNDO.
    DEFINE VARIABLE v-people-homephone LIKE people_mstr.people_homephone   NO-UNDO.
    DEFINE VARIABLE v-people-workphone LIKE people_mstr.people_workphone   NO-UNDO.
    DEFINE VARIABLE v-people-cellphone LIKE people_mstr.people_cellphone   NO-UNDO.
    DEFINE VARIABLE v-people-fax       LIKE people_mstr.people_fax         NO-UNDO.
    DEFINE VARIABLE v-people-email     LIKE people_mstr.people_email       NO-UNDO.
    DEFINE VARIABLE v-people-email2    LIKE people_mstr.people_email2      NO-UNDO.
    DEFINE VARIABLE v-people-addr_id   LIKE people_mstr.people_addr_id     NO-UNDO.
    DEFINE VARIABLE v-people-contact   LIKE people_mstr.people_contact     NO-UNDO.
    DEFINE VARIABLE v-people-DOB       LIKE people_mstr.people_DOB         NO-UNDO.
    DEFINE VARIABLE v-people-second_addr_ID LIKE people_mstr.people_second_addr_ID NO-UNDO.
    DEFINE VARIABLE v-people-prefname  LIKE people_mstr.people_prefname    NO-UNDO. /* 2dot1 */
    DEFINE VARIABLE v-people-title     LIKE people_mstr.people_title       NO-UNDO. /* 2dot3 */
    
    DEFINE VARIABLE v-people-create     AS LOGICAL INITIAL NO                 NO-UNDO.
    DEFINE VARIABLE v-people-update     AS LOGICAL INITIAL NO                 NO-UNDO.
    DEFINE VARIABLE v-people-avail      AS LOGICAL INITIAL YES                NO-UNDO.
    DEFINE VARIABLE v-people-successful AS LOGICAL INITIAL NO                 NO-UNDO.
    
    ASSIGN
        v-people-firstname = get-value("h-firstname")
        v-people-midname = get-value("h-midname")
        v-people-lastname = get-value("h-lastname")
        v-people-prefix = get-value("h-prefix")
        v-people-suffix = get-value("h-suffix")
        v-people-gender = LOGICAL(get-value("h-gender"))
        v-people-homephone = get-value("h-homephone")
        v-people-workphone = get-value("h-workphone")
        v-people-cellphone = get-value("h-cellphone")
        v-people-fax = get-value("h-fax")
        v-people-email = get-value("h-email")
        v-people-email2 = get-value("h-email2")
        v-people-DOB = IF get-value("h-dob") <> "" THEN DATE(INTEGER(ENTRY(2, get-value("h-dob"), "-")), INTEGER(ENTRY(3, get-value("h-dob"), "-")), INTEGER(ENTRY(1, get-value("h-dob"), "-"))) ELSE ?
        v-people-prefname = get-value("h-prefname")
        v-people-title = get-value("h-title").
        
    RUN VALUE(SEARCH("SUBpeop-ucU.r")) (
        0,
        v-people-firstname,
        v-people-midname,
        v-people-lastname,
        v-people-prefix,
        v-people-suffix,
        "",
        v-people-gender,
        v-people-homephone,
        v-people-workphone,
        v-people-cellphone,
        v-people-fax,
        v-people-email,
        v-people-email2,
        0,
        "",
        v-people-DOB,
        0,
        v-people-prefname,
        v-people-title,
        OUTPUT v-people-id,
        OUTPUT v-people-create,
        OUTPUT v-people-update,
        OUTPUT v-people-avail,
        OUTPUT v-people-successful
    ).
    
    IF v-people-successful = YES THEN DO:
        jObj:add("success", "true").
        jObj:add("peopleID", v-people-id).
        jObj:add("prettyName", v-people-firstname + " " + v-people-lastname).
    END.
    ELSE DO:
        jObj:add("error", "Something went wrong while creating that person. Please contact customer support.").
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