
/*------------------------------------------------------------------------
    File        : UTIL-EmpID-fix.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Thu Feb 04 14:24:31 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE oldid AS INTEGER NO-UNDO.
DEFINE VARIABLE newid AS INTEGER NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
UPDATE oldid newid.

FOR EACH Hours_Mstr WHERE Hours_Mstr.Hours_client_ID = oldid EXCLUSIVE-LOCK:
    ASSIGN 
        Hours_Mstr.Hours_client_ID = newid.
END.

FOR FIRST people_mstr WHERE people_mstr.people_id = newid NO-LOCK:
    DISPLAY people_mstr.people_lastname people_mstr.people_firstname.
END. 