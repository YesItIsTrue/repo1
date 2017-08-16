
/*------------------------------------------------------------------------
    File        : Step-8-extra-ISO-country.p
    Purpose     : 

    Syntax      :

    Description : Create extra "correct" (ISO to ISO) country records.

    Author(s)   : 
    Created     : Thu Feb 04 08:47:25 CST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

/* Step 8. */
DEFINE BUFFER c2 FOR country_mstr.

FOR EACH country_mstr WHERE country_mstr.country_primary = YES AND 
            NOT CAN-FIND(FIRST c2 WHERE c2.country_iso = country_mstr.country_iso AND 
                              c2.country_display_name = country_mstr.country_iso NO-LOCK) NO-LOCK:
    
     CREATE c2.
     ASSIGN 
          c2.country_iso = country_mstr.country_iso
          c2.country_display_name = country_mstr.country_iso
          c2.country_primary = NO
          c2.country_create_date = TODAY 
          c2.country_created_by = USERID("General")    
          c2.country_modified_date = TODAY 
          c2.country_modified_by = USERID("General")
          c2.country_prog_name = "SCRATCHPAD".
          
END.     /*** of 4ea. country_mstr, etc. ***/

  