/******
 Runs through the tk_mstr looking for tests of the MPA family that actually have MPA
 for a testtype instead of whatever the prefix is.  Changes the testtype to match the 
 prefix (in CAPS).
********/

DEFINE STREAM errlog.

DEFINE VARIABLE testpref AS CHARACTER NO-UNDO. 

OUTPUT STREAM errlog TO "c:\progress\wrk\testtypefix.txt".

EXPORT STREAM errlog DELIMITER ";"
    "TK_ID" "Test Type" "Error Message". 

FOR EACH tk_mstr : 

    testpref = CAPS(SUBSTRING(tk_id,1,INDEX(tk_id,"-") - 1)).

    FIND test_mstr WHERE test_type = testpref NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE (test_mstr) THEN DO:  
    
        EXPORT STREAM errlog DELIMITER ";"
            tk_id tk_test_type "Error 1 - No test_mstr found for test type.".
    
    END.  /** of not avail test_mstr **/
    
    ELSE DO:
    
        IF test_family = "MPA" THEN DO: 
        
            IF tk_test_type = "MPA" THEN
                TK_test_type = testpref.
               
           
        END.  /** of if test_family = MPA **/    
    
    END.  /** of else do -- if avail test_mstr **/
    
END.  /*** of 4ea. tk_mstr ***/

EXPORT STREAM errlog DELIMITER ";"
    "99999999" "DONE" "END OF FILE".
    
OUTPUT STREAM errlog CLOSE.

/********************  End of File.  ***********************/

