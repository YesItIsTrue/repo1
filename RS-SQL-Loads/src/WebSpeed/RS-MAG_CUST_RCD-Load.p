   
/*------------------------------------------------------------------------
    File        : RS-MAG_CUST_RCD-Load.p                                        /** 1dot2 **/
    Purpose     : Updates the MAGENTO Customer Record in the RS database.

    Description : Production program to read the selected (by date) 
                : Magento extracted .txt file and Update/Create the data 
                : in the MAG_CUST_RCD table 
                : in the RS database for future reference.
                
    Databases   : 
    
    Table       : MAG_CUST_RCD.
    
    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.2">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="7/Feb/15">
    <META NAME="LAST_UPDATED" CONTENT="3/Mar/15">

    Version 1.0 Feb 7, 2015 - by Harold Sr.
                :   Original code. 
                    
    Version 1.1 Feb 10, 2015 - by Harold Sr.
                :   Removed the input data fields that are no longer needed
                :   and changed the input delimiter to ; as the new standard. 
                :   Identified by: /** 10feb15 **/
               
    Version 1.2 Mar 3, 2015 - by Harold Sr.
                :   Changed program name to match the other Load program names
                :   and added code if a database error occured.
                :   Identified by: /** 1dot2 **/ 
              
    Version 1.3 Aug 20, 2015 - by Harold Sr.
                :   Changed code to use the emailaddr-USERID.i 
                :   statement instead of hard-coded user's e-mail ID's.
                :   Identified by: /** 1dot3 **/ 
                
    Version 1.4 Sept 17, 2015 - by Harold Sr.
                :   Changed code to use the emailaddr-USERID.i 
                :   statement from the RS-SQL-Loads/src folder instead of 
                :   the depot folder.  This saves changing the location
                :   from the server to the PC's.  Also changed code to 
                :   MAG_CUST_RCD instead of the &SCOPED-DEFINE this-table   MAG_CUST_RCD.
                :   Identified by: /** 1dot4 **/

    Version: 2.0    By Harold Luttrell, Sr.
        Date: 9/Feb/16.
            Added code to use the new ISO SUBcountry-findR.r and the new
            :   ISO SUBstate-findR.r programs to validate the 
            :   input country and state values to make sure they are in 
            :   the ISO formats.  If not, then change them to the ISO formats.
            :   If inputs are not found then generate an ISO Error Log report
            :   and e-mail it to magento.interface@holistichealth.com for review.        
        Identified by /* 2dot0 */ 
                                                                       
  ----------------------------------------------------------------------*/
     
/* ***************************  Definitions  ************************** */
/** 10feb15 **/
/* input file data field names:                     
doctor_tcp_id;email;prefix;firstname;middlename;lastname;suffix;
billing_prefix;billing_firstname;billing_middlename;billing_lastname;billing_suffix;
billing_street_1;billing_street_2;billing_street_3;billing_street_4;billing_street_5;billing_street_6;billing_street_7;billing_street_8;
billing_city;billing_region;billing_country;billing_postcode;billing_telephone;billing_company;billing_fax;
shipping_prefix;shipping_firstname;shipping_middlename;shipping_lastname;shipping_suffix;
shipping_street_1;shipping_street_2;shipping_street_3;shipping_street_4;shipping_street_5;shipping_street_6;shipping_street_7;shipping_street_8;
shipping_city;shipping_region;shipping_country;shipping_postcode;shipping_telephone;shipping_company;shipping_fax;
group;gender;dob;customer_id;doctor_tcp_coupon_code;test_kit_purchased
*/
/** 10feb15 **/

DEFINE  TEMP-TABLE Magento_Data 
        FIELD IP_dr_tcp_id_scust_dr_id_col-F  AS CHARACTER FORMAT "x(60)"       /**  goes in doctor_mstr if > 0  **/               
        FIELD IP_email-col-G                   AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "   E-Mail:"     /**  goes in people_mstr  **/
                  
        FIELD IP_prefix-col-J                  AS CHARACTER FORMAT "x(30)"      /** must be equal to billing_prefix-col-R **/           
        FIELD IP_firstname-col-K               AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "First Name:"     /** must be equal to billing_firstname-col-S **/      
        FIELD IP_middlename-col-L              AS CHARACTER FORMAT "x(60)"      /** must be equal to billing_middlename-col-T **/      
        FIELD IP_lastname-col-M                AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "Last Name:"    /** must be equal to billing_lastname-col-U **/      
        FIELD IP_suffix-col-N                  AS CHARACTER FORMAT "x(30)"      /** must be equal to billing_suffix-col-V  **/  
                                                                                /**   if NOT then  ABORT !!! we don't understand the data !!!! **/
                     
        FIELD IP_billing_prefix-col-R          AS CHARACTER FORMAT "x(60)"      /** must be equal to prefix-col-J **/                                                                           
        FIELD IP_billing_firstname-col-S       AS CHARACTER FORMAT "x(60)"      /** must be equal to firstname-col-K **/                                                                          
        FIELD IP_billing_middlename-col-T      AS CHARACTER FORMAT "x(60)"      /** must be equal to middlename-col- **/     
        FIELD IP_billing_lastname-col-U        AS CHARACTER FORMAT "x(60)"       /** must be equal to lastname-col-M **/     
        FIELD IP_billing_suffix-col-V          AS CHARACTER FORMAT "x(60)"      /** must be equal to suffix-col-N **/   
                                                                                /**   if NOT then  ABORT !!! we don't understand the data !!!! **/
                                                                                                                                                                                      
