/************************
 *
 *  VF1-hunt-for-pats-R.p - Doug Luttrell - 16/Dec/14 - Version 1.0
 *
 ************************/

pause 0 before-hide.

def var LN-FN-DOB as int no-undo.
def var LN-FN as int no-undo.
def var catnames as int no-undo.

def var LFD-goodpat as int no-undo.
def var LFD-badpat as int no-undo.
def var missing-mpa as int no-undo.

def var reccount as int no-undo.
def var updatedob as int no-undo.

def var foundone as log no-undo.

def var blankdob as char initial "c:\progress\wrk\EY-blank-dob.txt" no-undo.
def stream fixdob.
output stream fixdob to value(blankdob).

put stream fixdob unformatted
    "PatientID" "|"
    "Good_DOB" "|"
    "Gender" skip.
    
def var outfile as char initial "c:\progress\wrk\EY-off-dob.txt" no-undo.
def stream outward.
output stream outward to value(outfile).

export stream outward delimiter ";"
    "ID" "Lastname" "Firstname" "Good DOB" "TKID" "Patient_ID" "Wrong DOB".
    
    

def var missingmpafile as char initial "c:\progress\wrk\EY-missing-mpa.txt" no-undo.
def stream mpaout.
output stream mpaout to value(missingmpafile).

export stream mpaout delimiter ";"
    "ID" "Lastname" "Firstname" "Good DOB" "TKID" "Batch_ID" 
    "EY_Number" "Patient_ID".



for each vf1_det where vf1_det.vf1_good_dob <> ? :

    reccount = reccount + 1.

    /**** Look by Lastname, Firstname, & DOB  ****/
    find patient_rcd where patlastname = vf1_lastname and 
        patfirstname = vf1_firstname and 
        patdob = vf1_good_dob no-lock no-error.
        
    if avail patient_rcd then do:
        
        LN-FN-DOB = LN-FN-DOB + 1.
    
        find first mpa_rcd where 
            mpa_rcd.mpa_sample_id_number = vf1_tkid_sampleid 
                no-lock no-error.
        
        if avail (mpa_rcd) then do:
        
            if mpa_rcd.patientid = patient_rcd.patientid then
                LFD-goodpat = LFD-goodpat + 1.
            
            else do:
            
                LFD-badpat = LFD-badpat + 1.
            
                display vf1_id vf1_lastname format "x(20)"
                    vf1_tkid_sampleid vf1_good_dob.
            
            end.  /** of else do -- bad patient on mpa **/
                
        end.  /** of if avail mpa_rcd **/
        
        else do:
        
            missing-mpa = missing-mpa + 1.
        
            export stream mpaout delimiter ";"
                vf1_id vf1_lastname vf1_firstname
                vf1_good_dob vf1_tkid_sampleid 
                vf1_batch_id
                vf1_ey_nbr
                patient_rcd.patientid.
                
        end.  /** of else do --- not avail mpa_rcd **/
        
    end.  /*** of if avail patient_rcd - LN-FN-DOB ***/
        
    else do:
    
        find patient_rcd where patlastname = vf1_lastname and
            patfirstname = (vf1_firstname + " " + vf1_middlename) and
            patdob = vf1_good_dob
                no-lock no-error.
                
        if avail (patient_rcd) then 
            catnames = catnames + 1.

            
        else do:
        
                /*
            find patient_rcd where patlastname = vf1_lastname and
                patfirstname = vf1_firstname no-lock no-error.
                
            if avail patient_rcd then 
                LN-FN = LN-FN + 1.
                */
                
            for each patient_rcd where 
                  patient_rcd.patlastname = vf1_det.vf1_lastname,
	       EACH MPA_RCD WHERE MPA_RCD.PatientID = PATIENT_RCD.PatientID and
	           mpa_rcd.mpa_sample_id_number = vf1_det.vf1_TKID_SampleID no-lock:
            
                assign 
                    updatedob    = updatedob + 1
                    foundone        = yes.

                export stream outward delimiter ";"
                    vf1_id 
                    vf1_lastname 
                    vf1_firstname 
                    vf1_good_dob 
                    vf1_tkid_sampleid
                    patient_rcd.patientid
                    patient_rcd.patdob.
                        
                if patient_rcd.patdob = ? then
                    put stream fixdob unformatted
                        patient_rcd.patientid "|"
                        vf1_good_dob format "99/99/9999" "|"
                        vf1_good_sex skip.
            
/**** un-rem and run to cleanup middlenames for just this subset of records and re-run to test ***
            
                IF INDEX(vf1_firstname," ") > 0 then do:
                
                    ASSIGN 
                        VF1_det.VF1_middlename  = SUBSTRING(vf1_firstname,INDEX(vf1_firstname," ") + 1)
                        VF1_det.vf1_firstname   = SUBSTRING(vf1_firstname,1,INDEX(vf1_firstname," ") - 1).
                       
        
                END. /** of 4ea. vf1_det **/

******* End of un-rem ****/
                                        
                    
            end.  /** of 4ea. patient_rcd - match on TKID **/
            
            if foundone = no then
                display vf1_id vf1_lastname format "x(20)"
                    vf1_firstname format "x(20)"
                    vf1_good_dob 
                    vf1_tkid_sampleid 
                        with frame b width 132 down.  
                        
             else 
                foundone = no.               
                
        end.  /** of else do --- if not avail patient_rcd FN-LN **/
           
   end. /* of else do --- not avail patient_rcd */
   
   /* if vf1_id = 7621 then  */
   

        
   
end.    /*** of 4ea. vf1_det ***/
   
   
output stream outward close.
output stream mpaout close.

display reccount skip
        LN-FN-DOB LFD-goodpat LFD-badpat missing-mpa 
        (LFD-goodpat + LFD-badpat + missing-mpa) skip
        catnames skip
        updatedob skip
        "----------" skip(1)        
        (reccount - LN-FN-DOB - catnames - updatedob) SKIP(1)
            with frame a down width 132.  

