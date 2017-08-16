
/*------------------------------------------------------------------------
    File        : UTIL-reimport-trhhistU.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Trae Luttrell
    Created     : Fri Jul 01 18:24:47 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

DEFINE VARIABLE updatemode AS LOGICAL INITIAL NO LABEL "Update Mode?" NO-UNDO.

DEFINE VARIABLE infile AS CHARACTER FORMAT "x(65)" LABEL "Input File" 
    INITIAL "C:\PROGRESS\WRK\03jun16\Step_1dot25\EXPORTtrh_histR-2.txt" NO-UNDO.

DEFINE VARIABLE c-oldrecords    AS INTEGER LABEL "Old Files"    NO-UNDO.
DEFINE VARIABLE c-onlyold       AS INTEGER LABEL "No New Record"  NO-UNDO.
DEFINE VARIABLE c-matched       AS INTEGER LABEL "Match Found"  NO-UNDO.
DEFINE VARIABLE c-deleted       AS INTEGER LABEL "D-date uped"  NO-UNDO.
DEFINE VARIABLE c-old-deleted   AS INTEGER NO-UNDO.
DEFINE VARIABLE c-overalls      AS INTEGER NO-UNDO.

DEFINE VARIABLE c-create AS INTEGER NO-UNDO.
DEFINE VARIABLE c-update AS INTEGER NO-UNDO.
DEFINE VARIABLE c-fail AS INTEGER NO-UNDO.

DEFINE STREAM outward.
OUTPUT STREAM outward TO "C:\PROGRESS\WRK\reIMPORTtrh_histU.txt".
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "These are the files which could not be found in the current TRH_hist table".
EXPORT STREAM outward DELIMITER ";"
    "TRH_ID"
    "Test Type (item)"
    "TRH_date"
    "Status (action)"
    "TK_ID (serial)"
    "Seq (seq)"                                                          
    "TRH_people_ID"
    "Deletion Date".

DEFINE TEMP-TABLE oldTRH_hist LIKE general.trh_hist . 

/* ***************************  Main Block  *************************** */

UPDATE
    updatemode SKIP(1) infile
    WITH FRAME inward WIDTH 80.

INPUT FROM VALUE(infile).

REPEAT: 
    
    CREATE oldTRH_hist.
    
    IMPORT DELIMITER ";" oldTRH_hist.
    
    ASSIGN c-oldrecords  = c-oldrecords + 1.
    
END.  

INPUT CLOSE.

DISPLAY c-oldrecords c-onlyold c-matched c-deleted 
WITH FRAME b WIDTH 80 1 COL.

FOR EACH oldTRH_hist NO-LOCK:
    
    c-overalls = c-overalls + 1.
    
    FIND FIRST trh_hist WHERE 
        General.trh_hist.trh_item = OLDtrh_hist.trh_item AND 
        General.trh_hist.trh_serial = OLDtrh_hist.trh_serial AND 
        General.trh_hist.trh_sequence = OLDtrh_hist.trh_sequence AND
        General.trh_hist.trh_action = OLDtrh_hist.trh_action
        EXCLUSIVE-LOCK NO-ERROR. 
        
    IF AVAILABLE (trh_hist) THEN DO:
    
        ASSIGN c-matched = c-matched + 1.
        
        IF updatemode = YES THEN ASSIGN
            General.trh_hist.trh_item           = IF General.trh_hist.trh_item      <> "" THEN General.trh_hist.trh_item ELSE oldtrh_hist.trh_item
            General.trh_hist.trh_action         = IF General.trh_hist.trh_action    <> "" THEN General.trh_hist.trh_action ELSE OLDtrh_hist.trh_action
            General.trh_hist.trh_qty            = IF General.trh_hist.trh_qty       <> 0 THEN General.trh_hist.trh_qty ELSE OLDtrh_hist.trh_qty
            General.trh_hist.trh_loc            = IF General.trh_hist.trh_loc       <> "" THEN General.trh_hist.trh_loc ELSE OLDtrh_hist.trh_loc
            General.trh_hist.trh_lot            = IF trh_hist.trh_lot               <> "" THEN trh_hist.trh_lot ELSE OLDtrh_hist.trh_lot
            General.trh_hist.trh_serial         = IF General.trh_hist.trh_serial    <> "" THEN trh_hist.trh_serial ELSE OLDtrh_hist.trh_serial
            General.trh_hist.trh_deleted        = IF trh_hist.trh_deleted           <> ? THEN trh_hist.trh_deleted ELSE OLDtrh_hist.trh_deleted 
            General.trh_hist.trh_site           = IF trh_hist.trh_site              <> "" THEN trh_hist.trh_site ELSE OLDtrh_hist.trh_site
            General.trh_hist.trh_sequence       = IF trh_hist.trh_sequence          <> 0 THEN trh_hist.trh_sequence ELSE OLDtrh_hist.trh_sequence
            General.trh_hist.trh_comments       = IF trh_hist.trh_comments          <> "" THEN trh_hist.trh_comments ELSE OLDtrh_hist.trh_comments
            General.trh_hist.trh_date           = IF trh_hist.trh_date              <> ? THEN trh_hist.trh_date ELSE OLDtrh_hist.trh_date
            General.trh_hist.trh_people_id      = IF trh_hist.trh_people_id         <> 0 THEN trh_hist.trh_people_id ELSE OLDtrh_hist.trh_people_id
            General.trh_hist.trh_order          = IF trh_hist.trh_order             <> "" THEN trh_hist.trh_order ELSE OLDtrh_hist.trh_order
            General.trh_hist.trh_other_ID       = IF trh_hist.trh_other_ID          <> "" THEN trh_hist.trh_other_ID ELSE OLDtrh_hist.trh_other_ID
            General.trh_hist.trh_time           = IF trh_hist.trh_time              <> "" THEN trh_hist.trh_time ELSE OLDtrh_hist.trh_time
            General.trh_hist.trh_ref            = IF trh_hist.trh_ref               <> "" THEN trh_hist.trh_ref ELSE OLDtrh_hist.trh_ref
            General.trh_hist.trh__log03         = IF trh_hist.trh__log03            <> ? THEN trh_hist.trh__log03 ELSE OLDtrh_hist.trh__log03
            General.trh_hist.trh_modified_by     = USERID ("HHI")
            General.trh_hist.trh_modified_date   = TODAY
            General.trh_hist.trh_prog_name       = SOURCE-PROCEDURE:FILE-NAME
            . /*** here is the period. Dad. ***/
                
    END. /*** TK_mstr record still AVAILABLE IN the NEW TK_mstr TABLE ***/
    
    ELSE DO:  /*** no tk_mstr record available  ****/
    
        ASSIGN c-onlyold = c-onlyold + 1.
        
        EXPORT STREAM outward DELIMITER ";"
            OLDtrh_hist.trh_id 
            OLDtrh_hist.trh_item
            OLDtrh_hist.trh_date
            OLDtrh_hist.trh_action
            OLDtrh_hist.trh_serial
            OLDtrh_hist.trh_sequence
            OLDtrh_hist.trh_people_id
            OLDtrh_hist.trh_deleted.
            
    END. /*** TK_mstr record IN OLD TK_mstr, NOT IN the NEW TK_mstr ***/
    
END. /*** FOR EACH oldTRH_hist ***/

DISPLAY c-oldrecords c-onlyold c-matched c-overalls 
WITH FRAME b WIDTH 80 2 COL.

OUTPUT STREAM outward CLOSE. 
