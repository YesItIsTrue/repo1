
/*------------------------------------------------------------------------
    File        : DL-DDItrh-hist.i

    Description : This is stolen out of the RStP-MPA_RCD-U-1 program to check 
                to see if the history is complete or not and then to fill in the 
                empty spots, and produce an error for when they conflict.

    Author(s)   : Trae Luttrell
    Created     : Wed Oct 21 10:29:31 EDT 2015
    Updated     : Wed Oct 21 10:29:31 EDT 2015
    Version     : 1.0
    Notes       : Needs to be placed in side a successful find on the TK_mstr
  ----------------------------------------------------------------------*/

/* ***************************  Main Block  *************************** */
 
ASSIGN                                                      /* reset variables to blank before use */
    v-create-date   = ?
    v-mod-date      = ?
    v-TKstat        = "".  

     /*   MESSAGE "Inside the TRH.i Section Head: COLLECTED." SKIP
                "" i-filename VIEW-AS ALERT-BOX BUTTONS OK. */

IF i-trh-COLLECTED <> ? THEN DO: /******************************  COLLECTED  ***********************************/               

    ASSIGN 
        lazydate        = i-trh-COLLECTED                   /* the lazy date saves typing */               
        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate 
        v-tkstat        = "COLLECTED"
        v-trhid         = 0
        v-trhfound      = NO.
        
       /* MESSAGE "Inside the TRH.i:COLLECTED." SKIP
                "Pre-RUN trh FIND." VIEW-AS ALERT-BOX BUTTONS OK.  */
                                       
    RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                  
        (TK_mstr.TK_test_type,                                                   
         v-tkstat,                                                               
         TK_mstr.TK_ID,                                                         
         TK_mstr.TK_test_seq,                                                   
         lazydate,                                                              
         OUTPUT v-trhid,                                                       
         OUTPUT v-trhfound).
                                                              
        /* MESSAGE "Inside the TRH.i:COLLECTED." SKIP
                "Post-RUN trh FIND." SKIP
                "Found? = " v-trhfound VIEW-AS ALERT-BOX BUTTONS OK. */
                 
    IF v-trhfound = NO THEN DO: 
    
        /* MESSAGE "Inside the TRH.i:COLLECTED." SKIP
                "Pre-RUN trh ucU." VIEW-AS ALERT-BOX BUTTONS OK. */
                
       RUN VALUE(SEARCH("SUBtrh-ucU.r"))   
            (0,
            TK_mstr.TK_test_type,
            v-tkstat,
            1,
            "",
            "",
            TK_mstr.tk_ID,
            "",
            tk_mstr.tk_test_seq,
            "",
            "",
            0,
            "",
            lazydate,
            "",
            "",    
            "", /* warehouse */                                                              
            OUTPUT v-trhid-new,
            OUTPUT v-error).
    
       /* MESSAGE "Inside the TRH.i:COLLECTED." SKIP
                "Post-RUN trh ucU." VIEW-AS ALERT-BOX BUTTONS OK. */
                   
        IF v-error = YES THEN DO: 

            {DL-DDIverifierExport.i 4450 "PDF: Trh_hist COLLECTED not found, Error creating new record!" "Warning"}.
            
        END.  /*** OF ELSE DO --- ERROR TYPE ***/    
            
    END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
    
    ELSE IF v-trhfound = YES THEN DO:
    
        FIND trh_hist WHERE 
            trh_hist.trh_ID = v-trhid AND 
            trh_hist.trh_deleted = ? NO-LOCK NO-ERROR.
            
        IF AVAILABLE (trh_hist) THEN DO:
        
            IF  trh_hist.trh_create_date <> ?  AND 
                trh_hist.trh_create_date <> lazydate AND 
                trh_hist.trh_create_date <> v-create-date AND 
                trh_hist.trh_deleted = ? THEN DO:
                    
                    {DL-DDIverifierExport.i 4451 "PDF: Trh_hist COLLECTED found, different Date than PDF" "Warning"}.
                    
            END. /*** of dates don't match ***/
            
        END. /**** of trh_hist avail ***/    
        
    END.  
    
    IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN
        v-TKstat = v-TKstat.
    ELSE
        v-TKstat = TK_mstr.TK_status.   
        
    ASSIGN 
        TK_mstr.TK_status = v-TKstat
        TK_mstr.TK_modified_by = USERID("HHI")
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_prog_name = "DL-DDIverifier.p".
        
END. /* COLLECTED */

     /*   MESSAGE "Inside the TRH.i Section Head: LAB-RCVD." SKIP
                "" VIEW-AS ALERT-BOX BUTTONS OK. */
                
