
/*------------------------------------------------------------------------
    File        : SUBDpeop-ucU.p
    Purpose     : 

    Syntax      :

    Description : This is the external update and create program for the D_D_people_mstr table.

    Author(s)   : Andrew Garver
    Notes       : 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-D_people_id            LIKE D_people_mstr.D_people_id          NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_firstname     LIKE D_people_mstr.D_people_firstname   NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_midname       LIKE D_people_mstr.D_people_midname     NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_lastname      LIKE D_people_mstr.D_people_lastname    NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_prefix        LIKE D_people_mstr.D_people_prefix      NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_suffix        LIKE D_people_mstr.D_people_suffix      NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_company       LIKE D_people_mstr.D_people_company     NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_gender        LIKE D_people_mstr.D_people_gender      NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_homephone     LIKE D_people_mstr.D_people_homephone   NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_workphone     LIKE D_people_mstr.D_people_workphone   NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_cellphone     LIKE D_people_mstr.D_people_cellphone   NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_fax           LIKE D_people_mstr.D_people_fax         NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_email         LIKE D_people_mstr.D_people_email       NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_email2        LIKE D_people_mstr.D_people_email2      NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_addr_id       LIKE D_people_mstr.D_people_addr_id     NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_contact       LIKE D_people_mstr.D_people_contact     NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_DOB           LIKE D_people_mstr.D_people_DOB         NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_second_addr_ID LIKE D_people_mstr.D_people_second_addr_ID NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_prefname      LIKE D_people_mstr.D_people_prefname    NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_title         LIKE D_people_mstr.D_people_title       NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_Verify_Flag   LIKE D_people_mstr.D_people_Verify_Flag NO-UNDO.
DEFINE INPUT PARAMETER i-D_people_discrep_ID    LIKE D_people_mstr.D_people_discrep_ID NO-UNDO. 

DEFINE OUTPUT PARAMETER o-Dpeople-id             LIKE D_people_mstr.D_people_id    NO-UNDO.
DEFINE OUTPUT PARAMETER o-Dpeople-create         AS LOGICAL INITIAL NO                 NO-UNDO.
DEFINE OUTPUT PARAMETER o-Dpeople-update         AS LOGICAL INITIAL NO                 NO-UNDO.
DEFINE OUTPUT PARAMETER o-Dpeople-avail          AS LOGICAL INITIAL YES                NO-UNDO.
DEFINE OUTPUT PARAMETER o-Dpeople-successful     AS LOGICAL INITIAL NO                 NO-UNDO.


/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:

    IF i-D_people_id = 0 THEN 
    DO:
    
        CREATE D_people_mstr.
    
        ASSIGN 
            D_people_mstr.D_people_id        = NEXT-VALUE (seq-people)
            o-Dpeople-create                    = YES 
            D_people_mstr.D_people_firstname = i-D_people_firstname
            D_people_mstr.D_people_midname   = i-D_people_midname
            D_people_mstr.D_people_lastname  = i-D_people_lastname
            D_people_mstr.D_people_prefix    = i-D_people_prefix
            D_people_mstr.D_people_suffix    = i-D_people_suffix
            D_people_mstr.D_people_company   = i-D_people_company
            D_people_mstr.D_people_gender    = i-D_people_gender
            D_people_mstr.D_people_homephone = i-D_people_homephone
            D_people_mstr.D_people_workphone = i-D_people_workphone
            D_people_mstr.D_people_cellphone = i-D_people_cellphone
            D_people_mstr.D_people_fax       = i-D_people_fax
            D_people_mstr.D_people_email     = i-D_people_email
            D_people_mstr.D_people_email2    = i-D_people_email2
            D_people_mstr.D_people_addr_id   = i-D_people_addr_id
            D_people_mstr.D_people_contact   = i-D_people_contact
            D_people_mstr.D_people_DOB       = i-D_people_DOB
            o-Dpeople-successful                = YES
            D_people_mstr.D_people_create_date       = TODAY
            D_people_mstr.D_people_created_by        = USERID("Core")
            D_people_mstr.D_people_modified_date     = TODAY
            D_people_mstr.D_people_modified_by       = USERID("Core")
            D_people_mstr.D_people_second_addr_ID    = i-D_people_second_addr_ID
            o-Dpeople-id                        = D_people_mstr.D_people_id
            D_people_mstr.D_people_prefname          = i-D_people_prefname      
            D_people_mstr.D_people_title             = i-D_people_title        
            D_people_mstr.D_people_prog_name         = SOURCE-PROCEDURE:FILE-NAME
            D_people_mstr.D_people_Verify_Flag       = i-D_people_Verify_Flag
            D_people_mstr.D_people_discrep_ID        = i-D_people_discrep_ID
            .      
        
    END.  /*** of no id DO ***/
    
    ELSE 
    DO:
        
        FIND FIRST D_people_mstr WHERE
            D_people_mstr.D_people_id       = i-D_people_id AND
            D_people_mstr.D_people_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE D_people_mstr THEN 
        DO:
            /*** isn't this beautiful?, this is the assign that lets you pass blank fields into this external procedure ***/
            ASSIGN
                o-Dpeople-update                 = YES
                o-Dpeople-successful             = YES
                D_people_mstr.D_people_modified_date  = TODAY
                D_people_mstr.D_people_modified_by    = USERID("Core")
                o-Dpeople-id                     = D_people_mstr.D_people_id
                D_people_mstr.D_people_firstname      = IF i-D_people_firstname      <> "" THEN i-D_people_firstname     ELSE D_people_mstr.D_people_firstname
                D_people_mstr.D_people_midname        = IF i-D_people_midname        <> "" THEN i-D_people_midname       ELSE D_people_mstr.D_people_midname
                D_people_mstr.D_people_lastname       = IF i-D_people_lastname       <> "" THEN i-D_people_lastname      ELSE D_people_mstr.D_people_lastname
                D_people_mstr.D_people_prefix         = IF i-D_people_prefix         <> "" THEN i-D_people_prefix        ELSE D_people_mstr.D_people_prefix
                D_people_mstr.D_people_suffix         = IF i-D_people_suffix         <> "" THEN i-D_people_suffix        ELSE D_people_mstr.D_people_suffix
                D_people_mstr.D_people_company        = IF i-D_people_company        <> "" THEN i-D_people_company       ELSE D_people_mstr.D_people_company
                D_people_mstr.D_people_gender         = IF i-D_people_gender         <> ? THEN i-D_people_gender         ELSE D_people_mstr.D_people_gender
                D_people_mstr.D_people_homephone      = IF i-D_people_homephone      <> "" THEN i-D_people_homephone     ELSE D_people_mstr.D_people_homephone                
                D_people_mstr.D_people_workphone      = IF i-D_people_workphone      <> "" THEN i-D_people_workphone     ELSE D_people_mstr.D_people_workphone
                D_people_mstr.D_people_cellphone      = IF i-D_people_cellphone      <> "" THEN i-D_people_cellphone     ELSE D_people_mstr.D_people_cellphone
                D_people_mstr.D_people_fax            = IF i-D_people_fax            <> "" THEN i-D_people_fax           ELSE D_people_mstr.D_people_fax
                D_people_mstr.D_people_email          = IF i-D_people_email          <> "" THEN i-D_people_email         ELSE D_people_mstr.D_people_email
                D_people_mstr.D_people_email2         = IF i-D_people_email2         <> "" THEN i-D_people_email2        ELSE D_people_mstr.D_people_email2
                D_people_mstr.D_people_addr_id        = IF i-D_people_addr_id        <> 0 THEN i-D_people_addr_id        ELSE D_people_mstr.D_people_addr_id
                D_people_mstr.D_people_contact        = IF i-D_people_contact        <> "" THEN i-D_people_contact       ELSE D_people_mstr.D_people_contact
                D_people_mstr.D_people_DOB            = IF i-D_people_DOB            <> ? THEN i-D_people_DOB            ELSE D_people_mstr.D_people_DOB
                D_people_mstr.D_people_second_addr_ID = IF i-D_people_second_addr_ID <> 0 THEN i-D_people_second_addr_ID ELSE D_people_mstr.D_people_second_addr_ID
                D_people_mstr.D_people_prefname       = IF i-D_people_prefname       <> "" THEN i-D_people_prefname      ELSE D_people_mstr.D_people_prefname    
                D_people_mstr.D_people_title          = IF i-D_people_title          <> "" THEN i-D_people_title         ELSE D_people_mstr.D_people_title       
                D_people_mstr.D_people_prog_name      = SOURCE-PROCEDURE:FILE-NAME                                                                               
                D_people_mstr.D_people_Verify_Flag    = IF i-D_people_Verify_Flag    <> ? THEN i-D_people_Verify_Flag    ELSE D_people_mstr.D_people_Verify_Flag           
                D_people_mstr.D_people_discrep_ID     = IF i-D_people_discrep_ID     <> 0 THEN i-D_people_discrep_ID    ELSE D_people_mstr.D_people_discrep_ID           
                .
                                                        
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE
            ASSIGN 
                o-Dpeople-avail = NO.
        
    END. /*of the no id ELSE*/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */