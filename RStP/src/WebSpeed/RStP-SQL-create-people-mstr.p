  
/*------------------------------------------------------------------------
    File        : RStP-SQL-create-people-mstr.p
    Purpose     : Create the people_mstr using the SQL PATIENTID number.
                : Their PATIENTID numbers range is from 1 to 49,999.

    Syntax      :

    Description : This is the external create program for the people_mstr table.
                : Code was copied from the original: upcreate-people-mstr.p 

    Author(s)   : Trae Luttrell
    Created     : Tue Jul 08 09:46:41 MDT 2014
    Updated     : Tue Jul 09 09:30:00 EST 2014
    Version     : 1.1
    Notes       : 
    Modified by : Harold Luttrell, SR.
    Created     : Dec 20, 2014.
        
    Version: 2.0    By Harold Luttrell, Sr.
        Date: 9/Feb/16.
            Added input field dor the people_mstr.people_prefname.        
        Identified by /* 2dot0 */ 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucpeople-id        LIKE people_mstr.people_id          NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-firstname LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-midname   LIKE people_mstr.people_midname     NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-lastname  LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-prefix    LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-suffix    LIKE people_mstr.people_suffix      NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-prefname  LIKE people_mstr.people_prefname    NO-UNDO.    /* 2dot0 */
DEFINE INPUT PARAMETER i-ucpeople-company   LIKE people_mstr.people_company     NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-gender    LIKE people_mstr.people_gender      NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-homephone LIKE people_mstr.people_homephone   NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-workphone LIKE people_mstr.people_workphone   NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-cellphone LIKE people_mstr.people_cellphone   NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-fax       LIKE people_mstr.people_fax         NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-email     LIKE people_mstr.people_email       NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-email2    LIKE people_mstr.people_email2      NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-addr_id   LIKE people_mstr.people_addr_id     NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-contact   LIKE people_mstr.people_contact     NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-DOB       LIKE people_mstr.people_DOB         NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-second_addr_ID LIKE people_mstr.people_second_addr_ID NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucpeople-id         LIKE people_mstr.people_id    NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpeople-create     AS LOGICAL INITIAL NO                 NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpeople-update     AS LOGICAL INITIAL NO                 NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpeople-avail      AS LOGICAL INITIAL YES                NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpeople-successful AS LOGICAL INITIAL NO                 NO-UNDO.


/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-ucpeople-id > 0 THEN                                                   
    DO:
    
        CREATE people_mstr.
    
        ASSIGN 
            people_mstr.people_id           = i-ucpeople-id             
            o-ucpeople-create                       = YES 
            people_mstr.people_firstname    = i-ucpeople-firstname
            people_mstr.people_midname      = i-ucpeople-midname
            people_mstr.people_lastname     = i-ucpeople-lastname
            people_mstr.people_prefix       = i-ucpeople-prefix
            people_mstr.people_suffix       = i-ucpeople-suffix
            people_mstr.people_prefname     = i-ucpeople-prefname       /* 2dot0 */
            people_mstr.people_company      = i-ucpeople-company
            people_mstr.people_gender       = i-ucpeople-gender
            people_mstr.people_homephone    = i-ucpeople-homephone
            people_mstr.people_workphone    = i-ucpeople-workphone
            people_mstr.people_cellphone    = i-ucpeople-cellphone
            people_mstr.people_fax          = i-ucpeople-fax
            people_mstr.people_email        = i-ucpeople-email
            people_mstr.people_email2       = i-ucpeople-email2
            people_mstr.people_addr_id      = i-ucpeople-addr_id
            people_mstr.people_contact      = i-ucpeople-contact
            people_mstr.people_DOB          = i-ucpeople-DOB
            o-ucpeople-successful                   = YES
            people_mstr.people_create_date          = TODAY
            people_mstr.people_created_by           = USERID ("General")
            people_mstr.people_modified_date        = TODAY
            people_mstr.people_modified_by          = USERID ("General")
            people_mstr.people_second_addr_ID       = i-ucpeople-second_addr_ID
            o-ucpeople-id                           = people_mstr.people_id
            .      
        
    END.  /*** i-ucpeople-id > 0 ***/
    
    ELSE 
            ASSIGN 
                o-ucpeople-avail = NO.

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */