
/*------------------------------------------------------------------------
    File        : ext-cust-scust-delete.p
    Purpose     : To delete a customer record along with its scost record

    Syntax      :

    Description : This procedure runs ext-cust-delete.p and ext-scust-delet.p with 
                  2 separate run statements.
        
                  
    Author(s)   : 
    Created     : Thu Jul 17 13:33:35 EDT 2014
    Notes       : Mark Jacobs
    
 *  ------------------------------------------------------------------------------------
 *  
 *  Revision History:
 *  -----------------
 *  1.0 - written by MARK JACOBS on 17/Jun/14.  Original Version.
 *  1.1 - written by DOUG LUTTRELL on 09/Oct/15.  Fixed pathing issue.
    
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fcust-ID LIKE cust_mstr.cust_id      NO-UNDO.

DEFINE OUTPUT PARAMETER cust86     AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE OUTPUT PARAMETER scust86    AS LOGICAL INITIAL NO       NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


        RUN VALUE(SEARCH("ext-cust-delete.r"))                                                          /* 1dot1 */
        (i-fcust-id,
        OUTPUT cust86).  
        
        
        RUN VALUE(SEARCH("ext-scust-delete.r"))                                                         /* 1dot1 */
        (i-fcust-id,
        OUTPUT scust86).  