/*        FIELD IP_billing_street_full-col-W     AS CHARACTER FORMAT "x(80)"     /** SKIP FIELD.  **/*/

 /* x THRU ai goes INTO address_mstr. */  
        FIELD IP_billing_street1-col-X         AS CHARACTER FORMAT "x(80)"      COLUMN-LABEL "Street Address 1"
        FIELD IP_billing_street2-col-Y         AS CHARACTER FORMAT "x(80)"      COLUMN-LABEL "Street Address 2"
 /* STRING address-3 THRU 8 INTO address-line 3 in the address_mstr.  */       
        FIELD IP_billing_street3-col-Z         AS CHARACTER FORMAT "x(60)"  
        FIELD IP_billing_street4-col-AA        AS CHARACTER FORMAT "x(60)"  
        FIELD IP_billing_street5-col-AB        AS CHARACTER FORMAT "x(60)"
        FIELD IP_billing_street6-col-AC        AS CHARACTER FORMAT "x(60)"
        FIELD IP_billing_street7-col-AD        AS CHARACTER FORMAT "x(60)"  
        FIELD IP_billing_street8-col-AE        AS CHARACTER FORMAT "x(60)"  
        FIELD IP_billing_city-col-AF           AS CHARACTER FORMAT "x(60)"      
        FIELD IP_billing_region-col-AG         AS CHARACTER FORMAT "x(60)"      /** goes in the stateprov FIELD IP_in the address_mstr. **/        
        FIELD IP_billing_country-col-AH        AS CHARACTER FORMAT "x(60)"     
        FIELD IP_billing_postcode-col-AI       AS CHARACTER FORMAT "x(60)" 
        
 /*  aj THRU al goes INTO created people_mstr. **/          
        FIELD IP_billing_telephone-col-AJ      AS CHARACTER FORMAT "x(60)"  
        FIELD IP_billing_company-col-AK        AS CHARACTER FORMAT "x(60)"  
        FIELD IP_billing_fax-col-AL            AS CHARACTER FORMAT "x(60)" 
         
/* after creating the people_mstr:  IF doctor_tcp_coupon_code-col-BQ > "" then create a DOCTOR mstr   WITH people_id AND TCP CODE.
                                                    find or create a HHI: doctor,   General: people, address    
                                                       - using the data from the BILLING columns.      **/   
                                                            
        FIELD IP_shipping_prefix-col-AM        AS CHARACTER FORMAT "x(60)"
        FIELD IP_shipping_firstname-col-AN     AS CHARACTER FORMAT "x(60)" 
        FIELD IP_shipping_middlename-col-AO    AS CHARACTER FORMAT "x(60)"
        FIELD IP_shipping_lastname-col-AP      AS CHARACTER FORMAT "x(60)"   
        FIELD IP_shipping_suffix-col-AQ        AS CHARACTER FORMAT "x(60)" 
              
/*        FIELD IP_shipping_street_full-col-AR   AS CHARACTER FORMAT "x(80)"     /** SKIP FIELD.  **/*/
           
