DEFINE VARIABLE hWebService as HANDLE NO-UNDO.
DEFINE VARIABLE hPortType as HANDLE NO-UNDO.
DEFINE VARIABLE sessionId as CHARACTER NO-UNDO.
DEFINE VARIABLE callResults as CHARACTER NO-UNDO.

DEFINE VARIABLE serviceUrl as CHARACTER NO-UNDO.

serviceUrl = "https://test-store.holisticheal.com/index.php/api/v2_soap/index/?wsdl=1".

CREATE SERVER hWebService.
/*hWebService:CONNECT("-WSDL " + serviceUrl).*/
hWebService:CONNECT("-WSDL" + " file:///C:/Users/Showroom/Desktop/magento.wsdl").

IF NOT hWebService:CONNECTED() THEN DO:
    MESSAGE "SERVER: " SKIP serviceUrl SKIP
    "Is not connected"
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
  RETURN.
END.
    
RUN PortType SET hPortType ON hWebService.

RUN login IN hPortType(INPUT 'solsource_invctrl', INPUT 'HJ9d3D3SrfDjLE1JCaNP', OUTPUT sessionId).

DEFINE VARIABLE filters AS LONGCHAR NO-UNDO.

/* Use this filter if you don't want to filter for anything */
/*filters = "<filters><filter></filter></filters>".*/

filters = "<rootnode><filter><fnamefilter><key>firstname</key><value>Dwight</value></fnamefilter><lnamefilter><key>lastname</key><value>Coyle</value></lnamefilter></filter></rootnode>".

DEFINE TEMP-TABLE Item NO-UNDO
    FIELD customer_id AS INTEGER 
    FIELD created_at AS CHARACTER 
    FIELD updated_at AS CHARACTER 
    FIELD increment_id AS CHARACTER 
    FIELD store_id AS INTEGER 
    FIELD website_id AS INTEGER 
    FIELD created_in AS CHARACTER 
    FIELD email AS CHARACTER 
    FIELD firstname AS CHARACTER 
    FIELD middlename AS CHARACTER 
    FIELD lastname AS CHARACTER 
    FIELD group_id AS INTEGER 
    FIELD prefix AS CHARACTER 
    FIELD suffix AS CHARACTER 
    FIELD dob AS CHARACTER 
    FIELD taxvat AS CHARACTER 
    FIELD confirmation AS LOGICAL 
    FIELD password_hash AS CHARACTER .

DEFINE DATASET storeView FOR Item.

RUN customerCustomerList IN hPortType(INPUT sessionId, INPUT filters, OUTPUT DATASET storeView).

for each Item:
    display Item.email format "X(30)" Item.firstname format "X(30)" Item.lastname format "X(30)" with width 120.
end.

/*DEFINE TEMP-TABLE customerInfo NO-UNDO                                                                                                  */
/*/*    NAMESPACE-URI "urn:Magento"*/                                                                                                     */
/*    FIELD customer_id AS INTEGER                                                                                                        */
/*    FIELD created_at AS CHARACTER                                                                                                       */
/*    FIELD updated_at AS CHARACTER                                                                                                       */
/*    FIELD increment_id AS CHARACTER                                                                                                     */
/*    FIELD store_id AS INTEGER                                                                                                           */
/*    FIELD website_id AS INTEGER                                                                                                         */
/*    FIELD created_in AS CHARACTER                                                                                                       */
/*    FIELD email AS CHARACTER                                                                                                            */
/*    FIELD firstname AS CHARACTER                                                                                                        */
/*    FIELD middlename AS CHARACTER                                                                                                       */
/*    FIELD lastname AS CHARACTER                                                                                                         */
/*    FIELD group_id AS INTEGER                                                                                                           */
/*    FIELD prefix AS CHARACTER                                                                                                           */
/*    FIELD suffix AS CHARACTER                                                                                                           */
/*    FIELD dob AS CHARACTER                                                                                                              */
/*    FIELD taxvat AS CHARACTER                                                                                                           */
/*    FIELD confirmation AS LOGICAL                                                                                                       */
/*    FIELD password_hash AS CHARACTER .                                                                                                  */
/*                                                                                                                                        */
/*DEFINE DATASET magentodata for customerInfo.                                                                                            */
/*                                                                                                                                        */
/*DEFINE VARIABLE attributes AS CHARACTER EXTENT 3 NO-UNDO.                                                                               */
/*attributes[1] = 'email'.                                                                                                                */
/*attributes[2] = 'firstname'.                                                                                                            */
/*attributes[3] = 'lastname'.                                                                                                             */
/*                                                                                                                                        */
/*RUN customerCustomerInfo IN hPortType(INPUT sessionId, INPUT 1850, INPUT attributes, OUTPUT DATASET magentodata).                       */
/*                                                                                                                                        */
/*for each customerInfo:                                                                                                                  */
/*    display customerInfo.email format "X(30)" customerInfo.firstname format "X(30)" customerInfo.lastname format "X(30)" with width 120.*/
/*end.                                                                                                                                    */
