
/*------------------------------------------------------------------------
    File        : SUBfs-ucU.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Fri Sep 30 05:51:40 MDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucfs-ID            LIKE fs_mstr.fs_file_ID         NO-UNDO.
DEFINE INPUT PARAMETER i-ucfs-parent-lvl    LIKE fs_mstr.fs_parent_level    NO-UNDO.
DEFINE INPUT PARAMETER i-ucfs-child-lvl     LIKE fs_mstr.fs_child_level     NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucfs-ID           LIKE fs_mstr.fs_file_ID         NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucfs-parent-lvl   LIKE fs_mstr.fs_parent_level    NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucfs-child-lvl    LIKE fs_mstr.fs_child_level     NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucfs-create       AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucfs-error        AS LOGICAL INITIAL NO           NO-UNDO.

/* ***************************  Main Block  *************************** */ 

mainblock: 
DO TRANSACTION:

    IF i-ucfs-id = 0 THEN DO: 
        
        ASSIGN 
            o-ucfs-error = YES.
        LEAVE mainblock.
    
    END.        
    ELSE DO:
        
        FIND fs_mstr WHERE fs_mstr.fs_file_ID = i-ucfs-id AND 
                           fs_mstr.fs_parent_level = i-ucfs-parent-lvl AND 
                           fs_mstr.fs_child_level = i-ucfs-child-lvl
                           EXCLUSIVE-LOCK NO-ERROR.
         
        IF NOT AVAILABLE (fs_mstr) THEN DO: 
            
            CREATE fs_mstr.
            
            ASSIGN 
                fs_mstr.fs_file_ID          = i-ucfs-id
                fs_mstr.fs_parent_level     = i-ucfs-parent-lvl
                fs_mstr.fs_child_level      = i-ucfs-child-lvl
                fs_mstr.fs_processed        = "NEW"
                o-ucfs-create               = YES
                fs_mstr.fs_create_date      = TODAY
                fs_mstr.fs_created_by       = USERID("Core")
                .
                
        END.
        
        ASSIGN
            o-ucfs-id                   = fs_mstr.fs_file_ID
            o-ucfs-parent-lvl           = fs_mstr.fs_parent_level
            o-ucfs-child-lvl            = fs_mstr.fs_child_level
            fs_mstr.fs_modified_date    = TODAY
            fs_mstr.fs_modified_by      = USERID("Core")
            fs_mstr.fs_prog_name        = SOURCE-PROCEDURE:FILE-NAME
            .
            
    END. 
END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */