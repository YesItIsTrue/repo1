def var foundone as int no-undo.
def var affectedtks as int no-undo.
DEFINE VARIABLE details AS INTEGER NO-UNDO.
DEFINE VARIABLE tot-len AS INTEGER NO-UNDO.
DEFINE VARIABLE found-WTH AS INTEGER NO-UNDO.

def var updatemode as log initial   NO      no-undo.

update skip(1) 
    updatemode colon 20 skip(1)
        with frame a width 80 side-labels.

pause 0 before-hide.

main-loop:
for each mpa_rcd where progress_flag <> "D" and 
    progress_flag <> "DL"
        exclusive-lock:

    tot-len = length(progress_flag).
    IF tot-len > 4 THEN 
        IF SUBSTRING(progress_flag, (tot-len - 3), tot-len) = "-WTH" THEN DO:
            found-WTH = found-WTH + 1.
            NEXT main-loop.
        END. 
                
    
    
    find tk_mstr where tk_id = mpa_test_kit_nbr and 
        tk_test_seq = integer(mpa_test_kit_nbr_seq) 
            no-lock no-error.
            
    if not avail (tk_mstr) then do: 
    
        foundone = 0.
        
        for each tk_mstr where tk_id = mpa_test_kit_nbr no-lock,
            first test_mstr where test_type = tk_test_type and 
                test_family = "MPA" no-lock:
                
            foundone = foundone + 1.
            
        end.  /** of for first **/
        
        if foundone = 0 then do:
        
            affectedtks = affectedtks + 1. 
            
            IF  updatemode = YES  THEN DO:  
                tot-len = length(MPA_RCD.progress_flag).
                IF tot-len > 1 THEN DO:
                    IF  MPA_RCD.progress_flag = "AL" THEN  
                        MPA_RCD.progress_flag = "A".
                    ELSE  IF  MPA_RCD.progress_flag = "IL" THEN  
                        MPA_RCD.progress_flag = "A".
                    ELSE  IF  MPA_RCD.progress_flag = "UL" THEN  
                        MPA_RCD.progress_flag = "U".
                    ELSE 
                        MPA_RCD.progress_flag = MPA_RCD.progress_flag + "-WTH".
                END.  /**  IF tot-len > 1  **/

               for each MPA_TEST_DETAILS_RCD WHERE 
                   MPA_TEST_DETAILS_RCD.MPA_Sample_ID_Number   = MPA_RCD.MPA_Sample_ID_Number  AND 
                   MPA_TEST_DETAILS_RCD.MPA_Sample_ID_SeqNbr   = MPA_RCD.MPA_Sample_ID_SeqNbr  AND
                   MPA_TEST_DETAILS_RCD.PatientID              = MPA_RCD.PatientID 
                       EXCLUSIVE-LOCK: 
                                
                    details = details + 1.
                    tot-len = length(MPA_TEST_DETAILS_RCD.progress_flag).
                    IF tot-len > 1 THEN DO:
                        IF  MPA_TEST_DETAILS_RCD.progress_flag = "AL" THEN  
                            MPA_TEST_DETAILS_RCD.progress_flag = "A".
                        ELSE  IF  MPA_TEST_DETAILS_RCD.progress_flag = "IL" THEN  
                            MPA_TEST_DETAILS_RCD.progress_flag = "A".
                        ELSE  IF  MPA_TEST_DETAILS_RCD.progress_flag = "UL" THEN  
                            MPA_TEST_DETAILS_RCD.progress_flag = "U".
                        ELSE 
                            MPA_TEST_DETAILS_RCD.progress_flag = MPA_TEST_DETAILS_RCD.progress_flag + "-WTH".
                    END.  /**  IF tot-len > 1  **/
                END.  /** 4ea.  (MPA_TEST_DETAILS_RCD) **/
                
            END.  /** IF  updatemode = YES **/
                                
            /* */ 
                DISPLAY  
                    MPA_RCD.mpa_test_kit_nbr FORMAT  "X(18)"
                    MPA_RCD.mpa_test_kit_nbr_seq 
                    MPA_RCD.MPA_Test_Type
                    mpa_rcd.patientid 
                    MPA_RCD.progress_flag format "X(12)" SKIP.            
            /* */
                
        end.  /** of if foundone = 0 **/            
                
    end.  /** of if not avail tk_mstr **/
        
end.    /** of 4ea. mpa_rcd **/

display affectedtks.
DISPLAY details.
DISPLAY found-WTH.
