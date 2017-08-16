
/*------------------------------------------------------------------------
    File        : SUBatn-ucU.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Fri Sep 30 07:50:55 MDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucatn-ID           LIKE atn_det.atn_file_ID NO-UNDO.
DEFINE INPUT PARAMETER i-ucatn-node-lvl     LIKE atn_det.atn_node_level NO-UNDO.
DEFINE INPUT PARAMETER i-ucatn-name         LIKE atn_det.atn_name NO-UNDO.
DEFINE INPUT PARAMETER i-ucatn-value        LIKE atn_det.atn_value NO-UNDO.
DEFINE INPUT PARAMETER i-ucatn-type         LIKE atn_det.atn_type NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucatn-id          LIKE atn_det.atn_file_ID NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucatn-node-lvl    LIKE atn_det.atn_node_level NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucatn-name        LIKE atn_det.atn_name NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucatn-value       LIKE atn_det.atn_value NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucatn-create      AS LOGICAL INITIAL NO NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucatn-error       AS LOGICAL INITIAL NO NO-UNDO.

/* ***************************  Main Block  *************************** */ 

mainblock: 
DO TRANSACTION:

    IF i-ucatn-id = 0 THEN 
    DO: 
        
        ASSIGN 
            o-ucatn-error = YES.
        LEAVE mainblock.
    
    END.        
    ELSE 
    DO:
        
        FIND atn_det WHERE atn_det.atn_file_ID = i-ucatn-id AND 
            atn_det.atn_node_level = i-ucatn-node-lvl AND 
            atn_det.atn_name = i-ucatn-name
            EXCLUSIVE-LOCK NO-ERROR.
         
        IF NOT AVAILABLE (atn_det) THEN 
        DO: 
            
            CREATE atn_det.
            
            ASSIGN 
                atn_det.atn_file_ID         = i-ucatn-id
                atn_det.atn_node_level      = i-ucatn-node-lvl
                atn_det.atn_name            = i-ucatn-name   
                atn_det.atn_processed       = "NEW"    
                o-ucatn-create              = YES
                atn_det.atn_create_date     = TODAY
                atn_det.atn_created_by      = USERID ("General")

                .
                
        END.
        
        ASSIGN 
            atn_det.atn_value           = i-ucatn-value    
            atn_det.atn_type            = i-ucatn-type
            o-ucatn-id                  = atn_det.atn_file_ID
            o-ucatn-node-lvl            = atn_det.atn_node_level
            o-ucatn-name                = atn_det.atn_name      
            o-ucatn-value               = atn_det.atn_value      
            atn_det.atn_modified_date   = TODAY
            atn_det.atn_modified_by     = USERID ("General")
            atn_det.atn_prog_name       = SOURCE-PROCEDURE:FILE-NAME
            .        
    END. 
END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */