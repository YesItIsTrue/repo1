/*------------------------------------------------------------------------
    File        : o-depot-definenames.i
    Purpose     : To make it easier to use the depot utilities without having 
                : to code or duplicate the OUTPUT names/tags  DEFINE STATEMENTs
                : lines of code in your programs.

    Syntax      :

    Description : Contains the OUTPUT names/tags DEFINE STATEMENTs 
                : for the depot utilities.
 
    Author(s)   : Solsource.
    Created     : Tue Aug 26, 2014.
    Notes       :
        
    Updated:        31/Dec/14
    Version:        1.1
    Author:         Harold Luttrell, Sr,
    Description:    Added two output variables.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
  
/* ***  output variables from the find-xxxxxx.p programs.           *** */  
/* ***  address                                                     *** */
DEFINE VARIABLE o-faddr-addrID              LIKE addr_mstr.addr_id     NO-UNDO.   
DEFINE VARIABLE o-faddr-error               AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-faddr-ran                 AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  customer                                                    *** */
DEFINE VARIABLE o-fcust-ID                  LIKE people_mstr.people_id NO-UNDO.
DEFINE VARIABLE o-fcust-addr-ID             LIKE people_mstr.people_addr_id NO-UNDO.
DEFINE VARIABLE o-fcust-exist               AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-fcust-ran                 AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-fcust-error               AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  doctor                                                      *** */
DEFINE VARIABLE o-fdoc-ID                   LIKE people_mstr.people_id NO-UNDO.
DEFINE VARIABLE o-fdoc-addr_ID              LIKE people_mstr.people_addr_ID NO-UNDO.
DEFINE VARIABLE o-fdoc-exist                AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-fdoc-ran                  AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-fdoc-error                AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  patient                                                     *** */
DEFINE VARIABLE o-fpat-ID                   LIKE people_mstr.people_id NO-UNDO.
DEFINE VARIABLE o-fpat-addr-ID              LIKE people_mstr.people_addr_id NO-UNDO.
DEFINE VARIABLE o-fpat-exist                AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-fpat-ran                  AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-fpat-error                AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  people                                                      *** */
DEFINE VARIABLE o-fpe-peopleID              LIKE people_mstr.people_id NO-UNDO.
DEFINE VARIABLE o-fpe-addr_ID               LIKE people_mstr.people_addr_id NO-UNDO.
DEFINE VARIABLE o-fpe-error                 AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-fpe-ran                   AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  scust_shadow                                                *** */
DEFINE VARIABLE o-fshadc-ID                 LIKE people_mstr.people_id NO-UNDO.
DEFINE VARIABLE o-fshadc-addr-ID            LIKE people_mstr.people_addr_id NO-UNDO.
DEFINE VARIABLE o-fshadc-magento-ID         LIKE scust_shadow.scust_magento_ID NO-UNDO.   
DEFINE VARIABLE o-fshadc-exist              AS LOGICAL INITIAL NO              NO-UNDO. 
DEFINE VARIABLE o-fshadc-ran                AS LOGICAL INITIAL NO              NO-UNDO. 
DEFINE VARIABLE o-fshadc-error              AS LOGICAL INITIAL NO              NO-UNDO.  
/* ***  country_mstr                                                *** */
DEFINE VARIABLE o-fcountry-ISO     LIKE country_mstr.Country_ISO        NO-UNDO.
DEFINE VARIABLE o-fcountry-error   AS LOGICAL                                   NO-UNDO.
/* ***  state_mstr                                                   *** */ 
DEFINE VARIABLE o-fstate-ISO       LIKE state_mstr.state_country_ISO    NO-UNDO.
DEFINE VARIABLE o-fstate-error     AS LOGICAL                                   NO-UNDO.
/* ***  end output variables from the find-xxxxxx.p programs.       *** */

/* ***  output variables from the up-create-xxxxxx.p programs.      *** */ 
/* ***  address                                                     *** */
DEFINE VARIABLE o-ucaddr-id                 LIKE addr_mstr.addr_id     NO-UNDO.
DEFINE VARIABLE o-ucaddr-create             AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucaddr-update             AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucaddr-avail              AS LOGICAL INITIAL YES             NO-UNDO.
DEFINE VARIABLE o-ucaddr-successful         AS LOGICAL INITIAL NO              NO-UNDO.  
/* ***  customer                                                    *** */
DEFINE VARIABLE o-uccust-id                 LIKE cust_mstr.cust_id     NO-UNDO.
DEFINE VARIABLE o-uccust-create             AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-uccust-update             AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-uccust-error              AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-uccust-successful         AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  doctor                                                      *** */
DEFINE VARIABLE o-ucdoctor-id               LIKE doctor_mstr.doctor_id     NO-UNDO.
DEFINE VARIABLE o-ucdoctor-create           AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucdoctor-update           AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucdoctor-error            AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucdoctor-successful       AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  patient                                                     *** */
DEFINE VARIABLE o-ucpatient-id              LIKE patient_mstr.patient_id   NO-UNDO.
DEFINE VARIABLE o-ucpatient-create          AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucpatient-update          AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucpatient-error           AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucpatient-successful      AS LOGICAL INITIAL NO              NO-UNDO. 
/* ***  people                                                      *** */
DEFINE VARIABLE o-ucpeople-id               LIKE people_mstr.people_id NO-UNDO.
DEFINE VARIABLE o-ucpeople-create           AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucpeople-update           AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucpeople-avail            AS LOGICAL INITIAL YES             NO-UNDO.
DEFINE VARIABLE o-ucpeople-successful       AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  scust_shadow                                                *** */
DEFINE VARIABLE o-ucscust-id                LIKE scust_shadow.scust_id     NO-UNDO.
DEFINE VARIABLE o-ucscust-create            AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucscust-update            AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucscust-error             AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucscust-successful        AS LOGICAL INITIAL NO              NO-UNDO. 
/* ***  TK_mstr                                                     *** */
DEFINE VARIABLE o-uctkm-id                  LIKE TK_mstr.TK_id             NO-UNDO.
DEFINE VARIABLE o-uctkm-create              AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-uctkm-update              AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-uctkm-avail               AS LOGICAL INITIAL YES             NO-UNDO.
DEFINE VARIABLE o-uctkm-successful          AS LOGICAL INITIAL NO              NO-UNDO.
/* ***  TKR_det                                                     *** */
DEFINE VARIABLE o-ucTKRdet-id               LIKE TKR_det.TKR_id            NO-UNDO.
DEFINE VARIABLE o-ucTKRdet-create           AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucTKRdet-update           AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE VARIABLE o-ucTKRdet-avail            AS LOGICAL INITIAL YES             NO-UNDO.
DEFINE VARIABLE o-ucTKRdet-successful       AS LOGICAL INITIAL NO              NO-UNDO.

/* ***  create transaction history records.                         *** */
DEFINE VARIABLE o-ctrh-id                   LIKE trh_hist.trh_id       NO-UNDO.
DEFINE VARIABLE o-ctrh-error                AS LOGICAL INITIAL YES             NO-UNDO.
/* ***  end create transaction history records.                     *** */

/* ***  end output variables from the upcreate-xxxxxx.p programs.   *** */

/* ***  Subroutine: SUB-UnString-Name.p output variables.           *** */
DEFINE  VARIABLE o-unstring-error           AS LOGICAL INITIAL NO              NO-UNDO.  /** 31/Dec/14 **/
DEFINE  VARIABLE o-field-in-error           AS CHARACTER FORMAT "X(30)"        NO-UNDO.  /** 31/Dec/14 **/
/* ***  end output variables for Subroutines.                       *** */

/* ******************* End  of  Definitions *************************** */

/* ********************  Preprocessor Definitions  ******************** */
/*  none.  */

/* ***************************  Main Block  *************************** */
/*  none.  */