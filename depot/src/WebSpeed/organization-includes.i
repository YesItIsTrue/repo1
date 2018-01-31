
/*------------------------------------------------------------------------
    File        : global-css.i
    Purpose     : Reduce code by having one include file handle all global css links and scripts

    Syntax      :

    Description : Include for all Global Styles

    Author(s)   : Andrew Garver
    Created     : Thu Jan 25 09:39:28 EST 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE VARIABLE i-org-people-id AS INTEGER NO-UNDO.
DEFINE VARIABLE i-org-organization-id AS INTEGER NO-UNDO.
    
RUN VALUE(SEARCH("session-get-user-id.r")) (
    get-cookie("c-session-token"),
    OUTPUT i-org-people-id
).

FIND FIRST plink_mstr WHERE plink_mstr.plink_people_ID = i-org-people-id AND plink_rel_type = "employer" NO-ERROR.
IF AVAILABLE (plink_mstr) THEN DO:
    i-org-organization-id = plink_mstr.plink_rel_ID.
END.

FOR EACH att_files WHERE att_files.att_category = "organization-include" AND att_files.att_value1 = STRING(i-org-organization-id) 
AND att_files.att_value2 = "" NO-LOCK:
    {&OUT}
        att_files.att_value5.
END.