
/*------------------------------------------------------------------------
    File        : Fix-ISO-Country.p
    Purpose     : One-time program to re-build the General.country_mstr
                : within itsself, using the old current data to re-build
                : the table into the new ISO format. 

    Syntax      : If the data does not get built correctly, you must 
                : reload (Procopy) the old database and fix the program
                : are run again.  This should NOT happen.

    Description : Exports the country_mstr records to the
                : C:\PROGRESS\WRK\exports\country-ISO-cleanup.txt file.
                : It shows the before and after changes, just incase
                : you want to look at the data.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Jan 22, 2016. 
  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE STREAM outward.

DEFINE VARIABLE o-fcountry-ISO     LIKE General.country_mstr.Country_ISO                 NO-UNDO.   
DEFINE VARIABLE o-fcountry-error   AS LOGICAL                                            NO-UNDO. 

DEFINE VARIABLE i-country-name  LIKE General.country_mstr.Country_Display_Name NO-UNDO. 

OUTPUT STREAM outward TO "C:\PROGRESS\WRK\exports\country-ISO-cleanup.txt" APPEND.

/* ***************************  Main Block  *************************** */
 
/*ASSIGN i-country-name = "united states".     /*  za  */ */
/*                                                        */
/*RUN VALUE(SEARCH("SUBcountry-findR.r"))                 */
/*           (i-country-name,                             */
/*            OUTPUT o-fcountry-ISO,                      */
/*            OUTPUT o-fcountry-error).                   */
/*                                                        */
/*DISPLAY o-fcountry-ISO FORMAT "x(20)"  o-fcountry-error.*/

DEFINE BUFFER   h-country-buf  FOR General.country_mstr.
DEFINE VARIABLE new-country-disp-name     LIKE General.country_mstr.country_display_name NO-UNDO.
DEFINE VARIABLE new-country-ISO           LIKE General.country_mstr.country_ISO NO-UNDO.
DEFINE VARIABLE hold-old-country-display-name    LIKE General.country_mstr.country_display_name NO-UNDO.

FOR EACH General.country_mstr EXCLUSIVE-LOCK  BY country_display_name  BY country_ISO  :

    EXPORT STREAM outward DELIMITER ";" "before changes.".
    EXPORT STREAM outward DELIMITER ";"
                 General.country_mstr.
                     
    IF LENGTH(country_ISO) > 2 THEN
        ASSIGN  General.country_mstr.Country_Primary       = YES
                General.country_mstr.country_prog_name     = "ScratchPad code"
                General.country_mstr.country_modified_date = TODAY
                General.country_mstr.country_modified_by   = USERID("General").
    
    IF  General.country_mstr.country_display_name    = "UK" AND 
        General.country_mstr.country_ISO             = "UK" THEN 
            ASSIGN  General.country_mstr.country_display_name    = "Ukraine"
                    General.country_mstr.country_modified_date = TODAY.
                         
    IF  General.country_mstr.country_display_name    = "The Netherlands" OR 
        General.country_mstr.country_display_name    = "Hong Kong, China" OR 
        General.country_mstr.country_display_name    = "England" OR 
        General.country_mstr.country_display_name    = "Great Britain" OR 
        General.country_mstr.country_display_name    = "Macedonia" OR
        General.country_mstr.country_display_name    = "Shanghai China" OR 
        General.country_mstr.country_display_name    = "South Korea" OR 
        SUBSTRING(General.country_mstr.country_display_name, 1, 11) = "Venezuela, "  
         THEN 
            ASSIGN  General.country_mstr.Country_Primary       = YES
                    General.country_mstr.country_prog_name     = "ScratchPad code"
                    General.country_mstr.country_modified_date = TODAY
                    General.country_mstr.country_modified_by   = USERID("General").

    IF General.country_mstr.country_modified_date = TODAY THEN DO:     
        EXPORT STREAM outward DELIMITER ";" "after edit changes.".
        EXPORT STREAM outward DELIMITER ";"
                     General.country_mstr.
    END.  /*  IF General.country_mstr.country_modified_date = TODAY  */
                                             
    IF LENGTH(General.country_mstr.country_ISO) < 3 AND 
              General.country_mstr.Country_Primary = NO
      THEN DO:    
        ASSIGN  new-country-disp-name  = country_ISO
                hold-old-country-display-name = country_display_name
                new-country-ISO = country_ISO.
                   
        FIND h-country-buf WHERE h-country-buf.country_display_name = hold-old-country-display-name AND 
                                 h-country-buf.country_ISO <> new-country-disp-name
                     NO-LOCK NO-ERROR.
                     
        IF  AVAILABLE (h-country-buf) THEN /*  DO:  */   
            ASSIGN new-country-ISO     =   h-country-buf.country_ISO.
                              
        CREATE h-country-buf.
        
        ASSIGN h-country-buf.country_ISO           = new-country-ISO
               h-country-buf.country_display_name  = new-country-disp-name
               h-country-buf.Country_Primary       = NO  
               h-country-buf.country_prog_name     = "ScratchPad code"
               h-country-buf.country_modified_date = TODAY
               h-country-buf.country_modified_by   = USERID("General")
               h-country-buf.country_create_date   = TODAY
               h-country-buf.country_created_by    = USERID("General"). 
               
        EXPORT STREAM outward DELIMITER ";" "after country_ISO < 3.".
        EXPORT STREAM outward DELIMITER ";"
                 h-country-buf.
                     
    END.  /*  IF LENGTH(country_ISO) < 3  */
    
    EXPORT STREAM outward DELIMITER ";"
                 "".
END.  /*  4 ea.  */   

FOR EACH General.country_mstr WHERE LENGTH(country_ISO) < 3 AND 
             General.country_mstr.Country_Primary = NO 
         EXCLUSIVE-LOCK:
    DELETE General.country_mstr.
END.  /*  4 ea.  */
