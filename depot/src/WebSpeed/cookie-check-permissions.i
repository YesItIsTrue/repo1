
/*------------------------------------------------------------------------
    File        : cookie-check-permissions.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Wed Oct 18 14:26:42 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* This will redirect the user back to the login page if their cookie expires or their session can't be validated. */
DEFINE VARIABLE i-session-token AS CHARACTER NO-UNDO.
DEFINE VARIABLE i-menu-exprog AS CHARACTER NO-UNDO FORMAT "x(70)".
DEFINE VARIABLE i-worthiness-verified AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE i-empid AS INTEGER NO-UNDO.
    
RUN VALUE(SEARCH("session-get-user-id.r")) (
    get-cookie("c-session-token"),
    OUTPUT i-empid
).

i-session-token = get-cookie("c-session-token").
FIND session_det WHERE session_det.session_token = i-session-token NO-ERROR.
IF i-session-token = "" OR NOT AVAILABLE(session_det) OR session_det.session_expiration <= NOW THEN DO:
    DISPLAY "Session expired".
    RUN VALUE(SEARCH("cookie-logout.r")) (
        "{1}"
    ).
END.

/* This is done outside of the FOR EACH because putting it inside will cause the table to be searched without indexes */
i-menu-exprog = ENTRY(1, ENTRY(NUM-ENTRIES(THIS-PROCEDURE:FILE-NAME, "/"), THIS-PROCEDURE:FILE-NAME, "/"), ".").

FOR EACH menu_mstr WHERE menu_mstr.menu_exprog CONTAINS i-menu-exprog NO-LOCK,
EACH gud_det WHERE gud_det.gud_people_ID = i-empid NO-LOCK,
FIRST gmd_det WHERE gmd_det.gmd_menu_num = menu_mstr.menu_num AND gmd_det.gmd_menu_select = menu_mstr.menu_select AND gmd_det.gmd_grp_id = gud_det.gud_grp_id NO-LOCK:
    i-worthiness-verified = YES.
END.

IF NOT i-worthiness-verified THEN DO:
    DISPLAY "Deemed unworthy".
    RUN VALUE(SEARCH("cookie-logout.r")) (
        "{1}"
    ).
END.

/*set-cookie("c-user-id", "deleted", ADD-INTERVAL(TODAY, -1, "days"), ?, "/", ?, ?).*/      /* This IS how TO DELETE a cookie. */

/* There is a bug in the Progress implementation of set-cookie, which is utilized by delete-cookie.
* You cannot assign an existing cookie the value of an empty string (""). Doing so causes the program to crash.
* Because delete-cookie simply calls set-cookie with an emptry string and expired date, the program crashes.
* By recreating the functionality of delete-cookie, except with a non-empty string as the value, we can 
* work around this issue.
 */