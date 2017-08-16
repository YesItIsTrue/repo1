
/*------------------------------------------------------------------------
    File        : BLANKset.p
    Purpose     : Data clean up

    Syntax      :

    Description : Filters test types and Testkit IDs and then correct data in the TK_mstr.
                  It also flags TK_mstr.TK_deleted for the bad duplicate records.

    Author(s)   : Jacob Luttrell
    Created     : Tue Jun 21 14:33:15 MDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE a          AS INTEGER NO-UNDO.
DEFINE VARIABLE b          AS INTEGER NO-UNDO.
DEFINE VARIABLE updatemode AS LOGICAL INITIAL YES NO-UNDO.
DEFINE VARIABLE vf1type    LIKE VF1_det.VF1_TKID_SampleID NO-UNDO.
DEFINE VARIABLE mpatype    LIKE MPA_RCD.MPA_Test_Type NO-UNDO.
DEFINE VARIABLE v-tk       LIKE TK_mstr.TK_ID NO-UNDO.   
DEFINE VARIABLE deleted    AS LOGICAL NO-UNDO.

DEFINE BUFFER tk_buff FOR TK_mstr. 

DEFINE TEMP-TABLE count_mstr 
    FIELD newseq    LIKE TK_mstr.TK_test_seq 
    FIELD labid     LIKE TK_mstr.TK_lab_sample_ID
    FIELD labseq    LIKE TK_mstr.TK_lab_seq
    FIELD tkid      LIKE TK_mstr.TK_ID
    FIELD patid     LIKE TK_mstr.TK_patient_ID
    FIELD newttype  LIKE TK_mstr.TK_test_type
    FIELD oldttype  LIKE TK_mstr.TK_test_type
    FIELD newid     LIKE TK_mstr.TK_ID.

DEFINE BUFFER count_buff FOR count_mstr. 
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
OUTPUT TO "C:\PROGRESS\WRK\BLANKset.txt".

EXPORT DELIMITER ";"
    "TK ID"
    "Lab ID"
    "Lab Seq"
    "Pat ID" 
    "New Test Type"
    "Old Test Type"
    "New ID"
    "New Test Seq"
    "Deleted?".

FOR EACH TK_mstr WHERE TK_mstr.TK_test_type = "BLANK" NO-LOCK:
    
    FOR EACH tk_buff WHERE tk_buff.TK_patient_ID = TK_mstr.TK_patient_ID AND
        TK_buff.TK_lab_sample_ID = TK_mstr.TK_lab_sample_ID AND
        TK_buff.TK_test_type <> TK_mstr.TK_test_type AND
        tk_buff.tk_deleted = ?
        NO-LOCK,
        FIRST test_mstr WHERE test_mstr.test_type = tk_buff.tk_test_type AND 
        test_mstr.test_family = "MPA" AND 
        test_mstr.test_deleted = ? NO-LOCK:          
         
        FIND count_mstr WHERE count_mstr.labid = tk_mstr.TK_lab_sample_ID AND count_mstr.patid = TK_mstr.TK_patient_ID EXCLUSIVE-LOCK NO-ERROR.
        
        IF NOT AVAILABLE (count_mstr) THEN 
        DO:
            
            CREATE count_mstr.
            
            ASSIGN         
                count_mstr.newseq   = count_mstr.newseq + 1
                count_mstr.tkid     = TK_buff.TK_ID
                count_mstr.labid    = tk_buff.TK_lab_sample_ID
                count_mstr.labseq   = tk_buff.TK_lab_seq
                count_mstr.patid    = tk_buff.TK_patient_ID
                count_mstr.newttype = TK_buff.TK_test_type
                count_mstr.oldttype = tk_mstr.TK_test_type.
                   
        END. /* if not avail count_mstr */
        ELSE 
        DO:
    
            IF INDEX(count_mstr.tkid,"-") > 0 THEN
            
                ASSIGN 
                    count_mstr.tkid = tk_buff.TK_ID.   
                    
            IF count_mstr.newttype = "BLANK" AND TK_mstr.TK_test_type <> "BLANK" THEN 
                
                ASSIGN 
                    count_mstr.newttype = TK_mstr.TK_test_type.         
     
        END. /* else do (avail count_mstr) */
   
    END. /* 4ea. tk_buff */
       
END. /* 4ea TK_mstr */

FOR EACH count_mstr 
    EXCLUSIVE-LOCK BREAK BY count_mstr.labid:
                    
        
    IF INDEX(count_mstr.tkid,"-") = 0 THEN     
        ASSIGN 
            count_mstr.newid = count_mstr.tkid + "-BLANK-OAH".

    ELSE 
        ASSIGN 
            count_mstr.newid = count_mstr.tkid.                   

   

    FOR EACH TK_mstr WHERE TK_mstr.TK_patient_ID = count_mstr.patid AND
        TK_mstr.TK_lab_sample_ID = count_mstr.labid 
        EXCLUSIVE-LOCK BREAK BY TK_mstr.TK_ID:

        IF updatemode = YES THEN
        DO:

            deleted = ?.

            IF INDEX(TK_mstr.TK_ID,"-") = 0 THEN
    
                ASSIGN
                    TK_mstr.TK_deleted       = TODAY
                    TK_mstr.TK_prog_name     = THIS-PROCEDURE:FILE-NAME
                    TK_mstr.TK_modified_by   = USERID ("HHI")
                    TK_mstr.TK_modified_date = TODAY
                    deleted                  = YES.
    
            ELSE
    
                ASSIGN
                    TK_mstr.TK_test_type     = count_mstr.newttype
                    TK_mstr.TK_ID            = count_mstr.newid
                    TK_mstr.TK_test_seq      = 1
                    TK_mstr.TK_prog_name     = THIS-PROCEDURE:FILE-NAME
                    TK_mstr.TK_modified_by   = USERID ("HHI")
                    TK_mstr.TK_modified_date = TODAY
                    deleted                  = NO.
        
        END. /* updatemode */
        
        EXPORT DELIMITER ";"
            count_mstr.tkid        
            count_mstr.labid
            count_mstr.labseq
            count_mstr.patid
            TK_mstr.TK_test_type
            count_mstr.oldttype
            TK_mstr.TK_ID
            TK_mstr.TK_test_seq
            deleted.
                                   
    END.  /* 4ea. TK_mstr */
    
            
END. /* 4ea. count_mstr */
 
OUTPUT CLOSE.


