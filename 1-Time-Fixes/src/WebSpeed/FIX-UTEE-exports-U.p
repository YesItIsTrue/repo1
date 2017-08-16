/****
 *
 *  Export all the tk_mstr, tkr_det, and trh_hist records related to the duplicates
 *  before deleting them.
 *
 *****/
 
DEFINE VARIABLE updatemode AS LOG INITIAL YES NO-UNDO.

DEFINE STREAM outward.
DEFINE STREAM outdet.
DEFINE STREAM outhist. 

OUTPUT STREAM outward TO "C:\PROGRESS\WRK\exports\multi-test-cleanup.txt" APPEND.
OUTPUT STREAM outdet TO "C:\PROGRESS\WRK\exports\multi-test-cleanup-details.txt" APPEND.
OUTPUT STREAM outhist TO "C:\PROGRESS\WRK\exports\multi-test-cleanup-history.txt" APPEND.

DEFINE BUFFER tkbuff FOR TK_mstr.

FOR EACH TK_mstr WHERE TK_mstr.TK_test_type = "UTEE" AND 
        TK_mstr.TK_test_seq = 1 AND 
        TK_mstr.TK_deleted = ? NO-LOCK:
    
    FOR EACH tkbuff WHERE tkbuff.tk_id = tk_mstr.tk_id AND 
        tkbuff.tk_test_seq <> tk_mstr.tk_test_seq AND 
        tkbuff.tk_test_type = "UTM / UEE":
          
    	    EXPORT STREAM outward DELIMITER ";"
    	         tkbuff.
    	         
    	    FOR EACH TKR_det WHERE TKR_det.TKR_ID = tkbuff.tk_id AND 
    	         TKR_det.TKR_test_seq = tkbuff.tk_test_seq:
    	                  
    	         EXPORT STREAM outdet DELIMITER ";"
    	              TKR_det.
    	              
    	         IF updatemode = YES THEN 
                  DELETE TKR_det.
                  
        END.  /** of 4ea. tkr_det **/
        
        FOR EACH trh_hist WHERE trh_hist.trh_serial = tkbuff.tk_id AND 
        	     trh_hist.trh_sequence = tkbuff.tk_test_seq:
        	         
        	     EXPORT STREAM outhist DELIMITER ";"
        	          trh_hist.
        	          
        	     IF updatemode = YES THEN 
        	          DELETE trh_hist.
        	          
        END.  /** of 4ea. trh_hist **/
        
        IF updatemode = YES THEN 
             DELETE tkbuff.
             
     END.  /** of 4ea. tkbuff **/
     
END.  /*** of 4ea. tk_mstr, etc. ***/

OUTPUT STREAM outward CLOSE.
OUTPUT STREAM outdet CLOSE.
OUTPUT STREAM outhist CLOSE.

/*******  EOF ************/
        