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
    DEFINE VARIABLE v-event_ID AS INTEGER NO-UNDO.
    DEFINE VARIABLE v-event_name LIKE event_mstr.event_name NO-UNDO.
    DEFINE VARIABLE v-event_start_time LIKE event_mstr.event_start_time NO-UNDO.
    DEFINE VARIABLE v-event-start-time-string AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-event_end_time LIKE event_mstr.event_end_time NO-UNDO.
    DEFINE VARIABLE v-event-end-time-string AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-event_addr_id LIKE event_mstr.event_addr_id NO-UNDO.
    DEFINE VARIABLE v-event_desc LIKE event_mstr.event_desc NO-UNDO.
    DEFINE VARIABLE v-event_slogan LIKE event_mstr.event_slogan NO-UNDO.
    DEFINE VARIABLE v-event_contact LIKE event_mstr.event_contact NO-UNDO.
    DEFINE VARIABLE v-event_start_date LIKE event_mstr.event_start_date NO-UNDO.
    DEFINE VARIABLE v-event_end_date LIKE event_mstr.event_end_date NO-UNDO.
    DEFINE VARIABLE v-event_color_theme LIKE event_mstr.event_color_theme NO-UNDO.
    DEFINE VARIABLE v-event_category LIKE event_mstr.event_category NO-UNDO.
    DEFINE VARIABLE v-event_URL LIKE event_mstr.event_URL NO-UNDO.
    DEFINE VARIABLE v-event_dress_code LIKE event_mstr.event_dress_code NO-UNDO. 
    DEFINE VARIABLE v-event_age_group LIKE event_mstr.event__char01 NO-UNDO.
    DEFINE VARIABLE v-start-date-string AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-end-date-string AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-success AS LOGICAL INITIAL NO NO-UNDO.
    DEFINE VARIABLE v-action AS CHARACTER NO-UNDO.
    
    ASSIGN 
        v-event_name = html-encode(get-value("eventName"))
        v-event_addr_id = INTEGER(html-encode(get-value("eventAddressID")))
        v-event_desc = html-encode(get-value("eventDescription"))
        v-event_slogan = html-encode(get-value("eventSlogan"))
        v-event_contact = INTEGER(html-encode(get-value("eventContact")))
        v-start-date-string = html-encode(get-value("eventStartDate"))
        v-end-date-string = html-encode(get-value("eventEndDate"))
        v-event_ID = INTEGER(html-encode(get-value("eventID")))
        v-event_color_theme = html-encode(get-value("eventColorTheme"))
        v-event_category = html-encode(get-value("eventCategory"))
        v-event_URL = html-encode(get-value("eventURL"))
        v-event_dress_code = html-encode(get-value("eventDressCode"))
        v-event-start-time-string = html-encode(get-value("eventStartTimeString"))
        v-event-end-time-string = html-encode(get-value("eventEndTimeString"))
        v-event_age_group = html-encode(get-value("eventAgeGroup")).
    
    RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (                                               
        v-start-date-string,                                                                             
        OUTPUT v-event_start_date                                                                    
    ).
    
    RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (                                               
        v-end-date-string,                                                                             
        OUTPUT v-event_end_date                                                                        
    ).
    
    IF v-event-start-time-string <> "" THEN 
        v-event_start_time = DATETIME(MONTH(v-event_start_date), DAY(v-event_start_date), YEAR(v-event_start_date), INTEGER(ENTRY(1, v-event-start-time-string, ":")), INTEGER(ENTRY(2, v-event-start-time-string, ":"))).
    IF v-event-end-time-string <> "" THEN 
        v-event_end_time = DATETIME(MONTH(v-event_end_date), DAY(v-event_end_date), YEAR(v-event_end_date), INTEGER(ENTRY(1, v-event-end-time-string, ":")), INTEGER(ENTRY(2, v-event-end-time-string, ":"))).
        
    DISPLAY v-event_start_time.
    
    RUN VALUE(SEARCH("SUBevent-ucU.r")) (
        v-event_ID,
        v-event_name,
        v-event_start_time,
        v-event_end_time,
        v-event_addr_id,
        v-event_desc,
        v-event_slogan,
        v-event_contact,
        v-event_start_date,
        v-event_end_date,
        v-event_color_theme,
        v-event_category,
        v-event_URL,
        v-event_dress_code,
        v-event_age_group,
        OUTPUT v-success,
        OUTPUT v-action,
        OUTPUT v-event_ID
    ).
        
    IF v-success THEN 
        jObj:Add("success", "true").
    ELSE 
        jObj:Add("error", "Something went wrong while creating that event").
    /* End logic */
 
    jObj:write(OUTPUT cOut).
END PROCEDURE.
 
PROCEDURE outputHeader :
    output-content-type ("application/json":U).  
END PROCEDURE.
 
PROCEDURE process-web-request :
    {validate-admin.i "TSadmin"}.
    
    RUN outputHeader.
    RUN createJson.
 
    {&OUT} STRING(cOut).
END PROCEDURE.