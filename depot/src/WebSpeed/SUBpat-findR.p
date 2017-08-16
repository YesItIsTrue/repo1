/*------------------------------------------------------------------------

    File        : SUBfind-patR.p
    Purpose     : Find the people_mstr record where the first name,  last 
                    name, and DOB all match, verifies if that same person 
                    exists as a patient record and then returns and reports 
                    to you.

    Description : An external procedure for finding "unique" patient in the 
                    HHI patient database.

    Author(s)   : Trae Luttrell
    Created     : Tue Jun 03 08:47:13 EDT 2014
    Updated     : Tue Oct 20 08:43:00 EDT 2015
    Version     : 3.21
    Notes       : This is the version from just after the meeting with Mark,
                    Harold, Doug, and Trae on July 7th 2014.
                    
                3.1- Adding in the extra parameters so that the people_mstr.people_addr_id 
                    makes it all the way back up from the find-people.p. Version 3.0 already
                    found the Address Id if it found it at the patient level. Now it will
                    find it on the patient level, or down in the people level.
                    
                3.2 - written by TRAE LUTTRELL on 26/Aug/14.  Removing the bonus variables 
                        that were duplicates of other variables.
                        
                3.21 - written by DOUG LUTTRELL on 20/Oct/15.  Fixed pathing.  Marked by 321.
                    
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fpat-prefix      LIKE people_mstr.people_prefix     NO-UNDO.
DEFINE INPUT PARAMETER  i-fpat-firstname   LIKE people_mstr.people_firstname  NO-UNDO.
DEFINE INPUT PARAMETER  i-fpat-midname     LIKE people_mstr.people_midname    NO-UNDO.
DEFINE INPUT PARAMETER  i-fpat-lastname    LIKE people_mstr.people_lastname   NO-UNDO.
DEFINE INPUT PARAMETER  i-fpat-suffix      LIKE people_mstr.people_suffix     NO-UNDO.

DEFINE INPUT PARAMETER  i-fpat-DOB         LIKE people_mstr.people_DOB        NO-UNDO.

DEFINE OUTPUT PARAMETER o-fpat-ID          LIKE people_mstr.people_id         NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpat-addr-ID     LIKE people_mstr.people_addr_id    NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpat-exist       AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpat-ran         AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpat-error       AS LOGICAL INITIAL NO              NO-UNDO.

DEFINE VARIABLE         showmsg            AS LOGICAL INITIAL NO             NO-UNDO.      /** change to yes for debug messages **/

DEFINE VARIABLE codetorun       AS CHARACTER                        NO-UNDO.     
DEFINE VARIABLE depotcode       AS CHARACTER                        NO-UNDO.    
DEFINE VARIABLE drive_letter    AS CHARACTER                        NO-UNDO.    

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).

/* ***************************  Main Block  **************************** */

                                                                                IF showmsg = YES THEN 
                                                                                    MESSAGE "Inside SUBfind-patR about to start"
                                                                                        VIEW-AS ALERT-BOX BUTTONS OK.
    
FOR FIRST people_mstr WHERE
    people_mstr.people_DOB          = i-fpat-DOB       AND 
    people_mstr.people_lastname     = i-fpat-lastname  AND 
    people_mstr.people_firstname    = i-fpat-firstname AND 
    people_mstr.people_deleted      = ?
    NO-LOCK, 
FIRST patient_mstr WHERE 
    patient_mstr.patient_ID         = people_mstr.people_id AND
    patient_mstr.patient_deleted    = ?
    NO-LOCK:

    ASSIGN
        o-fpat-exist       = YES
        o-fpat-ID          = people_mstr.people_id
        o-fpat-addr-ID     = people_mstr.people_addr_id.
        
                                                                                        IF showmsg = YES THEN 
                                                                                            MESSAGE "End of 4ea."
                                                                                                    VIEW-AS ALERT-BOX BUTTONS OK.    
        
END.

IF o-fpat-exist = NO THEN DO:

                                                                                            IF showmsg = YES THEN 
                                                                                                MESSAGE "Inside Not Available"
                                                                                                    VIEW-AS ALERT-BOX BUTTONS OK.


    RUN VALUE(SEARCH("SUBpeop-datefindR.r"))                                                                    /* 321 */
        (i-fpat-prefix, 
        i-fpat-firstname, 
        i-fpat-midname, 
        i-fpat-lastname, 
        i-fpat-suffix,
        i-fpat-DOB,
        OUTPUT o-fpat-ID,
        OUTPUT o-fpat-addr-ID, 
        OUTPUT o-fpat-error, 
        OUTPUT o-fpat-ran).
     
END.                 
                 
/* ***************************  End of Line  *************************** */