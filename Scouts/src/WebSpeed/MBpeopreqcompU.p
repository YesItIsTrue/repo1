/*************************************************************
 *
 *  MBpeoplereqcompU.p - Doug Luttrell - 11/Oct/15 - Version 1.0
 *
 *  Modify who completed which requirement.
 *
 *  --------------------------------------------------------
 *  
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 11/Oct/15.  Original version.
 *  1.1 - written by DOUG LUTTRELL on 15/Aug/17.  Changes for the 
 *          new CMC structure (Version 12).  Not sure if this 
 *          should be updated, but tweaking it anyway.  Marked by 1dot1.
 *
 *************************************************************/


/******************  Variable Definitions  *********************/

DEFINE VARIABLE v-people_ID LIKE people_ID NO-UNDO.
DEFINE VARIABLE v-mb_BSA_ID LIKE mb_BSA_ID NO-UNDO.

DEFINE VARIABLE reqbin AS CHARACTER FORMAT "x(4)" EXTENT 10 NO-UNDO.
DEFINE VARIABLE compbin AS LOG EXTENT 10 NO-UNDO.
DEFINE VARIABLE x AS INTEGER NO-UNDO.                   /** junk counter for array **/
DEFINE VARIABLE y AS INTEGER NO-UNDO.

DEFINE VARIABLE outfile AS CHARACTER INITIAL "C:\progress\wrk\MBpeoplereqcompU.txt" NO-UNDO.

FORM
    speop_shadow.speop_stake                                                                        /* 1dot1 */ 
    speop_shadow.speop_ward                                                                         /* 1dot1 */
    SKIP(1)
        WITH FRAME unithead WIDTH 80 SIDE-LABELS.

FORM
    people_mstr.people_lastname                                                                     /* 1dot1 */ 
    people_mstr.people_firstname                                                                    /* 1dot1 */
    people_mstr.people_DOB                                                                          /* 1dot1 */
    /* people_quorum people_member people_Tsize */
        WITH FRAME mainpeop WIDTH 132 DOWN
            TITLE ("Stake = " + speop_shadow.speop_stake + " | Ward = " + speop_shadow.speop_ward).     /* 1dot1 */
  
FORM 
    mb_name COLON 10 /* sched_instructor_id */ SKIP
        WITH FRAME mbhead SIDE-LABELS WIDTH 80 DOWN.
    
FORM    
    "Req Nbr" AT 10 
    reqbin[1] AT 20 reqbin[2] AT 25 
    reqbin[3] AT 30 reqbin[4] AT 35
    reqbin[5] AT 40 reqbin[6] AT 45 
    reqbin[7] AT 50 reqbin[8] AT 55
    reqbin[9] AT 60 reqbin[10] AT 65 SKIP
    "Complete?" AT 10
    compbin[1] AT 20 compbin[2] AT 25 
    compbin[3] AT 30 compbin[4] AT 35
    compbin[5] AT 40 compbin[6] AT 45 
    compbin[7] AT 50 compbin[8] AT 55
    compbin[9] AT 60 compbin[10] AT 65 SKIP(1)
        WITH FRAME gorydets-orig NO-LABELS NO-ATTR-SPACE WIDTH 132 DOWN.   
     
FORM    
    "Req Nbr" AT 10 
    reqbin[1] AT 21 reqbin[2] AT 30
    reqbin[3] AT 39 reqbin[4] AT 48
    reqbin[5] AT 57 reqbin[6] AT 66
    reqbin[7] AT 75 reqbin[8] AT 84
    reqbin[9] AT 93 reqbin[10] AT 102 SKIP
    "Complete?" AT 10
    compbin[1] AT 21 compbin[2] AT 30
    compbin[3] AT 39 compbin[4] AT 48
    compbin[5] AT 57 compbin[6] AT 66 
    compbin[7] AT 75 compbin[8] AT 84
    compbin[9] AT 93 compbin[10] AT 102 SKIP(1)
        WITH FRAME gorydets NO-LABELS NO-ATTR-SPACE WIDTH 132 DOWN. 
        
        /*
output to value(outfile).        
        */
        
        
UPDATE SKIP(1)
    v-people_ID COLON 20
    v-mb_BSA_ID COLON 20 SKIP(1)
        WITH FRAME a WIDTH 80 SIDE-LABELS.
        
/*********************   Main Block  ***********************/
FOR EACH people_mstr WHERE people_mstr.people_id = v-people_ID NO-LOCK,                                 /* 1dot1 */
    FIRST speop_shadow WHERE speop_shadow.speop_ID = people_mstr.people_id NO-LOCK                      /* 1dot1 */
        BREAK   
            BY speop_shadow.speop_stake                                                                 /* 1dot1 */ 
            BY speop_shadow.speop_ward                                                                  /* 1dot1 */
            BY people_mstr.people_lastname                                                              /* 1dot1 */
            BY people_mstr.people_firstname:                                                            /* 1dot1 */
        
        /*
   if first-of(people_ward) then do:
        display people_stake people_ward
            with frame unithead.
        down with frame unithead.
   end.  /** of if first-of(people_ward) **/
        */
        
   DISPLAY people_lastname people_firstname people_dob
        /* people_quorum people_member people_Tsize */
            WITH FRAME mainpeop.
   DOWN WITH FRAME mainpeop.   
        
   FOR EACH regis_mstr WHERE regis_people_id = people_id NO-LOCK,
        EACH sched_mstr WHERE sched_class_id = regis_class_id AND 
            sched_BSA_ID = v-mb_BSA_ID NO-LOCK,
        FIRST mb_mstr WHERE mb_bsa_id = sched_bsa_id NO-LOCK,
        EACH mbr_reqs WHERE mbr_bsa_id = mb_bsa_ID NO-LOCK,
        EACH mbc_det WHERE mbc_people_id = regis_people_id AND 
            mbc_class_id = regis_class_id AND 
            mbc_req_nbr = mbr_req_nbr 
        BREAK BY mb_name BY mbr_req_nbr:
        
        /*    
        x = x + 1.    
        
        if x = 11 then do:
        
            x = 1.
            
            display reqbin compbin
                with frame gorydets.
            down with frame gorydets.        
            
            do y = 1 to 10:
                assign 
                    reqbin[y]   = ""
                    compbin[y]  = ?.
            end.  /** of y = 1 to 10 **/
            
        end.  /* of if x = 11 */
          
            
        if first-of(mb_name) then do:        
            display mb_name /* sched_instructor_id */
                with frame mbhead.
            down with frame mbhead.
        end.    /*** of if first-of(mbr_name) ***/
        */
        
        DISPLAY mbr_req_nbr
            WITH FRAME fixhere WIDTH 80 DOWN OVERLAY
                TITLE mb_name.
        UPDATE mbc_completed
            WITH FRAME fixhere.
        DOWN WITH FRAME fixhere.
        
        /*
        assign
            reqbin[x]   = mbr_req_nbr
            compbin[x]  = mbc_completed.
            
            
        if last-of(mb_name) then do:
            x = 0.
            
            display reqbin compbin
                with frame gorydets.
            down with frame gorydets.
            
            do y = 1 to 10:
                assign 
                    reqbin[y]   = ""
                    compbin[y]  = ?.
            end.  /** of y = 1 to 10 **/            
            
        end.  /*** of if last-of(mbr_name) ***/             
   */
   END.  /*** of 4ea. regis_mstr, etc. ***/
   
END.  /*** of 4ea. people_mstr ***/

/*
output close.
*/
/*******************  End of File.  ******************/
   
   
   
   
   
   
