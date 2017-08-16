
/*------------------------------------------------------------------------
    File        : TAP-Flags-Test-Kit-ID-Less-than-A.p
    Purpose     : 

    Syntax      :

    Description : Tap or flip or reverse the RS - progress_flags.

    Author(s)   : Harold Luttrell, Sr.
    Created     : May 16, 2016
    Notes       :
        
    1.1 - written by DOUG LUTTRELL on 02/Jun/16.  Changed this program around
            to make better use of the indices on the various tables.  Not all
            the tables have useable indices for what we need, but some do.
            Not marked.
                      
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE updatemode AS LOG INITIAL   YES  NO-UNDO. 

DEFINE VARIABLE Mkount-1 AS INTEGER  NO-UNDO.  
DEFINE VARIABLE Mkount-2 AS INTEGER  NO-UNDO. 

DEFINE VARIABLE PFkount-1 AS INTEGER NO-UNDO.
DEFINE VARIABLE PFkount-2 AS INTEGER NO-UNDO.

DEFINE VARIABLE Tkount-1 AS INTEGER  NO-UNDO.  
DEFINE VARIABLE Tkount-2 AS INTEGER  NO-UNDO.  
DEFINE VARIABLE Tkount-3 AS INTEGER  NO-UNDO.  
DEFINE VARIABLE Tkount-4 AS INTEGER  NO-UNDO.  
DEFINE VARIABLE Tkount-5 AS INTEGER  NO-UNDO. 

/* ***************************  Main Block  *************************** */
PAUSE  0 BEFORE-HIDE.

FOR EACH MPA_RCD  WHERE MPA_RCD.MPA_Test_Kit_Nbr <> ""  AND 
    MPA_RCD.MPA_Test_Kit_Nbr < "A" AND      
    MPA_RCD.Progress_Flag <> "DL" AND 
    MPA_RCD.Progress_Flag <> "D" 
        EXCLUSIVE-LOCK: 
                
    ASSIGN Mkount-1 = Mkount-1 + 1.

/*        DISPLAY RS.MPA_RCD.MPA_Test_Kit_Nbr FORMAT "x(15)" RS.MPA_RCD.MPA_Sample_ID_Number FORMAT "x(15)" RS.MPA_RCD.MPA_Sample_ID_SeqNbr RS.MPA_RCD.Progress_Flag FORMAT "xx".*/

    IF updatemode = YES THEN DO:
    
        ASSIGN MPA_RCD.Progress_Flag = "U".
    
    END.  /* IF updatemode = YES  */ 
    
    FOR EACH RS.MPA_TEST_DETAILS_RCD  WHERE RS.MPA_TEST_DETAILS_RCD.PatientID    = RS.MPA_RCD.PatientID AND
        RS.MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number = RS.MPA_RCD.MPA_Sample_ID_Number AND
        RS.MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr = RS.MPA_RCD.MPA_Sample_ID_SeqNbr AND
        RS.MPA_TEST_DETAILS_RCD.Progress_Flag <> "DL" AND 
        RS.MPA_TEST_DETAILS_RCD.Progress_Flag <> "D"     
            EXCLUSIVE-LOCK:
                    
        ASSIGN Mkount-2 = Mkount-2 + 1.

/*        DISPLAY RS.MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number FORMAT "x(15)" RS.MPA_TEST_DETAILS_RCD.MPA_SNP_ID_Seq_Nbr RS.MPA_TEST_DETAILS_RCD.Progress_Flag FORMAT "xx".*/

        IF updatemode = YES THEN DO:
            ASSIGN RS.MPA_TEST_DETAILS_RCD.Progress_Flag = "U".   
        END.  /* IF updatemode = YES  */  

    END.  /** 4 EACH RS.MPA_TEST_DETAILS_RCD **/    
    
    FOR EACH RS.PATIENT_FILES   WHERE   RS.PATIENT_FILES.PatientID    = RS.MPA_RCD.PatientID AND
        RS.PATIENT_FILES.lab_sampleid  = RS.MPA_RCD.MPA_Sample_ID_Number AND
        RS.PATIENT_FILES.lab_sampleid_seqnbr = RS.MPA_RCD.MPA_Sample_ID_SeqNbr AND                                        
        RS.PATIENT_FILES.Progress_Flag <> "DL" AND 
        RS.PATIENT_FILES.Progress_Flag <> "D"     
            EXCLUSIVE-LOCK:
                    
        ASSIGN PFkount-1 = PFkount-1 + 1.

