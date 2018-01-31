
/*------------------------------------------------------------------------
    File        : event-details.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Thu Oct 19 14:06:27 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE VARIABLE i-event-location AS CHARACTER FORMAT "x(16)" INITIAL "TBA" NO-UNDO.

{&OUT}
    "<div class='w3-card-4 w3-content w3-white' style='height: 100%'>" SKIP
    "    <header class='w3-container w3-theme-dark' style='height: 48px'>" SKIP
    "        <h3>Event Details</h3>" SKIP
    "    </header>" SKIP
    "    <ul class='w3-ul' style='overflow: auto; height: calc(100% - 48px)'>" SKIP. 
        
FOR FIRST event_mstr WHERE (event_mstr.event_ID = {1}) AND
    event_mstr.event_deleted = ? NO-LOCK 
        BREAK BY YEAR(event_mstr.event_start_date) DESCENDING  
            BY event_mstr.event_start_date 
            BY event_mstr.event_start_time:
            
    IF event_mstr.event_addr_id <> 0 THEN        
        FIND addr_mstr WHERE addr_mstr.addr_id = event_mstr.event_addr_id AND 
            addr_mstr.addr_deleted = ? 
                NO-LOCK NO-ERROR.
                
    IF AVAILABLE (addr_mstr) THEN 
        ASSIGN i-event-location = addr_mstr.addr_city.
    ELSE 
        ASSIGN i-event-location = "TBA".
    
    {&OUT}
                   /** What? --- Name row **/
        "       <div class='w3-row w3-padding-small w3-white w3-display-container'>" SKIP
        "           <div class='w3-col m4'><b>What?</b></div>" SKIP
        "           <div class='w3-col m8'>" SKIP
        "               <center id='ed-name'>" event_mstr.event_name "</center>" SKIP 
        "           </div>" SKIP
        "       </div>" SKIP
        
                   /** Who? --- Ages row **/
        "       <div class='w3-row w3-padding-small w3-white w3-display-container'>" SKIP
        "           <div class='w3-col m4'><b>Ages</b></div>" SKIP
        "           <div class='w3-col m8'>" SKIP
        "               <CENTER id='ed-ages'>" event_mstr.event__char01 "</CENTER>" SKIP 
        "           </div>" SKIP
        "       </div>" SKIP     
        
                   /** When? --- Start date row **/
        "       <div class='w3-row w3-padding-small w3-white w3-display-container'>" SKIP
        "           <div class='w3-col m4'><b>Start Date</b></div>" SKIP
        "           <div class='w3-col m8'>" SKIP
        "               <CENTER id='ed-start-date'>" event_mstr.event_start_date "</CENTER>" SKIP 
        "           </div>" SKIP
        "       </div>" SKIP      
         
                    /** Start Time row **/
        "       <div class='w3-row w3-padding-small w3-white w3-display-container'>" SKIP
        "           <div class='w3-col m4'><b>Start Time</b></div>" SKIP
        "           <div class='w3-col m8'>" SKIP
        "               <CENTER id='ed-start-time'>" event_mstr.event_start_time "</CENTER>" SKIP 
        "           </div>" SKIP
        "       </div>" SKIP         
        

                    /** End Time row **/
        "       <div  class='w3-row w3-padding-small w3-white w3-display-container'>" SKIP
        "           <div class='w3-col m4'><b>End Time</b></div>" SKIP
        "           <div class='w3-col m8'>" SKIP
        "               <CENTER id='ed-end-time'>" event_mstr.event_end_time "</CENTER>" SKIP 
        "           </div>" SKIP
        "       </div>" SKIP  
        
                    /** Where? --- location row **/
        "       <div class='w3-row w3-padding-small w3-white w3-display-container'>" SKIP
        "           <div class='w3-col m4'><b>Location</b></div>" SKIP
        "           <div class='w3-col m8'>" SKIP
        "               <CENTER id='ed-location'>" i-event-location "</CENTER>" SKIP 
        "           </div>" SKIP
        "       </div>" SKIP  
        
                    /** Dress code row **/
        "       <div class='w3-row w3-padding-small w3-white w3-display-container'>" SKIP
        "           <div class='w3-col m4'><b>Dress Code</b></div>" SKIP
        "           <div class='w3-col m8'>" SKIP
        "               <CENTER id='ed-dress-code'>" event_mstr.event_dress_code "</CENTER>" SKIP 
        "           </div>" SKIP
        "       </div>" SKIP.
END.  /** of 4first. event_mstr **/

{&OUT}
    "   </UL>" SKIP
    "</div>" SKIP(1).