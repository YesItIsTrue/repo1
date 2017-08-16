
/*------------------------------------------------------------------------
    File        : SoapPtest.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Wed Jan 25 13:03:33 EST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */

/*****  Define Variables  ******/
DEFINE VARIABLE hWebService AS HANDLE NO-UNDO.
DEFINE VARIABLE hPortType AS HANDLE NO-UNDO.
DEFINE VARIABLE sessionId AS CHARACTER NO-UNDO.
DEFINE VARIABLE callResults AS CHARACTER FORMAT "x(65)" NO-UNDO.
DEFINE VARIABLE endSessionResults AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-connect AS LOGICAL NO-UNDO.

/*****  Set Up for Web Server Thing ****/
CREATE SERVER hWebService.
hWebService:CONNECT("-WSDL 'https://demo.mysolsource.com/index.php/api/soap/index/?wsdl=1' -Service 'MagentoService' -Port 'Port'").

/*DISPLAY "Here is what happened when you tried to hwebService:Connect = " v-connect "" WITH FRAME dwight.*/

RUN PortType SET hPortType ON hWebService.
RUN login IN hPortType(INPUT 'solsource_invctrl', INPUT 'P@55w0rd', OUTPUT sessionId).
IF sessionID <> "" THEN DISPLAY "<h1> Successful connection to Magento, session ID = " sessionID " </h1><br>" WITH FRAME dwight2.
    ELSE DISPLAY "<p> Unsuccessfull </p><br>" WITH FRAME dwight2.

/*****  Internal Procedures  ******/
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

/******  Main Program  *******/
RUN call IN hPortType(INPUT sessionId, INPUT 'invctrl_connect.modify_qoh', INPUT '1600 + 11111', OUTPUT callResults).

DISPLAY  callResults WITH FRAME dwight3.

RUN endSession IN hPortType(INPUT sessionId, OUTPUT endSessionResults).

IF endSessionResults = YES THEN DISPLAY "<h1> Successful disconnection from Magento </h1><br>" WITH FRAME dwight4.
    ELSE DISPLAY "<h1> Unsuccessful disconnection from Magento </h1><br>" WITH FRAME dwight4.