/*        DISPLAY RS.PATIENT_FILES.lab_sampleid FORMAT "x(15)"  RS.PATIENT_FILES.lab_sampleid_seqnbr RS.PATIENT_FILES.Progress_Flag.Progress_Flag FORMAT "xx".*/

        IF updatemode = YES THEN DO:
            ASSIGN RS.PATIENT_FILES.Progress_Flag = "U".   
        END.  /* IF updatemode = YES  */  

    END.  /** 4 EACH RS.PATIENT_FILES **/    
          
END.  /** 4 EACH RS.MPA_RCD **/

DISPLAY  Mkount-1  "= RS.MPA_RCD" SKIP.
DISPLAY  Mkount-2  "= RS.MPA_TEST_DETAILS_RCD" SKIP.
DISPLAY  PFkount-1 "= RS.PATIENT_FILES for MPA data" SKIP.

       
FOR EACH RS.TESTS_RESULT_RCD WHERE RS.TESTS_RESULT_RCD.Test_Kit_Nbr  <> "" AND 
    RS.TESTS_RESULT_RCD.Test_Kit_Nbr < "A" AND 
    RS.TESTS_RESULT_RCD.Progress_Flag <> "DL" AND 
    RS.TESTS_RESULT_RCD.Progress_Flag <> "D" 
        EXCLUSIVE-LOCK:

    ASSIGN Tkount-1 = Tkount-1 + 1.
/*    DISPLAY RS.TESTS_RESULT_RCD.Test_Kit_Nbr FORMAT "x(15)" RS.TESTS_RESULT_RCD.Lab_Sampleid FORMAT "x(15)" RS.TESTS_RESULT_RCD.Progress_Flag FORMAT "xx"  RS.TESTS_RESULT_RCD.Progress_Datetime.*/
    
    IF updatemode = YES THEN DO:
        ASSIGN RS.TESTS_RESULT_RCD.Progress_Flag = "U".   
    END.  /* IF updatemode = YES  */ 
    
    FOR EACH RS.TESTS_DETAIL_RCD WHERE  RS.TESTS_DETAIL_RCD.PatientID    = RS.TESTS_RESULT_RCD.PatientID AND
        RS.TESTS_DETAIL_RCD.Lab_Sampleid = RS.TESTS_RESULT_RCD.Lab_Sampleid AND
        RS.TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr = RS.TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr AND
        RS.TESTS_DETAIL_RCD.Test_Abbv    = RS.TESTS_RESULT_RCD.Test_Abbv AND
        RS.TESTS_DETAIL_RCD.Progress_Flag <> "DL" AND 
        RS.TESTS_DETAIL_RCD.Progress_Flag <> "D"         
              EXCLUSIVE-LOCK:
        
        ASSIGN Tkount-2 = Tkount-2 + 1.
/*        DISPLAY RS.TESTS_DETAIL_RCD.Lab_Sampleid FORMAT "x(15)" RS.TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr*/
/*                RS.TESTS_DETAIL_RCD.PatientID   RS.TESTS_DETAIL_RCD.Test_Abbv FORMAT "x(8)"            */
/*                RS.TESTS_DETAIL_RCD.Progress_Flag FORMAT "xx".                                         */
        
        IF updatemode = YES THEN DO:
            ASSIGN RS.TESTS_DETAIL_RCD.Progress_Flag = "U".  
        END.
    END.  /** 4 EACH RS.TESTS_DETAIL_RCD **/ 
        
    FOR EACH RS.TESTS_FM_SPECIMEN_RCD WHERE RS.TESTS_FM_SPECIMEN_RCD.PatientID = RS.TESTS_RESULT_RCD.PatientID AND
        RS.TESTS_FM_SPECIMEN_RCD.Lab_Sampleid = RS.TESTS_RESULT_RCD.Lab_Sampleid AND
        RS.TESTS_FM_SPECIMEN_RCD.Lab_Sampleid_SeqNbr = RS.TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr AND
        RS.TESTS_FM_SPECIMEN_RCD.Test_Abbv    = RS.TESTS_RESULT_RCD.Test_Abbv AND
        RS.TESTS_FM_SPECIMEN_RCD.Progress_Flag <> "DL" AND 
        RS.TESTS_FM_SPECIMEN_RCD.Progress_Flag <> "D"         
              EXCLUSIVE-LOCK:
        
        ASSIGN Tkount-3 = Tkount-3 + 1.
