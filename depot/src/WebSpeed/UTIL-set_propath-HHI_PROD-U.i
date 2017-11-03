
/*------------------------------------------------------------------------
    File        : UTIL-set_propath-HHI_PROD-U.i
    Purpose     : 

    Syntax      :

    Description : To provide a single source include file for setting the PROPATH system variable.

    Author(s)   : Doug Luttrell
    Created     : Sat Oct 07 21:59:38 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */ 


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE VARIABLE ORIGPROPATH AS CHARACTER NO-UNDO. 
DEFINE VARIABLE DBENV AS CHARACTER INITIAL "P:\OpenEdge\PROD" NO-UNDO.
DEFINE VARIABLE RStP AS CHARACTER INITIAL "C:\apps\RStP" NO-UNDO.

ASSIGN 
    ORIGPROPATH = PROPATH
    PROPATH     = DBENV + "\rcode;" + RStP + ";" + PROPATH.
    
/*****************************  End of File  *******************************/    