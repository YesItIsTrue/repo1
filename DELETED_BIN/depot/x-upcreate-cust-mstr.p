
/*------------------------------------------------------------------------
    File        : upcreate-cust-mstr.p
    Purpose     : To allow effecient and external updating and creating for the records in the cust-mstr table. 

    Description : An Update/Create external procedure for the cust-mstr table in the General database.

    Author(s)   : Trae Luttrell
    Created     : Wed Jul 09 12:08:35 EDT 2014
    Updated     : Thu Sep 11 23:43:00 MST 2014
    Version     : 1.2
    Notes       : This program recieves a people_id for someone, it then checks the cust_mstr table to see
                    if that person is a customer, if they already are, it updates the database with the new
                    data you gave it (unless you left something blank, then it leaves the old data). Also
                    if there is not a customer record yet associated with that ID, then it makes a new 
                    customer record.
                     
                !!!!! IMPORTANT !!!!! - this is a "second tier" creation program. This means that if there
                    is not a people_ID passed to this program, it will throw an error. You then need to make
                    sure that (A) it is actually passing what you think it is or (B) run the upcreate-people
                    external program to create a people_ID with that number.
                    
 *  -------------------------------------------------------------------------------------------------------------------------------------                    
 *  Revision History:                    
 *  -----------------
 *  1.0  - written by Trae Luttrell on 09/Jul/14.  Original Version.
 *  1.01 - written by Doug Luttrell on 19/Jul/14.  Modifying path for new depot structure.  Correcting db errors.  Marked by 1.01.
 *  1.2  - written by Trae Luttrell on 11/Sep/14.  Changing the fields and variables to reflect the new changes in the db. Not marked.
 *
 *  -------------------------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
DEFINE INPUT PARAMETER i-uccust-people-id       LIKE people_mstr.people_id          NO-UNDO.
DEFINE INPUT PARAMETER i-uccust-card_nbr        LIKE cust_mstr.cust_card_nbr        NO-UNDO.
DEFINE INPUT PARAMETER i-uccust-card_seccode    LIKE cust_mstr.cust_card_seccode    NO-UNDO.
DEFINE INPUT PARAMETER i-uccust-card_type       LIKE cust_mstr.cust_card_type       NO-UNDO.
DEFINE INPUT PARAMETER i-uccust-card_expmonth   LIKE cust_mstr.cust_card_expmonth   NO-UNDO.
DEFINE INPUT PARAMETER i-uccust-card_expyear    LIKE cust_mstr.cust_card_expyear    NO-UNDO.

DEFINE OUTPUT PARAMETER o-uccust-id             LIKE cust_mstr.cust_id  NO-UNDO.
DEFINE OUTPUT PARAMETER o-uccust-create         AS LOGICAL INITIAL NO   NO-UNDO.
DEFINE OUTPUT PARAMETER o-uccust-update         AS LOGICAL INITIAL NO   NO-UNDO.
DEFINE OUTPUT PARAMETER o-uccust-error          AS LOGICAL INITIAL NO   NO-UNDO.
DEFINE OUTPUT PARAMETER o-uccust-successful     AS LOGICAL INITIAL NO   NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-uccust-people-id = 0 THEN DO:
        ASSIGN o-uccust-error = YES.
        LEAVE maineblock.
    END. 
    
    ELSE 
    DO:
        
        FIND FIRST cust_mstr WHERE
            cust_mstr.cust_id       = i-uccust-people-id AND
            cust_mstr.cust_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE cust_mstr THEN 
        DO:
            
            ASSIGN
                o-uccust-update              = YES
                o-uccust-successful          = YES
                cust_mstr.cust_modified_date = TODAY
                cust_mstr.cust_modified_by   = USERID ("General")                       /* 1.01 */
                o-uccust-id                  = cust_mstr.cust_id                
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE DO:
            
            CREATE cust_mstr.
            
            ASSIGN
                cust_mstr.cust_id               = i-uccust-people-id
                o-uccust-create                 = YES
                o-uccust-successful             = YES
                cust_mstr.cust_create_date      = TODAY
                cust_mstr.cust_created_by       = USERID ("General")                    /* 1.01 */
                cust_mstr.cust_modified_date    = TODAY
                cust_mstr.cust_modified_by      = USERID ("General")                    /* 1.01 */
                /*cust_mstr.cust_card_expmonth    = i-uccust-card_expmonth
                cust_mstr.cust_card_expyear     = i-uccust-card_expyear*/
                o-uccust-id                     = cust_mstr.cust_id 
                .
                
        END. /*** of not avail ELSE DO ***/
        
        /*** this is to allow blank inputs ***/
        ASSIGN 
            cust_mstr.cust_card_nbr      = IF i-uccust-card_nbr     <> "" THEN i-uccust-card_nbr        ELSE cust_mstr.cust_card_nbr   
            cust_mstr.cust_card_seccode  = IF i-uccust-card_seccode <> 0  THEN i-uccust-card_seccode    ELSE cust_mstr.cust_card_seccode   
            cust_mstr.cust_card_type     = IF i-uccust-card_type    <> "" THEN i-uccust-card_type       ELSE cust_mstr.cust_card_type                 
            cust_mstr.cust_card_expmonth = IF i-uccust-card_expmonth<> 0  THEN i-uccust-card_expmonth   ELSE cust_mstr.cust_card_expmonth
            cust_mstr.cust_card_expyear  = IF i-uccust-card_expyear <> 0  THEN i-uccust-card_expyear    ELSE cust_mstr.cust_card_expyear 
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */