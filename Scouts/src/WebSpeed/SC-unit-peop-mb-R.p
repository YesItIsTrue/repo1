/**********************************************************************
 *
 *  SC-unit-peop-mb-R.p - Doug Luttrell - 04/Oct/15 - Version 1.0
 *
 *  ---------------------------------------------------------------
 * 
 *  Program shows all people by stake by unit and their MBs.
 *
 *  ---------------------------------------------------------------
 *
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 04/Oct/15.  Original version.
 *          Based on SCpeopunitR.p.
 *
 **********************************************************************/

/********************  Variable Definitions  **************************/
DEFINE VARIABLE outfile AS CHARACTER FORMAT "x(60)" LABEL "Output File"
    INITIAL "C:\progress\WRK\SC-unit-peop-mb-R.txt".

DEFINE STREAM outward.
    
OUTPUT stream outward to value(outfile).


/****************************  Main Code  ******************************/
FOR EACH people_mstr NO-LOCK,
    FIRST speop_shadow WHERE speop_shadow.speop_ID = people_mstr.people_id NO-LOCK 
    BREAK 
        BY speop_shadow.speop_stake 
        BY speop_shadow.speop_ward 
        BY people_mstr.people_lastname 
        BY people_mstr.people_firstname:
    
    IF FIRST-OF(speop_shadow.speop_ward) THEN DO:
    
        PAGE STREAM outward.
        DISPLAY STREAM outward SKIP(1) 
            speop_shadow.speop_stake FORMAT "x(24)" COLON 10 
            speop_shadow.speop_ward FORMAT "x(30)" COLON 50 SKIP(1)
                WITH FRAME unithead SIDE-LABELS WIDTH 132.
                
    END.  /** of if first-of people_unit **/
    
    DISPLAY STREAM outward
        people_mstr.people_ID
        people_mstr.people_lastname 
        people_mstr.people_firstname 
        people_mstr.people_dob 
        /*
        people_quorum
        people_member
        */
            WITH FRAME maindets WIDTH 132 DOWN.
    DOWN STREAM outward WITH FRAME maindets.     
    
    FOR EACH regis_mstr WHERE regis_mstr.regis_people_id = people_mstr.people_id NO-LOCK,
        FIRST sched_mstr WHERE sched_mstr.sched_class_id = regis_mstr.regis_class_id NO-LOCK,
        FIRST mb_mstr WHERE MB_mstr.mb_bsa_id = sched_mstr.sched_bsa_id NO-LOCK
            BREAK BY mb_name:
            
        DISPLAY STREAM outward MB_mstr.mb_name AT 15 sched_mstr.sched_period MB_mstr.mb_bsa_id SKIP
            WITH FRAME mbclasses DOWN.
        DOWN STREAM outward
            WITH FRAME mbclasses.
        
    END.  /** of 4ea. regis_mstr **/
    
            
END.  /** of 4ea. people_mstr **/

OUTPUT stream outward close.


/*****************************  End of File.  ***************************/
      

   
