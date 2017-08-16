/*------------------------------------------------------------------------
    File        : SUBcountry-disp-name-findR.p
    Purpose     : External find program for the country_mstr ISO data.

    Description : This is the external find country_mstr program for the ISO data.
                : Input is the country-ISO.
                :
                : Output is the Country Display Name.
                :
                : E.g.  Input: = 'USA'
                :      Output:
                :           o-country-display-name = 'United States' ( Country_ISO-display-name for displaying data.). 
                :           o-country-error = logical YES if data is found or logical NO if data is not found.
                :    
    Author(s)   : Harold Luttrell, Sr.
    Created     : Feb. 15, 2016
    Updated     : 
    Version     : 1.0
                     
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-country-ISO           LIKE country_mstr.country_ISO           NO-UNDO. 

DEFINE OUTPUT PARAMETER o-fcountry-disp-name    LIKE country_mstr.country_display_name  NO-UNDO.
DEFINE OUTPUT PARAMETER o-fcountry-disp-error   AS LOGICAL                                      NO-UNDO.

/* ***************************  Main Block  *************************** */
ASSIGN  o-fcountry-disp-name         = "Not Found"
        o-fcountry-disp-error        = YES.                                     /* YES Error means no record found. */ 

FIND FIRST country_mstr WHERE    
              country_mstr.country_ISO = i-country-ISO 
               AND
              country_mstr.Country_Primary  = YES 
               AND 
              country_mstr.country_deleted      = ?
        NO-LOCK NO-ERROR.
               
IF  AVAILABLE (country_mstr) THEN    
    ASSIGN 
        o-fcountry-disp-name       = country_mstr.country_display_name
        o-fcountry-disp-error      = NO.                                        /* NO-Error means record found. */    

/* **************************  END OF CODE  *************************** */
