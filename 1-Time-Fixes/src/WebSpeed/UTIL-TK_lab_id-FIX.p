
/*------------------------------------------------------------------------
    File        : TK_lab_id-FIXp
    Purpose     : Data correction

    Syntax      :

    Description : Correct missing lab id's in the TK_mstr

    Author(s)   : Jacob Luttrell
    Created     : Fri Apr 01 14:06:46 MDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE x AS INTEGER LABEL "Updated Testkits" NO-UNDO.
DEFINE VARIABLE y AS INTEGER LABEL "Missed Testkits" NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH TK_mstr WHERE TK_mstr.TK_lab_ID = "" EXCLUSIVE-LOCK:
    
    FIND test_mstr WHERE test_mstr.test_type = TK_mstr.TK_test_type NO-LOCK NO-ERROR.
    
    IF AVAILABLE (test_mstr) THEN 
        
        ASSIGN 
            TK_mstr.TK_lab_ID = test_mstr.test_lab_ID
            x = x + 1.
                      
    ELSE 
          y = y + 1.

END. /* 4ea. tk_mstr */

DISPLAY x y.      