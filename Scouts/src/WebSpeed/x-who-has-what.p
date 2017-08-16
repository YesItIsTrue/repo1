for each attendance no-lock,
    first people_mstr where people_id = attend_people_id no-lock,
   first mb_classes where mb_class_id = attend_class_id no-lock
    break by mb_name by mb_period by people_lastname by people_firstname:
   
   display people_lastname (COUNT by mb_period)
        people_firstname format "x(12)" 
        mb_name format "x(12)" 
        mb_period
            with frame outward width 80 down.
        
   down with frame outward.
   
   if last-of(mb_period) then 
        down 1 with frame outward .
