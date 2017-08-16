/*************************************
 *
 * MBcompcreateU.p - Doug Luttrell - Version 1.0 - 11/Oct/15
 *
 * Creates MBC_det records for a specific person if they have
 * been registered in the regis_mstr.
 *
 *************************************/
 
 def var v-people_ID like people_ID no-undo.
 def var v-BSA_ID like MBR_BSA_ID no-undo.
 
 repeat:
 
 update skip(1)
    v-people_ID colon 20
    v-BSA_ID colon 20 skip(1)
        with frame a width 80 side-labels.
        
 for each people_mstr where people_id = v-people_ID no-lock,
    each regis_mstr where regis_people_id = people_id no-lock,
    each sched_mstr where sched_class_id = regis_class_ID no-lock,
    first mb_mstr where mb_BSA_ID = sched_bsa_id and 
        mb_BSA_ID = v-bsa_ID no-lock,
    each mbr_reqs where mbr_BSA_ID = mb_BSA_ID no-lock:
    
    find mbc_det where mbc_people_id = people_id and 
        mbc_class_id = regis_class_id and
        mbc_req_nbr = mbr_req_nbr
            exclusive-lock no-error.
            
    if not avail (mbc_det) then do: 
    
        create mbc_det.
        assign 
            mbc_people_id   = people_id
            mbc_class_id    = regis_class_id
            mbc_req_nbr     = mbr_req_nbr
            mbc_completed   = YES.
            
        display mbc_det
            with frame mbres width 80 down
                title (people_lastname + ", " + people_firstname).
        down with frame mbres.
            
    end.    /** of if not avail mbc_det **/
    
    else do:
       
        display mbc_det
            with frame mbres width 80 down
                title (people_lastname + ", " + people_firstname).       
        update mbc_completed
            with frame mbres.
        down with frame mbres.
       
    end.
    
end.  /** of 4ea. people_mstr, etc. **/


end.  /** of repeat **/

    
