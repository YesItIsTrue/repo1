repeat:

   create people_mstr.
   assign 
        people_ID = next-value(seq-people).
        
   update people_mstr except people_ID with 2 col.
   
end.

