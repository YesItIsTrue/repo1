
/*------------------------------------------------------------------------
    File        : ext-scust-delete.p
    Purpose     : See Description

    Syntax      :

    Description :  An external procedure to delete shadow customer record

    Author(s)   : Mark Jacobs
    Created     : Tue Jul 15 11:16:56 EDT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fcust-ID LIKE cust_mstr.cust_id      NO-UNDO.

DEFINE OUTPUT PARAMETER scust86     AS LOGICAL INITIAL NO       NO-UNDO.



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


        
                          FIND scust_shadow WHERE scust_id = i-fcust-id EXCLUSIVE-LOCK NO-ERROR.  
                             
                                                 IF AVAILABLE scust_shadow THEN         
                                                        ASSIGN
                                                           scust_deleted       = TODAY  /* (This sets the flag to delete in scust_shadow) */ 
                                                           scust_modified_date = TODAY
                                                           scust_modified_by   = USERID ("HHI")
                                                           scust86              = YES.                  
