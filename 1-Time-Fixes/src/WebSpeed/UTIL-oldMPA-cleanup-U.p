DEFINE BUFFER tkbuff FOR TK_mstr. 
DEFINE VARIABLE o-trh_id LIKE trh_hist.trh_ID NO-UNDO.
DEFINE VARIABLE o-success AS LOG NO-UNDO.

DEFINE VARIABLE updatemode AS LOG INITIAL NO NO-UNDO.

UPDATE updatemode WITH FRAME a.

PAUSE 0 BEFORE-HIDE.

FOR EACH TK_mstr,
    FIRST test_mstr WHERE test_mstr.test_type = TK_mstr.tk_test_type AND 
        test_mstr.test_family = "BioMed" NO-LOCK,
    FIRST TKR_det WHERE TKR_det.TKR_ID = TK_mstr.TK_ID AND 
        TKR_det.TKR_test_seq = TK_mstr.TK_test_seq AND 
        TKR_det.TKR_item BEGINS "RS",
    FIRST tkbuff WHERE tkbuff.tk_id = TK_mstr.TK_ID AND 
        tkbuff.tk_create_date = 02/08/16
    BREAK BY TK_mstr.tk_id BY TK_mstr.tk_test_seq:
    
    DISPLAY TK_mstr.tk_id (COUNT) TK_mstr.tk_test_seq 
        TK_mstr.tk_test_type TK_mstr.tk_cust_id 
        TK_mstr.tk_create_date TK_mstr.TK_test_age SKIP
        tkbuff.tk_id tkbuff.tk_test_seq
        tkbuff.tk_test_type tkbuff.tk_cust_id
        tkbuff.tk_create_date tkbuff.tk_test_age SKIP(1)
        TK_mstr.TK_status TK_mstr.TK_lbl_print TK_mstr.TK_lab_ID TK_mstr.TK_lab_paid TK_mstr.TK_lab_sample_ID SKIP
        tkbuff.tk_status tkbuff.tk_lbl_print tkbuff.tk_lab_id tkbuff.tk_lab_paid tkbuff.tk_lab_sample_id SKIP(1)
            WITH FRAME b.
	     		     
    IF updatemode = YES THEN DO: 
     
        ASSIGN 
            tkbuff.tk_cust_id	 = IF tkbuff.tk_cust_id = 0 THEN TK_mstr.TK_cust_ID ELSE tkbuff.tk_cust_id
            tkbuff.TK_create_date = TK_mstr.tk_create_date
            tkbuff.tk_test_age = IF tkbuff.tk_test_age = 0 THEN TK_mstr.TK_test_age ELSE tkbuff.tk_test_age
            tkbuff.tk_lab_paid = IF tkbuff.tk_lab_paid = ? THEN TK_mstr.TK_lab_paid ELSE tkbuff.tk_lab_paid 
            tkbuff.TK_lbl_print = ?
            TK_mstr.TK_deleted = TODAY.
     
        FOR EACH trh_hist WHERE trh_hist.trh_serial = TK_mstr.TK_ID AND 
            trh_hist.trh_sequence = TK_mstr.TK_test_seq AND 
            trh_hist.trh_ID < 200000: 
              
            RUN VALUE (SEARCH ("SUBtrh-RStP-findR.r"))
                (tkbuff.tk_test_type, 
                trh_hist.trh_action, 
                trh_hist.trh_serial, 
                tkbuff.tk_test_seq, 
                trh_hist.trh_modified_date,
                OUTPUT o-trh_id,
                OUTPUT o-success).
 
            IF o-trh_id = 0 THEN DO: 
 	         
                RUN VALUE (SEARCH ("SUBtrh-RStP-ucU.r"))
 	         	     (0,
 	         	      tkbuff.tk_test_type,
 	         	      trh_hist.trh_action,
 	         	      trh_hist.trh_qty,
 	         	      trh_hist.trh_loc, 
 	         	      trh_hist.trh_lot, 
 	         	      trh_hist.trh_serial, 
 	         	      trh_hist.trh_site,
 	         	      tkbuff.tk_test_seq,
 	         	      trh_hist.trh_modified_date,
 	         	      OUTPUT o-trh_id, 
 	         	      OUTPUT o-success).
 	         
            END.  /** of if o-trh_id = 0 **/
 
        END.  /*** of 4ea. trh_hist ***/    
     
    END.  /** of if updatemode = yes **/
     
END.  /** of 4ea. tk_mstr, etc. **/		     
     
IF updatemode = YES THEN DO: 
         
    FOR EACH TK_mstr WHERE TK_mstr.TK_deleted = TODAY,
        EACH TKR_det WHERE TKR_det.tkr_id = TK_mstr.tk_id AND 
            TKR_det.tkr_test_seq = TK_mstr.tk_test_seq:     
     
        TKR_det.tkr_deleted = TODAY.
          
        FOR EACH trh_hist WHERE trh_hist.trh_serial = TK_mstr.tk_id AND 
            trh_hist.trh_sequence = TK_mstr.tk_test_seq AND 
            trh_hist.trh_deleted = ?:
                   
            trh_hist.trh_deleted = TODAY.
               
        END.  /** of 4ea. trh_hist **/ 
 		
    END.  /** of 4ea. tk_mstr **/
     
END.  /** of if updatemode = yes **/


/***************************  END OF FILE  ***************************/