IF i-trh-LAB-RCVD <> ? THEN DO: /******************************  LAB-RCVD  ***********************************/               

    ASSIGN 
        lazydate        = i-trh-LAB-RCVD                   /* the lazy date saves typing */               
        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate 
        v-tkstat        = "LAB_RCVD"
        v-trhid         = 0
        v-trhfound      = NO.
                    
     /*  MESSAGE "Inside the TRH.i:LAB-RCVD." SKIP
                "Pre-RUN trh FIND." SKIP
                "test_type = " tk_test_type skip
                "Status = " v-tkstat skip
                "TK_ID = " tk_id skip
                "Test Seq = " tk_test_seq SKIP
                "lazydate = " lazydate skip
                
                    VIEW-AS ALERT-BOX BUTTONS OK.    */                 
                         
    RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
        (TK_mstr.TK_test_type,                                                   
         v-tkstat,                                                              
         TK_mstr.TK_ID,                                                         
         TK_mstr.TK_test_seq,                                                   
         lazydate,                                                              
         OUTPUT v-trhid,                                                       
         OUTPUT v-trhfound).                                                   

     /*  MESSAGE "Inside the TRH.i:LAB-RCVD." SKIP
                "Post-RUN trh FIND." VIEW-AS ALERT-BOX BUTTONS OK. */
                
    IF v-trhfound = NO THEN DO: 
    
          /* MESSAGE "Inside the TRH.i:LAB-RCVD." SKIP
                "Pre-RUN trh UPDATE." VIEW-AS ALERT-BOX BUTTONS OK. */
    
        RUN VALUE(SEARCH("SUBtrh-ucU.r"))   
            (0,
            TK_mstr.TK_test_type,
            v-tkstat,
            1,
            "",
            "",
            TK_mstr.tk_ID,
            "",
            tk_mstr.tk_test_seq,
            "",
            "",
            0,
            "",
            lazydate,
            "",
            "",    
            "", /* warehouse */                                                              
            OUTPUT v-trhid-new,
            OUTPUT v-error).
            
         /*  MESSAGE "Inside the TRH.i:LAB-RCVD." SKIP
                "Post-RUN trh UPDATE." VIEW-AS ALERT-BOX BUTTONS OK. */
            
        IF v-error = YES THEN DO: 

            {DL-DDIverifierExport.i 4452 "PDF: Trh_hist LAB-RCVD not found, Error create new record!" "Warning"}.
            
        END.  /*** OF ELSE DO --- ERROR TYPE ***/    
            
    END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
    
    ELSE IF v-trhfound = YES THEN DO:
    
        FIND trh_hist WHERE 
            trh_hist.trh_ID = v-trhid AND 
            trh_hist.trh_deleted = ? NO-LOCK NO-ERROR.
            
       IF AVAILABLE (trh_hist) THEN DO:
        
            IF  trh_hist.trh_create_date <> ?  AND 
                trh_hist.trh_create_date <> lazydate AND 
                trh_hist.trh_create_date <> v-create-date AND 
                trh_hist.trh_deleted = ? THEN DO:
                    
                    {DL-DDIverifierExport.i 4453 "PDF: Trh_hist LAB-RCVD found, different Date than PDF" "Warning"}.
                    
            END. /*** of dates don't match ***/
            
        END. /**** of trh_hist avail ***/    
        
    END.  
    
    IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN
        v-TKstat = v-TKstat.
    ELSE
        v-TKstat = TK_mstr.TK_status.
        
    ASSIGN 
        TK_mstr.TK_status = v-TKstat
        TK_mstr.TK_modified_by = USERID("HHI")
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_prog_name = "DL-DDIverifier.p".
        
