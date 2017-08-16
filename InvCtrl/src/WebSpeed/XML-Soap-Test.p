
/*------------------------------------------------------------------------
    File        : XML-Soap-Test.p
    Purpose     : 

    Syntax      :

    Description : This is for the salesOrderInfo Magento subroutine.

    Author(s)   : Trae Luttrell
    Created     : Wed Feb 08 16:03:18 EST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */

DEFINE VARIABLE xml-doc AS HANDLE NO-UNDO.
DEFINE VARIABLE xml-root AS HANDLE NO-UNDO.

/* ***************************  Main Block  *************************** */

    IF ITmessages = YES THEN {&OUT}
        "<li class='w3-hover-green'>About to run salesOrderInfo - " string(time,"HH:MM:SS") " increment_id = " item.increment_id "</li>" SKIP.
        
    RUN salesOrderInfo IN hPortType(INPUT sessionId, INPUT item.increment_id, OUTPUT result).
    
    IF ITmessages = YES THEN {&OUT}
        "<li class='w3-hover-green'>Finished running salesOrderInfo - " string(time,"HH:MM:SS") "</li>" SKIP.
