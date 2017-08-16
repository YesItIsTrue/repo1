/*  <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.3">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="3/Apr/14">
    <META NAME="LAST_UPDATED" CONTENT="25/Oct/14">  
*/
/*------------------------------------------------------------------------
    File        : Billing-Match-UnMatch.p
    Purpose     : Matches the Billing detail data (bip_bill_input record) 
                  for payment(s) to be made to the LABS.  
                  Matching critieria is on Persons last name, first name, 
                  sample-ID number and LABS charge amount.  If a match is made, 
                  UPDATE the status of the Test-Kit in the TK_mstr, Sold_det, 
                  bm_bill_mstr and the bd_bill_det records and 
                  delete the input BILL_IP_data record.  
                  
                  If no match, flag the bip_bill_input record as 
                  a no-match item by updating the bip_UnMatched_Date &
                  the bip_UnMatched_reason, leaving the record in the bip_bill_input table.

    Description : Validates the Billing detail data from the Labs to see if 
                  their Bills (Invoices) should be paid or not.

    Notes       : Based on the 2 sample input Bills (Invoices). 
    
  ----------------------------------------------------------------------
 
    Revision History:
    1.0 - April 3, 2014.  Original code.
    
    1.1 - June 16, 2014.  Modified previous code to reference/access the 
            new Progress Databases: General and 
            
    1.2 - July 8, 2014.  Modified previous code to reference/access the 
            new Progress Databases: General and HHI tables and apply the
            utility find-patient.p code.
            
    1.3 - Oct 25, 2014 - added the META infomation for identification.  
                      
  ----------------------------------------------------------------------*/ 

/* *****************  DATABASE Transaction Processing  **************** */
BLOCK-LEVEL ON ERROR UNDO, THROW.
  
/* ***************************  Definitions  ************************** */
/* Include code. */ 

{../depot/src/WebSpeed/o-depot-definenames.i}.     /*** depot output define variables ***/    
   
DEFINE VARIABLE pgm                         AS CHARACTER FORMAT "x(40)" NO-UNDO.
 
DEFINE VARIABLE IP-len                      AS INTEGER                  NO-UNDO.
DEFINE VARIABLE Match-sample-ID             AS CHARACTER FORMAT "X(31)" NO-UNDO. 
DEFINE VARIABLE chgx   AS CHARACTER NO-UNDO. 
/* ********************  Preprocessor Definitions  ******************** 

ASSIGN pgm = 'SampleId-Billing-Match-UnMatch.p'.    */

/* ***************************  Main Block  *************************** */

FOR EACH bip_bill_input 
    WHERE bip_bill_input.bip_UnMatched_Reason = "" : 
          
    IF AVAILABLE (bip_bill_input) THEN DO:    

/*               DISPLAY    bip_bill_input.bip_seq SKIP 
                          bip_bill_input.bip_Person_First_Name  FORMAT "x(30)" SKIP  
                          bip_bill_input.bip_Person_Last_Name FORMAT "x(30)" SKIP  
                          bip_bill_input.bip_LAB_ID SKIP 
                          bip_bill_input.bip_Invoice_Nbr SKIP
                          bip_bill_input.bip_Sample_ID SKIP
                          WITH FRAME a SIDE-LABELS DOWN.
                   DOWN WITH FRAME a.    
*/
         IF ( bip_bill_input.bip_Person_First_Name = "" AND 
              bip_bill_input.bip_Person_Last_Name  = ""  ) THEN DO:
                DELETE  bip_bill_input NO-ERROR.
                RELEASE bip_bill_input NO-ERROR.
                NEXT.          
        END. 
                   
        IF ( bip_bill_input.bip_Person_First_Name = "PREVIOUS" AND 
                bip_bill_input.bip_Person_Last_Name  = "BALANCE" )   OR 
             bip_bill_input.bip_Person_First_Name = "CHECK"       OR 
           ( bip_bill_input.bip_Person_First_Name = "" AND 
                bip_bill_input.bip_Person_Last_Name  = ""  ) 
             THEN DO:
                DELETE  bip_bill_input NO-ERROR.        
                RELEASE bip_bill_input NO-ERROR.      
                NEXT.                   
        END.    /* if previous balance or check */
        
        IF ( bip_bill_input.bip_Person_First_Name = "CANCELLED" AND 
            bip_bill_input.bip_Person_Last_Name  = "KIT"  ) THEN DO:
                ASSIGN  
                    bip_bill_input.bip_UnMatched_Date   = TODAY 
                    bip_bill_input.bip_UnMatched_Reason = 
                        'How do I handle this input record   ????????????'
                    bip_bill_input.bip_modified_by      = USERID("General")
                    bip_bill_input.bip_modified_date    = TODAY.
                RELEASE bip_bill_input NO-ERROR.
                NEXT.          
        END. 
              
        ASSIGN  IP-len   = LENGTH(bip_bill_input.bip_Sample_ID)
                Match-sample-ID = "*"
                SUBSTRING (Match-sample-ID, 2, IP-len) = bip_bill_input.bip_Sample_ID.
                 
        IF  SUBSTRING(bip_bill_input.bip_Sample_ID, 1, 1) > "9" THEN 
                ASSIGN  Match-sample-ID = "*" 
                        SUBSTRING (Match-sample-ID, 2, (IP-len - 1) ) = 
                            SUBSTRING (bip_bill_input.bip_Sample_ID, 2, (IP-len - 1) ).    
                        
 /*   MESSAGE   "Match-sample-ID =" Match-sample-ID    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.   */                                                          
 
        FIND  TK_mstr
            WHERE TK_mstr.TK_lab_sample_ID MATCHES(Match-sample-ID) AND                                  
                  TK_mstr.Tk_lab_seq        = 1 AND 
                  TK_mstr.TK_deleted        = ?                   
                EXCLUSIVE-LOCK NO-ERROR.
    
        IF NOT AVAILABLE (TK_mstr) THEN DO:
            ASSIGN  
               bip_bill_input.bip_UnMatched_Date   = TODAY 
               bip_bill_input.bip_UnMatched_Reason = 
                                "Test Kit Master record not found for Sample ID." 
               bip_bill_input.bip_modified_by      = USERID("General")
               bip_bill_input.bip_modified_date    = TODAY.  
            RELEASE bip_bill_input NO-ERROR.
            NEXT.
        END.    /*  NOT AVAILABLE (TK_mstr)  */        
        
        IF AVAILABLE (TK_mstr) THEN DO:
            FIND  lab_mstr
                WHERE lab_mstr.lab_ID = bip_bill_input.bip_LAB_ID
                    NO-LOCK NO-ERROR.
            FIND FIRST test_mstr
                WHERE  (test_mstr.test_type     = bip_bill_input.bip_Test_Type  OR          
                        test_mstr.test_name     = bip_bill_input.bip_Test_Type) AND 
                       (test_mstr.test_lab_ID   = bip_bill_input.bip_LAB_ID     OR 
                        test_mstr.test_lab_ID   = lab_mstr.lab_name)   AND  
                       test_mstr.test_deleted   = ? 
                    NO-LOCK NO-ERROR.
                 
            IF NOT AVAILABLE (test_mstr) THEN DO:
                ASSIGN  
                    bip_bill_input.bip_UnMatched_Date   = TODAY 
                    bip_bill_input.bip_UnMatched_Reason = 
                                    "Test Master record not found for test-type or test-name and Lab Name." 
                    bip_bill_input.bip_modified_by      = USERID("General")
                    bip_bill_input.bip_modified_date    = TODAY.  
                                      
                RELEASE bip_bill_input NO-ERROR.
                NEXT.
            END.    /**  IF NOT AVAILABLE (test_mstr)  **/
        
            IF AVAILABLE (test_mstr) THEN DO: 
                
                IF bip_bill_input.bip_Amount <> test_mstr.test_cost THEN DO: 
                    ASSIGN  
                       bip_bill_input.bip_UnMatched_Date   = TODAY 
                       bip_bill_input.bip_UnMatched_Reason = 
                                        "Invoice $ amount NOT equal to Test Master Lab test cost." 
                       bip_bill_input.bip_modified_by      = USERID("General")
                       bip_bill_input.bip_modified_date    = TODAY.  
                    RELEASE bip_bill_input NO-ERROR.
                    NEXT.
                END.    /** IF bip_bill_input.bip_Charges <> test_mstr.test_cost  **/  
            END.    /**  IF AVAILABLE (test_mstr)  **/
        END.    /**  IF AVAILABLE (TK_mstr)  **/
                                            
        IF AVAILABLE (TK_mstr) THEN DO:
           
             FIND FIRST bd_bill_det 
                    WHERE   bd_bill_det.bd_vendor_ref   = bip_bill_input.bip_Sample_ID  AND 
                            bd_bill_det.bd_serial       = TK_mstr.TK_ID AND 
                            bd_bill_det.bd_Invoice_Nbr  = bip_bill_input.bip_Invoice_Nbr AND 
                            bd_bill_det.bd_deleted      = ?
                        EXCLUSIVE-LOCK NO-ERROR.
                        
             IF AVAILABLE (bd_bill_det) THEN DO: 
                 
 /* DISPLAY "Found bd_bill_det = "  bip_bill_input.bip_Sample_ID SKIP
             " TK_mstrTK-ID  = "  TK_mstr.TK_ID SKIP 
         " DUPE - update record-delete field."
    WITH FRAME a SIDE-LABELS DOWN.
    DOWN WITH FRAME a.  */
    
  /*  Flag for deletetion - DUPE input Lab detail bill/invoice line item.  */ 
                                       
                ASSIGN  bd_bill_det.bd_modified_by      = USERID("General")
                        bd_bill_det.bd_modified_date    = TODAY
                        bd_bill_det.bd_deleted          = TODAY.
                RELEASE bd_bill_det NO-ERROR.   
