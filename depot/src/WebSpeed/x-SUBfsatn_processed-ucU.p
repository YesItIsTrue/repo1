
/*------------------------------------------------------------------------
    File        : SUBfsatn_processed-ucU.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Tue Feb 28 07:36:41 EST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-fsatn-id LIKE fs_mstr.fs_file_ID NO-UNDO.
DEFINE INPUT PARAMETER i-processed LIKE fs_mstr.fs_processed NO-UNDO.

DEFINE OUTPUT PARAMETER o-successful AS LOGICAL INITIAL NO NO-UNDO.
DEFINE OUTPUT PARAMETER o-processed LIKE fs_mstr.fs_processed NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH fs_mstr WHERE fs_mstr.fs_file_ID = i-fsatn-id EXCLUSIVE-LOCK,
    EACH atn_det WHERE atn_det.atn_file_ID = fs_mstr.fs_file_ID EXCLUSIVE-LOCK:
        
        ASSIGN 
            fs_mstr.fs_processed = i-processed
            fs_mstr.fs_modified_by = USERID("Modules")
            fs_mstr.fs_modified_date = TODAY
            atn_det.atn_processed = i-processed
            atn_det.atn_modified_by = USERID("Modules")
            atn_det.atn_modified_date = TODAY
            o-successful = YES. 
            