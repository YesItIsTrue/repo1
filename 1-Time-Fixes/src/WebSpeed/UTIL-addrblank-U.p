
/*------------------------------------------------------------------------
    File        : UTIL-addrblank-U.p
    Purpose     : 

    Syntax      :

    Description : Blanks out addresses that were erroneously tied to patients.

    Author(s)   : Doug Luttrell
    Created     : Thu Mar 03 22:04:32 EST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */

DEFINE VARIABLE x AS INTEGER NO-UNDO.

/* ***************************  Main Block  *************************** */
FOR EACH PATIENT_RCD WHERE (PATIENT_RCD.PatAddress1 + 
        PATIENT_RCD.PatCity +
        PATIENT_RCD.PatProvidence + 
        PATIENT_RCD.PatStatePostalAbbrev) = "" NO-LOCK,
    FIRST people_mstr WHERE people_mstr.people_id = INTEGER (PATIENT_RCD.PatientID) AND 
        people_mstr.people_addr_id <> 0,
    FIRST addr_mstr WHERE addr_mstr.addr_id = people_mstr.people_addr_id NO-LOCK, 
    FIRST scust_shadow WHERE scust_shadow.scust_ID = people_mstr.people_id AND 
        scust_shadow.scust_magento_id <> "" NO-LOCK, 
    FIRST MAG_CUST_RCD WHERE MAG_CUST_RCD.magento-id = integer(scust_shadow.scust_magento_id) NO-LOCK:

    x = x + 1.
    
    /**    
    DISPLAY people_mstr.people_id SKIP 
        people_mstr.people_lastname SKIP 
        people_mstr.people_firstname SKIP 
        people_mstr.people_DOB SKIP 
        people_mstr.people_addr_id SKIP(1)
        
        addr_mstr.addr_addr1 SKIP 
        addr_mstr.addr_city SKIP 
        addr_mstr.addr_stateprov SKIP 
        addr_mstr.addr_zip SKIP(1)
        
        PATIENT_RCD.PatientID SKIP 
        PATIENT_RCD.PatLastName SKIP 
        PATIENT_RCD.PatFirstName SKIP 
        PATIENT_RCD.PatDOB SKIP(1) 
                 
        MAG_CUST_RCD.billing_street1 SKIP 
        MAG_CUST_RCD.billing_city SKIP 
        MAG_CUST_RCD.billing_region SKIP 
        MAG_CUST_RCD.billing_postcode SKIP(1)
         
        MAG_CUST_RCD.dr_tcp_id_scust_dr_id_int SKIP(1)
        
        PATIENT_RCD.PatAddress1 SKIP 
        PATIENT_RCD.PatCity SKIP 
        PATIENT_RCD.PatProvidence SKIP 
        PATIENT_RCD.PatStatePostalAbbrev SKIP(1) 
        
            WITH FRAME a WIDTH 80 SIDE-LABELS. 
    
       */
        
END. /** of 4ea. patient_rcd, etc. **/
         
DISPLAY x.

/************************   END OF FILE  ********************************/
