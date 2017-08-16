/* 
for each patient_rcd where patientid = 6077 no-lock:

   display patlastname patfirstname patdob progress_flag format "XX"
        with 1 col title "From patient_rcd".
        
end.

for each people_mstr where people_id = 6077 no-lock:

   display people_lastname people_firstname people_dob
        with 1 col title "From people_mstr".
        
end.

*/

{C:\OpenEdge\workspace\depot\src\WebSpeed\Statuslist.i}.                                           /* 1dot5 */


for each tests_result_rcd where 
    (substring(tests_result_rcd.progress_flag,2,1) = "L" and 
     tests_result_rcd.progress_flag <> "DL") and 
    test_abbv <> "UTM/UEE" and 
    test_abbv <> "UTM / UEE" and 
    not can-find(first tk_mstr where tk_patient_id = int(patientid) and 
                    tk_lab_sample_id = lab_sampleID and 
                    tk_lab_seq = int(lab_sampleid_seqnbr) and 
                    tk_test_type = test_abbv and 
                    tk_id = test_kit_nbr and 
                    (lookup(tk_status,statlist) > 4) no-lock) no-lock,
    first patient_rcd where patient_rcd.patientid = tests_result_rcd.patientid no-lock:
                    
    display tests_result_rcd.patientid 
        Test_Kit_Nbr
        Lab_Sampleid Lab_Sampleid_SeqNbr test_abbv
        tests_result_rcd.progress_flag format "XX" 
        patlastname patfirstname patdob skip(1)
            with 1 col title "From RS".
            
end.


        
