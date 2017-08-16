/**********************************************************************

    * Trae Luttrell, updated: 14/APR/16

    * This is the Data Verification Catch All Table Maintenance Transaction History and Test Kit Status Updating include file
        - aka: DVcaTRHstatusU.i

    * Needs to have a hold of the TK_mstr and the catch_all
    
    * It also happens to be in the exact spot where all the att_file checking needs to go, so that is going in this dot-i as well.

***********************************************************************/

/* ***************************  Attached Files Non-sense  ********************************* */

FIND FIRST att_files WHERE 
    att_files.att_category = "SOURCE CSV"                   AND
    att_files.att_deleted = ?                               AND 
    att_files.att_table  = "TK_mstr"                        AND 
    att_files.att_field1 = "TK_mstr.TK_lab_sample_id"       AND 
    att_files.att_value1 = v-lab_sample_ID                  AND
    att_files.att_field2 = "TK_mstr.TK_lab_seq"             AND 
    att_files.att_value2 = STRING(v-lab_seq)         
    NO-LOCK NO-ERROR.

IF AVAILABLE (att_files) THEN DO:

/*    {&OUT} "<tr><td colspan='6'> Holy crap there is a file already attached! </td></tr>".*/
    
END. /*** att_files available ***/    

ELSE DO:
                
    CREATE att_files.
        
    ASSIGN 
        att_files.att_file_id       = NEXT-VALUE(seq-attfile)
        att_files.att_category      = "SOURCE CSV"
        att_files.att_table         = "TK_mstr"
        att_files.att_field1        = "TK_mstr.TK_lab_sample_id"        
        att_files.att_value1        = v-lab_sample_ID                  
        att_files.att_field2        = "TK_mstr.TK_lab_seq"            
        att_files.att_value2        = STRING(v-lab_seq)
        att_files.att_filepath      = SUBSTRING(catch_all.catch_file_location, (R-INDEX(catch_all.catch_file_location,"\") + 1))
        att_files.att_filename      = SUBSTRING(catch_all.catch_file_location, 1, (R-INDEX(catch_all.catch_file_location,"\")))
        att_files.att_created_by    = USER("HHI")
        att_files.att_create_date   = TODAY
        att_files.att_modified_by   = USER("HHI")
        att_files.att_modified_date = TODAY
        att_files.att_prog_name     = THIS-PROCEDURE:FILE-NAME.
   
    RELEASE att_files.

/*    {&OUT} "<tr><td colspan='6'> Wowzers! I made a new attached file!</td></tr>".*/

END. /*** of att_files not available  ***/

/* ***************************  Main Block of TRH/TK status stuff *************************** */
 
ASSIGN                                                      /* reset variables to blank before use */
    v-create-date   = ?
    v-mod-date      = ?
    v-TKstat        = "".  

IF catch_all.catch_COLLECTED <> ? THEN DO: /******************************  COLLECTED  ***********************************/               

    ASSIGN 
        lazydate        = catch_all.catch_COLLECTED                   /* the lazy date saves typing */               
        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate 
        v-tkstat        = "COLLECTED"
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
            
/*        IF v-error = YES THEN DO:                                                                                    */
/*                                                                                                                     */
/*/*            {DL-DDIverifierExport.i 450 "PDF: Trh_hist COLLECTED not found, Error creating new record!" "Error"}.*/*/
/*                                                                                                                     */
/*        END.  /*** OF ELSE DO --- ERROR TYPE ***/                                                                    */
            
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
                    
/*                    {DL-DDIverifierExport.i 451 "PDF: Trh_hist COLLECTED found, different Date than PDF" "Error"}.*/
                    
            END. /*** of dates don't match ***/
            
        END. /**** of trh_hist avail ***/     
        
    END.  
    
    IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN
        v-TKstat = v-TKstat.
    ELSE
        v-TKstat = TK_mstr.TK_status.
        
    ASSIGN 
        TK_mstr.TK_status = v-TKstat
        TK_mstr.TK_modified_by = USER("HHI")
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_prog_name = THIS-PROCEDURE:FILE-NAME.
        
END. /* COLLECTED */

IF catch_all.catch_LAB_RCVD <> ? THEN DO: /******************************  LAB-RCVD  ***********************************/               

    ASSIGN 
        lazydate        = catch_all.catch_LAB_RCVD                   /* the lazy date saves typing */               
        v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
        v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate 
        v-tkstat        = "LAB_RCVD"
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
            
/*        IF v-error = YES THEN DO:                                                                             */
/*                                                                                                              */
/*            {DL-DDIverifierExport.i 452 "PDF: Trh_hist LAB-RCVD not found, Error create new record!" "Error"}.*/
/*                                                                                                              */
/*        END.  /*** OF ELSE DO --- ERROR TYPE ***/                                                             */
/*                                                                                                              */
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
                    
/*                    {DL-DDIverifierExport.i 453 "PDF: Trh_hist LAB-RCVD found, different Date than PDF" "Error"}.*/
                    
            END. /*** of dates don't match ***/
            
        END. /**** of trh_hist avail ***/    
        
    END.  
    
    IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN
        v-TKstat = v-TKstat.
    ELSE
        v-TKstat = TK_mstr.TK_status.
        
    ASSIGN 
        TK_mstr.TK_status = v-TKstat
        TK_mstr.TK_modified_by = USER("HHI")
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_prog_name = THIS-PROCEDURE:FILE-NAME.
        
END. /* LAB-RCVD */

IF catch_all.catch_LAB_PROCESS <> ? THEN DO: /******************************  LAB-PROCESS  ***********************************/               

    ASSIGN 
        lazydate        = catch_all.catch_LAB_PROCESS                   /* the lazy date saves typing */               
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
            
/*        IF v-error = YES THEN DO:                                                                                */
/*                                                                                                                 */
/*            {DL-DDIverifierExport.i 454 "PDF: Trh_hist LAB-PROCESS not found, Error create new record!" "Error"}.*/
/*                                                                                                                 */
/*        END.  /*** OF ELSE DO --- ERROR TYPE ***/                                                                */
            
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
                    
/*                    {DL-DDIverifierExport.i 455 "PDF: Trh_hist LAB-PROCESS found, different Date than PDF" "Error"}.*/
                    
            END. /*** of dates don't match ***/
            
        END. /**** of trh_hist avail ***/    
        
    END.  
    
    IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN
        v-TKstat = v-TKstat.
    ELSE
        v-TKstat = TK_mstr.TK_status.
        
    ASSIGN 
        TK_mstr.TK_status = v-TKstat
        TK_mstr.TK_modified_by = USER("HHI")
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_prog_name = THIS-PROCEDURE:FILE-NAME.
        
END. /* LAB-PROCESS */

IF catch_all.catch_HHI_RCVD <> ? THEN DO: /******************************  HHI_RCVD  ***********************************/               

    ASSIGN 
        lazydate        = catch_all.catch_HHI_RCVD                   /* the lazy date saves typing */               
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
            
/*        IF v-error = YES THEN DO:                                                                             */
/*                                                                                                              */
/*            {DL-DDIverifierExport.i 456 "PDF: Trh_hist HHI_RCVD not found, Error create new record!" "Error"}.*/
/*                                                                                                              */
/*        END.  /*** OF ELSE DO --- ERROR TYPE ***/                                                             */
            
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
                    
/*                    {DL-DDIverifierExport.i 457 "PDF: Trh_hist HHI_RCVD found, different Date than PDF" "Error"}.*/
                    
            END. /*** of dates don't match ***/
            
        END. /**** of trh_hist avail ***/    
        
    END.  
    
    IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN
        v-TKstat = v-TKstat.
    ELSE
        v-TKstat = TK_mstr.TK_status.
        
    ASSIGN 
        TK_mstr.TK_status = v-TKstat
        TK_mstr.TK_modified_by = USER("HHI")
        TK_mstr.TK_modified_date = TODAY
        TK_mstr.TK_prog_name = THIS-PROCEDURE:FILE-NAME.
        
END. /* HHI_RCVD */