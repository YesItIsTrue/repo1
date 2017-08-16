/* 
display current-value(seq-people).
*/



for each people_mstr
    break by people_stake by people_ward by people_lastname by people_firstname:

   
   display people_Stake format "X"
        people_ward format "x(12)"
        people_lastname people_firstname 
        people_id
            with frame dets width 80 down title "People List".
   down with frame dets.     
        
   if last-of(people_ward) then 
        down 1 with frame dets .     
        
end.
   

   
