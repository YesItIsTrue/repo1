/*------------------------------------------------------------------------
    File        : HL7-Load-Main-DEV.
 
    Description : Load/Import/Extract the HL7 (XML) data from the 
                : fs_mstr and atn_det tables 
                : for processing and updates the different  
                : database table records as reqired.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Tue Jan 10, 2017.
    Notes       : Fields that start with  
                :   i-  are input parameters to subroutines and
                :   o-  are output parameters from subroutines.
                
    Revision History:
    -----------------
    1.1 - written by Harold Luttrell, Sr. on 15/Sept/17. 
          Added code to send any generated e-mails from HL7 to me only
          if the ITdisplay logical is set to YES.
            IF  ITdisplay THEN 
                ASSIGN e_to-whom = " harold.luttrell@mysolsource.com".
          Also added code to pass the total number of tests that was
          selected during this schedule run to HL7-Load-Append-Rpts.r.
          Marked by /* 1dot1 */ 

    1.2 - written by Harold Luttrell, Sr. on 20/Oct/17. 
          Changed to use single rcode PROPATH settings in accordance 
          with Release 12 (CMC structure).
          Marked by /* 1dot2 */
                               
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
ROUTINE-LEVEL ON ERROR UNDO, THROW.

{UTIL-set_propath-HHI_DEV-U.i}.                                        /* 1dot2 */

/* 
***************************************************************************************************  
*    The i-Admin-Update-OverRyde logical switch, when set to YES, is used to Update the actual    *
*        database records if any of the records already exists.                                   *
*                                                                                                 *
*    When set to NO then the tests inputs are ERRORed off/rejected if the database records        *
*    exists.                                                                                      *
*                                                                                                 *
*    By using this option, it saves us having two (2) entire sets of HL7 programs, one (1) to     *
*        store only new records and the second set to actually update the found/exixting database * 
*        records if the administrator wants to update/overlay the old data with the new data.     *
*                                                                                                 *
*    This option will have to be passed from the ADMIN program and this main program will         *
*        have to grab it somehow and pass it to the updating programs....................         *
***************************************************************************************************        
*/   
 
DEFINE VARIABLE  i-Admin-Update-OverRyde    AS LOGICAL  INITIAL NO              NO-UNDO.

/* ********************************************************************************************* */
/* if ITdisplay set to YES - program will generate dumps/list the different data files to assist in
debugging the different programs. */

DEFINE VARIABLE ITdisplay               AS LOGICAL INITIAL YES              NO-UNDO. 

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.       /* 1dot1 */

IF ITdisplay THEN DO:                                                 /* 1dot1 */ 
    PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */   
    PUT UNFORMATTED  "PROPATH =" PROPATH  SKIP. /* displays the PROPATH values in the batch C:\Progress\WRK\HL7_log.txt file. */ /* 1dot1 */
    PUT UNFORMATTED " " SKIP.                                           /* 1dot1 */
END.
/*  GET the input Admin OverRyde VALUE and set the VALUE in the i-Admin-Update-OverRyde IF = YES. */
/*                                                               */
DEFINE VARIABLE h-ip-ans                    AS CHARACTER FORMAT "x(3)"          NO-UNDO.

INPUT FROM VALUE(SEARCH("HL7-OverRyde.txt")) NO-CONVERT.                         /* 1dot2 */

IMPORT h-ip-ans.

INPUT CLOSE.

PUT UNFORMATTED   " " SKIP.
 
PUT UNFORMATTED   APPS-HL7 "\HL7-OverRyde.txt = " h-ip-ans SKIP(1).               /* 1dot2 */

IF  h-ip-ans = "YES" THEN
    ASSIGN  i-Admin-Update-OverRyde = YES.


DEFINE VARIABLE  i-flab-ID                  LIKE lab_mstr.lab_ID                NO-UNDO. 
DEFINE VARIABLE  o-flab-name                LIKE lab_mstr.lab_name              NO-UNDO.
DEFINE VARIABLE  o-flab-error               AS LOGICAL INITIAL NO               NO-UNDO.

DEFINE VARIABLE  o-people-id                LIKE people_mstr.people_id          NO-UNDO.
DEFINE VARIABLE  o-people-load-error        AS LOGICAL INITIAL NO               NO-UNDO.

DEFINE VARIABLE  o-addr-id                  LIKE addr_mstr.addr_id              NO-UNDO.
DEFINE VARIABLE  o-addr-load-error          AS LOGICAL INITIAL NO               NO-UNDO.

DEFINE VARIABLE  o-TK-Mstr-id               LIKE TK_mstr.TK_ID                  NO-UNDO.
DEFINE VARIABLE  o-Lab_Sample_ID            LIKE TK_mstr.TK_lab_sample_ID       NO-UNDO.
DEFINE VARIABLE  o-TK-Mstr-load-error       AS LOGICAL INITIAL NO               NO-UNDO.

DEFINE VARIABLE  o-TKR-det-id               LIKE TKR_det.TKR_ID                 NO-UNDO. 
DEFINE VARIABLE  o-TKR-det-load-error       AS LOGICAL INITIAL NO               NO-UNDO.
                
DEFINE VARIABLE  o-error-message            AS CHARACTER  FORMAT "x(200)"       NO-UNDO.

DEFINE VARIABLE i-ctrh-id                   LIKE trh_hist.trh_id                NO-UNDO.
DEFINE VARIABLE i-ctrh-item                 LIKE trh_hist.trh_item              NO-UNDO.
DEFINE VARIABLE i-ctrh-action               LIKE trh_hist.trh_action            NO-UNDO.
DEFINE VARIABLE i-ctrh-qty                  LIKE trh_hist.trh_qty               NO-UNDO.
DEFINE VARIABLE i-ctrh-serial               LIKE trh_hist.trh_serial            NO-UNDO.
DEFINE VARIABLE i-ctrh-sequence             LIKE trh_hist.trh_sequence          NO-UNDO.
DEFINE VARIABLE i-ctrh-date                 LIKE trh_hist.trh_create_date       NO-UNDO.
DEFINE VARIABLE i-mtrh-date                 LIKE trh_hist.trh_modified_date     NO-UNDO.
DEFINE VARIABLE i-trh-date                  LIKE trh_hist.trh_date              NO-UNDO.

DEFINE VARIABLE o-ctrh-id                   LIKE trh_hist.trh_id                NO-UNDO.
DEFINE VARIABLE o-ctrh-error                AS LOGICAL INITIAL YES              NO-UNDO.
 
DEFINE VARIABLE i-att_file_id   LIKE att_files.att_file_id                      NO-UNDO.
DEFINE VARIABLE i-att_table     LIKE att_files.att_table                        NO-UNDO.
DEFINE VARIABLE i-att_field1    LIKE att_files.att_field1                       NO-UNDO.
DEFINE VARIABLE i-att_value1    LIKE att_files.att_value1                       NO-UNDO.
DEFINE VARIABLE i-att_field2    LIKE att_files.att_field2                       NO-UNDO.
DEFINE VARIABLE i-att_value2    LIKE att_files.att_value2                       NO-UNDO.
DEFINE VARIABLE i-att_field3    LIKE att_files.att_field3                       NO-UNDO.
DEFINE VARIABLE i-att_value3    LIKE att_files.att_value3                       NO-UNDO.
DEFINE VARIABLE i-att_field4    LIKE att_files.att_field4                       NO-UNDO.
DEFINE VARIABLE i-att_value4    LIKE att_files.att_value4                       NO-UNDO.
DEFINE VARIABLE i-att_field5    LIKE att_files.att_field5                       NO-UNDO.
DEFINE VARIABLE i-att_value5    LIKE att_files.att_value5                       NO-UNDO.
DEFINE VARIABLE i-att_category  LIKE att_files.att_category                     NO-UNDO.
DEFINE VARIABLE i-att_filepath  LIKE att_files.att_filepath                     NO-UNDO.
DEFINE VARIABLE i-att_filename  LIKE att_files.att_filename                     NO-UNDO.
DEFINE VARIABLE i-att_filedesc  LIKE att_files.att_filedesc                     NO-UNDO.
DEFINE VARIABLE i-att_major_version LIKE att_files.att_major_version            NO-UNDO.
DEFINE VARIABLE i-att_minor_version LIKE att_files.att_minor_version            NO-UNDO.

DEFINE VARIABLE o-att_file_id       LIKE att_files.att_file_id                  NO-UNDO.
DEFINE VARIABLE o-att-find-create   AS LOGICAL                                  NO-UNDO.
DEFINE VARIABLE o-att-find-update   AS LOGICAL                                  NO-UNDO.
DEFINE VARIABLE o-att-find-success  AS LOGICAL                                  NO-UNDO.

DEFINE VARIABLE i-fsatn-id          LIKE fs_mstr.fs_file_ID                     NO-UNDO.
DEFINE VARIABLE i-processed         LIKE fs_mstr.fs_processed                   NO-UNDO.
DEFINE VARIABLE o-successful        AS LOGICAL INITIAL YES                      NO-UNDO.
DEFINE VARIABLE o-processed         LIKE fs_mstr.fs_processed                   NO-UNDO.

{XML_TT_1_Data.i "new"}.            /*  XML Extraction Temp table hold definations */
{XML_TT_People_Data.i "new"}.       /*  XML Extraction People Data to Load into Progress. */ 
{XML_TT_Address_Data.i "new"}.      /*  XML Extraction Address Data to Load into Progress. */
{XML_TT_PeopID_Basic_Data.i "NEW" "GLOBAL"}.  /* XML Extraction People ID-ONLY to be used in the XML-SUB- programs.p. */
{XML_TT_TK_Mstr_Data.i "NEW" "GLOBAL"}.       /*  XML Extraction TK Master Data to Load into Progress. */ 
{XML_TT_tkr_det_Data.i "new"}.      /*  XML Extraction TK Detail Data to Load into Progress. */

{E-Mail_definations.i}. 

{Logs_Rpts_Paths_Folders.i "NEW" "GLOBAL"}.  /* Logs/Reports folder path. */ 

CREATE  Logs_Rpts_Paths_Folders.
ASSIGN  TT-Logs-Rpts-Seq_Nbr_only = 1
        TT-Logs-Rpts-Path-Folder  = WRK-Logs.
         
/*IF  ITdisplay THEN                                                          /* 1dot1 */*/
/*    ASSIGN e_to-whom = " harold.luttrell@mysolsource.com".                  /* 1dot1 */*/
    
DEFINE BUFFER   h-XML_TT-buf  FOR XML_TT_1_Data.

DEFINE VARIABLE o-TKR-det-fs-atn-file-ID   LIKE XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID  NO-UNDO.   
DEFINE VARIABLE ip-Table-Name           AS CHARACTER                        NO-UNDO.
DEFINE VARIABLE h-ip-table-na           LIKE ip-Table-Name                  NO-UNDO.
DEFINE VARIABLE h-TK_ID                 LIKE TK_mstr.TK_ID                  NO-UNDO. 
DEFINE VARIABLE h-TK_test_seq           AS CHARACTER                        NO-UNDO. 
DEFINE VARIABLE h-Lab_Sample_ID         LIKE TK_mstr.TK_lab_sample_ID       NO-UNDO.
DEFINE VARIABLE h-Lab_Samp_seq          AS CHARACTER                        NO-UNDO.
DEFINE VARIABLE hold-set_id-Name        AS CHARACTER                        NO-UNDO.
DEFINE VARIABLE utee-fs-parent-level    AS INTEGER                          NO-UNDO.
DEFINE VARIABLE h-File-ID               AS INTEGER                          NO-UNDO.
DEFINE VARIABLE SNP-to-trh-hist         AS INTEGER INITIAL 0                NO-UNDO.    

DEFINE VARIABLE h-TK_ID_Seq-Nbr         AS INTEGER INITIAL 1                NO-UNDO.
DEFINE VARIABLE h-Lab_Sample_ID_Seq-Nbr AS INTEGER INITIAL 1                NO-UNDO. 

DEFINE VARIABLE c-tests-processed       AS INTEGER  INITIAL 0               NO-UNDO. 
DEFINE VARIABLE Temp-1-Seq-Nbr          AS INTEGER  INITIAL 0               NO-UNDO. 

DEFINE VARIABLE Temp-People-Seq-Nbr     AS INTEGER  INITIAL 0               NO-UNDO.  
DEFINE VARIABLE Temp-Address-Seq-Nbr    AS INTEGER  INITIAL 0               NO-UNDO. 
DEFINE VARIABLE Temp-TK-mstr-Seq-Nbr    AS INTEGER  INITIAL 0               NO-UNDO. 
DEFINE VARIABLE Temp-TKR_det-Seq-Nbr    AS INTEGER  INITIAL 0               NO-UNDO.
DEFINE VARIABLE Temp-SNP-Seq-Nbr        AS INTEGER  INITIAL 0               NO-UNDO.
DEFINE VARIABLE First-Date              AS INTEGER  INITIAL 0               NO-UNDO.
DEFINE VARIABLE Second-Date             AS INTEGER  INITIAL 0               NO-UNDO.

DEFINE VARIABLE OS-stat                 AS INTEGER                          NO-UNDO.
DEFINE VARIABLE ithree                  AS INTEGER                          NO-UNDO.
DEFINE VARIABLE len                     AS INTEGER                          NO-UNDO.
DEFINE VARIABLE ix                      AS INTEGER                          NO-UNDO.
            
