/*************************************************************
 *
 *  MBresultsR.p - Doug Luttrell - 14/Sep/15 - Version 1.0
 *
 *  Shows which person got which MB requirements.
 *
 *  --------------------------------------------------------
 *  
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 14/Sep/15.  Original version.
 *  1.1 - written by DOUG LUTTRELL on 15/Aug/17.  Changes for the 
 *          new CMC structure (Version 12).  Not sure if this 
 *          should be updated, but tweaking it anyway.  Marked by 1dot1.
 *
 *************************************************************/


/******************  Variable Definitions  *********************/

DEFINE VARIABLE reqbin AS CHARACTER FORMAT "x(4)" EXTENT 10 NO-UNDO.
DEFINE VARIABLE compbin AS LOG EXTENT 10 NO-UNDO.
DEFINE VARIABLE x AS INTEGER NO-UNDO.                   /** junk counter for array **/
DEFINE VARIABLE y AS INTEGER NO-UNDO.

DEFINE VARIABLE outfile AS CHARACTER NO-UNDO.

FORM
    speop_shadow.speop_stake                                                                        /* 1dot1 */ 
    speop_shadow.speop_ward                                                                         /* 1dot1 */
    SKIP(1)
        WITH FRAME unithead WIDTH 80 SIDE-LABELS.

FORM
    people_lastname people_firstname people_DOB people_ID
    /* people_quorum people_member people_Tsize */
        WITH FRAME mainpeop WIDTH 132 DOWN.
  
FORM 
    mb_name COLON 10 mb_bsa_ID /* sched_instructor_id */ SKIP
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
             
        
/*********************   Main Block  ***********************/
FOR EACH speop_shadow NO-LOCK,                                                                                  /* 1dot1 */
    FIRST people_mstr WHERE people_mstr.people_id = speop_shadow.speop_ID NO-LOCK                               /* 1dot1 */
        BREAK   
            BY speop_shadow.speop_stake                                                                 /* 1dot1 */ 
            BY speop_shadow.speop_ward                                                                  /* 1dot1 */
            BY people_mstr.people_lastname                                                              /* 1dot1 */
            BY people_mstr.people_firstname:                                                            /* 1dot1 */        

        
   IF FIRST-OF(speop_shadow.speop_ward) THEN DO:                                                        /* 1dot1 */
   
        outfile = "C:\progress\wrk\MBresultsR-" + 
                    speop_shadow.speop_stake +                                                          /* 1dot1 */
                    CAPS(speop_shadow.speop_ward) + ".txt".                                             /* 1dot1 */
                    
        OUTPUT to value(outfile).            
                 
        DISPLAY speop_shadow.speop_stake speop_shadow.speop_ward                                        /* 1dot1 */
            WITH FRAME unithead.
        DOWN WITH FRAME unithead.
         
   END.  /** of if first-of(people_ward) **/
        
   DISPLAY people_lastname people_firstname people_dob people_ID
        /* people_quorum people_member people_Tsize */
            WITH FRAME mainpeop.
   DOWN WITH FRAME mainpeop.   
        
   FOR EACH regis_mstr WHERE regis_mstr.regis_people_id = people_mstr.people_id NO-LOCK,
        EACH sched_mstr WHERE sched_mstr.sched_class_id = regis_mstr.regis_class_id NO-LOCK,
        FIRST mb_mstr WHERE MB_mstr.mb_bsa_id = sched_mstr.sched_bsa_id NO-LOCK,
        EACH mbr_reqs WHERE MBR_reqs.mbr_bsa_id = MB_mstr.mb_bsa_ID NO-LOCK,
        EACH mbc_det WHERE MBC_det.mbc_people_id = regis_mstr.regis_people_id AND 
            MBC_det.mbc_class_id = regis_mstr.regis_class_id AND 
            MBC_det.mbc_req_nbr = MBR_reqs.mbr_req_nbr NO-LOCK
        BREAK BY MB_mstr.mb_name BY MBR_reqs.mbr_req_nbr:
            
        x = x + 1.    
        
        IF x = 11 THEN DO:
        
            x = 1.
            
            DISPLAY reqbin compbin
                WITH FRAME gorydets.
            DOWN WITH FRAME gorydets.        
            
            DO y = 1 TO 10:
                ASSIGN 
                    reqbin[y]   = ""
                    compbin[y]  = ?.
            END.  /** of y = 1 to 10 **/
            
        END.  /* of if x = 11 */
            
        IF FIRST-OF(MB_mstr.mb_name) THEN DO:        
            DISPLAY MB_mstr.mb_name MB_mstr.mb_bsa_ID /* sched_instructor_id */
                WITH FRAME mbhead.
            DOWN WITH FRAME mbhead.
        END.    /*** of if first-of(mbr_name) ***/
        
        ASSIGN
            reqbin[x]   = MBR_reqs.mbr_req_nbr
            compbin[x]  = MBC_det.mbc_completed.
            
        IF LAST-OF(mb_name) THEN DO:
            x = 0.
            
            DISPLAY reqbin compbin
                WITH FRAME gorydets.
            DOWN WITH FRAME gorydets.
            
            DO y = 1 TO 10:
                ASSIGN 
                    reqbin[y]   = ""
                    compbin[y]  = ?.
            END.  /** of y = 1 to 10 **/            
            
        END.  /*** of if last-of(mbr_name) ***/             
   
   END.  /*** of 4ea. regis_mstr, etc. ***/
   
   IF LAST-OF(speop_shadow.speop_ward) THEN 
        OUTPUT close.
   
END.  /*** of 4ea. people_mstr ***/


/*******************  End of File.  ******************/
   
   
   
   
   
   
