
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
   
    Modified by : Harold Sr.
                : Nov 11, 2017.
                : Added the SOURCE-PROCEDURE:FILE-NAME to the FS and ATN prog_name fields.
                : Moved the input ERROR description to the fs__char01 and atn__char01 fields.
                : Identified by 1dot2.              
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-fsatn-id LIKE fs_mstr.fs_file_ID NO-UNDO.
DEFINE INPUT PARAMETER i-processed LIKE fs_mstr.fs_processed NO-UNDO.
DEFINE INPUT PARAMETER i-ERROR_Desc LIKE fs_mstr.fs__char01 NO-UNDO.

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
            fs_mstr.fs_processed     = i-processed
            fs_mstr.fs_modified_by   = USERID("Core")
            fs_mstr.fs_modified_date = TODAY
            fs_mstr.fs_prog_name     = SOURCE-PROCEDURE:FILE-NAME                                   /* 1dot2 */
            fs_mstr.fs__char01       = i-ERROR_Desc                                                 /* 1dot2 */
            
            atn_det.atn_processed     = i-processed
            atn_det.atn_modified_by   = USERID("Core")
            atn_det.atn_modified_date = TODAY
            atn_det.atn_prog_name     = SOURCE-PROCEDURE:FILE-NAME                                  /* 1dot2 */
            atn_det.atn__char01       = i-ERROR_Desc                                                /* 1dot2 */
            
            o-successful = YES. 

END. /* 4-each */                                                                                   /* 1dot1 */
     