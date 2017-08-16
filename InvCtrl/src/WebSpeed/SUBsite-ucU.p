
/*------------------------------------------------------------------------
    File        : SUBsite-ucU.p

    Description : This is a regular old update/create program for the Site Master table.

    Author(s)   : Trae Luttrell
    Created     : Thu Jul 07 14:28:34 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Input / Output Parameters  ******************** */

DEFINE INPUT PARAMETER i-site-name LIKE site_mstr.site_name NO-UNDO.
DEFINE INPUT PARAMETER i-addr-id LIKE site_mstr.site_addr_id NO-UNDO.
DEFINE INPUT PARAMETER i-site-desc LIKE site_mstr.site_desc NO-UNDO.
DEFINE INPUT PARAMETER i-def-ware LIKE site_mstr.site_def_ware NO-UNDO. 

DEFINE OUTPUT PARAMETER o-create AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-update AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ***************************  Main Block  *************************** */

FIND site_mstr WHERE site_mstr.site_name = i-site-name EXCLUSIVE-LOCK NO-ERROR.

IF AVAILABLE (site_mstr) THEN DO:

    ASSIGN
        o-update = YES
        o-success = YES
        site_mstr.site_addr_id = i-addr-id
        site_mstr.site_desc = i-site-desc
        site_mstr.site_def_ware = i-def-ware
        site_mstr.site_prog_name = SOURCE-PROCEDURE:FILE-NAME
        site_mstr.site_modified_by = USERID("InvCtrl")
        site_mstr.site_modified_date = TODAY.

END. /*** of update path ***/

ELSE DO:

    CREATE site_mstr.

    ASSIGN
        o-create = YES
        o-success = YES
        site_mstr.site_name = i-site-name
        site_mstr.site_addr_id = i-addr-id
        site_mstr.site_desc = i-site-desc
        site_mstr.site_def_ware = i-def-ware
        site_mstr.site_created_by = USERID("InvCtrl")
        site_mstr.site_create_date = TODAY
        site_mstr.site_prog_name = SOURCE-PROCEDURE:FILE-NAME
        site_mstr.site_modified_by = USERID("InvCtrl")
        site_mstr.site_modified_date = TODAY.

END. /*** of creation path ***/
