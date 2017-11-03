
/*------------------------------------------------------------------------
    File        : ICmag_importerU.p
    Purpose     : 

    Author(s)   : Trae Luttrell
    Created     : Mon Oct 24 14:52:51 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE c-import AS INTEGER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE TEMP-TABLE QOHcatcher
    FIELD Site AS CHARACTER 
    FIELD Warehouse AS CHARACTER 
    FIELD Loc AS CHARACTER
    FIELD item_sku AS CHARACTER
    FIELD item_name AS CHARACTER
    FIELD qoh AS INTEGER 
    FIELD item_other_id AS CHARACTER
    FIELD item_type AS CHARACTER
        INDEX main-idx AS PRIMARY item_name.
        
/*****  input / output parmeters  *****/
/*DEFINE VARIABLE v-filename      AS CHARACTER INITIAL "C:\Progress\WRK\HHI-inventory-20oct16.csv" NO-UNDO.*/
DEFINE VARIABLE v-filelocation  AS CHARACTER FORMAT "x(60)" INITIAL "C:\Progress\WRK\HHI-inventory-20oct16.csv" NO-UNDO.
DEFINE VARIABLE errlog          AS CHARACTER NO-UNDO. /*** location of the outbound log ***/
DEFINE VARIABLE dwightaddress   AS CHARACTER NO-UNDO. /** location of the dwight log ***/
DEFINE VARIABLE updatemode      AS LOGICAL NO-UNDO. 
DEFINE VARIABLE err-number      AS INTEGER NO-UNDO. /* 0 = didn't run, # = the # of the error, 99 = successfully ran. */

DEFINE VARIABLE o-create AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-update AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-success AS LOGICAL NO-UNDO.
/* ***************************  Main Block  *************************** */

UPDATE v-filelocation.

ASSIGN c-import = 0.

INPUT FROM VALUE (v-filelocation).

    ThisLinefromExcel: 
    REPEAT:
        
        CREATE QOHcatcher.
        
        IMPORT DELIMITER "," QOHcatcher.
        
        IF QOHcatcher.site = "SITE" THEN DO: /****/
    
            DELETE QOHcatcher.
        
            LEAVE ThisLinefromExcel.
         
        END. /** Gets rid of the line of column titles. **/
        
        ELSE DO: /*** this is stuff that happens to every record ***/
                   
            ASSIGN c-import = c-import + 1.
             
        END. /*** ELSE: successful import ***/

    END. /** StraightImport **/
    
INPUT CLOSE. 
 
IF c-import = 0 THEN DO: 

/*    queue-message("apocolypse", html-encode("There were no records entered!")).*/

END. 

site-loop:
FOR EACH QOHcatcher NO-LOCK
    BREAK BY QOHcatcher.site:

    IF FIRST-OF(qohcatcher.site) THEN DO:
    
        FIND FIRST site_mstr WHERE 
            site_mstr.site_name = qohcatcher.site
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF NOT AVAILABLE (site_mstr) THEN DO:
        
            CREATE site_mstr.
            
            ASSIGN 
                site_mstr.site_name = qohcatcher.site
                site_mstr.site_created_by = USERID("Modules")
                site_mstr.site_create_date = TODAY
                site_mstr.site_prog_name = SOURCE-PROCEDURE:FILE-NAME
                site_mstr.site_modified_by = USERID("Modules")
                site_mstr.site_modified_date = TODAY.
            
        END. /*** no site found, make one ***/
        
        ELSE IF AVAILABLE (site_mstr) AND site_mstr.site_deleted <> ? THEN 
            ASSIGN 
                site_mstr.site_deleted = ?
                site_mstr.site_prog_name = SOURCE-PROCEDURE:FILE-NAME
                site_mstr.site_modified_by = USERID("Modules")
                site_mstr.site_modified_date = TODAY.
        
        /* ELSE you are ALL SET. */
        
    END. /*** first site ***/

END. /* for each site */

warehouse-loop:
FOR EACH QOHcatcher NO-LOCK
    BREAK BY QOHcatcher.warehouse:
    
    IF FIRST-OF(qohcatcher.warehouse) THEN DO:
    
        FIND FIRST warehouse_mstr WHERE 
            warehouse_mstr.warehouse_site = qohcatcher.site AND 
            warehouse_mstr.warehouse_name = qohcatcher.warehouse
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF NOT AVAILABLE (warehouse_mstr) THEN DO:
        
            CREATE warehouse_mstr.
            
            ASSIGN 
                warehouse_mstr.warehouse_site = qohcatcher.site
                warehouse_mstr.warehouse_name = qohcatcher.warehouse 
                warehouse_mstr.warehouse_created_by = USERID("Modules")
                warehouse_mstr.warehouse_create_date = TODAY
                warehouse_mstr.warehouse_prog_name = SOURCE-PROCEDURE:FILE-NAME
                warehouse_mstr.warehouse_modified_by = USERID("Modules")
                warehouse_mstr.warehouse_modified_date = TODAY.
            
        END. /*** no warehouse found, make one ***/
        
        ELSE IF AVAILABLE (warehouse_mstr) AND warehouse_mstr.warehouse_deleted <> ? THEN 
            ASSIGN 
                warehouse_mstr.warehouse_deleted = ?
                warehouse_mstr.warehouse_prog_name = SOURCE-PROCEDURE:FILE-NAME
                warehouse_mstr.warehouse_modified_by = USERID("Modules")
                warehouse_mstr.warehouse_modified_date = TODAY.
                
        /* ELSE you are ALL SET. */
        
    END. /*** first warehouse ***/

END. /*** warehouse 4ea ***/

