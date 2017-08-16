/*------------------------------------------------------------------------
    File        : XML_TT_People_Data.i

    Description : XML Extraction People Data to Load into Progress.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="11/Jan/17">
    <META NAME="LAST_UPDATED" CONTENT="11/Jan/17">

    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 11/Jan/17.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
DEFINE {1} {2} SHARED TEMP-TABLE XML_TT_People_Data
    FIELD TT-People-Seq-Nbr             AS INTEGER          /* sequence nbr for this temp file. */
    FIELD TT-people_fs_atn_file_ID      AS INTEGER          /* use to find the file_id in the fs_mstr & 
                                                               atn_det table when required. */  
    FIELD TT-people_fs_parent-level     AS INTEGER           
    FIELD TT-people_atn_node_level      AS INTEGER          
    FIELD TT-people_firstname           AS CHARACTER    FORMAT "x(30)"  COLUMN-LABEL "First Name"
    FIELD TT-people_lastname            AS CHARACTER    FORMAT "x(30)"  COLUMN-LABEL "Last Name"
    FIELD TT-people_midname             AS CHARACTER    FORMAT "x(30)"  COLUMN-LABEL "Middle Name"
    FIELD TT-people_prefix              AS CHARACTER    FORMAT "x(8)"   COLUMN-LABEL "Prefix"
    FIELD TT-people_suffix              AS CHARACTER    FORMAT "x(8)"  COLUMN-LABEL "Suffix"
    FIELD TT-people_company             AS CHARACTER    FORMAT "x(20)"  COLUMN-LABEL "Company"
    FIELD TT-people_gender              AS CHARACTER                    COLUMN-LABEL "Sex"
    FIELD TT-people_homephone           AS CHARACTER    FORMAT "x(16)"  COLUMN-LABEL "Home Phone"
    FIELD TT-people_workphone           AS CHARACTER    FORMAT "x(16)"  COLUMN-LABEL "Work Phone"
    FIELD TT-people_cellphone           AS CHARACTER    FORMAT "x(16)"  COLUMN-LABEL "Cell Phone"
    FIELD TT-people_fax                 AS CHARACTER    FORMAT "x(16)"  COLUMN-LABEL "Fax"
    FIELD TT-people_email               AS CHARACTER    FORMAT "x(60)"  COLUMN-LABEL "E-Mail-1"
    FIELD TT-people_email2              AS CHARACTER    FORMAT "x(60)"  COLUMN-LABEL "E-Mail-2"
    FIELD TT-people_addr_id             AS INTEGER                      COLUMN-LABEL "Addr-1"
    FIELD TT-people_contact             AS CHARACTER    FORMAT "x(30)"  COLUMN-LABEL "Contact"
    FIELD TT-people_year                AS CHARACTER                    COLUMN-LABEL "B-YR"
    FIELD TT-people_month               AS CHARACTER                    COLUMN-LABEL "B-MO"
    FIELD TT-people_day                 AS CHARACTER                    COLUMN-LABEL "B-DAY"
    FIELD TT-people_second_addr_id      AS INTEGER                      COLUMN-LABEL "Addr-2"
    FIELD TT-people_title               AS CHARACTER    FORMAT "x(16)"  COLUMN-LABEL "Title"
    FIELD TT-people_prefname            AS CHARACTER    FORMAT "x(24)"  COLUMN-LABEL "Prefered Name"  
    FIELD TT-people_SSN                 AS CHARACTER    FORMAT "x(11)"  COLUMN-LABEL "SSN" 
    FIELD TT-people-pat_mstr_notes      AS CHARACTER                    COLUMN-LABEL "patient_notes"        
            INDEX temp-data         AS PRIMARY UNIQUE  TT-People-Seq-Nbr.
                     
/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
