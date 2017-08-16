
/*------------------------------------------------------------------------
    File        : Fix-ISO-State.p
    Purpose     : One-time program to re-build the General.state_mstr
                : within itsself, using the old current data to re-build
                : the table into the new ISO format. 

    Syntax      : If the data does not get built correctly, you must 
                : reload (Procopy) the old database and fix the program
                : are run again.  This should NOT happen.

    Description : Exports the state_mstr records to the
                : C:\PROGRESS\WRK\exports\state-ISO-cleanup.txt file.
                : It shows the before and after changes, just incase
                : you want to look at the data.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Jan 25, 2016.
 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE STREAM outward.

DEFINE VARIABLE o-fstate-ISO     LIKE General.state_mstr.state_ISO              NO-UNDO.   
DEFINE VARIABLE o-fstate-error   AS LOGICAL                                     NO-UNDO. 

DEFINE VARIABLE i-country-ISO   LIKE general.state_mstr.state_country_ISO       NO-UNDO.
DEFINE VARIABLE i-state-name    LIKE General.state_mstr.state_Display_Name      NO-UNDO. 

OUTPUT STREAM outward TO "C:\PROGRESS\WRK\exports\state-ISO-cleanup.txt" APPEND.

/* ***************************  Main Block  *************************** */
/*                                                                 */
/*ASSIGN  i-state-name = "Florida"                                 */
/*        i-country-ISO = "US".                                    */
/*                                                                 */
/*RUN VALUE(SEARCH("SUBstate-findR.r"))                            */
/*           (i-country-ISO,                                       */
/*            i-state-name,                                        */
/*            OUTPUT o-fstate-ISO,                                 */
/*            OUTPUT o-fstate-error).                              */
/*                                                                 */
/*DISPLAY i-country-ISO FORMAT "x(10)"  i-state-name FORMAT "x(10)"*/
/*        o-fstate-ISO FORMAT "x(10)"  o-fstate-error.             */

DEFINE BUFFER   h-state-buf  FOR General.state_mstr.
DEFINE VARIABLE new-state-disp-name     LIKE General.state_mstr.state_display_name NO-UNDO.
DEFINE VARIABLE new-state-ISO           LIKE General.state_mstr.state_ISO NO-UNDO.
DEFINE VARIABLE hold-old-state-display-name    LIKE General.state_mstr.state_display_name NO-UNDO.

FOR EACH General.state_mstr EXCLUSIVE-LOCK  BY state_display_name  BY state_country_ISO  :

    EXPORT STREAM outward DELIMITER ";" "before changes.".
    EXPORT STREAM outward DELIMITER ";"
                 General.state_mstr.
                 
    IF  General.state_mstr.state_country_ISO    = "CA"  THEN
            ASSIGN  General.state_mstr.state_country_ISO    = "CAN".

    IF  General.state_mstr.state_country_ISO    = "US"  THEN
            ASSIGN  General.state_mstr.state_country_ISO    = "USA".
    
    IF  General.state_mstr.state_ISO = "" AND 
        General.state_mstr.state_display_name = "" THEN 
            ASSIGN  General.state_mstr.state_ISO            = state_mstr.state_country_ISO
                    General.state_mstr.state_display_name   = state_mstr.state_country_ISO.
                                          
/*    IF LENGTH(state_mstr.state_country_ISO) > 2 THEN*/
        ASSIGN  General.state_mstr.state_Primary       = YES
                General.state_mstr.state_prog_name     = "ScratchPad code"
                General.state_mstr.state_modified_date = TODAY
                General.state_mstr.state_modified_by   = USERID("General").

/*                                                                               */
/*    IF  General.state_mstr.state_display_name    = "The Netherlands" OR        */
/*        General.state_mstr.state_display_name    = "Hong Kong, China" OR       */
/*        General.state_mstr.state_display_name    = "England" OR                */
/*        General.state_mstr.state_display_name    = "Great Britain" OR          */
/*        General.state_mstr.state_display_name    = "Macedonia" OR              */
/*        General.state_mstr.state_display_name    = "Shanghai China" OR         */
/*        General.state_mstr.state_display_name    = "South Korea" OR            */
/*        SUBSTRING(General.state_mstr.state_display_name, 1, 11) = "Venezuela, "*/
/*         THEN                                                                  */
/*            ASSIGN  General.state_mstr.state_Primary       = YES               */
/*                    General.state_mstr.state_prog_name     = "ScratchPad code" */
/*                    General.state_mstr.state_modified_date = TODAY             */
/*                    General.state_mstr.state_modified_by   = USERID("General").*/

    IF General.state_mstr.state_modified_date = TODAY THEN DO:
        EXPORT STREAM outward DELIMITER ";" "after edit changes.".
        EXPORT STREAM outward DELIMITER ";"
                     General.state_mstr.
    END.  /*  IF General.state_mstr.state_modified_date = TODAY  */

/*    IF LENGTH(General.state_mstr.state_ISO) < 3 AND                                            */
/*              General.state_mstr.state_Primary = NO                                            */
/*      THEN DO:                                                                                 */
/*        ASSIGN  new-state-disp-name  = state_ISO                                               */
/*                hold-old-state-display-name = state_display_name                               */
/*                new-state-ISO = state_ISO.                                                     */
/*                                                                                               */
/*        FIND h-state-buf WHERE h-state-buf.state_display_name = hold-old-state-display-name AND*/
/*                                 h-state-buf.state_ISO <> new-state-disp-name                  */
/*                     NO-LOCK NO-ERROR.                                                         */
/*                                                                                               */
/*        IF  AVAILABLE (h-state-buf) THEN /*  DO:  */                                           */
/*            ASSIGN new-state-ISO     =   h-state-buf.state_ISO.                                */
/*                                                                                               */
/*        CREATE h-state-buf.                                                                    */
/*                                                                                               */
/*        ASSIGN h-state-buf.state_ISO           = new-state-ISO                                 */
/*               h-state-buf.state_display_name  = new-state-disp-name                           */
/*               h-state-buf.state_Primary       = NO                                            */
/*               h-state-buf.state_prog_name     = "ScratchPad code"                             */
/*               h-state-buf.state_modified_date = TODAY                                         */
/*               h-state-buf.state_modified_by   = USERID("General")                             */
/*               h-state-buf.state_create_date   = TODAY                                         */
/*               h-state-buf.state_created_by    = USERID("General").                            */
/*                                                                                               */
/*        EXPORT STREAM outward DELIMITER ";" "after state_ISO < 3.".                            */
/*        EXPORT STREAM outward DELIMITER ";"                                                    */
/*                 h-state-buf.                                                                  */
/*                                                                                               */
/*    END.  /*  IF LENGTH(state_ISO) < 3  */                                                     */

    EXPORT STREAM outward DELIMITER ";"
                 "".
END.  /*  4 ea.  */

FOR EACH General.state_mstr WHERE state_stateID < 1 
         EXCLUSIVE-LOCK:
    DELETE General.state_mstr.
END.  /*  4 ea.  */
