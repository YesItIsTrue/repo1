
/*------------------------------------------------------------------------
    File        : SUBqoh-ucU.p

    locription : This is the update/create program for this Quantity on Hand Detailed table.

    Author(s)   : Trae Luttrell
    Created     : Fri Jul 08 10:16:11 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Input / Output Parameters  ******************** */

DEFINE INPUT PARAMETER i-qoh-site LIKE qoh_det.qoh_site NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-warehouse LIKE qoh_det.qoh_warehouse NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-item-nbr LIKE qoh_det.qoh_item_nbr NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-loc LIKE qoh_det.qoh_loc NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-lot LIKE qoh_det.qoh_lot NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-serial LIKE qoh_det.qoh_serial NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-quantity LIKE qoh_det.qoh_quantity NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-avail LIKE qoh_det.qoh_avail NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-status LIKE qoh_det.qoh_status NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-expire-date LIKE qoh_det.qoh_expire_date NO-UNDO.
DEFINE INPUT PARAMETER i-qoh-last-count LIKE qoh_det.qoh_last_count NO-UNDO.

DEFINE OUTPUT PARAMETER o-create AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-update AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ***************************  Main Bqohk  *************************** */

IF i-qoh-avail = ? AND i-qoh-quantity <> 0 THEN ASSIGN i-qoh-avail = YES.

IF i-qoh-avail = ? AND i-qoh-quantity = 0 THEN ASSIGN i-qoh-avail = NO.

FIND qoh_det WHERE
    /*** switch these! ***/ 
    i-qoh-site = qoh_det.qoh_site AND 
    i-qoh-warehouse = qoh_det.qoh_warehouse AND
    i-qoh-loc = qoh_det.qoh_loc AND 
    i-qoh-item-nbr = qoh_det.qoh_item_nbr AND 
    i-qoh-lot = qoh_det.qoh_lot AND 
    i-qoh-serial = qoh_det.qoh_serial EXCLUSIVE-LOCK NO-ERROR.

IF AVAILABLE (qoh_det) THEN DO:

/*    IF i-qoh-last-count = ? AND qoh_det.qoh_last_count = ? THEN ASSIGN i-qoh-last-count = qoh_det.qoh_create_date.*/

    ASSIGN
        o-update = YES
        o-success = YES
        qoh_det.qoh_quantity = i-qoh-quantity
        qoh_det.qoh_avail = i-qoh-avail
        qoh_det.qoh_status = i-qoh-status
        qoh_det.qoh_expire_date = i-qoh-expire-date
        qoh_det.qoh_last_count = i-qoh-last-count
        qoh_det.qoh_prog_name = SOURCE-PROCEDURE:FILE-NAME
        qoh_det.qoh_modified_by = USERID("Modules")
        qoh_det.qoh_modified_date = TODAY.
        
END. /*** of update path ***/

ELSE DO:

    CREATE qoh_det.

    IF i-qoh-last-count = ? THEN ASSIGN i-qoh-last-count = TODAY. 

    ASSIGN
        o-create = YES
        o-success = YES
        qoh_det.qoh_site = i-qoh-site
        qoh_det.qoh_warehouse = i-qoh-warehouse 
        qoh_det.qoh_item_nbr = i-qoh-item-nbr
        qoh_det.qoh_loc = i-qoh-loc
        qoh_det.qoh_lot = i-qoh-lot
        qoh_det.qoh_serial = i-qoh-serial
        qoh_det.qoh_quantity = i-qoh-quantity
        qoh_det.qoh_avail = i-qoh-avail
        qoh_det.qoh_status = i-qoh-status
        qoh_det.qoh_expire_date = i-qoh-expire-date
        qoh_det.qoh_last_count = i-qoh-last-count
        qoh_det.qoh_created_by = USERID("Modules")
        qoh_det.qoh_create_date = TODAY
        qoh_det.qoh_prog_name = SOURCE-PROCEDURE:FILE-NAME
        qoh_det.qoh_modified_by = USERID("Modules")
        qoh_det.qoh_modified_date = TODAY.

END. /*** of creation path ***/

/* ***************************  End of Line  **************************** */