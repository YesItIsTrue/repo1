
/*------------------------------------------------------------------------
    File        : find-addr.p
    Purpose     : To have an external tiered find program for the addr_mstr.

    Description : This is the external find address program.

    Author(s)   : Trae Luttrell
    Created     : Thu Jul 17 20:48:38 EDT 2014
    Updated     : 
    Version     : 1.0
    Notes       : This is a tiered-find like people-find. So when it can't find an address with the criteria
                    you gave it then is tries again using less, and continues to try with less and less 
                    until it is down to the minimum (which in this case is addr1, city, state, and zip code.
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-faddr-addr1        LIKE addr_mstr.addr_addr1       NO-UNDO.
DEFINE INPUT PARAMETER i-faddr-addr2        LIKE addr_mstr.addr_addr2       NO-UNDO.
DEFINE INPUT PARAMETER i-faddr-addr3        LIKE addr_mstr.addr_addr3       NO-UNDO.
DEFINE INPUT PARAMETER i-faddr-city         LIKE addr_mstr.addr_city        NO-UNDO.
DEFINE INPUT PARAMETER i-faddr-stateprov    LIKE addr_mstr.addr_statepro    NO-UNDO.
DEFINE INPUT PARAMETER i-faddr-zip          LIKE addr_mstr.addr_zip         NO-UNDO.
DEFINE INPUT PARAMETER i-faddr-country      LIKE addr_mstr.addr_country     NO-UNDO.

DEFINE OUTPUT PARAMETER o-faddr-addrID  LIKE addr_mstr.addr_id              NO-UNDO.
DEFINE OUTPUT PARAMETER o-faddr-error   AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE OUTPUT PARAMETER o-faddr-ran     AS LOGICAL INITIAL NO               NO-UNDO.

/* ***************************  Main Block  *************************** */
ASSIGN 
    o-faddr-ran = YES.

FIND FIRST addr_mstr WHERE
    addr_mstr.addr_addr1        = i-faddr-addr1 AND
    addr_mstr.addr_addr2        = i-faddr-addr2 AND
    addr_mstr.addr_addr3        = i-faddr-addr3 AND
    addr_mstr.addr_city         = i-faddr-city AND
    addr_mstr.addr_stateprov    = i-faddr-stateprov AND
    addr_mstr.addr_zip          = i-faddr-zip AND 
    addr_mstr.addr_country      = i-faddr-country AND
    addr_mstr.addr_deleted      = ?
    NO-LOCK 
    USE-INDEX addr-full-idx
    NO-ERROR.
        
IF AVAILABLE addr_mstr THEN
    
    ASSIGN 
        o-faddr-addrID = addr_mstr.addr_id
        o-faddr-error    = NO.

ELSE 
DO:
    
    FIND FIRST addr_mstr WHERE 
        addr_mstr.addr_addr1        = i-faddr-addr1 AND
        addr_mstr.addr_addr2        = i-faddr-addr2 AND
        addr_mstr.addr_addr3        = i-faddr-addr3 AND
        addr_mstr.addr_city         = i-faddr-city AND
        addr_mstr.addr_stateprov    = i-faddr-stateprov AND
        addr_mstr.addr_zip          = i-faddr-zip AND 
        addr_mstr.addr_deleted      = ?
        NO-LOCK
        USE-INDEX addr-full-idx
        NO-ERROR.
      
    IF AVAILABLE addr_mstr THEN
    
        ASSIGN 
            o-faddr-addrID = addr_mstr.addr_id
            o-faddr-error    = NO.
            
    ELSE 
    DO:
    
        FIND FIRST addr_mstr WHERE 
            addr_mstr.addr_addr1        = i-faddr-addr1 AND
            addr_mstr.addr_addr2        = i-faddr-addr2 AND
            addr_mstr.addr_city         = i-faddr-city AND
            addr_mstr.addr_stateprov    = i-faddr-stateprov AND
            addr_mstr.addr_zip          = i-faddr-zip AND 
            addr_mstr.addr_deleted      = ?
            NO-LOCK
            USE-INDEX addr-full-idx
            NO-ERROR.
      
        IF AVAILABLE addr_mstr THEN
    
            ASSIGN 
                o-faddr-addrID = addr_mstr.addr_id
                o-faddr-error    = NO. 
                  
        ELSE 
        DO:
        
            FIND FIRST addr_mstr WHERE 
                addr_mstr.addr_addr1        = i-faddr-addr1 AND
                addr_mstr.addr_city         = i-faddr-city AND
                addr_mstr.addr_stateprov    = i-faddr-stateprov AND
                addr_mstr.addr_zip          = i-faddr-zip AND 
                addr_mstr.addr_deleted      = ?
                NO-LOCK
                USE-INDEX addr-full-idx
                NO-ERROR.
            
            IF AVAILABLE addr_mstr THEN
        
                ASSIGN 
                    o-faddr-addrID = addr_mstr.addr_id
                    o-faddr-error    = NO.
                
            ELSE ASSIGN 
                    
                    o-faddr-error = YES.
                    
        
        END. /*** of ELSE DO: tier 4 ***/
    
    END. /*** of ELSE DO: tier 3 ***/
    
END. /*** of ELSE DO: tier 2 ***/       
      

/* **************************  END OF LINE  *************************** */