/* ?????               NEXT.            */
 /*               DELETE  bd_bill_det.  */
                
                FIND FIRST bd_bill_det 
                    WHERE   bd_bill_det.bd_vendor_ref   = bip_bill_input.bip_Sample_ID  AND 
                            bd_bill_det.bd_serial       = TK_mstr.TK_ID AND
                            bd_bill_det.bd_Invoice_Nbr  = bip_bill_input.bip_Invoice_Nbr AND  
                            bd_bill_det.bd_deleted      = ?
                        NO-LOCK NO-ERROR.

            END.    /**   IF AVAILABLE (bd_bill_det)  **/    
             
            IF NOT AVAILABLE (bd_bill_det) THEN DO: 
/*                 
DISPLAY "NOT-Found bd_bill_det = " SKIP 
               bip_bill_input.bip_Sample_ID SKIP
               TK_mstr.TK_ID SKIP 
             " Creating detail bill record." SKIP 
    WITH FRAME a SIDE-LABELS DOWN.
    DOWN WITH FRAME a.  
*/    
                DO TRANSACTION:         /** Start Database TRANSACTION processing for ROLLBACK of UPDATES if error occurs. **/
                    
                    CREATE bd_bill_det.
                    
                    ASSIGN 
                        bd_bill_det.bd_Invoice_Nbr          = bip_bill_input.bip_Invoice_Nbr
                        bd_bill_det.bd_serial               = TK_mstr.TK_ID        
                        bd_bill_det.bd_People_ID            = TK_mstr.TK_patient_id
                        bd_bill_det.bd_vendor_ref           = bip_bill_input.bip_Sample_ID 
                        bd_bill_det.bd_Activity_Date        = bip_bill_input.bip_Activity_Date
                        bd_bill_det.bd_Amount               = bip_bill_input.bip_Amount
                        bd_bill_det.bd_Amount_Action_Codes  = ""
                        bd_bill_det.bd_Paid_Date            = ?
                        bd_bill_det.bd_item                 = bip_bill_input.bip_Test_Type
                        bd_bill_det.bd__char01              = TK_mstr.TK_lab_sample_ID
                        bd_bill_det.bd_created_by           = USERID("General")
                        bd_bill_det.bd_create_date          = TODAY 
                        bd_bill_det.bd_modified_by          = USERID("General")
                        bd_bill_det.bd_modified_date        = TODAY
                    .
                    RELEASE bd_bill_det NO-ERROR.  
                    
                    FIND FIRST bm_bill_mstr
                        WHERE   bm_bill_mstr.bm_vendor_ID   =  bip_bill_input.bip_LAB_ID AND 
                                bm_bill_mstr.bm_Invoice_Nbr =  bip_bill_input.bip_Invoice_Nbr AND 
                                bm_bill_mstr.bm_deleted     = ?
                            NO-LOCK NO-ERROR.
                    
                    IF NOT AVAILABLE (bm_bill_mstr) THEN DO:
                              
