/*******************************
 *
 *  MBunregisterU.p - Doug Luttrell - Version 1.0 - 11/Oct/15
 *             Trae & Doug Luttrell - Version 2.0 - 14/Sep/17
 *
 *  Deletes records from the regis_mstr for a specific person and MB.
 *  2.0 - lowers the seat count, and looks better.
 *******************************/

DEFINE VARIABLE updatemode AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-event_ID LIKE event_mstr.event_ID NO-UNDO.

REPEAT:


FOR EACH regis_mstr SHARE-LOCK,
    FIRST sched_mstr WHERE sched_mstr.sched_class_id = regis_mstr.regis_class_ID AND 
     sched_mstr.sched_event_ID = v-event_ID SHARE-LOCK,
    FIRST MB_mstr WHERE MB_mstr.MB_BSA_ID = sched_mstr.sched_BSA_ID NO-LOCK,
    FIRST people_mstr WHERE people_mstr.people_ID = regis_mstr.regis_people_ID NO-LOCK
        BREAK BY people_mstr.people_lastname BY people_mstr.people_firstname BY MB_mstr.MB_name:
            
            DISPLAY people_lastname people_firstname SKIP
            MB_name sched_period SKIP
             WITH FRAME a SIDE-LABELS WIDTH 80.
             
            UPDATE updatemode WITH FRAME a.
            
            IF updatemode = YES THEN DO:
                
                updatemode = NO.
                
                DELETE regis_mstr.
                
                sched_mstr.sched_used_seats = sched_used_seats - 1. 
                
            END. /*** UPDATEmode = YES ****/
            
        END. /*** 4ea ***/

END.   /** of repeat **/
