
/*------------------------------------------------------------------------
    File        : paid_by_cust-to-cust_paid_date.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Wed Jul 05 13:44:41 EDT 2017
    Notes       :
    
    
  --------------------------------------------------------------------
  Revision History:
  -----------------
  1.0 - written by ANDREW GARVER on 05/Jul/17.  Original Version.
  1.1 - written by DOUG LUTTRELL on 10/Aug/17.  Added support for the 
            *_deleted fields, as well as fixed the direct find 
            references.  Added an output log.  Marked by 1dot1.
              
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
def stream outward.                                         /* 1dot1 */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
output stream outward to                                    /* 1dot1 */
    "C:\progress\wrk\UTIL-cust-paid-log-U.txt".             /* 1dot1 */

EXPORT STREAM OUTWARD DELIMITER ";"                         /* 1dot1 */
    "TK_ID" "TK_test_seq" "TK_cust_paid".                   /* 1dot1 */
    

FOR EACH trh_hist WHERE trh_hist.trh_action = "PAID_BY_CUST" and 
        trh_hist.trh_deleted = ? NO-LOCK:                  /* 1dot1 */
        
    FIND TK_mstr WHERE TK_mstr.TK_ID = trh_hist.trh_serial and  /* 1dot1 */
        tk_mstr.tk_test_seq = trh_hist.trh_sequence and     /* 1dot1 */
        tk_mstr.tk_deleted = ? EXCLUSIVE-LOCK NO-ERROR.    /* 1dot1 */
        
    IF AVAILABLE (TK_mstr) THEN DO:
        
        IF (TK_mstr.tk_cust_paid = TRUE) THEN DO:
        
            ASSIGN 
                TK_mstr.TK_cust_paid_date = trh_hist.trh_date
                TK_mstr.TK_modified_by = USERID ("General")
                TK_mstr.TK_modified_date = TODAY
                TK_mstr.TK_prog_name = SOURCE-PROCEDURE:FILE-NAME.
                
            EXPORT STREAM OUTWARD DELIMITER ";"             /* 1dot1 */
                TK_ID TK_test_seq TK_cust_paid              /* 1dot1 */
                "TK updated".                               /* 1dot1 */
        
        END.    /** of if tk_cust_paid = yes **/            
        
        ELSE DO:
        
            /*  commented out with 1dot1 in favor of the log ****
            DISPLAY "Record not marked as paid: " TK_mstr.TK_ID (COUNT).
            ***/
        
            EXPORT STREAM OUTWARD DELIMITER ";"             /* 1dot1 */
                TK_ID TK_test_seq TK_cust_paid              /* 1dot1 */
                "TestKit not paid".                         /* 1dot1 */
                
        END.    /** of else do -- tk_cust_paid = no **/
        
    END.    /*** of if avail tk_mstr ***/
    
    else do:                                                /* 1dot1 */
    
        export stream outward delimiter ";"                 /* 1dot1 */
            trh_serial trh_sequence trh_date                /* 1dot1 */
            "NO TK_mstr Found".                             /* 1dot1 */
    
    end.                                                    /* 1dot1 */
    
END.    /**** of 4ea. trh_hist ****/

output stream outward close.                                /* 1dot1 */

/***************  EOF  *******************/
