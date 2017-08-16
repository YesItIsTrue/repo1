/*************** 
 *
 *  SCregiscreateU.p - Doug Luttrell - Version 0.1 - 11/Oct/15
 *
 ***************/

def var v-people_ID like people_id no-undo.
def var v-class_ID like sched_class_ID initial 138 no-undo.
def var v-MB_ID like mbr_bsa_id initial 900 no-undo.

repeat:

    update skip(1)
        v-people_ID colon 20
        v-class_ID colon 20
        v-MB_ID colon 20 skip(1)
            with frame a width 80 side-labels.

        
    find regis_mstr where regis_people_id = v-people_ID and 
        regis_class_ID = v-class_ID 
            no-lock no-error.
            
    if avail regis_mstr then 
        message "ERROR!  regis_mstr already exists for:" SKIP
            "People ID = " v-people_ID SKIP
            "Class ID = " v-class_ID SKIP
                view-as alert-box error buttons ok.
                
    else do: 
    
        create regis_mstr.
        assign 
            regis_people_id = v-people_id
            regis_class_id = v-class_id.
    
    end.    /* of else do --- if not avail regis_mstr */
    
end.  /** of repeat **/    
    
