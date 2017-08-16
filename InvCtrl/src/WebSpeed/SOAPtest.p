<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD>
<META NAME="AUTHOR" CONTENT="Trae">
<TITLE>SOAP Test</TITLE>
<SCRIPT LANGUAGE="SpeedScript">
/* Create an unnamed pool to store all the widgets created by this procedure.
   This is a good default which assures that this procedure's triggers and
   internal procedures will execute in this procedure's storage, and that
   proper cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.
</SCRIPT>
</HEAD>

<BODY>
<SCRIPT LANGUAGE="SpeedScript">
  /*------------------------------------------------------------------
    File:
    Description:
    Created: 
    Notes: 
        
        /*-WSDLUserid 'solsource_invctrl' -WSDLPassword 'HJ9d3D3SrfDjLE1JCaNP'*/
        -Service 'modify_qoh' 
  -------------------------------------------------------------------*/

 
/* client_ValidateEmail.p */
/*DEFINE VARIABLE MagentoConnection AS HANDLE NO-UNDO.                  */
/*DEFINE VARIABLE v-whathappened AS CHARACTER INITIAL "Nothing" NO-UNDO.*/
/*DEFINE VARIABLE hXWebEmailValidationInterface AS HANDLE NO-UNDO.      */
/*CREATE SERVER MagentoConnection.                                                                          */
/*MagentoConnection:CONNECT("-WSDL 'https://test-store.holisticheal.com/index.php/api/soap/index/?wsdl=1'").*/
/*/*MagentoConnection:INITIALIZE ("solsource_invctrl" , "HJ9d3D3SrfDjLE1JCaNP" ).*/                         */

/*RUN XWebEmailValidationInterface SET hXWebEmailValidationInterface ON MagentoConnection.*/
/*                                                                                        */
/*RUN modify_qoh                                                                          */
/*/*IN hXWebEmailValidationInterface*/                                                    */
/*  (INPUT "1307 + 11", OUTPUT v-whathappened).                                           */
/*{&OUT} "<h2>Here is what happened: " v-whathappened "</h2>".*/
/* client_GetExternalIP.p */

/*DEFINE VARIABLE hWebService AS HANDLE NO-UNDO.                                                      */
/*DEFINE VARIABLE hGetExternalIP2Soap AS HANDLE NO-UNDO.                                              */
/*CREATE SERVER hWebService.                                                                          */
/*hWebService:CONNECT("-WSDL 'https://test-store.holisticheal.com/index.php/api/soap/index/?wsdl=1'").*/
/*/*RUN GetExternalIP2Soap SET hGetExternalIP2Soap ON hWebService.*/                                  */
/*RUN modify_qoh SET hGetExternalIP2Soap ON hWebService.                                              */
/*FUNCTION getExternalIp RETURNS CHARACTER                                                            */
/*  IN hGetExternalIP2Soap.                                                                           */
/*/*MESSAGE  getExternalIp() VIEW-AS ALERT-BOX.*/                                                     */
/*{&OUT} "<h2>Here is what happened: " getExternalIp() "</h2>".                                       */
/*hWebService:DISCONNECT().                                                                           */

/*****  Define Variables  ******/
DEFINE VARIABLE hWebService AS HANDLE NO-UNDO.
DEFINE VARIABLE hPortType AS HANDLE NO-UNDO.
DEFINE VARIABLE sessionId AS CHARACTER NO-UNDO.
DEFINE VARIABLE callResults AS CHARACTER FORMAT "x(65)" NO-UNDO.
DEFINE VARIABLE endSessionResults AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-connect AS LOGICAL NO-UNDO.

DEFINE VARIABLE pn AS CHARACTER NO-UNDO.


    /***** Temp Table for the MakeAwesomeTable Procedure ***/
    DEFINE TEMP-TABLE MagQOH NO-UNDO
        NAMESPACE-URI "urn:Magento"
        FIELD mq-PartNumber AS CHARACTER 
        FIELD mq-Qty AS DECIMAL  
        FIELD mq-Operand AS CHARACTER.

