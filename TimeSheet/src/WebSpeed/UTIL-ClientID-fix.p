
/*------------------------------------------------------------------------
    File        : UTIL-ClientID-fix.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Thu Feb 04 14:23:05 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE oldid AS INTEGER NO-UNDO.
DEFINE VARIABLE newid AS INTEGER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
UPDATE oldid newid.

FOR EACH Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = oldid EXCLUSIVE-LOCK:
    ASSIGN 
        Proj_Mstr.Proj_client_ID = newid.
END.
FOR EACH Hours_Mstr WHERE Hours_Mstr.Hours_client_ID = oldid EXCLUSIVE-LOCK:
    ASSIGN 
        Hours_Mstr.Hours_client_ID = newid.
END.
FOR FIRST Client_Mstr WHERE Client_Mstr.Client_people_ID = newid NO-LOCK:
    DISPLAY Client_Mstr.Client_abbv.
END. 