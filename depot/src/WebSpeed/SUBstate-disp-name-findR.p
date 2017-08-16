/*------------------------------------------------------------------------
    File        : SUBstate-disp-name-findR.p
    Purpose     : External find program for the state_mstr ISO data.

    Description : This is the external find state_mstr program for the ISO data.
                : Input is the  state_country_ISO      and
                :               state_ISO.
                :
                : Output is the State Display Name.               :
                :
                : E.g.  Input: = 'USA'      and
                :              = 'AL' 
                :      Output:
                :           o-state-display-name = 'Alabama' ( State_ISO-display-name for displaying data.). 
                :           o-state-error = logical YES if data is found or logical NO if data is not found.
                :    
    Author(s)   : Harold Luttrell, Sr.
    Created     : Feb. 15, 2016
    Updated     : 
    Version     : 1.0
                     
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-state-country-ISO     LIKE state_mstr.state_country_ISO     NO-UNDO. 
DEFINE INPUT PARAMETER  i-state-ISO             LIKE state_mstr.state_ISO             NO-UNDO. 
 
DEFINE OUTPUT PARAMETER o-fstate-disp-name     LIKE state_mstr.state_display_name     NO-UNDO.
DEFINE OUTPUT PARAMETER o-fstate-disp-error    AS LOGICAL                                     NO-UNDO.

/* ***************************  Main Block  *************************** */
ASSIGN  o-fstate-disp-name         = "Not Found"
        o-fstate-disp-error        = YES.                       /* Error - no record found. */ 

FIND FIRST state_mstr WHERE    
              state_mstr.state_country_ISO  = i-state-country-ISO
               AND 
              state_mstr.state_ISO          = i-state-ISO
               AND 
              state_mstr.state_primary      = YES  
               AND
              state_mstr.state_deleted      = ?
        NO-LOCK NO-ERROR.   
        
IF  AVAILABLE (state_mstr) THEN    
    ASSIGN 
        o-fstate-disp-name      = state_mstr.state_display_name
        o-fstate-disp-error     = NO.                       /* NO-Error - record found. */    

/* **************************  END OF CODE  *************************** */
