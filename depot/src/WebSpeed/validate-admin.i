
/*------------------------------------------------------------------------
    File        : validate-admin.i
    Purpose     : Stop all the hackerz

    Syntax      :

    Description : Validates that the current user is an admin before continuing

    Author(s)   : Andrew Garver
    Created     : Thu Dec 07 18:34:48 EST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE VARIABLE i-userid AS INTEGER NO-UNDO.

RUN VALUE(SEARCH("session-get-user-id.r")) (
    get-cookie("c-session-token"),
    OUTPUT i-userid
).

FIND gud_det WHERE gud_det.gud_people_ID = i-userid AND gud_det.gud_grp_id = "{1}" NO-ERROR.
IF NOT AVAILABLE (gud_det) THEN DO:
    DISPLAY "Unworthy User " i-userid " attempted to access this admin function at " NOW.
    RETURN.
END.