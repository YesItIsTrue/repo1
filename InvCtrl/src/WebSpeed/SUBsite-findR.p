
/*------------------------------------------------------------------------
    File        : SUBsite-findR.p

    Description : A sub-routine for finding in the Site Master table.

    Author(s)   : Trae Luttrell
    Created     : Tue Jul 12 08:51:58 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Input / Output Parameters  ******************** */

DEFINE INPUT PARAMETER i-site-name LIKE site_mstr.site_name NO-UNDO.

DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ***************************  Main Block  *************************** */

FIND site_mstr WHERE i-site-name = site_mstr.site_name NO-LOCK NO-ERROR.

IF AVAILABLE (site_mstr) THEN DO:

    ASSIGN
        o-success = YES.

END. /*** of update path ***/

ELSE DO:
    
    ASSIGN
        o-success = NO.

END. /*** of creation path ***/