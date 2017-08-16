
/*------------------------------------------------------------------------
    File        : upcreate-scust_shadow.p
    Purpose     : to allow unified creation of the scust_shadow records using the person id previously found.

    Description : External Update/ Create program for the Shadow scustomer Master table in the HHI Database.

    Author(s)   : Trae Luttrell
    Created     : Wed Jul 09 22:50:59 EDT 2014
    Updated     :
    Version     : 1.1
    Notes       : This one is almost identical in function to the upcreate-cust-mstr program. It recieves a
                    cust_id from the program that calls it, then it looks for a scust_shadow with the same id
                    if it can find one, it updates it, if not it creates it.
                    
                The difference is that instead of not working if there is no people_ID with the same number passed,
                    it doesn't work if there is no customer_ID with the same number passes (which wouldn't have 
                    worked if there was no people_ID)
                    
 *  -------------------------------------------------------------------------------------------------------------------------------------                    
 *  Revision History:                    
 *  -----------------
 *  1.0  - written by Trae Luttrell on 09/Jul/14.  Original Version.
 *  1.01 - written by Doug Luttrell on 19/Jul/14.  Adding in updates for modify/create fields.  Marked by 1.01.
 *  1.1  - written by Jacob Luttrell on 14/Mar/16. Added prog_name. Marked by 1dot1.
 *  -------------------------------------------------------------------------------------------------------------------------------------                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
DEFINE INPUT PARAMETER i-ucscust-cust-id       LIKE cust_mstr.cust_id                NO-UNDO.
DEFINE INPUT PARAMETER i-ucscust-magento_ID    LIKE scust_shadow.scust_magento_ID    NO-UNDO.
DEFINE INPUT PARAMETER i-ucscust-prof          LIKE scust_shadow.scust_prof          NO-UNDO.
DEFINE INPUT PARAMETER i-ucscust-doctor_ID     LIKE scust_shadow.scust_doctor_ID     NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucscust-id            LIKE scust_shadow.scust_id  NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucscust-create        AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucscust-update        AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucscust-error         AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucscust-successful    AS LOGICAL INITIAL NO       NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-ucscust-cust-id = 0 THEN 
    DO:
        ASSIGN 
            o-ucscust-error = YES.
        LEAVE maineblock.
    END. 
    
    ELSE 
    DO:
        
        FIND FIRST scust_shadow WHERE
            scust_shadow.scust_id = i-ucscust-cust-id AND
            scust_shadow.scust_deleted = ? 
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE scust_shadow THEN 

            ASSIGN
                o-ucscust-update                    = YES
                o-ucscust-successful                = YES
                scust_shadow.scust_modified_date    = TODAY
                scust_shadow.scust_modified_by      = USERID("HHI")                                     /* 1.01 */
                o-ucscust-id                        = scust_shadow.scust_id                
                .
                
        ELSE 
        DO:
            
            CREATE scust_shadow.
            
            ASSIGN
                scust_shadow.scust_id               = i-ucscust-cust-id
                o-ucscust-create                    = YES
                o-ucscust-successful                = YES
                scust_shadow.scust_create_date      = TODAY
                scust_shadow.scust_created_by       = USERID("HHI")                                     /* 1.01 */
                scust_shadow.scust_modified_date    = TODAY
                scust_shadow.scust_modified_by      = USERID("HHI")                                     /* 1.01 */
                o-ucscust-id                        = scust_shadow.scust_id 
                .
                
        END. /*** of not avail ELSE DO ***/
        
        ASSIGN /*** this is to allow blank inputs ***/
            scust_shadow.scust_magento_ID   = IF i-ucscust-magento_ID   <> "" THEN i-ucscust-magento_ID ELSE scust_shadow.scust_magento_ID
            scust_shadow.scust_prof         = IF i-ucscust-prof         <> ?  THEN i-ucscust-prof       ELSE scust_shadow.scust_prof 
            scust_shadow.scust_doctor_ID    = IF i-ucscust-doctor_ID    <> 0  THEN i-ucscust-doctor_ID  ELSE scust_shadow.scust_doctor_ID                 
            scust_shadow.scust_prog_name    = SOURCE-PROCEDURE:FILE-NAME                                       /* 1dot1 */
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */