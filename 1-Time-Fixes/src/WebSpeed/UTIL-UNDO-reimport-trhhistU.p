
/*------------------------------------------------------------------------
    File        : UTIL-UNDO-reimport-trhhistU.p
    Purpose     : UNDO or backout the CUST-ID changes made by the previous
                : massive changes.
    Syntax      :

    Description : 
 
    Author(s)   : Harold Luttrell, Sr.
    Created     : Jul 07, 2016
    Notes       :
  ----------------------------------------------------------------------*/

DEFINE VARIABLE updatemode AS LOGICAL INITIAL NO LABEL "Update Mode?" NO-UNDO.

DEFINE VARIABLE infile AS CHARACTER FORMAT "x(65)" LABEL "Input File" 
    INITIAL "C:\Progress\WRK\exports\allpeople-modified-2.txt" NO-UNDO.
    
DEFINE VARIABLE xx AS INTEGER NO-UNDO.     
DEFINE TEMP-TABLE temp_TXT_Data
        FIELD ip-column-A   AS CHARACTER FORMAT "x(60)"
        FIELD ip-column     AS CHARACTER FORMAT "x(60)" EXTENT 43
            INDEX temp_TXT_data AS PRIMARY ip-column-A.
/* 
    ip-column-a    = people_id
    ip-column [1]  = people_firstname   column B
    ip-column [3]  = people_lastname    column D
    ip-column [16]  = people_DOB         column Q
    ip-column [31] = people_dec02  is 108679 example
*/  
DEFINE VARIABLE hold-lastname  LIKE General.people_mstr.people_lastname NO-UNDO.
DEFINE VARIABLE hold-firstname LIKE General.people_mstr.people_firstname NO-UNDO.
DEFINE VARIABLE hold-DOB       LIKE General.people_mstr.people_DOB NO-UNDO.

DEFINE VARIABLE c-ipexcelrds    AS INTEGER LABEL "Old Files"    NO-UNDO.
DEFINE VARIABLE c-nomatch       AS INTEGER LABEL "No New Record"  NO-UNDO.
DEFINE VARIABLE c-matchedSOLD   AS INTEGER LABEL "SOLD Match Found"  NO-UNDO.
DEFINE VARIABLE c-matchedPBC    AS INTEGER LABEL "Paid-By-Cust Match Found"  NO-UNDO.
DEFINE VARIABLE c-matchedVP     AS INTEGER LABEL "VEND-Paid Match Found"  NO-UNDO.
/*DEFINE VARIABLE c-deleted       AS INTEGER LABEL "D-date uped"  NO-UNDO.*/
/*DEFINE VARIABLE c-old-deleted   AS INTEGER NO-UNDO.                     */
DEFINE VARIABLE c-overalls      AS INTEGER NO-UNDO.

DEFINE VARIABLE c-create AS INTEGER NO-UNDO.
DEFINE VARIABLE c-update AS INTEGER NO-UNDO.
DEFINE VARIABLE c-fail AS INTEGER NO-UNDO.

DEFINE STREAM outward.
OUTPUT STREAM outward TO "C:\PROGRESS\WRK\UNDO-reIMPORTtrh_histU.txt".
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    "These are the current TRH_hist SOLD records that were changed". 
EXPORT STREAM outward DELIMITER ";"
    "      after 06/03/16 by Chrissy and should NOT have been changed by Doug's pgm.".
EXPORT STREAM outward DELIMITER ";"
    "InPut -2.txt:"
    "Last Name"         "First Name"
    "DOB"
    "TK_mstr:"
    "TK_ID"             "TK_test_seq"
    "TK_patient_ID"     "TK_cust_ID"
    "trh_hist:"
    "Test Type (item)"
    "TRH_date"
    "Status (action)"
    "TK_ID (serial)"
    "Seq (seq)"                                                          
    "TRH_people_ID"
    .

/* ***************************  Main Block  *************************** */

UPDATE
    updatemode SKIP(1) infile
    WITH FRAME inward WIDTH 80.

INPUT FROM VALUE(infile).

REPEAT:

    CREATE temp_TXT_Data.

    IMPORT DELIMITER ";" temp_TXT_Data.

    ASSIGN c-ipexcelrds  = c-ipexcelrds + 1.

END.

INPUT CLOSE.

DISPLAY c-ipexcelrds c-nomatch c-matchedSOLD c-matchedPBC c-matchedVP
WITH FRAME b WIDTH 80 1 COL.

FOR EACH HHI.TK_mstr WHERE 
/*        tk_id = "HE-31473" AND*/
                    tk_deleted = ? 
              EXCLUSIVE-LOCK:
                  
    c-overalls = c-overalls + 1.
    
    FIND FIRST trh_hist WHERE 
            General.trh_hist.trh_item = HHI.TK_mstr.TK_test_type AND           
            General.trh_hist.trh_serial = HHI.TK_mstr.TK_ID AND 
            General.trh_hist.trh_sequence = HHI.TK_mstr.TK_test_seq AND
            General.trh_hist.trh_date   > DATE("06/02/16")  AND 
          ( General.trh_hist.trh_action =  "SOLD"  OR 
            General.trh_hist.trh_action =  "PAID_BY_CUST"  OR 
            General.trh_hist.trh_action =  "VEND_PAID"  )                
        EXCLUSIVE-LOCK NO-ERROR. 
        
    IF AVAILABLE (trh_hist) THEN DO:
        IF  General.trh_hist.trh_action =  "SOLD" THEN 
            ASSIGN c-matchedsold = c-matchedsold + 1.

        IF  General.trh_hist.trh_action =  "PAID_BY_CUST" THEN 
            ASSIGN c-matchedPBC = c-matchedPBC + 1.

        IF  General.trh_hist.trh_action =  "VEND_PAID" THEN 
            ASSIGN c-matchedVP = c-matchedVP + 1.

        FIND FIRST temp_TXT_Data 
                WHERE   INTEGER(ip-column [31]) = TRH_people_ID 
                NO-LOCK NO-ERROR.
                  
        IF AVAILABLE (temp_TXT_Data) THEN DO:  
            
            FIND FIRST cust_mstr 
                        WHERE cust_id = INTEGER(ip-column-A)
                        NO-LOCK NO-ERROR.
                        
            IF NOT AVAILABLE (cust_mstr) THEN 
                EXPORT STREAM outward DELIMITER ";"
                "MISSING cust_mstr for:"
                HHI.TK_mstr.TK_ID               HHI.TK_mstr.TK_test_seq
                HHI.TK_mstr.TK_patient_ID       INTEGER(ip-column-A)
                "<<<<<".                     
            
            ASSIGN  hold-lastname  = "Not found"
                    hold-firstname = "Not found"
                    hold-DOB       = ?.
                    
            FIND FIRST General.people_mstr WHERE 
                   General.people_mstr.people_id        = HHI.TK_mstr.TK_cust_ID AND 
                   General.people_mstr.people_deleted   = ? NO-LOCK NO-ERROR.
                   
/*                   General.people_mstr.people_lastname  = ip-column [3] AND   /* = people_lastname    column D */*/
/*                   General.people_mstr.people_firstname = ip-column [1] AND   /* = people_firstname   column B */*/
/*                   General.people_mstr.people_DOB       = ip-column [16]      /* = people_DOB        column Q*/  */
            
            IF AVAILABLE (General.people_mstr) THEN 
                ASSIGN  hold-lastname  = General.people_mstr.people_lastname
                        hold-firstname = General.people_mstr.people_firstname
                        hold-DOB       = General.people_mstr.people_DOB.
                                
            EXPORT STREAM outward DELIMITER ";"
                "B-4"
                hold-lastname       hold-firstname      hold-DOB
                "B-4"
                HHI.TK_mstr.TK_ID               HHI.TK_mstr.TK_test_seq
                HHI.TK_mstr.TK_patient_ID       HHI.TK_mstr.TK_cust_ID
                "B-4"
                General.trh_hist.trh_item
                General.trh_hist.trh_date
                General.trh_hist.trh_action
                General.trh_hist.trh_serial
                General.trh_hist.trh_sequence
                General.trh_hist.trh_people_id
                .
                        
            ASSIGN  hold-lastname  = "Not found"
                    hold-firstname = "Not found"
                    hold-DOB       = ?.
                    
            FIND FIRST General.people_mstr WHERE 
                   General.people_mstr.people_id        = INTEGER(ip-column-A) AND 
                   General.people_mstr.people_deleted   = ? NO-LOCK NO-ERROR.
            
            IF AVAILABLE (General.people_mstr) THEN 
                ASSIGN  hold-lastname  = General.people_mstr.people_lastname
                        hold-firstname = General.people_mstr.people_firstname
                        hold-DOB       = General.people_mstr.people_DOB.
                                              
            EXPORT STREAM outward DELIMITER ";"
                "AFT"
                hold-lastname       hold-firstname      hold-DOB
                "AFT"
                HHI.TK_mstr.TK_ID               HHI.TK_mstr.TK_test_seq
                HHI.TK_mstr.TK_patient_ID       INTEGER(ip-column-A)
                "AFT"
                General.trh_hist.trh_item
                General.trh_hist.trh_date
                General.trh_hist.trh_action
                General.trh_hist.trh_serial
                General.trh_hist.trh_sequence
                INTEGER(ip-column-A)
                .
               
            IF updatemode = YES THEN 
                ASSIGN
                    HHI.TK_mstr.TK_cust_ID              = INTEGER(ip-column-A)
                    HHI.TK_mstr.TK_modified_by          = USERID ("HHI")
                    HHI.TK_mstr.TK_modified_date        = TODAY
                    HHI.TK_mstr.TK_prog_name            = SOURCE-PROCEDURE:FILE-NAME
                    
                    General.trh_hist.trh_people_id      = INTEGER(ip-column-A) 
                    General.trh_hist.trh_modified_by    = USERID ("General")
                    General.trh_hist.trh_modified_date  = TODAY
                    General.trh_hist.trh_prog_name      = SOURCE-PROCEDURE:FILE-NAME

            . /*** here is the period. ***/
            
        END.  /* IF AVAILABLE (temp_TXT_Data) */
                
    END. /*** TK_mstr record still AVAILABLE IN the TK_mstr TABLE ***/  
 
/* 
    FIND FIRST trh_hist WHERE 
            General.trh_hist.trh_item = HHI.TK_mstr.TK_test_type AND           
            General.trh_hist.trh_serial = HHI.TK_mstr.TK_ID AND 
            General.trh_hist.trh_sequence = HHI.TK_mstr.TK_test_seq AND
            General.trh_hist.trh_action =  "PAID_BY_CUST" AND 
            General.trh_hist.trh_date   > DATE("06/02/16")              
        EXCLUSIVE-LOCK NO-ERROR. 
        
    IF AVAILABLE (trh_hist) THEN DO:
    
        ASSIGN c-matchedPBC = c-matchedPBC + 1.

        FIND FIRST temp_TXT_Data 
                WHERE   INTEGER(ip-column [31]) = TRH_people_ID 
                NO-LOCK NO-ERROR.
            
        IF AVAILABLE (temp_TXT_Data) THEN DO: 
                    
            FIND FIRST cust_mstr 
            WHERE cust_id = INTEGER(ip-column-A)
            NO-LOCK NO-ERROR.
                        
            IF NOT AVAILABLE (cust_mstr) THEN 
                EXPORT STREAM outward DELIMITER ";"
                "MISSING cust_mstr for:"
                HHI.TK_mstr.TK_ID               HHI.TK_mstr.TK_test_seq
                HHI.TK_mstr.TK_patient_ID       INTEGER(ip-column-A)
                "<<<<<".                     
            
            ASSIGN  hold-lastname  = "Not found"
                    hold-firstname = "Not found"
                    hold-DOB       = ?.
                    
            FIND FIRST General.people_mstr WHERE 
                   General.people_mstr.people_id        = HHI.TK_mstr.TK_cust_ID AND 
                   General.people_mstr.people_deleted   = ? NO-LOCK NO-ERROR.
                   
/*                   General.people_mstr.people_lastname  = ip-column [3] AND   /* = people_lastname    column D */*/
/*                   General.people_mstr.people_firstname = ip-column [1] AND   /* = people_firstname   column B */*/
/*                   General.people_mstr.people_DOB       = ip-column [16]      /* = people_DOB        column Q*/  */
            
            IF AVAILABLE (General.people_mstr) THEN 
                ASSIGN  hold-lastname  = General.people_mstr.people_lastname
                        hold-firstname = General.people_mstr.people_firstname
                        hold-DOB       = General.people_mstr.people_DOB.
                                
            EXPORT STREAM outward DELIMITER ";"
                "B-4"
                hold-lastname       hold-firstname      hold-DOB
                "B-4"
                HHI.TK_mstr.TK_ID               HHI.TK_mstr.TK_test_seq
                HHI.TK_mstr.TK_patient_ID       HHI.TK_mstr.TK_cust_ID
                "B-4"
                General.trh_hist.trh_item
                General.trh_hist.trh_date
                General.trh_hist.trh_action
                General.trh_hist.trh_serial
                General.trh_hist.trh_sequence
                General.trh_hist.trh_people_id
                .

            ASSIGN  hold-lastname  = "Not found"
                    hold-firstname = "Not found"
                    hold-DOB       = ?.
                    
            FIND FIRST General.people_mstr WHERE 
                   General.people_mstr.people_id        = INTEGER(ip-column-A) AND 
                   General.people_mstr.people_deleted   = ? NO-LOCK NO-ERROR.
            
            IF AVAILABLE (General.people_mstr) THEN 
                ASSIGN  hold-lastname  = General.people_mstr.people_lastname
                        hold-firstname = General.people_mstr.people_firstname
                        hold-DOB       = General.people_mstr.people_DOB.
                                              
            EXPORT STREAM outward DELIMITER ";"
                "AFT"
                hold-lastname       hold-firstname      hold-DOB
                "AFT"
                HHI.TK_mstr.TK_ID               HHI.TK_mstr.TK_test_seq
                HHI.TK_mstr.TK_patient_ID       INTEGER(ip-column-A)
                "AFT"
                General.trh_hist.trh_item
                General.trh_hist.trh_date
                General.trh_hist.trh_action
                General.trh_hist.trh_serial
                General.trh_hist.trh_sequence
                INTEGER(ip-column-A)
                .
               
            IF updatemode = YES THEN 
                ASSIGN
                    HHI.TK_mstr.TK_cust_ID              = INTEGER(ip-column-A)
                    HHI.TK_mstr.TK_modified_by          = USERID ("HHI")
                    HHI.TK_mstr.TK_modified_date        = TODAY
                    HHI.TK_mstr.TK_prog_name            = SOURCE-PROCEDURE:FILE-NAME
                    
                    General.trh_hist.trh_people_id      = INTEGER(ip-column-A) 
                    General.trh_hist.trh_modified_by    = USERID ("General")
                    General.trh_hist.trh_modified_date  = TODAY
                    General.trh_hist.trh_prog_name      = SOURCE-PROCEDURE:FILE-NAME

            . /*** here is the period. ***/
            
        END.  /* IF AVAILABLE (temp_TXT_Data) */
                        
    END. /*** TK_mstr record still AVAILABLE IN the TK_mstr TABLE ***/
*/
    
END. /*** FOR EACH HHI.TK_mstrt ***/

DISPLAY c-ipexcelrds c-nomatch c-matchedSOLD c-matchedPBC c-matchedVP c-overalls 
WITH FRAME b WIDTH 80 2 COL.

EXPORT STREAM outward DELIMITER ";" "c-ipexcelrds" "c-nomatch" "c-matchedSOLD" "c-matchedPBC" "c-matchedVP" "c-overalls". 
EXPORT STREAM outward DELIMITER ";" c-ipexcelrds c-nomatch c-matchedSOLD c-matchedPBC c-matchedVP c-overalls. 

OUTPUT STREAM outward CLOSE. 