loc-loop:
FOR EACH QOHcatcher NO-LOCK
    BREAK BY QOHcatcher.loc:
    
    IF FIRST-OF(qohcatcher.loc) THEN DO:
    
        FIND FIRST loc_mstr WHERE
            loc_mstr.loc_site = qohcatcher.site AND 
            loc_mstr.loc_warehouse = qohcatcher.warehouse AND  
            loc_mstr.loc_name = qohcatcher.loc
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF NOT AVAILABLE (loc_mstr) THEN DO:
        
            CREATE loc_mstr.
            
            ASSIGN 
                loc_mstr.loc_site = qohcatcher.site
                loc_mstr.loc_warehouse = qohcatcher.warehouse
                loc_mstr.loc_name = qohcatcher.loc
                loc_mstr.loc_created_by = USERID("Modules")
                loc_mstr.loc_create_date = TODAY
                loc_mstr.loc_prog_name = SOURCE-PROCEDURE:FILE-NAME
                loc_mstr.loc_modified_by = USERID("Modules")
                loc_mstr.loc_modified_date = TODAY.
            
        END. /*** no loc found, make one ***/
        
        ELSE IF AVAILABLE (loc_mstr) AND loc_mstr.loc_deleted <> ? THEN 
            ASSIGN 
                loc_mstr.loc_deleted = ?
                loc_mstr.loc_prog_name = SOURCE-PROCEDURE:FILE-NAME
                loc_mstr.loc_modified_by = USERID("Modules")
                loc_mstr.loc_modified_date = TODAY.
                
        /* ELSE you are ALL SET. */
        
    END. /*** first loc ***/

END. /*** loc 4ea ***/

item-loop:
FOR EACH QOHcatcher NO-LOCK
    BREAK BY QOHcatcher.item_name:

    IF FIRST-OF(qohcatcher.item_name) THEN DO:
    
        FIND FIRST item_mstr WHERE 
            item_mstr.item_nbr = qohcatcher.item_sku
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF NOT AVAILABLE (item_mstr) THEN DO:
            
            CREATE item_mstr.
            
            ASSIGN 
                item_mstr.item_nbr = qohcatcher.item_sku
                item_mstr.item_sku_nbr = qohcatcher.item_sku
                item_mstr.item_desc1 = qohcatcher.item_name
                item_mstr.item_other_id = qohcatcher.item_other_id
                item_mstr.item_type = qohcatcher.item_type
                item_mstr.item_created_by = USERID("Modules")
                item_mstr.item_create_date = TODAY
                item_mstr.item_prog_name = SOURCE-PROCEDURE:FILE-NAME
                item_mstr.item_modified_by = USERID("Modules")
                item_mstr.item_modified_date = TODAY.
                
        END. /*** no item, created one ***/
        
        ELSE DO:
        
            IF item_mstr.item_deleted <> ? THEN ASSIGN item_mstr.item_deleted = ? .
                
            ASSIGN 
                item_mstr.item_sku_nbr = qohcatcher.item_sku
                item_mstr.item_other_id = qohcatcher.item_other_id
                item_mstr.item_type = qohcatcher.item_type
                item_mstr.item_prog_name = SOURCE-PROCEDURE:FILE-NAME
                item_mstr.item_modified_by = USERID("Modules")
                item_mstr.item_modified_date = TODAY.
        
        END. /*** Item_mstr available ***/
        
    END. /*** first item ***/

END. /*** 4ea for items ***/

qoh-loop:
FOR EACH QOHcatcher NO-LOCK:
    
    /***** EACH section ******/

    IF qohcatcher.qoh <= 0 THEN NEXT qoh-loop.

/*    IF qohcatcher.loc = "NULL" THEN NEXT qoh-loop.*/

    FIND qoh_det WHERE
        qoh_det.qoh_site = qohcatcher.site AND
        qoh_det.qoh_warehouse = qohcatcher.warehouse AND
        qoh_det.qoh_loc = qohcatcher.loc AND
        qoh_det.qoh_item_nbr = qohcatcher.item_name AND
        qoh_det.qoh_loc = "" AND
        qoh_det.qoh_serial = "" AND
        qoh_det.qoh_deleted = ?
        NO-LOCK NO-ERROR.

    IF AVAILABLE (qoh_det) THEN ASSIGN qohcatcher.qoh = qohcatcher.qoh + qoh_det.qoh_quantity.

    RUN VALUE(SEARCH("SUBqoh-ucU.r"))
        (qohcatcher.site,
        qohcatcher.warehouse,
        qohcatcher.item_name,
        qohcatcher.Loc,
        "", /*lot*/
        "", /*serial*/
        qohcatcher.qoh,
        ?,
        "", /*status*/
        ?, /*expire-date*/
        ?, /*last-count*/
        OUTPUT o-create,
        OUTPUT o-update,
        OUTPUT o-success).

    /***** end of EACH section ****/
     
END. /*** 4ea QOHcatcher ***/


/*                                                        */
/*    IF NOT AVAILABLE (qoh_det) THEN DO:                 */
/*                                                        */
/*        CREATE qoh_det.                                 */
/*                                                        */
/*        ASSIGN                                          */
/*            qoh_det.qoh_site = qohcatcher.site          */
/*            qoh_det.qoh_warehouse = qohcatcher.warehouse*/
/*            qoh_det.qoh_loc = qohcatcher.loc            */
/*            qoh_det.qoh_item_nbr = qohcatcher.item_name */
/*            qoh_det.qoh_loc = ""                        */
/*            qoh_det.qoh_serial = ""                     */
/*            qoh_det.qoh_qty = qohcatcher.qoh            */
/*            qoh_det.qoh_created_by =                    */
/*                                                        */
/*                                                        */
/*    END. /*** of no qoh there. ***/                     */

