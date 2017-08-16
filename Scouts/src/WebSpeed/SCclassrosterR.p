/******************************
 *
 *  SCclassrosterR.p - Doug Luttrell - 06/Nov/15 - 1.0
 *
 ******************************/
 

def var mbname like mb_name no-undo.


main-loop:
repeat:

update skip(1)
    mbname colon 20 skip(1)
        with frame a width 80 side-labels.
        
output to "\\ss-dc-1\ss-prt-color".        
        
   for each mb_mstr where mb_name = mbname no-lock,
        each sched_mstr where sched_bsa_id = mb_bsa_id no-lock,
        each regis_mstr where regis_class_id = sched_class_id no-lock,
        first people_mstr where people_id = regis_people_id no-lock
            break by regis_class_id by people_lastname by people_firstname:
            
        display 
            regis_class_id 
            people_lastname (COUNT by regis_class_id) 
            people_firstname
            people_ID
                with frame outward width 80 down 
                    title "Class Roster for " + mb_name.
        down with frame outward. 
        
   end. /** of 4ea. mb_mstr, etc. **/
   
output close.
     
end.    /** of repeat --- main-loop **/

/******************************  END OF FILE  ******************************/
