/*****************************
 *
 *  SCpeop-delU.p - Doug Luttrell - Version 1.0 - 27/Sep/15
 *
 *  ----------------------------------------------------------
 *
 *  Deletes people from the people_mstr and associated records
 *  from the attend_det, mbc_det, & regis_mstr.
 *
 *****************************/

def var v-people_ID like people_ID label "Person to Delete" no-undo.
def var yousure as log label "Are you sure?" initial NO no-undo.

form skip(1)
    v-people_id colon 20
    people_mstr.people_lastname colon 20 people_mstr.people_firstname colon 50
    yousure colon 20
        with frame a width 80 side-labels.

main-loop:
repeat:

    update v-people_ID
        with frame a.
        
    find people_mstr where people_id = v-people_ID exclusive-lock no-error.
    
    if not avail (people_mstr) then do:
    
        message "People ID = " v-people_ID " not found.  Please re-enter.".
        next main-loop.
        
    end.  /** of if not avail people_mstr **/
    
    else do:
    
        display people_lastname people_firstname 
            with frame a.
        update yousure with frame a.
        
        if yousure = YES then do:
        
            for each attend_det where attend_people_ID = people_ID:
                delete attend_det.
            end.  /** of 4ea. attend_det **/
            
            for each mbc_det where mbc_people_ID = people_ID:
                delete mbc_det.
            end.  /*** of 4ea. mbc_det ***/
            
            for each regis_mstr:
                delete regis_mstr.
            end.  /** of 4ea. regis_mstr **/
            
            delete people_mstr.
            
            assign
                yousure = NO.
                
        end.  /** of if yousure = yes **/
            
   end. /** of else do **/
   
end.  /*** of repeat --- main-loop ***/
