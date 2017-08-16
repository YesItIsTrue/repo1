
/*------------------------------------------------------------------------
    File        : Statuslist.i
    Purpose     : Reduce confusion about the statlist order

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Wed Feb 03 05:56:43 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE statlist AS CHARACTER                                                                                                                                      
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,BURNED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
