
/*------------------------------------------------------------------------
    File        : TSvert-menu.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Tue Oct 31 08:20:17 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/*TODO: Remove these silly lines. For backwards compatibility while we iron out old things.*/
DEFINE VARIABLE whatshouldrun AS CHARACTER NO-UNDO. 
DEFINE VARIABLE menuprefix AS CHARACTER NO-UNDO.
DEFINE VARIABLE menusuffix AS INTEGER NO-UNDO.      
DEFINE VARIABLE menuheadername AS CHARACTER NO-UNDO.
/*End of silly lines*/

{&OUT}
    "<link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>" SKIP
    "<link rel='stylesheet' href='/depot/src/HTMLContent/stylesheets/timesheet.css'>" SKIP
    "<link rel='stylesheet' href='https://fonts.googleapis.com/css?family=Montserrat'>" SKIP
    "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css'>" SKIP
    "<!-- Icon Bar (Sidebar - hidden on small screens) -->" SKIP
    "<div id='side-nav' class='col-md-1'>" SKIP
    "   <nav class='w3-sidebar w3-bar-block w3-small w3-hide-small w3-center w3-theme'>" SKIP
    "     <!-- Avatar image in top left corner -->" SKIP
    "     <img src='/depot/src/HTMLContent/images/Solsource/Solsource_Logo_V_RGB_Sm.jpg' style='width:100%'>" SKIP
    "     <a href='app-portal.r#' class='w3-bar-item w3-button w3-padding-large w3-hover-theme-accent top-nav-btn'>" SKIP
    "       <i class='fa fa-home w3-xxlarge'></i>" SKIP
    "       <p>HOME</p>" SKIP
    "     </a>" SKIP
    "     <a href='app-portal.r#reports' class='w3-bar-item w3-button w3-padding-large w3-hover-theme-accent'>" SKIP
    "       <i class='fa fa-list w3-xxlarge'></i>" SKIP
    "       <p>REPORTS</p>" SKIP
    "     </a>" SKIP
    "     <a href='app-portal.r#maintenance' class='w3-bar-item w3-button w3-padding-large w3-hover-theme-accent'>" SKIP
    "       <i class='fa fa-wrench w3-xxlarge'></i>" SKIP
    "       <p>MAINT</p>" SKIP
    "     </a>" SKIP
    "     <a href='cookie-logout-html.r?redirect-location=TSlogin.r' class='w3-bar-item w3-button w3-padding-large w3-hover-theme-accent logout-btn'>" SKIP
    "       <i class='fa fa-sign-out w3-xxlarge'></i>" SKIP
    "       <p>LOGOUT</p>" SKIP
    "     </a>" SKIP
    "   </nav>" SKIP
    "" SKIP
    "   <!-- Navbar on small screens (Hidden on medium and large screens) -->" SKIP
    "    <div class='w3-top w3-hide-large w3-hide-medium' id='myNavbar'>" SKIP
    "       <div class='w3-bar w3-theme w3-center top-menu'>" SKIP
    "           <a href='app-portal.r#' class='w3-bar-item w3-button' style='width:25% !important'>HOME</a>" SKIP
    "           <a href='app-portal.r#reports' class='w3-bar-item w3-button' style='width:25% !important'>REPORTS</a>" SKIP
    "           <a href='app-portal.r#maintenance' class='w3-bar-item w3-button' style='width:25% !important'>MAINT</a>" SKIP
    "           <a href='cookie-logout-html.r?redirect-location=TSlogin.r' class='w3-bar-item w3-button' style='width:25% !important'>LOGOUT</a>" SKIP
    "       </div>" SKIP
    "    </div>" SKIP
    "</div>" SKIP.