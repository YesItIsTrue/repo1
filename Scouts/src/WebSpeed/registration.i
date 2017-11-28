
/*------------------------------------------------------------------------
    File        : registration.i
    Purpose     : This both maintains consistent headers above each page, providing account preference access and logout functionality, 
                  and includes the logic for checking the worthiness of the logged in user.

    Syntax      :

    Description : This should be included at the top of every registration page

    Author(s)   : Andrew Garver
    Created     : Wed Oct 18 12:46:54 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<link rel='stylesheet' href='/depot/src/HTMLContent/stylesheets/registration.css'>".
    
DEFINE VARIABLE i-organization AS CHARACTER NO-UNDO.
DEFINE VARIABLE i-group AS CHARACTER NO-UNDO.
DEFINE VARIABLE i-regis-people-id AS INTEGER NO-UNDO.

ASSIGN
    i-organization = "Augusta Maine Stake"
    i-group = html-encode(get-value("h-group")).
    
RUN VALUE(SEARCH("session-get-user-id.r")) (
    get-cookie("c-session-token"),
    OUTPUT i-regis-people-id
).

FIND usr_mstr WHERE usr_mstr.usr_people_ID = i-regis-people-id AND usr_mstr.usr_deleted = ? NO-ERROR.
IF NOT AVAILABLE (usr_mstr) THEN DO:
    {&OUT} "<script>window.location = 'AMS-landing-R.r';</script>".
END.

{&OUT}
"<div class='w3-bar w3-theme-dark'>" SKIP
"    <a class='nav-item' href='regis-homepage.html'>" SKIP
"       <div class='menu-title nav-item w3-bar-item'>" i-organization " " i-group "Activities</div>" SKIP
"    </a>" SKIP
"   <div class='w3-right nav-item'>" SKIP
"       <div class='w3-dropdown-hover w3-bar-item w3-padding-0 w3-hover-theme'>" SKIP
"          <button class='dropbtn'>"
"              <p class='nav-line-1'>Hello,</p>" SKIP
"              <span class='nav-line-2'>" usr_mstr.usr_name "</span>" SKIP 
"          </button>" SKIP
"          <div class='w3-dropdown-content nav-dropdown w3-bar-block w3-card-4'>" SKIP
"               <a href='profile-page.html' class='w3-bar-item w3-button w3-hover-theme'><i class='fa fa-user dropdown-icon' aria-hidden='true'></i>Preferences</a>" SKIP
"               <a href='cookie-logout-html.r?redirect-location=AMS-landing-R.r' class='w3-bar-item w3-button w3-hover-theme'><i class='fa fa-sign-out dropdown-icon' aria-hidden='true'></i>Logout</a>" SKIP
"          </div>" SKIP
"       </div>" SKIP.

FIND FIRST gud_det WHERE gud_det.gud_people_ID = i-regis-people-id AND gud_det.gud_grp_id = "RegisAdmin" NO-ERROR.
IF AVAILABLE (gud_det) THEN
{&OUT}
"       <a href='regis-admin-portal.r' class='w3-bar-item w3-button nav-single w3-hover-theme-accent'>Administration</a>" SKIP.

FIND FIRST gud_det WHERE gud_det.gud_people_ID = i-regis-people-id AND gud_det.gud_grp_id = "RegisEmp" NO-ERROR.
IF AVAILABLE (gud_det) THEN
{&OUT}
"       <a href='regis-emp-portal.r' class='w3-bar-item w3-button nav-single w3-hover-theme-accent'>Counselor Portal</a>" SKIP.

{&OUT}
"   </div>" SKIP
"</div>" SKIP
"<br/><br/>" SKIP.