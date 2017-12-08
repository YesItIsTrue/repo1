
/*------------------------------------------------------------------------
    File        : UTIL-set_propath-HHI_TEST-U.i
    Purpose     : 

    Syntax      :

    Description : To provide a single source include file for setting the PROPATH system variable.

    Author(s)   : Doug Luttrell
    Created     : Sat Oct 07 21:59:38 EDT 2017
    Notes       :
        
    Revision History:
    -----------------
    1.1 - written by Harold Luttrell, Sr. on 20/Oct/17. 
          Added the HL7, WRK and Utils directory due to the CMC pathing problem.
          
          Most, if not all of the batch, programs use the different
          utilities (e.g. Send-EMAIL-Message.p) and without making
          the changes in the batch programs to use this Utils folder,
          all of the batch programs would error off.
          Marked by /* 1dot1 */  
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */ 
/*  Character data. */
DEFINE VARIABLE ORIGPROPATH AS CHARACTER NO-UNDO. 
DEFINE VARIABLE DBENV       AS CHARACTER INITIAL "P:\OpenEdge\TEST" NO-UNDO.
DEFINE VARIABLE RStP        AS CHARACTER INITIAL "C:\apps\RStP" NO-UNDO.
DEFINE VARIABLE APPS-HL7    AS CHARACTER INITIAL "C:\APPS\HL7" NO-UNDO.         /* 1dot1 */
DEFINE VARIABLE Utils       AS CHARACTER INITIAL "C:\APPS\Utils" NO-UNDO.       /* 1dot1 */
DEFINE VARIABLE WRK-Logs    AS CHARACTER INITIAL "C:\Progress\WRK" NO-UNDO.     /* 1dot1 */

/* Integer / counters, etc. */
DEFINE VARIABLE i-dbenv-len   AS INTEGER INITIAL 0 NO-UNDO.                     /* 1dot1 */
DEFINE VARIABLE i-propath-len AS INTEGER INITIAL 0 NO-UNDO.                     /* 1dot1 */
DEFINE VARIABLE i-slash-pos   AS INTEGER INITIAL 0 NO-UNDO.                     /* 1dot1 */

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

ASSIGN  i-propath-len   = LENGTH(PROPATH)                                       /* 1dot1 */
        i-dbenv-len     = LENGTH(DBENV)                                         /* 1dot1 */
        i-slash-pos     = R-INDEX (DBENV, "\").                                 /* 1dot1 */

/* Set up the log/reports folder for placing of log files for the DBENV. */     /* 1dot1 */        
ASSIGN                                                                          /* 1dot1 */
    WRK-Logs =  WRK-Logs +                                                      /* 1dot1 */
                SUBSTRING(DBENV, i-slash-pos, i-dbenv-len) +                    /* 1dot1 */
                "-Logs\".                                                       /* 1dot1 */

/* Store off the orig PROPATH and build a new PROPATH for Batch programs, */    /* 1dot1 */ 
ASSIGN 
    ORIGPROPATH = PROPATH
    PROPATH     = DBENV + "\rcode;" + RStP + ";" + 
                  APPS-HL7 + ";" +                                              /* 1dot1 */
                  WRK-Logs + ";" +                                              /* 1dot1 */
                  Utils + ";" +                                                 /* 1dot1 */
                  SUBSTRING(PROPATH, 3, i-propath-len).                         /* 1dot1 */                                

/*****************************  End of File  *******************************/    