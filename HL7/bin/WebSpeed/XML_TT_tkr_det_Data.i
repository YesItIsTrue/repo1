/*------------------------------------------------------------------------
    File        : XML_TT_tkr_det_Data.i

    Description : XML Extraction TK Detail Data to Load into Progress.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="28/Apr/17">
    <META NAME="LAST_UPDATED" CONTENT="28/Apr/17">

    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 28/Apr/17.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
DEFINE {1} {2} SHARED TEMP-TABLE XML_TT_tkr_det_Data
    FIELD TT-tkr_det-Seq-Nbr                AS INTEGER          /* sequence nbr for this temp file. */
    FIELD TT-tkr_det_fs_atn_file_ID         AS INTEGER          /* use to find the file_id in the fs_mstr & 
                                                                   atn_det table when required. */
    FIELD TT-tkr_det_fs_parent-level        AS INTEGER 
    FIELD TT-tkr_det_atn_node_level         AS INTEGER 
    
    FIELD TT-tkr_det_TKR_ID                 LIKE HHI.TKR_det.TKR_ID
    FIELD TT-tkr_det_TKR_ID_Seq             LIKE HHI.TKR_det.TKR_test_seq 
    
    FIELD TT-tkr_det_TKR_item               LIKE HHI.TKR_det.TKR_item
    FIELD TT-tkr_det_TKR_lab_result         LIKE HHI.TKR_det.TKR_lab_result
    FIELD TT-tkr_det_TKR_ref_uom            LIKE HHI.TKR_det.TKR_ref_uom  
    FIELD TT-tkr_det_TKR_lab_ref            LIKE HHI.TKR_det.TKR_lab_ref  

            INDEX temp-data         AS PRIMARY UNIQUE  TT-tkr_det-Seq-Nbr.
                       
/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
