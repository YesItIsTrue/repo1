
/*------------------------------------------------------------------------
    File        : ext-people-delete.p
    Purpose     : See description

    Syntax      :

    Description : An external procedure to delete a people record

    Author(s)   : Mark Jacobs
    Created     : Fri Jul 11 18:04:30 EDT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-fpe-ID LIKE cust_mstr.cust_id      NO-UNDO.

DEFINE OUTPUT PARAMETER peop86   AS LOGICAL INITIAL NO       NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

         FIND  people_mstr WHERE people_id = i-fpe-ID  NO-ERROR.   /* NO-LOCK peop-ID */        
                                        IF AVAILABLE (people_mstr) THEN DO: 
                                        ASSIGN
                                        people_deleted       = TODAY
                                        people_modified_date = TODAY
                                        people_modified_by   = USERID ("General")
                                        peop86                = YES.                  