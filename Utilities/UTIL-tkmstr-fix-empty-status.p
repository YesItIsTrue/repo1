DEFINE VARIABLE o-uctkm-id              LIKE TK_mstr.TK_id              NO-UNDO.
DEFINE VARIABLE o-uctkm-create          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE o-uctkm-update          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE o-uctkm-avail           AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE VARIABLE o-uctkm-successful      AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE o-ctrh-id       LIKE trh_hist.trh_id        NO-UNDO.
DEFINE VARIABLE o-ctrh-error    AS LOGICAL INITIAL YES      NO-UNDO.

DEFINE BUFFER tk_mstr2 FOR TK_mstr.
DEFINE BUFFER tk_mstr3 FOR TK_mstr.

FOR EACH TK_mstr WHERE TK_mstr.TK_status = "":
    FIND FIRST tk_mstr2 WHERE tk_mstr2.TK_ID = TK_mstr.TK_ID AND tk_mstr2.tk_test_seq = TK_mstr.TK_test_seq AND tk_mstr2.tk_status <> "" NO-ERROR.
    FIND FIRST tk_mstr3 WHERE tk_mstr3.TK_lab_sample_ID = TK_mstr.TK_lab_sample_ID AND tk_mstr3.tk_lab_seq = TK_mstr.TK_lab_seq AND tk_mstr3.tk_status <> "" NO-ERROR.
    IF AVAILABLE (tk_mstr2) OR AVAILABLE (tk_mstr3) THEN DO:
        
        ASSIGN 
            tk_mstr.tk_deleted = TODAY 
            tk_mstr.tk_prog_name = "UTIL-tkmstr-fix-empty-status.r".
            
        FOR EACH trh_hist WHERE trh_hist.trh_serial = tk_mstr.tk_id AND trh_hist.trh_sequence = tk_mstr.tk_test_seq:
            ASSIGN 
                trh_hist.trh_deleted = TODAY
                trh_hist.trh_prog_name = "UTIL-tkmstr-fix-empty-status.r".
        END.
        
        FOR EACH tkr_det WHERE tkr_det.tkr_id = tk_mstr.tk_id AND tkr_det.tkr_test_seq = tk_mstr.tk_test_seq:
            ASSIGN 
                tkr_det.tkr_deleted = TODAY
                tkr_det.tkr_prog_name = "UTIL-tkmstr-fix-empty-status.r".
                
            FOR EACH bmpa_det WHERE bmpa_det.bmpa_id = tkr_det.tkr_id AND bmpa_det.bmpa_test_seq = tkr_det.tkr_test_seq AND bmpa_det.bmpa_item = tkr_det.tkr_item:
                ASSIGN 
                    bmpa_det.bmpa_deleted = TODAY
                    bmpa_det.bmpa_prog_name = "UTIL-tkmstr-fix-empty-status.r".
            END.
        END.
        
        FOR EACH bfm_mstr WHERE bfm_mstr.bfm_id = tk_mstr.tk_id AND bfm_mstr.bfm_test_seq = tk_mstr.tk_test_seq:
            ASSIGN 
                bfm_mstr.bfm_deleted = TODAY
                bfm_mstr.bfm_prog_name = "UTIL-tkmstr-fix-empty-status.r".
        END.
        
        FOR EACH bhe_mstr WHERE bhe_mstr.bhe_id = tk_mstr.tk_id AND bhe_mstr.bhe_test_seq = tk_mstr.tk_test_seq:
            ASSIGN 
                bhe_mstr.bhe_deleted = TODAY
                bhe_mstr.bhe_prog_name = "UTIL-tkmstr-fix-empty-status.r".
        END.
        
        FOR EACH btkr_det WHERE btkr_det.btkr_id = tk_mstr.tk_id AND btkr_det.btkr_test_seq = tk_mstr.tk_test_seq:
            ASSIGN 
                btkr_det.btkr_deleted = TODAY
                btkr_det.btkr_prog_name = "UTIL-tkmstr-fix-empty-status.r".
        END.
        
        FOR EACH btk_mstr WHERE btk_mstr.btk_id = tk_mstr.tk_id AND btk_mstr.btk_test_seq = tk_mstr.tk_test_seq:
            ASSIGN 
                btk_mstr.btk_deleted = TODAY
                btk_mstr.btk_prog_name = "UTIL-tkmstr-fix-empty-status.r".
        END.
        
        FOR EACH butee_mstr WHERE butee_mstr.butee_id = tk_mstr.tk_id AND butee_mstr.butee_test_seq = tk_mstr.tk_test_seq:
            ASSIGN 
                butee_mstr.butee_deleted = TODAY
                butee_mstr.butee_prog_name = "UTIL-tkmstr-fix-empty-status.r".
        END.
        
    END. /* IF AVAILABLE (tk_mstr2) OR AVAILABLE (tk_mstr3) */
    
    ELSE DO:
        /* Update the record's status to COMPLETE */
        RUN VALUE(SEARCH("SUBtkmstr-ucU.r")) (
            TK_mstr.TK_ID,
            "",
            ?,
            TK_mstr.TK_test_seq,
            ?,
            0,
            0,
            "",
            0,
            0,
            "",
            "COMPLETE",
            "",
            "",
            ?,
            ?,
            ?,
            "",
            ?,
            OUTPUT o-uctkm-id,
            OUTPUT o-uctkm-create,
            OUTPUT o-uctkm-update,
            OUTPUT o-uctkm-avail,
            OUTPUT o-uctkm-successful
        ).
        
        /* Create a trh_hist record reflecting our change to the TK_mstr's status */
        IF o-uctkm-successful THEN DO:
            FIND FIRST trh_hist WHERE trh_hist.trh_serial = TK_mstr.TK_ID NO-ERROR.
            IF AVAILABLE (trh_hist) THEN DO:
                RUN VALUE(SEARCH("SUBtrh-ucU.r")) (
                    0,
                    trh_hist.trh_item,      
                    "COMPLETE",    
                    trh_hist.trh_qty,       
                    trh_hist.trh_loc, 
                    trh_hist.trh_lot, 
                    trh_hist.trh_serial, 
                    trh_hist.trh_site, 
                    trh_hist.trh_sequence,  
                    trh_hist.trh_comments,  
                    trh_hist.trh_other_ID,  
                    trh_hist.trh_people_ID, 
                    trh_hist.trh_order,     
                    trh_hist.trh_date,      
                    trh_hist.trh_time,      
                    trh_hist.trh_ref,       
                    trh_hist.trh_warehouse,       
                    OUTPUT o-ctrh-id,
                    OUTPUT o-ctrh-error
                ).
            END. /* IF AVAILABLE (trh_hist) */
            ELSE DO:
                RUN VALUE(SEARCH("SUBtrh-ucU.r")) (
                    0,
                    "",
                    "COMPLETE",
                    0,
                    "",
                    "",
                    TK_mstr.TK_ID,
                    "",
                    0,
                    "",
                    "",
                    0,
                    "",
                    ?,
                    ?,
                    "",
                    "",
                    OUTPUT o-ctrh-id,
                    OUTPUT o-ctrh-error
                ).
                
            END.
        END. /* IF o-uctkm-successful */
    END.
END.