DEFINE VARIABLE h_from_path             LIKE att_files.att_filepath         NO-UNDO.
DEFINE VARIABLE h_to_path               LIKE att_files.att_filepath         NO-UNDO.
DEFINE VARIABLE h_file_name             LIKE att_files.att_filename         NO-UNDO.
DEFINE VARIABLE hold-field-name         AS CHARACTER FORMAT "x(32)"         NO-UNDO.
DEFINE VARIABLE dir_name                AS CHARACTER FORMAT "x(150)"        NO-UNDO.
DEFINE VARIABLE h_HTML_prefix           AS CHARACTER FORMAT "x(60)"         NO-UNDO.
DEFINE VARIABLE by-pass-SNP-data        AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE by-pass-UTEE-Dupe-Data  AS LOGICAL INITIAL NO               NO-UNDO. 
DEFINE VARIABLE by-pass-NO-COLL-date    AS LOGICAL INITIAL NO               NO-UNDO.  
DEFINE VARIABLE TK-ID-len               AS INTEGER                          NO-UNDO. 
                 
DEFINE VARIABLE xx                      AS INTEGER                          NO-UNDO. 

/* Following TEMP-TABLE is used to get the DATE off of the input data file
that you see in the Windows explorer.
The data file date is used for the "HHI-RCVD" history date in the trh_hist record. */
         
DEFINE  TEMP-TABLE dirlist_data  UNDO 
        FIELD IP_Field-1  AS CHARACTER FORMAT "x(60)"   /* contains the DATE of the file when loaded on the server. */
        FIELD IP_Field-2  AS CHARACTER FORMAT "x(60)"   /* contains the Hour & Minutes */        
        FIELD IP_Field-3  AS CHARACTER FORMAT "x(60)"   /* contains either AM or PM */
        FIELD IP_Field-4  AS CHARACTER FORMAT "x(60)"   /* contains the size of the file */
        FIELD IP_Field-5  AS CHARACTER FORMAT "x(60)"   /* contains the filename! */
            INDEX temp-data         AS PRIMARY UNIQUE IP_Field-2. 


/* get the Logs-Path-Folder name. */        
FIND Logs_Rpts_Paths_Folders WHERE TT-Logs-Rpts-Seq_Nbr_only = 1 NO-LOCK NO-ERROR. 

PUT UNFORMATTED "" SKIP(1) "TT-Logs-Rpts-Path-Folder =" TT-Logs-Rpts-Path-Folder SKIP(1).
            
/*  Output report with the count of total Test Kits selected for each run. */
DEFINE STREAM outwardTTD.
DEFINE VARIABLE loadRpt AS CHARACTER NO-UNDO. 
ASSIGN loadRPT = TT-Logs-Rpts-Path-Folder + "HL7-Load-Main-Rpt.txt".
OUTPUT STREAM outwardTTD TO value(loadRpt) PAGED. 

PUT STREAM outwardTTD 
    "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP.
PUT STREAM outwardTTD 
    "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP(1). 
               
IF  i-Admin-Update-OverRyde = YES THEN 
    PUT STREAM outwardTTD
        "Admin-Update-OverRyde Option has been turned on for this run only!" AT 5 SKIP(1).
            
/*IF  ITdisplay = YES THEN DO:*/
    DEFINE STREAM PeopBasic.
/*    DEFINE VARIABLE dumpRptPB AS CHARACTER                    */
/*        INITIAL "C:\PROGRESS\WRK\PeopleBasic-Log.txt" NO-UNDO.*/
    DEFINE VARIABLE dumpRptPB AS CHARACTER NO-UNDO.
    ASSIGN dumpRptPB = TT-Logs-Rpts-Path-Folder + "PeopleBasic-Log.txt". 
    OUTPUT STREAM PeopBasic TO value(dumpRptPB) APPEND.
    
    PUT STREAM PeopBasic
        "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP.
    PUT STREAM PeopBasic
        "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP(1).
        
    IF  i-Admin-Update-OverRyde = YES THEN 
        PUT STREAM PeopBasic
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP(1).
        
/*END. /*  IF  ITdisplay THEN DO */*/

IF  ITdisplay = YES THEN DO:  
    DEFINE STREAM TT1dump.
/*    DEFINE VARIABLE dumpR1 AS CHARACTER                              */
/*        INITIAL "C:\PROGRESS\WRK\XML-Load-Main-TT1-DUMP.txt" NO-UNDO.*/
    DEFINE VARIABLE dumpR1 AS CHARACTER NO-UNDO.
    ASSIGN dumpR1 = TT-Logs-Rpts-Path-Folder + "XML-Load-Main-TT1-DUMP.txt".
    OUTPUT STREAM TT1dump TO value(dumpR1).
    PUT STREAM TT1dump 
        "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP(1).
    IF  i-Admin-Update-OverRyde = YES THEN 
        PUT STREAM TT1dump
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP(2).
    PUT STREAM TT1dump 
        "     seq:   fs_file_ID   p-lvl     c_lvl  TABLE:         Field-Name:          Field-value:" SKIP (2).    
END. /*  IF  ITdisplay THEN DO */    

IF  ITdisplay = YES THEN DO:    
    DEFINE STREAM DBUTrace.
/*    DEFINE VARIABLE TraceRpt AS CHARACTER                              */
/*        INITIAL "C:\PROGRESS\WRK\XML-Load-Main_Trace-Para.txt" NO-UNDO.*/
    DEFINE VARIABLE TraceRpt AS CHARACTER NO-UNDO.
    ASSIGN TraceRpt = TT-Logs-Rpts-Path-Folder + "XML-Load-Main_Trace-Para.txt".
    OUTPUT STREAM DBUTrace TO value(TraceRpt).
    PUT STREAM DBUTrace 
        "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP.
    PUT STREAM DBUTrace 
        "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP(1).
    IF  i-Admin-Update-OverRyde = YES THEN 
        PUT STREAM DBUTrace
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP(2). 
               
END. /*  IF  ITdisplay THEN DO */
 
IF  ITdisplay = YES THEN DO:    
    DEFINE STREAM DBUTrace1.
/*    DEFINE VARIABLE Trace1Rpt AS CHARACTER                                */
/*        INITIAL "C:\PROGRESS\WRK\XML-SUB-People_Trace-1-Dump.txt" NO-UNDO.*/
    DEFINE VARIABLE Trace1Rpt AS CHARACTER NO-UNDO.
    ASSIGN Trace1Rpt = TT-Logs-Rpts-Path-Folder + "XML-SUB-People_Trace-1-Dump.txt".
    OUTPUT STREAM DBUTrace1 TO value(Trace1Rpt).
    PUT STREAM DBUTrace1 
        "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP.
    PUT STREAM DBUTrace1 
        "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP(1).
    IF  i-Admin-Update-OverRyde = YES THEN 
        PUT STREAM DBUTrace1
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP(2).         
END. /*  IF  ITdisplay THEN DO */

IF  ITdisplay = YES THEN DO:    
    DEFINE STREAM DBUTrace2.
/*    DEFINE VARIABLE Trace2Rpt AS CHARACTER                                 */
/*        INITIAL "C:\PROGRESS\WRK\XML-SUB-Address_Trace-2-Dump.txt" NO-UNDO.*/
    DEFINE VARIABLE Trace2Rpt AS CHARACTER NO-UNDO.
    ASSIGN Trace2Rpt = TT-Logs-Rpts-Path-Folder + "XML-SUB-Address_Trace-2-Dump.txt".
    OUTPUT STREAM DBUTrace2 TO value(Trace2Rpt).
    PUT STREAM DBUTrace2 
        "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP.
    PUT STREAM DBUTrace2 
        "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP(1).
    IF  i-Admin-Update-OverRyde = YES THEN 
        PUT STREAM DBUTrace2
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP(2).         
END. /*  IF  ITdisplay THEN DO */ 

IF  ITdisplay = YES THEN DO:    
    DEFINE STREAM DBUTrace3.
/*    DEFINE VARIABLE Trace3Rpt AS CHARACTER                                 */
/*        INITIAL "C:\PROGRESS\WRK\XML-SUB-TK_Mstr_Trace-3-Dump.txt" NO-UNDO.*/
    DEFINE VARIABLE Trace3Rpt AS CHARACTER NO-UNDO.
    ASSIGN Trace3Rpt = TT-Logs-Rpts-Path-Folder + "XML-SUB-TK_Mstr_Trace-3-Dump.txt".
    OUTPUT STREAM DBUTrace3 TO value(Trace3Rpt).
    PUT STREAM DBUTrace3 
        "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP.
    PUT STREAM DBUTrace3 
        "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP(1).
    IF  i-Admin-Update-OverRyde = YES THEN 
        PUT STREAM DBUTrace3
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP(2).             
END. /*  IF  ITdisplay THEN DO */ 

IF  ITdisplay = YES THEN DO:    
    DEFINE STREAM DBUTrace4.
/*    DEFINE VARIABLE Trace4Rpt AS CHARACTER                                 */
/*        INITIAL "C:\PROGRESS\WRK\XML-SUB-TKR_det_Trace-4-Dump.txt" NO-UNDO.*/
    DEFINE VARIABLE Trace4Rpt AS CHARACTER NO-UNDO.
    ASSIGN Trace4Rpt = TT-Logs-Rpts-Path-Folder + "XML-SUB-TKR_det_Trace-4-Dump.txt".
    OUTPUT STREAM DBUTrace4 TO value(Trace4Rpt).
    PUT STREAM DBUTrace4 
        "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP.
    PUT STREAM DBUTrace4 
        "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP(1).
    IF  i-Admin-Update-OverRyde = YES THEN 
        PUT STREAM DBUTrace4
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP(2).         
END. /*  IF  ITdisplay THEN DO */ 

/* ***************************  Main Block  *************************** */
PUT UNFORMATTED  "Start of HL7-Load-Main Program."  SKIP.
   
IF  ITDisplay = YES THEN
        PUT STREAM DBUTrace "Start of Main Program."  SKIP(1)
                            "FirstLoopie: paragraph." SKIP.   

/* ***************************************************************************** *  
 * Extract the input HL7 data from the fs_mstr & atn_det tables. * 
 * Section 1.                                                                    * 
 * Select  data where the fs_processed and atn.processed values                  * 
 *         are set to: "NEW"  or "CORRECTED".                                    *
 * ***************************************************************************** */ 
    
FirstLoopie: 
    
FOR EACH fs_mstr    WHERE  fs_mstr.fs_deleted = ?   
                      AND  (TRIM(fs_mstr.fs_processed) = "NEW"  OR TRIM(fs_mstr.fs_processed) = "CORRECTED")
            EXCLUSIVE-LOCK,
    EACH atn_det    WHERE  atn_det.atn_deleted = ? 
                      AND  atn_det.atn_file_ID = fs_mstr.fs_file_ID 
                      AND  atn_det.atn_node_level = fs_mstr.fs_child_level 
                      AND  (TRIM(atn_det.atn_processed) = "NEW"  OR  TRIM(atn_det.atn_processed) = "CORRECTED")
            EXCLUSIVE-LOCK 
                 BREAK BY fs_mstr.fs_file_ID BY fs_mstr.fs_child_level  BY atn_det.atn_node_level  :
                
/* Bypass the xml record - not needed.  "xmlns: ATTR     http://www.w3.org/2001/XMLSche"   */

    IF  SUBSTRING(atn_det.atn_name, 1, 6) = "xmlns:" THEN 
    
        NEXT FirstLoopie.
             
/* Start of a new HL7 input. Space out the variable ip-Table-Name.  */
    
    IF  TRIM(atn_det.atn_name) =  "root"    THEN DO: 
        
             ASSIGN  ip-Table-Name      = "". 
             
             NEXT FirstLoopie.
             
        END.  /* IF  TRIM(atn_det.atn_name) =  "root"  */ 
  
/* increment the c-tests-processed counter by 1 and 
    space out the ip-Table-Name again incase the ROOT record did not get supplied. */

    IF  (fs_mstr.fs_parent_level = 1)   AND 
        (atn_det.atn_node_level  = 2)   AND 
        TRIM(atn_det.atn_name)  = "TK_test_seq" AND 
        TRIM(atn_det.atn_value) = "" THEN DO: 
            
            ASSIGN  ip-Table-Name        = ""
                    utee-fs-parent-level = 0
                    c-tests-processed    = (c-tests-processed + 1)
                    h-ip-table-na        = ""
                    SNP-to-trh-hist      = 0.
                    
            ASSIGN by-pass-NO-COLL-date  = NO. 
                    
            NEXT FirstLoopie.
            
    END. /* IF (fs_mstr.fs_parent_level = 1   and  atn_det.atn_node_level  = 2 ) */
    
/*  UTEE- code set up. */
/*          UTEE input test files have 2 or more tests results within their files. */
    
    IF  (fs_mstr.fs_parent_level = 1)   AND 
        (atn_det.atn_node_level  > 2)   AND 
        TRIM(atn_det.atn_name)  = "TK_test_seq" AND 
        TRIM(atn_det.atn_value) = "" THEN DO: 
            
            ASSIGN  utee-fs-parent-level   = atn_det.atn_node_level
                    c-tests-processed      = (c-tests-processed + 1).
                    
            NEXT FirstLoopie.
            
    END. /* IF (fs_mstr.fs_parent_level = 1   and   atn_det.atn_node_level > 2) */
    
    IF  utee-fs-parent-level   > 0 AND 
        utee-fs-parent-level   = fs_mstr.fs_parent_level THEN DO: 
                                           
           ASSIGN  ip-Table-Name = TRIM(atn_det.atn_name).
           
           NEXT FirstLoopie.
           
    END. /* IF  utee-fs-parent-level   > 0  and   utee-fs-parent-level   = fs_mstr.fs_parent_level */
    
