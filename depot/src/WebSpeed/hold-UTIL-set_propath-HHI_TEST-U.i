
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
          Added the HL7 directory due to the CMC pathing problem.
          Marked by /* 1dot1 */  
    
    1.2 - written by Harold Luttrell, Sr. on 21/Oct/17. 
          Added the Utils directory due to the CMC pathing problem
          and found out that I was not notifiied about this change.
          Most, if not all of the batch programs use the different
          utilities (e.g. Send-EMAIL-Message.p) and with out making
          the changes in the batch programs to use this Utils folder
          then all of the batch programs would error off.
          Marked by /* 1dot2 */ 
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */ 


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE VARIABLE ORIGPROPATH AS CHARACTER NO-UNDO. 
DEFINE VARIABLE DBENV AS CHARACTER INITIAL "P:\OpenEdge\TEST" NO-UNDO.
DEFINE VARIABLE RStP AS CHARACTER INITIAL "C:\apps\RStP" NO-UNDO.
DEFINE VARIABLE HL7-Dir AS CHARACTER INITIAL "C:\APPS\HL7" NO-UNDO.             /* 1dot1 */
DEFINE VARIABLE Utils AS CHARACTER INIT "C:\APPS\Utils" NO-UNDO.                /* 1dot2 */

ASSIGN 
    ORIGPROPATH = PROPATH
    PROPATH     = DBENV + "\rcode;" + RStP + ";" + HL7-Dir + ";" +              /* 1dot1 */
                  Utils + ";" +                                                 /* 1dot2 */
                  PROPATH.                                
    
/*****************************  End of File  *******************************/    