/* as THRU bd goes INTO address_mstr. */  
        FIELD IP_shipping_street1-col-AS       AS CHARACTER FORMAT "x(80)"      COLUMN-LABEL "Street Address 1"        
        FIELD IP_shipping_street2-col-AT       AS CHARACTER FORMAT "x(80)"      COLUMN-LABEL "Street Address 2"
 /* STRING address-3 THRU 8 INTO address-line 3 in the address_mstr.  */          
        FIELD IP_shipping_street3-col-AU       AS CHARACTER FORMAT "x(60)"
        FIELD IP_shipping_street4-col-AV       AS CHARACTER FORMAT "x(60)"   
        FIELD IP_shipping_street5-col-AW       AS CHARACTER FORMAT "x(60)"  
        FIELD IP_shipping_street6-col-AX       AS CHARACTER FORMAT "x(60)"   
        FIELD IP_shipping_street7-col-AY       AS CHARACTER FORMAT "x(60)"   
        FIELD IP_shipping_street8-col-AZ       AS CHARACTER FORMAT "x(60)"   
        FIELD IP_shipping_city-col-BA          AS CHARACTER FORMAT "x(60)"      
        FIELD IP_shipping_region-col-BB        AS CHARACTER FORMAT "x(60)"        /** goes in the stateprov FIELD IP_in the address_mstr. **/  
        FIELD IP_shipping_country-col-BC       AS CHARACTER FORMAT "x(60)"      
        FIELD IP_shipping_postcode-col-BD      AS CHARACTER FORMAT "x(60)" 
 
 /*  be THRU bg goes INTO created people_mstr. **/               
        FIELD IP_shipping_telephone-col-BE     AS CHARACTER FORMAT "x(60)" 
        FIELD IP_shipping_company-col-BF       AS CHARACTER FORMAT "x(60)"    
        FIELD IP_shipping_fax-col-BG           AS CHARACTER FORMAT "x(60)"

        FIELD IP_group-col-BJ                  AS CHARACTER FORMAT "x(60)"      /** new group-membership table with people-id & group-id as unique identifier */        
             
        FIELD IP_gender-col-BN                 AS CHARACTER FORMAT "x(60)"        
        FIELD IP_skip-dob-col-BO               AS CHARACTER FORMAT "x(60)"  
        FIELD IP_magento-id-BP                 AS CHARACTER FORMAT "x(10)"  COLUMN-LABEL "Magento-ID" 
        FIELD IP_doctor_tcp_coupon_code_col_BQ   AS CHARACTER FORMAT "x(60)"
/*        FIELD IP_order_count-col-BR            AS CHARACTER FORMAT "x(60)"*/
        FIELD IP_test_kit_purchased-col-BS     AS CHARACTER FORMAT "x(60)"            

                  INDEX temp-data         AS PRIMARY UNIQUE IP_magento-id-BP. 
                      
/* ********************  Preprocessor Definitions  ******************** */
             
DEFINE VARIABLE recordsprocessed AS INTEGER LABEL "Records Processed"    NO-UNDO.
DEFINE VARIABLE Updated-cnt AS INTEGER LABEL "Records Updated"           NO-UNDO.
DEFINE VARIABLE Created-cnt AS INTEGER LABEL "Records Created"           NO-UNDO.
DEFINE VARIABLE Bypassed-cnt AS INTEGER LABEL "Records Bypassed"         NO-UNDO.

/* 2dot0 */                                                                                 /* 2dot0 */
DEFINE VARIABLE BadBState-cnt AS INTEGER LABEL "Billing State not found"        NO-UNDO.    /* 2dot0 */
DEFINE VARIABLE BadBCountry-cnt AS INTEGER LABEL "Billing Country not found"    NO-UNDO.    /* 2dot0 */
DEFINE VARIABLE BadSState-cnt AS INTEGER LABEL "Shipping State not found"       NO-UNDO.    /* 2dot0 */
DEFINE VARIABLE BadSCountry-cnt AS INTEGER LABEL "Shipping Country not found"   NO-UNDO.    /* 2dot0 */
DEFINE VARIABLE h-message AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "Error Message" NO-UNDO. /* 2dot0 */
DEFINE VARIABLE h-city    AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "City" NO-UNDO.          /* 2dot0 */
DEFINE VARIABLE h-region  AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "Region/State" NO-UNDO.  /* 2dot0 */
DEFINE VARIABLE h-country AS CHARACTER FORMAT "x(60)" COLUMN-LABEL "Country" NO-UNDO.       /* 2dot0 */
DEFINE VARIABLE h-pgm-name AS CHARACTER FORMAT "x(60)" NO-UNDO.                             /* 2dot0 */
DEFINE VARIABLE starting-position AS INTEGER NO-UNDO.                                       /* 2dot0 */
/* 2dot0 */                                                                                 /* 2dot0 */

DEFINE VARIABLE disp-msg    AS CHARACTER FORMAT "x(40)" COLUMN-LABEL "Description"    NO-UNDO.
DEFINE VARIABLE database-error-cnt AS INTEGER COLUMN-LABEL "database Errors"    NO-UNDO.    /** 1dot2 **/
  
DEFINE VARIABLE limitdisplay                AS INTEGER INITIAL 0 NO-UNDO.        /** a non-zero number will limit displays to that many records **/

DEFINE VARIABLE loadedlist      AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.  

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r magento.interface@holistichealth.com"          NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Log Report attached from "                     NO-UNDO.    /** 1dot3 **/
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Log Report from "                              NO-UNDO.    /** 1dot3 **/
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.
 
DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

