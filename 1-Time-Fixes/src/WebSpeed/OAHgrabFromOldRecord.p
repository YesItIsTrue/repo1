
/*------------------------------------------------------------------------
    File        : OAHgrabFromOldRecord.p

    Description : This program touches each -OAH record and finds  the correspoinding 
                    non-OAH version of itself and updates any fields that were missed 
                    by the RStP programs. Here is a list of the fields:
                        TK_prof
                        TK_domestic
                        TK_cust_ID
                        TK_cust_paid
                        TK_deleted
                        TK_lbl_print
                        TK_lab_paid
                        TK_lab_ID
                        TK_magento_order
                        TK_cust_paid_date

    Author(s)   : Trae Luttrell
    Created     : Thu Jun 09 19:03:31 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE BUFFER tk_mstr2 FOR TK_mstr. 
DEFINE BUFFER trh_hist2 FOR trh_hist.

DEFINE VARIABLE c-all           AS INTEGER LABEL "Old Records" NO-UNDO.
DEFINE VARIABLE c-OAH-modified  AS INTEGER LABEL "Matched, has -OAH"NO-UNDO.
DEFINE VARIABLE c-no-suffix     AS INTEGER LABEL "Didn't Match" NO-UNDO.
DEFINE VARIABLE c-new-trh-rec   AS INTEGER  NO-UNDO.
DEFINE VARIABLE c-matched-trh   AS INTEGER  NO-UNDO.

DEFINE VARIABLE statlist AS CHARACTER 
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,EMAILED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO.
    
DEFINE VARIABLE datelist AS DATE EXTENT 17 NO-UNDO. 
DEFINE VARIABLE x AS INTEGER NO-UNDO.

DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 11 NO-UNDO.
DEFINE VARIABLE saywhatnowwhatnow AS LOGICAL  NO-UNDO.

DEFINE VARIABLE updatemode AS LOG INITIAL NO NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */

UPDATE updatemode.

FOR EACH TK_mstr2 WHERE 
    (TK_mstr2.TK_ID < "A" OR 
    TK_mstr2.TK_ID BEGINS "CPR" OR 
    TK_mstr2.TK_ID BEGINS "NN") AND 
     SUBSTRING (TK_mstr2.tk_id,MAX((LENGTH(TK_mstr2.tk_id) - 2),1)) <> "OAH" 
     NO-LOCK:

    c-all = c-all + 1.
        
    FIND tk_mstr WHERE 
        tk_mstr.tk_id BEGINS TK_mstr2.TK_ID AND 
         SUBSTRING (TK_mstr.tk_id,MAX((LENGTH(TK_mstr.tk_id) - 2),1)) = "OAH"
        EXCLUSIVE-LOCK NO-ERROR.
    
    IF AVAILABLE (tk_mstr) THEN DO:
        
        c-OAH-modified = c-OAH-modified + 1.
    
        IF updatemode = YES THEN ASSIGN
            TK_mstr.TK_prof             = IF TK_mstr.TK_prof            <> ? THEN TK_mstr.TK_prof ELSE tk_mstr2.tk_prof
            TK_mstr.TK_domestic         = IF TK_mstr.TK_domestic        <> ? THEN TK_mstr.TK_domestic ELSE TK_mstr2.TK_domestic
            TK_mstr.TK_cust_ID          = IF TK_mstr.TK_cust_ID         <> 0 THEN TK_mstr.TK_cust_ID ELSE TK_mstr2.TK_cust_ID
            TK_mstr.TK_cust_paid        = IF TK_mstr.TK_cust_paid       <> ? THEN TK_mstr.TK_cust_paid ELSE TK_mstr2.TK_cust_paid
            TK_mstr.TK_deleted          = IF TK_mstr.TK_deleted         <> ? THEN TK_mstr.TK_deleted ELSE TK_mstr2.TK_deleted
            TK_mstr.TK_lbl_print        = IF TK_mstr.TK_lbl_print       <> ? THEN TK_mstr.TK_lbl_print ELSE TK_mstr2.TK_lbl_print
            TK_mstr.TK_lab_paid         = IF TK_mstr.TK_lab_paid        <> ? THEN TK_mstr.TK_lab_paid ELSE TK_mstr2.TK_lab_paid
            TK_mstr.TK_lab_ID           = IF TK_mstr.TK_lab_ID          <> "" THEN TK_mstr.TK_lab_ID ELSE TK_mstr2.TK_lab_ID
            TK_mstr.TK_magento_order    = IF TK_mstr.TK_magento_order   <> "" THEN TK_mstr.TK_magento_order ELSE TK_mstr2.TK_magento_order
            TK_mstr.TK_cust_paid_date   = IF TK_mstr.TK_cust_paid_date  <> ? THEN TK_mstr.TK_cust_paid_date ELSE TK_mstr2.TK_cust_paid_date
            TK_mstr.TK__char02          = IF TK_mstr.TK__char02         <> "" THEN TK_mstr.TK__char02 ELSE TK_mstr2.tk__char02
            TK_mstr.TK__dec01           = IF TK_mstr.TK__dec01          <> 0 THEN TK_mstr.TK__dec01 ELSE TK_mstr2.tk__dec01
            TK_mstr.TK_modified_by      = USERID ("HHI")
            TK_mstr.TK_modified_date    = TODAY
            TK_mstr.TK_prog_name        = SOURCE-PROCEDURE:FILE-NAME
        . /*** here is the period. Dad. ***/

        DO x = 1 TO 17:
            
            datelist[x] = ?.
            
        END. 

        FOR EACH trh_hist WHERE 
            trh_hist.trh_item = TK_mstr2.tk_test_type AND 
            trh_hist.trh_serial = TK_mstr2.tk_id AND 
            trh_hist.trh_sequence = tk_mstr2.TK_test_seq  
        NO-LOCK:
        