/*        DISPLAY RS.TESTS_FM_SPECIMEN_RCD.Lab_Sampleid FORMAT "x(15)" RS.TESTS_FM_SPECIMEN_RCD.Lab_Sampleid_SeqNbr*/
/*                RS.TESTS_FM_SPECIMEN_RCD.PatientID   RS.TESTS_FM_SPECIMEN_RCD.Test_Abbv FORMAT "x(8)"            */
/*                RS.TESTS_FM_SPECIMEN_RCD.Progress_Flag FORMAT "xx".                                              */
        
        IF updatemode = YES THEN DO:
            ASSIGN RS.TESTS_FM_SPECIMEN_RCD.Progress_Flag = "U".  
        END.
    END.  /** 4 EACH RS.TESTS_FM_SPECIMEN_RCD **/ 
            
    FOR EACH RS.TESTS_HE_SPECIMEN_RATIOS_RCD WHERE RS.TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID    = RS.TESTS_RESULT_RCD.PatientID AND
        RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid = RS.TESTS_RESULT_RCD.Lab_Sampleid AND
        RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr = RS.TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr AND
        RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Test_Abbv    = RS.TESTS_RESULT_RCD.Test_Abbv AND
        RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag <> "DL" AND 
        RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag <> "D"         
              EXCLUSIVE-LOCK:
        
        ASSIGN Tkount-4 = Tkount-4 + 1.
/*        DISPLAY RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid FORMAT "x(15)" RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Lab_Sampleid_SeqNbr*/
/*                RS.TESTS_HE_SPECIMEN_RATIOS_RCD.PatientID   RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Test_Abbv FORMAT "x(8)"            */
/*                RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag FORMAT "xx".                                                     */
        
        IF updatemode = YES THEN DO:
            ASSIGN RS.TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "U".  
        END.
    END.  /** 4 EACH RS.TESTS_HE_SPECIMEN_RATIOS_RCD **/ 
            
    FOR EACH RS.TESTS_UTM_UEE_SPECIMEN_RCD WHERE RS.TESTS_UTM_UEE_SPECIMEN_RCD.PatientID    = RS.TESTS_RESULT_RCD.PatientID AND
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid = RS.TESTS_RESULT_RCD.Lab_Sampleid AND
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr = RS.TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr AND
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv    = RS.TESTS_RESULT_RCD.Test_Abbv AND
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag <> "DL" AND 
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag <> "D"         
              EXCLUSIVE-LOCK:
        
        ASSIGN Tkount-5 = Tkount-5 + 1.
/*        DISPLAY RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid FORMAT "x(15)" RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr*/
/*                RS.TESTS_UTM_UEE_SPECIMEN_RCD.PatientID   RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv FORMAT "x(8)"            */
/*                RS.TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag FORMAT "xx".                                                   */
        
        IF updatemode = YES THEN DO:
            ASSIGN RS.TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "U".  
        END.
    END.  /** 4 EACH RS.TESTS_HE_SPECIMEN_RATIOS_RCD **/ 
 
    
    FOR EACH RS.PATIENT_FILES   WHERE RS.PATIENT_FILES.PatientID    = RS.TESTS_RESULT_RCD.PatientID AND
        RS.PATIENT_FILES.lab_sampleid  = RS.TESTS_RESULT_RCD.Lab_Sampleid AND
        RS.PATIENT_FILES.lab_sampleid_seqnbr = RS.TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr AND
        RS.PATIENT_FILES.Progress_Flag <> "DL" AND 
        RS.PATIENT_FILES.Progress_Flag <> "D"     
                EXCLUSIVE-LOCK:
                    
        ASSIGN PFkount-2 = PFkount-2 + 1.

/*        DISPLAY RS.PATIENT_FILES.lab_sampleid FORMAT "x(15)"  RS.PATIENT_FILES.lab_sampleid_seqnbr RS.PATIENT_FILES.Progress_Flag.Progress_Flag FORMAT "xx".*/

        IF updatemode = YES THEN DO:
            ASSIGN RS.PATIENT_FILES.Progress_Flag = "U".   
        END.  /* IF updatemode = YES  */  

    END.  /** 4 EACH RS.PATIENT_FILES **/    
        
END.  /** 4 EACH RS.TESTS_RESULT_RCD **/

DISPLAY  Tkount-1   "= RS.TESTS_RESULT_RCD" SKIP.
DISPLAY  Tkount-2   "= RS.TESTS_DETAIL_RCD" SKIP.
DISPLAY  Tkount-3   "= RS.TESTS_FM_SPECIMEN_RCD" SKIP.
DISPLAY  Tkount-4   "= RS.TESTS_HE_SPECIMEN_RATIOS_RCD" SKIP.
DISPLAY  Tkount-5   "= RS.TESTS_UTM_UEE_SPECIMEN_RCD" SKIP.
DISPLAY  PFkount-2  "= RS.PATIENT_FILES for TESTS data" SKIP.
/*                                                             */