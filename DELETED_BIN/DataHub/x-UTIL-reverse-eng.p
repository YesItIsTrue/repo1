
/*------------------------------------------------------------------------
    File        : UTIL-reverse-eng.p
    Purpose     : Data cleanup

    Syntax      :

    Description : Updates HHI database from MPA_ReEngineered_Date field in the RS database

    Author(s)   : Jacob Luttrell
    Created     : Wed Sep 30 13:07:45 MDT 2015
    Notes       :
                    To run the utility in update mode change:
                        report initial to yes
                        In the FOR EACH comment out NO-LOCKS's and comment in EXCLUSIVE-LOCK's
                        In the FIND comment out NO-LOCKS and comment in EXCLUSIVE-LOCK
     
     Version 1.1 - Written by Jacob Luttrell on 04/Mar/16. changed testtype to test_type (unmakred).
                    Changed the run program SUBtrh-RStP-ucU.p to SUBtrh-ucU.p with new field for v11.1 release.
                    Marked by 1dot1.               
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE x AS INTEGER LABEL "Number of Matching Files" NO-UNDO.
DEFINE VARIABLE y AS INTEGER LABEL "Updated Files" NO-UNDO.
DEFINE VARIABLE z AS INTEGER LABEL "Unmatched Files" NO-UNDO.
DEFINE VARIABLE report AS LOGICAL INITIAL NO NO-UNDO.

DEFINE VARIABLE v-create-date LIKE TK_mstr.TK_create_date NO-UNDO.
DEFINE VARIABLE v-mod-date    LIKE TK_mstr.tk_modified_date NO-UNDO.
DEFINE VARIABLE lazydate      AS DATE NO-UNDO.        /* because laziness is a virtue in a programmer */
DEFINE VARIABLE v-tkstat LIKE TK_mstr.TK_status NO-UNDO.
DEFINE VARIABLE v-trhid    LIKE trh_hist.trh_id NO-UNDO.
DEFINE VARIABLE v-trhfound AS LOGICAL NO-UNDO.  
DEFINE VARIABLE v-error AS LOGICAL NO-UNDO.

DEFINE VARIABLE statlist AS CHARACTER 
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,BURNED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO.

DEFINE VARIABLE itmessage AS LOGICAL INITIAL NO NO-UNDO.

DEFINE VARIABLE o-ctrh-id    LIKE trh_hist.trh_id NO-UNDO.      /* 1dot1 */
DEFINE VARIABLE o-ctrh-error AS LOGICAL INITIAL YES NO-UNDO.    /* 1dot1 */
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH MPA_RCD        WHERE MPA_RCD.MPA_ReEngineered_Date <> ?  AND
                              MPA_RCD.MPA_Nbr_of_SNP_IDs > 0 AND 
                              SUBSTRING(MPA_RCD.MPA_Test_Kit_Nbr,1,1) = "M" 
/*                              NO-LOCK,*/
                              EXCLUSIVE-LOCK,
    EACH PATIENT_RCD    WHERE PATIENT_RCD.PatientID = MPA_RCD.PatientID AND 
                              PATIENT_RCD.Pat_Verify_Flag = "Y"
/*                              NO-LOCK:*/
                              EXCLUSIVE-LOCK
                                  BREAK BY YEAR(MPA_RCD.MPA_DateCompleted):
                              
    
    FIND TK_mstr WHERE TK_mstr.TK_ID = MPA_RCD.MPA_Test_Kit_Nbr AND
                       TK_mstr.TK_test_seq = INTEGER(MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr) 
                       EXCLUSIVE-LOCK
/*                       NO-LOCK*/
                       NO-ERROR.                                                                                                       
                                                                                                        IF itmessage = YES THEN 
                                                                                                        DISPLAY 
                                                                                                            "Message 1" SKIP
                                                                                                            "AFTER: find tk_mstr" SKIP 
                                                                                                            "BEFORE: if avail tk_mstr." SKIP.                                                                                                                                                                                                             
        IF AVAILABLE TK_mstr THEN DO:
            
            x = x + 1.
            
