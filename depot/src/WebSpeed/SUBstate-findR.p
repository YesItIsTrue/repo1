/*------------------------------------------------------------------------
    File        : SUBstate-findR.p
    Purpose     : External find program for the state_mstr ISO data.

    Description : This is the external find country_mstr program for the ISO data.
                : Input is the country name or the abbreviated name.
                :
                : E.g.  Input = i-country =  ( state_country_ISO - e.g.  USA )
                :               i-state   =  ( state_display_name - e.g. FL or FLA or Florida).
                :      Output:
                :               o-state   =  (state-ISO  - e.g. FL). 
                :       and
                :               o-state-error = logical YES if data is found or logical NO if data is not found.
                :    
    Author(s)   : Harold Luttrell, Sr.
    Created     : Jan. 25, 2016
    Updated     : 
    Version     : 1.0
                     
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-country    LIKE state_mstr.state_country_ISO          NO-UNDO. 
DEFINE INPUT PARAMETER  i-state      LIKE state_mstr.state_display_name         NO-UNDO. 
 
DEFINE OUTPUT PARAMETER o-fstate-ISO     LIKE state_mstr.state_ISO              NO-UNDO.
DEFINE OUTPUT PARAMETER o-fstate-error   AS LOGICAL                                     NO-UNDO.

/* ***************************  Main Block  *************************** */
ASSIGN  o-fstate-ISO          = "Not Found"
        o-fstate-error        = YES.                       /* Error - no record found. */ 

FIND FIRST state_mstr WHERE    
              state_mstr.state_country_ISO  = i-country AND 
              state_mstr.state_display_name = i-state  
               AND
              state_mstr.state_deleted      = ?
        NO-LOCK NO-ERROR.   
        
IF  AVAILABLE (state_mstr) THEN    
    ASSIGN 
        o-fstate-ISO          = state_mstr.state_ISO
        o-fstate-error        = NO.                       /* NO-Error - record found. */    

/* **************************  END OF CODE  *************************** */
