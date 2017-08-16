DEFINE VARIABLE x AS INTEGER NO-UNDO.
DEFINE VARIABLE y AS INTEGER NO-UNDO.

FOR EACH catch_all EXCLUSIVE-LOCK:
 DELETE catch_all.
 x = x + 1.
END.

FOR EACH orig_catch_all EXCLUSIVE-LOCK:
 DELETE orig_catch_all.
 y = y + 1.
END.

MESSAGE 
    x " catch_all records deleted" SKIP
    y " orig_catch_all records deleted" 
    VIEW-AS ALERT-BOX BUTTONS OK.
