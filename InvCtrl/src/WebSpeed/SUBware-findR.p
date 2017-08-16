
/*------------------------------------------------------------------------
    File        : SUBware-findR.p

    Description : The sub-routine for finding in the Warehouse Master table.

    Author(s)   : Trae Luttrell
    Created     : Tue Jul 12 09:03:35 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Input / Output Parameters  ******************** */

DEFINE INPUT PARAMETER i-warehouse-site LIKE warehouse_mstr.warehouse_site NO-UNDO.
DEFINE INPUT PARAMETER i-warehouse-name LIKE warehouse_mstr.warehouse_name NO-UNDO.

DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ***************************  Main Block  *************************** */

FIND warehouse_mstr WHERE 
    i-warehouse-site = warehouse_mstr.warehouse_site AND 
    i-warehouse-name = warehouse_mstr.warehouse_name NO-LOCK NO-ERROR.

IF AVAILABLE (warehouse_mstr) THEN DO:

    ASSIGN o-success = YES.

END. /*** of update path ***/

ELSE DO:

    ASSIGN o-success = NO.
    
END. 
