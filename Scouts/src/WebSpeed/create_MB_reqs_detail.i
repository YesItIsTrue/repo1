for each MB_mstr where MB_name = "{1}" no-lock,
     first sched_mstr where sched_bsa_id = mb_bsa_id and 
         sched_period = classlist[x] no-lock,
     each mbr_reqs where mbr_bsa_id = mb_bsa_id no-lock
         break by mb_name:
    
     if first-of(mb_name) then do:
         create regis_mstr.
         assign
             regis_people_id = people_id
             regis_class_ID  = sched_class_ID.
     end.  /*** of if first-of mb_name ***/
    
     find mbc_det where mbc_people_id = people_id and 
         mbc_class_id = sched_class_id and 
         mbc_req_nbr = mbr_req_nbr 
             exclusive-lock no-error.
             
     if not avail (Mbc_det) then do:
         create MBC_det.
         assign 
             MBC_people_ID   = people_ID
             MBC_class_ID    = sched_class_ID
             MBC_Req_Nbr     = mbr_req_nbr.
     end.
     
     assign         
         MBC_completed   = yes.
    
end.  /** of 4ea. MB_mstr **/   
