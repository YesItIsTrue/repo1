
/*------------------------------------------------------------------------
    File        : RScleanupU.p
    Purpose     : 

    Syntax      :

    Description : Blank Testkit ID cleanup program

    Author(s)   : Jacob Luttrell
    Created     : Wed Jun 01 06:15:54 MDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE x AS INTEGER LABEL "Testkits with no ID." NO-UNDO.
DEFINE VARIABLE y AS INTEGER LABEL "Testkit flags changed." NO-UNDO.
DEFINE VARIABLE successful AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE a AS INTEGER LABEL "MPAs with no ID." NO-UNDO.
DEFINE VARIABLE b AS INTEGER LABEL "MPA flags changed." NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH rs.TESTS_RESULT_RCD WHERE rs.TESTS_RESULT_RCD.Test_Kit_Nbr = "" EXCLUSIVE-LOCK: 
    
    x = x + 1.
    
/*    DISPLAY rs.TESTS_RESULT_RCD.Test_Kit_Nbr rs.TESTS_RESULT_RCD.Test_Abbv rs.TESTS_RESULT_RCD.Progress_Flag.*/

    ASSIGN
        rs.TESTS_RESULT_RCD.Progress_Flag = "D"
        successful = YES.
        
    IF successful = YES THEN 
    
    y = y + 1.    

    successful = ?.
        
END.
FOR EACH rs.MPA_RCD WHERE rs.MPA_RCD.MPA_Test_Kit_Nbr = "" EXCLUSIVE-LOCK:
    
    a = a + 1.
    
    ASSIGN 
        rs.MPA_RCD.Progress_Flag = "D"
        successful = YES.
        
    IF successful = YES THEN 
    
        b = b + 1.    

    successful = ?.
        
END. 
    
DISPLAY x SKIP(1) y SKIP(1) a SKIP(1) b SKIP(1) WITH FRAME fox SIDE-LABELS.
