
/*------------------------------------------------------------------------
    File        : fix-TK-singles-U.p
    Purpose     : 

    Syntax      :

    Description : Program to find all TK's that are multiples (as defined by test_group_qty) and create missing 
                    TK_mstr & trh_hist records for them.

    Author(s)   : Doug Luttrell
    Created     : Fri Jan 15 10:33:10 EST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE x-tkmstr AS INTEGER NO-UNDO.
DEFINE VARIABLE x-trhhist AS INTEGER NO-UNDO. 
DEFINE VARIABLE x-totrecs AS INTEGER NO-UNDO.
DEFINE VARIABLE x-preexist AS INTEGER NO-UNDO.
DEFINE VARIABLE x-actupon AS INTEGER NO-UNDO. 

DEFINE VARIABLE updatemode AS LOG INITIAL YES NO-UNDO.

DEFINE BUFFER tkbuff FOR TK_mstr.

DEFINE VARIABLE v-testid LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE VARIABLE v-currseq LIKE TK_mstr.TK_test_seq NO-UNDO.

DEFINE VARIABLE o-uctkm-id LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE VARIABLE o-uctkm-create AS LOG NO-UNDO.
DEFINE VARIABLE o-uctkm-update AS LOG NO-UNDO. 
DEFINE VARIABLE o-uctkm-avail AS LOG NO-UNDO. 
DEFINE VARIABLE o-uctkm-successful AS LOG NO-UNDO.

DEFINE VARIABLE o-ctrh-id LIKE trh_hist.trh_ID NO-UNDO.
DEFINE VARIABLE o-ctrh-error AS LOG NO-UNDO. 


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH test_mstr WHERE test_mstr.test_group_qty > 1 AND 
        test_mstr.test_deleted = ? NO-LOCK,
    EACH TK_mstr WHERE TK_mstr.TK_test_type = test_mstr.test_type AND 
        TK_mstr.TK_test_seq = 1 AND 
        TK_mstr.TK_deleted = ? NO-LOCK:
   
    x-totrecs = x-totrecs + 1. 
    
    FIND tkbuff WHERE tkbuff.tk_id = tk_mstr.tk_id AND 
        tkbuff.tk_test_seq <> tk_mstr.tk_test_seq AND 
        tkbuff.tk_test_type = TK_mstr.tk_test_type AND 
        tkbuff.tk_deleted = ? 
            NO-LOCK NO-ERROR.
          
    IF AVAILABLE (tkbuff) THEN
        x-preexist = x-preexist + 1.
        
    ELSE DO: 
        
        x-actupon = x-actupon + 1.
        
        DO v-currseq = 2 TO test_mstr.test_group_qty:

            x-tkmstr = x-tkmstr + 1.
            
            IF updatemode = YES THEN DO: 
            
                RUN VALUE (SEARCH ("SUBtkmstrRSTPucU.r"))
                    (TK_mstr.TK_ID, 
                     TK_mstr.TK_test_type,
                     TK_mstr.TK_prof,
                     v-currseq,
                     TK_mstr.TK_domestic,
                     TK_mstr.TK_cust_ID,
                     TK_mstr.TK_patient_ID,
                     TK_mstr.TK_lab_sample_ID,
                     TK_mstr.TK_lab_seq,
                     TK_mstr.TK_test_age,
                     TK_mstr.TK_lab_ID,
                     TK_mstr.TK_status,
                     TK_mstr.TK_comments,
                     TK_mstr.TK_notes,
                     TK_mstr.TK_cust_paid,
                     TK_mstr.TK_lbl_print,
                     TK_mstr.TK_lab_paid, 
                     OUTPUT o-uctkm-id,
                     OUTPUT o-uctkm-create,
                     OUTPUT o-uctkm-update,
                     OUTPUT o-uctkm-avail,
                     OUTPUT o-uctkm-successful).
            
            END.  /** of if updatemode = yes --- create tk_mstr records **/
            
            FOR EACH trh_hist WHERE trh_hist.trh_serial = TK_mstr.TK_ID AND 
                trh_hist.trh_sequence = TK_mstr.TK_test_seq AND 
                trh_hist.trh_deleted = ? NO-LOCK:

                x-trhhist = x-trhhist + 1.

                IF updatemode = YES THEN DO: 
                               
                    RUN VALUE (SEARCH ("SUBtrh-RSTP-ucU.r"))
                        (0,                                     /* trh_hist.trh_id */
                         trh_hist.trh_item,
                         trh_hist.trh_action,
                         trh_hist.trh_qty,
                         trh_hist.trh_loc,
                         trh_hist.trh_lot,
                         trh_hist.trh_serial,
                         trh_hist.trh_site,
                         v-currseq,
                         trh_hist.trh_create_date,
                         OUTPUT o-ctrh-id,
                         OUTPUT o-ctrh-error).
                
                END.  /** of if updatemode = yes --- create trh_hist records **/
                        
            END. /** of 4ea. trh_hist **/
        
        END.  /** of do v-currseq = 2 to test_group_qty **/
            
    END.  /** of else do --- NOT avail tkbuff **/
         
END.    /** of 4ea. tk_mstr **/
    
DISPLAY x-totrecs x-preexist x-actupon x-tkmstr x-trhhist. 

/***************************  END OF FILE  *****************************/