ASSIGN starting-position = R-INDEX (THIS-PROCEDURE:FILE-NAME, "\").                                                     /* 2dot0 */

ASSIGN h-pgm-name = SUBSTRING(THIS-PROCEDURE:FILE-NAME, (starting-position + 1), LENGTH (THIS-PROCEDURE:FILE-NAME) ).   /* 2dot0 */

ASSIGN messagetxt = messagetxt  + "\n"
                                + THIS-PROCEDURE:FILE-NAME
                                + "\n"
                                + "End of message.".
                                
ASSIGN subjtxt = subjtxt + h-pgm-name.                                          /* 2dot0 */
   
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RS-MAG_CUST_RCD-Load-log.txt"                      NO-UNDO.

OUTPUT  STREAM outward TO value(errlog).
DISPLAY STREAM outward 
          "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" SKIP  (2)  
          "Start of input processing at: " TODAY STRING(TIME, "HH:MM:SS") SKIP (2)      /* 2dot0 */
         WITH FRAME outheader WIDTH 132 SIDE-LABELS.

/* 2dot0 */                                                                     /* 2dot0 */
DEFINE STREAM outwardISO.
DEFINE VARIABLE ISOlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RS-MAG_CUST_RCD-Load-ISO-log.txt"                  NO-UNDO.

OUTPUT  STREAM outwardISO TO value(ISOlog).
DISPLAY STREAM outwardISO 
          "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" SKIP  (2)  
          "Start of input processing at: " TODAY STRING(TIME, "HH:MM:SS") SKIP (2) 
         WITH FRAME outISOheader WIDTH 180 SIDE-LABELS.

/* 2dot0 */                                                                     /* 2dot0 */
                 
/* ********************  Preprocessor Definitions  ******************** */
/*&SCOPED-DEFINE this-table   MAG_CUST_RCD*/                                 /** 1dot4 **/
    
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.              

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

{emailaddr-USERID.i}                                                            /** 1dot4 **/

DEFINE VARIABLE o-fcountry-ISO     LIKE country_mstr.Country_ISO        NO-UNDO.
DEFINE VARIABLE o-fcountry-error   AS LOGICAL                                   NO-UNDO. 
DEFINE VARIABLE o-fstate-ISO       LIKE state_mstr.state_country_ISO    NO-UNDO.
DEFINE VARIABLE o-fstate-error     AS LOGICAL                                   NO-UNDO.
       
/* ***************************  Main Block  *************************** */

IF drive_letter = "P" THEN                                                      
    INPUT FROM "P:\OpenEdge\WRK\RS-SQL-Loads\Input-Files\MAG-CUST-RCD-Extracted.txt". 
ELSE 
    INPUT FROM "C:\OpenEdge\Workspace\RS-SQL-Loads\Input-Files\MAG-CUST-RCD-Extracted.txt".
    
REPEAT:
    
    CREATE   Magento_Data.  
                                                                
    IMPORT DELIMITER ";"  Magento_Data.                                         /** 10feb15 **/  
               
    ASSIGN recordsprocessed = (recordsprocessed + 1).
   
END.  /** REPEAT **/ 
   
INPUT CLOSE.  

ASSIGN recordsprocessed = (recordsprocessed - 1).

/** end of input **/

mainloopie:  
FOR EACH Magento_Data   WHERE INTEGER(IP_magento-id-BP) > 0 AND 
                                      IP_magento-id-BP < 'A'  NO-LOCK 
                        BY IP_billing_country-col-AH BY IP_billing_region-col-AG BY IP_magento-id-BP :          

    IF  IP_billing_firstname-col-S = "" AND 
        IP_billing_lastname-col-U  = "" THEN DO:
            
            ASSIGN Bypassed-cnt = (Bypassed-cnt + 1)
                       disp-msg = "No billing data - bypassed."
                       .
                       
           DISPLAY STREAM outward 
                    Magento_Data.IP_magento-id-BP   FORMAT "x(10)"                  
                    Magento_Data.IP_email-col-G     FORMAT "x(30)" 
                    Magento_Data.IP_firstname-col-K FORMAT "x(20)"
                    Magento_Data.IP_lastname-col-M  FORMAT "x(20)"
                    disp-msg                        FORMAT "x(40)" 
                WITH FRAME outdetail WIDTH 132 DOWN.
                DOWN WITH FRAME outdetail. 
                 
            NEXT mainloopie.
    END.  /**  IF  IP_billing_firstname-col-S = "" AND IP_billing_lastname-col-U  = ""  **/


/* 2dot0 */                         /* 2dot0 */                                 /* 2dot0 */
/*  Verify the input country and state data for valid ISO formats.  */           
/* Check Billing Country for ISO Validation. */                                 /* 2dot0 */                                                             
    RUN VALUE(SEARCH("SUBcountry-findR.r"))
                           (IP_billing_country-col-AH,
                            OUTPUT o-fcountry-ISO,
                            OUTPUT o-fcountry-error).

/* Billing Country NOT Found in country_mstr. Report error. */                  /* 2dot0 */
        IF o-fcountry-error =  YES THEN DO:                                     /* logical YES = data is not found */
            ASSIGN  h-message = "Billing Country not found in ISO country_mstr."
                    h-city    = IP_billing_city-col-AF
                    h-region  = IP_billing_region-col-AG
                    h-country = IP_billing_country-col-AH.
            DISPLAY STREAM outwardISO                                           /* 2dot0 */
                         IP_magento-id-BP               FORMAT "x(10)"
                         h-city                         FORMAT "x(20)"
                         h-region                       FORMAT "x(30)"   
                         h-country                      FORMAT "x(30)"
                         h-message                      FORMAT "x(50)" SKIP 
                    WITH FRAME outISOdetail WIDTH 180 DOWN.
                    DOWN WITH FRAME outISOdetail.  

            ASSIGN  BadBCountry-cnt = (BadBCountry-cnt + 1).
        END.  /* IF o-fcountry-error =  YES */                                  /* 2dot0 */
        
        IF o-fcountry-error =  NO THEN
            ASSIGN  IP_billing_country-col-AH = o-fcountry-ISO.
            
/* Check Shipping Country for ISO Validation. */                                /* 2dot0 */                                                             
    RUN VALUE(SEARCH("SUBcountry-findR.r"))
                           (IP_shipping_country-col-BC,
                            OUTPUT o-fcountry-ISO,
                            OUTPUT o-fcountry-error).

/* Shipping Country NOT Found in country_mstr. Report error. */                 /* 2dot0 */
        IF o-fcountry-error =  YES THEN DO:                                     /* logical YES = data is not found */
            ASSIGN  h-message = "Shipping Country not found in ISO country_mstr."
                    h-city    = IP_shipping_city-col-BA
                    h-region  = IP_shipping_region-col-BB
                    h-country = IP_shipping_country-col-BC.     
            DISPLAY STREAM outwardISO                                           /* 2dot0 */
                         IP_magento-id-BP                   FORMAT "x(10)"
                         h-city                             FORMAT "x(20)"
                         h-region                           FORMAT "x(30)"
                         h-country                          FORMAT "x(30)"
                         h-message                          FORMAT "x(50)" SKIP 
                    WITH FRAME outISOdetail WIDTH 180 DOWN.
                    DOWN WITH FRAME outISOdetail.  
            ASSIGN  BadSCountry-cnt = (BadSCountry-cnt + 1).
        END.  /* IF o-fcountry-error =  YES */                                  /* 2dot0 */

        IF o-fcountry-error =  NO THEN                                          /* 2dot0 */
            ASSIGN  IP_shipping_country-col-BC = o-fcountry-ISO.                /* 2dot0 */
                        
/* Check Billing State for ISO Validation. */                                   /* 2dot0 */                                                                                                                        
        RUN VALUE(SEARCH("SUBstate-findR.r"))
                           (IP_billing_country-col-AH,
                            IP_billing_region-col-AG,
                            OUTPUT o-fstate-ISO,
                            OUTPUT o-fstate-error).   

/* Billing State NOT Found in state_mstr. Report error. */                      /* 2dot0 */
        IF o-fstate-error =  YES THEN DO:                                       /* logical YES = data is not found */
            ASSIGN  h-message   = "Billing State not found in ISO state_mstr."
                    h-city      = IP_billing_city-col-AF
                    h-region    = IP_billing_region-col-AG
                    h-country   = IP_billing_country-col-AH.
            DISPLAY STREAM outwardISO                                           /* 2dot0 */
                         IP_magento-id-BP               FORMAT "x(10)"
                         h-city                         FORMAT "x(20)"
                         h-region                       FORMAT "x(30)"   
                         h-country                      FORMAT "x(30)"  
                         h-message                      FORMAT "x(50)"  SKIP
                    WITH FRAME outISOdetail WIDTH 180 DOWN.
                    DOWN WITH FRAME outISOdetail.                                                      
            ASSIGN  BadBState-cnt = (BadBState-cnt + 1).
        END.  /* IF o-fstate-error =  YES */                                    /* 2dot0 */ 
       
        IF o-fstate-error =  NO THEN                                            /* 2dot0 */
            ASSIGN  IP_billing_region-col-AG = o-fstate-ISO.                    /* 2dot0 */
                     
/* Check Shipping State for ISO Validation. */                                  /* 2dot0 */                                                                                                                          
        RUN VALUE(SEARCH("SUBstate-findR.r"))
                           (IP_shipping_country-col-BC,
                            IP_shipping_region-col-BB,
                            OUTPUT o-fstate-ISO,
                            OUTPUT o-fstate-error).   

/* Shipping State NOT Found in state_mstr. Report error. */                     /* 2dot0 */
        IF o-fstate-error =  YES THEN DO:                                       /* logical YES = data is not found */
            ASSIGN  h-message   = "Shipping State not found in ISO state_mstr."
                    h-city      = IP_shipping_city-col-BA
                    h-region    = IP_shipping_region-col-BB
                    h-country   = IP_shipping_country-col-BC.
            DISPLAY STREAM outwardISO                                           /* 2dot0 */
                         IP_magento-id-BP                   FORMAT "x(10)"
                         h-city                             FORMAT "x(20)"
                         h-region                           FORMAT "x(30)"
                         h-country                          FORMAT "x(30)"
                         h-message                          FORMAT "x(50)"  SKIP
                    WITH FRAME outISOdetail WIDTH 180 DOWN.
                    DOWN WITH FRAME outISOdetail.  
            ASSIGN  BadSState-cnt = (BadSState-cnt + 1).
        END.  /* IF o-fstate-error =  YES */                                    /* 2dot0 */

        IF o-fstate-error =  NO THEN                                            /* 2dot0 */
            ASSIGN  IP_shipping_region-col-BB = o-fstate-ISO.                   /* 2dot0 */
                   
/* 2dot0 */                         /* 2dot0 */                                 /* 2dot0 */

          
    FIND MAG_CUST_RCD                                                        /** 1dot4 **/
        WHERE  MAG_CUST_RCD.magento-id = INTEGER(IP_magento-id-BP)           /** 1dot4 **/
            EXCLUSIVE-LOCK NO-ERROR.
    
    IF AVAILABLE (MAG_CUST_RCD) THEN DO:                                     /** 1dot4 **/
                
        ASSIGN Updated-cnt = (Updated-cnt + 1).
       
        ASSIGN          
                dr_tcp_id_scust_dr_id_int       =  IP_dr_tcp_id_scust_dr_id_col-F                
                M_C_email                       =  IP_email-col-G
                prefix                          =  IP_prefix-col-J           
                firstname                       =  IP_firstname-col-K         
                middlename                      =  IP_middlename-col-L        
                lastname                        =  IP_lastname-col-M          
                suffix                          =  IP_suffix-col-N                  
                          
                billing_prefix                  =  IP_billing_prefix-col-R                                                                         
                billing_firstname               =  IP_billing_firstname-col-S                                                                                  
                billing_middlename              =  IP_billing_middlename-col-T        
                billing_lastname                =  IP_billing_lastname-col-U             
                billing_suffix                  =  IP_billing_suffix-col-V
                billing_street1                 =  IP_billing_street1-col-X             
                billing_street2                 =  IP_billing_street2-col-Y            
                billing_street3                 =  IP_billing_street3-col-Z           
                billing_street4                 =  IP_billing_street4-col-AA          
                billing_street5                 =  IP_billing_street5-col-AB        
                billing_street6                 =  IP_billing_street6-col-AC         
                billing_street7                 =  IP_billing_street7-col-AD          
                billing_street8                 =  IP_billing_street8-col-AE          
                billing_city                    =  IP_billing_city-col-AF             
                billing_region                  =  IP_billing_region-col-AG                   
                billing_country                 =  IP_billing_country-col-AH        
                billing_postcode                =  IP_billing_postcode-col-AI                 
                billing_telephone               =  IP_billing_telephone-col-AJ        
                billing_company                 =  IP_billing_company-col-AK          
                billing_fax                     =  IP_billing_fax-col-AL                 
     
                shipping_prefix                 =  IP_shipping_prefix-col-AM                                                                         
                shipping_firstname              =  IP_shipping_firstname-col-AN                                                                                  
                shipping_middlename             =  IP_shipping_middlename-col-AO         
                shipping_lastname               =  IP_shipping_lastname-col-AP             
                shipping_suffix                 =  IP_shipping_suffix-col-AQ
                shipping_street1                =  IP_shipping_street1-col-AS            
                shipping_street2                =  IP_shipping_street2-col-AT            
                shipping_street3                =  IP_shipping_street3-col-AU           
                shipping_street4                =  IP_shipping_street4-col-AV          
                shipping_street5                =  IP_shipping_street5-col-AW        
                shipping_street6                =  IP_shipping_street6-col-AX        
                shipping_street7                =  IP_shipping_street7-col-AY          
                shipping_street8                =  IP_shipping_street8-col-AZ          
                shipping_city                   =  IP_shipping_city-col-BA             
                shipping_region                 =  IP_shipping_region-col-BB                    
                shipping_country                =  IP_shipping_country-col-BC        
                shipping_postcode               =  IP_shipping_postcode-col-BD                 
                shipping_telephone              =  IP_shipping_telephone-col-BE        
                shipping_company                =  IP_shipping_company-col-BF          
                shipping_fax                    =  IP_shipping_fax-col-BG        
                            
                group-Magento                   =  IP_group-col-BJ        
                gender                          =  IF IP_gender-col-BN = "Male" THEN YES ELSE IF IP_gender-col-BN = "Female" THEN NO ELSE  ?       
                skip-dob                        =  IP_skip-dob-col-BO 
                magento-id                      =  INTEGER(IP_magento-id-BP)    
                doctor_tcp_coupon_code          =  IP_doctor_tcp_coupon_code_col_BQ
                Progress_Flag                   =  "U"
                Progress_DateTime               =  (TODAY - 1)
                    NO-ERROR.                
                
/*                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:              */
/*                    ASSIGN database-error-cnt   = (database-error-cnt + 1).     /** 1dot2 **/*/
/*                    ASSIGN disp-msg = ERROR-STATUS:GET-MESSAGE (1).                          */
/*                    DISPLAY STREAM outward                                                   */
/*                            Magento_Data.IP_magento-id-BP   FORMAT "x(10)"                   */
/*                            Magento_Data.IP_email           FORMAT "x(30)"                   */
/*                            Magento_Data.IP_firstname       FORMAT "x(20)"                   */
/*                            Magento_Data.IP_lastname        FORMAT "x(20)" SKIP              */
/*                            disp-msg                        FORMAT "x(40)" SKIP              */
/*                        WITH FRAME outdetail WIDTH 132 DOWN.                                 */
/*                        DOWN WITH FRAME outdetail.                                           */
/*                END.                                                                         */
/*                ELSE DO:                                                                     */
                    ASSIGN disp-msg = "Record Updated.".
                    IF limitdisplay > 0  AND  limitdisplay > Updated-cnt THEN                     
                       DISPLAY STREAM outward 
                                Magento_Data.IP_magento-id-BP   FORMAT "x(10)"                  
                                Magento_Data.IP_email-col-G     FORMAT "x(30)" 
                                Magento_Data.IP_firstname-col-K FORMAT "x(20)"
                                Magento_Data.IP_lastname-col-M  FORMAT "x(20)"
                                disp-msg                        FORMAT "x(40)"  
                            WITH FRAME outdetail WIDTH 160 DOWN.
                            DOWN WITH FRAME outdetail.  
/*                END.  /** ELSE DO: **/*/
                
                RELEASE MAG_CUST_RCD.                                        /** 1dot4 **/
                      
    END.  /**  IF AVAILABLE (MAGENTO_RCD)  **/
                   
    ELSE DO:
                 
        CREATE MAG_CUST_RCD.                                                 /** 1dot4 **/
        
        Created-cnt = (Created-cnt  + 1).
        
        ASSIGN     
                dr_tcp_id_scust_dr_id_int       =  IP_dr_tcp_id_scust_dr_id_col-F                   
                M_C_email                       =  IP_email-col-G     

                prefix                          =  IP_prefix-col-J           
                firstname                       =  IP_firstname-col-K         
                middlename                      =  IP_middlename-col-L        
                lastname                        =  IP_lastname-col-M          
                suffix                          =  IP_suffix-col-N                  

                billing_prefix                  =  IP_billing_prefix-col-R                                                                         
                billing_firstname               =  IP_billing_firstname-col-S                                                                                  
                billing_middlename              =  IP_billing_middlename-col-T        
                billing_lastname                =  IP_billing_lastname-col-U             
                billing_suffix                  =  IP_billing_suffix-col-V
/*                billing_street_full-col-W       =  IP_billing_street_full-col-W*/
                billing_street1                 =  IP_billing_street1-col-X             
                billing_street2                 =  IP_billing_street2-col-Y            
                billing_street3                 =  IP_billing_street3-col-Z           
                billing_street4                 =  IP_billing_street4-col-AA          
                billing_street5                 =  IP_billing_street5-col-AB        
                billing_street6                 =  IP_billing_street6-col-AC         
                billing_street7                 =  IP_billing_street7-col-AD          
                billing_street8                 =  IP_billing_street8-col-AE          
                billing_city                    =  IP_billing_city-col-AF             
                billing_region                  =  IP_billing_region-col-AG                   
                billing_country                 =  IP_billing_country-col-AH        
                billing_postcode                =  IP_billing_postcode-col-AI                 
                billing_telephone               =  IP_billing_telephone-col-AJ        
                billing_company                 =  IP_billing_company-col-AK          
                billing_fax                     =  IP_billing_fax-col-AL                 

                shipping_prefix                 =  IP_shipping_prefix-col-AM                                                                         
                shipping_firstname              =  IP_shipping_firstname-col-AN                                                                                  
                shipping_middlename             =  IP_shipping_middlename-col-AO         
                shipping_lastname               =  IP_shipping_lastname-col-AP             
                shipping_suffix                 =  IP_shipping_suffix-col-AQ
/*                shipping_street_full-col-AR      =  IP_shipping_street_full-col-AR*/
                shipping_street1                =  IP_shipping_street1-col-AS            
                shipping_street2                =  IP_shipping_street2-col-AT            
                shipping_street3                =  IP_shipping_street3-col-AU           
                shipping_street4                =  IP_shipping_street4-col-AV          
                shipping_street5                =  IP_shipping_street5-col-AW        
                shipping_street6                =  IP_shipping_street6-col-AX        
                shipping_street7                =  IP_shipping_street7-col-AY          
                shipping_street8                =  IP_shipping_street8-col-AZ          
                shipping_city                   =  IP_shipping_city-col-BA             
                shipping_region                 =  IP_shipping_region-col-BB                    
                shipping_country                =  IP_shipping_country-col-BC        
                shipping_postcode               =  IP_shipping_postcode-col-BD                 
                shipping_telephone              =  IP_shipping_telephone-col-BE        
                shipping_company                =  IP_shipping_company-col-BF          
                shipping_fax                    =  IP_shipping_fax-col-BG        

                group-Magento                   =  IP_group-col-BJ        
                gender                          =  IF IP_gender-col-BN = "Male" THEN YES ELSE IF IP_gender-col-BN = "Female" THEN NO ELSE  ?       
                skip-dob                        =  IP_skip-dob-col-BO   
                magento-id                      =  INTEGER(IP_magento-id-BP)    
                doctor_tcp_coupon_code          =  IP_doctor_tcp_coupon_code_col_BQ
                Progress_Flag                   =  "A"
                Progress_DateTime               =  (TODAY - 1)    
                    NO-ERROR.                
                 
/*                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:              */
/*                    ASSIGN database-error-cnt   = (database-error-cnt + 1).     /** 1dot2 **/*/
/*                    ASSIGN disp-msg = ERROR-STATUS:GET-MESSAGE (1).                          */
/*                    DISPLAY STREAM outward                                                   */
/*                            Magento_Data.IP_magento-id-BP   FORMAT "x(10)"                   */
/*                            Magento_Data.IP_email           FORMAT "x(30)"                   */
/*                            Magento_Data.IP_firstname       FORMAT "x(20)"                   */
/*                            Magento_Data.IP_lastname        FORMAT "x(20)"                   */
/*                            disp-msg                        FORMAT "x(40)" SKIP              */
/*                        WITH FRAME outdetail WIDTH 132 DOWN.                                 */
/*                        DOWN WITH FRAME outdetail.                                           */
/*                END.                                                                         */
/*                ELSE DO:                                                                     */
                    ASSIGN disp-msg = "Record created.".                                                                  
                    IF limitdisplay > 0  AND  limitdisplay > Created-cnt THEN                    
                        DISPLAY STREAM outward 
                                Magento_Data.IP_magento-id-BP   FORMAT "x(10)"                    
                                Magento_Data.IP_email-col-G     FORMAT "x(30)" 
                                Magento_Data.IP_firstname-col-K FORMAT "x(20)"
                                Magento_Data.IP_lastname-col-M  FORMAT "x(20)" 
                                disp-msg                        FORMAT "x(40)" 
                            WITH FRAME outdetail WIDTH 160 DOWN.
                            DOWN WITH FRAME outdetail. 
/*                END.  /** ELSE DO: **/*/
                
                RELEASE MAG_CUST_RCD.                                        /** 1dot4 **/
                
    END.  /**  ELSE DO:  **/
                                   
END.  /** FOR EACH Magento_Data **/

DISPLAY STREAM outward SKIP (2)
        "End of input processing at" TODAY STRING(TIME, "HH:MM:SS") SKIP (2)
        recordsprocessed  COLON 30  SKIP 
        Updated-cnt       COLON 30  SKIP  
        Created-cnt       COLON 30  SKIP
        Bypassed-cnt      COLON 30  SKIP(2) 
        "ISO Log Report Error Record Counts:" SKIP 
        BadBState-cnt      COLON 30  SKIP
        BadBCountry-cnt    COLON 30  SKIP
        BadSState-cnt      COLON 30  SKIP
        BadSCountry-cnt    COLON 30  SKIP(2)
        "End of Report." 
    WITH FRAME outtrailer WIDTH 132 SIDE-LABELS. 

DISPLAY STREAM outwardISO SKIP (2)                                              /* 2dot0 */
        "End of input processing at" TODAY STRING(TIME, "HH:MM:SS") SKIP (2)
        recordsprocessed  COLON 30  SKIP(2) 
        BadBState-cnt      COLON 30  SKIP(2)
        BadBCountry-cnt    COLON 30  SKIP(2)
        BadSState-cnt      COLON 30  SKIP(2) 
        BadSCountry-cnt    COLON 30  SKIP(2)
        "End of Report." 
    WITH FRAME outISOtrailer WIDTH 160 SIDE-LABELS. 
    
OUTPUT STREAM outward CLOSE.
OUTPUT STREAM outwardISO CLOSE.                                                 /* 2dot0 */

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).

/* Invalid ISO State and/or Country Error Report. */                            /* 2dot0 */
IF  BadBState-cnt > 0 OR 
    BadBCountry-cnt > 0 OR 
    BadSState-cnt > 0 OR 
    BadSCountry-cnt > 0 THEN                                                    /* 2dot0 */
        OS-COMMAND SILENT 
            VALUE(cmdname)  
            VALUE(emailaddr)
            VALUE(messagetxt) 
            VALUE(subjtxt) 
            VALUE(cmdparams) 
            VALUE(ISOlog).
   
/* END OF program */
