/*******************************************
 * 
 *  UTIL-fix-mpa-testtype-U.p - Doug Luttrell - Version 1.1 - 28/Sep/15
 *
 *  Runs through the tk_mstr looking for tests of the MPA family that actually have MPA
 *  for a testtype instead of whatever the prefix is.  Changes the testtype to match the 
 *  prefix (in CAPS).
 *
 *  --------------------------------------------------------------------------------------
 *
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 28/Feb/15.  Original Version.
 *  1.1 - written by DOUG LUTTRELL on on 28/Sep/15.  Verify that this
 *          code will really fix the problems that were created before
 *          the RStP-MPA_RCD-U-1.p was fixed.  There are lots of tests
 *          without a prefix, so those show in the error log, though 
 *          they are actually OK.
 *  1.2 - written by Jacob Luttrell on 18/Mar/16. added progname marked by 1dot2.
 ********************************************/

DEFINE STREAM errlog.

DEFINE VARIABLE testpref AS CHARACTER NO-UNDO.

OUTPUT stream errlog to "c:\progress\wrk\testtypefix.txt".

EXPORT STREAM errlog DELIMITER ";"
    "TK_ID" "Test Type" "Error Message".

FOR EACH tk_mstr : 

    testpref = CAPS(SUBSTRING(tk_id,1,INDEX(tk_id,"-") - 1)).

    FIND FIRST test_mstr WHERE test_mstr.test_type = testpref NO-LOCK NO-ERROR.
    
    IF NOT avail (test_mstr) THEN DO:  
    
        EXPORT STREAM errlog DELIMITER ";"
            TK_mstr.tk_id TK_mstr.tk_test_type "Error 1 - No test_mstr found for test type.".
    
    END.  /** of not avail test_mstr **/
    
    ELSE DO:
    
        IF test_mstr.test_family = "MPA" THEN DO: 
        
            IF TK_mstr.tk_test_type = "MPA" THEN
               ASSIGN 
                    TK_mstr.TK_test_type = testpref
                    TK_mstr.TK_prog_name = THIS-PROCEDURE:FILE-NAME.        /* 1dot2 */
               
           
        END.  /** of if test_family = MPA **/    
    
    END.  /** of else do -- if avail test_mstr **/
    
END.  /*** of 4ea. tk_mstr ***/

EXPORT STREAM errlog DELIMITER ";"
    "99999999" "DONE" "END OF FILE".
    
OUTPUT stream errlog close.

/********************  End of File.  ***********************/

