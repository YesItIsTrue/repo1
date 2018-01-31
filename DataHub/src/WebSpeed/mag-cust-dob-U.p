
/*------------------------------------------------------------------------
    File        : mag-cust-dob-U.p
    Purpose     : Finds all Magento Customers with birthdays on the current day

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Mon Jan 08 21:11:13 EST 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{UTIL-set_propath-HHI_TEST-U.i}.

DEFINE VARIABLE hWebService AS HANDLE NO-UNDO.
DEFINE VARIABLE hPortType AS HANDLE NO-UNDO.
DEFINE VARIABLE sessionId AS CHARACTER NO-UNDO.
DEFINE VARIABLE callResults AS CHARACTER NO-UNDO.

DEFINE VARIABLE serviceUrl AS CHARACTER NO-UNDO.

serviceUrl = "https://test-store.holisticheal.com/api/v2_soap/?wsdl".

CREATE SERVER hWebService.
hWebService:CONNECT("-WSDL " + serviceUrl).
    
RUN PortType SET hPortType ON hWebService.

RUN login IN hPortType(INPUT 'solsource_custupdate', INPUT 'HJ9d3D3SrfDjLE1JCaNP', OUTPUT sessionId).

DEFINE TEMP-TABLE customerData NO-UNDO
    NAMESPACE-URI "urn:Magento" 
    FIELD dob AS CHARACTER.

DEFINE DATASET customerDataDset NAMESPACE-URI "urn:Magento" 
    XML-NODE-TYPE "HIDDEN" 
    FOR customerData.
    
DEFINE VARIABLE v-result AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-dob AS CHARACTER NO-UNDO.
DEFINE BUFFER people_mstr2 FOR people_mstr.
DEFINE STREAM v-out.
OUTPUT STREAM v-out TO "C:\PROGRESS\WRK\dob-log.txt".

/* For each people_mstr record that has a magento ID */
FOR EACH scust_shadow WHERE scust_shadow.scust_magento_ID <> "" NO-LOCK,
FIRST people_mstr WHERE people_mstr.people_id = INTEGER(scust_shadow.scust_ID) NO-LOCK
BREAK BY scust_shadow.scust_magento_ID:
    IF FIRST-OF(scust_shadow.scust_magento_ID) THEN DO:
        /* For each testkit that has been purchased by that person */
        FOR EACH TK_mstr WHERE TK_mstr.TK_cust_ID = people_mstr.people_id NO-LOCK
        BREAK BY TK_mstr.TK_patient_ID:
            IF FIRST-OF(TK_mstr.TK_patient_ID) THEN DO:
            FIND FIRST people_mstr2 WHERE MONTH(people_mstr2.people_DOB) = MONTH(TODAY) AND DAY(people_mstr2.people_DOB) = DAY(TODAY) AND
            people_mstr2.people_id = TK_mstr.TK_patient_ID NO-ERROR.
                /* If one of the patients for whom this person bought a testkit has a birthday today */
                IF AVAILABLE(people_mstr2) THEN DO:
                    RUN VALUE(SEARCH("subr_YY_to_CCYY.r")) (
                        people_mstr2.people_DOB,
                        OUTPUT v-dob
                        ).
                    
                    CREATE customerData.
                    ASSIGN 
                        customerData.dob = v-dob.
                    
                    RUN customerCustomerUpdate IN hPortType(INPUT sessionId, INPUT scust_shadow.scust_magento_ID, INPUT DATASET customerDataDset, OUTPUT v-result) NO-ERROR.
                    
                    IF v-result THEN 
                        EXPORT STREAM v-out scust_shadow.scust_magento_ID v-dob.
                    ELSE 
                        EXPORT STREAM v-out "ERROR" scust_shadow.scust_magento_ID v-dob.
                        
                    EMPTY TEMP-TABLE customerData.
                    LEAVE.
                END.
            END.
        END.
    END.
END.

hWebService:DISCONNECT ().
DELETE OBJECT hWebService.