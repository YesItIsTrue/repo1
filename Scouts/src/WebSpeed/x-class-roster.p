def var mbname like mb_name format "x(30)" no-undo.

update skip(1)
    mbname colon 20 skip(1)
        with frame whichmb width 80 side-labels title "Which MB?".
        
for each attendance no-lock,
    first people_mstr where people_id = attend_people_id no-lock,
    first mb_classes where mb_class_id = attend_class_id and 
        mb_name = mbname no-lock,
    each mbd_det where mbd_name = mb_name no-lock
        break by mb_name by mb_period 
            by people_lastname by people_firstname
            by mbd_req_nbr:
   
        display people_lastname people_firstname format "x(12)" 
            mb_period mbd_req_nbr
                with frame roster width 80 title "Class Roster" down.
        down with frame roster.
        

   
end.    /** of 4ea. attendance, etc. **/
