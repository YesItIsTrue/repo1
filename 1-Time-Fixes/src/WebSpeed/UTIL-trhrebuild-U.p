
/*------------------------------------------------------------------------
    File        : UTIL-trhrebuild-U.p

    Version     : 1.0

    Description : Populate the new trh_date field based on sets of data from the 
                    trh_create_date and trh_mod_date.  Cleanup the "duplicate" 
                    records in the trh_hist.  Fix the problem with some statuses 
                    being PAID_BY_CUSTOMER instead of PAID_BY_CUST.		

    Author(s)   : Doug Luttrell
    Created     : Thu Mar 17 06:40:47 EDT 2016
    Notes       :
        
  ----------------------------------------------------------------------
  Revision History:
  -----------------
  1.0 - written by DOUG LUTTRELL on 17/Mar/16.  Original Version.
        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE newdate AS DATE NO-UNDO.
DEFINE VARIABLE updatemode AS LOGICAL INITIAL NO NO-UNDO.

DEFINE VARIABLE tkid LIKE TK_mstr.TK_ID NO-UNDO.

DEFINE VARIABLE outfile AS CHARACTER INITIAL "C:\progress\wrk\trhfixlog.txt".

DEFINE STREAM logfile.
OUTPUT STREAM logfile TO value(outfile).


/* ********************  Preprocessor Definitions  ******************** */

UPDATE SKIP(1)
    tkid COLON 20 SKIP 
    updatemode COLON 20 SKIP(1)
        WITH FRAME a WIDTH 80 SIDE-LABELS. 
        
/* ***************************  Main Block  *************************** */
IF updatemode = YES THEN DO: 

    FOR EACH trh_hist WHERE (trh_hist.trh_serial = tkid OR 
        tkid = "") AND 
        trh_hist.trh_action = "PAID_BY_CUSTOMER": 
        
        ASSIGN 
            trh_hist.trh__log03         = NO 
            trh_hist.trh_action         = "PAID_BY_CUST"
            trh_hist.trh_modified_date  = TODAY 
            trh_hist.trh_modified_by    = USERID("General")
            trh_hist.trh_prog_name      = THIS-PROCEDURE:FILE-NAME.
            
    END.  /** of 4ea. trh_hist **/
    
END.  /** of if updatemode = yes then cleanup bad PAID_BY_CUSTOMER data **/

FOR EACH trh_hist WHERE (trh_hist.trh_serial = tkid OR 
        tkid = "")
    BREAK BY trh_hist.trh_serial BY trh_hist.trh_sequence BY trh_hist.trh_action BY trh_hist.trh_create_date DESCENDING :
        
    IF FIRST-OF (trh_hist.trh_action) THEN 
        newdate = trh_hist.trh_create_date.    
        
    IF trh_hist.trh_create_date < newdate THEN 
        newdate = trh_hist.trh_create_date.
        
    IF LAST-OF (trh_hist.trh_action) THEN DO: 
        
        DISPLAY STREAM logfile 
            trh_hist.trh_serial FORMAT "x(12)"
            trh_hist.trh_sequence FORMAT ">>9"
            trh_hist.trh_action
            trh_hist.trh_create_date 
            newdate 
            trh_hist.trh_modified_date
            "UPDATED".
            
        IF updatemode = YES THEN DO: 
            
            ASSIGN 
                trh_hist.trh_date           = newdate 
                trh_hist.trh_modified_date  = TODAY 
                trh_hist.trh_modified_by    = USERID("General")
                trh_hist.trh_prog_name      = THIS-PROCEDURE:FILE-NAME
                trh_hist.trh__log03         = YES.    
        
            IF trh_hist.trh_action = "SOLD" OR trh_hist.trh_action = "SHIPPED" OR trh_hist.trh_action = "PAID_BY_CUST" THEN DO: 
                
                FIND TK_mstr WHERE TK_mstr.TK_ID = trh_hist.trh_serial AND 
                    TK_mstr.TK_test_seq = trh_hist.trh_sequence NO-LOCK NO-ERROR.
                    
                IF AVAILABLE (tk_mstr) THEN 
                    ASSIGN 
                        trh_hist.trh_people_id = TK_mstr.TK_cust_ID.
                        
                ELSE 
                    DISPLAY STREAM logfile 
                        "trh_hist exists with no tk_mstr for trh_serial = " trh_hist.trh_serial.
                
            END.  /** of if trh_action = customer related **/     
            
        END.  /** of if updatemode = yes **/
            
    END.  /** of if last-of trh_action **/
                
        
END.  /** of 4ea. trh_hist --- find the answers **/

IF updatemode = YES THEN DO: 

    FOR EACH trh_hist WHERE (trh_hist.trh_serial = tkid OR 
            tkid = "") AND 
        trh_hist.trh__log03  <> YES : 
        
        DISPLAY STREAM logfile
            trh_hist.trh_serial FORMAT "x(12)" 
            trh_hist.trh_sequence FORMAT ">>9" 
            trh_hist.trh_action 
            trh_hist.trh_create_date 
            "" @ newdate
            trh_hist.trh_modified_date
            "DELETED".    
    
        /*
        DELETE trh_hist. 
        */
        ASSIGN 
            trh_hist.trh_deleted = TODAY.
                
    END.  /** of 4ea. trh_hist --- cleanup records **/

END.  /** of if updatemode = yes **/

OUTPUT STREAM logfile CLOSE.

/******************************  End of File  ***************************/
