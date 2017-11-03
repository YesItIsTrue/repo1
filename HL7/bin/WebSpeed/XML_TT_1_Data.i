/*------------------------------------------------------------------------
    File        : XML_TT_1_Data.i

    Description : XML Extraction Temp table hold definations.

    <META NAME="AUTHOR" CONTENT="Harold Luttrell, Sr.">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="10/Jan/17">
    <META NAME="LAST_UPDATED" CONTENT="10/Jan/17">

    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 10/Jan/17.
             
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
DEFINE {1} {2} SHARED TEMP-TABLE XML_TT_1_Data
    FIELD TT-1-Seq-Nbr                  AS INTEGER          /* sequence nbr for this temp file. */
    FIELD TT-1-File-ID                  AS INTEGER 
    FIELD TT-1-parent-level             AS INTEGER 
    FIELD TT-1-p-child-node-level       AS INTEGER 

    FIELD TT-1-Table-Name               AS CHARACTER 
    FIELD TT-1-Field-Name               AS CHARACTER
    FIELD TT-1-Field-Value              AS CHARACTER
            INDEX temp-data         AS PRIMARY UNIQUE TT-1-Seq-Nbr.
                     
/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
