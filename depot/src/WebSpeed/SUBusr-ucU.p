
/*------------------------------------------------------------------------
    File        : SUBusr-ucU.p
    Purpose     : Updates / Deletes records in the usr_mstr

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Sep 22 07:49:03 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-usr_name LIKE usr_mstr.usr_name NO-UNDO.
DEFINE INPUT PARAMETER i-usr_password LIKE usr_mstr.usr_password NO-UNDO.
DEFINE INPUT PARAMETER i-usr_people_ID LIKE usr_mstr.usr_people_ID NO-UNDO.
DEFINE INPUT PARAMETER i-usr_password_reset LIKE usr_mstr.usr_password_reset NO-UNDO.
DEFINE INPUT PARAMETER i-usr_locked LIKE usr_mstr.usr_locked NO-UNDO.
DEFINE INPUT PARAMETER i-create AS LOGICAL INITIAL YES NO-UNDO.

DEFINE OUTPUT PARAMETER o-successful AS LOGICAL INITIAL NO NO-UNDO.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
IF i-create = YES THEN DO: /* Create */
    CREATE usr_mstr.
    ASSIGN 
        usr_mstr.usr_name = i-usr_name
        usr_mstr.usr_password = ENCODE(i-usr_password)
        usr_mstr.usr_people_ID = i-usr_people_ID
        usr_mstr.usr_password_reset = TODAY
        usr_mstr.usr_locked = i-usr_locked
        usr_mstr.usr_create_date = TODAY 
        usr_mstr.usr_created_by = USERID("Core")
        usr_mstr.usr_modified_date = TODAY 
        usr_mstr.usr_modified_by = USERID("Core")
        usr_mstr.usr_prog_name = SOURCE-PROCEDURE:FILE-NAME
        o-successful = TRUE.
END.
ELSE DO: /* Update */
    FIND usr_mstr WHERE usr_mstr.usr_people_ID = i-usr_people_ID AND usr_mstr.usr_deleted = ? NO-ERROR.
    IF AVAILABLE (usr_mstr) THEN DO:
        ASSIGN 
            usr_mstr.usr_name = IF i-usr_name <> "" THEN i-usr_name ELSE usr_mstr.usr_name
            usr_mstr.usr_password = IF i-usr_password <> "" THEN ENCODE(i-usr_password) ELSE usr_mstr.usr_password
            usr_mstr.usr_password_reset = IF i-usr_password <> "" THEN TODAY ELSE usr_mstr.usr_password_reset
            usr_mstr.usr_locked = IF i-usr_locked <> ? THEN i-usr_locked ELSE usr_mstr.usr_locked
            usr_mstr.usr_modified_date = TODAY 
            usr_mstr.usr_modified_by = USERID("Core")
            usr_mstr.usr_prog_name = SOURCE-PROCEDURE:FILE-NAME
            o-successful = TRUE.
    END.
END.