END. /* LAB-RCVD */
 /*
        MESSAGE "Inside the TRH.i Section Head: LAB-PROCESS." SKIP
                "" VIEW-AS ALERT-BOX BUTTONS OK.
*/
IF i-trh-LAB-PROCESS <> ? THEN DO: /******************************  LAB-PROCESS  ***********************************/               

    ASSIGN 
        lazydate        = i-trh-LAB-PROCESS                   /* the lazy date saves typing */               
        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate 
        v-tkstat        = "LAB_PROCESS"
        v-trhid         = 0
        v-trhfound      = NO.
                         
    RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
        (TK_mstr.TK_test_type,                                                   
         v-tkstat,                                                              
         TK_mstr.TK_ID,                                                         
         TK_mstr.TK_test_seq,                                                   
         lazydate,                                                              
         OUTPUT v-trhid,                                                       
         OUTPUT v-trhfound).                                                     

    IF v-trhfound = NO THEN DO: 
    
        RUN VALUE(SEARCH("SUBtrh-ucU.r"))   
            (0,
            TK_mstr.TK_test_type,
            v-tkstat,
            1,
            "",
            "",
            TK_mstr.tk_ID,
            "",
            tk_mstr.tk_test_seq,
            "",
            "",
            0,
            "",
            lazydate,
            "",
            "",          
            "", /* warehouse */                                                        
            OUTPUT v-trhid-new,
            OUTPUT v-error).
            
        IF v-error = YES THEN DO: 

            {DL-DDIverifierExport.i 4454 "PDF: Trh_hist LAB-PROCESS not found, Error create new record!" "Warning"}.
            
        END.  /*** OF ELSE DO --- ERROR TYPE ***/    
            
    END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
    
    ELSE IF v-trhfound = YES THEN DO:
    
        FIND trh_hist WHERE 
            trh_hist.trh_ID = v-trhid AND 
            trh_hist.trh_deleted = ? NO-LOCK NO-ERROR.
            
        IF AVAILABLE (trh_hist) THEN DO:
        
            IF  trh_hist.trh_create_date <> ?  AND 
                trh_hist.trh_create_date <> lazydate AND 
                trh_hist.trh_create_date <> v-create-date AND 
                trh_hist.trh_deleted = ? THEN DO:
                    
                    {DL-DDIverifierExport.i 4455 "PDF: Trh_hist LAB-PROCESS found, different Date than PDF" "Warning"}.
                    
            END. /*** of dates don't match ***/
            
        END. /**** of trh_hist avail ***/    
        
    END.  
    
    IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN
        v-TKstat = v-TKstat.
    ELSE
        v-TKstat = TK_mstr.TK_status.
    
    ASSIGN 
        TK_mstr.TK_status = v-TKstat
        TK_mstr.TK_modified_by = USERID("HHI")
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_prog_name = "DL-DDIverifier.p".
        
END. /* LAB-PROCESS */
/*
        MESSAGE "Inside the TRH.i Section Head: HHI_RCVD." SKIP
                "" VIEW-AS ALERT-BOX BUTTONS OK.
*/
IF i-createdate <> ? THEN DO: /******************************  HHI_RCVD  ***********************************/               

    ASSIGN 
        lazydate        = i-createdate                   /* the lazy date saves typing */               
        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate 
        v-tkstat        = "HHI_RCVD"
        v-trhid         = 0
        v-trhfound      = NO.
                         
    RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
        (TK_mstr.TK_test_type,                                                   
         v-tkstat,                                                              
         TK_mstr.TK_ID,                                                         
         TK_mstr.TK_test_seq,                                                   
         lazydate,                                                              
         OUTPUT v-trhid,                                                       
         OUTPUT v-trhfound).                                                     

    IF v-trhfound = NO THEN DO: 
    
        RUN VALUE(SEARCH("SUBtrh-ucU.r"))   
            (0,
            TK_mstr.TK_test_type,
            v-tkstat,
            1,
            "",
            "",
            TK_mstr.tk_ID,
            "",
            tk_mstr.tk_test_seq,
            "",
            "",
            0,
            "",
            lazydate,
            "",
            "",          
            "", /* warehouse */                                                        
            OUTPUT v-trhid-new,
            OUTPUT v-error).
            
        IF v-error = YES THEN DO: 

            {DL-DDIverifierExport.i 4456 "PDF: Trh_hist HHI_RCVD not found, Error create new record!" "Warning"}.
            
        END.  /*** OF ELSE DO --- ERROR TYPE ***/    
            
    END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
    
    ELSE IF v-trhfound = YES THEN DO:
    
        FIND trh_hist WHERE 
            trh_hist.trh_ID = v-trhid AND 
            trh_hist.trh_deleted = ? NO-LOCK NO-ERROR.
            
        IF AVAILABLE (trh_hist) THEN DO:
        
            IF  trh_hist.trh_create_date <> ?  AND 
                trh_hist.trh_create_date <> lazydate AND 
                trh_hist.trh_create_date <> v-create-date AND 
                trh_hist.trh_deleted = ? THEN DO:
                    
                    {DL-DDIverifierExport.i 4457 "PDF: Trh_hist HHI_RCVD found, different Date than PDF" "Warning"}.
                    
            END. /*** of dates don't match ***/
            
        END. /**** of trh_hist avail ***/    
        
    END.  
    
    IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN
        v-TKstat = v-TKstat.
    ELSE
        v-TKstat = TK_mstr.TK_status.
                  
    ASSIGN 
        TK_mstr.TK_status = v-TKstat
        TK_mstr.TK_modified_by = USERID("HHI")
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_prog_name = "DL-DDIverifier.p".
        
END. /* HHI_RCVD */

/*/** put in a catch to make sure that we don't move a status backwards during an Update **/*/
/*            IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN        */
/*                v-TKstat = v-TKstat.                                                      */
/*            ELSE                                                                          */
/*                v-TKstat = TK_mstr.TK_status.                                             */
