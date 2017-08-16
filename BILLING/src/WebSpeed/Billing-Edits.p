/*  <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="14/Oct/14">
    <META NAME="LAST_UPDATED" CONTENT="dd/mmm/14">  
*/
/*------------------------------------------------------------------------
    File        : Billing-Edits.p
    Purpose     : 

    Syntax      :

    Description : Edits the basic input data fields from the HTML screens 
                : or the BATCH program. 

    Notes       :
 
    Revision History:
        1.0 - Oct. 14, 2014.  Original code.
        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE INPUT PARAMETER  hold-string-unmatch-reason      AS CHARACTER            NO-UNDO.

DEFINE OUTPUT PARAMETER Error-flag                      AS LOGICAL INITIAL NO   NO-UNDO.
    
DEFINE VARIABLE len                             AS INTEGER                      NO-UNDO.
DEFINE VARIABLE codetorun                       AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE op_text                         AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE Progress-Date                   AS DATE                         NO-UNDO. 
DEFINE VARIABLE ip-Stripped-Invoice-Date        AS DATE                         NO-UNDO.
DEFINE VARIABLE ip-Stripped-Activity-Date       AS DATE                         NO-UNDO.
DEFINE VARIABLE ip-Stripped-Bill-Due-Date       AS DATE                         NO-UNDO. 

/*  Following is the header info from the bill.  */ 
DEFINE VARIABLE ip-lab-id           LIKE bip_bill_input.bip_LAB_ID          NO-UNDO.
DEFINE VARIABLE ip-Account-Nbr      LIKE bip_bill_input.bip_Account_Nbr     NO-UNDO.
DEFINE VARIABLE ip-Invoice-Nbr      LIKE bip_bill_input.bip_Invoice_Nbr     NO-UNDO.
DEFINE VARIABLE ip-Invoice-Date     AS CHARACTER FORMAT "x(10)"                 NO-UNDO.
DEFINE VARIABLE ip-Total-Amt-Due    AS DECIMAL FORMAT "->>>,>>9.99"             NO-UNDO. 
DEFINE VARIABLE ip-Pay-Term         LIKE bip_bill_input.bip_Payment_Term    NO-UNDO.
DEFINE VARIABLE ip-Bill-Due-Date    AS CHARACTER FORMAT "x(10)"                 NO-UNDO.
/*  Following is the line item from the bill.  */
DEFINE VARIABLE ip-Sample-ID        LIKE bip_bill_input.bip_Sample_ID         NO-UNDO. 
DEFINE VARIABLE ip-Activity-Date    AS CHARACTER FORMAT "x(10)"                   NO-UNDO. 
DEFINE VARIABLE ip-Pat-First-Name   LIKE bip_bill_input.bip_Person_First_Name NO-UNDO.  
DEFINE VARIABLE ip-Pat-Mid-Name     LIKE bip_bill_input.bip_Person_Mid_Name   NO-UNDO.  
DEFINE VARIABLE ip-Pat-Last-Name    LIKE bip_bill_input.bip_Person_Last_Name  NO-UNDO.
DEFINE VARIABLE ip-Pat-Suffix       LIKE bip_bill_input.bip_Person_Suffix     NO-UNDO.  
DEFINE VARIABLE ip-Test-Type        LIKE bip_bill_input.bip_Test_Type         NO-UNDO.
DEFINE VARIABLE ip-Amount           AS  DECIMAL FORMAT "->>>,>>9.99"              NO-UNDO.
/*  End if the input bill/invoice data fields.  */

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


    IF ip-lab-id = "" THEN DO: 
        {&OUT} "<tr><th style='text-align:center;'>Lab ID is missing.</th></tr>".
/*                act = 3.      */
        ASSIGN len = LENGTH(hold-string-unmatch-reason).
        ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Lab|ID|is|missing.|".
        ASSIGN Error-flag = LOGICAL ("yes").                  
    END.  /** IF ip-lab-id = "" **/
            
    ASSIGN ip-Pay-Term = LC(ip-Pay-Term).
    RUN VALUE (codetorun) (ip-Pay-Term, OUTPUT op_text). 
    ASSIGN ip-Pay-Term = op_text.
    
    IF ip-Invoice-Nbr = "" THEN DO: 
        {&OUT} "<tr><th style='text-align:center;'>Invoice number is missing.</th></tr>".
