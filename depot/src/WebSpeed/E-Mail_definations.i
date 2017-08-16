
/*------------------------------------------------------------------------
    File        : E-Mail_definations.i
    Purpose     : 

    Description : Define variable statements for the "Send-EMail-Message.p" program.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Tue Jan 10 11:38:53 CST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE VARIABLE starting-position       AS INTEGER                  NO-UNDO.  
DEFINE VARIABLE h-pgm-name              AS CHARACTER FORMAT "x(60)" NO-UNDO.


/* ***************************  E-Mail  Definitions  *************************** */
DEFINE VARIABLE From-Calling-Pgm        AS CHARACTER  FORMAT "x(118)"       NO-UNDO. 
DEFINE VARIABLE e_to-whom               AS CHARACTER  FORMAT "x(120)"       NO-UNDO. 
DEFINE VARIABLE e_subject               AS CHARACTER  FORMAT "x(80)"        NO-UNDO. 
DEFINE VARIABLE e_message               AS CHARACTER  FORMAT "x(4000)"      NO-UNDO. 
DEFINE VARIABLE msg-attach-file-name    AS CHARACTER  FORMAT "x(4000)"      NO-UNDO. 

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
ASSIGN starting-position = R-INDEX (THIS-PROCEDURE:FILE-NAME, "\").

ASSIGN h-pgm-name = SUBSTRING(THIS-PROCEDURE:FILE-NAME, (starting-position + 1), LENGTH (THIS-PROCEDURE:FILE-NAME) ).

ASSIGN From-Calling-Pgm = h-pgm-name.
ASSIGN e_to-whom = "". 
ASSIGN e_subject =  "-s Error from ".
ASSIGN e_message =  "-m Error encountered with input data in "
                                + " \n "
                                + THIS-PROCEDURE:FILE-NAME
                                + " \n "
                                + "End of message.".
ASSIGN msg-attach-file-name = "". 

