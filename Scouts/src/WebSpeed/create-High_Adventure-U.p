def var v-people_ID like people_ID label "Attendee" no-undo.
def var yousure as log label "Are you sure?" initial no no-undo.
def var whatclass like MBC_class_ID initial 104 label "Class Number" no-undo.
def var mbid like MB_BSA_ID initial 019 no-undo.


main-loop:
repeat:

    update v-people_ID.
    
    find people_mstr where people_ID = v-people_ID no-lock no-error.
    
    if not avail (people_mstr) then do:
    
        message "Invalid person.  Try again.".
        next main-loop.
    
    end.  /** of if not avail people_mstr **/
    
    else do:
    
        display people_lastname people_firstname.
        
        update yousure.
        
        if yousure = yes then do:
        
            create attend_det.
            assign
                attend_people_id    = people_id
                attend_class_id     = whatclass
                attend_date         = 08/03/15
                attend_present      = YES.
 
            for each mbr_reqs where mbr_bsa_id = mbid no-lock:
            
                create MBC_det.
                assign
                    MBC_people_ID   = people_id
                    MBC_class_ID    = attend_class_ID
                    MBC_Req_nbr     = mbr_req_nbr
                    MBC_completed   = YES.
                    
            end.  /** of 4ea. mbr_reqs --- create mbc_det **/
        
        end. /** of if yousure = yes **/
        
        else do:
        
            next main-loop.
            
        end.  /** of else do -- yousure = no **/
        
   end.  /** of else do --- people_mstr avail **/
   
end. /** of repeat ---- main-loop **/


/*********************  End of File.  *******************/
        
        

