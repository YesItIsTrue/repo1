
/*------------------------------------------------------------------------
    File        : upcreate-people-mstr.p
    Purpose     : To take the data already submitted by the user and then to check it against the database and to see if the record already exists (checks with the people_ID field). It then updates the existing record or creates a new one acordingly.

    Syntax      :

    Description : This is the external update and create program for the people_mstr table.

    Author(s)   : Trae Luttrell
    Created     : Tue Jul 08 09:46:41 MDT 2014
    Updated     : Tue Feb 09 2016
    Version     : 2.1
    Notes       : 
        Version history:
            2.1 - Written by Jacob Luttrell 09Feb16.
                Added prefname updater for release v11.1  
                Marked by /* 2dot1 */      
            2.2 - Written by Jacob Luttrell 14Mar16.
                Added prog_name Marked by 2dot2.
            2.3 - Written by Andrew Garver 16Jun17
                Added people_title Marked by 2dot3    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucpeople-id        LIKE people_mstr.people_id          NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-firstname LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-midname   LIKE people_mstr.people_midname     NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-lastname  LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-prefix    LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE INPUT PARAMETER i-ucpeople-suffix    LIKE people_mstr.people_suffix      NO-UNDO.
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
DEFINE INPUT PARAMETER i-ucpeople-prefname  LIKE people_mstr.people_prefname    NO-UNDO. /* 2dot1 */
DEFINE INPUT PARAMETER i-ucpeople-title     LIKE people_mstr.people_title       NO-UNDO. /* 2dot3 */

DEFINE OUTPUT PARAMETER o-ucpeople-id         LIKE people_mstr.people_id    NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpeople-create     AS LOGICAL INITIAL NO                 NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpeople-update     AS LOGICAL INITIAL NO                 NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpeople-avail      AS LOGICAL INITIAL YES                NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucpeople-successful AS LOGICAL INITIAL NO                 NO-UNDO.


/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-ucpeople-id = 0 THEN 
    DO:
    
        CREATE people_mstr.
    
        ASSIGN 
            people_mstr.people_id           = NEXT-VALUE (seq-people)
            o-ucpeople-create                       = YES 
            people_mstr.people_firstname    = i-ucpeople-firstname
            people_mstr.people_midname      = i-ucpeople-midname
            people_mstr.people_lastname     = i-ucpeople-lastname
            people_mstr.people_prefix       = i-ucpeople-prefix
            people_mstr.people_suffix       = i-ucpeople-suffix
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
            people_mstr.people_created_by           = USERID("Core")
            people_mstr.people_modified_date        = TODAY
            people_mstr.people_modified_by          = USERID("Core")
            people_mstr.people_second_addr_ID       = i-ucpeople-second_addr_ID
            o-ucpeople-id                           = people_mstr.people_id
            people_mstr.people_prefname             = i-ucpeople-prefname      /* 2dot1 */
            people_mstr.people_title                = i-ucpeople-title         /*2dot3*/
            people_mstr.people_prog_name            = SOURCE-PROCEDURE:FILE-NAME     /* 2dot2 */
            .      
        
    END.  /*** of no id DO ***/
    
    ELSE 
    DO:
        
        FIND FIRST people_mstr WHERE
            people_mstr.people_id       = i-ucpeople-id AND
            people_mstr.people_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE people_mstr THEN 
        DO:
            /*** isn't this beautiful?, this is the assign that lets you pass blank fields into this external procedure ***/
            ASSIGN
                o-ucpeople-update                   = YES
                o-ucpeople-successful               = YES
                people_mstr.people_modified_date    = TODAY
                people_mstr.people_modified_by      = USERID("Core")
                o-ucpeople-id                       = people_mstr.people_id
                people_mstr.people_firstname        = IF i-ucpeople-firstname      <> "" THEN i-ucpeople-firstname     ELSE people_mstr.people_firstname
                people_mstr.people_midname          = IF i-ucpeople-midname        <> "" THEN i-ucpeople-midname       ELSE people_mstr.people_midname
                people_mstr.people_lastname         = IF i-ucpeople-lastname       <> "" THEN i-ucpeople-lastname      ELSE people_mstr.people_lastname
                people_mstr.people_prefix           = IF i-ucpeople-prefix         <> "" THEN i-ucpeople-prefix        ELSE people_mstr.people_prefix
                people_mstr.people_suffix           = IF i-ucpeople-suffix         <> "" THEN i-ucpeople-suffix        ELSE people_mstr.people_suffix
                people_mstr.people_company          = IF i-ucpeople-company        <> "" THEN i-ucpeople-company       ELSE people_mstr.people_company
                people_mstr.people_gender           = IF i-ucpeople-gender         <> ? THEN i-ucpeople-gender         ELSE people_mstr.people_gender
                people_mstr.people_homephone        = IF i-ucpeople-homephone      <> "" THEN i-ucpeople-homephone     ELSE people_mstr.people_homephone                
                people_mstr.people_workphone        = IF i-ucpeople-workphone      <> "" THEN i-ucpeople-workphone     ELSE people_mstr.people_workphone
                people_mstr.people_cellphone        = IF i-ucpeople-cellphone      <> "" THEN i-ucpeople-cellphone     ELSE people_mstr.people_cellphone
                people_mstr.people_fax              = IF i-ucpeople-fax            <> "" THEN i-ucpeople-fax           ELSE people_mstr.people_fax
                people_mstr.people_email            = IF i-ucpeople-email          <> "" THEN i-ucpeople-email         ELSE people_mstr.people_email
                people_mstr.people_email2           = IF i-ucpeople-email2         <> "" THEN i-ucpeople-email2        ELSE people_mstr.people_email2
                people_mstr.people_addr_id          = IF i-ucpeople-addr_id        <> 0 THEN i-ucpeople-addr_id        ELSE people_mstr.people_addr_id
                people_mstr.people_contact          = IF i-ucpeople-contact        <> "" THEN i-ucpeople-contact       ELSE people_mstr.people_contact
                people_mstr.people_DOB              = IF i-ucpeople-DOB            <> ? THEN i-ucpeople-DOB            ELSE people_mstr.people_DOB
                people_mstr.people_second_addr_ID   = IF i-ucpeople-second_addr_ID <> 0 THEN i-ucpeople-second_addr_ID ELSE people_mstr.people_second_addr_ID
                people_mstr.people_prefname         = IF i-ucpeople-prefname       <> "" THEN i-ucpeople-prefname      ELSE people_mstr.people_prefname        /* 2dot1 */
                people_mstr.people_title            = IF i-ucpeople-title          <> "" THEN i-ucpeople-title         ELSE people_mstr.people_title           /* 2dot3 */
                people_mstr.people_prog_name        = SOURCE-PROCEDURE:FILE-NAME                                                                               /* 2dot2 */
                .
                                                        
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE
            ASSIGN 
                o-ucpeople-avail = NO.
        
    END. /*of the no id ELSE*/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */