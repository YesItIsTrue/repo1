
/*------------------------------------------------------------------------
    File        : SUBloc-ucU.p

    Description : This is the update/create program for the Location Master table.

    Author(s)   : Trae Luttrell
    Created     : Fri Jul 08 10:13:23 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Input / Output Parameters  ******************** */

DEFINE INPUT PARAMETER i-loc-site LIKE loc_mstr.loc_site NO-UNDO.
DEFINE INPUT PARAMETER i-loc-warehouse LIKE loc_mstr.loc_warehouse NO-UNDO.
DEFINE INPUT PARAMETER i-loc-name LIKE loc_mstr.loc_name NO-UNDO.
DEFINE INPUT PARAMETER i-loc-desc LIKE loc_mstr.loc_desc NO-UNDO.
DEFINE INPUT PARAMETER i-loc-def-status LIKE loc_mstr.loc_def_status NO-UNDO.
DEFINE INPUT PARAMETER i-loc-type LIKE loc_mstr.loc_type NO-UNDO.

DEFINE OUTPUT PARAMETER o-create AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-update AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ***************************  Main Block  *************************** */

FIND loc_mstr WHERE 
    loc_mstr.loc_site = i-loc-site AND 
    loc_mstr.loc_warehouse = i-loc-warehouse AND
    loc_mstr.loc_name = i-loc-name EXCLUSIVE-LOCK NO-ERROR.

IF AVAILABLE (loc_mstr) THEN DO:

    ASSIGN
        o-update = YES
        o-success = YES
        loc_mstr.loc_desc = i-loc-desc
        loc_mstr.loc_def_status = i-loc-def-status
        loc_mstr.loc_type = i-loc-type
        loc_mstr.loc_prog_name = SOURCE-PROCEDURE:FILE-NAME
        loc_mstr.loc_modified_by = USERID("Modules")
        loc_mstr.loc_modified_date = TODAY.

END. /*** of update path ***/

ELSE DO:

    CREATE loc_mstr.

    ASSIGN
        o-create = YES
        o-success = YES
        loc_mstr.loc_site = i-loc-site
        loc_mstr.loc_warehouse = i-loc-warehouse 
        loc_mstr.loc_name = i-loc-name
        loc_mstr.loc_desc = i-loc-desc
        loc_mstr.loc_def_status = i-loc-def-status
        loc_mstr.loc_type = i-loc-type
        loc_mstr.loc_created_by = USERID("Modules")
        loc_mstr.loc_create_date = TODAY
        loc_mstr.loc_prog_name = SOURCE-PROCEDURE:FILE-NAME
        loc_mstr.loc_modified_by = USERID("Modules")
        loc_mstr.loc_modified_date = TODAY.

END. /*** of creation path ***/

/* ***************************  End of Line  **************************** */