
/*------------------------------------------------------------------------
    File        : event-upcoming.i

    Description : A little self contained card that makes a list of upcoming events. 
        Now that it is finished, I am thinking I probably could have just stole the 
        guts out of the AMS-landing-R.html program.

    Author(s)   : Trae Luttrell
    Created     : Fri Sep 29 16:44:53 EDT 2017
    Version     : 1.0
    Notes       : If you want multiple uses on the same web page, you need to make
        a different counter variable.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE c-event AS INTEGER NO-UNDO.

/* ***************************  Main Proc  **************************** */
{&OUT}
    "           <div class='w3-card-4 w3-white'>" SKIP
    "               <div class='w3-theme-accent w3-container'>" SKIP
    "               <h2>Upcomming Events</h2>" SKIP
    "               </div>" SKIP
    "              <ul class='w3-ul'>" SKIP. 

    ASSIGN c-event = 0.

    FOR EACH event_mstr WHERE event_mstr.event_start_date > TODAY NO-LOCK:
    
        IF c-event >= 4 THEN LEAVE.
    
        {&OUT}
            "                  <li class='w3-bar w3-hover-theme'>" SKIP
            "                      <div class='w3-bar-item'>" SKIP
            "                          <span class='w3-large'>" event_mstr.event_name "</span><br>" SKIP
            "                          <span>" event_mstr.event_slogan "</span>" SKIP
            "                      </div>" SKIP 
            "                  </li>" SKIP.    
    
        ASSIGN c-event = c-event + 1.
        
    END. /*** event_mstr 4ea ***/

    ASSIGN c-event = 0.

{&OUT}
    "               </ul>" SKIP
    "           </div>" SKIP.


/* ***************************  Main Block  *************************** */
