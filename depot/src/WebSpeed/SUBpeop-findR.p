
/*------------------------------------------------------------------------
    File        : find-people.p
    Purpose     : To find the people based on first name, middle name, last name, 
                        suffix, and prefix in the order in which they are 
                        indexed in the Database.

    Description : A find external procedure, straight people finding.

    Author(s)   : Trae Luttrell
    Created     : Mon Jun 16 12:30:49 EDT 2014
    Updated     : Mon July 07 17:33:00 EDT 2014
    Version     : 3.1
    Notes       : This is the version that I am putting out on the Buffalo 
                    after the Monday night meeting with Mark, Harold, Doug,
                    and myself.
                    
                 3.1 - Added the people_addr_id on the OUTPUTS
                 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-fpe-prefix     LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE INPUT PARAMETER i-fpe-firstname  LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE INPUT PARAMETER i-fpe-midname    LIKE people_mstr.people_midname     NO-UNDO.
DEFINE INPUT PARAMETER i-fpe-lastname   LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE INPUT PARAMETER i-fpe-suffix     LIKE people_mstr.people_suffix      NO-UNDO.

DEFINE OUTPUT PARAMETER o-fpe-peopleID  LIKE people_mstr.people_id          NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpe-addr_ID   LIKE people_mstr.people_addr_id     NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpe-error     AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpat-ran      AS LOGICAL INITIAL NO               NO-UNDO.

/* ***************************  Main Block  *************************** */
ASSIGN o-fpat-ran = YES.

FIND FIRST people_mstr WHERE
    people_mstr.people_lastname     = i-fpe-lastname AND
    people_mstr.people_firstname    = i-fpe-firstname AND
    people_mstr.people_midname      = i-fpe-midname AND
    people_mstr.people_suffix       = i-fpe-suffix AND
    people_mstr.people_prefix       = i-fpe-prefix AND
    people_mstr.people_deleted      = ?
        NO-LOCK 
        USE-INDEX people-name-idx 
        NO-ERROR.
        
IF AVAILABLE people_mstr THEN
    
    ASSIGN 
        o-fpe-peopleID  = people_mstr.people_id
        o-fpe-error     = NO
        o-fpe-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
        /** o-fpe-tier      = 1 **/.

ELSE DO:
    
    FIND FIRST people_mstr WHERE 
        people_mstr.people_lastname     = i-fpe-lastname    AND 
        people_mstr.people_firstname    = i-fpe-firstname   AND 
        people_mstr.people_midname      = i-fpe-midname     AND
        people_mstr.people_suffix       = i-fpe-suffix      AND
        people_mstr.people_deleted      = ?
        NO-LOCK
        USE-INDEX people-name-idx
        NO-ERROR.
      
    IF AVAILABLE people_mstr THEN
    
        ASSIGN 
            o-fpe-peopleID  = people_mstr.people_id
            o-fpe-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
            o-fpe-error     = NO.
            
    ELSE DO:
    
    FIND FIRST people_mstr WHERE 
        people_mstr.people_lastname     = i-fpe-lastname    AND 
        people_mstr.people_firstname    = i-fpe-firstname   AND 
        people_mstr.people_midname      = i-fpe-midname     AND
        people_mstr.people_deleted      = ?
        NO-LOCK
        USE-INDEX people-name-idx
        NO-ERROR.
      
    IF AVAILABLE people_mstr THEN
    
        ASSIGN 
            o-fpe-peopleID  = people_mstr.people_id
            o-fpe-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
            o-fpe-error     = NO. 
                  
        ELSE DO:
        
        FIND FIRST people_mstr WHERE 
            people_mstr.people_lastname         = i-fpe-lastname AND 
            people_mstr.people_firstname        = i-fpe-firstname AND 
            people_mstr.people_suffix           = i-fpe-suffix AND
            people_mstr.people_deleted  = ?
            NO-LOCK 
            USE-INDEX people-name-idx
            NO-ERROR.
            
            IF AVAILABLE people_mstr THEN
        
            ASSIGN 
                o-fpe-peopleID  = people_mstr.people_id
                o-fpe-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
                o-fpe-error     = NO.
                
            ELSE DO:
                
                FIND FIRST people_mstr WHERE
                
                    people_mstr.people_lastname         = i-fpe-lastname AND 
                    people_mstr.people_firstname        = i-fpe-firstname AND
                    people_mstr.people_deleted  = ?
                    NO-LOCK 
                    USE-INDEX people-name-idx
                    NO-ERROR.
                
                IF AVAILABLE people_mstr THEN
        
                ASSIGN 
                    o-fpe-peopleID  = people_mstr.people_id
                    o-fpe-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
                    o-fpe-error     = NO.
                    
                ELSE ASSIGN 
                    
                    o-fpe-error     = YES.
                    
            END. /*** of ELSE DO: tier 5 ***/
        
        END. /*** of ELSE DO: tier 4 ***/
    
    END. /*** of ELSE DO: tier 3 ***/
    
END. /*** of ELSE DO: tier 2 ***/       
      

/* **************************  END OF LINE  *************************** */