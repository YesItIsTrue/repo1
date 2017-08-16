/**********************************************************************
 *
 *  SCpeopreqsR.p - Doug Luttrell - 27/Aug/15 - Version 1.0
 *
 *  ---------------------------------------------------------------
 * 
 *  Program shows all people by stake by unit and what they have for 
 *  MB requirements.
 *
 *  ---------------------------------------------------------------
 *
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 27/Aug/15.  Original version.
 *
 **********************************************************************/

/********************  Variable Definitions  **************************/
def var outfile as char format "x(60)" label "Output File"
    initial "C:\progress\WRK\SCpeopreqsR.txt".

def stream outward.
    
output stream outward to value(outfile).


/****************************  Main Code  ******************************/
for each people_mstr no-lock
    break by people_stake by people_ward 
        by people_lastname by people_firstname:
    
    if first-of(people_ward) then do:
    
        page stream outward.
        display stream outward skip(1) 
            people_stake format "x(24)" colon 10 
            people_ward format "x(30)" colon 50 skip(1)
                with frame unithead side-labels width 132.
                
    end.  /** of if first-of people_unit **/
    
    display stream outward
        people_lastname people_firstname 
        people_dob people_quorum
        people_member
            with frame maindets down.
    down stream outward with frame maindets.  
    
    for each regis_mstr where regis_people_id = people_id no-lock,
        each sched_mstr where sched_class_id = regis_class_id no-lock,
        first mb_mstr where mb_bsa_id = sched_bsa_id no-lock,
        each mbr_reqs where mbr_bsa_id = mb_bsa_id no-lock
        /*
        each mbc_det where mbc_people_id = regis_people_id and 
            mbc_class_id = sched_class_id no-lock
        */
        break by mb_name by mbr_req_nbr:
        
        display stream outward mb_name mbr_req_nbr mbr_ORgroup mbr_ORqty.
        
    end.
            
end.  /** of 4ea. people_mstr **/

output stream outward close.


/*****************************  End of File.  ***************************/
      

   
