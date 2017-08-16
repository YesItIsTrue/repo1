/*------------------------------------------------------------------------
    File        : RStP-TESTS-trh-TK-Status-Date-U.i
    Purpose     : Common code used multiply times with in the 
                : RStP-TESTS_RESULT_RCD-U.p program.

    Syntax      : 

    Description : Create trh_mstr history records for input 
                : BioMed TESTS-RESULT data. 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Sun Sep 27, 2015
     
    Version: 2.0    By Harold Luttrell, Sr.
    Date: 5/Mar/16.
    Description:    Changed database field name from 
                        TK_mstr.TK_testtype to TK_mstr.TK_test_type
                        and added TRH_hist new fields.                    
    Identified by /* 2dot0 */  
           
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */

                        ASSIGN 
                            v-trhid     = 0
                            v-trhfound  = NO.
                                             
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
                                
                        END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    