/* get the input table name. */
   
    IF  h-ip-table-na  = "SNP_ID"           AND 
        ip-Table-Name  = "trh_hist"         AND 
        TRIM(atn_det.atn_name) = "tk_mstr"  THEN 
        
            ASSIGN  ip-Table-Name   = "SNP_ID"
                    h-ip-table-na   = "".

    IF  ip-Table-Name                       = "SNP_ID"  AND   
        SUBSTRING(atn_det.atn_name, 1, 3)   =  "tk_"    THEN
        
            ASSIGN  ip-Table-Name   =  "SNP_ID".
            
    ELSE       
    
    IF  (fs_mstr.fs_parent_level = 2)   AND 
         TRIM(atn_det.atn_value) = ""   THEN DO:
             
            ASSIGN  ip-Table-Name        = TRIM(atn_det.atn_name).
                                      
            NEXT FirstLoopie.  
                 
    END.  /* IF  (fs_mstr.fs_parent_level = 2)  AND  atn_det.atn_value = "" */
               
/* Store the SNP FAKE table name.  */
                 
    IF  TRIM(atn_det.atn_name)    = "SNP_ID"    AND
        TRIM(atn_det.atn_value)   = ""          AND
        atn_det.atn_file_ID       = fs_mstr.fs_file_ID THEN DO:
            
            ASSIGN  ip-Table-Name               = "SNP_ID".
            
            NEXT FirstLoopie.
            
    END. /* IF  TRIM(atn_det.atn_name)    = "SNP_ID"  */
                     
    IF  (TRIM(atn_det.atn_name) = "coll_begin"   OR 
         TRIM(atn_det.atn_name) = "coll_end"   ) AND 
         TRIM(atn_det.atn_value) = ""            THEN DO:   
                
    /* ***************************************************** *    
     * Create the XML Extraction Temp table hold definations * 
     * ***************************************************** */    
                CREATE  XML_TT_1_Data.
                
                IF  SNP-to-trh-hist = 0 THEN
                    ASSIGN  h-ip-table-na       = ip-Table-Name
                            ip-Table-Name       = "trh_hist"
                            SNP-to-trh-hist     = 1.
                            
                ASSIGN  Temp-1-Seq-Nbr                    = (Temp-1-Seq-Nbr + 1).  
                              
                ASSIGN  XML_TT_1_Data.TT-1-Seq-Nbr        = Temp-1-Seq-Nbr                 
                        XML_TT_1_Data.TT-1-File-ID        = fs_mstr.fs_file_id
                        XML_TT_1_Data.TT-1-parent-level   = fs_mstr.fs_parent_level
                        XML_TT_1_Data.TT-1-p-child-node-level   = fs_mstr.fs_child_level
                        
                        XML_TT_1_Data.TT-1-Table-Name     = TRIM(ip-Table-Name) 
                        XML_TT_1_Data.TT-1-Field-Name     = TRIM(atn_det.atn_name)
                        XML_TT_1_Data.TT-1-Field-Value    = TRIM(atn_det.atn_name).       /* force the name into the value field for dates. */
                
                NEXT FirstLoopie.  
                        
    END. /* IF  TRIM(atn_det.atn_name) = "coll_begin" */
 
                     
    IF  SNP-to-trh-hist             = 0         AND               
        ip-Table-Name               = "SNP_ID"  AND 
        (TRIM(atn_det.atn_name)     = "year"    OR 
         TRIM(atn_det.atn_name)     = "month"   OR  
         TRIM(atn_det.atn_name)     = "day" )   AND 
         TRIM(atn_det.atn_value)    = ""        THEN DO:   
                
                IF  SNP-to-trh-hist = 0 THEN
                
                    ASSIGN  h-ip-table-na           = ip-Table-Name
                            ip-Table-Name           = "trh_hist"
                            SNP-to-trh-hist         = 1.
                                    
    /* ***************************************************** *    
     * Create the XML Extraction Temp table hold definations * 
     * ***************************************************** */    
                CREATE  XML_TT_1_Data.
                
                ASSIGN  Temp-1-Seq-Nbr                    = (Temp-1-Seq-Nbr + 1). 
                               
                ASSIGN  XML_TT_1_Data.TT-1-Seq-Nbr        = Temp-1-Seq-Nbr                
                        XML_TT_1_Data.TT-1-File-ID        = fs_mstr.fs_file_id
                        XML_TT_1_Data.TT-1-parent-level   = fs_mstr.fs_parent_level
                        XML_TT_1_Data.TT-1-p-child-node-level    = fs_mstr.fs_child_level
                        
                        XML_TT_1_Data.TT-1-Table-Name     = TRIM(ip-Table-Name) 
                        XML_TT_1_Data.TT-1-Field-Name     = TRIM(atn_det.atn_name)
                        XML_TT_1_Data.TT-1-Field-Value    = TRIM(atn_det.atn_name).       /* force the name into the value field for dates. */
                
                NEXT FirstLoopie.   
                       
    END. /*  IF  SNP-to-trh-hist             = 0  */
               
/* *********************************************************** *    
 * Create the XML Extraction Temp table hold names and values. * 
 * *********************************************************** */    
    
    IF  TRIM(atn_det.atn_value) <> "" THEN DO: 
        
        CREATE  XML_TT_1_Data.
        
        ASSIGN  Temp-1-Seq-Nbr                    = (Temp-1-Seq-Nbr + 1). 
                       
        ASSIGN  XML_TT_1_Data.TT-1-Seq-Nbr        = Temp-1-Seq-Nbr         
                XML_TT_1_Data.TT-1-File-ID        = fs_mstr.fs_file_id
                XML_TT_1_Data.TT-1-parent-level   = fs_mstr.fs_parent_level
                XML_TT_1_Data.TT-1-p-child-node-level    = fs_mstr.fs_child_level
                
                XML_TT_1_Data.TT-1-Table-Name     = TRIM(ip-Table-Name) 
                XML_TT_1_Data.TT-1-Field-Name     = TRIM(atn_det.atn_name)
                XML_TT_1_Data.TT-1-Field-Value    = TRIM(atn_det.atn_value). 
 
        /* Flag the End of each tests with the incremented counter. */
        IF  SUBSTRING(atn_det.atn_name, 1, 3) = "xsi" THEN DO:  
                             
                CREATE  XML_TT_1_Data. 
                   
                ASSIGN  Temp-1-Seq-Nbr      = (Temp-1-Seq-Nbr + 1).  
                              
                ASSIGN  XML_TT_1_Data.TT-1-Seq-Nbr        = Temp-1-Seq-Nbr
                        XML_TT_1_Data.TT-1-File-ID        = fs_mstr.fs_file_id
                        XML_TT_1_Data.TT-1-parent-level   = fs_mstr.fs_parent_level
                        XML_TT_1_Data.TT-1-p-child-node-level    = fs_mstr.fs_child_level
                        
                        XML_TT_1_Data.TT-1-Table-Name     = TRIM(ip-Table-Name) 
                        XML_TT_1_Data.TT-1-Field-Name     = TRIM(atn_det.atn_name)
                        XML_TT_1_Data.TT-1-Field-Value    = "END TEST-" + STRING(c-tests-processed) + ".". 
                        
        END. /* IF  SUBSTRING(atn_det.atn_name, 1, 3) = "xsi" */ 
             
    END. /* IF  TRIM(atn_det.atn_value) <> "" */
           
/* Write/Dump out the input select XML data. */ 

    IF  TRIM(atn_det.atn_value) <> "" THEN DO: 
        
        IF  ITdisplay = YES THEN
         
            PUT STREAM TT1dump 
                XML_TT_1_Data.TT-1-Seq-Nbr      
                XML_TT_1_Data.TT-1-File-ID  
                XML_TT_1_Data.TT-1-parent-level  
                XML_TT_1_Data.TT-1-p-child-node-level  
                "  "
                XML_TT_1_Data.TT-1-Table-Name FORMAT "x(15)"   
                XML_TT_1_Data.TT-1-Field-Name FORMAT "x(20)"
                " "
                XML_TT_1_Data.TT-1-Field-Value FORMAT "x(25)" SKIP.
                
    END. /* IF  TRIM(atn_det.atn_value) <> "" */  
          
END.  /** FirstLoopie: FOR EACH fs_mstr    WHERE  fs_mstr.fs_deleted = ? , etc. **/

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of FirstLoopie: paragraph." SKIP.

IF  ITdisplay = YES THEN DO: 
    PUT STREAM TT1dump 
        "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1).
    OUTPUT STREAM TT1dump CLOSE.
END. /* IF  ITdisplay = YES */

      
/* ********************************************** */
/* ********************************************** */
/* Start parseing the selected HL7 data.          */
/* ********************************************** */
/* ********************************************** */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "SecondLoopie: paragraph." SKIP.
    
ASSIGN by-pass-SNP-data = NO. 

SecondLoopie:
   
FOR EACH XML_TT_1_Data      EXCLUSIVE-LOCK      BREAK BY TT-1-Seq-Nbr :  

    IF  SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-" THEN DO: 
        
            NEXT SecondLoopie.
            
    END. /* SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-"  */
               
    IF  TRIM(XML_TT_1_Data.TT-1-Table-Name)   =   "test_mstr"   THEN DO:
