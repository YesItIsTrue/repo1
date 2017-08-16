/** SCRATCHPAD-144 **/
/** UTIL-genderfix-U.p **/

DEFINE VARIABLE updatemode AS LOG INITIAL NO.
DEFINE VARIABLE x AS INTEGER NO-UNDO.

UPDATE skip(1)
	     updatemode COLON 20 skip(1)
	          WITH FRAME inward WIDTH 80 SIDE-LABELS.
	
	PAUSE 0 BEFORE-HIDE.
	          
FOR EACH people_mstr:
    
    FIND patient_rcd WHERE patientid = people_id NO-LOCK NO-ERROR.
    
    IF AVAILABLE (patient_rcd) THEN DO: 
    
    	     IF (PATIENT_RCD.PatGender = "MALE" AND people_mstr.people_gender <> YES) OR 
    	        (PATIENT_RCD.PatGender = "FEMALE" AND people_mstr.people_gender <> NO) OR 
    	        (PATIENT_RCD.PatGender = "" AND people_mstr.people_gender <> ?) THEN DO: 
    	            
    	     	     DISPLAY people_id people_lastname people_firstname people_dob FORMAT "99/99/9999" people_gender PATIENT_RCD.PatGender.
    	     	     
    	     	     x = x + 1.
    	     	     	
    		          IF updatemode = YES THEN 
    	               ASSIGN 
    	                    people_mstr.people_gender = IF PATIENT_RCD.PatGender = "MALE" THEN YES 
    	          	                                      ELSE IF PATIENT_RCD.PatGender = "FEMALE" THEN NO
    	          	                                      ELSE ?
    	          	          people_mstr.people_prog_name = THIS-PROCEDURE:FILE-NAME.

         END.  /** of if genders different **/
    	
    	END.  /** of if avail patient_rcd **/
    	
    	ELSE DO:  /** of not avail patient_rcd **/
    	          	                
         FIND scust_shadow WHERE scust_shadow.scust_ID = people_mstr.people_id NO-LOCK NO-ERROR.
    
         IF AVAILABLE (scust_shadow) THEN DO: 
        	
        	     FIND FIRST MAG_CUST_RCD WHERE MAG_CUST_RCD.magento-id = int(scust_shadow.scust_magento_ID) NO-LOCK NO-ERROR.
        	
        	     IF AVAILABLE (MAG_CUST_RCD) THEN DO: 
        
                  IF MAG_CUST_RCD.gender <> people_mstr.people_gender THEN DO: 
                 
                       DISPLAY people_id people_lastname people_firstname people_dob people_gender MAG_CUST_RCD.gender @ PATIENT_RCD.PatGender "**".		

    	     	              x = x + 1.
    	     	             		
        		               IF updatemode = YES THEN 
        		     	               ASSIGN
        		     	                    people_mstr.people_gender = IF MAG_CUST_RCD.gender = YES THEN YES 
        		                                                     ELSE IF MAG_CUST_RCD.gender = NO THEN NO 
        		                                                     ELSE ?
        		                         people_mstr.people_prog_name = THIS-PROCEDURE:FILE-NAME.
        
                  END.  /** of genders different 2 **/		
             
             		END.  /** of if avail mag_cust_rcd **/
        		                                 
         END.  /** of if avail scust_shadow **/
    
    END.  /** of else do -- not avail patient_rcd **/    
     
END.  /** of 4ea. people_mstr **/

DISPLAY x.

/*** EOF ***/
    
        	