for each mb_mstr where mb_name = "First Aid" no-lock,
        each sched_mstr where sched_bsa_id = mb_bsa_id no-lock:
        
        
        for each regis_mstr where regis_class_id = sched_class_id no-lock:
        
            display regis_class_id regis_people_id.
            
            find first people_mstr where people_id = regis_people_id no-lock no-error.
            
            if avail people_mstr then 
                display people_lastname people_firstname.
            else
                "X".
                
        end.
        
end.

/*
find regis_mstr where regis_people_id = 164 and regis_class_id = 131 exclusive-lock no-error.

if avail (regis_mstr) then 
    delete regis_mstr.
  */
  
    
    
/*
create regis_mstr.
assign
    regis_class_id = 112
    regis_people_id = 164.
  */
    
    