/*****  Set Up for Web Server Thing ****/
CREATE SERVER hWebService.
hWebService:CONNECT("-WSDL 'https://demo.mysolsource.com/index.php/api/soap/index/?wsdl=1' -Service 'MagentoService' -Port 'Port'").

RUN PortType SET hPortType ON hWebService.
RUN login IN hPortType(INPUT 'solsource_invctrl', INPUT 'P@55w0rd', OUTPUT sessionId).
IF sessionID <> "" THEN {&OUT} "<h1> Successful connection to Magento, session ID = " sessionID " </h1><br>" SKIP(1).
    ELSE {&OUT} "<p> Unsuccessfull </p><br>".

/*****  Internal Procedures  ******/
PROCEDURE getData: 
    DEFINE INPUT PARAMETER searchstring AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER searchfor AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER partnumber AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE huntstart AS CHARACTER NO-UNDO.
    DEFINE VARIABLE huntend AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-start AS INTEGER NO-UNDO.
    DEFINE VARIABLE v-end AS INTEGER NO-UNDO.
    
    ASSIGN 
        huntstart   = "&lt;" + searchfor + "&gt;"
        huntend     = "&lt;/" + searchfor + "&gt;".
    
    DISPLAY substring(searchstring,1,50) FORMAT "x(50)" skip 
        substring(searchstring,51,100) format "x(50)" skip
        substring(searchstring,101,150) FORMAT "x(50)" skip
        substring(searchstring,151,200) format "x(50)" skip 
        substring(searchstring,201,250) format "x(50)" skip
        substring(searchstring,251,300) format "x(50)" skip 
        substring(searchstring,301,350) format "x(50)" skip
        substring(searchstring,351,400) format "x(50)" skip 
        substring(searchstring,401,450) format "x(50)" skip
        substring(searchstring,451,500) format "x(50)" skip 
        substring(searchstring,501,550) format "x(50)" skip(1)
        huntstart skip
        huntend skip(1)
            WITH FRAME abc NO-LABELS.
         
    v-start = index(searchstring,huntstart).
    IF v-start = 0 THEN
        DISPLAY "ERR FLAG - Start".
    
    v-end = index(searchstring,huntend).
    IF v-end = 0 THEN
        DISPLAY "ERR FLAG - End".
        
    IF v-start > 0 AND v-end > 0 THEN 
        partnumber = substring(searchstring,(v-start + length(huntstart)),(length(huntend) - (v-start + length(huntstart)))).
        
END.  /** of procedure getdata **/        
     
        
    

PROCEDURE call:
    DEFINE INPUT PARAMETER sessionId AS CHARACTER NO-UNDO. 
    DEFINE INPUT PARAMETER resourcePath AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER args AS LONGCHAR NO-UNDO.
    DEFINE OUTPUT PARAMETER callReturn AS LONGCHAR NO-UNDO.
END PROCEDURE. 

PROCEDURE endSession:
  DEFINE INPUT PARAMETER sessionId AS CHARACTER NO-UNDO.   
  DEFINE OUTPUT PARAMETER endSessionReturn AS LOGICAL NO-UNDO.
END PROCEDURE.

PROCEDURE MakeAwesomeTable:
    DEFINE INPUT PARAMETER sessionID AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR MagQOH.
END PROCEDURE.


        
/******  Main Program  *******/
RUN call IN hPortType(INPUT sessionId, INPUT 'invctrl_connect.modify_qoh', INPUT '1600 - 11111', OUTPUT callResults).

RUN getData (callResults, "PartNumber", OUTPUT pn).

{&OUT} "<P><H1>Part Number = " pn "</H1></P>".

{&OUT} "<p><i> Call Results: </i>" callResults "</p><br>".

RUN endSession IN hPortType(INPUT sessionId, OUTPUT endSessionResults).

IF endSessionResults = YES THEN {&OUT} "<h1> Successful disconnection from Magento </h1><br>".
    ELSE {&OUT} "<h1> Unsuccessful disconnection from Magento </h1><br>".

</SCRIPT>
</BODY>
</HTML>