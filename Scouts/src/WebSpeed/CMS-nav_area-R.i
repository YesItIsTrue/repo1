
/*------------------------------------------------------------------------
    File        : MC-nav_area-R.i
    Purpose     : 

    Syntax      :

    Description : Navigation area.

    Author(s)   : Doug Luttrell
    Created     : Sun Mar 26 17:26:57 EDT 2017
    Notes       :
        
        Needs to dynamically build the contents of the menu based on event_mstr and menu_mstr data.
        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<!-- Navbar (sticky bottom) -->" SKIP
/*    "<div class='w3-bottom w3-hide-small'>" SKIP    /*** uncomment this to make the menu stick to the bottom of the screen ***/ */
    "<div class=''>" SKIP    
/*    "   <div class='w3-bar w3-white w3-center w3-padding w3-opacity-min w3-hover-opacity-off'>" SKIP    /** uncomment this to make the menu see through **/*/
    "   <div class='w3-bar w3-white w3-center w3-padding'>" SKIP
    "       <a href=~"CMS-Event_Home-R.r?h-event_id=" v-event_ID "~" style='width:16%' class='w3-bar-item w3-mobile w3-button w3-hover-theme'><B>Home</B></a>" SKIP
    "       <a href=~"CMS-Event_About-R.r?h-event_id=" v-event_ID "~" style='width:16%' class='w3-bar-item w3-mobile w3-button w3-hover-theme'><B>About Man College!!!</B></a>" SKIP

/*    /*** Uncomment this line when the event_mstr is available ***/                                                                                                                    */
/*    "       <a href=~"CMS-Event_About-R.r?h-event_id=" v-event_ID "~" style='width:16%' class='w3-bar-item w3-mobile w3-button w3-hover-theme'>About " event_mstr.event_name "</a>" SKIP*/
        
    "       <a href=~"CMS-Event_FAQ-R.r?h-event_id=" v-event_ID "~"  style='width:16%' class='w3-bar-item w3-mobile w3-button w3-hover-theme'><B>FAQ</B></a>" SKIP
    "       <a href=~"CMS-Event_Schedule-R.r?h-event_id=" v-event_ID "~"  style='width:16%' class='w3-bar-item w3-mobile w3-button w3-hover-theme'><B>Schedule</B></a>" SKIP
    "       <a href=~"CMS-Event_Register-U.r?h-event_id=" v-event_ID "~"  style='width:16%' class='w3-bar-item w3-mobile w3-button w3-hover-theme'><B>Register</B></a>" SKIP
    
    "       <a href=~"CMS-Event_Class_Desc-R.r?h-event_id=" v-event_ID "~"  style='width:16%' class='w3-bar-item w3-mobile w3-button w3-hover-theme'><B>Classtivities</B></a>" SKIP

    "   </div>" SKIP
    "</div>" SKIP(1).
    
    