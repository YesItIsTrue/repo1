
/*------------------------------------------------------------------------
    File        : FSatnR.p
    Purpose     : Report of the fs_mstr and the atn_det tables

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Thu Jan 05 13:23:29 MST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */
OUTPUT TO "C:\PROGRESS\WRK\WhatTheHeck-HL7-Thingsdata.txt".

PUT  "fs_file_ID" AT 1 "fs_parent" AT 12 "fs_child" AT 22  "processed" AT 32 
     "atn_det.atn_name" AT 45 "atn_det.atn_value" AT 65 "atn_det.atn_type" AT 85.
DEFINE VARIABLE len AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE by-pass-data AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE kount AS INTEGER INITIAL 0 NO-UNDO.  
ReportLoop:

FOR EACH fs_mstr WHERE  fs_mstr.fs_deleted = ? 
     /*    fs_mstr.fs_file_ID       = 16735 OR fs_mstr.fs_file_ID = 16736   */
            NO-LOCK,
        EACH atn_det WHERE  atn_det.atn_deleted = ? AND 
                                    /* (atn_det.atn_type = "text" OR atn_det.atn_type = "root" OR
                                    substring(atn_det.atn_name, 1, 5) = 'xmlns' OR 
                                    substring(atn_det.atn_name, 1, 3) = 'xsi' OR 
                                    fs_mstr.fs_parent_level = 0 OR fs_mstr.fs_parent_level = 2)     
                               AND */
                                   atn_det.atn_file_ID = fs_mstr.fs_file_ID AND 
                                   atn_det.atn_node_level = fs_mstr.fs_child_level 
                 NO-LOCK
/*                BREAK BY fs_mstr.fs_child_level BY atn_det.atn_name:*/
/*                BREAK BY atn_det.atn_file_id BY atn_det.atn_node_level :*/
                BREAK BY fs_mstr.fs_file_ID BY fs_mstr.fs_child_level  BY atn_det.atn_node_level : 

/*
FOR EACH fs_mstr /* WHERE fs_mstr.fs_file_ID = 16729 */  /* i-fsatn-id */   
              /*     AND fs_mstr.fs_parent_level = 0 OR fs_mstr.fs_parent_level = 1 */
                   /*AND (fs_mstr.fs_processed   = "NEW" OR fs_mstr.fs_processed   = "CORRECTED") */
             EXCLUSIVE-LOCK,
    EACH atn_det WHERE atn_det.atn_type = "text" AND 
                       atn_det.atn_file_ID = fs_mstr.fs_file_ID AND
                       atn_det.atn_node_level = fs_mstr.fs_child_level  AND 
                      (atn_det.atn_processed   = "NEW" OR atn_det.atn_processed   = "CORRECTED") 
             EXCLUSIVE-LOCK :
*/               

            
/*            IF  atn_det.atn_name        = "TK_test_seq" AND                */
/*                atn_det.atn_node_level  = 2  AND                           */
/*                atn_det.atn_value       = "" THEN                          */
/*                    NEXT ReportLoop.                                       */
/*                                                                           */
/*            IF  atn_det.atn_name = "tkr_det" THEN ASSIGN by-pass-data = NO.*/
/*                                                                           */
/*            IF  atn_det.atn_name = "SNP_ID" THEN ASSIGN by-pass-data = YES.*/
/*                                                                           */
/*            IF  by-pass-data = YES THEN NEXT ReportLoop.                   */
/*                                                                           */
/*            IF  atn_det.atn_name = "item-check" THEN NEXT ReportLoop.      */
/*                                                                           */
/*            IF  atn_det.atn_name = "tkr_item" THEN DO:                     */
/*                ASSIGN len = 0.                                            */
/*                                                                           */
/*                ASSIGN len = (INDEX(atn_det.atn_value, "_call", 1 ) ).     */
/*                                                                           */
/*                IF  len > 0 THEN                                           */
/*                    NEXT ReportLoop.                                       */
/*                                                                           */
/*            END. /* IF  atn_det.atn_name = "tkr_item"  */                  */
 
            ASSIGN kount = (kount + 1).          
            PUT fs_mstr.fs_file_ID AT 1    FORMAT ">>>>9"   
                fs_mstr.fs_parent_level AT 12 FORMAT ">>>9"
                fs_mstr.fs_child_level AT 22 FORMAT ">>>9"
                 
                atn_det.atn_processed AT 33 FORMAT "x(10)"
                atn_det.atn_name FORMAT "x(18)" AT 45
                atn_det.atn_value FORMAT "x(15)" AT 65 
                atn_det.atn_type    FORMAT "x(8)" AT 85 
                SKIP .
             
END.    /** of 4ea. fs_mstr, etc. **/
PUT " " SKIP .
PUT "Selected records = " kount SKIP.
OUTPUT CLOSE.
