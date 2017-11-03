
/*------------------------------------------------------------------------
    File        : SUBatt-ucU.p
    Purpose     : 

    Syntax      :

    Description : The update / creation program for that att_files program in the general database.

    Author(s)   : Trae Luttrell
    Created     : Mon May 09 10:39:53 EDT 2016
    Notes       : 
    Version     : 1.1 - updated by Jacob Luttrell on 22FEB17 added code to allow new id to be passed in and created. Marked by 1dot1.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-att_file_id    LIKE att_files.att_file_id NO-UNDO.
DEFINE INPUT PARAMETER i-att_table      LIKE att_files.att_table NO-UNDO.
DEFINE INPUT PARAMETER i-att_field1     LIKE att_files.att_field1 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value1     LIKE att_files.att_value1 NO-UNDO.
DEFINE INPUT PARAMETER i-att_field2     LIKE att_files.att_field2 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value2     LIKE att_files.att_value2 NO-UNDO.
DEFINE INPUT PARAMETER i-att_field3     LIKE att_files.att_field3 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value3     LIKE att_files.att_value3 NO-UNDO.
DEFINE INPUT PARAMETER i-att_field4     LIKE att_files.att_field4 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value4     LIKE att_files.att_value4 NO-UNDO.
DEFINE INPUT PARAMETER i-att_field5     LIKE att_files.att_field5 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value5     LIKE att_files.att_value5 NO-UNDO.
DEFINE INPUT PARAMETER i-att_category   LIKE att_files.att_category NO-UNDO.
DEFINE INPUT PARAMETER i-att_filepath   LIKE att_files.att_filepath NO-UNDO.
DEFINE INPUT PARAMETER i-att_filename   LIKE att_files.att_filename NO-UNDO.
DEFINE INPUT PARAMETER i-att_filedesc   LIKE all_files.att_filedesc NO-UNDO.
DEFINE INPUT PARAMETER i-att_major_version LIKE att_files.att_major_version NO-UNDO.
DEFINE INPUT PARAMETER i-att_minor_version LIKE att_files.att_minor_version NO-UNDO.

DEFINE OUTPUT PARAMETER o-att_file_id LIKE att_files.att_file_id NO-UNDO.
DEFINE OUTPUT PARAMETER o-att-find-create AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-att-find-update AS LOGICAL NO-UNDO.
DEFINE OUTPUT PARAMETER o-att-find-success AS LOGICAL NO-UNDO.

/* ***************************  Main Block  *************************** */

main-block:
DO TRANSACTION:

    IF i-att_file_id = 0 THEN DO:
    
        CREATE att_files.
                
        ASSIGN
            att_files.att_file_id       = NEXT-VALUE(seq-attfile)
            o-att-find-create                   = YES
            o-att-find-success                  = YES
            att_files.att_create_date   = TODAY
            att_files.att_created_by    = USERID("Core")
            att_files.att_table         = i-att_table
            att_files.att_field1        = i-att_field1
            att_files.att_field2        = i-att_field2
            att_files.att_field3        = i-att_field3
            att_files.att_field4        = i-att_field4
            att_files.att_field5        = i-att_field5
            att_files.att_value1        = i-att_value1
            att_files.att_value2        = i-att_value2
            att_files.att_value3        = i-att_value3
            att_files.att_value4        = i-att_value4
            att_files.att_value5        = i-att_value5
            att_files.att_category      = i-att_category
            att_files.att_filepath      = i-att_filepath
            att_files.att_filename      = i-att_filename
            att_files.att_filedesc      = i-att_filedesc
            att_files.att_major_version = i-att_major_version
            att_files.att_minor_version = i-att_minor_version
                
            att_files.att_modified_date = TODAY
            att_files.att_modified_by   = USERID("Core")
            att_files.att_prog_name     = SOURCE-PROCEDURE:FILE-NAME
            o-att_file_id                       = att_files.att_file_id
            .
        
        
/*        ASSIGN o-att-find-success = NO.*/
/*        LEAVE main-block.              */
    
    
    END. 

    ELSE DO:

        FIND att_files WHERE att_files.att_file_id = i-att_file_id
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE (att_files) THEN DO:       
         
            /** update **/
            ASSIGN
                o-att-find-update                   = YES
                o-att-find-success                  = YES.

        END.

        ELSE DO:                                                        /* 1dot1 */

            /** create **/                                              /* 1dot1 */
            CREATE att_files.                                           /* 1dot1 */
        
            ASSIGN                                                      /* 1dot1 */
                att_files.att_file_id               = i-att_file_id     /* 1dot1 */
                o-att-find-create                   = YES               /* 1dot1 */
                o-att-find-success                  = YES               /* 1dot1 */
                att_files.att_create_date   = TODAY             /* 1dot1 */    
                att_files.att_created_by    = USERID("Core")    /* 1dot1 */
                .                                                       /* 1dot1 */
        END.                                                            /* 1dot1 */
        
        /*** assignment section ***/

            ASSIGN 
                att_files.att_table         = IF i-att_table         <> "" THEN i-att_table ELSE att_files.att_table
                att_files.att_field1        = IF i-att_field1        <> "" THEN i-att_field1 ELSE att_files.att_field1
                att_files.att_field2        = IF i-att_field2        <> "" THEN i-att_field2 ELSE att_files.att_field2
                att_files.att_field3        = IF i-att_field3        <> "" THEN i-att_field3 ELSE att_files.att_field3
                att_files.att_field4        = IF i-att_field4        <> "" THEN i-att_field4 ELSE att_files.att_field4
                att_files.att_field5        = IF i-att_field5        <> "" THEN i-att_field5 ELSE att_files.att_field5
                att_files.att_value1        = IF i-att_value1        <> "" THEN i-att_value1 ELSE att_files.att_value1
                att_files.att_value2        = IF i-att_value2        <> "" THEN i-att_value2 ELSE att_files.att_value2
                att_files.att_value3        = IF i-att_value3        <> "" THEN i-att_value3 ELSE att_files.att_value3
                att_files.att_value4        = IF i-att_value4        <> "" THEN i-att_value4 ELSE att_files.att_value4
                att_files.att_value5        = IF i-att_value5        <> "" THEN i-att_value5 ELSE att_files.att_value5
                att_files.att_category      = IF i-att_category      <> "" THEN i-att_category ELSE att_files.att_category
                att_files.att_filepath      = IF i-att_filepath      <> "" THEN i-att_filepath ELSE att_files.att_filepath
                att_files.att_filename      = IF i-att_filename      <> "" THEN i-att_filename ELSE att_files.att_filename
                att_files.att_filedesc      = IF i-att_filedesc      <> "" THEN i-att_filedesc ELSE att_files.att_filedesc
                att_files.att_major_version = IF i-att_major_version <> "" THEN i-att_major_version ELSE att_files.att_major_version
                att_files.att_minor_version = IF i-att_minor_version <> "" THEN i-att_minor_version ELSE att_files.att_minor_version 
                
                att_files.att_modified_date = TODAY
                att_files.att_modified_by   = USERID("Core")
                att_files.att_prog_name     = SOURCE-PROCEDURE:FILE-NAME
                o-att_file_id                       = att_files.att_file_id
                o-att-find-update                   = YES
                o-att-find-success                  = YES
                .
            
    END. /* else do */

END. /*** main BLOCK ***/