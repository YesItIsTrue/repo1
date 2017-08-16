
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

/* Step 9 */

DEFINE VARIABLE v-country_iso LIKE state_mstr.state_country_iso NO-UNDO.
/*DEFINE VARIABLE v-country_display-name LIKE country_mstr.country_display_name NO-UNDO.*/
/*DEFINE VARIABLE v-country_primary    LIKE country_mstr.Country_Primary NO-UNDO.       */
DEFINE VARIABLE v-error AS LOG NO-UNDO.

FOR EACH state_mstr: 
    
    RUN VALUE("SUBcountry-findR.p")
         (state_mstr.state_country_iso,
          OUTPUT v-country_iso,
/*          OUTPUT v-country_display-name,*/
/*          OUTPUT v-country_primary  ,   */
          OUTPUT v-error).
          
    IF v-error = NO THEN DO:

         ASSIGN 
              state_mstr.state_country_iso = v-country_iso
              state_mstr.state_primary = YES
              state_mstr.state_create_date = TODAY 
              state_mstr.state_created_by = USERID("General")    
              state_mstr.state_modified_date = TODAY 
              state_mstr.state_modified_by = USERID("General")
              state_mstr.state_prog_name = "SCRATCHPAD".
    
    END.  /* IF v-error = NO */     
                     
END.  /** OF 4ea. state_mstr **/
             
                     
/*           IF  state_mstr.state_country_ISO = "USA" AND 
                    LENGTH(state_mstr.state_iso) = 2 THEN DO:
                                CREATE s2.
                                ASSIGN s2.state_country_iso = v-country_iso
                                       s2.state_ISO = state_mstr.state_ISO
                                       s2.state_display_name = state_mstr.state_ISO
                      s2.state_primary = NO 
                      s2.state_create_date = today
                              s2.state_created_by = USERID("General")    
                    s2.state_modified_date = today
                    s2.state_modified_by = USERID("General")
                    s2.state_prog_name = "SCRATCHPAD".
                                             
                END.  /* IF  state_mstr.state_country_ISO = "USA" and LENGTH(state_mstr.state_iso) = 2 */        
*/
 