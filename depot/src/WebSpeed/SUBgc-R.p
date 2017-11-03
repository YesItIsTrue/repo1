
/*------------------------------------------------------------------------
    File        : SUBgc-R.p
    Purpose     : Find a field name in the gc_det table and return all it's values

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Aug 31 07:56:30 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER i-gc_field_name LIKE gc_det.gc_field_name NO-UNDO.
DEFINE INPUT PARAMETER i-gc_type LIKE gc_det.gc_type NO-UNDO.

DEFINE OUTPUT PARAMETER o-values AS CHARACTER INITIAL "" NO-UNDO.
DEFINE OUTPUT PARAMETER o-displays AS CHARACTER INITIAL "" NO-UNDO.
DEFINE OUTPUT PARAMETER o-num-values AS INTEGER INITIAL 0 NO-UNDO.
DEFINE OUTPUT PARAMETER o-successful AS LOGICAL INITIAL NO NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
CASE i-gc_type:
    WHEN "char" THEN DO:
        FOR EACH gc_det WHERE gc_det.gc_field_name = i-gc_field_name AND gc_det.gc_type = i-gc_type AND gc_det.gc_deleted = ? NO-LOCK
            BY gc_det.gc_value_char:
            ASSIGN 
                o-values = IF o-values = "" THEN gc_det.gc_value_char ELSE o-values + "," + gc_det.gc_value_char
                o-displays = IF o-displays = "" THEN gc_det.gc_display ELSE o-displays + "," + gc_det.gc_display
                o-num-values = o-num-values + 1
                o-successful = TRUE.
        END.
    END.
    WHEN "dec" THEN DO:
        FOR EACH gc_det WHERE gc_det.gc_field_name = i-gc_field_name AND gc_det.gc_type = i-gc_type AND gc_det.gc_deleted = ? NO-LOCK
            BY gc_det.gc_value_dec:
            ASSIGN 
                o-values = IF o-values = "" THEN STRING(gc_det.gc_value_dec) ELSE o-values + "," + STRING(gc_det.gc_value_dec)
                o-displays = IF o-displays = "" THEN gc_det.gc_display ELSE o-displays + "," + gc_det.gc_display
                o-num-values = o-num-values + 1
                o-successful = TRUE.
        END.
    END.
    WHEN "date" THEN DO:
        FOR EACH gc_det WHERE gc_det.gc_field_name = i-gc_field_name AND gc_det.gc_type = i-gc_type AND gc_det.gc_deleted = ? NO-LOCK
            BY gc_det.gc_value_date:
            ASSIGN 
                o-values = IF o-values = "" THEN STRING(gc_det.gc_value_date) ELSE o-values + "," + STRING(gc_det.gc_value_date)
                o-displays = IF o-displays = "" THEN gc_det.gc_display ELSE o-displays + "," + gc_det.gc_display
                o-num-values = o-num-values + 1
                o-successful = TRUE.
        END.
    END.
    WHEN "log" THEN DO:
        FOR EACH gc_det WHERE gc_det.gc_field_name = i-gc_field_name AND gc_det.gc_type = i-gc_type AND gc_det.gc_deleted = ? NO-LOCK
            BY gc_det.gc_value_log:
            ASSIGN 
                o-values = IF o-values = "" THEN STRING(gc_det.gc_value_log) ELSE o-values + "," + STRING(gc_det.gc_value_log)
                o-displays = IF o-displays = "" THEN gc_det.gc_display ELSE o-displays + "," + gc_det.gc_display
                o-num-values = o-num-values + 1
                o-successful = TRUE.
        END.
    END.
END.