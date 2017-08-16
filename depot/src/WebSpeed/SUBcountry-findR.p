/*------------------------------------------------------------------------
    File        : SUBcountry-findR.p
    Purpose     : External find program for the country_mstr ISO data.

    Description : This is the external find country_mstr program for the ISO data.
                : Input is the country name or the abbreviated name.
                :
                : E.g.  Input: = US or U.S.A. or United States, etc.
                :      Output:
                :           o-country-ISO = 'USA' ( Country_ISO for data storage - not displaying data.). 
                :           o-country-error = logical YES if data is found or logical NO if data is not found.
                :    
    Author(s)   : Harold Luttrell, Sr.
    Created     : Jan. 21, 2016
    Updated     : 
    Version     : 1.0
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-country-name  LIKE country_mstr.Country_Display_Name  NO-UNDO. 

DEFINE OUTPUT PARAMETER o-fcountry-ISO          LIKE country_mstr.Country_ISO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-fcountry-error        AS LOGICAL                                      NO-UNDO.

/* ***************************  Main Block  *************************** */
ASSIGN  o-fcountry-ISO          = "Not Found"
        o-fcountry-error        = YES.                                          /* YES Error means no record found. */ 

FIND FIRST country_mstr WHERE    
              country_mstr.country_display_name = i-country-name 
               AND
              country_mstr.country_deleted      = ?
        NO-LOCK NO-ERROR.
               
IF  AVAILABLE (country_mstr) THEN    
    ASSIGN 
        o-fcountry-ISO          = country_mstr.Country_ISO
        o-fcountry-error        = NO.                                           /* NO-Error means record found. */    

/* **************************  END OF CODE  *************************** */
