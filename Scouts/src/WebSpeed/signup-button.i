
/*------------------------------------------------------------------------
    File        : signup-button.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Oct 19 16:28:17 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<style>" SKIP
    "   .i-signup-btn ~{" SKIP
    "       width: 90%;" SKIP
    "       height: 100%;" SKIP
    "   ~}" SKIP
    "</style>" SKIP.
    
DEFINE VARIABLE i-event-registered AS LOGICAL INITIAL NO NO-UNDO.

{&OUT}
    "<div id='register-btn'>" SKIP.
    
FOR EACH regis_mstr WHERE regis_mstr.regis_people_id = {1} AND regis_mstr.regis_deleted = ?,
EACH sched_mstr WHERE sched_mstr.sched_class_ID = regis_mstr.regis_class_ID AND sched_mstr.sched_event_ID = {2} AND sched_mstr.sched_deleted = ? NO-LOCK:
    ASSIGN i-event-registered = YES.
    {&OUT}
        "<center><button type='button' class='w3-btn-block w3-theme-dark w3-round i-signup-btn'><h2>You're registered!</h2></button></center>" SKIP.
END.

IF NOT i-event-registered THEN DO:
    FIND event_mstr WHERE event_mstr.event_ID = {2} AND event_mstr.event_deleted = ? NO-ERROR.
    IF AVAILABLE (event_mstr) THEN DO:
        IF event_mstr.event_URL <> "" THEN DO:
            {&OUT}
                "<a href=~"" event_mstr.event_url "~">" SKIP.

                IF event_mstr.event_URL BEGINS "event-one-click-signup." THEN
                    {&OUT}
                        "   <center><button type='submit' class='w3-btn-block w3-green w3-round i-signup-btn'><h1>I'm IN!</h1></button></center>" SKIP.
                ELSE
                    {&OUT}
                        "   <center><button type='submit' class='w3-btn-block w3-green w3-round i-signup-btn'><h1>Sign up!</h1></button></center>" SKIP.
            {&OUT}
                "</a>" SKIP.
        END.
        ELSE
            {&OUT}
                "<center><button type='button' class='w3-btn-block w3-grey w3-round i-signup-btn'>Registration not yet available</button></center>" SKIP.
    END.
END.

{&OUT}
    "</div>" SKIP.