for each people_mstr
    break by people_stake by people_ward
        by people_lastname by people_firstname:
        
    update people_stake format "x(24)" colon 20
        people_ward format "x(30)" colon 20
        people_lastname colon 20
        people_firstname colon 20
        people_dob colon 20
        people_quorum colon 20
        people_member colon 20
        people_Tsize colon 20
            with frame a width 80 side-labels.
            
    
end.
    