/*                act = 3.      */
        ASSIGN len = LENGTH(hold-string-unmatch-reason).
        ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Invoice|Nbr|is|missing-Required!|".
        ASSIGN Error-flag = LOGICAL ("yes").                  
    END.  /** IF ip-Invoice-Nbr = "" **/ 
            
/*  MESSAGE ip-Invoice-Date VIEW-AS ALERT-BOX BUTTONS OK.       */
          
/*    ASSIGN  ip_text = ip-Invoice-Date.
    RUN "../depot/rcode/subr_CCYY_to_YY.r" (ip_text, OUTPUT op_text). 
    ASSIGN  ip-Stripped-Invoice-Date   =   DATE(op_text).  */
    RUN "../depot/rcode/subr_CCYY_to_YY.r" (ip-Invoice-Date, OUTPUT Progress-Date). 
    ASSIGN  ip-Stripped-Invoice-Date   =   Progress-Date.
                        
/*  MESSAGE ip-Stripped-Invoice-Date VIEW-AS ALERT-BOX BUTTONS OK.         */    
            
    IF ip-Sample-ID = "" THEN DO:
        {&OUT} "<tr><th style='text-align:center;'>Sample ID is missing.</th></tr>".
/*                act = 3.      */
        ASSIGN len = LENGTH(hold-string-unmatch-reason).
        ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Sample|ID|is|missing.|".
        ASSIGN Error-flag = LOGICAL ("yes").                  
    END.  /** IF ip-Sample-ID = ""  **/
    
    ELSE DO: 
         
        ASSIGN ip-Sample-ID = CAPS(ip-Sample-ID).
        
    END.  /**  ELSE DO: **/
            
/*  MESSAGE ip-Activity-Date VIEW-AS ALERT-BOX BUTTONS OK.           */
          
/*    ASSIGN  ip_text = ip-Activity-Date.
    RUN "../depot/rcode/subr_CCYY_to_YY.r" (ip_text, OUTPUT op_text). 
    ASSIGN  ip-Stripped-Activity-Date   =   DATE(op_text).  */
    RUN "../depot/rcode/subr_CCYY_to_YY.r" (ip-Activity-Date, OUTPUT Progress-Date). 
    ASSIGN  ip-Stripped-Activity-Date   =   Progress-Date.
             
/*  MESSAGE ip-Stripped-Activity-Date VIEW-AS ALERT-BOX BUTTONS OK.     */
            
    IF ip-Activity-Date = ? OR ip-Activity-Date = "" THEN DO: 
        {&OUT} "<tr><th style='text-align:center;'>Activity Date is missing.</th></tr>".
/*                act = 3.      */
         ASSIGN len = LENGTH(hold-string-unmatch-reason).
         ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Activity|Date|is|missing.|".
         ASSIGN Error-flag = LOGICAL ("yes").                   
     END.  /** IF ip-Activity-Date = ? OR ip-Activity-Date = "" **/
     
     IF ip-Stripped-Activity-Date > TODAY THEN DO: 
         {&OUT} "<tr><th style='text-align:center;'>Activity Date can NOT be greater than todays date.</th></tr>".
/*                act = 3.      */
         ASSIGN len = LENGTH(hold-string-unmatch-reason).
         ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Activity|Date|can|NOT|be|greater|than|todays|date.|".
         ASSIGN Error-flag = LOGICAL ("yes").                    
     END.  /** IF ip-Stripped-Activity-Date > TODAY **/  

/*  MESSAGE ip-Bill-Due-Date VIEW-AS ALERT-BOX BUTTONS OK.  */
            
/*     ASSIGN  ip_text = ip-Bill-Due-Date. 
     RUN "../depot/rcode/subr_CCYY_to_YY.r" (ip_text, OUTPUT op_text). 
     ASSIGN ip-Stripped-Bill-Due-Date   =   DATE(op_text).  */
     RUN "../depot/rcode/subr_CCYY_to_YY.r" (ip-Bill-Due-Date, OUTPUT Progress-Date). 
     ASSIGN  ip-Stripped-Bill-Due-Date   =   Progress-Date.
     
     IF ip-Stripped-Bill-Due-Date = ? OR ip-Bill-Due-Date = "" THEN DO:
         {&OUT} "<tr><th style='text-align:center;'>Bill Due Date is blank.</th></tr>".
