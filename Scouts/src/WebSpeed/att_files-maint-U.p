DEFINE VARIABLE v-fileid LIKE att_file_id NO-UNDO. 
	DEFINE VARIABLE v-create AS LOGICAL NO-UNDO.
	DEFINE VARIABLE v-update AS LOGICAL NO-UNDO.
	DEFINE VARIABLE v-success AS LOGICAL NO-UNDO.
	
FOR EACH mb_mstr WHERE MB_mstr.MB_BSA_ID <= 199 NO-LOCK:

	    ASSIGN 
	         v-filename = REPLACE(MB_mstr.MB_name," ","_") + ".jpg"
	         v-success  = NO.
	        
    DISPLAY 
         MB_mstr.mb_bsa_id SKIP 
         MB_mstr.MB_name SKIP 
              WITH FRAME a WIDTH 80 side-labels.
              
    UPDATE v-filename SKIP(1)
         WITH FRAME a.    

        
    RUN VALUE(SEARCH("SUBatt-ucU.r"))
	         (0,	             /* file_ID */
	          "MB_mstr",     /* table name */
	          "MB_BSA_ID",   /* field1 */
	          STRING(MB_mstr.mb_bsa_id),     /* value1 */
	          "",            /* field2 */
	          "",            /* value2 */
	          "",            /* field3 */
	          "",            /* value3 */
	          "",            /* field4 */
	          "",            /* value4 */
	          "",            /* field5 */
	          "",            /* value5 */
	          "IMAGE",       /* category */
	          "/depot/src/HTMLContent/images/Scouting", 	     /* filepath */
	          v-filename,    /* filename */
	          "Official Merit Badge Image.",		     /* filedesc */
	          "2017",        /* major version --- should be latest rev year for MB, but since I'm doing this en masse I just put the current info */
	          "Sep",         /* minor version --- should be latest rev month for MB, but since I'm doing this en masse I just put the current info */    
	          OUTPUT v-fileid, 
	          OUTPUT v-create,
	          OUTPUT v-update,
	          OUTPUT v-success
	          ).
	          
	     
	     IF v-success = NO THEN 
	          MESSAGE "Problem creating att_files for the" MB_mstr.MB_name "MB."
	               VIEW-AS ALERT-BOX WARNING BUTTONS OK.      
	     
	END.  /** of 4ea. mb_mstr **/
	     
	/***************************  End of File  *********************************/          
	          