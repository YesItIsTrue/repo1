
/*------------------------------------------------------------------------
    File        : SUBfsatn_processed-ucU.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Tue Feb 28 07:36:41 EST 2017
    Notes       :
    
    Modified by : Harold Sr.
                : June 1, 2017.
                : Did not need to pass back to the calling program the 
                : "processed" value that was input.
                : Added code to also select the fs_processed and atn_processed
                : records with "NEW" or "CORRECTED" records for processing.
                : Identified by: 1dot1.
                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-fsatn-id LIKE fs_mstr.fs_file_ID NO-UNDO.
DEFINE INPUT PARAMETER i-processed LIKE fs_mstr.fs_processed NO-UNDO.

DEFINE OUTPUT PARAMETER o-successful AS LOGICAL INITIAL NO NO-UNDO.
/*DEFINE OUTPUT PARAMETER o-processed LIKE fs_mstr.fs_processed NO-UNDO.*/                          /* 1dot1 */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
             
FOR EACH fs_mstr WHERE fs_mstr.fs_file_ID = i-fsatn-id   
                   AND (fs_mstr.fs_processed   = "NEW" OR fs_mstr.fs_processed   = "CORRECTED")     /* 1dot1 */
             EXCLUSIVE-LOCK,
    EACH atn_det WHERE atn_det.atn_file_ID = fs_mstr.fs_file_ID AND
                       atn_det.atn_node_level = fs_mstr.fs_child_level  AND 
                      (atn_det.atn_processed   = "NEW" OR atn_det.atn_processed   = "CORRECTED")    /* 1dot1 */
             EXCLUSIVE-LOCK :
              
        ASSIGN 
            fs_mstr.fs_processed = i-processed
            fs_mstr.fs_modified_by = USERID("Core")
            fs_mstr.fs_modified_date = TODAY
            
            atn_det.atn_processed = i-processed
            atn_det.atn_modified_by = USERID("Core")
            atn_det.atn_modified_date = TODAY
            
            o-successful = YES. 

END. /* 4-each */                                                                                   /* 1dot1 */
     