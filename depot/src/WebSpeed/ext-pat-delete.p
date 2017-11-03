
/*------------------------------------------------------------------------
    File        : ext-pat-delete.p
    Purpose     : External procedure to delete patient record

    Syntax      : SpeedScript

    Description : Written in Open Edge Developer Studio

    Author(s)   : Mark Jacobs
    Created     : Fri Jul 18 09:09:33 EDT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fpeop-ID LIKE cust_mstr.cust_id      NO-UNDO.

DEFINE OUTPUT PARAMETER pat86     AS LOGICAL INITIAL NO       NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


        FIND patient_mstr WHERE patient_id = i-fpeop-id EXCLUSIVE-LOCK NO-ERROR.   
                                                               
                                     IF AVAILABLE patient_mstr THEN         
                                            ASSIGN
                                               patient_deleted        = TODAY  /* (This sets the flag to delete in patient_mstr) */
                                               patient_modified_date  = TODAY
                                               patient_modified_by    = USERID("Modules") 
                                               pat86                 = YES.                  