/*            IF FIRST-OF (YEAR(MPA_RCD.MPA_DateCompleted)) THEN*/
/*                                                              */
/*                DISPLAY                                       */
/*                    TK_mstr.TK_ID FORMAT "x(24)".             */
            
            IF report = NO THEN DO:                    
                                                                                                        IF itmessage = YES THEN 
                                                                                                            DISPLAY
                                                                                                                "Message 2" SKIP
                                                                                                                "AFTER: if report = no" SKIP
                                                                                                                "BEFORE: Assign" SKIP.                               
                ASSIGN 
                    lazydate      = MPA_RCD.MPA_ReEngineered_Date    /* serves no purpose but to save me typing */
                    v-create-date = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
                    v-mod-date    = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                         
                    v-tkstat      = "PRINTED".
                        
                /********  Begin 1dot6 ***********/      
                ASSIGN 
                    v-trhid    = 0
                    v-trhfound = NO.
                                                                                                        IF itmessage = YES THEN 
                                                                                                            DISPLAY
                                                                                                                "Message 3" SKIP                                                                                                            
                                                                                                                "AFTER: Assign" SKIP
                                                                                                                "BEFORE: RUN...SUBthr...findR" SKIP.                                                             
                RUN VALUE(SEARCH("SUBtrh-RStP-findR.p"))                                                                 
                    (TK_mstr.TK_test_type,                                                   
                    v-tkstat,                                                              
                    TK_mstr.TK_ID,                                                         
                    TK_mstr.TK_test_seq,                                                   
                    lazydate,                                                              
                    OUTPUT v-trhid,                                                       
                    OUTPUT v-trhfound).                                                     
                                                                                                        IF itmessage = YES THEN 
                                                                                                            DISPLAY 
                                                                                                                "Message 4" SKIP
                                                                                                                "AFTER: RUN...SUBthr...findR" SKIP
                                                                                                                "BEFORE: If v-trhfound = NO" SKIP. 
                IF v-trhfound = NO THEN DO: 
                    /* 1dot1 --> */
                    RUN VALUE(SEARCH("SUBtrh-ucU.r"))
                    (0,                              /**  i-ctrh-id   **/
                        HHI.TK_mstr.TK_test_type,       /**  i-ctrh-item **/
                        HHI.TK_mstr.TK_status,          /**  i-ctrh-action **/
                        1,                              /**  i-ctrh-qty  **/
                        "",                             /**  i-ctrh-loc  **/
                        "",                             /**  i-ctrh-lot  **/
                        HHI.TK_mstr.TK_ID,              /**  i-ctrh-serial  **/
                        "",                             /**  i-ctrh-site  **/
                        HHI.TK_mstr.TK_test_seq,        /**  i-ctrh-sequence **/ 

                        "",                            /*i-ctrh-comments*/
                        TK_mstr.TK_magento_order,      /*i-ctrh-other   */
                        TK_mstr.Tk_cust_id,            /*i-ctrh-people  */
                        "",                            /*i-ctrh-order   */
                        TODAY,                         /*i-ctrh-date    */
                        STRING(TIME,"HH:MM:SS"),       /*i-ctrh-time    */
                        (TK_mstr.TK_lab_sample_ID + " / " + STRING(TK_mstr.TK_lab_seq)),      /*i-ctrh-ref     */
                  
                        OUTPUT o-ctrh-id,
                        OUTPUT o-ctrh-error).  
                   /* <-- 1dot1 */ 
                                      
