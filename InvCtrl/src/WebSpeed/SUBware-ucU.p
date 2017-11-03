
/*------------------------------------------------------------------------
    File        : SUBware-ucU.p

    Description : This is a regular old update/create program for the Warehouse Master table.
        It trusts that you have passed it a valid site and warehouse combination.

    Author(s)   : Trae Luttrell
    Created     : Thu Jul 07 14:38:26 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Input / Output Parameters  ******************** */

DEFINE INPUT PARAMETER i-warehouse-site LIKE warehouse_mstr.warehouse_site NO-UNDO.
DEFINE INPUT PARAMETER i-warehouse-name LIKE warehouse_mstr.warehouse_name NO-UNDO.
DEFINE INPUT PARAMETER i-warehouse-desc LIKE warehouse_mstr.warehouse_desc NO-UNDO.
DEFINE INPUT PARAMETER i-warehouse-def-loc LIKE warehouse_mstr.warehouse_def_loc NO-UNDO.

DEFINE OUTPUT PARAMETER o-create AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-update AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ***************************  Main Block  *************************** */

FIND warehouse_mstr WHERE 
    warehouse_mstr.warehouse_site = i-warehouse-site AND 
    warehouse_mstr.warehouse_name = i-warehouse-name EXCLUSIVE-LOCK NO-ERROR.

IF AVAILABLE (warehouse_mstr) THEN DO:

    ASSIGN
        o-update = YES
        o-success = YES
        warehouse_mstr.warehouse_desc = i-warehouse-desc
        warehouse_mstr.warehouse_def_loc = i-warehouse-def-loc
        warehouse_mstr.warehouse_prog_name = SOURCE-PROCEDURE:FILE-NAME
        warehouse_mstr.warehouse_modified_by = USERID("Modules")
        warehouse_mstr.warehouse_modified_date = TODAY.

END. /*** of update path ***/

ELSE DO:

    CREATE warehouse_mstr.

    ASSIGN
        o-create = YES
        o-success = YES
        warehouse_mstr.warehouse_site = i-warehouse-site 
        warehouse_mstr.warehouse_name = i-warehouse-name
        warehouse_mstr.warehouse_desc = i-warehouse-desc
        warehouse_mstr.warehouse_def_loc = i-warehouse-def-loc
        warehouse_mstr.warehouse_created_by = USERID("Modules")
        warehouse_mstr.warehouse_create_date = TODAY
        warehouse_mstr.warehouse_prog_name = SOURCE-PROCEDURE:FILE-NAME
        warehouse_mstr.warehouse_modified_by = USERID("Modules")
        warehouse_mstr.warehouse_modified_date = TODAY.

END. /*** of creation path ***/

/* ***************************  End of Line  **************************** */
