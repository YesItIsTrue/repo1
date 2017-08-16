/*------------------------------------------------------------------------
    File        : HHItrh_importerU.p

    Author(s)   : Trae Luttrell
    Created     : Tue Nov 01 14:39:56 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE TEMP-TABLE catcher
    FIELD mag_nbr AS CHARACTER 
    FIELD qty_ordered AS DECIMAL  
    FIELD order_nbr AS CHARACTER
    FIELD cust_id AS INTEGER
    FIELD date_block AS DATETIME  
    FIELD loc AS CHARACTER
    FIELD shipped_by AS CHARACTER
        INDEX main-idx AS PRIMARY mag_nbr.
        
/*****  input / output parmeters  *****/
/*DEFINE VARIABLE v-filename      AS CHARACTER INITIAL "C:\Progress\WRK\HHI-inventory-20oct16.csv" NO-UNDO.*/
DEFINE VARIABLE v-filelocation  AS CHARACTER FORMAT "x(60)" INITIAL "C:\Progress\WRK\HHI-order-item-history.csv" NO-UNDO.
DEFINE VARIABLE updatemode AS LOGICAL INITIAL YES NO-UNDO.
DEFINE VARIABLE v-item_nbr LIKE item_mstr.item_nbr NO-UNDO.
DEFINE VARIABLE v-date AS DATE NO-UNDO.
DEFINE VARIABLE v-time AS CHARACTER NO-UNDO.
DEFINE VARIABLE c-progress AS INTEGER NO-UNDO.
DEFINE VARIABLE c-import AS INTEGER NO-UNDO.

DEFINE VARIABLE o-create AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-update AS LOGICAL NO-UNDO.
DEFINE VARIABLE o-success AS LOGICAL NO-UNDO.
/* ***************************  Main Block  *************************** */

UPDATE v-filelocation updatemode WITH 2 COL FRAME a.

ASSIGN c-import = 0.

INPUT FROM VALUE (v-filelocation).

    ThisLinefromExcel: 
    REPEAT:
        
        CREATE catcher.
        
        IMPORT DELIMITER "," catcher.
      
        ASSIGN c-import = c-import + 1.

    END. /** StraightImport **/
    
INPUT CLOSE. 
 
IF c-import = 0 THEN DO: 

/*    queue-message("apocolypse", html-encode("There were no records entered!")).*/

END. 

FOR EACH catcher NO-LOCK:

    FIND FIRST item_mstr WHERE 
        item_mstr.item_other_id = catcher.mag_nbr 
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE (item_mstr) THEN DO:
        
        IF updatemode = YES THEN DO:
        
            CREATE trh_hist.
            
            ASSIGN 
                trh_hist.trh_ID             = NEXT-VALUE (seq-trh)
                trh_hist.trh_item           = item_mstr.item_nbr 
                trh_hist.trh_action         = "PO-RCPT"
                trh_hist.trh_qty            = catcher.qty_ordered
                trh_hist.trh_loc            = catcher.loc
                trh_hist.trh_site           = "279 Walkers Mills"
                trh_hist.trh_prog_name      = SOURCE-PROCEDURE:FILE-NAME
                trh_hist.trh_date           = catcher.date_block
                trh_hist.trh_people_id      = catcher.cust_id
                trh_hist.trh_order          = catcher.order_nbr
                trh_hist.trh_other_ID       = catcher.mag_nbr
                trh_hist.trh_create_date    = TODAY
                trh_hist.trh_created_by     = catcher.shipped_by
                trh_hist.trh_modified_date  = TODAY
                trh_hist.trh_modified_by    = catcher.shipped_by.                
       
        END. /** of updatemode ***/
        
        c-progress = c-progress + 1.
        
    END. /*** available item_mstr ***/
    
    
    
END. /*** trh-hist loop ***/

DISPLAY c-import c-progress WITH 2 COL FRAME b.
