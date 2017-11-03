
/*------------------------------------------------------------------------
    File        : ext-cust-delete.p
    Purpose     : See Description.

    Syntax      :

    Description : An external procedure to delete customer record.This procedure 
                  also runs ext-scust-delete.p to delete the shadow customer record.

    Author(s)   : Mark Jacobs
    Created     : Fri Jul 11 17:08:31 EDT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fcust-ID LIKE cust_mstr.cust_id      NO-UNDO.

DEFINE OUTPUT PARAMETER cust86     AS LOGICAL INITIAL NO       NO-UNDO.
/* DEFINE OUTPUT PARAMETER scust86    AS LOGICAL INITIAL NO       NO-UNDO. */
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */ 

         FIND cust_mstr WHERE cust_id = i-fcust-id EXCLUSIVE-LOCK NO-ERROR.   
                                                       
                             IF AVAILABLE cust_mstr THEN         
                                    ASSIGN
                                       cust_deleted        = TODAY  /* (This sets the flag to delete in cust_mstr) */
                                       cust_modified_date  = TODAY
                                       cust_modified_by    = USERID("Core") 
                                       cust86              = YES.                  

                                      
        
        
                             