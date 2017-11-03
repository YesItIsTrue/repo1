
/*------------------------------------------------------------------------
    File        : SUBusr-ucU.p
    Purpose     : Updates / Deletes records in the grp_mstr

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Sep 22 07:49:03 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-grp_ID LIKE grp_mstr.grp_ID NO-UNDO.
DEFINE INPUT PARAMETER i-grp_type LIKE grp_mstr.grp_type NO-UNDO.
DEFINE INPUT PARAMETER i-grp_desc LIKE grp_mstr.grp_desc NO-UNDO.
DEFINE INPUT PARAMETER i-grp_notes LIKE grp_mstr.grp_notes NO-UNDO.
DEFINE INPUT PARAMETER i-grp_sec_backdoor LIKE grp_mstr.grp_sec_backdoor NO-UNDO.

DEFINE OUTPUT PARAMETER o-successful AS LOGICAL INITIAL NO NO-UNDO.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND grp_mstr WHERE grp_mstr.grp_ID = i-grp_id AND grp_mstr.grp_deleted = ? NO-ERROR.
IF AVAILABLE (grp_mstr) THEN
    ASSIGN
        grp_mstr.grp_ID = i-grp_ID
        grp_mstr.grp_type = i-grp_type
        grp_mstr.grp_desc = i-grp_desc
        grp_mstr.grp_notes = i-grp_notes
        grp_mstr.grp_sec_backdoor = i-grp_sec_backdoor
        grp_mstr.grp_modified_by = USERID("Core")
        grp_mstr.grp_modified_date = TODAY
        grp_mstr.grp_prog_name = THIS-PROCEDURE:FILE-NAME.
ELSE DO:
    CREATE grp_mstr.
    ASSIGN
        grp_mstr.grp_ID = i-grp_ID
        grp_mstr.grp_type = i-grp_type
        grp_mstr.grp_desc = i-grp_desc
        grp_mstr.grp_notes = i-grp_notes
        grp_mstr.grp_sec_backdoor = i-grp_sec_backdoor
        grp_mstr.grp_modified_by = USERID("Core")
        grp_mstr.grp_modified_date = TODAY
        grp_mstr.grp_created_by = USERID("Core")
        grp_mstr.grp_create_date = TODAY
        grp_mstr.grp_prog_name = THIS-PROCEDURE:FILE-NAME.
END.