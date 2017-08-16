
/*------------------------------------------------------------------------
    File        : SUBpeop-datefindR.p

    Description : An external finding procedure that will only find people who have dates of birth.

    Author(s)   : Trae Luttrell
    Created     : Thu Sep 10 12:31:07 EDT 2015
    Updated     :
    Version     : 1.0
    Notes       : Made for Harold.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-fpeopd-prefix     LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE INPUT PARAMETER i-fpeopd-firstname  LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE INPUT PARAMETER i-fpeopd-midname    LIKE people_mstr.people_midname     NO-UNDO.
DEFINE INPUT PARAMETER i-fpeopd-lastname   LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE INPUT PARAMETER i-fpeopd-suffix     LIKE people_mstr.people_suffix      NO-UNDO.
DEFINE INPUT PARAMETER i-fpeopd-DOB        LIKE people_mstr.people_DOB         NO-UNDO.

DEFINE OUTPUT PARAMETER o-fpeopd-peopleID  LIKE people_mstr.people_id          NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpeopd-addr_ID   LIKE people_mstr.people_addr_id     NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpeopd-error     AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE OUTPUT PARAMETER o-fpat-ran      AS LOGICAL INITIAL NO               NO-UNDO.

/* ***************************  Main Block  *************************** */
ASSIGN o-fpat-ran = YES.

FIND FIRST people_mstr WHERE
    people_mstr.people_lastname     = i-fpeopd-lastname     AND
    people_mstr.people_firstname    = i-fpeopd-firstname    AND
    people_mstr.people_midname      = i-fpeopd-midname      AND
    people_mstr.people_suffix       = i-fpeopd-suffix       AND
    people_mstr.people_prefix       = i-fpeopd-prefix       AND
    people_mstr.people_DOB          = i-fpeopd-DOB          AND 
    people_mstr.people_deleted      = ?
        NO-LOCK 
        USE-INDEX people-name-idx
        NO-ERROR.
        
IF AVAILABLE people_mstr THEN
    
    ASSIGN 
        o-fpeopd-peopleID  = people_mstr.people_id
        o-fpeopd-error     = NO
        o-fpeopd-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
        /** o-fpeopd-tier      = 1 **/.

ELSE DO:
    
    FIND FIRST people_mstr WHERE 
        people_mstr.people_lastname     = i-fpeopd-lastname     AND 
        people_mstr.people_firstname    = i-fpeopd-firstname    AND 
        people_mstr.people_midname      = i-fpeopd-midname      AND
        people_mstr.people_suffix       = i-fpeopd-suffix       AND
        people_mstr.people_DOB          = i-fpeopd-DOB          AND
        people_mstr.people_deleted      = ?
        NO-LOCK
        USE-INDEX people-name-idx
        NO-ERROR.
      
    IF AVAILABLE people_mstr THEN
    
        ASSIGN 
            o-fpeopd-peopleID  = people_mstr.people_id
            o-fpeopd-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
            o-fpeopd-error     = NO.
            
    ELSE DO:
    
    FIND FIRST people_mstr WHERE 
        people_mstr.people_lastname     = i-fpeopd-lastname     AND 
        people_mstr.people_firstname    = i-fpeopd-firstname    AND 
        people_mstr.people_midname      = i-fpeopd-midname      AND
        people_mstr.people_DOB          = i-fpeopd-DOB          AND
        people_mstr.people_deleted      = ?
        NO-LOCK
        USE-INDEX people-name-idx
        NO-ERROR.
      
    IF AVAILABLE people_mstr THEN
    
        ASSIGN 
            o-fpeopd-peopleID  = people_mstr.people_id
            o-fpeopd-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
            o-fpeopd-error     = NO. 
                  
        ELSE DO:
        
        FIND FIRST people_mstr WHERE 
            people_mstr.people_lastname         = i-fpeopd-lastname     AND 
            people_mstr.people_firstname        = i-fpeopd-firstname    AND 
            people_mstr.people_suffix           = i-fpeopd-suffix       AND
            people_mstr.people_DOB          = i-fpeopd-DOB              AND
            people_mstr.people_deleted  = ?
            NO-LOCK 
            USE-INDEX people-name-idx
            NO-ERROR.
            
            IF AVAILABLE people_mstr THEN
        
            ASSIGN 
                o-fpeopd-peopleID  = people_mstr.people_id
                o-fpeopd-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
                o-fpeopd-error     = NO.
                
            ELSE DO:
                
                FIND FIRST people_mstr WHERE
                
                    people_mstr.people_lastname         = i-fpeopd-lastname     AND 
                    people_mstr.people_firstname        = i-fpeopd-firstname    AND
                    people_mstr.people_DOB          = i-fpeopd-DOB              AND
                    people_mstr.people_deleted  = ?
                    NO-LOCK 
                    USE-INDEX people-name-idx
                    NO-ERROR.
                
                IF AVAILABLE people_mstr THEN
        
                ASSIGN 
                    o-fpeopd-peopleID  = people_mstr.people_id
                    o-fpeopd-addr_id   = people_mstr.people_addr_id                    /** 3.1 ***/
                    o-fpeopd-error     = NO.
                    
                ELSE ASSIGN 
                    
                    o-fpeopd-error     = YES.
                    
            END. /*** of ELSE DO: tier 5 ***/
        
        END. /*** of ELSE DO: tier 4 ***/
    
    END. /*** of ELSE DO: tier 3 ***/
    
END. /*** of ELSE DO: tier 2 ***/       
      

/* **************************  END OF LINE  *************************** */