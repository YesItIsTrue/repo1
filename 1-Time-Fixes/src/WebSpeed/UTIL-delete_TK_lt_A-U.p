
/*------------------------------------------------------------------------
    File        : UTIL-delete_TK_lt_A-U.p
    Purpose     : 

    Syntax      :

    Description : Flags all records with a TK_ID < "A" as being deleted.

    Author(s)   : Doug Luttrell
    Created     : Thu Jun 02 19:05:33 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE updatemode AS LOGICAL NO-UNDO.

UPDATE SKIP(1)
    updatemode SKIP(1)
        WITH FRAME a WIDTH 80 SIDE-LABELS.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


