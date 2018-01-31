/*------------------------------------------------------------------------
    File        : XML_TT_Address_Data.i

    Description : XML Extraction Address Data to Load into Progress.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="13/Jan/17">
    <META NAME="LAST_UPDATED" CONTENT="13/Jan/17">

    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 14/Jan/17.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
DEFINE {1} {2} SHARED TEMP-TABLE XML_TT_Address_Data
    FIELD TT-address-Seq-Nbr             AS INTEGER             /* sequence nbr for this temp file. */
    FIELD TT-address_fs_atn_file_ID      AS INTEGER             /* use to find the file_id in the fs_mstr & 
                                                                   atn_det table when required. */
    FIELD TT-address_fs_parent-level     AS INTEGER 
    FIELD TT-address_atn_node_level      AS INTEGER  
    FIELD TT-addr_addr1                  AS CHARACTER 
    FIELD TT-addr_addr2                  AS CHARACTER 
    FIELD TT-addr_addr3                  AS CHARACTER 
    FIELD TT-addr_city                   AS CHARACTER
    FIELD TT-state_iso                   AS CHARACTER
    FIELD TT-addr_zip                    AS CHARACTER  
    FIELD TT-country_iso                 AS CHARACTER             
            INDEX temp-data         AS PRIMARY UNIQUE  TT-address-Seq-Nbr .
                     
/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
