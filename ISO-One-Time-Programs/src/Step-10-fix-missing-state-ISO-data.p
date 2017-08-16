
/*------------------------------------------------------------------------
    File        : Step-10-fix-missing-state-ISO-data.p
    Purpose     : 

    Syntax      :

    Description : Fix the missing state ISO data.

    Author(s)   : 
    Created     : Thu Feb 04 08:47:25 CST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */

/* Step 10 */
/* >>> ASSIGN  the General seq-state TO 4999 . */
           
DEFINE BUFFER s2 FOR state_mstr.

FOR EACH state_mstr WHERE state_mstr.state_primary = YES AND 
            NOT CAN-FIND(FIRST s2 WHERE s2.state_country_iso = state_mstr.state_country_iso AND 
                              s2.state_iso = state_mstr.state_iso AND 
                              s2.state_display_name = state_mstr.state_iso NO-LOCK) NO-LOCK:
    
     CREATE s2.
     ASSIGN 
          s2.state_stateID = NEXT-VALUE (seq-state)
          s2.state_country_iso = state_mstr.state_country_iso
          s2.state_iso = state_mstr.state_iso
          s2.state_display_name = state_mstr.state_iso
          s2.state_primary = NO
          s2.state_create_date = TODAY 
          s2.state_created_by = USERID("General")    
          s2.state_modified_date = TODAY 
          s2.state_modified_by = USERID("General")
          s2.state_prog_name = "SCRATCHPAD".
          
END.     /*** of 4ea. state_mstr, etc. ***/
   