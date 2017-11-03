
/*------------------------------------------------------------------------
    File        : SUBpal-ucU.p
    Purpose     : To allow any program to update an existing record, or create one 
                    with the attributes passed to this program.

    Description : The external update and create program for the People Address 
                   List (pal_list) table in the General Database.

    Author(s)   : Andrew Garver
    Created     : Wed May 24 2017
    Updated     : Wed May 24 2017
    Version     : 1.0
    Notes       : This program is NOT to blank out fields in a People Address List Record.
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-people_id      LIKE pal_list.pal_people_ID        NO-UNDO.
DEFINE INPUT PARAMETER i-addr_id        LIKE pal_list.pal_addr_ID     NO-UNDO.
DEFINE INPUT PARAMETER i-type           LIKE pal_list.pal_type     NO-UNDO.
DEFINE INPUT PARAMETER i-requestedkey   LIKE pal_list.pal_type     NO-UNDO.
DEFINE INPUT PARAMETER i-update         AS  LOGICAL INITIAL NO    NO-UNDO.
DEFINE INPUT PARAMETER i-new-type       AS  CHARACTER INITIAL "" NO-UNDO.

DEFINE OUTPUT PARAMETER o-requestedkey LIKE pal_list.pal_people_ID NO-UNDO.
DEFINE OUTPUT PARAMETER o-successful  AS LOGICAL INITIAL NO           NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:
    FIND FIRST pal_list WHERE 
        pal_list.pal_people_ID = i-people_id AND 
        pal_list.pal_addr_ID = i-addr_id AND 
        pal_list.pal_type = i-type NO-ERROR.
        
    IF i-update THEN /*Update the record*/
        DO:
            IF AVAILABLE pal_list THEN  
                ASSIGN 
                    o-successful         = YES
                    pal_list.pal_type          = IF i-new-type <> "" THEN i-new-type ELSE pal_list.pal_type
                    pal_list.pal_modified_date = TODAY
                    pal_list.pal_modified_by   = USERID("Core")
                    pal_list.pal_prog_name     = SOURCE-PROCEDURE:FILE-NAME
                    o-requestedkey       = IF i-requestedkey = "people_id" THEN pal_list.pal_people_ID ELSE pal_list.pal_addr_ID.
        END.
    ELSE IF NOT AVAILABLE pal_list THEN /*Create a new record*/
        DO:
             IF (i-type = "Primary") THEN /*Change all other addresses linked to this people_id to secondary*/ 
                DO: 
                    IF AVAILABLE (pal_list) THEN 
                    DO:
                        FOR EACH pal_list WHERE pal_list.pal_people_id = i-people_id AND pal_list.pal_type = "Primary" EXCLUSIVE-LOCK:
                            ASSIGN pal_list.pal_type = "Secondary".
                        END.
                    END.
                END.
        
            /*Create the new Primary address*/
            CREATE pal_list.
        
            ASSIGN 
                pal_list.pal_people_ID      = i-people_id
                pal_list.pal_addr_ID        = i-addr_id
                pal_list.pal_type           = i-type
                o-successful          = YES
                pal_list.pal_create_date    = TODAY
                pal_list.pal_created_by     = USERID("Core")
                pal_list.pal_modified_date  = TODAY
                pal_list.pal_modified_by    = USERID("Core")
                pal_list.pal_prog_name      = SOURCE-PROCEDURE:FILE-NAME
                o-requestedkey          = IF i-requestedkey = "people_id" THEN pal_list.pal_people_ID ELSE pal_list.pal_addr_ID
                .    
        END.
END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */
