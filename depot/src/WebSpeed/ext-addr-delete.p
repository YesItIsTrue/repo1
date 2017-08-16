
/*------------------------------------------------------------------------
    File        : ext-addr-delete.p
    Purpose     : See purpose

    Syntax      :

    Description : External procedure to delete a address record

    Author(s)   : Mark Jacobs
    Created     : Sat Jul 12 08:13:52 EDT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-faddr-ID LIKE cust_mstr.cust_id      NO-UNDO.

DEFINE OUTPUT PARAMETER addr86     AS LOGICAL INITIAL NO       NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

        FIND addr_mstr WHERE addr_id = i-faddr-id NO-ERROR. /* NO-LOCK */
                                IF AVAILABLE addr_mstr THEN DO:
                                ASSIGN
                                addr_deleted       = TODAY
                                addr_modified_date = TODAY
                                addr_modified_by   = USERID ("General")
                                addr86              = YES. 