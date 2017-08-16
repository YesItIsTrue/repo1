
/*------------------------------------------------------------------------
    File        : SUBDaddr-ucU.p
    Purpose     : To allow any program to update an existing record, or create one 
                    with the attributes passed to this program.

    Description : The external update and create program for the Discrepancy Address 
                    Master (D_addr_mstr) table in the General Database.

    Author(s)   : Andrew Garver
    Notes       : This program is NOT to blank out fields in an Address Record.
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-D_addr_id          LIKE D_addr_mstr.D_addr_id        NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_addr1       LIKE D_addr_mstr.D_addr_addr1     NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_addr2       LIKE D_addr_mstr.D_addr_addr2     NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_addr3       LIKE D_addr_mstr.D_addr_addr3     NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_city        LIKE D_addr_mstr.D_addr_city      NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_stateprov   LIKE D_addr_mstr.D_addr_stateprov NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_zip         LIKE D_addr_mstr.D_addr_zip       NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_country     LIKE D_addr_mstr.D_addr_country   NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_type        LIKE D_addr_mstr.D_addr_type      NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_Verify_Flag LIKE D_addr_mstr.D_addr_Verify_Flag      NO-UNDO.
DEFINE INPUT PARAMETER i-D_addr_discr_ID    LIKE D_addr_mstr.D_addr_discr_ID  NO-UNDO.

DEFINE OUTPUT PARAMETER o-Daddr-id         LIKE D_addr_mstr.D_addr_id  NO-UNDO.
DEFINE OUTPUT PARAMETER o-Daddr-create     AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-Daddr-update     AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-Daddr-avail      AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE OUTPUT PARAMETER o-Daddr-successful AS LOGICAL INITIAL NO           NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-D_addr_id = 0 THEN 
    DO:
    
        CREATE D_addr_mstr.
    
        ASSIGN 
            D_addr_mstr.D_addr_id            = NEXT-VALUE (seq-addr)
            o-Daddr-create              = YES 
            D_addr_mstr.D_addr_addr1         = i-D_addr_addr1
            D_addr_mstr.D_addr_addr2         = i-D_addr_addr2
            D_addr_mstr.D_addr_addr3         = i-D_addr_addr3
            D_addr_mstr.D_addr_city          = i-D_addr_city
            D_addr_mstr.D_addr_stateprov     = i-D_addr_stateprov
            D_addr_mstr.D_addr_zip           = i-D_addr_zip
            D_addr_mstr.D_addr_country       = i-D_addr_country
            o-Daddr-successful          = YES
            D_addr_mstr.D_addr_create_date   = TODAY
            D_addr_mstr.D_addr_created_by    = USERID ("General")
            D_addr_mstr.D_addr_modified_date = TODAY
            D_addr_mstr.D_addr_modified_by   = USERID ("General")
            D_addr_mstr.D_addr_type          = i-D_addr_type
            o-Daddr-id                  = D_addr_mstr.D_addr_id
            D_addr_mstr.D_addr_prog_name     = SOURCE-PROCEDURE:FILE-NAME
            D_addr_mstr.D_addr_Verify_Flag  = i-D_addr_Verify_Flag
            D_addr_mstr.D_addr_discr_ID     = i-D_addr_discr_ID
            .      
        
    END.  /*** of no id DO ***/
    
    ELSE 
    DO:
        
        FIND FIRST D_addr_mstr WHERE
            D_addr_mstr.D_addr_id       = i-D_addr_id AND 
            D_addr_mstr.D_addr_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE D_addr_mstr THEN 
        DO:
            
            /*** this is to allow blank inputs ***/
            ASSIGN
                o-Daddr-update              = YES
                o-Daddr-successful          = YES
                D_addr_mstr.D_addr_modified_date = TODAY
                D_addr_mstr.D_addr_modified_by   = USERID ("General")
                o-Daddr-id                  = D_addr_mstr.D_addr_id
                D_addr_mstr.D_addr_addr1         = IF i-D_addr_addr1     <> "" THEN i-D_addr_addr1       ELSE D_addr_mstr.D_addr_addr1
                D_addr_mstr.D_addr_addr2         = IF i-D_addr_addr2     <> "" THEN i-D_addr_addr2       ELSE D_addr_mstr.D_addr_addr2   
                D_addr_mstr.D_addr_addr3         = IF i-D_addr_addr3     <> "" THEN i-D_addr_addr3       ELSE D_addr_mstr.D_addr_addr3   
                D_addr_mstr.D_addr_city          = IF i-D_addr_city      <> "" THEN i-D_addr_city        ELSE D_addr_mstr.D_addr_city  
                D_addr_mstr.D_addr_stateprov     = IF i-D_addr_stateprov <> "" THEN i-D_addr_stateprov   ELSE D_addr_mstr.D_addr_stateprov   
                D_addr_mstr.D_addr_zip           = IF i-D_addr_zip       <> "" THEN i-D_addr_zip         ELSE D_addr_mstr.D_addr_zip
                D_addr_mstr.D_addr_country       = IF i-D_addr_country   <> "" THEN i-D_addr_country     ELSE D_addr_mstr.D_addr_country
                D_addr_mstr.D_addr_type          = IF i-D_addr_type      <> "" THEN i-D_addr_type        ELSE D_addr_mstr.D_addr_type
                D_addr_mstr.D_addr_Verify_Flag   = IF i-D_addr_Verify_Flag  <> ? THEN i-D_addr_Verify_Flag        ELSE D_addr_mstr.D_addr_Verify_Flag
                D_addr_mstr.D_addr_discr_ID      = IF i-D_addr_discr_ID  <> 0 THEN i-D_addr_discr_ID     ELSE D_addr_mstr.D_addr_discr_ID 
                D_addr_mstr.D_addr_prog_name     = SOURCE-PROCEDURE:FILE-NAME                                 
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE
            ASSIGN 
                o-Daddr-avail = NO.
        
    END. /*of the no id ELSE*/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */