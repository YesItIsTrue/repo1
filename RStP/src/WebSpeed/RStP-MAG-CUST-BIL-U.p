   
/*------------------------------------------------------------------------
    File        : RStP-MAG-CUST-BIL.p
                :
    Purpose     : Takes the data from the Magento system and processes it 
                : into to HHI Progress system by updating or creating the 
                : Address Master, People Master, 
                : Doctor Master,
                : Customer Master, Shadow-customer Master. 

    Syntax      :

    Description : Processes the Magento Customer/Billing/Shipping data.     
    
    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="2.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="8/Feb/15">
    <META NAME="LAST_UPDATED" CONTENT="24/May/16">
    
    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 8/Feb/15.   
    
    Version: 1.1    By Harold Luttrell, Sr.
        Date: 12/Feb/15.
        Removed checking the e-mail <> statement.
        Identified by /** 1dot1 **/
    
    Version: 1.2    By Harold Luttrell, Sr.
        Date: 14/Feb/15.
        Changed code to move the people_email to people_email2 and 
            move the input email to people_email.
        Identified by /** 1dot2 **/     

    Version: 1.3    By Harold Luttrell, Sr.
        Date: 3/Mar/15.
        Added code to process the 1st set of names to create the standard
            records except the address_mstr ONLY IF the input Billing names 
            is blank. 
        Identified by /** 1dot3 **/ 
    
    Version: 1.4    By Harold Luttrell, Sr.
        Date: 20/Aug/15.
        Modified code to use the new "RUN VALUE(SEARCH("pgm.p"))
            statement instead of the long pathing name. 
        Identified by /** 1dot4 **/  
        
    Version: 1.5    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Modified RUN statements to use the .r extensions. 
        Identified by /* 1dot5 */  
    
    Version 2.0 - Harold Luttrell - 24/May/16.
            Added code to set the genderhold logical from the SUB-UnString-Name.p program.
            Identified by:  /* 2dot0 */                                                      
            
    Version 2.1 - HAROLD LUTTRELL, JR. - 09/Oct/17
            Modified to support the new directory structure and names in the CMC structure (Release 12).  Marked by 2dot1.
                                      
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/*  include statements  */ 
 
{RStP-MAG-CUST.i}.                                                              /** 1dot4 **/

{o-depot-definenames.i}.                                                        /** 1dot4 **/

/*  define statenebts  */
DEFINE INPUT  PARAMETER ip-Seq-nbr-col-BT   AS INTEGER                      NO-UNDO.

DEFINE OUTPUT PARAMETER op-error-nbr        AS INTEGER                      NO-UNDO.
DEFINE OUTPUT PARAMETER new-Billing-Cust-ID AS INTEGER                      NO-UNDO.
  
DEFINE VARIABLE hold-area-1                 AS CHARACTER FORMAT "x(160)"    NO-UNDO.
DEFINE VARIABLE hold-area-2                 AS CHARACTER FORMAT "x(160)"    NO-UNDO.
DEFINE VARIABLE hold-area-940               AS CHARACTER FORMAT "x(940)"    NO-UNDO.
DEFINE VARIABLE hard-code-logical           AS LOGICAL INITIAL ?            NO-UNDO.
DEFINE VARIABLE check_date                  AS DATE                         NO-UNDO.
DEFINE VARIABLE next-seq-state              AS INTEGER                      NO-UNDO.
DEFINE VARIABLE US-state-cnt                AS INTEGER INITIAL 0            NO-UNDO.

/* ***************************  E-Mail  Definitions  *************************** */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Log Report is attached from "                  NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Log Report from "                              NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.
 
messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                 

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 

{emailaddr-USERID.i}.                                                           /** 1dot4 **/

/* ***************************  Main Block  *************************** */      

ASSIGN op-error-nbr = 0.


FIND RStP_MAG_CUST_Data WHERE magento-id-BP = ip-Seq-nbr-col-BT NO-LOCK. 

ASSIGN  hold-area-940 = "".
ASSIGN  hold-area-940 = billing_street1-col-X + billing_street2-col-Y + billing_street3-col-Z + billing_street4-col-AA + billing_street5-col-AB 
                      + billing_street6-col-AC + billing_street7-col-AD + billing_street8-col-AE
                      + billing_city-col-AF + billing_region-col-AG + billing_postcode-col-AI + billing_country-col-AH.
                                                                      
IF hold-area-940 <> "" THEN DO:                                                 /** 1dot3 **/ 
    
/*  find or create the address_mstr using the Billing info.  */                                                                                
  
    RUN VALUE(SEARCH("SUBaddr-findR.r"))                                                        /* 1dot5 */                 
       (TRIM(billing_street1-col-X), 
        TRIM(billing_street2-col-Y), 
        (TRIM(billing_street3-col-Z) + " " + TRIM(billing_street4-col-AA) + " " + TRIM(billing_street5-col-AB) 
                 + " " + TRIM(billing_street6-col-AC) + " " + TRIM(billing_street7-col-AD) + " " + TRIM(billing_street8-col-AE) ),               
        TRIM(billing_city-col-AF), 
        TRIM(billing_region-col-AG),
        TRIM(billing_postcode-col-AI),
        TRIM(billing_country-col-AH),
        OUTPUT o-faddr-addrID,
        OUTPUT o-faddr-error, 
        OUTPUT o-faddr-ran).  
         
    IF o-faddr-error = YES  THEN DO:  
        
        RUN VALUE(SEARCH("SUBaddr-ucU.r"))                                      /* 1dot5 */
               (0,
                TRIM(billing_street1-col-X), 
                TRIM(billing_street2-col-Y), 
                ( TRIM(billing_street3-col-Z) + " " + TRIM(billing_street4-col-AA) + " " + TRIM(billing_street5-col-AB) 
                         + " " + TRIM(billing_street6-col-AC) + " " + TRIM(billing_street7-col-AD) + " " + TRIM(billing_street8-col-AE) ),               
                TRIM(billing_city-col-AF), 
                TRIM(billing_region-col-AG),
                TRIM(billing_postcode-col-AI),
                TRIM(billing_country-col-AH),
                "",                                                                               
                OUTPUT o-ucaddr-id,
                OUTPUT o-ucaddr-create,
                OUTPUT o-ucaddr-update,
                OUTPUT o-ucaddr-avail,  
                OUTPUT o-ucaddr-successful).
             
        IF o-ucaddr-successful = NO THEN 
            ASSIGN o-ucaddr-id = 0.
                                   
        ASSIGN  o-faddr-addrID = o-ucaddr-id.
             
    END.    /**  IF o-faddr-error = YES  **/   
                  
    FIND addr_mstr
        WHERE addr_mstr.addr_id = o-faddr-addrID
            EXCLUSIVE-LOCK NO-ERROR.
            
    IF AVAILABLE (addr_mstr) THEN         
        ASSIGN  addr_mstr.addr_type = "billed to"
                addr_mstr.addr_modified_by  = USERID("Core")                                            /* 2dot1 */
                addr_mstr.addr_modified_date = TODAY
                addr_mstr.addr_prog_name  = THIS-PROCEDURE:FILE-NAME.
    
    RELEASE addr_mstr NO-ERROR.                    

/*  Find or create the people_mstr using the Billing info.  */                  /** 1dot3 **/
    
    RUN VALUE(SEARCH("SUBpeop-findR.r"))                                        /* 1dot5 */     
           (TRIM(billing_prefix-col-R),
            TRIM(billing_firstname-col-S),
            TRIM(billing_middlename-col-T),
            TRIM(billing_lastname-col-U),
            TRIM(billing_suffix-col-V),
            OUTPUT o-fpe-peopleID,
            OUTPUT o-fpe-addr_ID,
            OUTPUT o-fpe-error,
            OUTPUT o-fpat-ran).
    
    IF o-fpe-peopleID  > 0 THEN DO:
        
/** 1dot2 **/            
        FIND  people_mstr 
            WHERE people_mstr.people_id = o-fpe-peopleID 
                EXCLUSIVE-LOCK NO-ERROR. 
        
        IF AVAILABLE (people_mstr) THEN DO:
            
            IF  people_mstr.people_email <> email-col-G THEN DO:  
              
                ASSIGN people_mstr.people_email2 = people_mstr.people_email.       
                ASSIGN people_mstr.people_email  = email-col-G.
                   
            END.  /** people_mstr.people_email <> email-col-G **/ 
            
            ASSIGN  people_mstr.people_title        = billing_title_desc-R-V                
                    people_mstr.people_prefname     = billing_prefname-R-V
/*                    people_mstr.people_addr_id      = o-faddr-addrID*/
                    people_mstr.people_addr_id       = IF o-faddr-addrID    <> 0 THEN o-faddr-addrID   ELSE people_mstr.people_addr_id
                    people_mstr.people_second_addr_ID = 0
                    people_mstr.people_gender       = billing_genderhold-R-V            /* 2dot0 */
                    people_mstr.people_modified_by  = USERID("Core")                                        /* 2dot1 */
                    people_mstr.people_modified_date = TODAY
                    people_mstr.people_prog_name    = THIS-PROCEDURE:FILE-NAME. 
                
        END.  /**  IF AVAILABLE (people_mstr)  **/
/** 1dot2 **/        
    END.    /**  o-fpe-peopleID  > 0  **/  
                                         
    IF o-fpe-peopleID  = 0 THEN DO:
        
        RUN VALUE(SEARCH("SUBpeop-ucU.r"))                                      /* 1dot5 */
               (0,
                TRIM(billing_firstname-col-S),
                TRIM(billing_middlename-col-T),
                TRIM(billing_lastname-col-U),
                TRIM(billing_prefix-col-R),
                TRIM(billing_suffix-col-V),
                TRIM(billing_company-col-AK),
                billing_genderhold-R-V,                                                                    
                TRIM(billing_telephone-col-AJ),
                "",
                "",
                TRIM(billing_fax-col-AL),
                TRIM(email-col-G),
                "",
                o-faddr-addrID,
                "",
                ?,                     /* DATE(dob-col-BO),  11-20-14 */
                0, 
                TRIM(billing_prefname-R-V),                                     /* 2dot0 */  
                "",                     /* title */             
                OUTPUT o-ucpeople-id,
                OUTPUT o-ucpeople-create,
                OUTPUT o-ucpeople-update,
                OUTPUT o-ucpeople-avail,
                OUTPUT o-ucpeople-successful).        
 
        IF o-ucpeople-successful = NO THEN
            ASSIGN o-ucpeople-id = 0.
        
        ASSIGN  o-fpe-peopleID = o-ucpeople-id. 

        FIND people_mstr 
            WHERE people_mstr.people_id  =  o-fpe-peopleID 
                EXCLUSIVE-LOCK NO-ERROR.
                
        IF AVAILABLE (people_mstr) THEN 
            ASSIGN  people_mstr.people_title        = billing_title_desc-R-V                
                    people_mstr.people_prefname     = billing_prefname-R-V
/*                    people_mstr.people_addr_id      = o-faddr-addrID*/
                    people_mstr.people_addr_id       = IF o-faddr-addrID    <> 0 THEN o-faddr-addrID   ELSE people_mstr.people_addr_id
                    people_mstr.people_second_addr_ID = 0
                    people_mstr.people_gender         = billing_genderhold-R-V          /* 2dot0 */
                    people_mstr.people_modified_by  = USERID("Core")                                        /* 2dot1 */
                    people_mstr.people_modified_date = TODAY
                    people_mstr.people_prog_name    = THIS-PROCEDURE:FILE-NAME.                 
                            
    END.    /**  o-fpe-peopleID  = 0  **/  

 /* after creating the people_mstr:  
        IF doctor_TCP_id-col-F > 0 then create a DOCTOR mstr   WITH people_id AND TCP CODE **/  
    
    ASSIGN o-fdoc-ID = 0.                                                                      
    
    IF  doctor_tcp_coupon_code_col_BQ <> "" THEN DO: 
        
        RUN VALUE(SEARCH("SUBdoc-findR.r"))                                     /* 1dot5 */        
                   (TRIM(billing_prefix-col-R),
                    TRIM(billing_firstname-col-S),
                    TRIM(billing_middlename-col-T),
                    TRIM(billing_lastname-col-U),
                    TRIM(billing_suffix-col-V),
                    OUTPUT o-fdoc-ID,
                    OUTPUT o-fdoc-addr_ID,
                    OUTPUT o-fdoc-exist,
                    OUTPUT o-fdoc-ran,
                    OUTPUT o-fdoc-error).
    
        IF o-fdoc-exist = NO  THEN DO:
             
            RUN VALUE(SEARCH("SUBdoc-ucC.r"))                                   /* 1dot5 */  
                   (o-fpe-peopleID,
                    doctor_tcp_coupon_code_col_BQ,              
                    OUTPUT o-ucdoctor-id,
                    OUTPUT o-ucdoctor-create,
                    OUTPUT o-ucdoctor-update,
                    OUTPUT o-ucdoctor-error,
                    OUTPUT o-ucdoctor-successful).        
   
            IF o-ucdoctor-successful = NO THEN 
                ASSIGN o-ucdoctor-id = 0.
            
            ASSIGN  o-fdoc-ID = o-ucdoctor-id. 
            
            FIND doctor_mstr
                WHERE doctor_mstr.doctor_ID = o-fdoc-ID
                    EXCLUSIVE-LOCK. 
            IF AVAILABLE (doctor_mstr) THEN DO:
            
                ASSIGN  doctor_mstr.doctor_modified_by  = USERID("Modules")                             /* 2dot1 */
                        doctor_mstr.doctor_modified_date = TODAY
                        doctor_mstr.doctor_prog_name = THIS-PROCEDURE:FILE-NAME. 
                
            END.  /**  IF AVAILABLE (doctor_mstr)   **/
                  
        END.    /**  o-fdoc-exist = NO **/    
                
    END.    /** doctor_tcp_coupon_code_col_BQ <> "" **/                         

END.    /**  IF hold-area-940 <> ""  **/                                        /** 1dot3 **/ 

/* Use the 1st set of input names to create a people_mstr if                    /** 1dot3 **/
   the Billing names are blank. */                                              /** 1dot3 **/
   
IF  billing_firstname-col-S = "" AND                                            /** 1dot3 **/ 
    billing_lastname-col-U  = "" THEN DO:                                       /** 1dot3 **/
/*  Overlay the blank Billing fields with the 1st set of names  */              /** 1dot3 **/
/*           so the original code used later does not have to be changed. */    /** 1dot3 **/     
        ASSIGN  billing_prefix-col-R     = prefix-col-J                         /** 1dot3 **/ 
                billing_firstname-col-S  = firstname-col-K                      /** 1dot3 **/
                billing_middlename-col-T = middlename-col-L                     /** 1dot3 **/
                billing_lastname-col-U   = lastname-col-M                       /** 1dot3 **/ 
                billing_suffix-col-V     = suffix-col-N.                        /** 1dot3 **/
/** 1dot3 **/
        
        RUN VALUE(SEARCH("SUBpeop-findR.r"))                                    /* 1dot5 */
               (TRIM(billing_prefix-col-R),
                TRIM(billing_firstname-col-S),
                TRIM(billing_middlename-col-T),
                TRIM(billing_lastname-col-U),
                TRIM(billing_suffix-col-V),
                OUTPUT o-fpe-peopleID,
                OUTPUT o-fpe-addr_ID,
                OUTPUT o-fpe-error,
                OUTPUT o-fpat-ran).
                
        IF o-fpe-peopleID  > 0 THEN DO:
            
            FIND  people_mstr 
                WHERE people_mstr.people_id = o-fpe-peopleID 
                    EXCLUSIVE-LOCK NO-ERROR. 
        
            IF AVAILABLE (people_mstr) THEN DO:
                
                IF  people_mstr.people_email <> email-col-G THEN DO:  
                  
                    ASSIGN people_mstr.people_email2 = people_mstr.people_email.       
                    ASSIGN people_mstr.people_email  = email-col-G.
                       
                END.  /** people_mstr.people_email <> email-col-G **/ 
                
                ASSIGN  people_mstr.people_title        = billing_title_desc-R-V                
                        people_mstr.people_prefname     = billing_prefname-R-V
/*                        people_mstr.people_addr_id      = o-faddr-addrID*/
                        people_mstr.people_addr_id       = IF o-faddr-addrID    <> 0 THEN o-faddr-addrID   ELSE people_mstr.people_addr_id
                        people_mstr.people_second_addr_ID = 0
                        people_mstr.people_gender       = billing_genderhold-R-V            /* 2dot0 */
                        people_mstr.people_modified_by  = USERID("Core")                            /* 2dot1 */
                        people_mstr.people_modified_date = TODAY
                        people_mstr.people_prog_name    = THIS-PROCEDURE:FILE-NAME. 
                    
            END.  /**  IF AVAILABLE (people_mstr)  **/
       
        END.    /**  o-fpe-peopleID  > 0  **/  
                                         
        IF o-fpe-peopleID  = 0 THEN DO:
            
            RUN VALUE(SEARCH("SUBpeop-ucU.r"))                                  /* 1dot5 */
                   (0,
                    TRIM(billing_firstname-col-S),
                    TRIM(billing_middlename-col-T),
                    TRIM(billing_lastname-col-U),
                    TRIM(billing_prefix-col-R),
                    TRIM(billing_suffix-col-V),
                    TRIM(billing_company-col-AK),
                    billing_genderhold-R-V,                                                                    
                    "",
                    "",
                    "",
                    "",
                    TRIM(email-col-G),
                    "",
                    0,
                    "",
                    ?,                     /* DATE(dob-col-BO),  11-20-14 */
                    0,                
                    "",                     /* prefname */
                    "",                      /* title */
                    OUTPUT o-ucpeople-id,
                    OUTPUT o-ucpeople-create,
                    OUTPUT o-ucpeople-update,
                    OUTPUT o-ucpeople-avail,
                    OUTPUT o-ucpeople-successful).        
 
            IF o-ucpeople-successful = NO THEN
                ASSIGN o-ucpeople-id = 0.
            
            ASSIGN  o-fpe-peopleID = o-ucpeople-id. 
    
            FIND people_mstr 
                WHERE people_mstr.people_id  =  o-fpe-peopleID 
                    EXCLUSIVE-LOCK NO-ERROR.
                    
            IF AVAILABLE (people_mstr) THEN 
                ASSIGN  people_mstr.people_title     = billing_title_desc-R-V                
                        people_mstr.people_prefname  = billing_prefname-R-V
/*                        people_mstr.people_addr_id      = o-faddr-addrID*/
                        people_mstr.people_addr_id       = IF o-faddr-addrID    <> 0 THEN o-faddr-addrID   ELSE people_mstr.people_addr_id
                        people_mstr.people_second_addr_ID = 0
                        people_mstr.people_gender       = billing_genderhold-R-V            /* 2dot0 */
                        people_mstr.people_modified_by  = USERID("Core")                                    /* 2dot1 */
                        people_mstr.people_modified_date = TODAY
                        people_mstr.people_prog_name = THIS-PROCEDURE:FILE-NAME.                 
                                
        END.    /**  o-fpe-peopleID  = 0  **/          
/** 1dot3 **/                
END.  /** IF  billing_firstname-col-S = "" **/                                  /** 1dot3 **/
    
/*  Continue with the normal processing of the input data.  */                  /** 1dot3 **/

RUN VALUE(SEARCH("SUBcust-findR.r"))                                            /* 1dot5 */
           (TRIM(billing_prefix-col-R),
            TRIM(billing_firstname-col-S),
            TRIM(billing_middlename-col-T),
            TRIM(billing_lastname-col-U),
            TRIM(billing_suffix-col-V),
            TRIM(email-col-G),
            OUTPUT o-fcust-ID,
            OUTPUT o-fcust-addr-ID, 
            OUTPUT o-fcust-exist, 
            OUTPUT o-fcust-ran,
            OUTPUT o-fcust-error).            
     
IF o-fcust-exist = NO THEN DO:
    
    RUN VALUE(SEARCH("SUBcust-ucU.r"))                                          /* 1dot5 */
              (o-fcust-ID,
               "",
               0,
               "",
               0,
               0,                
               OUTPUT o-uccust-id,
               OUTPUT o-uccust-create, 
               OUTPUT o-uccust-update, 
               OUTPUT o-uccust-error,
               OUTPUT o-uccust-successful).
       
    IF o-uccust-successful = NO THEN 
        ASSIGN o-uccust-id = 0.
 
    ASSIGN  o-fcust-ID = o-uccust-id. 

    FIND cust_mstr
        WHERE cust_mstr.cust_id = o-fcust-ID
            EXCLUSIVE-LOCK.
            
    IF AVAILABLE (cust_mstr) THEN 
        ASSIGN  cust_mstr.cust_modified_by      = USERID("Core")                                    /* 2dot1 */
                cust_mstr.cust_modified_date    = TODAY
                cust_mstr.cust_prog_name        = THIS-PROCEDURE:FILE-NAME.
                
END.  /**  IF o-fcust-exist = NO  */ 

/*  Return the Cust_Id to the calling program so it can be passed to 
    the shipping program for the patient_mstr.cust_id update.   */
     
ASSIGN new-Billing-Cust-ID = o-fcust-ID.

RUN VALUE(SEARCH("SUBscust-findR.r"))                                           /* 1dot5 */
           (TRIM(billing_prefix-col-R),
            TRIM(billing_firstname-col-S),
            TRIM(billing_middlename-col-T),
            TRIM(billing_lastname-col-U),
            TRIM(billing_suffix-col-V),
            TRIM(email-col-G),
            OUTPUT o-fshadc-ID,
            OUTPUT o-fshadc-addr-ID, 
            OUTPUT o-fshadc-magento-ID,
            OUTPUT o-fshadc-exist, 
            OUTPUT o-fshadc-ran,
            OUTPUT o-fshadc-error).      
                                   
ASSIGN hard-code-logical = NO.

IF doctor_tcp_coupon_code_col_BQ <> "" THEN

    ASSIGN hard-code-logical = YES. 

IF  o-fshadc-ID  > 0 THEN DO: 
    
    RUN VALUE(SEARCH("SUBscust-ucU.r"))                                         /* 1dot5 */
          (o-fshadc-ID,
           magento-id-BP,
           hard-code-logical,
           INTEGER(dr_tcp_id_scust_dr_id_int-col-F),                    
           OUTPUT o-ucscust-id,
           OUTPUT o-uccust-create, 
           OUTPUT o-ucscust-update, 
           OUTPUT o-ucscust-error,
           OUTPUT o-ucscust-successful).

    IF o-ucscust-successful = NO THEN 
        ASSIGN o-ucscust-id = 0.
        
    ASSIGN o-fshadc-ID = o-ucscust-id.            

    FIND scust_shadow
        WHERE scust_shadow.scust_ID     = o-fshadc-ID
            EXCLUSIVE-LOCK NO-ERROR.
                                                        
    IF AVAILABLE (scust_shadow) THEN DO: 
    
        ASSIGN scust_shadow.scust_magento_id    = STRING(magento-id-BP) 
               scust_shadow.scust_doctor_ID     = INTEGER(dr_tcp_id_scust_dr_id_int-col-F)
               scust_shadow.scust_modified_by   = USERID("Custom")                                                  /* 2dot1 */
               scust_shadow.scust_modified_date = TODAY
               scust_shadow.scust_prog_name     = THIS-PROCEDURE:FILE-NAME.  
            
        RELEASE scust_shadow NO-ERROR.
        
    END.  /**  AVAILABLE (scust_shadow)  **/  

END.  /**  IF  o-fshadc-ID  > 0  **/

/*  End of Program.  */

