
/*------------------------------------------------------------------------
    File        : XMLgen.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Mon Jan 02 10:25:07 MST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE INPUT PARAMETER INfile AS CHARACTER NO-UNDO.

DEFINE OUTPUT PARAMETER o-INfile AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER HL7file AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER SSfile AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER SS-ERRfile AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER o-fail AS LOGICAL INITIAL YES NO-UNDO.

DEFINE VARIABLE DDIfile   AS CHARACTER FORMAT "x(50)" NO-UNDO.
DEFINE VARIABLE startTime AS DATETIME INIT "06-04-1992 00:00:00" NO-UNDO.
DEFINE VARIABLE currentTime AS DATETIME INIT NOW NO-UNDO.
DEFINE VARIABLE UID       AS INT64 NO-UNDO.  
DEFINE VARIABLE UIDString AS CHARACTER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

ASSIGN   
    UID             = INTERVAL(currentTime, startTime, "milliseconds")
    UIDString       = STRING(UID)
    DDIfile         = SUBSTRING(INfile,1,INDEX(INfile,".txt") - 1)
    HL7file         = UIDString + "_HL7_" + DDIfile + ".xml"
    SSfile          = UIDString + "_SS_" + DDIfile + ".xml"
    SS-ERRfile      = UIDString + "_ERR_" + DDIfile + ".xml"
    o-INfile        = INfile
    o-fail          = NO 
    .
