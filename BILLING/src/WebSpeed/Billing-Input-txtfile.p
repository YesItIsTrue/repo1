/*  <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.1">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="3/Apr/14">
    <META NAME="LAST_UPDATED" CONTENT="16/Jun/14">  
*/
/*------------------------------------------------------------------------
    File        : Billing-Input-txtfile.p
    Purpose     : Reads text data files.

    Syntax      : 

    Description : Program reads in TXT data files from the LABS and stores 
                  the input data in the bip_bill_input table.

    Notes       :
  ----------------------------------------------------------------------

    Revision History:
    1.0 - April 3, 2014.  Original Version.
    
    1.1 - June 16, 2014.  Modified previous code to reference/access the 
            new Progress Databases: General and 
            
  ----------------------------------------------------------------------*/ 
/* ***************************  Definitions  ************************** */
/* Include code. */ 

{../depot/src/WebSpeed/o-depot-definenames.i}.     /*** depot output define variables ***/    
   
/* Following define is for a test CSV input data file: */   
DEFINE TEMP-TABLE temp_Billing_Data
        FIELD ip-lab-id AS CHARACTER 
        FIELD ip-closng-date AS DATE 
        FIELD ip-account-nbr AS CHARACTER FORMAT "x(30)"
        FIELD ip-invoice-nbr AS CHARACTER FORMAT "x(30)"
        FIELD ip-invoice-date AS DATE 
        FIELD ip-amt-pass-due AS DECIMAL FORMAT "->,>>>,>>9.99"
        FIELD ip-total-amt-due AS DECIMAL FORMAT "->,>>>,>>9.99"  
        FIELD ip-payment-term AS CHARACTER FORMAT "x(20)"
        FIELD ip-sample-id AS CHARACTER FORMAT "x(30)"
        FIELD ip-activity-date AS DATE 
        FIELD ip-Pat-First-Name AS CHARACTER FORMAT "x(60)"
        FIELD ip-Pat-Mid-Name AS CHARACTER FORMAT "x(30)"
        FIELD ip-Pat-Last-Name AS CHARACTER FORMAT "x(60)"
        FIELD ip-Pat-Suffix AS CHARACTER FORMAT "x(60)"     
        FIELD ip-test-type AS CHARACTER FORMAT "x(60)"
        FIELD ip-amount AS DECIMAL FORMAT "->>,>>9.99" 
            INDEX temp-data AS PRIMARY ip-sample-id. 

 
DEFINE VARIABLE IP-Kount1           AS INTEGER NO-UNDO.
DEFINE VARIABLE IP-Kount2           AS INTEGER NO-UNDO. 
 
/* ********************  Preprocessor Definitions  ******************** */
 

/* ***************************  Main Block  *************************** */

/*  INPUT FROM "C:\OpenEdge\Workspace\BILLING\Billing-Input-Files\DDI-Billing-2014-01-20.csv".    */     
INPUT FROM "C:\OpenEdge\Workspace\BILLING\Billing-Input-Files\DDI-Billing-2014-02-28.txt". 
/*  INPUT FROM "C:\OpenEdge\Workspace\BILLING\Billing-Input-Files\DDI-Billing-Data.csv".        */ 

    REPEAT:
        
        CREATE  temp_Billing_Data.                                                              
        IMPORT DELIMITER "," temp_Billing_Data. 
/*          IMPORT DELIMITER "," ip-lab-id ip-closng-date ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^.    */  
                    
        IP-Kount1 = (IP-Kount1 + 1).

    END.  /** REPEAT **/ 
   
INPUT CLOSE.  

 MESSAGE "Records Imported to temp_Billing_Data = " IP-Kount1
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.    
    
/** end of input **/


/** move the temp table data to the LB_input_data table. **/

FOR EACH temp_Billing_Data NO-LOCK: 
 
    IF ip-sample-id <> "" THEN DO: 
        
        ASSIGN  ip-test-type = CAPS(ip-test-type)
                ip-sample-id = CAPS(ip-sample-id).
        
        CREATE  bip_bill_input. 
          
        ASSIGN 
            bip_bill_input.bip_seq                  = NEXT-VALUE (seq-bip) 
            bip_bill_input.bip_LAB_ID               = ip-lab-id 
            bip_bill_input.bip_Account_Nbr          = ip-account-nbr
            bip_bill_input.bip_Invoice_Nbr          = ip-invoice-nbr
            bip_bill_input.bip_Invoice_Date         = ip-invoice-date 
            bip_bill_input.bip_Total_Amt_Due        = ip-total-amt-due 
            bip_bill_input.bip_Payment_Term         = ip-payment-term 
            bip_bill_input.bip_Sample_ID            = ip-sample-id
            bip_bill_input.bip_Activity_Date        = ip-activity-date
            bip_bill_input.bip_Person_First_Name    = ip-Pat-First-Name
            bip_bill_input.bip_Person_Mid_Name      = ip-Pat-Mid-Name
            bip_bill_input.bip_Person_Last_Name     = ip-Pat-Last-Name
            bip_bill_input.bip_Person_Suffix        = ip-Pat-Suffix    
            bip_bill_input.bip_Test_Type            = ip-test-type   
            bip_bill_input.bip_Amount               = ip-amount
            bip_bill_input.bip_created_by           = USERID("HHI")
            bip_bill_input.bip_create_date          = TODAY
            bip_bill_input.bip_modified_by          = USERID("HHI")
            bip_bill_input.bip_modified_date        = TODAY
            .
            
        RELEASE bip_bill_input NO-ERROR.
        
        IP-Kount2 = (IP-Kount2 + 1).     
    END.    /** end of if.  **/ 
END.    /**  end of for loop.  **/


 MESSAGE ">>>>  Records moved to LB_input_data = " IP-Kount2
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.       
