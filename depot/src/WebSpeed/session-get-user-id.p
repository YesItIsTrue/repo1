
/*------------------------------------------------------------------------
    File        : session-get-user-id.p
    Purpose     : Get's the user's id from the current session.

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Sat Oct 28 09:38:29 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE INPUT PARAMETER v-session-token AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER o-user-id AS INTEGER INITIAL 0 NO-UNDO.

FIND session_det WHERE session_det.session_token = v-session-token NO-ERROR.
IF AVAILABLE (session_det) THEN 
    o-user-id = session_det.session_user_id. 