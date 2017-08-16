def var peep as int no-undo.
def var class as char format "X" extent 8 column-label "X" no-undo.
def var x as int no-undo.

for each attend_det no-lock
    break by attend_people_id by attend_class_id:

    if first-of(attend_people_id) then
        peep = peep + 1.

    x = x + 1.
       
    class[x] = "X".
    
    if last-of(attend_people_id) then do: 
    
        display attend_people_id attend_class_id attend_date 
            class skip.
        x = 0.
        
    end.
    
    
end.

message "Total People = " peep view-as alert-box information buttons ok.
        

   
