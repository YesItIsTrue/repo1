
/*------------------------------------------------------------------------
    File        : TAP-Flags.p
    Purpose     : 

    Syntax      :

    Description : Tap or flip or reverse the RS - progress_flags.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Apr 29, 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE updatemode AS LOG INITIAL   YES    NO-UNDO. 

/* ***************************  Main Block  *************************** */
PAUSE  0 BEFORE-HIDE.
FOR EACH RS.PATIENT_RCD  WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.PATIENT_RCD" SKIP.

FOR EACH RS.MAG_CUST_RCD  WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.MAG_CUST_RCD" SKIP.

FOR EACH RS.MPA_RCD  WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.MPA_RCD" SKIP.

FOR EACH RS.MPA_TEST_DETAILS_RCD  WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.MPA_TEST_DETAILS_RCD" SKIP.
     
FOR EACH RS.patient_files WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.patient_files" SKIP.
      
FOR EACH RS.TESTS_RESULT_RCD WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.TESTS_RESULT_RCD" SKIP.

FOR EACH RS.TESTS_DETAIL_RCD WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.TESTS_DETAIL_RCD" SKIP.
  
FOR EACH RS.TESTS_FM_SPECIMEN_RCD WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.TESTS_FM_SPECIMEN_RCD" SKIP.
       
FOR EACH RS.TESTS_HE_SPECIMEN_RATIOS_RCD WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.TESTS_HE_SPECIMEN_RATIOS_RCD" SKIP.
           
FOR EACH RS.TESTS_UTM_UEE_SPECIMEN_RCD WHERE Progress_DateTime > DATETIME ("04/01/16")  EXCLUSIVE-LOCK:
    DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (count)  "= RS.TESTS_UTM_UEE_SPECIMEN_RCD" SKIP.

    
