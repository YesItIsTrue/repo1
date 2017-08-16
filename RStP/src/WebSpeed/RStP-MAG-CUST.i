
/*------------------------------------------------------------------------
    File        : RStP-MAG-CUST.i

    Description : Temp table hold definations.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="8/Feb/15">
    <META NAME="LAST_UPDATED" CONTENT="8/Feb/15">

    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 8/Feb/15.
            
  ----------------------------------------------------------------------*/
 
/* ***************************  Definitions  ************************** */
 
DEFINE {1} {2} SHARED TEMP-TABLE RStP_MAG_CUST_Data 
        FIELD dr_tcp_id_scust_dr_id_int-col-F  AS CHARACTER FORMAT "x(60)"      /**  goes in doctor_mstr if > 0  **/               
        FIELD email-col-G                   AS CHARACTER FORMAT "x(80)"         /**  goes in people_mstr  **/                 
        FIELD prefix-col-J                  AS CHARACTER FORMAT "x(30)"         /** must be equal to billing_prefix-col-R **/           
        FIELD firstname-col-K               AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "First Name:"     /** must be equal to billing_firstname-col-S **/      
        FIELD middlename-col-L              AS CHARACTER FORMAT "x(60)"         /** must be equal to billing_middlename-col-T **/      
        FIELD lastname-col-M                AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "Last Name:"    /** must be equal to billing_lastname-col-U **/      
        FIELD suffix-col-N                  AS CHARACTER FORMAT "x(30)"         /** must be equal to billing_suffix-col-V  **/  
                                                                                /**   if NOT then  ABORT !!! we don't understand the data !!!! **/                     
        FIELD billing_prefix-col-R          AS CHARACTER FORMAT "x(60)"         /** must be equal to prefix-col-J **/                                                                           
        FIELD billing_firstname-col-S       AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "First Name:"     /** must be equal to firstname-col-K **/                                                                          
        FIELD billing_middlename-col-T      AS CHARACTER FORMAT "x(60)"         /** must be equal to middlename-col- **/     
        FIELD billing_lastname-col-U        AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "Last Name:"     /** must be equal to lastname-col-M **/     
        FIELD billing_suffix-col-V          AS CHARACTER FORMAT "x(60)"         /** must be equal to suffix-col-N **/   
                                                                                /**   if NOT then  Use the 1st set of names, no address, no doctor but rest of records. **/
 /* x THRU ai goes INTO address_mstr. */  
        FIELD billing_street1-col-X         AS CHARACTER FORMAT "x(80)"  
        FIELD billing_street2-col-Y         AS CHARACTER FORMAT "x(80)"      
        FIELD billing_street3-col-Z         AS CHARACTER FORMAT "x(60)"  
        FIELD billing_street4-col-AA        AS CHARACTER FORMAT "x(60)"  
        FIELD billing_street5-col-AB        AS CHARACTER FORMAT "x(60)"
        FIELD billing_street6-col-AC        AS CHARACTER FORMAT "x(60)"
        FIELD billing_street7-col-AD        AS CHARACTER FORMAT "x(60)"  
        FIELD billing_street8-col-AE        AS CHARACTER FORMAT "x(60)"  
        FIELD billing_city-col-AF           AS CHARACTER FORMAT "x(60)"  
        FIELD billing_region-col-AG         AS CHARACTER FORMAT "x(60)"         /** goes in the stateprov field in the address_mstr. **/        
        FIELD billing_country-col-AH        AS CHARACTER FORMAT "x(60)"
        FIELD billing_postcode-col-AI       AS CHARACTER FORMAT "x(60)"        
 /*  aj THRU al goes INTO created people_mstr. **/          
        FIELD billing_telephone-col-AJ      AS CHARACTER FORMAT "x(60)"  
        FIELD billing_company-col-AK        AS CHARACTER FORMAT "x(60)"  
        FIELD billing_fax-col-AL            AS CHARACTER FORMAT "x(60)"         
