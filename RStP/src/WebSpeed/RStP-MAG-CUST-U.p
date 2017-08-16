    
/*------------------------------------------------------------------------
    File        : RStP-MAG-CUST-U.p
    Purpose     : Takes the daily data from the Magento system and processes it 
                : into to HHI Progress system by updating or creating the 
                : Customer Master, Shadow-customer Master, People Master, 
                : Address Master and the Doctor Master. 

    Syntax      : Has 2 RUN statements 1 for program:
                :       RStP-MAG-CUST-BIL-U.p
                :   and program:
                :       RStP-MAG-CUST-SHP-U.p

    Description : Processes the Magento Customer/Billing/Shipping data.
    
    Databases   : General, 
    
    Tables      : addr_mstr,
                : people_mstr,                               
                : cust_mstr,
                  
                : doctor_mstr,
                : scust_shadow,
                : patient_mstr.
    
    
    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.3">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="8/Feb/15">
    <META NAME="LAST_UPDATED" CONTENT="3/Mar/15">
    
    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 8/Feb/15.
    
    Version: 1.1    By Harold Luttrell, Sr.
        Date: 12/Feb/15.
        Added code to assign missing data assignments.
        Identified by /** 1dot1 **/

    Version: 1.2    By Harold Luttrell, Sr.
        Date: 14/Feb/15.
        Commented out the code to run the shipping program:
            "RStP-MAG-CUST-SHP-U.p" per Doug.  We don't think
            that we need the shipping to names and address.
        Identified by /** 1dot2 **/  
        
    Version: 1.3    By Harold Luttrell, Sr.
        Date: 3/Mar/15.
        Added code to process the 1st set of names to create the standard
            records except the address_mstr ONLY IF the input Billing names 
            is blank. 
        Identified by /** 1dot3 **/ 
    
     Version: 1.4    By Harold Luttrell, Sr.
        Date: 17/Sept/15.
        Modified code to use the new "RUN VALUE(SEARCH("pgm.p"))
            statement instead of the long pathing name.  Also changed code to 
            MAG_CUST_RCD instead of the &SCOPED-DEFINE this-table   MAG_CUST_RCD.
        Identified by /** 1dot4 **/ 
        
     Version: 1.5    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Modified RUN statements to use the .r extensions.
        Identified by /* 1dot5 */    

     Version: 2.0    By Harold Luttrell, Sr.
        Date: 10/Mar/16.
            Removed dead (commented out) code.
        Not Identified by /* 2dot0 */ - code was deleted.   
                                                  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/*  include statements  */

{RStP-MAG-CUST.i "new"}.                                                        /** 1dot4 **/

{o-depot-definenames.i}.                                                        /** 1dot4 **/

/*  define statements  */

DEFINE VARIABLE op_text                     AS CHARACTER FORMAT "x(60)"     NO-UNDO.
DEFINE VARIABLE hold-cols-J-N               AS CHARACTER FORMAT "x(160)"    NO-UNDO.
DEFINE VARIABLE hold-cols-R-V               AS CHARACTER FORMAT "x(160)"    NO-UNDO.
DEFINE VARIABLE hold-cols-AM-AQ             AS CHARACTER FORMAT "x(160)"    NO-UNDO.
DEFINE VARIABLE hold-area-940               AS CHARACTER FORMAT "x(940)"    NO-UNDO.
DEFINE VARIABLE op-error-nbr                AS INTEGER                      NO-UNDO.
DEFINE VARIABLE new-Billing-Cust-ID         AS INTEGER                      NO-UNDO.

DEFINE VARIABLE recordsprocessed            AS INTEGER   LABEL "Records Processed" NO-UNDO.
DEFINE VARIABLE cust-name-error             AS INTEGER   LABEL "Cust vs Bill Name" NO-UNDO.
DEFINE VARIABLE Cust_format_error           AS INTEGER   LABEL "Cust Format Error" NO-UNDO.
DEFINE VARIABLE Bill_format_error           AS INTEGER   LABEL "Bill Format Error" NO-UNDO.
DEFINE VARIABLE op-field-err-info           AS CHARACTER FORMAT "x(20)" COLUMN-LABEL "Field in error" NO-UNDO.
DEFINE VARIABLE op-err-message              AS CHARACTER FORMAT "x(38)" COLUMN-LABEL "Error message" NO-UNDO.

DEFINE VARIABLE hard-code-logical           AS LOGICAL INITIAL ?            NO-UNDO.

DEFINE VARIABLE String_Pat_Name             AS CHARACTER FORMAT "x(70)"     NO-UNDO.  
DEFINE VARIABLE prefix LIKE people_mstr.people_prefix                       NO-UNDO.
DEFINE VARIABLE firstname LIKE people_mstr.people_firstname                 NO-UNDO.
DEFINE VARIABLE middlename LIKE people_mstr.people_midname                  NO-UNDO.
DEFINE VARIABLE lastname LIKE people_mstr.people_lastname                   NO-UNDO.
DEFINE VARIABLE prefname LIKE people_mstr.people_prefname                   NO-UNDO.
DEFINE VARIABLE suffix LIKE people_mstr.people_suffix                       NO-UNDO.
DEFINE VARIABLE title_desc LIKE people_mstr.people_suffix                   NO-UNDO.
DEFINE VARIABLE genderhold                  AS LOGICAL                      NO-UNDO.

DEFINE VARIABLE it-message      AS LOGICAL INITIAL NO                       NO-UNDO.

DEFINE VARIABLE processlist      AS CHARACTER 
    INITIAL "A,U" NO-UNDO. 


DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Log Report from "                              NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
 
messagetxt = messagetxt + "\n"
                    + "The attached report file is best using Landscape when printed. " 
                    + "\n"
                    + "End of message.". 
   
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\Progress\WRK\RStP-MAG_CUST-U-errors.txt"              NO-UNDO.

OUTPUT STREAM outward TO value(errlog).
DISPLAY STREAM outward 
          "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)"  SKIP    
          "Start of input processing at: " TODAY STRING(TIME, "HH:MM:SS")
         WITH FRAME outheader WIDTH 132 SIDE-LABELS.

/* ********************  Preprocessor Definitions  ******************** */
    
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                 

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).   
              
{emailaddr-USERID.i} 
        
/* ***************************  Main Block  *************************** */ 
DISPLAY STREAM outward "Magento ID" "Field in Error" AT 15  
    "Error Message" AT 70 SKIP
    "----------" "--------------------" AT 15 "--------------------------------------" AT 70 SKIP
    WITH FRAME Heading NO-LABELS WIDTH 132.
    
mainloopie:
      
FOR EACH MAG_CUST_RCD                                                        /** 1dot4 **/  
        WHERE LOOKUP(MAG_CUST_RCD.Progress_Flag,processlist) > 0  :          /** 1dot4 **/
    
    ASSIGN recordsprocessed = (recordsprocessed + 1).

    CREATE RStP_MAG_CUST_Data.
    
    ASSIGN  magento-id-BP                   = MAG_CUST_RCD.magento-id
            dr_tcp_id_scust_dr_id_int-col-F = MAG_CUST_RCD.dr_tcp_id_scust_dr_id_int        /** 1dot1 **/
            email-col-G                     = MAG_CUST_RCD.M_C_email                        /** 1dot1 **/
            group-col-BJ                    = MAG_CUST_RCD.group-Magento                    /** 1dot1 **/             
            gender-col-BN                   = MAG_CUST_RCD.gender                           /** 1dot1 **/       
            skip-dob-col-BO                 = MAG_CUST_RCD.skip-dob                         /** 1dot1 **/
            doctor_tcp_coupon_code_col_BQ   = MAG_CUST_RCD.doctor_tcp_coupon_code           /** 1dot1 **/
           
            billing_street1-col-X           = MAG_CUST_RCD.billing_street1         
            billing_street2-col-Y           = MAG_CUST_RCD.billing_street2             
            billing_street3-col-Z           = MAG_CUST_RCD.billing_street3         
            billing_street4-col-AA          = MAG_CUST_RCD.billing_street4        
            billing_street5-col-AB          = MAG_CUST_RCD.billing_street5        
            billing_street6-col-AC          = MAG_CUST_RCD.billing_street6        
            billing_street7-col-AD          = MAG_CUST_RCD.billing_street7        
            billing_street8-col-AE          = MAG_CUST_RCD.billing_street8        
            billing_city-col-AF             = MAG_CUST_RCD.billing_city           
            billing_region-col-AG           = MAG_CUST_RCD.billing_region               
            billing_country-col-AH          = MAG_CUST_RCD.billing_country        
            billing_postcode-col-AI         = MAG_CUST_RCD.billing_postcode             
             /*  aj THRU al goes INTO created people_mstr. **/          
            billing_telephone-col-AJ        = MAG_CUST_RCD.billing_telephone      
            billing_company-col-AK          = MAG_CUST_RCD.billing_company        
            billing_fax-col-AL              = MAG_CUST_RCD.billing_fax

                NO-ERROR. 
                      
    IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
        DISPLAY STREAM outward
                MAG_CUST_RCD.magento-id
                ERROR-STATUS:GET-MESSAGE (1)   FORMAT "x(100)" SKIP(1)
            WITH FRAME outdetailE1 WIDTH 132 DOWN.
            DOWN WITH FRAME outdetailE1.
    END.
          
/* String the 2 different sets of names: CUSTOMER & BILLING  and
   run them thru the SUB-UnString-Name.p program.  */

    ASSIGN  String_Pat_Name =   "".      
    ASSIGN  String_Pat_Name =   MAG_CUST_RCD.prefix + " " + MAG_CUST_RCD.firstname + " ".    
    IF  MAG_CUST_RCD.middlename <> "" THEN 
        ASSIGN  String_Pat_Name =   String_Pat_Name + MAG_CUST_RCD.middlename + " ".      
    ASSIGN  String_Pat_Name     =   String_Pat_Name + MAG_CUST_RCD.lastname + " ".
    ASSIGN  String_Pat_Name     =   String_Pat_Name + MAG_CUST_RCD.suffix.

    RUN VALUE(SEARCH("SUB-UnString-Name.r"))                                                        /* 1dot5 */
           (String_Pat_Name,                               /* input_name_big_string, */
            it-message,                                    /* if YES then SUB program displays information. */ 
            OUTPUT prefix-col-J,                           /*  o-prefix, */
            OUTPUT firstname-col-K,                        /*  o-firstname, */
            OUTPUT middlename-col-L,                       /*  o-middlename, */
            OUTPUT lastname-col-M,                         /*  o-lastname, */
            OUTPUT suffix-col-N,                           /*  o-suffix, */
            OUTPUT title_desc-J-N,                         /*  o-title_desc, */
            OUTPUT prefname-J-N,                           /*  o-prefname, */
            OUTPUT genderhold-J-N,                         /*  o-gender */
            OUTPUT o-unstring-error,                       /*  YES = errors / NO = no errors. */
            OUTPUT o-field-in-error).                      /*  name of the input field that is in error, if one. */
  
        IF  o-unstring-error = YES THEN DO:
            ASSIGN  op-field-err-info    = o-field-in-error
                    op-err-message       = "- Cust input field in error.".
            ASSIGN Cust_format_error = (Cust_format_error + 1).
            DISPLAY STREAM outward
                    MAG_CUST_RCD.magento-id     FORMAT ">>>>>>>9" COLUMN-LABEL "Magento ID:" 
                    MAG_CUST_RCD.firstname      FORMAT "x(15)"    COLUMN-LABEL "First Name:"
                    MAG_CUST_RCD.lastname       FORMAT "x(20)"    COLUMN-LABEL "Last Name:"
                    op-field-err-info               FORMAT "x(14)"
                    op-err-message                  FORMAT "x(35)" SKIP(1)
                WITH FRAME outdetail1 WIDTH 132 DOWN.
                DOWN WITH FRAME outdetail1.
             NEXT  mainloopie.
        END.  /** IF  o-unstring-error = YES  **/
          
    ASSIGN  String_Pat_Name =   "".     
    ASSIGN  String_Pat_Name =   MAG_CUST_RCD.billing_prefix + " " + MAG_CUST_RCD.billing_firstname + " ".    
    IF  MAG_CUST_RCD.billing_middlename <> "" THEN 
        ASSIGN  String_Pat_Name =   String_Pat_Name + MAG_CUST_RCD.billing_middlename + " ".      
    ASSIGN  String_Pat_Name     =   String_Pat_Name + MAG_CUST_RCD.billing_lastname + " ".
    ASSIGN  String_Pat_Name     =   String_Pat_Name + MAG_CUST_RCD.billing_suffix.

    RUN VALUE(SEARCH("SUB-UnString-Name.r"))                                                        /* 1dot5 */
           (String_Pat_Name,                               /* input_name_big_string, */
            it-message,                                    /* if YES then SUB program displays information. */ 
            OUTPUT billing_prefix-col-R,                   /*  o-prefix, */
            OUTPUT billing_firstname-col-S,                /*  o-firstname, */
            OUTPUT billing_middlename-col-T,               /*  o-middlename, */
            OUTPUT billing_lastname-col-U,                 /*  o-lastname, */
            OUTPUT billing_suffix-col-V,                   /*  o-suffix, */
            OUTPUT billing_title_desc-R-V,                 /*  o-title_desc, */
            OUTPUT billing_prefname-R-V,                   /*  o-prefname, */
            OUTPUT billing_genderhold-R-V,                 /*  o-gender */
            OUTPUT o-unstring-error,                       /*  YES = errors / NO = no errors. */
            OUTPUT o-field-in-error).                      /*  name of the input field that is in error, if one. */

    IF  String_Pat_Name <>  "" THEN DO:                                         /** 1dot3 **/ 
        IF  o-unstring-error = YES THEN DO: 

            IF  billing_lastname-col-U = "Stefani"  OR
                billing_firstname-col-S = "Stefani" THEN
                ASSIGN Bill_format_error = (Bill_format_error - 1).
                 
            IF billing_lastname-col-U <> "Stefani"  AND
                billing_firstname-col-S <> "Stefani"  THEN DO:           
                ASSIGN Bill_format_error = (Bill_format_error + 1).
                ASSIGN  op-field-err-info    = "Bill name: " + TRIM(firstname-col-K) + " " + TRIM(lastname-col-M)
                        op-err-message    = "- Billing input field in error: " + TRIM(billing_firstname-col-S) + " " + TRIM(billing_lastname-col-U).
                DISPLAY STREAM outward 
                        MAG_CUST_RCD.magento-id     FORMAT ">>>>>>>9" 
                        op-field-err-info               FORMAT "x(60)" AT 15 
                        op-err-message                  FORMAT "x(60)" AT 70 SKIP(1) 
                    WITH FRAME outdetail3 NO-LABELS WIDTH 132 DOWN.
                    DOWN WITH FRAME outdetail3.                      
                NEXT mainloopie.
            END.  /* if billing_lastname-col-U <> "Stefani" */ 

             
        END.  /** IF  o-unstring-error = YES  **/  
    END.    /** IF  String_Pat_Name <>  "" **/                                  /** 1dot3 **/ 
   
    RUN VALUE(SEARCH("RStP-MAG-CUST-BIL-U.r"))                                  /* 1dot5 */
            (MAG_CUST_RCD.magento-id,
             OUTPUT op-error-nbr,
             OUTPUT new-Billing-Cust-ID). 

    IF  MAG_CUST_RCD.Progress_Flag = "U" THEN 
        ASSIGN  MAG_CUST_RCD.Progress_Flag     = "IU"
                MAG_CUST_RCD.Progress_DateTime  = TODAY.                     

    IF  MAG_CUST_RCD.Progress_Flag = "A" THEN 
        ASSIGN  MAG_CUST_RCD.Progress_Flag     = "IA"
                MAG_CUST_RCD.Progress_DateTime  = TODAY. 
                                                               
END.  /**  FOR EACH MAG_CUST_RCD  **/

/**  END of mainloopie:     */

DISPLAY STREAM outward 
        " End of input processing at: " TODAY STRING(TIME, "HH:MM:SS") SKIP(1) 
        recordsprocessed       SKIP (1) 
        Cust_format_error      SKIP (1) 
        Bill_format_error      SKIP (1)
        cust-name-error        SKIP (1) 
        "End of Report." 
    WITH FRAME outtrailer WIDTH 132 SIDE-LABELS. 
   
OUTPUT STREAM outward CLOSE.

    OS-COMMAND SILENT 
        VALUE(cmdname)  
        VALUE(emailaddr)
        VALUE(messagetxt) 
        VALUE(subjtxt) 
        VALUE(cmdparams) 
        VALUE(errlog).
    
/* END OF program */
        
