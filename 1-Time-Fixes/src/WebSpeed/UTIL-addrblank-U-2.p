
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
DEFINE VARIABLE updatemode AS LOG INITIAL NO NO-UNDO.

OUTPUT TO "c:\progress\wrk\UTIL-addrblank-U-2.txt".
EXPORT DELIMITER ";"
    "People_ID" "Lastname" "Firstname" "DOB" "addr_ID" "Address1" "City" "State" "ZIP"
    "Mag_Addr1" "Mag_City" "Mag_Region" "Mag_PostCode" "Mag-dr_tcp_id_scust_dr_id_int"
    "Old_Addr1" "Old_City" "Old_Prov" "Old_Postal".
    

/* ***************************  Main Block  *************************** */
FOR EACH PATIENT_RCD WHERE (PATIENT_RCD.PatAddress1 + 
        PATIENT_RCD.PatCity +
        PATIENT_RCD.PatProvidence + 
        PATIENT_RCD.PatStatePostalAbbrev) = "" NO-LOCK,
    FIRST people_mstr WHERE people_mstr.people_id = INTEGER (PATIENT_RCD.PatientID) AND 
        people_mstr.people_addr_id <> 0,
    FIRST scust_shadow WHERE scust_shadow.scust_ID = people_mstr.people_id AND 
                        scust_shadow.scust_magento_ID <> "" NO-LOCK,
    FIRST MAG_CUST_RCD WHERE MAG_CUST_RCD.magento-id = INTEGER(scust_shadow.scust_magento_ID) NO-LOCK,                        
    FIRST addr_mstr WHERE addr_mstr.addr_id = people_mstr.people_addr_id NO-LOCK:

    x = x + 1.
    
    EXPORT DELIMITER ";" 
        people_mstr.people_id  
        people_mstr.people_lastname  
        people_mstr.people_firstname 
        people_mstr.people_DOB 
        people_mstr.people_addr_id
        
        addr_mstr.addr_addr1 
        addr_mstr.addr_city  
        addr_mstr.addr_stateprov  
        addr_mstr.addr_zip 
        
        /*
        PATIENT_RCD.PatientID SKIP 
        PATIENT_RCD.PatLastName SKIP 
        PATIENT_RCD.PatFirstName SKIP 
        PATIENT_RCD.PatDOB SKIP(1) 
        */
                 
        MAG_CUST_RCD.billing_street1  
        MAG_CUST_RCD.billing_city  
        MAG_CUST_RCD.billing_region  
        MAG_CUST_RCD.billing_postcode 
         
        MAG_CUST_RCD.dr_tcp_id_scust_dr_id_int 
                
        PATIENT_RCD.PatAddress1  
        PATIENT_RCD.PatCity  
        PATIENT_RCD.PatProvidence  
        PATIENT_RCD.PatStatePostalAbbrev . 
        
    
        IF updatemode = YES THEN 
            ASSIGN 
                people_mstr.people__dec01 = people_mstr.people_addr_id 
                people_mstr.people_addr_id = 0. 
        
END. /** of 4ea. patient_rcd, etc. **/
        
OUTPUT CLOSE.
         
DISPLAY x.

/************************   END OF FILE  ********************************/