/* after creating the people_mstr:  IF doctor_tcp_coupon_code-col-BQ > "" then create a DOCTOR mstr   WITH people_id AND TCP CODE.
                                                    find or create a HHI: doctor,   General: people, address    
                                                       - using the data from the BILLING columns.      **/                                                               
        FIELD shipping_prefix-col-AM        AS CHARACTER FORMAT "x(60)"
        FIELD shipping_firstname-col-AN     AS CHARACTER FORMAT "x(60)" 
        FIELD shipping_middlename-col-AO    AS CHARACTER FORMAT "x(60)"
        FIELD shipping_lastname-col-AP      AS CHARACTER FORMAT "x(60)"   
        FIELD shipping_suffix-col-AQ        AS CHARACTER FORMAT "x(60)"          
/* as THRU bd goes INTO address_mstr. */  
        FIELD shipping_street1-col-AS       AS CHARACTER FORMAT "x(80)"  
        FIELD shipping_street2-col-AT       AS CHARACTER FORMAT "x(80)"
 /* STRING address-3 THRU 8 INTO address-line 3 in the address_mstr.  */          
        FIELD shipping_street3-col-AU       AS CHARACTER FORMAT "x(60)"
        FIELD shipping_street4-col-AV       AS CHARACTER FORMAT "x(60)"   
        FIELD shipping_street5-col-AW       AS CHARACTER FORMAT "x(60)"  
        FIELD shipping_street6-col-AX       AS CHARACTER FORMAT "x(60)"   
        FIELD shipping_street7-col-AY       AS CHARACTER FORMAT "x(60)"   
        FIELD shipping_street8-col-AZ       AS CHARACTER FORMAT "x(60)"   
        FIELD shipping_city-col-BA          AS CHARACTER FORMAT "x(60)"
        FIELD shipping_region-col-BB        AS CHARACTER FORMAT "x(60)"         /** goes in the stateprov field in the address_mstr. **/  
        FIELD shipping_country-col-BC       AS CHARACTER FORMAT "x(60)"  
        FIELD shipping_postcode-col-BD      AS CHARACTER FORMAT "x(60)" 
 /*  be THRU bg goes INTO created people_mstr. **/               
        FIELD shipping_telephone-col-BE     AS CHARACTER FORMAT "x(60)" 
        FIELD shipping_company-col-BF       AS CHARACTER FORMAT "x(60)"    
        FIELD shipping_fax-col-BG           AS CHARACTER FORMAT "x(60)"
        FIELD group-col-BJ                  AS CHARACTER FORMAT "x(60)"         /** new group-membership table with people-id & group-id as unique identifier */             
        FIELD gender-col-BN                 AS LOGICAL        
        FIELD skip-dob-col-BO               AS CHARACTER FORMAT "x(60)"  
        FIELD magento-id-BP                 AS INTEGER  COLUMN-LABEL "Magento ID:"
        FIELD doctor_tcp_coupon_code_col_BQ   AS CHARACTER FORMAT "x(60)"
               
        FIELD title_desc-J-N                AS CHARACTER FORMAT "x(30)"         /*  o-title_desc, */  
        FIELD prefname-J-N                  AS CHARACTER FORMAT "x(30)"         /*  o-prefname, */  
        FIELD genderhold-J-N                AS LOGICAL                          /*  o-gender, */      
        
        FIELD billing_title_desc-R-V        AS CHARACTER FORMAT "x(30)"         /*  o-title_desc, */  
        FIELD billing_prefname-R-V          AS CHARACTER FORMAT "x(30)"         /*  o-prefname, */  
        FIELD billing_genderhold-R-V        AS LOGICAL                          /*  o-gender, */     
        
        FIELD shipping_title_desc-AM-AQ     AS CHARACTER FORMAT "x(30)"         /*  o-title_desc, */ 
        FIELD shipping_prefname-AM-AQ       AS CHARACTER FORMAT "x(30)"         /*  o-prefname, */  
        FIELD shipping_genderhold-AM-AQ     AS LOGICAL.                         /*  o-gender, */  
                     
/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