/*            DISPLAY trh_hist.trh_item trh_hist.trh_serial trh_hist.trh_sequence trh_hist.trh_action trh_hist.trh_date SKIP*/
/*            TK_mstr2.tk_ID TK_mstr.TK_test_seq SKIP                                                                       */
/*            TK_mstr.TK_ID TK_mstr2.TK_test_seq WITH FRAME B WITH 2 COL.                                                   */
        
            FIND FIRST trh_hist2 WHERE 
                trh_hist2.trh_item = TK_mstr.TK_test_type /** OAH **/ AND 
                trh_hist2.trh_serial = TK_mstr.tk_id /** OAH **/ AND 
                trh_hist2.trh_sequence = tk_mstr.TK_test_seq /** OAH **/ AND
                trh_hist2.trh_action = trh_hist.trh_action 
/*                AND trh_hist2.trh_date = trh_hist.trh_date*/
            NO-LOCK NO-ERROR.
            
            IF AVAILABLE trh_hist2 THEN DO:
            
                c-matched-trh = c-matched-trh + 1.
            
            END. /*** available matching trh_hist records. ***/
            
            ELSE DO:

                /****** start of the date voodoo *******/
                IF LOOKUP(trh_hist.trh_action, statlist) > 0 THEN 
                    ASSIGN datelist[LOOKUP(trh_hist.trh_action, statlist)] = trh_hist.trh_date.
                
                RUN VALUE(SEARCH("TRHtkStatusU.p"))     /*** this makes a new trh_hist record ***/
                    (datelist, 
                    TK_mstr.tk_id, 
                    TK_mstr.TK_test_seq, 
                    updatemode, 
                    General.trh_hist.trh_comments,                                                 
                    trh_hist.trh_other_ID,                                 
                    General.trh_hist.trh_people_id,                                  
                    General.trh_hist.trh_order,                                 
                    General.trh_hist.trh_date,                                    
                    General.trh_hist.trh_time,                                     
                    General.trh_hist.trh_ref, 
                    OUTPUT saywhatnowwhatnow , 
                    OUTPUT ERROR-count).  

                c-new-trh-rec = c-new-trh-rec + 1.
                
            END. /*** not available trh_hist record w/ the new ID ***/            
            
        END. /*** for each old TRH_hist (non-OAH) ***/

    END. /*** available OAH and paired with non-OAH ***/
        
    ELSE c-no-suffix = c-no-suffix + 1.
    
/*    FIND tk_mstr WHERE                                                        */
/*        tk_mstr.tk_id BEGINS TK_mstr2.TK_ID AND                               */
/*         SUBSTRING (TK_mstr.tk_id,MAX((LENGTH(TK_mstr.tk_id) - 2),1)) <> "OAH"*/
/*        EXCLUSIVE-LOCK NO-ERROR.                                              */
/*                                                                              */
/*    IF AVAILABLE (tk_mstr) THEN DO:                                           */
/*                                                                              */
/*                                                                              */
/*                                                                              */
/*    END.                                                                      */
        
END. /*** 4ea TK_mstr2 looking for old as heck records. ***/     

DISPLAY c-all c-oah-modified c-no-suffix c-matched-trh c-new-trh-rec WITH 2 COL.

/* ***************************  Main Block  *************************** */
