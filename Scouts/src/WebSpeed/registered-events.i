
/*------------------------------------------------------------------------
    File        : registered-events.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Nov 17 12:12:35 EST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE VARIABLE i-people-id LIKE people_mstr.people_id NO-UNDO.

RUN VALUE(SEARCH("session-get-user-id.r")) (
    get-cookie("c-session-token"),
    OUTPUT i-people-id
).
    
{&OUT}
"<header class='w3-container w3-theme-dark'>" SKIP
"    <h3>Registered Events</h3>" SKIP
"</header>" SKIP
"<ul class='w3-ul'> " SKIP.
    
DEFINE VARIABLE v-num-registered-events AS INTEGER INITIAL 0 NO-UNDO.

FOR EACH regis_mstr WHERE regis_mstr.regis_people_id = i-people-id AND regis_mstr.regis_deleted = ?,
EACH sched_mstr WHERE sched_mstr.sched_class_ID = regis_mstr.regis_class_ID AND sched_mstr.sched_deleted = ?,
EACH event_mstr WHERE event_mstr.event_ID = sched_mstr.sched_event_ID AND event_mstr.event_start_date >= TODAY AND event_mstr.event_deleted = ? NO-LOCK 
BREAK BY YEAR(event_mstr.event_start_date) BY event_mstr.event_start_date BY event_mstr.event_name BY event_mstr.event_ID:
    IF FIRST-OF (YEAR(event_mstr.event_start_date)) THEN DO:

    {&OUT}
    "<li class='w3-padding w3-white w3-theme' style='border-bottom: 1px solid #ddd !important;'>" SKIP
    "   <span class='w3-margin-right w3-large'>" SKIP
    "       <center>`YEAR(event_mstr.event_start_date)`</center> " SKIP
    "   </span>" SKIP
    "</li>" SKIP.
    
    END. /* IF FIRST-OF (YEAR(event_mstr.event_start_date)) */
    
    IF FIRST-OF (event_mstr.event_ID) THEN DO:
        v-num-registered-events = v-num-registered-events + 1.
        IF event_mstr.event_URL <> '' THEN DO:  
            
            {&OUT}
            "<a href='event-flyer-preview.html?h-event_ID=`event_mstr.event_id`' style='text-decoration:none;'>" SKIP
            "    <li class='w3-padding-16 w3-white w3-hover-theme' style='border-bottom: 1px solid #ddd !important;'>" SKIP
            "        <span class='w3-large'> `event_mstr.event_name`  ( `event_mstr.event_start_date` )</span>" SKIP
            "    </li>" SKIP
            "</a>" SKIP.

        END. /* IF event_mstr.event_URL <> '' */
    END. /* IF FIRST-OF (event_mstr.event_ID) */
END.  /** of 4ea. event_mstr **/
        
IF v-num-registered-events = 0 THEN DO:
    {&OUT}
        "<li class='w3-padding-16 w3-white w3-hover-theme' style='border-bottom: 1px solid #ddd !important;'>" SKIP
            "<span class='w3-large'>You haven't registered for any events yet!</span>" SKIP
        "</li>" SKIP.
END.
 
{&OUT}
    "</ul>" SKIP.