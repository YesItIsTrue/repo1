
/*------------------------------------------------------------------------
    File        : SUBevent-ucU.p
    Purpose     : Update / Create event_mstr records

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Aug 31 10:54:01 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-event_ID LIKE event_mstr.event_ID NO-UNDO.
DEFINE INPUT PARAMETER i-event_name LIKE event_mstr.event_name NO-UNDO.
DEFINE INPUT PARAMETER i-event_start_time LIKE event_mstr.event_start_time NO-UNDO.
DEFINE INPUT PARAMETER i-event_end_time LIKE event_mstr.event_end_time NO-UNDO.
DEFINE INPUT PARAMETER i-event_addr_id LIKE event_mstr.event_addr_id NO-UNDO.
DEFINE INPUT PARAMETER i-event_desc LIKE event_mstr.event_desc NO-UNDO.
DEFINE INPUT PARAMETER i-event_slogan LIKE event_mstr.event_slogan NO-UNDO.
DEFINE INPUT PARAMETER i-event_contact LIKE event_mstr.event_contact NO-UNDO.
DEFINE INPUT PARAMETER i-event_start_date LIKE event_mstr.event_start_date NO-UNDO.
DEFINE INPUT PARAMETER i-event_end_date LIKE event_mstr.event_end_date NO-UNDO.
DEFINE INPUT PARAMETER i-event_color_theme LIKE event_mstr.event_color_theme NO-UNDO.
DEFINE INPUT PARAMETER i-event_category LIKE event_mstr.event_category NO-UNDO.
DEFINE INPUT PARAMETER i-event_URL LIKE event_mstr.event_URL NO-UNDO.
DEFINE INPUT PARAMETER i-event_dress_code LIKE event_mstr.event_dress_code NO-UNDO. 

DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.
DEFINE OUTPUT PARAMETER o-action AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_ID LIKE event_mstr.event_ID NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND event_mstr WHERE event_mstr.event_ID = i-event_ID AND event_mstr.event_deleted = ? NO-ERROR.
    
IF AVAILABLE (event_mstr) THEN DO:
    ASSIGN 
        event_mstr.event_name = IF i-event_name <> "" THEN i-event_name ELSE event_mstr.event_name
        event_mstr.event_start_time = IF i-event_start_time <> ? THEN i-event_start_time ELSE event_mstr.event_start_time
        event_mstr.event_end_time = IF i-event_end_time <> ? THEN i-event_end_time ELSE event_mstr.event_end_time
        event_mstr.event_addr_id = IF i-event_addr_id <> 0 THEN i-event_addr_id ELSE event_mstr.event_addr_id
        event_mstr.event_desc = IF i-event_desc <> "" THEN i-event_desc ELSE event_mstr.event_desc
        event_mstr.event_slogan = IF i-event_slogan <> "" THEN i-event_slogan ELSE event_mstr.event_slogan
        event_mstr.event_contact = IF i-event_contact <> 0 THEN i-event_contact ELSE event_mstr.event_contact
        event_mstr.event_start_date = IF i-event_start_date <> ? THEN i-event_start_date ELSE event_mstr.event_start_date
        event_mstr.event_end_date = IF i-event_end_date <> ? THEN i-event_end_date ELSE event_mstr.event_end_date
        event_mstr.event_ID = IF i-event_ID <> 0 THEN i-event_ID ELSE event_mstr.event_ID
        event_mstr.event_color_theme = IF i-event_color_theme <> "" THEN i-event_color_theme ELSE event_mstr.event_color_theme
        event_mstr.event_category = IF i-event_category <> "" THEN i-event_category ELSE event_mstr.event_category
        event_mstr.event_URL = IF i-event_URL <> "" THEN i-event_URL ELSE event_mstr.event_URL
        event_mstr.event_dress_code = IF i-event_dress_code <> "" THEN i-event_dress_code ELSE event_mstr.event_dress_code
        event_mstr.event_modified_date = TODAY 
        event_mstr.event_modified_by = USERID("Modules")
        event_mstr.event_prog_name = THIS-PROCEDURE:FILENAME
        o-success = TRUE 
        o-action = "update"
        o-event_ID = event_mstr.event_ID.
END.
ELSE DO:
        CREATE event_mstr.
        ASSIGN 
            event_mstr.event_name = i-event_name
            event_mstr.event_start_time = i-event_start_time
            event_mstr.event_end_time = i-event_end_time
            event_mstr.event_addr_id = i-event_addr_id
            event_mstr.event_desc = i-event_desc
            event_mstr.event_slogan = i-event_slogan
            event_mstr.event_contact = i-event_contact
            event_mstr.event_start_date = i-event_start_date
            event_mstr.event_end_date =  i-event_end_date
            event_mstr.event_ID = NEXT-VALUE(seq-event)
            event_mstr.event_color_theme = i-event_color_theme
            event_mstr.event_category = i-event_category
            event_mstr.event_URL = i-event_URL
            event_mstr.event_dress_code = i-event_dress_code
            event_mstr.event_create_date = TODAY 
            event_mstr.event_created_by = USERID("Modules")
            event_mstr.event_prog_name = THIS-PROCEDURE:FILENAME
            o-success = TRUE 
            o-action = "create"
            o-event_ID = event_mstr.event_ID.
END.