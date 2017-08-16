DEFINE VARIABLE  o-uccust-id             LIKE cust_mstr.cust_id  NO-UNDO.
DEFINE VARIABLE  o-uccust-create         AS LOGICAL INITIAL NO   NO-UNDO.
DEFINE VARIABLE  o-uccust-update         AS LOGICAL INITIAL NO   NO-UNDO.
DEFINE VARIABLE  o-uccust-error          AS LOGICAL INITIAL NO   NO-UNDO.
DEFINE VARIABLE  o-uccust-successful     AS LOGICAL INITIAL NO   NO-UNDO.

DEFINE VARIABLE  o-ucscust-id            LIKE scust_shadow.scust_id  NO-UNDO.
DEFINE VARIABLE  o-ucscust-create        AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE VARIABLE  o-ucscust-update        AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE VARIABLE  o-ucscust-error         AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE VARIABLE  o-ucscust-successful    AS LOGICAL INITIAL NO       NO-UNDO.


FOR EACH patient_mstr WHERE patient_cust_id <> 0 AND 
     CAN-FIND(people_mstr WHERE people_id = patient_cust_id no-lock) AND 
     NOT CAN-FIND(cust_mstr WHERE cust_id = patient_cust_id NO-LOCK) NO-LOCK: 
         
     RUN VALUE(SEARCH("SUBcust-ucU.r"))
     	     (patient_cust_id, 
     	      "",
     	      0,
     	      "",
     	      0,
     	      0,
     	      OUTPUT o-uccust-id,
     	      OUTPUT o-uccust-create,
     	      OUTPUT o-uccust-update,
     	      OUTPUT o-uccust-error,
     	      OUTPUT o-uccust-successful).
     	      
     	IF o-uccust-id <> 0 AND o-uccust-successful = YES THEN DO: 
     	    
     	    IF NOT CAN-FIND(scust_shadow WHERE scust_id = patient_cust_id NO-LOCK) THEN DO: 
     	        
     	        RUN VALUE(SEARCH("SUBscust-ucU.r"))
     	             (patient_cust_id,
     	              "",
     	              ?,
     	              0,
     	              OUTPUT o-ucscust-id,
     	              OUTPUT o-ucscust-create,
     	              OUTPUT o-ucscust-update,
     	              OUTPUT o-ucscust-error,
     	              OUTPUT o-ucscust-successful).
     	              
     	    END.  /** of if not can-find scust_shadow **/
     	    
     END.  /*** of if cust_mstr create was successful ***/
     
END.  /** of 4ea. patient_mstr, etc. **/

/*************************  End of File.  *****************************/
     
     	        		     