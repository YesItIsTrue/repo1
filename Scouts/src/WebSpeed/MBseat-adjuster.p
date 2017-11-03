/*------------------------------------------------------------------------
    File        : MBseat-adjuster.p
    Purpose     : To manually adjust the seat count in any given class.

    Author(s)   : Trae Luttrell
    Created     : Thu Sep 14 14:32:11 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE v-event_ID LIKE event_mstr.event_ID INITIAL 20170923 NO-UNDO.


/* ***************************  Main Block  *************************** */
REPEAT:

    UPDATE v-event_ID WITH FRAME b.

    FOR EACH sched_mstr WHERE sched_mstr.sched_event_ID = v-event_ID,
        FIRST MB_mstr WHERE MB_mstr.MB_BSA_ID = sched_mstr.sched_BSA_ID NO-LOCK
        BREAK BY sched_mstr.sched_period BY MB_mstr.MB_name:
         
        DISPLAY MB_mstr.MB_name sched_mstr.sched_period sched_mstr.sched_total_seats sched_mstr.sched_used_seats WITH FRAME a WIDTH 80.
         
        UPDATE sched_mstr.sched_used_seats WITH FRAME a. 
    
    END. /*** 4ea sched_mstr ***/
    
END. /** REPEAT ***/