/* Validate the lab_id. */

        ASSIGN  
                i-flab-ID       = XML_TT_1_Data.TT-1-Field-Value  
                h-TK_ID         = ""
                h-Lab_Sample_ID = "".

        RUN VALUE(SEARCH("SUBlabid-findR.r")) 
                                   (i-flab-ID,
                                    OUTPUT o-flab-name,
                                    OUTPUT o-flab-error)
                  NO-ERROR.

        IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
              DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error1 - RUN VALUE(SEARCH(." SKIP.      
                  DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                      DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                  END.  /*  DO ix = 1 TO ERROR-STATUS:  */  
        END.  /*  IF ERROR-STATUS:ERROR  */

        IF  o-flab-error = YES THEN DO:  

            ASSIGN msg-attach-file-name = "".

            IF h-TK_ID = "" THEN DO:
                
                FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "TK_ID" EXCLUSIVE-LOCK NO-ERROR.
                
                IF  NOT AVAILABLE (h-XML_TT-buf) THEN
                    ASSIGN h-TK_ID = "?".
                ELSE
                    ASSIGN h-TK_ID = h-XML_TT-buf.TT-1-Field-Value.
                    
            END. /* IF h-TK_ID = "" */

            IF h-Lab_Sample_ID = "" THEN DO:
                
                FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "tk_lab_sample_ID" EXCLUSIVE-LOCK NO-ERROR.
                
                IF NOT AVAILABLE (h-XML_TT-buf) THEN
                    ASSIGN h-Lab_Sample_ID = "?".
                ELSE
                    ASSIGN h-Lab_Sample_ID = h-XML_TT-buf.TT-1-Field-Value.
                    
            END. /* IF h-Lab_Sample_ID = "" */
            
            ASSIGN  h-TK_test_seq        = "1"
                    h-Lab_Samp_seq       = "1".
            
            ASSIGN e_subject =  "Invalid XML Input Lab-ID: " + "'" + i-flab-ID + "'" + ".  Output from: ".
            ASSIGN e_message =  "-m Error encountered with input data from "
                                + " \n "
                                + THIS-PROCEDURE:FILE-NAME
                                + " \n "
                                + " Input data is NOT in the Lab_mstr: " + "'" + i-flab-ID + "'" + "."
                                + " \n "
                                + " Test Kit ID = " + h-TK_ID + " / " + h-TK_test_seq
                                + " \n "
                                + " Lab Sample ID = " + h-Lab_Sample_ID + " / " + h-Lab_Samp_seq
                                + " \n "
                                + "End of message.".
  
            RUN VALUE(SEARCH("Send-EMAIL-Message.r"))
                    (From-Calling-Pgm,
                     e_to-whom,
                     e_subject,
                     e_message,
                     msg-attach-file-name)
                NO-ERROR.

            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
               DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error2 - RUN VALUE(SEARCH(." SKIP.      
                  DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                      DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                  END.  /*  DO ix = 1 TO ERROR-STATUS:  */
            END.  /*  IF ERROR-STATUS:ERROR  */

            ASSIGN  h-TK_ID = ""
                    h-Lab_Sample_ID = "".

            FIND NEXT h-XML_TT-buf WHERE
                            SUBSTRING(h-XML_TT-buf.TT-1-Field-Value, 1, 9) = "END TEST-"  EXCLUSIVE-LOCK NO-ERROR.

            ASSIGN  i-flab-ID       = "".
        
        END.  /* IF  o-flab-error = YES */

/* increment the TT files Seq-Nbr FOR every input test_mstr data line. */
 
        ASSIGN  Temp-People-Seq-Nbr     = (Temp-People-Seq-Nbr  + 1)
                Temp-Address-Seq-Nbr    = (Temp-Address-Seq-Nbr + 1)
                Temp-TK-mstr-Seq-Nbr    = (Temp-TK-mstr-Seq-Nbr + 1)
                Temp-TKR_det-Seq-Nbr    = (Temp-TKR_det-Seq-Nbr + 1)
                Temp-SNP-Seq-Nbr        = (Temp-SNP-Seq-Nbr     + 1).
                
        ASSIGN  by-pass-UTEE-Dupe-Data  = NO
                First-Date              = 0
                Second-Date             = 0.  
        
        NEXT SecondLoopie.
                                  
    END.  /* IF  TRIM(XML_TT_1_Data.TT-1-Table-Name = "test_mstr" */
     
    IF  XML_TT_1_Data.TT-1-Table-Name  =   "people_mstr"    OR 
        XML_TT_1_Data.TT-1-Table-Name  =   "patient_mstr"   THEN DO:  
          
/* Create a new XML_TT_People_Data table record if it does not exist. */         
        FIND XML_TT_People_Data WHERE XML_TT_People_Data.TT-People-Seq-Nbr  = Temp-People-Seq-Nbr 
                    EXCLUSIVE-LOCK NO-ERROR.
                    
        IF  NOT AVAILABLE (XML_TT_People_Data) THEN DO: 
            
            CREATE XML_TT_People_Data.

            ASSIGN XML_TT_People_Data.TT-People-Seq-Nbr         = Temp-People-Seq-Nbr
                   XML_TT_People_Data.TT-people_fs_atn_file_ID  = XML_TT_1_Data.TT-1-File-ID
                   XML_TT_People_Data.TT-people_fs_parent-level = XML_TT_1_Data.TT-1-parent-level 
                   XML_TT_People_Data.TT-people_atn_node_level  = XML_TT_1_Data.TT-1-p-child-node-level.     
        END.  /*  IF NOT AVAILABLE (XML_TT_People_Data)   */

/* Get any patient_mstr data.  If found then this PEOPLE record needs its PATIENT record data processing logic
    in XML-SUB-People-Load program. */    
    
        IF  XML_TT_1_Data.TT-1-Table-Name   = "patient_mstr"  AND 
            XML_TT_1_Data.TT-1-Field-Name   = "patient_notes" THEN DO:
                
                ASSIGN XML_TT_People_Data.TT-people-pat_mstr_notes       = XML_TT_1_Data.TT-1-Field-Value.
                        
                NEXT SecondLoopie.
                
        END.  /* XML_TT_1_Data.TT-1-Field-Name   = "patient_notes" */
                                     
/* Get the input people data and create the XML Extraction People Data to LOAD into Progress..*/ 
        
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_firstname" THEN DO: 
            
                ASSIGN  XML_TT_People_Data.TT-people_firstname  = XML_TT_1_Data.TT-1-Field-Value. 
                              
                NEXT SecondLoopie.
                
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_firstname" */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_lastname" THEN DO:
            
                ASSIGN XML_TT_People_Data.TT-people_lastname    = XML_TT_1_Data.TT-1-Field-Value. 
                                        
                NEXT SecondLoopie.
                
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_lastname" */
        
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_midname" THEN DO:
            
                ASSIGN XML_TT_People_Data.TT-people_midname     = XML_TT_1_Data.TT-1-Field-Value.
                
                NEXT SecondLoopie.
                
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_midname" */
     
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_prefix" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_prefix       = XML_TT_1_Data.TT-1-Field-Value.
            
            IF  (XML_TT_1_Data.TT-1-Field-Value = "Ms." OR XML_TT_1_Data.TT-1-Field-Value = "Ms" OR  
                 XML_TT_1_Data.TT-1-Field-Value = "Mrs." OR XML_TT_1_Data.TT-1-Field-Value = "Mrs" OR
                 XML_TT_1_Data.TT-1-Field-Value = "Miss")  THEN
                 
                    ASSIGN XML_TT_People_Data.TT-people_gender = "Female".
 
            IF  (XML_TT_1_Data.TT-1-Field-Value = "Mr.")   THEN 
            
                    ASSIGN XML_TT_People_Data.TT-people_gender = "Male".  
                    
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_prefix" */
             
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_suffix" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_suffix       = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_suffix" */
        
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_prefname" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_prefname    = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_perfname" */
                                 
        IF  XML_TT_1_Data.TT-1-Field-Name   = "year" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_year = TRIM(XML_TT_1_Data.TT-1-Field-Value).
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "year" */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "month" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_month = TRIM(XML_TT_1_Data.TT-1-Field-Value).
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "month" */
                
        IF  XML_TT_1_Data.TT-1-Field-Name   = "day" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_day = TRIM(XML_TT_1_Data.TT-1-Field-Value).
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "day" */
        
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_gender" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_gender = ?.
            
            IF  XML_TT_1_Data.TT-1-Field-Value = "F" THEN 
            
                ASSIGN XML_TT_People_Data.TT-people_gender = "Female".
                
            IF  XML_TT_1_Data.TT-1-Field-Value = "M" THEN 
            
                ASSIGN XML_TT_People_Data.TT-people_gender = "Male".   
                 
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_gender" */
              
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_homephone" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_homephone   = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_homephone" */
        
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_workphone" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_workphone   = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "people_workphone" */
          
        IF  XML_TT_1_Data.TT-1-Field-Name   = "people_SSN" THEN DO:
            
            ASSIGN XML_TT_People_Data.TT-people_SSN         =
                            SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 3) + "-" +
                            SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 4, 2) + "-" +
                            SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 6, 4).
                            
            NEXT SecondLoopie.
            
        END.  /* XML_TT_1_Data.TT-1-Field-Name   = "people_SSN" */       
        
        IF  SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-" THEN DO: 
            
            NEXT SecondLoopie.
            
        END.  /* SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-" */
        
/* New input XML field name - notify MySolsource Admin to update program. */

{XML-DB-Std-ERROR-Code-2.i}.                                                                             

        NEXT SecondLoopie.
                        
    END.  /*  IF  XML_TT_1_Data.TT-1-Table-Name = "people_mstr" */


    IF XML_TT_1_Data.TT-1-Table-Name  =   "addr_mstr" THEN DO: 
                                
/* Get the input address data and create the XML Extraction Address Data to LOAD into Progress..*/

        FIND XML_TT_Address_Data WHERE XML_TT_Address_Data.TT-address-Seq-Nbr  = Temp-Address-Seq-Nbr 
                    EXCLUSIVE-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE (XML_TT_Address_Data) THEN DO: 
                                 
            CREATE XML_TT_Address_Data.
            
            ASSIGN  XML_TT_Address_Data.TT-address-Seq-Nbr         = Temp-Address-Seq-Nbr
                    XML_TT_Address_Data.TT-address_fs_atn_file_ID  = XML_TT_1_Data.TT-1-File-ID
                    XML_TT_Address_Data.TT-address_fs_parent-level = XML_TT_1_Data.TT-1-parent-level
                    XML_TT_Address_Data.TT-address_atn_node_level  = XML_TT_1_Data.TT-1-p-child-node-level. 
                    
        END.  /* IF  NOT AVAILABLE (XML_TT_Address_Data) */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "addr_addr1" THEN DO:
            
            ASSIGN XML_TT_Address_Data.TT-addr_addr1              = XML_TT_1_Data.TT-1-Field-Value. 
            
            NEXT SecondLoopie. 
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "addr_addr1" */
   
        IF  XML_TT_1_Data.TT-1-Field-Name   = "addr_addr2" THEN DO:
            
            ASSIGN XML_TT_Address_Data.TT-addr_addr2              = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "addr_addr2" */
           
        IF  XML_TT_1_Data.TT-1-Field-Name   = "addr_addr3" THEN DO:
            
            ASSIGN XML_TT_Address_Data.TT-addr_addr3              = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "addr_addr3" */
 
        IF  XML_TT_1_Data.TT-1-Field-Name   = "addr_city" THEN DO:
            
            ASSIGN XML_TT_Address_Data.TT-addr_city               = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "addr_city" */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "state_iso" THEN DO:
            
            ASSIGN XML_TT_Address_Data.TT-state_iso               = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "state_iso" */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "addr_zip " THEN DO:
            
            ASSIGN XML_TT_Address_Data.TT-addr_zip                = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "addr_zip " */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "country_iso" THEN DO:
            
            ASSIGN XML_TT_Address_Data.TT-country_iso             = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "country_iso" */

        IF  SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-" THEN DO: 
            
            NEXT SecondLoopie.
            
        END.  /* SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-" */
                
/* New input XML field name - notify MySolsource Admin to update program. */

{XML-DB-Std-ERROR-Code-2.i}.  
     
        NEXT SecondLoopie.
                                           
    END.  /*  IF XML_TT_1_Data.TT-1-Table-Name  =   "addr_mstr"  */
    

    IF TRIM(XML_TT_1_Data.TT-1-Table-Name)  =   "tk_mstr"   OR 
       TRIM(XML_TT_1_Data.TT-1-Table-Name)  =   "trh_hist"  THEN DO:  
                                 
/* Get the input TK Master data and create the XML Extraction TK-mstr Data to LOAD into Progress..*/ 

        FIND XML_TT_TK_Mstr_Data WHERE XML_TT_TK_Mstr_Data.TT-TK_Mstr-Seq-Nbr  = Temp-TK-mstr-Seq-Nbr  
                    EXCLUSIVE-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE (XML_TT_TK_Mstr_Data) THEN DO: 
                                 
            CREATE XML_TT_TK_Mstr_Data.
            
            ASSIGN  h-TK_ID_Seq-Nbr         = 1
                    h-Lab_Sample_ID_Seq-Nbr = 1.
                    
            ASSIGN  XML_TT_TK_Mstr_Data.TT-TK_Mstr-Seq-Nbr               = Temp-TK-mstr-Seq-Nbr
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_fs_atn_file_ID        = XML_TT_1_Data.TT-1-File-ID
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_fs_parent-level       = XML_TT_1_Data.TT-1-parent-level
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_atn_node_level        = XML_TT_1_Data.TT-1-p-child-node-level
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq             = h-TK_ID_Seq-Nbr
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID_Seq  = h-Lab_Sample_ID_Seq-Nbr. 
                    
        END.  /* IF  NOT AVAILABLE (XML_TT_TK_Mstr_Data) */
  
        IF  TRIM(XML_TT_1_Data.TT-1-Field-Name)   = "TK_ID" THEN DO: 
                                       
/* increment both the TK_ID seq nbr and the TK_Lab_Sample_ID seq nbr by 1 only if it is an UTEE tests. */  
          
            IF  SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 4) = "UTEE"  AND 
                XML_TT_TK_Mstr_Data.TT-TK_Mstr_fs_parent-level  > 99      THEN   
                
                    ASSIGN  XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq            = (XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq + 1)
                            XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID_Seq = (XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID_Seq + 1)
                            by-pass-UTEE-Dupe-Data                              = YES.
                            
            ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID     = XML_TT_1_Data.TT-1-Field-Value
                   h-TK_ID                                  = XML_TT_1_Data.TT-1-Field-Value
                   h-TK_ID_Seq-Nbr                          = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq.
                   
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name   = "TK_ID" */
       
        IF  XML_TT_1_Data.TT-1-Field-Name   = "tk_lab_sample_ID" THEN DO:
            
            ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID      = XML_TT_1_Data.TT-1-Field-Value
                   h-Lab_Sample_ID                                      = XML_TT_1_Data.TT-1-Field-Value
                   h-Lab_Sample_ID_Seq-Nbr                              = XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID_Seq.
                   
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "tk_lab_sample_ID" */
    
        IF  XML_TT_1_Data.TT-1-Field-Name   = "tk_test_desc" THEN DO:
            
            ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_test_desc  = XML_TT_1_Data.TT-1-Field-Value.
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "tk_test_desc" */
                
 /* get the 2 sets of the year, month, day and store in the coll-begin and coll-end date fields. */
                
        IF  XML_TT_1_Data.TT-1-Field-Name   = "coll_begin" THEN DO:
            
            FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "coll_begin" NO-LOCK NO-ERROR.    /* Position temp Buffer. */
                       
            FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "year" NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE (h-XML_TT-buf) THEN
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_year = "?".
            ELSE
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_year = TRIM(h-XML_TT-buf.TT-1-Field-Value). 
           
            FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "month" NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE (h-XML_TT-buf) THEN
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_month = "?".
            ELSE
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_month = TRIM(h-XML_TT-buf.TT-1-Field-Value).
            
            FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "day" NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE (h-XML_TT-buf) THEN
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_day = "?".
            ELSE
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_day = TRIM(h-XML_TT-buf.TT-1-Field-Value).
            
            NEXT SecondLoopie.
                                  
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "coll_begin" */
        
        IF  XML_TT_1_Data.TT-1-Field-Name   = "coll_end" THEN DO:
        
            FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "coll_end" NO-LOCK NO-ERROR.    /* Position temp Buffer. */
                       
            FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "year" NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE (h-XML_TT-buf) THEN
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_year = "?".
            ELSE
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_year = TRIM(h-XML_TT-buf.TT-1-Field-Value). 
           
            FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "month" NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE (h-XML_TT-buf) THEN
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_month = "?".
            ELSE
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_month = TRIM(h-XML_TT-buf.TT-1-Field-Value).
            
            FIND NEXT h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-Field-Name = "day" NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE (h-XML_TT-buf) THEN
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_day = "?".
            ELSE
                ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_day = TRIM(h-XML_TT-buf.TT-1-Field-Value).     
            
            NEXT SecondLoopie.
                                    
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "coll_end" */

/* get the BIOMED collection begin date. */

        IF First-Date <= 3 THEN DO: 
                        
            IF  XML_TT_1_Data.TT-1-Field-Name   = "year" THEN DO:
                
                    ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_year  = XML_TT_1_Data.TT-1-Field-Value.
                    
                    ASSIGN First-Date = (First-Date + 1).
                    
                    NEXT SecondLoopie.
                    
            END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "year" */   
      
            IF  XML_TT_1_Data.TT-1-Field-Name   = "month" THEN DO:
                
                    ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_month  = XML_TT_1_Data.TT-1-Field-Value.
                    
                    ASSIGN First-Date = (First-Date + 1).
                    
                    NEXT SecondLoopie.
                    
            END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "month" */   
      
            IF  XML_TT_1_Data.TT-1-Field-Name   = "day" THEN DO:
                
                    ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_day  = XML_TT_1_Data.TT-1-Field-Value.
                    
                    ASSIGN First-Date = (First-Date + 1).
                    
                    NEXT SecondLoopie.
                    
            END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "day" */   

        END. /* IF First-Date <= 3 THEN DO: */
 
        
