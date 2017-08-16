DEFINE VARIABLE moretests AS INTEGER NO-UNDO.
DEFINE VARIABLE testcount AS INTEGER NO-UNDO.

FOR EACH test_mstr: 
    
    FOR EACH TK_mstr WHERE TK_mstr.TK_testtype = test_mstr.test_type NO-LOCK:
            
        testcount = testcount + 1.
        
    END.  /** of 4ea. tk_mstr **/
        
    test_mstr.test__dec01 = testcount.
     
    testcount = 0.
     
END.  /*** OF 4ea. test_mstr ***/

FOR EACH TESTS_RESULT_RCD WHERE 
    NOT CAN-FIND(FIRST TK_mstr WHERE TK_mstr.TK_id = TESTS_RESULT_RCD.test_kit_nbr AND 
                    TK_mstr.TK_lab_sample_ID = TESTS_RESULT_RCD.lab_sampleid AND 
                    TK_mstr.TK_lab_seq = integer(TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr) NO-LOCK) NO-LOCK,
    FIRST patient_rcd WHERE patient_rcd.patientid = tests_result_rcd.patientid NO-LOCK
        BREAK BY TESTS_RESULT_RCD.Test_Abbv BY TESTS_RESULT_RCD.lab_sampleid:
	     	        
    moretests = moretests + 1.
		          	         
    IF LAST-OF(TESTS_RESULT_RCD.test_abbv) THEN DO: 

        DISPLAY patient_rcd.patfirstname FORMAT "x(15)" 
            patient_rcd.patlastname FORMAT "x(15)"
            TESTS_RESULT_RCD.Test_Abbv FORMAT "x(15)"
            moretests SKIP
            WITH WIDTH 132.
        
        FIND test_mstr WHERE test_mstr.test_type = tests_result_rcd.test_abbv
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF avail (test_mstr) THEN 
            test_mstr.test__dec01 = test_mstr.test__dec01 + moretests.
        ELSE
            MESSAGE "ERROR! No TEST_MSTR record found for " 
                tests_result_rcd.test_abbv SKIP
                "Qty = " moretests SKIP
                VIEW-AS ALERT-BOX WARNING BUTTONS OK.
                    
        moretests = 0.

    END. /** of if last test_abbv **/
	     	
END.  /*** of 4ea. tests_result_rcd ***/


/**************  Show results ***************/
OUTPUT TO PRINTER.

FOR EACH test_mstr NO-LOCK
    BREAK BY test_mstr.test__dec01 DESCENDING BY test_mstr.test_type:
	    
    DISPLAY test_type test_name FORMAT "x(40)" test__dec01.
	    
END.  /** OF 4ea. test_mstr **/
	
OUTPUT CLOSE.

/*****************  End of File.  ***********************/