/*                    RUN VALUE(SEARCH("SUBtrh-RStP-ucU.p"))                                /* 1dot5 */  */
/*                        (0,                                                                            */
/*                        TK_mstr.TK_test_type,                                                          */
/*                        v-tkstat,                                                                      */
/*                        1,                                                                             */
/*                        "",                                                                            */
/*                        "",                                                                            */
/*                        TK_mstr.tk_ID,                                                                 */
/*                        "",                                                                            */
/*                        TK_mstr.TK_test_seq,                                                           */
/*                        lazydate,                                                           /* 1dot6 */*/
/*                        OUTPUT X,                                                                      */
/*                        OUTPUT v-error).                                                               */
                                                                                                        IF itmessage = YES THEN 
                                                                                                            DISPLAY
                                                                                                                "Message 5" SKIP 
                                                                                                                "AFTER: RUN...SUBthr...ucU" SKIP
                                                                                                                "BEFORE: If v-error = YES" SKIP.        
                    IF v-error = YES THEN 
                    DO:
                
                        DISPLAY 
                            MPA_RCD.PatientID
                            MPA_RCD.MPA_Test_Kit_Nbr
                            MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr
                            MPA_RCD.MPA_Sample_ID_Number
                            MPA_RCD.MPA_Sample_ID_SeqNbr
                            MPA_RCD.progress_flag
                            "ERROR!  trh_hist create failed." WITH FRAME dude DOWN NO-LABELS.
                                    DOWN WITH FRAME dude. 
                                
                    END.  /*** OF ELSE DO --- ERROR TYPE ***/
                                
                END.  /** of find trh_hist failed -- don't make extra records if they already exist **/ 
              
            /************ End of 1dot6 ***************/ 
                                                                                                        IF itmessage = YES THEN 
                                                                                                            DISPLAY 
                                                                                                                "Message 6" SKIP
                                                                                                                "AFTER: END. /* of find trh_hist failed */ " SKIP
                                                                                                                "BEFORE: IF LOOKUP" SKIP.                
                /** don't allow the status to roll backwards **/                                
                IF LOOKUP(v-tkstat,statlist) > LOOKUP(TK_mstr.TK_status,statlist) THEN
                    ASSIGN 
                        TK_mstr.TK_status = v-tkstat.
                ELSE 
                    ASSIGN 
                        TK_mstr.TK_status = TK_mstr.TK_status.  
                /** end of prevent status rollback **/
                                      
                ASSIGN
                    TK_mstr.TK_prog_name     = THIS-PROCEDURE:FILE-NAME          /* 1dot4 */
                    v-create-date            = IF v-create-date = ? THEN TODAY ELSE v-create-date
                    v-mod-date               = IF v-mod-date = ? THEN TODAY ELSE v-mod-date
                    TK_mstr.TK_create_date   = IF TK_mstr.TK_create_date <= v-create-date THEN TK_mstr.TK_create_date ELSE v-create-date
                    TK_mstr.TK_created_by    = IF TK_mstr.TK_created_by = "" THEN USERID("HHI") ELSE TK_mstr.TK_created_by       /* 1dot6 */
                    TK_mstr.TK_modified_date = IF TK_mstr.TK_modified_date >= v-mod-date THEN TK_mstr.TK_modified_date ELSE v-mod-date
                    TK_mstr.TK_modified_by   = USERID("HHI")                                                                     /* 1dot6 */
                    TK_mstr.TK__dec01        = MPA_RCD.MPA_batch_number
                    TK_mstr.TK__dec02        = MPA_RCD.MPA_Nbr_of_SNP_IDs
                    TK_mstr.TK__char01       = "MPA"
                    MPA_RCD.Progress_Flag    = IF MPA_RCD.Progress_Flag = "A" OR MPA_RCD.Progress_Flag = "" THEN  
                                                            "AL"      /** stands for Add Loaded **/
                                                      ELSE IF MPA_RCD.Progress_Flag = "U" THEN
                                                            "UL"                                                            
                                                      ELSE 
                                                            "IL".     /** stands for Import Loaded **/
               
                y = y + 1.                
                
            END. /* report = no */
            
        END. /** if avail **/
          
        ELSE 
        DO:
            z = z + 1.
                        
/*            DISPLAY MPA_RCD.PatientID*/
/*                    MPA_RCD.MPA_Sample_ID_Number          */
/*                    MPA_RCD.Progress_Flag FORMAT "xx"     */
/*                    PATIENT_RCD.PatFirstName              */
/*                    PATIENT_RCD.PatLastName               */
/*                    PATIENT_RCD.Progress_Flag FORMAT "xx".*/
            
        END.
END. 

DISPLAY x y z.