/*------------------------------------------------------------------------
    File        : XML_TT_PeopID_Basic_Data.i

    Description : XML Extraction People ID to be used in the XML-SUB- programs.p.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="9/Feb/17">
    <META NAME="LAST_UPDATED" CONTENT="9/Feb/17">

    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 9/Feb/17.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
DEFINE {1} {2} SHARED TEMP-TABLE XML_TT_PeopID_Basic_Data   
    FIELD TT_PeopID_Seq_Nbr_only        AS INTEGER          /* sequence nbr (1 - nnn) for this temp file. */
    FIELD TT_PeopID_fs_atn_file_id      AS INTEGER          /* use this number to find the processed field 
                                                               in the fs_mstr & atn_det tables. */      
    FIELD TT-PeopID_fs_parent-level     AS INTEGER         
    FIELD TT-PeopID_atn_node_level      AS INTEGER        
    
    FIELD TT_PeopID_people_id           AS INTEGER          /* people_ID - if other programs need to access the people_mstr. */
    
    FIELD TT_PeopID_ERROR_Flag          AS CHARACTER        /* ERROR the input tests results if a major error, not warnings. */
    
    FIELD TT_PeopID_TK_ID               LIKE HHI.TK_mstr.TK_ID
    FIELD TT_PeopID_Tk_test_seq         LIKE HHI.TK_mstr.TK_test_seq
    
    FIELD TT_PeopID_lab_sample_ID       LIKE HHI.TK_mstr.TK_lab_sample_ID
    FIELD TT_PeopID_lab_sample_ID_Seq   LIKE HHI.TK_mstr.TK_lab_seq
    
    FIELD TT_PeopID_lab_ID              LIKE HHI.lab_mstr.lab_ID           /* use when you need the lab_Id for 
                                                                              this person and its tests. */
                                                                              
    FIELD TT-PeopID_TK_Mstr_coll_beg_dte        AS DATE 
    FIELD TT-PeopID_TK_Mstr_coll_end_dte        AS DATE 

/* Which Discrepancy table: People = D_people, Address = D_addr, or Both = D_both */    
    FIELD TT_PeopID_Discrep_Table       AS CHARACTER FORMAT "x(10)"
        
    FIELD TT-test-family                LIKE HHI.test_mstr.test_family     /* should be either : MPA or BIOMED */ 
    FIELD TT-test-type                  LIKE HHI.test_mstr.test_type 
        
            INDEX temp-data         AS PRIMARY UNIQUE  TT_PeopID_Seq_Nbr_only.
                     
/* ********************  Preprocessor Definitions  ******************** */ 
 
/* ***************************  Main Block  *************************** */
