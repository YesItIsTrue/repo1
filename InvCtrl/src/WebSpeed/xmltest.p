
/*------------------------------------------------------------------------
    File        : xmltest.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Fri Jan 27 12:58:53 EST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
<callReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns1="urn:Magento" xmlns:ns2="http://xml.apache.org/xml-soap" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xsi:type="ns2:Map"><item><key xsi:type="xsd:string">order</key><value xsi:type="ns2:Map"><item><key xsi:type="xsd:string">customer_info</key><value xsi:type="ns2:Map"><item><key xsi:type="xsd:string">id</key><value xsi:type="xsd:string">1848</value></item><item><key xsi:type="xsd:string">name</key><value xsi:type="xsd:string">Long Richardson</value></item><item><key xsi:type="xsd:string">email</key><value xsi:type="xsd:string">long.richardson@noemail.com</value></item></value></item><item><key xsi:type="xsd:string">shipping_info</key><value xsi:type="ns2:Map"><item><key xsi:type="xsd:string">name</key><value xsi:type="xsd:string">Long Richardson</value></item><item><key xsi:type="xsd:string">street_1</key><value xsi:type="xsd:string">172 Hillside Drive</value></item><item><key xsi:type="xsd:string">city</key><value xsi:type="xsd:string">Anytown</value></item><item><key xsi:type="xsd:string">region</key><value xsi:type="xsd:string">Armed Forces Africa</value></item><item><key xsi:type="xsd:string">postcode</key><value xsi:type="xsd:string">99999</value></item><item><key xsi:type="xsd:string">country_id</key><value xsi:type="xsd:string">US</value></item></value></item><item><key xsi:type="xsd:string">order_items_info</key><value SOAP-ENC:arrayType="ns2:Map[3]" xsi:type="SOAP-ENC:Array"><item xsi:type="ns2:Map"><item><key xsi:type="xsd:string">line_id</key><value xsi:type="xsd:string">533444</value></item><item><key xsi:type="xsd:string">product_id</key><value xsi:type="xsd:string">215920</value></item><item><key xsi:type="xsd:string">sku</key><value xsi:type="xsd:string">FA-SI-QU-BR</value></item><item><key xsi:type="xsd:string">quantity_ordered</key><value xsi:type="xsd:string">1.0000</value></item><item><key xsi:type="xsd:string">name</key><value xsi:type="xsd:string">Fantastic Silver Quilted Broadsword</value></item><item><key xsi:type="xsd:string">weight</key><value xsi:type="xsd:string">1.2000</value></item></item><item xsi:type="ns2:Map"><item><key xsi:type="xsd:string">line_id</key><value xsi:type="xsd:string">533445</value></item><item><key xsi:type="xsd:string">product_id</key><value xsi:type="xsd:string">215921</value></item><item><key xsi:type="xsd:string">sku</key><value xsi:type="xsd:string">OB-GR-IN-LE</value></item><item><key xsi:type="xsd:string">quantity_ordered</key><value xsi:type="xsd:string">1.0000</value></item><item><key xsi:type="xsd:string">name</key><value xsi:type="xsd:string">Obtuse Green Inlaid Leather Armor</value></item><item><key xsi:type="xsd:string">weight</key><value xsi:type="xsd:string">1.5000</value></item></item><item xsi:type="ns2:Map"><item><key xsi:type="xsd:string">line_id</key><value xsi:type="xsd:string">533446</value></item><item><key xsi:type="xsd:string">product_id</key><value xsi:type="xsd:string">215922</value></item><item><key xsi:type="xsd:string">sku</key><value xsi:type="xsd:string">LA-PU-WA-EL</value></item><item><key xsi:type="xsd:string">quantity_ordered</key><value xsi:type="xsd:string">1.0000</value></item><item><key xsi:type="xsd:string">name</key><value xsi:type="xsd:string">Lazy Purple Waxed Elven Broadsword</value></item><item><key xsi:type="xsd:string">weight</key><value xsi:type="xsd:string">3.1000</value></item></item></value></item></value></item></callReturn>