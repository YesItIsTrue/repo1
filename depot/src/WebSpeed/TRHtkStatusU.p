
/*------------------------------------------------------------------------
    File        : TRHtkStatusU.p
    Purpose     : The segrigate this chunk of code that is used repeatiedly into its own sub program.

    Syntax      :

    Description : This is the anti-roll back code that has been used in some of the RStP programs as well as the DDI Dire Walk. 

    Author(s)   : Trae Luttrell
    Created     : Tue Jun 14 14:52:56 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/ 

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER datelist         AS DATE EXTENT 17               NO-UNDO.
DEFINE INPUT PARAMETER i-tk_id          LIKE TK_mstr.TK_ID              NO-UNDO.
DEFINE INPUT PARAMETER i-tk_seq         LIKE TK_mstr.TK_test_seq        NO-UNDO.
DEFINE INPUT PARAMETER updatemode       AS LOGICAL                      NO-UNDO.
DEFINE INPUT PARAMETER v-trh-comments   LIKE trh_hist.trh_comments      NO-UNDO.    
DEFINE INPUT PARAMETER v-trh-other      LIKE trh_hist.trh_other_ID      NO-UNDO.             
DEFINE INPUT PARAMETER v-trh-people     LIKE trh_hist.trh_people_ID     NO-UNDO.                
DEFINE INPUT PARAMETER v-trh-order      LIKE trh_hist.trh_order         NO-UNDO.            
DEFINE INPUT PARAMETER v-trh-date       LIKE trh_hist.trh_date          NO-UNDO.            
DEFINE INPUT PARAMETER v-trh-time       LIKE trh_hist.trh_time          NO-UNDO.            
DEFINE INPUT PARAMETER v-trh-ref        LIKE trh_hist.trh_ref           NO-UNDO.

DEFINE OUTPUT PARAMETER o-whatnowwhatnow AS LOGICAL INITIAL NO NO-UNDO.
DEFINE OUTPUT PARAMETER ERROR-count AS INTEGER EXTENT 11 NO-UNDO.

DEFINE VARIABLE statlist AS CHARACTER 
    INITIAL "CREATED,IN_STOCK,SOLD,SHIPPED,COLLECTED,LAB_RCVD,LAB_PROCESS,HHI_RCVD,LOADED,PROCESSED,PRINTED,BURNED,COMPLETE,PAID_BY_CUST,VEND_PAID,DELETED,VOID" NO-UNDO.      

DEFINE VARIABLE v-create-date   LIKE TK_mstr.TK_create_date     NO-UNDO.
DEFINE VARIABLE v-mod-date      LIKE TK_mstr.tk_modified_date   NO-UNDO.
DEFINE VARIABLE lazydate        AS DATE                         NO-UNDO.
DEFINE VARIABLE v-TKstat        LIKE TK_mstr.TK_status          NO-UNDO.
DEFINE VARIABLE x               AS INTEGER INITIAL 1            NO-UNDO.
DEFINE VARIABLE v-trhid         LIKE trh_hist.trh_id            NO-UNDO.
DEFINE VARIABLE v-trhfound      AS LOGICAL                      NO-UNDO. 
DEFINE VARIABLE v-seqNbr        AS INTEGER                      NO-UNDO.

DEFINE VARIABLE v-error         AS LOGICAL                      NO-UNDO.

DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\TRHtkStatusU-report.txt" NO-UNDO.        /* 1dot4 */ /* change to 2 for number 2 program */
 
OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "I don't actually have anything for this report".
   
/* ***************************  Main Block  *************************** */

DO x = 1 TO NUM-ENTRIES(statlist):
    
    IF datelist[x] <> ? THEN DO:                    
     
        ASSIGN 
            lazydate        = datelist[x]    
            v-create-date   = IF v-create-date <= lazydate THEN v-create-date ELSE (lazydate - 1)
            v-mod-date      = IF v-mod-date >= lazydate THEN v-mod-date ELSE lazydate                     
            v-tkstat        = ENTRY(x,statlist)
            v-trh-date      = lazydate.                         
    
        FIND tk_mstr WHERE 
            TK_mstr.TK_ID = i-tk_id AND 
            TK_mstr.TK_test_seq = i-tk_seq NO-LOCK NO-ERROR.
        
        IF AVAILABLE (tk_mstr) THEN DO:
           
            ASSIGN 
                v-trhid     = 0 
                v-trhfound  = NO.
                
            IF updatemode = YES THEN DO:
                                     
                RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
                    (TK_mstr.TK_test_type,                              /* 2dot0 */                                                   
                     v-tkstat,                                                              
                     TK_mstr.TK_ID,                                                         
                     TK_mstr.TK_test_seq,                                                   
                     lazydate,                                                              
                     OUTPUT v-trhid,                                                       
                     OUTPUT v-trhfound).                                                     
     
                IF v-trhfound = NO THEN DO: 
                            
                    RUN VALUE(SEARCH("SUBtrh-ucU.r"))
                        (0,
                        TK_mstr.TK_test_type,                           /* 2dot0 */
                        v-tkstat,
                        1,
                        "",
                        "",
                        TK_mstr.tk_ID,
                        "",
                        TK_mstr.TK_test_seq,                               
                        v-trh-comments,                                 /* 2dot0 */                    
                        v-trh-other,                                    /* 2dot0 */
                        v-trh-people,                                   /* 2dot0 */ 
                        v-trh-order,                                    /* 2dot0 */
                        v-trh-date,                                     /* 2dot0 */ 
                        v-trh-time,                                     /* 2dot0 */
                        v-trh-ref,                                      /* 2dot0 */       
                        "", /* warehouse */                       
                        OUTPUT X,
                        OUTPUT v-error).
                        
                    IF v-error = YES THEN DO: 
        
                        EXPORT STREAM outward DELIMITER ";"
                            TK_mstr.TK_ID                                                         
                            TK_mstr.TK_test_seq                                                  
                            lazydate
                            TK_mstr.TK_test_type                        /* 2dot0 */                                                  
                            v-tkstat      
                            "ERROR 9!  trh_hist create failed.". 
                            
                        ASSIGN ERROR-count[9] = ERROR-count[9]  + 1.
                        
                    END.  /*** OF ELSE DO --- ERROR TYPE ***/    
            
                END. /** update mode ***/
                    
            END.  /** of find trh_hist failed -- don't make extra records if they already exist **/                                             
            
            IF UPDATEmode = YES THEN DO:
                    
                IF LOOKUP(v-TKstat,statlist) > LOOKUP(TK_mstr.tk_status,statlist) THEN 
                    v-TKstat = v-TKstat.
                ELSE 
                    v-TKstat = TK_mstr.TK_status.
        
            END. /*** update mode ***/
        
            IF error-count[9] = 0 THEN ASSIGN o-whatnowwhatnow = YES.
        
        END.
        
        ELSE DO: /*** TK_mstr is unavaiable ***/
             
        END.
                
    END.             

END. 
    
/* **************************  End of Line  **************************** */ 

   