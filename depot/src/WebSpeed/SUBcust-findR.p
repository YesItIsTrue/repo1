/*------------------------------------------------------------------------
    File        : find-customer.p
    Purpose     : See Description.

    Description : A external procudre built to allow us to find a specific 
                    customer record based on the email field data. 
                    Then to unify the unique-ness across the database.

    Author(s)   : Trae Luttrell
    Created     : Mon Jun 02 20:23:53 EDT 2014
    Version     : 3.3
    Updated     : Sat Aug 15 09:09:00 EDT 2015
    Notes       : This is the one explained in the WebEx meeting on July 7th
                    with Mark, Harold, Doug, and myself.
                    
                3.1- Adding in the extra parameters so that the people_mstr.people_addr_id 
                    makes it all the way back up from the find-people.p. Version 3.0 already
                    found the Address Id if it found it at the customer level. Now it will
                    find it on the customer level, or down in the people level.
                    
                3.2 - written by TRAE LUTTRELL on 26/Aug/14.  Removing Bonus variables that 
                        were duplicates of previous variables.
                            
                3.3 - written by DOUG LUTTRELL on 15/Aug/15.  Changed to use the SEARCH function
                        to help with the pathing issue.  Also noticed that this was still
                        using the find code instead of the newer SUBpeop-findR.p code.
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fcust-prefix      LIKE people_mstr.people_prefix     NO-UNDO.
DEFINE INPUT PARAMETER  i-fcust-firstname   LIKE people_mstr.people_firstname  NO-UNDO.
DEFINE INPUT PARAMETER  i-fcust-midname     LIKE people_mstr.people_midname    NO-UNDO.
DEFINE INPUT PARAMETER  i-fcust-lastname    LIKE people_mstr.people_lastname   NO-UNDO.
DEFINE INPUT PARAMETER  i-fcust-suffix      LIKE people_mstr.people_suffix     NO-UNDO.
 
DEFINE INPUT PARAMETER  i-fcust-email       LIKE people_mstr.people_email      NO-UNDO.

DEFINE OUTPUT PARAMETER o-fcust-ID          LIKE people_mstr.people_id         NO-UNDO.
DEFINE OUTPUT PARAMETER o-fcust-addr-ID     LIKE people_mstr.people_addr_id    NO-UNDO.
DEFINE OUTPUT PARAMETER o-fcust-exist       AS LOGICAL INITIAL NO              NO-UNDO. /* this is if the CUSTOMER record exists */
DEFINE OUTPUT PARAMETER o-fcust-ran         AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE OUTPUT PARAMETER o-fcust-error       AS LOGICAL INITIAL NO              NO-UNDO.

DEFINE VARIABLE         showmsg             AS LOGICAL INITIAL NO              NO-UNDO. /** change to yes for debug messages **/

/* ***************************  Main Block  **************************** */

IF showmsg = YES THEN 
    MESSAGE "Inside find-customer.p about to start"
        VIEW-AS ALERT-BOX BUTTONS OK.
    
FOR FIRST people_mstr WHERE
    people_mstr.people_email        = i-fcust-email     AND 
    people_mstr.people_lastname     = i-fcust-lastname  AND 
    people_mstr.people_firstname    = i-fcust-firstname AND 
    people_mstr.people_deleted      = ?
    NO-LOCK, 
FIRST cust_mstr WHERE 
    cust_mstr.cust_id               = people_mstr.people_id AND
    cust_mstr.cust_deleted          = ?
    NO-LOCK:

    ASSIGN
        o-fcust-exist       = YES
        o-fcust-ID          = people_mstr.people_id
        o-fcust-addr-ID     = people_mstr.people_addr_id.
        
    IF showmsg = YES THEN 
        MESSAGE "Inside initial 4ea."
                VIEW-AS ALERT-BOX BUTTONS OK.    
        
END.

IF o-fcust-exist = NO THEN DO:

    FOR FIRST people_mstr WHERE
        people_mstr.people_email2       = i-fcust-email     AND 
        people_mstr.people_lastname     = i-fcust-lastname  AND 
        people_mstr.people_firstname    = i-fcust-firstname AND 
        people_mstr.people_deleted      = ?
        NO-LOCK, 
    FIRST cust_mstr WHERE 
        cust_mstr.cust_id               = people_mstr.people_id AND
        cust_mstr.cust_deleted          = ?
        NO-LOCK:
    
        ASSIGN
            o-fcust-exist       = YES
            o-fcust-ID          = people_mstr.people_id
            o-fcust-addr-ID     = people_mstr.people_addr_id.
            
        IF showmsg = YES THEN 
            MESSAGE "Inside secondary 4ea."
                    VIEW-AS ALERT-BOX BUTTONS OK.    
            
    END. /*** of secondary 4ea ***/

END. /*** of if no then do ***/

IF o-fcust-exist = NO THEN DO:

    IF showmsg = YES THEN 
        MESSAGE "Inside Not Available"
            VIEW-AS ALERT-BOX BUTTONS OK.

    RUN VALUE(SEARCH("SUBpeop-findR.r"))
/*    RUN "../depot/rcode/find-people.r"*/
        (i-fcust-prefix, 
        i-fcust-firstname, 
        i-fcust-midname, 
        i-fcust-lastname, 
        i-fcust-suffix,
        OUTPUT o-fcust-ID,
        OUTPUT o-fcust-addr-ID, 
        OUTPUT o-fcust-error, 
        OUTPUT o-fcust-ran).

END. /*** find-people.p loop ***/                
                 
/* ***************************  End of Line  *************************** */
