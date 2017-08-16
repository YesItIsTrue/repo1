/**********************************************************************
 *
 *  SCpeopunitR.p - Doug Luttrell - 27/Aug/15 - Version 1.0
 *
 *  ---------------------------------------------------------------
 * 
 *  Program shows all people by stake by unit.
 *
 *  ---------------------------------------------------------------
 *
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 27/Aug/15.  Original version.
 *
 **********************************************************************/

/********************  Variable Definitions  **************************/
DEFINE VARIABLE outfile AS CHARACTER FORMAT "x(60)" LABEL "Output File"
    INITIAL "C:\progress\WRK\SCpeopunitR.txt".

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
        speop_shadow.speop_quorum
        speop_shadow.speop_LDS
            WITH FRAME maindets WIDTH 132 DOWN.
    DOWN STREAM outward WITH FRAME maindets.     
            
END.  /** of 4ea. people_mstr **/

OUTPUT stream outward close.


/*****************************  End of File.  ***************************/
      

   
