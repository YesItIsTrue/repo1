
/*------------------------------------------------------------------------
    File        : SUBevent-R.p
    Purpose     : Searches for, and returns, information about an event_mstr record
                  given the record's ID or its name and start and end dates

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Aug 31 10:56:15 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-event_ID LIKE event_mstr.event_ID NO-UNDO.
DEFINE INPUT PARAMETER i-event_name LIKE event_mstr.event_name NO-UNDO.
DEFINE INPUT PARAMETER i-event_start_date LIKE event_mstr.event_start_date NO-UNDO.
DEFINE INPUT PARAMETER i-event_end_date LIKE event_mstr.event_end_date NO-UNDO.

DEFINE OUTPUT PARAMETER o-event_name LIKE event_mstr.event_name NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_start_time LIKE event_mstr.event_start_time NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_end_time LIKE event_mstr.event_end_time NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_addr_id LIKE event_mstr.event_addr_id NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_desc LIKE event_mstr.event_desc NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_slogan LIKE event_mstr.event_slogan NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_contact LIKE event_mstr.event_contact NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_start_date LIKE event_mstr.event_start_date NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_end_date LIKE event_mstr.event_end_date NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_ID LIKE event_mstr.event_ID NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_color_theme LIKE event_mstr.event_color_theme NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_category LIKE event_mstr.event_category NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_URL LIKE event_mstr.event_URL NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_dress_code LIKE event_mstr.event_dress_code NO-UNDO.
DEFINE OUTPUT PARAMETER o-event_age_group LIKE event_mstr.event__char01 NO-UNDO.
DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND event_mstr WHERE ((event_mstr.event_ID = i-event_ID) OR 
    (event_mstr.event_name = i-event_name AND 
    event_mstr.event_start_date = i-event_start_date AND 
    event_mstr.event_end_date = i-event_end_date)) AND 
    event_mstr.event_deleted = ? NO-ERROR.
    
IF AVAILABLE (event_mstr) THEN DO:
    ASSIGN 
        o-event_name = event_mstr.event_name
        o-event_start_time = event_mstr.event_start_time
        o-event_end_time = event_mstr.event_end_time
        o-event_addr_id = event_mstr.event_addr_id
        o-event_desc = event_mstr.event_desc
        o-event_slogan = event_mstr.event_slogan
        o-event_contact = event_mstr.event_contact
        o-event_start_date = event_mstr.event_start_date
        o-event_end_date = event_mstr.event_end_date
        o-event_ID = event_mstr.event_ID
        o-event_color_theme = event_mstr.event_color_theme
        o-event_category = event_mstr.event_category
        o-event_URL = event_mstr.event_URL
        o-event_dress_code = event_mstr.event_dress_code
        o-event_age_group = event_mstr.event__char01
        o-success = TRUE.
END.
