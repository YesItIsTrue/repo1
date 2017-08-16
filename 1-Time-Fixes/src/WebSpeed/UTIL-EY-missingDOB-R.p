/*********************
 *
 *  EY-misssingDOB-R.p - Doug Luttrell - 17/Dec/14 - Version 1.0
 *
 *********************/
 
 def var outfile as char initial "C:\progress\wrk\EY-missingDOB.txt" no-undo.
 
 def stream outward.
 output stream outward to value(outfile).
 
 export stream outward delimiter ";"
    "ID" "Lastname" "Firstname" "Bad DOB" "Good DOB" "TKID".
    
 for each vf1_det where vf1_good_dob = ? no-lock:
 
    export stream outward delimiter ";"
        vf1_id 
        vf1_lastname 
        vf1_firstname 
        vf1_bad_dob 
        vf1_good_dob 
        vf1_tkid_sampleid.
        
 end.  /** of 4ea. vf1_det **/
 
 output stream outward close.
 
 
 /*****************  EOF ******************/
 