/*                act = 3.      */
         ASSIGN len = LENGTH(hold-string-unmatch-reason).
         ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Bill|Due|Date|is|blank.|".
         ASSIGN Error-flag = LOGICAL ("yes").                
     END.  /** IF ip-Stripped-Bill-Due-Date = ? OR ip-Bill-Due-Date = "" **/
     
/*  MESSAGE ip-Stripped-Bill-Due-Date VIEW-AS ALERT-BOX BUTTONS OK.  */ 
                        
     IF ip-Pat-First-Name = "" THEN DO:
         {&OUT} "<tr><th style='text-align:center;'>Person First Name is missing.</th></tr>".
/*                act = 3.      */
         ASSIGN len = LENGTH(hold-string-unmatch-reason).
         ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Person|First|Name|is|missing.|".
         ASSIGN Error-flag = LOGICAL ("yes").                 
     END.  /** IF ip-Pat-First-Name = "" **/
            
     ELSE DO:  
         ASSIGN ip-Pat-First-Name = LC(ip-Pat-First-Name).
         RUN VALUE (codetorun) (ip-Pat-First-Name, OUTPUT op_text). 
         ASSIGN ip-Pat-First-Name = op_text. 
     END.  /** ELSE DO: **/ 
    
     ASSIGN ip-Pat-Mid-Name = LC(ip-Pat-Mid-Name).
     RUN VALUE (codetorun) (ip-Pat-Mid-Name, OUTPUT op_text). 
     ASSIGN ip-Pat-Mid-Name = op_text.
     
     ASSIGN ip-Pat-Suffix = LC(ip-Pat-Suffix).
     RUN VALUE (codetorun) (ip-Pat-Suffix, OUTPUT op_text). 
     ASSIGN ip-Pat-Suffix = op_text.
     
     IF ip-Pat-Last-Name = "" THEN DO:
         {&OUT} "<tr><th style='text-align:center;'>Person Last Name is missing.</th></tr>".
/*                act = 3.      */
         ASSIGN len = LENGTH(hold-string-unmatch-reason).
         ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Person|Last|Name|is|missing.|".
         ASSIGN Error-flag = LOGICAL ("yes").                 
     END.  /** IF ip-Pat-Last-Name = "" **/ 
            
     ELSE DO:  
         ASSIGN ip-Pat-Last-Name = LC(ip-Pat-Last-Name).
         RUN VALUE (codetorun) (ip-Pat-Last-Name, OUTPUT op_text). 
         ASSIGN ip-Pat-Last-Name = op_text.           
     END.  /** ELSE DO: **/ 
                
     IF ip-Test-Type = "" THEN DO:
         {&OUT} "<tr><th style='text-align:center;'>Test Type is missing.</th></tr>".
/*                act = 3.      */
         ASSIGN len = LENGTH(hold-string-unmatch-reason).
         ASSIGN SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Test|Type|is|missing.|".
         ASSIGN Error-flag = LOGICAL ("yes").               
     END.  /** IF ip-Test-Type = "" **/
     
     ELSE DO:  
         ASSIGN ip-Test-Type = CAPS(ip-Test-Type).
     END.  /** ELSE DO: **/
      
     IF ip-Total-Amt-Due = 0 THEN DO:
         {&OUT} "<tr><th style='text-align:center;'>Bill Total Amount Due can NOT be zero or blank.</th></tr>".
/*                act = 3.      */
         ASSIGN len = LENGTH(hold-string-unmatch-reason)
                SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Bill|Total|Amount|Due|can|NOT|be|zero|or|blank.|"
                Error-flag = LOGICAL ("yes").  
     END.  /** IF ip-Total-Amt-Due = 0 **/
     
     IF ip-Amount = 0 THEN DO: 
         {&OUT} "<tr><th style='text-align:center;'>Line Item Amount can NOT be zero or blank.</th></tr>".
/*                act = 3.      */
         ASSIGN len = LENGTH(hold-string-unmatch-reason)
                SUBSTRING(hold-string-unmatch-reason, (len + 1), 48) = "Line|Item|Amount|can|NOT|be|zero|or|blank.|"
                Error-flag = LOGICAL ("yes").  
     END.  /**  IF ip-Amount = 0 **/
     
     