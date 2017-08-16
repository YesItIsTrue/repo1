
/*------------------------------------------------------------------------
    File        : upcreate-addr-mstr.p
    Purpose     : To allow any program to update an existing record, or create one 
                    with the attributes passed to this program.

    Description : The external update and create program for the Address 
                    Master (addr_mstr) table in the General Database.

    Author(s)   : Trae Luttrell
    Created     : Mon Jul 07 12:18:41 MDT 2014
    Updated     : Tue Jul 08 08:01:00 MDT 2014
    Version     : 2.1
    Notes       : This program is NOT to blank out fields in an Address Record.
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucaddr-id          LIKE addr_mstr.addr_id        NO-UNDO.
DEFINE INPUT PARAMETER i-ucaddr-addr1       LIKE addr_mstr.addr_addr1     NO-UNDO.
DEFINE INPUT PARAMETER i-ucaddr-addr2       LIKE addr_mstr.addr_addr2     NO-UNDO.
DEFINE INPUT PARAMETER i-ucaddr-addr3       LIKE addr_mstr.addr_addr3     NO-UNDO.
DEFINE INPUT PARAMETER i-ucaddr-city        LIKE addr_mstr.addr_city      NO-UNDO.
DEFINE INPUT PARAMETER i-ucaddr-stateprov   LIKE addr_mstr.addr_stateprov NO-UNDO.
DEFINE INPUT PARAMETER i-ucaddr-zip         LIKE addr_mstr.addr_zip       NO-UNDO.
DEFINE INPUT PARAMETER i-ucaddr-country     LIKE addr_mstr.addr_country   NO-UNDO.
DEFINE INPUT PARAMETER i-ucaddr-type        LIKE addr_mstr.addr_type      NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucaddr-id         LIKE addr_mstr.addr_id  NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucaddr-create     AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucaddr-update     AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucaddr-avail      AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucaddr-successful AS LOGICAL INITIAL NO           NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-ucaddr-id = 0 THEN DO:
    
        CREATE addr_mstr.
    
        ASSIGN 
            addr_mstr.addr_id               = NEXT-VALUE (seq-addr)
            o-ucaddr-create                 = YES 
            addr_mstr.addr_addr1            = i-ucaddr-addr1
            addr_mstr.addr_addr2            = i-ucaddr-addr2
            addr_mstr.addr_addr3            = i-ucaddr-addr3
            addr_mstr.addr_city             = i-ucaddr-city
            addr_mstr.addr_stateprov        = i-ucaddr-stateprov
            addr_mstr.addr_zip              = i-ucaddr-zip
            addr_mstr.addr_country          = i-ucaddr-country
            o-ucaddr-successful             = YES
            addr_mstr.addr_create_date      = TODAY
            addr_mstr.addr_created_by       = USERID ("General")
            addr_mstr.addr_modified_date    = TODAY
            addr_mstr.addr_modified_by      = USERID ("General")
            addr_mstr.addr_type             = i-ucaddr-type
            o-ucaddr-id                     = addr_mstr.addr_id
            addr_mstr.addr_prog_name        = SOURCE-PROCEDURE:FILE-NAME                                    /* 2dot1 */
            .      
        
    END.  /*** of no id DO ***/
    
    ELSE DO:
        
        FIND FIRST addr_mstr WHERE
            addr_mstr.addr_id       = i-ucaddr-id AND 
            addr_mstr.addr_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE addr_mstr THEN DO:
            
            /*** this is to allow blank inputs ***/
            ASSIGN
                o-ucaddr-update                 = YES
                o-ucaddr-successful             = YES
                addr_mstr.addr_modified_date    = TODAY
                addr_mstr.addr_modified_by      = USERID ("General")
                o-ucaddr-id                     = addr_mstr.addr_id
                addr_mstr.addr_addr1            = IF i-ucaddr-addr1     <> "" THEN i-ucaddr-addr1       ELSE addr_mstr.addr_addr1
                addr_mstr.addr_addr2            = IF i-ucaddr-addr2     <> "" THEN i-ucaddr-addr2       ELSE addr_mstr.addr_addr2   
                addr_mstr.addr_addr3            = IF i-ucaddr-addr3     <> "" THEN i-ucaddr-addr3       ELSE addr_mstr.addr_addr3   
                addr_mstr.addr_city             = IF i-ucaddr-city      <> "" THEN i-ucaddr-city        ELSE addr_mstr.addr_city  
                addr_mstr.addr_stateprov        = IF i-ucaddr-stateprov <> "" THEN i-ucaddr-stateprov   ELSE addr_mstr.addr_stateprov   
                addr_mstr.addr_zip              = IF i-ucaddr-zip       <> "" THEN i-ucaddr-zip         ELSE addr_mstr.addr_zip
                addr_mstr.addr_country          = IF i-ucaddr-country   <> "" THEN i-ucaddr-country     ELSE addr_mstr.addr_country
                addr_mstr.addr_type             = IF i-ucaddr-type      <> "" THEN i-ucaddr-type        ELSE addr_mstr.addr_type 
                addr_mstr.addr_prog_name        = SOURCE-PROCEDURE:FILE-NAME                                    /* 2dot1 */            
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE
            ASSIGN 
                o-ucaddr-avail = NO.
        
    END. /*of the no id ELSE*/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */