
/*------------------------------------------------------------------------
    File        : UTIL-reimport-tkmstrU.p

    Description : This compares the old exported data from an import file and compare 
                    it to the current database being used and bring over any missing 
                    data to the current database. Originally created for the 
                    "EXPORTtk_mstrR.txt" file from 03/Jun/2016.

    Author(s)   : Trae Luttrell
    Created     : Wed Jun 22 11:30:27 EDT 2016
    Notes       : Using the UTIL-renumber-people-U.p as a reference.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE updatemode AS LOGICAL INITIAL NO LABEL "Update Mode?" NO-UNDO.

DEFINE VARIABLE infile AS CHARACTER FORMAT "x(65)" LABEL "Input File" 
    INITIAL "C:\PROGRESS\WRK\03jun16\Step_1dot25\EXPORTtk_mstrR-2.txt" NO-UNDO.

DEFINE VARIABLE c-oldrecords    AS INTEGER LABEL "Old Files"    NO-UNDO.
DEFINE VARIABLE c-onlyold       AS INTEGER LABEL "No New Record"  NO-UNDO.
DEFINE VARIABLE c-matched       AS INTEGER LABEL "Match Found"  NO-UNDO.
DEFINE VARIABLE c-deleted       AS INTEGER LABEL "D-date uped"  NO-UNDO.
DEFINE VARIABLE c-old-deleted   AS INTEGER NO-UNDO.
DEFINE VARIABLE c-overalls      AS INTEGER NO-UNDO.

DEFINE VARIABLE c-create AS INTEGER NO-UNDO.
DEFINE VARIABLE c-update AS INTEGER NO-UNDO.
DEFINE VARIABLE c-fail AS INTEGER NO-UNDO.
/*** tk_mstr upcreate output ***/
DEFINE VARIABLE o-uctkm-id              LIKE TK_mstr.TK_id              NO-UNDO.
DEFINE VARIABLE o-uctkm-create          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE o-uctkm-update          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE o-uctkm-avail           AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE VARIABLE o-uctkm-successful      AS LOGICAL INITIAL NO           NO-UNDO.

DEFINE STREAM outward.
OUTPUT STREAM outward TO "C:\PROGRESS\WRK\reIMPORTtk_mstrU.txt".
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "These are the files which could not be found in the current TK_mstr table".
EXPORT STREAM outward DELIMITER ";"
    "TK_ID"
    "TK_test_seq"
    "TK_test_type"
    "TK_patient_ID"
    "TK_customer_ID"
    "TK_Lab_Sample_ID"                                                             
    "TK_Lab_Seq"
    "Deletion Date".

DEFINE TEMP-TABLE oldTK_mstr LIKE hhi.tk_mstr. 

/* ***************************  Main Block  *************************** */

UPDATE
    updatemode SKIP(1) infile
    WITH FRAME inward WIDTH 80.

INPUT FROM VALUE(infile).

REPEAT: 
    
    CREATE oldTK_mstr.
    
    IMPORT DELIMITER ";" oldTK_mstr.
    
    IF oldtk_mstr.tk_id = "" THEN DELETE oldtk_mstr.
    
    ASSIGN c-oldrecords  = c-oldrecords + 1.
    
END.  

INPUT CLOSE.

DISPLAY c-oldrecords c-onlyold c-matched c-deleted 
WITH FRAME b WIDTH 80 1 COL.

FOR EACH oldtk_mstr NO-LOCK:
    
    c-overalls = c-overalls + 1.
    
    FIND TK_mstr WHERE 
        TK_mstr.TK_ID = OLDtk_mstr.tk_id AND 
        TK_mstr.TK_test_seq = OLDtk_mstr.TK_test_seq 
        EXCLUSIVE-LOCK NO-ERROR. 
        
    IF AVAILABLE (TK_mstr) THEN DO:
    
        ASSIGN c-matched = c-matched + 1.
        
        IF updatemode = YES THEN ASSIGN
            TK_mstr.TK_prof             = IF TK_mstr.TK_prof            <> ? THEN TK_mstr.TK_prof       ELSE oldtk_mstr.tk_prof
            TK_mstr.TK_domestic         = IF TK_mstr.TK_domestic        <> ? THEN TK_mstr.TK_domestic   ELSE oldtk_mstr.TK_domestic
            TK_mstr.TK_cust_ID          = IF TK_mstr.TK_cust_ID         <> 0 THEN TK_mstr.TK_cust_ID    ELSE oldtk_mstr.TK_cust_ID
            TK_mstr.TK_cust_paid        = IF TK_mstr.TK_cust_paid       <> ? THEN TK_mstr.TK_cust_paid  ELSE oldtk_mstr.TK_cust_paid
            TK_mstr.TK_deleted          = IF TK_mstr.TK_deleted         <> ? THEN TK_mstr.TK_deleted    ELSE oldtk_mstr.TK_deleted
            TK_mstr.TK_lbl_print        = IF TK_mstr.TK_lbl_print       <> ? THEN TK_mstr.TK_lbl_print  ELSE oldtk_mstr.TK_lbl_print
            TK_mstr.TK_lab_paid         = IF TK_mstr.TK_lab_paid        <> ? THEN TK_mstr.TK_lab_paid   ELSE oldtk_mstr.TK_lab_paid
            TK_mstr.TK_lab_ID           = IF TK_mstr.TK_lab_ID          <> "" THEN TK_mstr.TK_lab_ID    ELSE oldtk_mstr.TK_lab_ID
            TK_mstr.TK_magento_order    = IF TK_mstr.TK_magento_order   <> "" THEN TK_mstr.TK_magento_order ELSE oldtk_mstr.TK_magento_order
            TK_mstr.TK_cust_paid_date   = IF TK_mstr.TK_cust_paid_date  <> ? THEN TK_mstr.TK_cust_paid_date ELSE oldtk_mstr.TK_cust_paid_date
            TK_mstr.TK__char02          = IF TK_mstr.TK__char02         <> "" THEN TK_mstr.TK__char02   ELSE oldtk_mstr.tk__char02
            TK_mstr.TK__dec01           = IF TK_mstr.TK__dec01          <> 0 THEN TK_mstr.TK__dec01     ELSE oldtk_mstr.tk__dec01
            TK_mstr.TK_modified_by      = USERID ("HHI")
            TK_mstr.TK_modified_date    = TODAY
            TK_mstr.TK_prog_name        = SOURCE-PROCEDURE:FILE-NAME
            . /*** here is the period. Dad. ***/
       
        delete-checker: DO:

            IF TK_mstr.TK_deleted <> ? AND oldtk_mstr.tk_deleted <> ? THEN LEAVE delete-checker.

            ELSE IF TK_mstr.TK_deleted = ? AND oldtk_mstr.tk_deleted = ? THEN LEAVE delete-checker.

            ELSE IF TK_mstr.TK_deleted <> ? AND oldtk_mstr.tk_deleted = ? THEN LEAVE delete-checker.

            ELSE IF TK_mstr.TK_deleted = ? AND oldtk_mstr.tk_deleted <> ? THEN DO:

                ASSIGN c-deleted = c-deleted + 1.

                IF updatemode = YES THEN ASSIGN TK_mstr.TK_deleted = oldtk_mstr.tk_deleted.

            END.

            ELSE LEAVE delete-checker.

        END. /*** of delete checker ***/
                
    END. /*** TK_mstr record still AVAILABLE IN the NEW TK_mstr TABLE ***/
    
    ELSE DO:  /*** no tk_mstr record available  ****/
    
        ASSIGN c-onlyold = c-onlyold + 1.
        
        EXPORT STREAM outward DELIMITER ";"
            oldTK_mstr.TK_ID
            oldTK_mstr.TK_test_seq
            oldTK_mstr.TK_test_type
            oldTK_mstr.TK_patient_ID
            oldTK_mstr.TK_cust_ID
            oldTK_mstr.TK_lab_sample_ID                                                           
            oldTK_mstr.TK_lab_seq
            oldtk_mstr.tk_deleted.
        
