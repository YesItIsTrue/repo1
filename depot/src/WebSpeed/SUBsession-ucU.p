
/*------------------------------------------------------------------------
    File        : SUBevent-ucU.p
    Purpose     : Update / Create session_det records

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Aug 31 10:54:01 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-session_token LIKE session_det.session_token NO-UNDO.
DEFINE INPUT PARAMETER i-session_user_id LIKE session_det.session_user_id NO-UNDO.
DEFINE INPUT PARAMETER i-session_expiration LIKE session_det.session_expiration NO-UNDO.

DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND session_det WHERE session_det.session_user_id = i-session_user_id NO-ERROR.
    
IF AVAILABLE (session_det) THEN DO:
    ASSIGN 
        session_det.session_token = IF i-session_token <> "" THEN i-session_token ELSE session_det.session_token
        session_det.session_expiration = IF i-session_expiration <> ? THEN i-session_expiration ELSE session_det.session_expiration
/*        session_det.session_modified_date = TODAY              */
/*        session_det.session_modified_by = USERID("Core")       */
/*        session_det.session_prog_name = THIS-PROCEDURE:FILENAME*/
        o-success = TRUE.
END.
ELSE DO:
    CREATE session_det.
    ASSIGN 
        session_det.session_token = i-session_token
        session_det.session_expiration = i-session_expiration
        session_det.session_user_id = i-session_user_id
/*        session_det.session_create_date = TODAY                */
/*        session_det.session_created_by = USERID("Core")        */
/*        session_det.session_modified_date = TODAY              */
/*        session_det.session_modified_by = USERID("Core")       */
/*        session_det.session_prog_name = THIS-PROCEDURE:FILENAME*/
        o-success = TRUE.
END.