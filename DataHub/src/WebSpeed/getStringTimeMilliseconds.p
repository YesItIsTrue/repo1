
/*------------------------------------------------------------------------
    File        : getStringTimeMilliseconds.p
    Purpose     : Prepend or append a unique value to a filename

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Mon May 17 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE OUTPUT PARAMETER timeInMilliseconds AS CHARACTER INITIAL "" NO-UNDO.

DEFINE VARIABLE startTime   AS DATETIME  INIT "01-01-1970 00:00:00" NO-UNDO.
DEFINE VARIABLE currentTime AS DATETIME  INIT NOW NO-UNDO.
DEFINE VARIABLE UID         AS INT64     NO-UNDO.  

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
ASSIGN   
    UID        = INTERVAL(currentTime, startTime, "milliseconds")
    timeInMilliseconds = STRING(UID)
    .
    