
/*------------------------------------------------------------------------
    File        : SUBitem-ucU.p

    Description : This is the update/create program for the Item Master table.

    Author(s)   : Trae Luttrell
    Created     : Fri Jul 08 10:15:16 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Input / Output Parameters  ******************** */

DEFINE INPUT PARAMETER i-item-nbr LIKE item_mstr.item_nbr NO-UNDO.
DEFINE INPUT PARAMETER i-item-desc1 LIKE item_mstr.item_desc1 NO-UNDO.
DEFINE INPUT PARAMETER i-item-desc2 LIKE item_mstr.item_desc2 NO-UNDO.
DEFINE INPUT PARAMETER i-item-code LIKE item_mstr.item_code NO-UNDO.
DEFINE INPUT PARAMETER i-item-group LIKE item_mstr.item_group NO-UNDO.
DEFINE INPUT PARAMETER i-item-prod-line LIKE item_mstr.item_prod_line NO-UNDO.
DEFINE INPUT PARAMETER i-item-status LIKE item_mstr.item_status NO-UNDO.
DEFINE INPUT PARAMETER i-item-req-loc-type LIKE item_mstr.item_req_loc_type NO-UNDO.
DEFINE INPUT PARAMETER i-item-upc-code LIKE item_mstr.item_upc_code NO-UNDO.
DEFINE INPUT PARAMETER i-item-shelf-life LIKE item_mstr.item_shelf_life NO-UNDO.
DEFINE INPUT PARAMETER i-item-dea-ctrl LIKE item_mstr.item_dea_ctrl NO-UNDO.
DEFINE INPUT PARAMETER i-item-fda-ctrl LIKE item_mstr.item_fda_ctrl NO-UNDO.
DEFINE INPUT PARAMETER i-item-length LIKE item_mstr.item_length NO-UNDO.
DEFINE INPUT PARAMETER i-item-length-uom LIKE item_mstr.item_length_uom NO-UNDO.
DEFINE INPUT PARAMETER i-item-height LIKE item_mstr.item_height NO-UNDO.
DEFINE INPUT PARAMETER i-item-height-uom LIKE item_mstr.item_height_uom NO-UNDO.
DEFINE INPUT PARAMETER i-item-width LIKE item_mstr.item_width NO-UNDO.
DEFINE INPUT PARAMETER i-item-width-uom LIKE item_mstr.item_width_uom NO-UNDO.
DEFINE INPUT PARAMETER i-item-weight LIKE item_mstr.item_weight NO-UNDO.
DEFINE INPUT PARAMETER i-item-weight-uom LIKE item_mstr.item_weight_uom NO-UNDO.
DEFINE INPUT PARAMETER i-item-abc-class LIKE item_mstr.item_abc_class NO-UNDO.
DEFINE INPUT PARAMETER i-item-abc-val-tol-over LIKE item_mstr.item_abc_val_tol_over NO-UNDO.
DEFINE INPUT PARAMETER i-item-abc-qty-tol-over LIKE item_mstr.item_abc_qty_tol_over NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-cons-uom LIKE item_mstr.item_def_cons_uom NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-cons-qty LIKE item_mstr.item_def_cons_qty NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-purch-uom LIKE item_mstr.item_def_purch_uom NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-purch-qty LIKE item_mstr.item_def_purch_qty NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-sale-uom LIKE item_mstr.item_def_sale_uom NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-sale-qty LIKE item_mstr.item_def_sale_qty NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-store-uom LIKE item_mstr.item_def_store_uom NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-store-qty LIKE item_mstr.item_def_store_qty NO-UNDO.
DEFINE INPUT PARAMETER i-item-cycle-interval LIKE item_mstr.item_cycle_interval NO-UNDO.
DEFINE INPUT PARAMETER i-item-cycle-date LIKE item_mstr.item_cycle_date NO-UNDO.
DEFINE INPUT PARAMETER i-item-min-QOH LIKE item_mstr.item_min_QOH NO-UNDO.
DEFINE INPUT PARAMETER i-item-max-QOH LIKE item_mstr.item_max_QOH NO-UNDO.
DEFINE INPUT PARAMETER i-item-order-mult LIKE item_mstr.item_order_mult NO-UNDO.
DEFINE INPUT PARAMETER i-item-min-order-qty LIKE item_mstr.item_min_order_qty NO-UNDO.
DEFINE INPUT PARAMETER i-item-def-reorder LIKE item_mstr.item_def_reorder NO-UNDO.
DEFINE INPUT PARAMETER i-item-min-max LIKE item_mstr.item_min_max NO-UNDO.
DEFINE INPUT PARAMETER i-item-other-id LIKE item_mstr.item_other_id NO-UNDO.
DEFINE INPUT PARAMETER i-item-type LIKE item_mstr.item_type NO-UNDO.
DEFINE INPUT PARAMETER i-item-sku-nbr LIKE item_mstr.item_sku_nbr NO-UNDO.

DEFINE OUTPUT PARAMETER o-create AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-update AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO. 

/* ***************************  Main Bitemk  *************************** */

FIND item_mstr WHERE 
    item_mstr.item_nbr = i-item-nbr EXCLUSIVE-LOCK NO-ERROR.

