
/*------------------------------------------------------------------------
    File        : fix-extra-testkits.p
    Purpose     : 

    Syntax      :

    Description : This is to fix the testkits that have been created by Chrissy 
                    in the old (BarTender) system, but don't exist in the new system.  
                    These are missing for 3 reasons - 1) Chrissy has the stickers 
                    still and hasn't given them to Pete, or 2) the testkits haven't 
                    even been shipped out yet (so they're not logged), or 3) for 
                    whatever reason they were not listed in the old system or in 
                    the TK Tracking spreadsheet.  Or I suppose they could have had 
                    bad data and gotten kicked out, so that's 4 ways.

    Author(s)   : Doug Luttrell
    Created     : Mon Jan 12 16:24:01 EST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE v-testtype LIKE TK_mstr.TK_testtype NO-UNDO.
DEFINE VARIABLE v-firstid AS INTEGER NO-UNDO.
DEFINE VARIABLE v-lastid AS INTEGER NO-UNDO.
DEFINE VARIABLE v-makekits AS LOGICAL LABEL "Make these kits?" INITIAL NO NO-UNDO.

DEFINE VARIABLE v-tkid LIKE TK_mstr.TK_ID NO-UNDO.

DEFINE VARIABLE v-missingkits AS INTEGER NO-UNDO.
DEFINE VARIABLE lastkit AS INTEGER NO-UNDO.

DEFINE VARIABLE x AS INTEGER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
FORM SKIP(1)
    v-testtype COLON 20
    v-firstid COLON 20 v-lastid COLON 60
    v-makekits COLON 20 SKIP(1)
    v-missingkits COLON 20 SKIP(1)
        WITH FRAME a WIDTH 80 SIDE-LABELS.  

/* ***************************  Main Block  *************************** */

main-loop:
REPEAT: 
    
ASSIGN 
    v-missingkits = 0.    
    
UPDATE SKIP(1)
    v-testtype 
        WITH FRAME a.    
    
FIND test_mstr WHERE test_mstr.test_type = v-testtype NO-LOCK NO-ERROR. 
    
FIND LAST TK_mstr WHERE TK_mstr.TK_testtype = v-testtype AND 
    TK_mstr.TK_ID BEGINS STRING(v-testtype + "-")
    USE-INDEX TK-main-idx 
    NO-LOCK NO-ERROR.
    
MESSAGE TK_mstr.TK_ID
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    
IF AVAILABLE (TK_mstr) THEN 
    v-firstid = IF tk_id BEGINS v-testtype THEN 
                    INTEGER(SUBSTRING(TK_mstr.tk_id,LENGTH(TK_mstr.TK_testtype) + 2)) + 1
                ELSE 
                    INTEGER(TK_mstr.tk_id) + 1.
    
UPDATE 
    v-firstid 
    v-lastid
    v-makekits
        WITH FRAME a.
    
DO x = v-firstid TO v-lastid:     

    v-tkid  = STRING(v-testtype + "-" + STRING(x)).
    
    FIND FIRST TK_mstr WHERE /* TK_mstr.TK_testtype = v-testtype AND */ 
        TK_mstr.TK_ID = v-tkid
            NO-LOCK NO-ERROR.
             
    IF NOT AVAILABLE (tk_mstr) THEN DO: 
        
        v-missingkits = v-missingkits + 1.
        
        IF v-makekits = YES THEN DO: 
            
            CREATE TK_mstr.
            ASSIGN 
                TK_mstr.TK_ID               = v-tkid   
                TK_mstr.TK_test_seq         = 1                
                TK_mstr.TK_created_by       = USERID("HHI")
                TK_mstr.TK_create_date      = 12/24/14
                TK_mstr.TK_cust_paid        = YES 
                TK_mstr.TK_domestic         = YES   /* YES = Domestic */                
                TK_mstr.TK_lab_ID           = IF AVAILABLE (test_mstr) THEN 
                                                    test_mstr.test_lab_id
                                              ELSE 
                                                    ""
                TK_mstr.TK_modified_by      = USERID("HHI")
                TK_mstr.TK_modified_date    = 12/24/14
                TK_mstr.TK_status           = "CREATED" 
                TK_mstr.TK_testtype         = test_mstr.test_type.
                
            CREATE trh_hist.
            ASSIGN 
                trh_hist.trh_ID             = NEXT-VALUE(seq-trh)
                trh_hist.trh_serial         = TK_mstr.TK_ID
                trh_hist.trh_sequence       = TK_mstr.TK_test_seq
                trh_hist.trh_qty            = 1
                trh_hist.trh_modified_date  = TK_mstr.TK_modified_date
                trh_hist.trh_modified_by    = TK_mstr.TK_modified_by
                trh_hist.trh_item           = TK_mstr.TK_testtype 
                trh_hist.trh_create_date    = TK_mstr.TK_create_date
                trh_hist.trh_created_by     = TK_mstr.TK_created_by
                trh_hist.trh_action         = TK_mstr.TK_status.
                
        END.  /** of if v-makekits = YES **/
        
        ELSE DO: 
            
            DISPLAY x v-missingkits 
                STRING(v-testtype + "-" + string(x)) FORMAT "x(16)"
                v-tkid
                lastkit
                "**" WHEN lastkit <> (x - 1)
                    WITH FRAME b DOWN.
            DOWN WITH FRAME b.
            
        END.  /** of else do --- v-makekits = NO **/
                    
        lastkit = x.
                        
    END.    /** of if not avail tk_mstr **/
    
END.  /* of do x = first to last */

DISPLAY v-missingkits 
    WITH FRAME a.
    
END.  /** of repeat --- main_loop **/
    