/* get the BIOMED collection end date. */ 

        IF Second-Date <= 3 THEN DO:             
            IF  XML_TT_1_Data.TT-1-Field-Name   = "year" THEN DO:
                
                    ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_year  = XML_TT_1_Data.TT-1-Field-Value.
                    
                    ASSIGN Second-Date = (Second-Date + 1).
                    
                    NEXT SecondLoopie.
                    
            END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "year" */   
      
            IF  XML_TT_1_Data.TT-1-Field-Name   = "month" THEN DO:
                
                    ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_month  = XML_TT_1_Data.TT-1-Field-Value.
                    
                    ASSIGN Second-Date = (Second-Date + 1).
                    
                    NEXT SecondLoopie.
                    
            END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "month" */   
      
            IF  XML_TT_1_Data.TT-1-Field-Name   = "day" THEN DO:
                
                    ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_day  = XML_TT_1_Data.TT-1-Field-Value.
                    
                    ASSIGN Second-Date = (Second-Date + 1).
                    
                    NEXT SecondLoopie.
                    
            END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "day" */           

        END.  /* IF Second-Date <= 3 THEN DO: */
                           
        IF  XML_TT_1_Data.TT-1-Field-Name   = "volume" THEN DO:
            
            ASSIGN XML_TT_TK_Mstr_Data.TT-TK_Mstr_volume         = INTEGER(XML_TT_1_Data.TT-1-Field-Value).
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "volume" */

/* Begin of the Bypass of the 1st set of SNP_ID tests results because I didn't know what to do
    with the data!. */
 
        IF  TRIM(XML_TT_1_Data.TT-1-Table-Name) = "tkr_det" AND
            hold-set_id-Name                    = ""        THEN DO:
                ASSIGN by-pass-SNP-data     = NO.
                ASSIGN hold-set_id-Name = "set_id".
                NEXT SecondLoopie.
        END. /* IF  TRIM(XML_TT_1_Data.TT-1-Table-Name) = "tkr_det" OR */
        
        IF  TRIM(XML_TT_1_Data.TT-1-Field-Name) = "SNP_ID" THEN ASSIGN by-pass-SNP-data = YES.

        IF  by-pass-SNP-data = YES THEN NEXT SecondLoopie. 
        
/* End of the Bypass of the 1st set of MPA rs tests results because I didn't know what to do
    with the data!. */

        IF  SUBSTRING(XML_TT_1_Data.TT-1-Field-Name, 1, 3)  = "xsi"         OR 
            SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-"   THEN DO: 
                NEXT SecondLoopie.
        END.  /* SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-" */
                 
/* New input XML field name - notify MySolsource Admin to update program. */

{XML-DB-Std-ERROR-Code-2.i}.   

        NEXT SecondLoopie.
                                            
    END.  /* IF XML_TT_1_Data.TT-1-Table-Name = "tk_mstr"  or  "trh_hist"   */
     
    IF XML_TT_1_Data.TT-1-Table-Name  =   "tkr_det" THEN DO: 
                                
/* Get the input TK detail data and create the XML Extraction tkr_det and brother-rcds Data to LOAD into Progress..*/         

        IF  SUBSTRING(XML_TT_1_Data.TT-1-Field-Name, 1, 3)  = "xsi"         OR 
            SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-"   THEN DO: 
                NEXT SecondLoopie.
        END.  /* SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-" */
                              
        IF  by-pass-UTEE-Dupe-Data = YES THEN 
              IF  TRIM(XML_TT_1_Data.TT-1-Field-Name) = "set_id"   THEN 
                  ASSIGN by-pass-UTEE-Dupe-Data = NO.
              ELSE 
                  NEXT SecondLoopie.
                                    
        IF  TRIM(XML_TT_1_Data.TT-1-Field-Name) = "item-check"  THEN 
                NEXT SecondLoopie.
                    
/* Bypass the   _call   data in the tkr_item input field. */
        IF  TRIM(XML_TT_1_Data.TT-1-Field-Name) = "tkr_item" THEN DO:
            
            ASSIGN len = 0.
    
            ASSIGN len = (INDEX(XML_TT_1_Data.TT-1-Field-Value, "_call", 1 ) ).
    
            IF  len = 0 THEN
                ASSIGN  Temp-TKR_det-Seq-Nbr   = (Temp-TKR_det-Seq-Nbr + 1).
                
            IF  len > 0 THEN
                NEXT SecondLoopie.
    
        END. /* IF  atn_det.atn_name = "tkr_item"  */
                      
        IF  XML_TT_1_Data.TT-1-Field-Name   = "set_id" OR
            hold-set_id-Name                = "set_id" THEN DO:
                ASSIGN hold-set_id-Name  = "".
                NEXT SecondLoopie.
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name   = "set_id" */
                  
        FIND  XML_TT_tkr_det_Data WHERE  
                                XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID   = XML_TT_1_Data.TT-1-File-ID   AND 
                                XML_TT_tkr_det_Data.TT-tkr_det-Seq-Nbr          = Temp-TKR_det-Seq-Nbr  
                    NO-LOCK NO-ERROR.
         
        IF  NOT AVAILABLE (XML_TT_tkr_det_Data) THEN DO:
            
            CREATE XML_TT_tkr_det_Data.
            
            ASSIGN  Temp-TKR_det-Seq-Nbr   = (Temp-TKR_det-Seq-Nbr + 1).
            
            ASSIGN  XML_TT_tkr_det_Data.TT-tkr_det-Seq-Nbr         = Temp-TKR_det-Seq-Nbr             
                    XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID  = XML_TT_1_Data.TT-1-File-ID
                    XML_TT_tkr_det_Data.TT-tkr_det_fs_parent-level = XML_TT_1_Data.TT-1-parent-level
                    XML_TT_tkr_det_Data.TT-tkr_det_atn_node_level  = XML_TT_1_Data.TT-1-p-child-node-level
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID          = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID      /* use TK-Id for detail records. */            
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq      = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq. /* use TK-Id-seq for detail records. */ 
                 
        END.  /* IF  NOT AVAILABLE (XML_TT_TK_Mstr_Data) */
                                 
        IF  XML_TT_1_Data.TT-1-Field-Name   = "tkr_result" THEN DO:
            
            ASSIGN XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result  =  TRIM(XML_TT_1_Data.TT-1-Field-Value). 
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "tkr_result" */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "tkr_ref_uom" THEN DO:
            
            ASSIGN XML_TT_tkr_det_Data.TT-tkr_det_TKR_ref_uom  =  TRIM(XML_TT_1_Data.TT-1-Field-Value). 
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "tkr_ref_uom" */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "tkr_lab_ref" THEN DO:
            
            ASSIGN XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref  =  TRIM(XML_TT_1_Data.TT-1-Field-Value). 
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "tkr_lab_ref" */
        
        IF  XML_TT_1_Data.TT-1-Field-Name   = "tkr_lab_results" THEN DO:
            
            ASSIGN XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result  =  TRIM(XML_TT_1_Data.TT-1-Field-Value). 
            
            NEXT SecondLoopie.
            
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "tkr_lab_results" */

        IF  XML_TT_1_Data.TT-1-Field-Name   = "tkr_item" THEN DO:
            
            ASSIGN XML_TT_tkr_det_Data.TT-tkr_det_TKR_item  =  TRIM(XML_TT_1_Data.TT-1-Field-Value). 
            
            NEXT SecondLoopie.
             
        END.  /* IF  XML_TT_1_Data.TT-1-Field-Name = "tkr_item" */

        IF  SUBSTRING(XML_TT_1_Data.TT-1-Field-Name, 1, 3)  = "xsi"         OR 
            SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-"   THEN DO: 
                NEXT SecondLoopie.
        END.  /* SUBSTRING(XML_TT_1_Data.TT-1-Field-Value, 1, 9) = "END TEST-" */   
                                      
/* New input XML field name - notify MySolsource Admin to update program. */

{XML-DB-Std-ERROR-Code-2.i}.   
    
        NEXT SecondLoopie.
                                            
    END.  /* IF XML_TT_1_Data.TT-1-Table-Name = "tkr_det" */    


    IF XML_TT_1_Data.TT-1-Table-Name  =   "SNP_ID" THEN DO: 
                          
/* Don't know what to do with the SNP data.  
Do we try to validate it, where do we store it ?
See the following input examples:
                                     table-name     field-name     value
   859    16,730       626       627 SNP_ID         SNP_ID         rs819171       
   860    16,730       628       629 SNP_ID         SNP_gene       AHCY           
   861    16,730       630       631 SNP_ID         SNP_variation  19             
   862    16,730       619       632 SNP_ID         coll_begin     coll_begin     
   863    16,730       633       634 SNP_ID         year           2013           
   864    16,730       635       636 SNP_ID         month          02             
   865    16,730       637       638 SNP_ID         day            09             
*/
        NEXT SecondLoopie.
                                           
    END.  /* IF XML_TT_1_Data.TT-1-Table-Name = "SNP_ID" */

    FIND NEXT h-XML_TT-buf WHERE 
                SUBSTRING(h-XML_TT-buf.TT-1-Field-Value, 1, 9) = "END TEST-"  EXCLUSIVE-LOCK NO-ERROR. 
 
END.  /* SecondLoopie: FOR EACH XML_TT_1_Data */   

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of SecondLoopie: paragraph." SKIP.

IF  ITDisplay = YES THEN DO:
/* Dump/list out the selected HL7 data files that are used in the following sub-programs for processing. */

        FOR EACH XML_TT_People_Data         NO-LOCK BREAK BY  TT-People-Seq-Nbr:
            IF  TT-People-Seq-Nbr = 1 THEN 
                PUT STREAM DBUTrace1 
                    "Input to Prog: XML-SUB-People-Load - XML_TT_People_Data:" SKIP.
            PUT STREAM DBUTrace1 
                TT-People-Seq-Nbr           FORMAT ">>>>>9" " " 
                TT-people_fs_atn_file_ID    FORMAT ">>>>>9" " "   
                TT-people_fs_parent-level   FORMAT ">>>9"   " "  
                TT-people_atn_node_level    FORMAT ">>>9"   "  "
                TT-people_firstname         FORMAT "x(15)"  " "
                TT-people_midname           FORMAT "x(8)"   " "
                TT-people_lastname          FORMAT "x(15)"  " "
                TT-people_prefix            FORMAT "x(4)"   " "
                TT-people_suffix            FORMAT "x(4)"   " " 
                TT-people_month             FORMAT "x(2)"   "/"
                TT-people_day               FORMAT "x(2)"   "/"
                TT-people_year              FORMAT "x(4)"   "  "
                TT-people_gender                            SKIP 
                "                              "
                TT-people_homephone         FORMAT "x(14)"  " "
                TT-people_workphone         FORMAT "x(14)"  " "
                TT-people_prefname          FORMAT "x(10)"  " "
                TT-people_SSN               FORMAT "x(12)"  SKIP 
                "                              "
                TT-people-pat_mstr_notes    FORMAT "x(60)"  SKIP(1) 
                .     
    	END. /*  FOR EACH XML_TT_People_Data  */

        PUT STREAM DBUTrace1 
            "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1).
        OUTPUT STREAM DBUTrace1 CLOSE. 

         
        FOR EACH XML_TT_Address_Data         NO-LOCK BREAK BY  TT-Address-Seq-Nbr:
            IF  TT-Address-Seq-Nbr = 1 THEN 
                PUT STREAM DBUTrace2 
                    "Input to Prog: XML-SUB-Address-Load: XML_TT_Address_Data:" SKIP.
            PUT STREAM DBUTrace2
                TT-Address-Seq-Nbr          FORMAT ">>>>>9" " "  
                TT-Address_fs_atn_file_ID   FORMAT ">>>>>9" " "   
                TT-Address_fs_parent-level  FORMAT ">>>9"   " "  
                TT-Address_atn_node_level   FORMAT ">>>9"   SKIP    "           "
                TT-addr_addr1               FORMAT "x(30)"  " "
                TT-addr_addr2               FORMAT "x(30)"  SKIP    "           " 
                TT-addr_city                FORMAT "x(30)"  " " 
                TT-state_iso                FORMAT "x(20)"  "  "
                TT-addr_zip                 FORMAT "x(20)"  "  "
                TT-country_iso              FORMAT "x(40)"  SKIP(1). 
               
        END. /*  FOR EACH XML_TT_Address_Data  */

        PUT STREAM DBUTrace2 
            "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1).
        OUTPUT STREAM DBUTrace2 CLOSE. 

    
        FOR EACH XML_TT_TK_Mstr_Data         NO-LOCK BREAK BY  TT-TK_Mstr-Seq-Nbr:
            IF  TT-TK_Mstr-Seq-Nbr = 1 THEN 
                PUT STREAM DBUTrace3 
                    "Input to Prog: XML-SUB-TK-Mstr-Load: XML_TT_TK_Mstr_Data:" SKIP.
            PUT STREAM DBUTrace3 
                TT-TK_Mstr-Seq-Nbr              FORMAT ">>>>>9" " " 
                TT-TK_Mstr_fs_atn_file_ID       FORMAT ">>>>>9" " "  
                TT-TK_Mstr_fs_parent-level      FORMAT ">>>9"   " "
                TT-TK_Mstr_atn_node_level       FORMAT ">>>9"   "  "
                TT-TK_Mstr_people_id            FORMAT ">>>>>>>" "  "
                TT-TK_Mstr_TK_ID                FORMAT "x(20)"  " "
                TT-TK_Mstr_TK_ID_Seq            FORMAT ">>9"    "  "
                TT-TK_Mstr_TK_test_type         FORMAT "x(10)"  " "
                TT-TK_Mstr_tk_lab_sample_ID     FORMAT "x(20)"  " "
                TT-TK_Mstr_tk_lab_sample_ID_Seq FORMAT ">>9"    " "
                TT-TK_Mstr_tk_test_desc         FORMAT "x(30)"  " " SKIP 
                "                           "
                "Begin-Date: "
                TT-TK_Mstr_coll_begin_month     FORMAT "99"
                "/"
                TT-TK_Mstr_coll_begin_day       FORMAT "99"
                "/"
                TT-TK_Mstr_coll_begin_year      FORMAT "9999"        "  "
                "  End-Date: "
                TT-TK_Mstr_coll_end_month       FORMAT "99"
                "/"
                TT-TK_Mstr_coll_end_day         FORMAT "99"
                "/"
                TT-TK_Mstr_coll_end_year        FORMAT "9999"        "  "

                TT-TK_Mstr_volume                               SKIP(1).   
        END. /*  FOR EACH XML_TT_TK_Mstr_Data  */

        PUT STREAM DBUTrace3 
            "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1). 
        OUTPUT STREAM DBUTrace3 CLOSE. 

    
        FOR EACH XML_TT_tkr_det_Data 	  NO-LOCK BREAK BY TT-tkr_det-Seq-Nbr: 
            IF  TT-tkr_det-Seq-Nbr = 1 THEN 
                PUT STREAM DBUTrace4 
                    "Input tp Prog: XML-SUB-TKR-det-Load: XML_TT_tkr_det_Data:" SKIP.
            PUT STREAM DBUTrace4
                XML_TT_tkr_det_Data.TT-tkr_det-Seq-Nbr          FORMAT ">>>>>9" " "
                XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID   FORMAT ">>>>>9" " "
                TT-tkr_det_fs_parent-level                      FORMAT ">>>9"   " "
                TT-tkr_det_atn_node_level                       FORMAT ">>>9"   "  " 
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID           FORMAT "x(15)"  " "
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq       FORMAT ">>9"    " "
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_item         FORMAT "x(15)"  "  "
                TT-tkr_det_TKR_lab_result                       FORMAT "x(10)"  "  "
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_ref_uom      FORMAT "x(10)"  "  "
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref      FORMAT "x(10)"  SKIP.  
        END. /*  FOR EACH XML_TT_tkr_det_Data  */
 
        PUT STREAM DBUTrace4 
            "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1). 
        OUTPUT STREAM DBUTrace4 CLOSE. 

