/*------------------------------------------------------------------------

    File        : SUBdoc-findR.p
    Purpose     : Find the people_mstr record where the first name and last 
                    name match and verifies if that same person exists as a 
                    doctor record and then returns and reports to you.

    Description : An external procedure for finding doctors in the HHI 
                    doctor table and the people master one.

    Author(s)   : Trae Luttrell
    Created     : Tue Jun 03 08:47:13 EDT 2014
    Updated     : Tue Oct 20 08:40:00 EDT 2015
    Version     : 3.21
    Notes       : This is the version just after the Monday meeting between
                    Mark, Harold, Doug, and myself.
    
                3.1- Adding in the extra parameters so that the people_mstr.people_addr_id 
                    makes it all the way back up from the find-people.p and so that it will 
                    find the addr-id up here on the find-doctor level.
                    
                3.2 - written by TRAE LUTTRELL on 26/Aug/14.  Fixing the huge bug where the 
                        find-doctor would never run the find-people.
                
                3.21 - written by DOUG LUTTRELL on 20/Oct/15.  Fixed pathing.  Marked by 321.
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fdoc-prefix      LIKE people_mstr.people_prefix     NO-UNDO.
DEFINE INPUT PARAMETER  i-fdoc-firstname   LIKE people_mstr.people_firstname  NO-UNDO.
DEFINE INPUT PARAMETER  i-fdoc-midname     LIKE people_mstr.people_midname    NO-UNDO.
DEFINE INPUT PARAMETER  i-fdoc-lastname    LIKE people_mstr.people_lastname   NO-UNDO.
DEFINE INPUT PARAMETER  i-fdoc-suffix      LIKE people_mstr.people_suffix     NO-UNDO.

DEFINE OUTPUT PARAMETER o-fdoc-ID          LIKE people_mstr.people_id         NO-UNDO.
DEFINE OUTPUT PARAMETER o-fdoc-addr_ID     LIKE people_mstr.people_addr_ID    NO-UNDO.
DEFINE OUTPUT PARAMETER o-fdoc-exist       AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE OUTPUT PARAMETER o-fdoc-ran         AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE OUTPUT PARAMETER o-fdoc-error       AS LOGICAL INITIAL NO              NO-UNDO.

DEFINE VARIABLE         showmsg            AS LOGICAL INITIAL NO              NO-UNDO.            /** change to yes for debug messages **/

/* ***************************  Main Block  **************************** */

                                                                                IF showmsg = YES THEN 
                                                                                    MESSAGE "Inside find-doctor.p about to start"
                                                                                        VIEW-AS ALERT-BOX BUTTONS OK.
    
FOR FIRST people_mstr WHERE
    people_mstr.people_lastname     = i-fdoc-lastname  AND 
    people_mstr.people_firstname    = i-fdoc-firstname AND 
    people_mstr.people_deleted      = ?
    NO-LOCK, 
FIRST doctor_mstr WHERE 
    doctor_mstr.doctor_ID       = people_mstr.people_id AND
    doctor_mstr.doctor_deleted  = ?
    NO-LOCK:

                                                                                                IF showmsg = YES THEN 
                                                                                                    MESSAGE "Inside initial 4ea."
                                                                                                    VIEW-AS ALERT-BOX BUTTONS OK. 

    IF AVAILABLE doctor_mstr THEN DO:
    
        ASSIGN
            o-fdoc-ID          = people_mstr.people_id
            o-fdoc-addr_ID     = people_mstr.people_addr_id
            o-fdoc-exist       = YES
            o-fdoc-ran         = NO 
            o-fdoc-error       = NO
            .
        
    END. /* of if avail doc */
    
END. /* of 4ea */ 

IF o-fdoc-exist = NO THEN DO:

                                                                                            IF showmsg = YES THEN 
                                                                                                MESSAGE "Inside Not Available"
                                                                                                    VIEW-AS ALERT-BOX BUTTONS OK.

    RUN VALUE(SEARCH("SUBpeop-findR.r"))                                                        /* 321 */
        (i-fdoc-prefix, 
        i-fdoc-firstname, 
        i-fdoc-midname, 
        i-fdoc-lastname, 
        i-fdoc-suffix,
        OUTPUT o-fdoc-id,
        OUTPUT o-fdoc-addr_id, 
        OUTPUT o-fdoc-error, 
        OUTPUT o-fdoc-ran).
 
END. /* of doctor unavailable */
                 
/* ***************************  End of Line  *************************** */
