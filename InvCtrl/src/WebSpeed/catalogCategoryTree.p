DEFINE VARIABLE hWebService as HANDLE NO-UNDO.
DEFINE VARIABLE hPortType as HANDLE NO-UNDO.
DEFINE VARIABLE sessionId as CHARACTER NO-UNDO.
DEFINE VARIABLE callResults as CHARACTER NO-UNDO.

DEFINE VARIABLE serviceUrl as CHARACTER NO-UNDO.

serviceUrl = "https://test-store.holisticheal.com/index.php/api/v2_soap/index/?wsdl=1".

CREATE SERVER hWebService.
hWebService:CONNECT("-WSDL " + serviceUrl).
/*hWebService:CONNECT("-WSDL" + " file:///C:/Users/Showroom/Desktop/magento.wsdl").*/

IF NOT hWebService:CONNECTED() THEN DO:
    MESSAGE "SERVER: " SKIP serviceUrl SKIP
    "Is not connected"
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
  RETURN.
END.
    
RUN PortType SET hPortType ON hWebService.

RUN login IN hPortType(INPUT 'solsource_invctrl', INPUT 'HJ9d3D3SrfDjLE1JCaNP', OUTPUT sessionId).

DEFINE TEMP-TABLE tree NO-UNDO
    FIELD category_id AS INTEGER
    FIELD parent_id AS INTEGER
    FIELD name AS CHARACTER
    FIELD position AS INTEGER
    FIELD level AS INTEGER .

DEFINE TEMP-TABLE children NO-UNDO
    FIELD Item_id AS RECID
        XML-NODE-TYPE "HIDDEN"
    FIELD tree_id AS RECID
        XML-NODE-TYPE "HIDDEN" .

DEFINE TEMP-TABLE Item NO-UNDO
    FIELD category_id AS INTEGER
    FIELD parent_id AS INTEGER
    FIELD name AS CHARACTER
    FIELD is_active AS INTEGER
    FIELD position AS INTEGER
    FIELD level AS INTEGER .

DEFINE DATASET treeDset
    FOR tree, children, Item.
/*    PARENT-ID-RELATION RELATION1 FOR Item, children*/
/*        PARENT-ID-FIELD Item_id                    */
/*    PARENT-ID-RELATION RELATION2 FOR tree, children*/
/*        PARENT-ID-FIELD tree_id.                   */

DEFINE VARIABLE parentId AS CHARACTER NO-UNDO.
DEFINE VARIABLE storeView AS CHARACTER NO-UNDO.

parentId = "2".
storeView = "0".

RUN catalogCategoryTree IN hPortType(INPUT sessionId, INPUT parentId, INPUT storeView, OUTPUT DATASET treeDset).

/*for each tree:                       */
/*    display tree.name format "X(30)".*/
/*end.                                 */

for each ITEM BREAK BY ITEM.parent_id BY ITEM.position:
   display Item.name format "X(30)" ITEM.parent_id ITEM.position ITEM.category_id ITEM.level.
end.
/*for each Item:                                                                                                      */
/*  display Item.name format "X(30)".                                                                                 */
/*/*    display Item.email format "X(30)" Item.firstname format "X(30)" Item.lastname format "X(30)" with width 120.*/*/
/*end.                                                                                                                */

/*DEFINE VARIABLE filters AS LONGCHAR NO-UNDO.*/

/* Use this filter if you don't want to filter for anything */
/*filters = "<filters><filter></filter></filters>".*/

/*filters = "<rootnode><filter><fnamefilter><key>firstname</key><value>Dwight</value></fnamefilter><lnamefilter><key>lastname</key><value>Coyle</value></lnamefilter></filter></rootnode>".*/
/*filters = "".                                                                                                   */
/*                                                                                                                */
/*DEFINE TEMP-TABLE Item NO-UNDO                                                                                  */
/*    FIELD customer_id AS INTEGER                                                                                */
/*    FIELD created_at AS CHARACTER                                                                               */
/*    FIELD updated_at AS CHARACTER                                                                               */
/*    FIELD increment_id AS CHARACTER                                                                             */
/*    FIELD store_id AS INTEGER                                                                                   */
/*    FIELD website_id AS INTEGER                                                                                 */
/*    FIELD created_in AS CHARACTER                                                                               */
/*    FIELD email AS CHARACTER                                                                                    */
/*    FIELD firstname AS CHARACTER                                                                                */
/*    FIELD middlename AS CHARACTER                                                                               */
/*    FIELD lastname AS CHARACTER                                                                                 */
/*    FIELD group_id AS INTEGER                                                                                   */
/*    FIELD prefix AS CHARACTER                                                                                   */
/*    FIELD suffix AS CHARACTER                                                                                   */
/*    FIELD dob AS CHARACTER                                                                                      */
/*    FIELD taxvat AS CHARACTER                                                                                   */
/*    FIELD confirmation AS LOGICAL                                                                               */
/*    FIELD password_hash AS CHARACTER .                                                                          */
/*                                                                                                                */
/*DEFINE DATASET storeView FOR Item.                                                                              */
/*                                                                                                                */
/*RUN customerCustomerList IN hPortType(INPUT sessionId, INPUT filters, OUTPUT DATASET storeView).                */
/*                                                                                                                */
/*for each Item:                                                                                                  */
/*    display Item.email format "X(30)" Item.firstname format "X(30)" Item.lastname format "X(30)" with width 120.*/
/*end.                                                                                                            */