END. /* IF  ITDisplay = YES THEN DO:  */

 

/* Process the parsed input data into the Progress databases. */  

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "PeopleLoopie: paragraph." SKIP.
    
ASSIGN  h-TK_ID                 = ""
        h-Lab_Sample_ID         = ""
        o-error-message         = "".

/* Process the People Data. */

PeopleLoopie:
    
FOR FIRST    XML_TT_People_Data  WHERE TT-People-Seq-Nbr > 0   BREAK BY Temp-People-Seq-Nbr:
    
    ASSIGN  h-TK_ID                 = ""
            h-Lab_Sample_ID         = "".
                   
    RUN VALUE(SEARCH("HL7-Load-People.r"))
                     (i-flab-ID,                    /* tests done at the Lab-ID. */
                      i-Admin-Update-OverRyde,
                      OUTPUT o-people-id,
                      OUTPUT o-people-load-error,
                      OUTPUT o-error-message)
            NO-ERROR.

    IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
       DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error3 - RUN VALUE(SEARCH(." SKIP.      
          DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
              DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
          END.  /*  DO ix = 1 TO ERROR-STATUS:  */  
    END.  /*  IF ERROR-STATUS:ERROR  */

    IF  o-people-load-error = YES THEN DO: 
        ASSIGN  From-Calling-Pgm    = "HL7-Load-People.r"
                h-File-ID           = XML_TT_1_Data.TT-1-File-ID
                h-TK_ID             = "Unknown"
                h-Lab_Sample_ID     = "Unknown". 

{XML-DB-Std-ERROR-Code-3.i}. 

        FIND NEXT h-XML_TT-buf WHERE 
                SUBSTRING(h-XML_TT-buf.TT-1-Field-Value, 1, 9) = "END TEST-"  EXCLUSIVE-LOCK NO-ERROR. 
                            
        ASSIGN o-people-load-error = NO.

        NEXT PeopleLoopie.
                                    
    END. /* IF  o-people-load-error = YES */

END. /*  PeopleLoopie: FOR FIRST    XML_TT_People_Data  WHERE TT-People-Seq-Nbr > 0  */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of PeopleLoopie: paragraph." SKIP.
    
IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "AddressLoopie: paragraph." SKIP.
    
/* Process the Address Data. */

AddressLoopie:
            
FOR FIRST    XML_TT_Address_Data  WHERE Temp-Address-Seq-Nbr > 0    BREAK BY Temp-Address-Seq-Nbr:

    ASSIGN  h-TK_ID                 = ""
            h-Lab_Sample_ID         = "".
              
    RUN VALUE(SEARCH("HL7-Load-People-Address.r"))
                     (o-people-id,
                      i-Admin-Update-OverRyde,
                      OUTPUT o-addr-id,
                      OUTPUT o-addr-load-error,
                      OUTPUT o-error-message) 
            NO-ERROR.

    IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
       DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error4 - RUN VALUE(SEARCH(." SKIP.      
          DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
              DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
          END.  /* DO ix = 1 TO ERROR-STATUS: */
    END.  /*  IF ERROR-STATUS:ERROR  */
    
    IF  o-addr-load-error = YES THEN DO:  
        
        ASSIGN  From-Calling-Pgm    = "HL7-Load-People-Address.r"
                h-File-ID           = XML_TT_1_Data.TT-1-File-ID
                h-TK_ID             = "Unknown"
                h-Lab_Sample_ID     = "Unknown". 
                
/* Standard E-Mail error message when returning from SUB programs that encountered some type of processing error.  */  
        
{XML-DB-Std-ERROR-Code-3.i}.

        FIND NEXT h-XML_TT-buf WHERE 
                SUBSTRING(h-XML_TT-buf.TT-1-Field-Value, 1, 9) = "END TEST-"  EXCLUSIVE-LOCK NO-ERROR.  
                  
        ASSIGN o-addr-load-error = NO.
        
        NEXT AddressLoopie.
                       
    END. /* IF  o-addr-load-error = YES */
                
END. /*  AddressLoopie: FOR FIRST    XML_TT_Address_Data  */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of AddressLoopie: paragraph." SKIP.
    
IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "TK-MstrLoopie: paragraph." SKIP.
    
/* Process the TK-Mstr Data. */

TK-MstrLoopie:
    
FOR FIRST XML_TT_TK_Mstr_Data  WHERE  Temp-TK-Mstr-Seq-Nbr > 0    BREAK BY Temp-TK-Mstr-Seq-Nbr:    
    
    ASSIGN  h-TK_ID                 = ""
            h-Lab_Sample_ID         = "".
                      
    RUN VALUE(SEARCH("HL7-Load-TK-Mstr.r"))
                     (o-people-id,
                      i-Admin-Update-OverRyde,
                      OUTPUT o-TK-Mstr-id,
                      OUTPUT o-Lab_Sample_ID, 
                      OUTPUT o-TK-Mstr-load-error,
                      OUTPUT o-error-message) 
            NO-ERROR.

    IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
       DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error5 - RUN VALUE(SEARCH(." SKIP.      
          DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
              DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
          END.  /*  DO ix = 1 TO ERROR-STATUS:  */
    END.  /*  IF ERROR-STATUS:ERROR  */
 
    IF  o-TK-Mstr-load-error = YES THEN DO: 

        ASSIGN  From-Calling-Pgm    = "HL7-Load-TK-Mstr.r"
                h-File-ID           = XML_TT_1_Data.TT-1-File-ID     
                h-TK_ID             = o-TK-Mstr-id
                h-Lab_Sample_ID     = o-Lab_Sample_ID. 
                      
/* Standard E-Mail error message when returning from SUB programs that encountered some type of processing error.  */  
    
{XML-DB-Std-ERROR-Code-3.i}.
 
/*  bypass the rest of this input XML data within this ROOT. */ 
       
        FIND NEXT h-XML_TT-buf WHERE 
                        SUBSTRING(h-XML_TT-buf.TT-1-Field-Value, 1, 9) = "END TEST-"  EXCLUSIVE-LOCK NO-ERROR.
                                    
        ASSIGN o-TK-Mstr-load-error = NO.
        
        NEXT TK-MstrLoopie. 
                       
    END. /* IF  o-TK_Mstr-load-error = YES */    

END. /*  TK-MstrLoopie: FOR EACH XML_TT_TK_Mstr_Data  */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of TK-MstrLoopie: paragraph." SKIP.
    
IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "TKR-DetLoopie: paragraph." SKIP.
    
/* Process the TKR_det Data. */

TKR-DetLoopie:
     
FOR FIRST XML_TT_tkr_det_Data  WHERE  Temp-TKR_det-Seq-Nbr > 0   BREAK BY Temp-TKR_det-Seq-Nbr:    
                                 
    RUN VALUE(SEARCH("HL7-Load-TKR-Det.r"))
                     (o-people-id,
                      i-Admin-Update-OverRyde,
                      OUTPUT o-TKR-det-id,
                      OUTPUT o-TKR-det-fs-atn-file-ID,
                      OUTPUT o-TKR-det-load-error,
                      OUTPUT o-error-message)
            NO-ERROR.

    IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
       DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error6 - RUN VALUE(SEARCH(." SKIP.      
          DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
              DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
          END.  /*  DO ix = 1 TO ERROR-STATUS:  */ 
    END.  /*  IF ERROR-STATUS:ERROR  */
 
    IF  o-TKR-det-load-error = YES THEN DO: 

        ASSIGN  From-Calling-Pgm     = "HL7-Load-TKR-det.r"       
                h-File-ID            = o-TKR-det-fs-atn-file-ID
                h-TK_ID              = o-TKR-det-id
                h-Lab_Sample_ID      = o-Lab_Sample_ID. 
                
/* Standard E-Mail error message when returning from SUB programs that encountered some type of processing error.  */  
         
{XML-DB-Std-ERROR-Code-3.i}.
 
/*  bypass the rest of this input XML data within this ROOT. */  
     
        FIND NEXT h-XML_TT-buf WHERE 
                    SUBSTRING(h-XML_TT-buf.TT-1-Field-Value, 1, 9) = "END TEST-"  EXCLUSIVE-LOCK NO-ERROR.
                             
        ASSIGN o-TKR-det-load-error = NO.
        
        NEXT TKR-DetLoopie. 
                       
    END. /* IF  o-TKR_det-load-error = YES */    

END. /*  TKR-DetLoopie: FOR FIRST XML_TT_tkr_det_Data  */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of TKR-DetLoopie: paragraph." SKIP.

/* Change the FS_mstr.fs-processed AND atn_det.atn_processed fields 
    from NEW or CORRECTED to either 
        ERROR or PROCESSSED-(if they processed with out errors). */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "Update-fsatn: paragraph." SKIP.
   
Update-fsatn:

FOR EACH XML_TT_PeopID_Basic_Data  
            EXCLUSIVE-LOCK   
                BREAK BY XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only :
                    
    IF  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag = "" THEN  
    
        ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag = "PROCESSED".
                    
    RUN VALUE (SEARCH("SUBfsatn_processed-ucU.r"))
                    (XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id,
                     XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag,
                     XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Desc, 
                     OUTPUT o-successful)
            NO-ERROR.

    IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
       DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error7 - RUN VALUE(SEARCH(." SKIP.      
          DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
              DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
          END.  /*  DO ix = 1 TO ERROR-STATUS:  */
    END.  /*  IF ERROR-STATUS:ERROR  */
                     
END. /* Update-fsatn: FOR EACH XML_TT_PeopID_Basic_Data */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of Update-fsatn: paragraph." SKIP.
      
    FOR EACH XML_TT_PeopID_Basic_Data   NO-LOCK BREAK BY  TT_PeopID_Seq_Nbr_only:     
        IF   XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only = 1 THEN DO:
            PUT STREAM PeopBasic "In PROG: XML-DB-Updates: XML_TT_PeopID_Basic_Data:" SKIP(1).
            PUT STREAM PeopBasic "Seq #" " " "file_id" " " "plvl" " " "node" "  " "peop-id" "  " "error-flg" "  "
                                 "  TK-ID      "  "   " "seq" "  " "lab-sample-id  " " seq" "  " "lab-id    "
                                 " " "begin-date" "  " "end-date " "  " "discrep-tbl " " " "test-family"
                                 " " "test-type" " " "long error description" SKIP.
        END.  /* IF   XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only = 1 */    
                
        PUT STREAM PeopBasic
              XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only       FORMAT ">>>>9"   " "
              XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id     FORMAT ">>>>>>9" " "
              XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level    FORMAT ">>>9"    " "
              XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level     FORMAT ">>>9"    "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_people_id          FORMAT ">>>>>>9" "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag         FORMAT "x(9)"    "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID              FORMAT "x(15)"   " "
              XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq        FORMAT ">>9"     "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_lab_sample_ID      FORMAT "x(15)"   " "
              XML_TT_PeopID_Basic_Data.TT_PeopID_lab_sample_ID_Seq  FORMAT ">>9"     "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID             FORMAT "x(10)"   " "  
              XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte FORMAT "99/99/9999" "  "
              XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_end_dte FORMAT "99/99/9999" "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table      FORMAT "x(11)"   " "
              XML_TT_PeopID_Basic_Data.TT-test-family               FORMAT "x(11)"   " " 
              XML_TT_PeopID_Basic_Data.TT-test-type                 FORMAT "x(9)"    " "
              XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Desc         FORMAT "x(70)"   " " 
              SKIP.
                    
    END. /* 4 each */   
 
    PUT STREAM PeopBasic
        "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (2).
    OUTPUT STREAM PeopBasic CLOSE.


IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "trh_hist-Loopie: paragraph." SKIP.
   
/* NOTE:    Must CREATE the trh_hist records, 
            set the trh_date to the 1st and/or 2nd dates from 
            the HL7 input data  as the collected date and set the processed 
            date to TODAY and set the received date from the date on the input file. */   

trh_hist-Loopie:   
                  
FOR EACH XML_TT_PeopID_Basic_Data     WHERE TT_PeopID_ERROR_Flag = "PROCESSED"   
            NO-LOCK   
                BREAK BY XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only :
                                          
    ASSIGN  i-mtrh-date = TODAY.
 
/*PUT UNFORMATTED "XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id = " XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id SKIP.*/
  
    FIND  FIRST att_files WHERE   
                        att_file_id         = (XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id  + 1)  AND 
                        INTEGER(att_value1) = XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id         AND
                        att_filepath        = "C:\apps\HL7\Processed\EDI\Successful\"
            NO-LOCK  NO-ERROR.
            
    IF  NOT AVAILABLE (att_files)   THEN 
        ASSIGN  i-ctrh-date     = TODAY 
                h_from_path     = "C:\apps\HL7\Processed\EDI\Error\" + STRING(XML_TT_PeopID_Basic_Data.TT_PeopID_people_id) + "\".
    ELSE   
        ASSIGN  i-ctrh-date     = att_create_date                   
                h_from_path     = att_filepath + att_filename.  

    IF  XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte <> ? THEN
        ASSIGN  i-trh-date      = XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte
                i-ctrh-date     = XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte.
    ELSE 
        IF  XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte = ? THEN 
        ASSIGN  i-trh-date      = (XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_end_dte - 1)
                i-ctrh-date     = (XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_end_dte - 1).   
                  

/* Use the date of the input begin or end for the "COLLECTED" action. */  
/*   
    ASSIGN i-ctrh-action   = "COLLECTED".      
/*DISPLAY "calling 1: SUBtrh-HL7-U.r" SKIP.*/
/*DISPLAY i-ctrh-action ":" h_from_path SKIP.*/
    RUN VALUE (SEARCH("SUBtrh-HL7-U.r"))
                   (XML_TT_PeopID_Basic_Data.TT-test-type,          /* trh_hist.trh_item        */
                    i-ctrh-action,                                  /* trh_hist.trh_action      */
                    1,                                              /* trh_hist.trh_qty         */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID,       /* trh_hist.trh_serial      */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq, /* trh_hist.trh_sequence    */
                    i-ctrh-date,                                    /* trh_hist.trh_create_date */
                    i-mtrh-date,                                    /* trh_hist.trh_modified_date */
                    i-trh-date,                                     /* trh_hist.trh_date        */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_people_id ,  /* trh_hist_trh_people_id   */
                    OUTPUT o-ctrh-id,                               /* trh_hist.trh_id          */
                    OUTPUT o-ctrh-error)                            /* LOGICAL INITIAL YES      */
            NO-ERROR.
*/ 
/* Get the date of the input source file and use it for the "HHI-RCVD" date. */

    IF  AVAILABLE (att_files) THEN 
        ASSIGN  h_from_path = att_filepath + att_filename.
       
/*DISPLAY i-ctrh-action ":" h_from_path SKIP.*/

/* Delete the .txt file from last run.
    this files hold the DIR data for the input HL7 data file so
    we can get the DATE the file was received into the server. */
  
        OS-COMMAND  SILENT    
            VALUE ("DEL " + TT-Logs-Rpts-Path-Folder + "HL7-dirlist.txt").            
        OS-stat = OS-ERROR. 
        IF  OS-stat <> 0 THEN DISPLAY "OS-ERROR DEL = " OS-stat SKIP.
           
        OS-COMMAND  SILENT    
            VALUE ("DIR " + h_from_path  + " >> " + TT-Logs-Rpts-Path-Folder + "HL7-dirlist.txt"). 
            
        OS-stat = OS-ERROR. 
        IF  OS-stat <> 0 THEN DISPLAY "OS-ERROR DIR = " OS-stat SKIP.
        
/* Following TEMP-TABLE: dirlist_data - is used to get the DATE off of the input data file
that you see in the Windows explorer.
The data file date is used for the "HHI-RCVD" history date in the trh_hist record. 
The data file date should be in Field-5, unless someone changes this code!*/  
                   
        INPUT FROM VALUE(SEARCH(TT-Logs-Rpts-Path-Folder + "HL7-dirlist.txt")).
                          
        REPEAT:  
            
            CREATE   dirlist_data. 
                                                                            
            IMPORT DELIMITER ""  dirlist_data.
            
            IF  IP_Field-5 <> att_filename THEN DELETE dirlist_data. 
                             
        END.  /** REPEAT **/   
         
        INPUT CLOSE. 

/* Find the filename in the IP_Field-5 of the temp-table. */
        
        FIND FIRST dirlist_data WHERE IP_Field-5 = att_filename NO-LOCK NO-ERROR.
/*            DISPLAY  "IP_Field-1 = " IP_Field-1 SKIP.*/
/*            DISPLAY  "IP_Field-2 = " IP_Field-2 SKIP.*/
/*            DISPLAY  "IP_Field-3 = " IP_Field-3 SKIP.*/
/*            DISPLAY  "IP_Field-4 = " IP_Field-4 SKIP.*/
/*            DISPLAY  "IP_Field-5 = " IP_Field-5 SKIP.*/

/* IP_Field-1 contains the DATE of the file when loaded on the server. */ 
        
        ASSIGN  i-ctrh-date     = ?
                i-ctrh-action   = "HHI-RCVD".
                           
        IF AVAILABLE (dirlist_data) THEN 
            ASSIGN  i-ctrh-date = DATE(IP_Field-1).

/* Empty the temp-table dirlist_date file to clear out the data from the above import. 
    The EMPTY statement ensures the temp table file does not contains
    the previous file information.  It is used to help the DEL statement above
    cause sometimes during testing, the DEL did not delete the file fast enought. */
                
        EMPTY TEMP-TABLE dirlist_data NO-ERROR.

        RUN VALUE (SEARCH("SUBtrh-HL7-U.r"))
                   (i-Admin-Update-OverRyde,                        /* Admin OverRyde option    */
                    XML_TT_PeopID_Basic_Data.TT-test-type,          /* trh_hist.trh_item        */
                    i-ctrh-action,                                  /* trh_hist.trh_action      */
                    1,                                              /* trh_hist.trh_qty         */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID,       /* trh_hist.trh_serial      */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq, /* trh_hist.trh_sequence    */
                    i-ctrh-date,                                    /* trh_hist.trh_create_date */
                    i-mtrh-date,                                    /* trh_hist.trh_modified_date */
                    i-trh-date,                                     /* trh_hist.trh_date        */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_people_id ,  /* trh_hist_trh_people_id   */
                    OUTPUT o-ctrh-id,                               /* trh_hist.trh_id          */
                    OUTPUT o-ctrh-error)                            /* LOGICAL INITIAL YES      */
            NO-ERROR.

            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
               DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error9 - RUN VALUE(SEARCH(." SKIP.      
                  DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                      DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                  END.
            END.
                                         
/*    END. /* IF  AVAILABLE (att_files) */*/
        
/* Get the date the input source file was loaded into the ATN_det table and use it for the "LOADED" date. */

    ASSIGN i-ctrh-action   = "LOADED".
    
    IF  AVAILABLE (att_files) THEN
        ASSIGN  i-ctrh-date     = att_create_date.

        RUN VALUE (SEARCH("SUBtrh-HL7-U.r"))
                   (i-Admin-Update-OverRyde,                        /* Admin OverRyde option    */
                    XML_TT_PeopID_Basic_Data.TT-test-type,          /* trh_hist.trh_item        */
                    i-ctrh-action,                                  /* trh_hist.trh_action      */
                    1,                                              /* trh_hist.trh_qty         */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID,       /* trh_hist.trh_serial      */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq, /* trh_hist.trh_sequence    */
                    i-ctrh-date,                                    /* trh_hist.trh_create_date */
                    i-mtrh-date,                                    /* trh_hist.trh_modified_date */
                    i-trh-date,                                     /* trh_hist.trh_date        */
                    XML_TT_PeopID_Basic_Data.TT_PeopID_people_id ,  /* trh_hist_trh_people_id   */
                    OUTPUT o-ctrh-id,                               /* trh_hist.trh_id          */
                    OUTPUT o-ctrh-error)                            /* LOGICAL INITIAL YES      */
            NO-ERROR.

            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
               DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error10 - RUN VALUE(SEARCH(." SKIP.      
                  DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                      DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                  END.
            END.
                              
/*    END. /* IF  AVAILABLE (att_files) */*/
        
/* Use the TODAY date for the "PROCESSED" date. */

    ASSIGN  i-ctrh-date     = TODAY 
            i-ctrh-action   = "PROCESSED".                

    RUN VALUE (SEARCH("SUBtrh-HL7-U.r"))
               (i-Admin-Update-OverRyde,                        /* Admin OverRyde option    */
                XML_TT_PeopID_Basic_Data.TT-test-type,          /* trh_hist.trh_item        */
                i-ctrh-action,                                  /* trh_hist.trh_action      */ 
                1,                                              /* trh_hist.trh_qty         */
                XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID,       /* trh_hist.trh_serial      */
                XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq, /* trh_hist.trh_sequence    */
                i-ctrh-date,                                    /* trh_hist.trh_create_date */
                i-mtrh-date,                                    /* trh_hist.trh_modified_date */
                i-trh-date,                                     /* trh_hist.trh_date        */
                XML_TT_PeopID_Basic_Data.TT_PeopID_people_id ,  /* trh_hist_trh_people_id   */
                OUTPUT o-ctrh-id,                               /* trh_hist.trh_id          */
                OUTPUT o-ctrh-error)                            /* LOGICAL INITIAL YES      */    
            NO-ERROR.

            IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
               DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error11 - RUN VALUE(SEARCH(." SKIP.      
                  DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                      DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                  END.
            END.
                               
END. /*  trh_hist-Loopie: FOR EACH XML_TT_PeopID_Basic_Data     WHERE TT_PeopID_ERROR_Flag = "PROCESSED"  */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of trh_hist-Loopie: paragraph." SKIP. 
                
/* ********************************************************************** */              
/*  Update the att_files table for ALL the HL7 data files and info and    */
/*  move the input files to the attached files folder by people-id.       */
/*                                                                        */
/*  Sample att_files records created via HL7 extraction programs follows: */
/*
 ID     Table      Field1                Value1                 Filepath                                Filename                                                                 
16574 "fs_mstr" "fs_file_ID" "" "" "" "" "16574" "" "" "" "" "" "C:\apps\HL7\Processed\XML\Successful\" "B130208-2529-1_EDItest-1466967372153.pdf" "" "" "" ? "sysprogress" 06/26/16 "sysprogress" 06/26/16 "" "" "" ? ? ? no no no 0 0 0 0 0 "DireXMLWalk.p"
16575 "fs_mstr" "fs_file_ID" "" "" "" "" "16574" "" "" "" "" "" "C:\apps\HL7\Processed\EDI\Successful\" "B130208-2529-1_EDItest-1466967372153.txt" "" "" "" ? "sysprogress" 06/26/16 "sysprogress" 06/26/16 "" "" "" ? ? ? no no no 0 0 0 0 0 "DireXMLWalk.p"
16576 "fs_mstr" "fs_file_ID" "" "" "" "" "16574" "" "" "" "" "" "C:\apps\HL7\Processed\PDF\Successful\" "B130208-2529-1_EDItest-1466967372153.pdf" "" "" "" ? "sysprogress" 06/26/16 "sysprogress" 06/26/16 "" "" "" ? ? ? no no no 0 0 0 0 0 "DireXMLWalk.p"
16577 "fs_mstr" "fs_file_ID" "" "" "" "" "16577" "" "" "" "" "" "C:\apps\HL7\Processed\XML\Successful\" "B130209-2091-1_EDItest-1466967388813.pdf" "" "" "" ? "sysprogress" 06/26/16 "sysprogress" 06/26/16 "" "" "" ? ? ? no no no 0 0 0 0 0 "DireXMLWalk.p"
*/
/* ********************************************************************** */  
IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "att_files-Loopie: paragraph." SKIP.

att_files-Loopie:
     
FOR EACH XML_TT_PeopID_Basic_Data   WHERE TT_PeopID_ERROR_Flag = "PROCESSED"
                NO-LOCK BREAK BY TT_PeopID_Seq_Nbr_only : 

/*NEW  FIND ATT-FILES USING the new fs_mstr-id sub-routine here.*/
    ASSIGN ithree = 0.
    FOR EACH att_files WHERE att_table = "fs_mstr" AND att_field1 = "fs_file_ID" AND
                             att_value1 = STRING(XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id) 
                       BY att_file_id :
                           
        ASSIGN ithree = (ithree + 1).                           
                                
        IF  AVAILABLE (att_files) THEN DO: 

/* Get the PATH and it's FILE NAME to MOVE the files FROM and then use the 
    OD-COMMAND's to CREATE the people directory and then MOVE the files TO for the people_id folder. */

            ASSIGN  h_file_name = att_filename
                    h_from_path = att_filepath + h_file_name
                    h_HTML_prefix = "file:\\hhi-dc-4.local\"
                    h_to_path   = "C:\APPS\BioMed\AttachedFiles\" +
                                  STRING(XML_TT_PeopID_Basic_Data.TT_PeopID_people_id) +
                                  "\" + 
                                  h_file_name
                    dir_name    = "C:\APPS\BioMed\AttachedFiles\" + STRING(XML_TT_PeopID_Basic_Data.TT_PeopID_people_id)
                    len         = LENGTH(dir_name)
                    . 

            ASSIGN msg-attach-file-name = "".
 
/*  Now CREATE the attachfiles folder for the people_id here.  */
            
            OS-CREATE-DIR VALUE(dir_name).
            OS-stat = OS-ERROR. 

            IF  OS-stat NE 0 THEN DO:            
                ASSIGN  From-Calling-Pgm        = "XML-DB-Updates.r".
                ASSIGN  e_subject               =  "System DIRECTORY Error Status Nbr: " + STRING(OS-stat) + " in program: ".
                ASSIGN  e_message =  "-m " 
                        + "Paragraph att_files-Loopie: has an processing error trying to "
                        + " \n "
                        + "CREATE the DIRECTORY "
                        + " \n "  
                        + dir_name
                        + " \n " 
                        + "for the input file  : " + h_file_name + "."
                        + " \n "
                        + "CREATE DIRECTORY Error Status Nbr: " + STRING(OS-stat) + "."
                        + " \n "
                        + "Notify MySolsource Admin asap with this E-Mail message."
                        + " \n " 
                        + "This e-mail was sent from program: " + THIS-PROCEDURE:FILE-NAME + "."
                        + " \n "    
                        + "End of message.".
                                                                        
                RUN VALUE(SEARCH("Send-EMAIL-Message.r"))
                        (From-Calling-Pgm,
                         e_to-whom,                                   
                         e_subject,
                         e_message,
                         msg-attach-file-name) 
                        NO-ERROR.
            
                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
                   DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error12 - RUN VALUE(SEARCH(." SKIP.      
                      DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                          DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                      END.  /*  DO ix = 1 TO ERROR-STATUS:  */
                END.  /* IF ERROR-STATUS:ERROR */
                         
            END. /* IF  stat NE 0 */
                                                          
/*  Now move FROM i/p folder TO attachfiles folder here.  */
            IF  h_from_path = "" THEN 
                ASSIGN h_from_path = "Pgm: HL7-Load-Main ".
            IF  h_to_path = "" THEN 
                ASSIGN h_to_path = " Please notify Mysolsource ASAP.".
                 
            OS-COMMAND  SILENT
                        VALUE("MOVE /Y " + h_from_path + " " + h_to_path).
            OS-stat = OS-ERROR.

            IF  OS-stat NE 0 THEN DO:            
                ASSIGN  From-Calling-Pgm        = "XML-DB-Updates.r".
                ASSIGN  e_subject               =  "MOVE Error Status Nbr: " + STRING(OS-stat) + " in program: ".
                ASSIGN  e_message =  "-m " 
                        + "Paragraph att_files-Loopie: has an processing error trying to MOVE the input files"
                        + " \n "  
                        + "from: " + h_from_path
                        + " \n " 
                        + "to  : " + h_to_path + "."
                        + " \n "
                        + "Move Error Status Nbr: " + STRING(OS-stat) + "."
                        + " \n "
                        + "Notify MySolsource Admin asap with this E-Mail message."
                        + " \n " 
                        + "This e-mail was sent from program: " + THIS-PROCEDURE:FILE-NAME + "."
                        + " \n "    
                        + "End of message.".
                                 
                RUN VALUE(SEARCH("Send-EMAIL-Message.r"))
                        (From-Calling-Pgm,
                         e_to-whom,                                   
                         e_subject,
                         e_message,
                         msg-attach-file-name) 
                    NO-ERROR.
        
                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
                   DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error13 - RUN VALUE(SEARCH(." SKIP.      
                      DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                          DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                      END.
                END.
                
            END. /* IF stat NE 0 */

/* create the att_files with the new file path, att_category, att_filedesc & file_name, etc at this time. */
/* NOTE:  The following sequence is what RJ sent to me in the first test data file.
          If he changes the file sequences of what he stores, then the 3 if statements need to be changed also. */
                                                         
            IF  ithree = 1 THEN                 /* find SS .xml - 1st of 3 att_files records for the fs_file_ID from XML . */
                ASSIGN  i-att_category  = "CONVERTED XML"
                        i-att_filedesc  = "Converted XML file."
                        i-att_file_id   = XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id.
/*            ELSE*/
            IF  ithree = 2 THEN                 /* find EDI .txt - 2nd of 3 att_files records for the fs_file_ID from XML . */
                ASSIGN  i-att_category  = "SOURCE EDI"
                        i-att_filedesc  = "EDI raw file."
                        i-att_file_id   = (XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id + 1).
/*            ELSE*/
            IF  ithree = 3 THEN                 /* find PDF .pdf - 1st of 3 att_files records for the fs_file_ID from XML . */ 
                ASSIGN  i-att_category  = "SOURCE TEST"
                        i-att_filedesc  = "Import PDF file."
                        i-att_file_id   = (XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id + 2).
                        
/* FUTURE Change:  Switch to attaching to the TK-MSTR by setting: i-att_table     = "TK_mstr"  i-att_field1    = "TK_mstr.TK_ID" */     
/*            ASSIGN  i-att_table     = "TK_mstr"                                                                                  */
/*                    i-att_field1    = "TK_mstr.TK_ID"                                                                            */
/*                    i-att_value1    = XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID                          /* TK_ID value */        */
/*                    i-att_field2    = "TK_mstr.TK_test_seq"                                                                      */
/*                    i-att_value2    = STRING(XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq)            /* TK_ID_Seq_nbr value */*/

/* SELECT att_file_id, att_table, att_field1, att_field2, att_field3, att_field4, att_field5, att_value1, att_value2, att_value3, 
att_value4, att_value5, att_category, att_filepath, att_filename, att_filedesc, att_deleted, att_created_by, 
att_create_date, att_modified_by, att_modified_date, att_prog_name
FROM "CORE"."PUB"."att_files" where att_table =  'patient_mstr'   or att_table = 'fs_mstr' 
                                    or att_file_id = 16501 or att_file_id = 16502 or att_file_id = 16503; */
                                                    
            ASSIGN  i-att_table     = "patient_mstr"       
                    i-att_field1    = "patient_mstr.patient_ID" 
                    i-att_value1    = STRING(XML_TT_PeopID_Basic_Data.TT_PeopID_people_id)             /* People_ID value */
                    i-att_filename  = h_file_name
                    i-att_filepath  = dir_name + "\". 

            RUN VALUE(SEARCH("SUBatt-ucU.r"))
                        (i-att_file_id,
                         i-att_table,
                         i-att_field1,
                         i-att_value1,
                         i-att_field2,
                         i-att_value2,
                         "",                /* i-att_field3, */
                         "",                /* i-att_value3, */
                         "",                /* i-att_field4, */
                         "",                /* i-att_value4, */
                         "",                /* i-att_field5, */
                         "",                /* i-att_value5, */
                         i-att_category, 
                         i-att_filepath, 
                         i-att_filename,
                         i-att_filedesc,
                         "1",               /* i-att_major_version */
                         "0",               /* i-att_minor_version */
                         OUTPUT o-att_file_id,
                         OUTPUT o-att-find-create,
                         OUTPUT o-att-find-update,
                         OUTPUT o-att-find-success) 
                NO-ERROR.
    
                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
                   DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error14 - RUN VALUE(SEARCH(." SKIP.      
                      DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                          DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                      END.
                END.
                        
            IF  o-att-find-success = NO THEN DO:
                
                ASSIGN  From-Calling-Pgm        = "SUBatt-ucU.r".
                ASSIGN  e_subject               =  "Major Error in program: ".
                ASSIGN  e_message =  "-m " 
                        + "Paragraph att_files-Loopie: has an processing error storing/creating a att_files table record."
                        + " \n "  
                        + "Notify MySolsource Admin asap with this E-Mail message."
                        + " \n " 
                        + "This e-mail was sent from program: " + THIS-PROCEDURE:FILE-NAME + "."
                        + " \n "    
                        + "End of message.".
                                 
                RUN VALUE(SEARCH("Send-EMAIL-Message.r"))
                        (From-Calling-Pgm,
                         e_to-whom,                                   
                         e_subject,
                         e_message,
                         msg-attach-file-name)  
                NO-ERROR.
    
                IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:
                   DISPLAY ERROR-STATUS:NUM-MESSAGES " Run error15 - RUN VALUE(SEARCH(." SKIP.      
                      DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES: 
                          DISPLAY ERROR-STATUS:GET-NUMBER(ix) ERROR-STATUS:GET-MESSAGE(ix) SKIP.
                      END.
                END.
                
            END. /* IF  o-att-find-success = NO */

        END. /* IF  AVAILABLE (att_files) */
        
    END. /* FOR EACH att_files */
              
END.  /*  att_files-Loopie:  FOR EACH XML_TT_PeopID_Basic_Data   WHERE TT_PeopID_ERROR_Flag = "PROCESSED" */                    

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of att_files-Loopie: paragraph." SKIP.
 
PUT STREAM outwardTTD
    c-tests-processed FORMAT ">,>>>,>>9" " : Tests data was selected during this scheduled run." AT 11 SKIP (1).    

PUT STREAM outwardTTD 
    "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1).

PAGE STREAM outwardTTD.
   
OUTPUT STREAM outwardTTD CLOSE.

/*    
/*IF  ITDisplay = YES THEN*/
    FOR EACH XML_TT_PeopID_Basic_Data   NO-LOCK BREAK BY  TT_PeopID_Seq_Nbr_only:     
        IF   XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only = 1 THEN
            PUT STREAM PeopBasic "In PROG: XML-DB-Updates: XML_TT_PeopID_Basic_Data:" SKIP.
            
        PUT STREAM PeopBasic
              XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only       FORMAT ">>>>9"   " "
              XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id     FORMAT ">>>>>>9" " "
              XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level    FORMAT ">>>9"    " "
              XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level     FORMAT ">>>9"    "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_people_id          FORMAT ">>>>>9"  "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag         FORMAT "x(9)"    "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID              FORMAT "x(15)"   " "
              XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq        FORMAT ">>9"     "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_lab_sample_ID      FORMAT "x(15)"   " "
              XML_TT_PeopID_Basic_Data.TT_PeopID_lab_sample_ID_Seq  FORMAT ">>9"     "  "
              XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID             FORMAT "x(15)"   " "  
              XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte FORMAT "99/99/9999" "  "
              XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_end_dte FORMAT "99/99/9999" "  "
              XML_TT_PeopID_Basic_Data.TT-test-family               FORMAT "x(10)"   " " 
              XML_TT_PeopID_Basic_Data.TT-test-type                 FORMAT "x(20)"   " "
              SKIP.
                    
    END. /* 4 each */ 
*/
/*    IF  ITDisplay = YES THEN DO:*/
/*        PUT STREAM PeopBasic                                                  */
/*            "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (2).*/
/*        OUTPUT STREAM PeopBasic CLOSE.                                        */
/*    END. /* 4 each */*/    

/* call the Append program to combine the report files to one report file. */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "HL7-Load-Append-Rpts: paragraph." SKIP.
    
RUN VALUE(SEARCH("HL7-Load-Append-Rpts.r"))                                         /* 1dot1 */
                (c-tests-processed).                                                /* 1dot1 */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of HL7-Load-Append-Rpts: paragraph." SKIP.
    
/* call the Delete Reports program to remove Append files older then 2-weeks. */

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "HL7-Delete-Rpts: paragraph." SKIP.
    
RUN VALUE(SEARCH("HL7-Delete-Rpts.r")).

IF  ITDisplay = YES THEN
    PUT STREAM DBUTrace "end of HL7-Delete-Rpts: paragraph." SKIP.

IF  ITDisplay = YES THEN DO: 
    PUT STREAM DBUTrace " " SKIP.
    PUT STREAM DBUTrace "End of HL7-Load-Main Program." SKIP.
    PUT STREAM DBUTrace " " SKIP.
END. /* IF  ITDisplay = YES  */

IF  ITdisplay = YES  THEN DO: 
    PUT STREAM DBUTrace 
        "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1).  
    OUTPUT STREAM DBUTrace CLOSE.
END. /* IF  ITdisplay = YES */
            
PUT UNFORMATTED  "  End of HL7-Load-Main Program."  SKIP.

/* Re-set the PROBATH back before this program executation. */

PROPATH = ORIGPROPATH.                                                              /* 1dot2 */
    
/* End of Program. */                         