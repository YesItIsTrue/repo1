for each mpa_test_details_rcd where progress_flag <> "DL" : 

   if progress_flag = "AL" or progress_flag = "IL" then 
        progress_flag = "A".
   else if progress_flag = "UL" then 
        progress_flag = "U".
        
end.
