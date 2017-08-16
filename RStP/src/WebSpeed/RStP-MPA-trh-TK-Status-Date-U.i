/*------------------------------------------------------------------------
    File        : RStP-MPA-trh-TK-Status-Date-U.i
    Purpose     : Common code used multiply times with in the 
                : RStP-MPA_RCD-U.p program.

    Syntax      : 

    Description : Create trh_mstr history records for input 
                : MPA MPA_RCD data and the TK_status. 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Feb. 24, 2016.
                :   Created for Release 11_1,
                :   ISO code.
                 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
 
                        ASSIGN v-trhID     = 0 
                               v-trhfound  = NO.
                                             
                        RUN VALUE(SEARCH("SUBtrh-RStP-findR.r"))                                                                 
                            (TK_mstr.TK_test_type,                                                   
                             v-tkstat,                                                              
                             TK_mstr.TK_ID,                                                         
                             TK_mstr.TK_test_seq,                                                   
                             v-trh-date,                                                              
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
                                TK_mstr.TK_test_seq,
                                v-trh-comments,                     
                                v-trh-other,                                  
                                v-trh-people,                                    
                                v-trh-order,                                  
                                v-trh-date,                                      
                                v-trh-time,                                     
                                v-trh-ref,    
                                "", /* warehouse */                                    
                                OUTPUT X,
                                OUTPUT v-error).
                                
                            IF v-error = YES THEN DO: 
                
                                EXPORT STREAM outward DELIMITER ";"                                                
                                    MPA_RCD.PatientID
                                    MPA_RCD.MPA_Test_Kit_Nbr
                                    MPA_RCD.MPA_Test_Kit_Nbr_SeqNbr
                                    MPA_RCD.MPA_Sample_ID_Number
                                    MPA_RCD.MPA_Sample_ID_SeqNbr
                                    MPA_RCD.progress_flag
                                    "ERROR 9!  trh_hist create failed.". 
                                    
                                ASSIGN ERROR-count[9] = ERROR-count[9]  + 1.
                                
                            END.  /*** OF ELSE DO --- ERROR TYPE ***/    
                                
                        END.  /** of find trh_hist failed -- don't make extra records if they already exist **/    
/*  End of Include file or program. */