/*                                    
DISPLAY "NOT-Found bm_bill_mstr= "  SKIP 
                bip_bill_input.bip_LAB_ID SKIP
                bip_bill_input.bip_Invoice_Nbr SKIP
                bip_bill_input.bip_Invoice_Date SKIP 
                bill-due-date SKIP  
               "  Creating bill master record." SKIP 
        WITH FRAME a SIDE-LABELS DOWN.
        DOWN WITH FRAME a.    
*/                    
                        CREATE bm_bill_mstr.
                        
                        ASSIGN 
                            bm_bill_mstr.bm_Paid_Date       =  ? 
                            
                            bm_bill_mstr.bm_vendor_ID       =  bip_bill_input.bip_LAB_ID
                            bm_bill_mstr.bm_Invoice_Date    =  bip_bill_input.bip_Invoice_Date  
                            bm_bill_mstr.bm_Due_Date        =  bip_bill_input.bip__date01
                            bm_bill_mstr.bm_Invoice_Nbr     =  bip_bill_input.bip_Invoice_Nbr
                            bm_bill_mstr.bm_Invoice_Amt     =  bip_bill_input.bip_Total_Amt_Due
                            bm_bill_mstr.bm_Paid_Date       =  ? 
                            bm_bill_mstr.bm_Payment_Term    =  bip_bill_input.bip_Payment_Term 
                            bm_bill_mstr.bm_Account_Nbr     =  bip_bill_input.bip_Account_Nbr  
                            bm_bill_mstr.bm_created_by      =  USERID("General")
                            bm_bill_mstr.bm_create_date     =  TODAY
                            bm_bill_mstr.bm_modified_by     =  USERID("General")
                            bm_bill_mstr.bm_modified_date   =  TODAY.                                 
                     
                        RELEASE bm_bill_mstr NO-ERROR.
                               
                    END.  /*  IF NOT AVAILABLE (bm_bill_mstr)  */
                                 
                    DELETE  bip_bill_input NO-ERROR.        
                    RELEASE bip_bill_input NO-ERROR.                         
                    NEXT.
                    
                    CATCH err AS Progress.Lang.Error :
                        MESSAGE "Database Error occured: " err:GetMessage(1)
                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.       
                    END CATCH.
                    
                END.  /** DO TRANSACTION:  */   /** End Database TRANSACTION processing for ROLLBACK of UPDATES if error occurs. **/
                              
             END.    /**   IF NOT AVAILABLE (bd_bill_det)  **/  
                
        END.    /* IF AVAILABLE (TK_mstr)  */                                  
                
    END.    /** end of IF avail BILL_IP_data.  **/ 

    RELEASE TK_mstr NO-ERROR. 
    RELEASE bip_bill_input NO-ERROR.  
        
END.    /** end of FOR EACH.  **/          
          
    