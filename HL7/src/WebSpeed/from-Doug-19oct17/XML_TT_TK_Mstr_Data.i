/*------------------------------------------------------------------------
    File        : XML_TT_TK_Mstr_Data.i

    Description : XML Extraction TK-mstr Data to Load into Progress.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="28/Feb/17">
    <META NAME="LAST_UPDATED" CONTENT="28/Feb/17">

    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 28/Feb/17.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
DEFINE {1} {2} SHARED TEMP-TABLE XML_TT_TK_Mstr_Data
    FIELD TT-TK_Mstr-Seq-Nbr                AS INTEGER          /* sequence nbr for this temp file. */
    FIELD TT-TK_Mstr_fs_atn_file_ID         AS INTEGER          /* use to find the file_id in the fs_mstr & 
                                                                   atn_det table when required. */
    FIELD TT-TK_Mstr_fs_parent-level        AS INTEGER 
    FIELD TT-TK_Mstr_atn_node_level         AS INTEGER  
    
    FIELD TT-TK_Mstr_people_id              AS INTEGER          /* people_ID - if other programs need to 
                                                                               access the people_mstr. */
    FIELD TT-TK_Mstr_TK_ID                  AS CHARACTER    FORMAT "x(30)"  COLUMN-LABEL "TK ID Nbr"
    FIELD TT-TK_Mstr_TK_ID_Seq              AS INTEGER      FORMAT "99"     COLUMN-LABEL "TKSeq #" 
    
    FIELD TT-TK_Mstr_TK_test_type           AS CHARACTER    FORMAT "x(30)"  COLUMN-LABEL "TK Test Type" 
    
    FIELD TT-TK_Mstr_tk_lab_sample_ID       AS CHARACTER    FORMAT "x(30)"  COLUMN-LABEL "TK Lab Sample ID"
    FIELD TT-TK_Mstr_tk_lab_sample_ID_Seq   AS INTEGER      FORMAT "99"     COLUMN-LABEL "LabSeq #"
    
    FIELD TT-TK_Mstr_tk_test_desc           AS CHARACTER    FORMAT "x(30)"  COLUMN-LABEL "TK Test Desc" 
    
    FIELD TT-TK_Mstr_coll_begin_year        AS CHARACTER    FORMAT "x(4)"   COLUMN-LABEL "c_begin_yr" 
    FIELD TT-TK_Mstr_coll_begin_month       AS CHARACTER    FORMAT "x(2)"   COLUMN-LABEL "c_begin_mo"
    FIELD TT-TK_Mstr_coll_begin_day         AS CHARACTER    FORMAT "x(2)"   COLUMN-LABEL "c_begin_da"
    FIELD TT-TK_Mstr_coll_end_year          AS CHARACTER    FORMAT "x(4)"   COLUMN-LABEL "c_end_yr" 
    FIELD TT-TK_Mstr_coll_end_month         AS CHARACTER    FORMAT "x(2)"   COLUMN-LABEL "c_end_mo"
    FIELD TT-TK_Mstr_coll_end_day           AS CHARACTER    FORMAT "x(2)"   COLUMN-LABEL "c_begin_day"
    
    FIELD TT-TK_Mstr_volume                 AS INTEGER                      COLUMN-LABEL "Volume" 
    
            INDEX temp-data         AS PRIMARY UNIQUE  TT-TK_Mstr-Seq-Nbr.
                      
/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