/*        IF oldtk_mstr.tk_deleted = ? THEN DO:                                                                                */
/*                                                                                                                             */
/*/*            ASSIGN /*** flag clean out ***/*/                                                                              */
/*/*                o-uctkm-successful = NO    */                                                                              */
/*/*                o-uctkm-create = NO        */                                                                              */
/*/*                o-uctkm-update = NO.       */                                                                              */
/*                                                                                                                             */
/*            IF updatemode = YES THEN RUN VALUE(SEARCH("SUBtkmstrRSTPucU.r"))                                                 */
/*                (oldTK_mstr.TK_ID,                                                                                           */
/*                oldTK_mstr.TK_test_type,                                                                                     */
/*                oldTK_mstr.TK_prof,                                                                                          */
/*                oldTK_mstr.TK_test_seq,                                                                                      */
/*                oldTK_mstr.TK_domestic,                                                                                      */
/*                oldTK_mstr.TK_cust_ID,                                                                                       */
/*                oldTK_mstr.TK_patient_ID,                                                                                    */
/*                oldTK_mstr.TK_lab_sample_ID,                                                                                 */
/*                oldTK_mstr.TK_lab_seq,                                                                                       */
/*                oldTK_mstr.TK_test_age,                                                                                      */
/*                oldTK_mstr.TK_lab_ID,                                                                                        */
/*                oldTK_mstr.TK_status,                                                                                        */
/*                oldTK_mstr.TK_comments,                                                                                      */
/*                oldTK_mstr.TK_notes,                                                                                         */
/*                oldTK_mstr.TK_cust_paid,                                                                                     */
/*                oldTK_mstr.TK_lbl_print,                                                                                     */
/*                oldTK_mstr.TK_lab_paid,                                                                                      */
/*                oldTK_mstr.TK_magento_order,                                                                                 */
/*                oldTK_mstr.TK_cust_paid_date,                                                                                */
/*                OUTPUT o-uctkm-id,                                                                                           */
/*                OUTPUT o-uctkm-create,                                                                                       */
/*                OUTPUT o-uctkm-update,                                                                                       */
/*                OUTPUT o-uctkm-avail,                                                                                        */
/*                OUTPUT o-uctkm-successful).                                                                                  */
/*                                                                                                                             */
/*/*            DISPLAY oldTK_mstr.TK_ID o-uctkm-id o-uctkm-successful o-uctkm-create o-uctkm-update WITH FRAME c WITH 1 COL.*/*/
/*                                                                                                                             */
/*            IF o-uctkm-successful = YES THEN DO:                                                                             */
/*                                                                                                                             */
/*                IF o-uctkm-create = YES THEN DO:                                                                             */
/*                                                                                                                             */
/*                    ASSIGN c-create = c-create + 1.                                                                          */
/*                                                                                                                             */
/*                END. /*** of create ***/                                                                                     */
/*                                                                                                                             */
/*                ELSE ASSIGN c-update = c-update + 1.                                                                         */
/*                                                                                                                             */
/*            END. /*** successful **/                                                                                         */
/*                                                                                                                             */
/*            ELSE DO:                                                                                                         */
/*                                                                                                                             */
/*                c-fail = c-fail + 1.                                                                                         */
/*                                                                                                                             */
/*            END. /*** not successful ***/                                                                                    */
/*                                                                                                                             */
/*        END. /*** not deleted in the old system ***/                                                                         */
/*                                                                                                                             */
/*        ELSE ASSIGN c-old-deleted = c-old-deleted + 1.                                                                       */
        
    END. /*** TK_mstr record IN OLD TK_mstr, NOT IN the NEW TK_mstr ***/
    
END. /*** FOR EACH oldtk_mstr ***/

DISPLAY c-oldrecords c-onlyold c-matched c-overalls 
WITH FRAME b WIDTH 80 2 COL.

OUTPUT STREAM outward CLOSE. 
