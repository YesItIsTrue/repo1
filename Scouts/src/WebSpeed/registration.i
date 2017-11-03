
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

ASSIGN
    i-organization = "Augusta Maine Stake"
    i-group = html-encode(get-value("h-group")).

FIND usr_mstr WHERE usr_mstr.usr_people_ID = INTEGER(get-cookie("c-user-id")) AND usr_mstr.usr_deleted = ? NO-ERROR.
IF NOT AVAILABLE (usr_mstr) THEN DO:
    {&OUT} "<script>window.location = 'https://google.com';</script>".
END.

{&OUT}
"<header class='w3-container w3-theme-dark' style='margin-bottom: 2%'>" SKIP
"    <a href='regis-homepage.html'>" SKIP
"       <h3 class='menu-title'>" i-organization " " i-group "Activities</h3>" SKIP
"    </a>" SKIP
"    <div class='user-settings'>" SKIP
"           <h3>" SKIP
"               <span>Signed in as " usr_mstr.usr_name " &nbsp;</span>" SKIP
"               <form action='account-preferences.html' method='post' class='title-form'>" SKIP

/*"                   <button type='submit' class='title-btn' title='Account Preferences'><i class='fa fa-cog' aria-hidden='true'></i></button>" SKIP*/
"               </form>" SKIP
"               <form action='cookie-logout.html' method='post' class='title-form'>" SKIP
"                   <button type='submit' class='title-btn' title='Logout'><i class='fa fa-sign-out' aria-hidden='true'></i></button>" SKIP
"               </form>" SKIP
"           </h3>" SKIP
"    </div>" SKIP
"</header>" SKIP.