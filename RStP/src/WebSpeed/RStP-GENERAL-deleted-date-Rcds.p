/******************************************************************************
 *
 *  RStP-General-deleted-date-Rcds.p - 30/Sept/15 - Version 1.0
 * 
 * -----------------------------------------------------------------------
 *
 *  Description:
 *  ------------
 *  Removes/deletes all General table records 
 *  where the "*_deleted" field is not equal to ?. 
 *  MUST be run before any of the other RStP programs.
 *
 * -----------------------------------------------------------------------
 *
 *  Revision History:
 *  ----------------- 
 *  1.0 - Original program by Harold Luttrell on 30/Sep/15.
 *
 ******************************************************************************/


/****************************  Variable Definition Section  ************************/

/*****************************    Main Code    *********************/
 
FOR EACH addr_mstr WHERE addr_mstr.addr_deleted <> ? EXCLUSIVE-LOCK:     

    DELETE addr_mstr.

END.  /*** of 4ea. addr_mstr ***/
       
FOR EACH att_files WHERE att_files.att_deleted <> ? EXCLUSIVE-LOCK:

	DELETE att_files.

END.    /** of 4ea. att_files **/									
			

FOR EACH bd_bill_det WHERE bd_bill_det.bd_deleted <> ? EXCLUSIVE-LOCK:

	DELETE bd_bill_det.

END. /** of 4ea. bd_bill_det **/

FOR EACH bm_bill_mstr WHERE bm_bill_mstr.bm_deleted <> ? EXCLUSIVE-LOCK:

	DELETE bm_bill_mstr.

END. /** of 4ea. bm_bill_mstr **/

FOR EACH country_mstr WHERE country_mstr.country_deleted <> ? EXCLUSIVE-LOCK:

	DELETE country_mstr.

END. /** of 4ea. country_mstr **/			  
			
FOR EACH cust_mstr WHERE cust_mstr.cust_deleted <> ? EXCLUSIVE-LOCK:

	DELETE cust_mstr.

		END. /** of 4ea. cust_mstr **/			  

FOR EACH err_message WHERE err_message.err_deleted <> ? EXCLUSIVE-LOCK:

	DELETE err_message.

END.  /*** of 4ea. err_message ***/
    
FOR EACH grp_mstr WHERE  grp_mstr.grp_deleted <> ? EXCLUSIVE-LOCK:

	DELETE grp_mstr.

END. /** of 4ea. grp_mstr **/

FOR EACH menu_mstr WHERE  menu_mstr.menu_deleted <> ? EXCLUSIVE-LOCK:

    DELETE menu_mstr.

END. /** of 4ea. menu_mstr **/

FOR EACH people_mstr WHERE  people_mstr.people_deleted <> ? EXCLUSIVE-LOCK:

    DELETE people_mstr.

END. /** of 4ea. people_mstr **/

FOR EACH state_mstr WHERE  state_mstr.state_deleted <> ? EXCLUSIVE-LOCK:

    DELETE state_mstr.

END. /** of 4ea. state_mstr **/

FOR EACH trh_hist WHERE  trh_hist.trh_deleted <> ? EXCLUSIVE-LOCK:

    DELETE trh_hist.

END. /** of 4ea. trh_hist **/
 
/*****************************  End of FIle.  *******************************/
