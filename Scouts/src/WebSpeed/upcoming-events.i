
/*------------------------------------------------------------------------
    File        : upcoming-events.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Thu Oct 19 13:14:16 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<div class='w3-card-4 w3-content w3-white' style='height: 100%'>" SKIP
        "<header class='w3-container w3-theme-dark'>" SKIP
        "   <h3>Upcoming Events</h3>" SKIP
        "</header>" SKIP.

    {&OUT}
        "<ul class='w3-ul' style='overflow: auto; height: calc(100% - 48px)'>" SKIP.
           
FOR EACH event_mstr WHERE event_mstr.event_start_date >= TODAY AND 
        event_mstr.event_deleted = ? NO-LOCK 
    BREAK BY YEAR(event_mstr.event_start_date) BY event_mstr.event_start_date BY event_mstr.event_name:     /* 1dot1 */
    
    /*** begin 1dot1 ***/
    IF FIRST-OF (YEAR(event_mstr.event_start_date)) THEN 
        {&OUT}
            "       <li class='w3-padding w3-white w3-theme' style='border-bottom: 1px solid #ddd !important;'>" SKIP
            "           <span class='w3-margin-right w3-large'>" SKIP
            "               <CENTER>" YEAR(event_mstr.event_start_date) "</CENTER>" SKIP 
            "           </span>" SKIP
            "       </li>" SKIP.                
    /*** end 1dot1 ***/
    
/*    IF event_mstr.event_url <> "" THEN*/
        {&OUT}
            "       <a href=~"event-flyer-preview.html?h-event_ID=" event_mstr.event_id "~" class='ajax-event-link' style='text-decoration:none;'>" SKIP
            "           <input type='hidden' value='" event_mstr.event_id "'/>" SKIP
            "           <li class='w3-padding-16 w3-white w3-hover-theme' style='border-bottom: 1px solid #ddd !important;'>" SKIP
            "               <span class='w3-large'>" event_mstr.event_name " (" event_mstr.event_start_date ")</span>" SKIP
            "           </li>" SKIP
            "       </a>" SKIP.
            
/*    ELSE                                                                                                                          */
/*        {&OUT}                                                                                                                    */
/*            "           <li class='w3-padding-16 w3-white w3-hover-theme' style='border-bottom: 1px solid #ddd !important;'>" SKIP*/
/*            "               <span class='w3-large'>" event_mstr.event_name " (" event_mstr.event_start_date ")</span>" SKIP       */
/*            "           </li>" SKIP.                                                                                              */

END.  /** of 4ea. event_mstr **/

{&OUT}
    "   </ul>" SKIP
    "</div>" SKIP.