IF AVAILABLE (item_mstr) THEN DO:

    ASSIGN
        o-update = YES
        o-success = YES
        item_mstr.item_desc1 = i-item-desc1 
        item_mstr.item_desc2 = i-item-desc2 
        item_mstr.item_code = i-item-code 
        item_mstr.item_group = i-item-group 
        item_mstr.item_prod_line = i-item-prod-line 
        item_mstr.item_status = i-item-status 
        item_mstr.item_req_loc_type = i-item-req-loc-type 
        item_mstr.item_upc_code = i-item-upc-code 
        item_mstr.item_shelf_life = i-item-shelf-life 
        item_mstr.item_dea_ctrl = i-item-dea-ctrl 
        item_mstr.item_fda_ctrl = i-item-fda-ctrl 
        item_mstr.item_length = i-item-length 
        item_mstr.item_length_uom = i-item-length-uom 
        item_mstr.item_height = i-item-height 
        item_mstr.item_height_uom = i-item-height-uom 
        item_mstr.item_width = i-item-width 
        item_mstr.item_width_uom = i-item-width-uom 
        item_mstr.item_weight = i-item-weight 
        item_mstr.item_weight_uom = i-item-weight-uom 
        item_mstr.item_abc_class = i-item-abc-class 
        item_mstr.item_abc_val_tol_over = i-item-abc-val-tol-over 
        item_mstr.item_abc_qty_tol_over = i-item-abc-qty-tol-over 
        item_mstr.item_def_cons_uom = i-item-def-cons-uom 
        item_mstr.item_def_cons_qty = i-item-def-cons-qty 
        item_mstr.item_def_purch_uom = i-item-def-purch-uom 
        item_mstr.item_def_purch_qty = i-item-def-purch-qty 
        item_mstr.item_def_sale_uom = i-item-def-sale-uom 
        item_mstr.item_def_sale_qty = i-item-def-sale-qty 
        item_mstr.item_def_store_uom = i-item-def-store-uom 
        item_mstr.item_def_store_qty = i-item-def-store-qty 
        item_mstr.item_cycle_interval = i-item-cycle-interval 
        item_mstr.item_cycle_date = i-item-cycle-date 
        item_mstr.item_min_QOH = i-item-min-QOH 
        item_mstr.item_max_QOH = i-item-max-QOH 
        item_mstr.item_order_mult = i-item-order-mult 
        item_mstr.item_min_order_qty = i-item-min-order-qty 
        item_mstr.item_def_reorder = i-item-def-reorder
        item_mstr.item_min_max = i-item-min-max
        item_mstr.item_other_id = i-item-other-id
        item_mstr.item_type = i-item-type
        item_mstr.item_sku_nbr = i-item-sku-nbr
        item_mstr.item_prog_name = SOURCE-PROCEDURE:FILE-NAME
        item_mstr.item_modified_by = USERID("InvCtrl")
        item_mstr.item_modified_date = TODAY.

END. /*** of update path ***/

ELSE DO:

    CREATE item_mstr.

    ASSIGN
        o-create = YES
        o-success = YES
        item_mstr.item_nbr = i-item-nbr
        item_mstr.item_desc1 = i-item-desc1 
        item_mstr.item_desc2 = i-item-desc2 
        item_mstr.item_code = i-item-code 
        item_mstr.item_group = i-item-group 
        item_mstr.item_prod_line = i-item-prod-line 
        item_mstr.item_status = i-item-status 
        item_mstr.item_req_loc_type = i-item-req-loc-type 
        item_mstr.item_upc_code = i-item-upc-code 
        item_mstr.item_shelf_life = i-item-shelf-life 
        item_mstr.item_dea_ctrl = i-item-dea-ctrl 
        item_mstr.item_fda_ctrl = i-item-fda-ctrl 
        item_mstr.item_length = i-item-length 
        item_mstr.item_length_uom = i-item-length-uom 
        item_mstr.item_height = i-item-height 
        item_mstr.item_height_uom = i-item-height-uom 
        item_mstr.item_width = i-item-width 
        item_mstr.item_width_uom = i-item-width-uom 
        item_mstr.item_weight = i-item-weight 
        item_mstr.item_weight_uom = i-item-weight-uom 
        item_mstr.item_abc_class = i-item-abc-class 
        item_mstr.item_abc_val_tol_over = i-item-abc-val-tol-over 
        item_mstr.item_abc_qty_tol_over = i-item-abc-qty-tol-over 
        item_mstr.item_def_cons_uom = i-item-def-cons-uom 
        item_mstr.item_def_cons_qty = i-item-def-cons-qty 
        item_mstr.item_def_purch_uom = i-item-def-purch-uom 
        item_mstr.item_def_purch_qty = i-item-def-purch-qty 
        item_mstr.item_def_sale_uom = i-item-def-sale-uom 
        item_mstr.item_def_sale_qty = i-item-def-sale-qty 
        item_mstr.item_def_store_uom = i-item-def-store-uom 
        item_mstr.item_def_store_qty = i-item-def-store-qty 
        item_mstr.item_cycle_interval = i-item-cycle-interval 
        item_mstr.item_cycle_date = i-item-cycle-date 
        item_mstr.item_min_QOH = i-item-min-QOH 
        item_mstr.item_max_QOH = i-item-max-QOH 
        item_mstr.item_order_mult = i-item-order-mult 
        item_mstr.item_min_order_qty = i-item-min-order-qty 
        item_mstr.item_def_reorder = i-item-def-reorder
        item_mstr.item_min_max = i-item-min-max
        item_mstr.item_other_id = i-item-other-id
        item_mstr.item_type = i-item-type
        item_mstr.item_sku_nbr = i-item-sku-nbr
        item_mstr.item_created_by = USERID("InvCtrl")
        item_mstr.item_create_date = TODAY
        item_mstr.item_prog_name = SOURCE-PROCEDURE:FILE-NAME
        item_mstr.item_modified_by = USERID("InvCtrl")
        item_mstr.item_modified_date = TODAY.

END. /*** of creation path ***/

/* ***************************  End of Line  **************************** */