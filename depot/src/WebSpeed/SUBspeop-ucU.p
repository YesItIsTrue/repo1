
/*------------------------------------------------------------------------
    File        : SUBspeop-ucU.p
    Purpose     : 

    Syntax      :

    Description : v1 simply updates a speop record with people-id, tsize, and unit

    Author(s)   : Andrew Garver
    Created     : Thu Oct 19 17:44:04 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE INPUT PARAMETER i-speop_ID LIKE speop_shadow.speop_ID NO-UNDO.
DEFINE INPUT PARAMETER i-speop_Tsize LIKE speop_shadow.speop_Tsize NO-UNDO.
DEFINE INPUT PARAMETER i-speop_ward LIKE speop_shadow.speop_ward NO-UNDO.

DEFINE OUTPUT PARAMETER o-error AS LOGICAL INITIAL YES NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND speop_shadow WHERE speop_shadow.speop_ID = i-speop_ID AND speop_shadow.speop_deleted = ? NO-ERROR.
    
IF AVAILABLE (speop_shadow) THEN DO:
    ASSIGN 
        speop_shadow.speop_Tsize = IF i-speop_Tsize <> "" THEN i-speop_Tsize ELSE speop_shadow.speop_Tsize
        speop_shadow.speop_ward = IF i-speop_ward <> "" THEN i-speop_ward ELSE speop_shadow.speop_ward
        speop_shadow.speop_modified_date = TODAY 
        speop_shadow.speop_modified_by = USERID("Custom")
        speop_shadow.speop_prog_name = THIS-PROCEDURE:FILENAME
        o-error = FALSE.
END.
ELSE DO:
        CREATE speop_shadow.
        ASSIGN 
            speop_shadow.speop_ID = i-speop_ID
            speop_shadow.speop_Tsize = i-speop_Tsize
            speop_shadow.speop_ward = i-speop_ward
            speop_shadow.speop_create_date = TODAY 
            speop_shadow.speop_created_by = USERID("Custom")
            speop_shadow.speop_prog_name = THIS-PROCEDURE:FILENAME
            o-error = FALSE.
END.