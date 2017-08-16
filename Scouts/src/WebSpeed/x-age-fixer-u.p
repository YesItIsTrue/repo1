def var deaconmark as date initial "08/08/03" no-undo.
def var teachermark as date initial "08/08/01" no-undo.
def var priestmark as date initial "08/08/99" no-undo.
def var eldermark as date initial "08/03/96" no-undo.

def var calcquorum as char no-undo.


for each people_mstr:

   if (people_DOB <= deaconmark and 
            people_DOB > teachermark) then
        calcquorum = "Deacon".        
   else if (people_DOB <= teachermark and 
           people_DOB > priestmark) then
        calcquorum = "Teacher".
   else if (people_DOB <= priestmark and 
            people_DOB > eldermark) then
        calcquorum = "Priest".
   else
        calcquorum = "Error".

   display people_lastname people_firstname
        people_DOB people_quorum calcquorum
        with width 132.
        
   if people_DOB <> ? then 
        people_quorum = calcquorum.
