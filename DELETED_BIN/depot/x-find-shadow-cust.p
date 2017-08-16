
/*------------------------------------------------------------------------
    File        : find-shadow-cust.p

    Description : This is the find procedure for the shadow-customer records for the 
                        HHI database.

    Author(s)   : Trae Luttrell
    Created     : Tue Jul 29 13:49:19 EDT 2014
    Updated     :
    Version     : 1.0
    Notes       : 
        
            1.0 - copied version 3.1 of the find-customer procedure and am starting to 
                make the changes to have it work for shadow customers.
                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fshadc-prefix      LIKE people_mstr.people_prefix     NO-UNDO.
DEFINE INPUT PARAMETER  i-fshadc-firstname   LIKE people_mstr.people_firstname  NO-UNDO.
DEFINE INPUT PARAMETER  i-fshadc-midname     LIKE people_mstr.people_midname    NO-UNDO.
DEFINE INPUT PARAMETER  i-fshadc-lastname    LIKE people_mstr.people_lastname   NO-UNDO.
DEFINE INPUT PARAMETER  i-fshadc-suffix      LIKE people_mstr.people_suffix     NO-UNDO.

DEFINE INPUT PARAMETER  i-fshadc-email       LIKE people_mstr.people_email      NO-UNDO.

DEFINE OUTPUT PARAMETER o-fshadc-ID          LIKE people_mstr.people_id         NO-UNDO.
DEFINE OUTPUT PARAMETER o-fshadc-addr-ID     LIKE people_mstr.people_addr_id    NO-UNDO.
DEFINE OUTPUT PARAMETER o-fshadc-magento-ID  LIKE scust_shadow.scust_magento_ID NO-UNDO.
DEFINE OUTPUT PARAMETER o-fshadc-exist       AS LOGICAL INITIAL NO              NO-UNDO. /* this is if the SHADOW-CUSTOMER record exists */
DEFINE OUTPUT PARAMETER o-fshadc-ran         AS LOGICAL INITIAL NO              NO-UNDO. /* this is if the find-people.p ran */
DEFINE OUTPUT PARAMETER o-fshadc-error       AS LOGICAL INITIAL NO              NO-UNDO. /* this is if the find-people.p came back with nothing */

DEFINE VARIABLE         fshadc-rec-id        LIKE people_mstr.people_id         NO-UNDO.
DEFINE VARIABLE         fshadc-rec-logerror  AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE         fshadc-rec-addr-id   LIKE people_mstr.people_addr_id    NO-UNDO.

DEFINE VARIABLE         showmsg              AS LOGICAL INITIAL NO              NO-UNDO. /** change to yes for debug messages **/

/* ***************************  Main Block  **************************** */

IF showmsg = YES THEN 
    MESSAGE "Inside find-shadow-cust.p about to start"
        VIEW-AS ALERT-BOX BUTTONS OK.
    
FOR FIRST people_mstr WHERE
    people_mstr.people_email        = i-fshadc-email     AND 
    people_mstr.people_lastname     = i-fshadc-lastname  AND 
    people_mstr.people_firstname    = i-fshadc-firstname AND 
    people_mstr.people_deleted      = ?
    NO-LOCK, 
FIRST cust_mstr WHERE 
    cust_mstr.cust_id               = people_mstr.people_id AND
    cust_mstr.cust_deleted          = ?
    NO-LOCK,
FIRST scust_shadow WHERE
    scust_shadow.scust_id           = people_mstr.people_id AND
    scust_shadow.scust_deleted      = ?
    NO-LOCK:

    ASSIGN
        o-fshadc-exist       = YES
        o-fshadc-ID          = people_mstr.people_id
        o-fshadc-addr-ID     = people_mstr.people_addr_id.
        o-fshadc-magento-ID  = scust_shadow.scust_magento_id.
        
    IF showmsg = YES THEN 
        MESSAGE "Inside initial 4ea."
                VIEW-AS ALERT-BOX BUTTONS OK.    
        
END.

/* * *** I believe this is no longer nessisary ...

IF o-fshadc-exist = NO THEN DO:

    FOR FIRST people_mstr WHERE
        people_mstr.people_email2       = i-fshadc-email     AND 
        people_mstr.people_lastname     = i-fshadc-lastname  AND 
        people_mstr.people_firstname    = i-fshadc-firstname AND 
        people_mstr.people_deleted      = ?
        NO-LOCK, 
    FIRST cust_mstr WHERE 
        cust_mstr.cust_id               = people_mstr.people_id AND
        cust_mstr.cust_deleted          = ?
        NO-LOCK:
    
        ASSIGN
            o-fshadc-exist       = YES
            o-fshadc-ID          = people_mstr.people_id
            o-fshadc-addr-ID     = people_mstr.people_addr_id.
            
        IF showmsg = YES THEN 
            MESSAGE "Inside secondary 4ea."
                    VIEW-AS ALERT-BOX BUTTONS OK.    
            
    END. /*** of secondary 4ea ***/ 

END. /*** of if no then do ***/*** * */

IF o-fshadc-exist = NO THEN DO:

    IF showmsg = YES THEN 
        MESSAGE "Inside Not Available"
            VIEW-AS ALERT-BOX BUTTONS OK.

    RUN "../depot/rcode/find-people.p"
        (i-fshadc-prefix, 
        i-fshadc-firstname, 
        i-fshadc-midname, 
        i-fshadc-lastname, 
        i-fshadc-suffix,
        OUTPUT o-fshadc-ID,
        OUTPUT o-fshadc-addr-ID, 
        OUTPUT o-fshadc-error, 
        OUTPUT o-fshadc-ran).

/* *** * * This is also unnessisary ...
        
    ASSIGN 
        o-fshadc-ID          = fshadc-rec-id
        o-fshadc-addr-ID     = fshadc-rec-addr-id
        o-fshadc-error       = fshadc-rec-logerror
        .
 ... * * *** */
    
END. /*** find-people.p loop ***/                
                 
/* ***************************  End of Line  *************************** */