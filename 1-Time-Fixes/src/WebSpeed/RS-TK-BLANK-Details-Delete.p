
/*------------------------------------------------------------------------
    File        : RS-TK-BLANK-Details-Delete.p
    Purpose     : 

    Syntax      :

    Description : One-time special cleanup since 4-2-16.

    Author(s)   : 
    Created     : Sat Jun 04 11:07:58 CDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE TEMP-TABLE tt
    FIELD LABSAMPLEid                      AS CHARACTER FORMAT "x(15)"
        INDEX temp-data AS PRIMARY LABSAMPLEid. 
        
DEFINE BUFFER TRRCD FOR RS.tests_result_rcd.

/* ***************************  Main Block  *************************** */
/****** SCRATCHPAD 146 *********/

DEFINE VARIABLE whichlabsample LIKE TESTS_RESULT_RCD.Lab_Sampleid NO-UNDO.

/*UPDATE SKIP(1)                                     */
/*            whichlabsample COLON 30 SKIP(1)        */
/*                 WITH FRAME a WIDTH 80 SIDE-LABELS.*/
/*                                                   */ 
INPUT FROM "C:\Progress\WRK\Book2a.txt".    /*  new o/p file from Dwights cleanup program:   */

    REPEAT:

        CREATE tt.
                                                                    
        IMPORT  tt.     

    END.  /** REPEAT **/ 
   
INPUT CLOSE.    

FOR EACH  tt NO-LOCK:
  DISPLAY tt.LABSAMPLEid.        
    FOR EACH RS.tests_result_rcd WHERE (Lab_Sampleid = tt.LABSAMPLEid) AND progress_flag <> "DL" 
            BY Test_Kit_Nbr DESC BY patientid BY progress_flag BY Lab_Sampleid BY Lab_Sampleid_SeqNbr : 
               
        IF  TESTS_RESULT_RCD.Test_Kit_Nbr <> "" AND TESTS_RESULT_RCD.Progress_Flag <> "D" THEN DO:
        
            FIND first TRRCD WHERE TRRCD.PatientID    = TESTS_RESULT_RCD.PatientID AND 
                    (TRRCD.Lab_Sampleid = TESTS_RESULT_RCD.lab_sampleid ) AND
                    trrcd.Lab_Sampleid_SeqNbr = TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr and
                    trrcd.Test_Abbv    = TESTS_RESULT_RCD.Test_Abbv AND 
                    TRRCD.Test_Kit_Nbr = ""  AND TRRCD.Progress_Flag = "D" AND                   
                    RECID(trrcd) <> RECID(tests_result_rcd) 
                    EXCLUSIVE-LOCK NO-ERROR.  
        
            IF AVAILABLE (TRRCD)  THEN           
/*            DISPLAY "TRRCD" SKIP TRRCD.patientid                                                      */
/*                TRRCD.Test_Kit_Nbr FORMAT "x(8)" TRRCD.Test_Abbv FORMAT "x(6)"                        */
/*                TRRCD.Lab_Sampleid FORMAT "x(15)" (COUNT) TRRCD.Lab_Sampleid_SeqNbr COLUMN-LABEL "Seq"*/
/*                TRRCD.Progress_Flag FORMAT "xx".                                                      */
                DELETE  TRRCD.              
        END. 

    END.  
END.  /* FOR EACH  tt */
