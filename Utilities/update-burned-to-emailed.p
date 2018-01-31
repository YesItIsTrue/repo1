FOR EACH TK_mstr WHERE TK_mstr.TK_status = "BURNED" EXCLUSIVE-LOCK:
    ASSIGN
        TK_mstr.TK_status = "EMAILED"
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_modified_by = USERID("Modules")
        TK_mstr.TK_prog_name = THIS-PROCEDURE:FILE-NAME.
END.

FOR EACH D_TK_mstr WHERE D_TK_mstr.D_TK_status = "BURNED" EXCLUSIVE-LOCK:
    ASSIGN 
        D_TK_mstr.D_TK_status = "EMAILED"
        D_TK_mstr.D_TK_modified_date = TODAY
        D_TK_mstr.D_TK_modified_by = USERID("Modules")
        D_TK_mstr.D_TK_prog_name = THIS-PROCEDURE:FILE-NAME.
END.

FOR EACH trh_hist WHERE trh_hist.trh_action = "BURNED" EXCLUSIVE-LOCK:
    ASSIGN 
        trh_hist.trh_action = "EMAILED"
        trh_hist.trh_modified_date = TODAY
        trh_hist.trh_modified_by = USERID("Modules")
        trh_hist.trh_prog_name = THIS-PROCEDURE:FILE-NAME.
END.