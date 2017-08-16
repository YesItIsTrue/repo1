/*******************************
 *
 *  MBunregisterU.p - Doug Luttrell - Version 1.0 - 11/Oct/15
 *
 *  Deletes records from the regis_mstr for a specific person and MB.
 *
 *******************************/

def var v-people_id like people_id no-undo.
def var v-mb_name like mb_name format "x(30)" no-undo.

repeat:

update skIP(1)
    v-people_ID colon 20 
    v-mb_name colon 20 skip(1)
        with frame a width 80 side-labels.
        

for each mb_mstr where mb_name = v-mb_name no-lock,
    each sched_mstr where sched_bsa_id = mb_bsa_id no-lock,
    each regis_mstr where regis_class_id = sched_class_id,
    first people_mstr where people_id = regis_people_id and 
        people_id = v-people_ID no-lock:

   display regis_class_ID people_id people_lastname people_firstname
        with frame foundone width 80
            title mb_name.
   
   
   delete regis_mstr.
   
   
end.    /** of 4ea. mb_mstr, etc. **/

end.  /** of repeat **/
