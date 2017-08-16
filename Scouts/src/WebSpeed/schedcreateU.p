/********************
 *
 * schedcreateU.p
 *
 ********************/

def var mbname like mb_name no-undo.
def var period like sched_period no-undo.

main-loop:
repeat:

    update mbname period.
    
    find mb_mstr where mb_name = mbname no-lock no-error.
    
    if not avail (MB_mstr) then do:
     
         message "MB = " MBname " not found in database.  Please re-enter."
             view-as alert-box warning buttons ok.
             
         next main-loop.
    
    end.  /** of if not avail MB_mstr **/
         
    else do:

        find first sched_mstr where sched_bsa_id = mb_bsa_id and 
            sched_period = period no-lock no-error.
            
        if not avail sched_mstr then do:
        
            create sched_mstr.
            assign
                sched_bsa_id        = mb_bsa_id
                sched_period        = period
                sched_start_date    = 08/03/15
                sched_end_date      = 08/08/15
                sched_class_id      = next-value(seq-class).
                
        end.  /** of if not avail sched_mstr **/
    
    end.  /** of else do -- avail mb_mstr **/
    
end.  /** of repeat -- main-loop **/

/*************  EOF  **************/
