
/*------------------------------------------------------------------------
    File        : SUBgc-ucU.p
    Purpose     : Updates / Deletes records in the gc_det table

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Aug 31 07:49:03 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-gc_field_name LIKE gc_det.gc_field_name NO-UNDO.
DEFINE INPUT PARAMETER i-gc_type LIKE gc_det.gc_type NO-UNDO.
DEFINE INPUT PARAMETER i-gc-values AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-gc-displays AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER i-update AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER i-new-gc_field_name LIKE gc_det.gc_field_name NO-UNDO.
DEFINE INPUT PARAMETER i-new-gc_type LIKE gc_det.gc_type NO-UNDO.

DEFINE OUTPUT PARAMETER o-successful AS LOGICAL INITIAL NO NO-UNDO.
DEFINE OUTPUT PARAMETER o-action AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER o-error AS CHARACTER NO-UNDO.

DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE createDate LIKE gc_det.gc_create_date NO-UNDO.
DEFINE VARIABLE createdBy LIKE gc_det.gc_created_by NO-UNDO.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
IF NUM-ENTRIES(i-gc-values) = NUM-ENTRIES(i-gc-displays) THEN DO:
    
    IF i-update = YES THEN DO:
        /* First, delete old records */
        FOR EACH gc_det WHERE 
            gc_det.gc_field_name = i-gc_field_name AND 
            gc_det.gc_type = i-gc_type AND
            gc_det.gc_deleted = ? EXCLUSIVE-LOCK:
                ASSIGN 
                    createDate = gc_det.gc_create_date
                    createdBy = gc_det.gc_created_by.
                DELETE gc_det.
        END.
    END.
    
    DO i = 1 TO NUM-ENTRIES(i-gc-values):
        IF i-update = YES THEN DO:            
            /* Then, create new records with the updated data */
            CREATE gc_det.
            IF i-new-gc_type <> "" THEN
                ASSIGN
                    gc_det.gc_value_char = IF i-new-gc_type = "char" THEN ENTRY(i, i-gc-values) ELSE ""
                    gc_det.gc_value_dec = IF i-new-gc_type = "dec" THEN DECIMAL(ENTRY(i, i-gc-values)) ELSE 0
                    gc_det.gc_value_date = IF i-new-gc_type = "date" THEN DATE(ENTRY(i, i-gc-values)) ELSE ?
                    gc_det.gc_value_log = IF i-new-gc_type = "log" THEN LOGICAL(ENTRY(i, i-gc-values)) ELSE ?.
            ELSE
                ASSIGN
                    gc_det.gc_value_char = IF i-gc_type = "char" THEN ENTRY(i, i-gc-values) ELSE ""
                    gc_det.gc_value_dec = IF i-gc_type = "dec" THEN DECIMAL(ENTRY(i, i-gc-values)) ELSE 0
                    gc_det.gc_value_date = IF i-gc_type = "date" THEN DATE(ENTRY(i, i-gc-values)) ELSE ?
                    gc_det.gc_value_log = IF i-gc_type = "log" THEN LOGICAL(ENTRY(i, i-gc-values)) ELSE ?.
            
            ASSIGN
                gc_det.gc_field_name = IF i-new-gc_field_name <> "" THEN i-new-gc_field_name ELSE gc_det.gc_field_name
                gc_det.gc_display = ENTRY(i, i-gc-displays)
                gc_det.gc_type = IF i-new-gc_type <> "" THEN i-new-gc_type ELSE gc_det.gc_type
                gc_det.gc_create_date = createDate
                gc_det.gc_created_by = createdBy
                gc_det.gc_modified_date = TODAY 
                gc_det.gc_modified_by = USERID("Modules")
                gc_det.gc_prog_name = THIS-PROCEDURE:FILENAME
                o-action = "update"
                o-successful = TRUE.
        END.
        ELSE DO:
            CREATE gc_det.
            ASSIGN
                gc_det.gc_field_name = i-gc_field_name
                gc_det.gc_value_char = IF i-gc_type = "char" THEN ENTRY(i, i-gc-values) ELSE ""
                gc_det.gc_value_dec = IF i-gc_type = "dec" THEN DECIMAL(ENTRY(i, i-gc-values)) ELSE 0
                gc_det.gc_value_date = IF i-gc_type = "date" THEN DATE(ENTRY(i, i-gc-values)) ELSE ?
                gc_det.gc_value_log = IF i-gc_type = "log" THEN LOGICAL(ENTRY(i, i-gc-values)) ELSE ?
                gc_det.gc_display = ENTRY(i, i-gc-displays)
                gc_det.gc_type = i-gc_type
                gc_det.gc_create_date = TODAY 
                gc_det.gc_created_by = USERID("Modules")
                gc_det.gc_prog_name = THIS-PROCEDURE:NAME
                o-action = "create"
                o-successful = TRUE.
        END.
    END.
END.
ELSE DO:
    ASSIGN 
        o-successful = NO
        o-error = "ERROR: Number of values and displays don't match".
END.

